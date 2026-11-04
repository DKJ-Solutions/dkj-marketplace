<#
.SYNOPSIS
    Stop a server the dev-preview hook started once the logon session that started it stays disconnected
    (INBOUND #3569). Started by hooks/dev-preview-sessionstart.ps1 beside every server it starts; never run
    by hand.

.DESCRIPTION
    A disconnected Windows session keeps its processes, so a product started there held its port for every
    later session on the machine -- measured cross-account, where the later session cannot stop it without
    elevation. This watcher runs in the same session as the server it watches. Every -PollSeconds it reads
    its own session's connect state (WTSQuerySessionInformation, WTSConnectState); once that has read
    WTSDisconnected for -GraceSeconds without a break, it stops the server's whole tree (taskkill /T /F) and
    exits. A disconnect counts only after the session was seen connected (#3595): one that reads
    disconnected from the start is in use while disconnected, since the hook ran there. And a WTSDisconnected
    read counts only where two other sources agree with it (#3597): the session is not the active console
    session (WTSGetActiveConsoleSessionId), and WTSEnumerateSessions lists it as disconnected too. Measured
    on a machine with fast user switching, the single read was inverted -- 4 for the active console session,
    0 for a disconnected one -- so a switch away and back could arm the watcher and then stop a server in
    use; a contradiction reads as uncertain (-1), which never stops a server. And a disconnect counts only
    while no Claude Code process runs in the session (#3798, Test-DevPreviewSessionHeld): Claude Code kept
    running in a session switched away from, and the owner read its hub from the other one. It exits as soon as the server
    does, so a server stopped by hand leaves nothing behind. The rules are Get-DevPreviewWatchStep in
    hub/lib/dev-preview-rules.ps1.

      -ProcessId     the cmd.exe the hook launched (the root of the server's tree)
      -StartTicks    that process's start time as FILETIME UTC: a pid reused by another process is not
                     the server, and is never stopped
      -GraceSeconds  how long the session must stay disconnected (default 60)
      -PollSeconds   how often it looks (default 15)
      -ForceState    the TEST override: the connect states to read instead of the session's own, one per
                     poll and the last one repeated, space-separated (e.g. '0 4')
      -ForceHeld     with -ForceState only: '1' reads the session as held by Claude Code, anything else as
                     not held. A forced run never reads the live process table, because the gate that runs
                     the test is itself a Claude Code process in that session
      -OwnerId, -OwnerStartTicks
                     the process the server is tied to (#3620), passed only where a test set
                     DKJ_DEV_PREVIEW_OWNER_PID: once it has exited, or its pid is no longer that process, the
                     server's tree is stopped at the next poll, whatever the session's state. A killed gate
                     never reaches a suite's finally, so without this its servers outlived it.

    Exits 0 in every case: nobody reads its exit code. Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][int]$ProcessId,
    [long]$StartTicks = 0,
    [int]$GraceSeconds = -1,
    [int]$PollSeconds = -1,
    [string]$ForceState = '',
    [string]$ForceHeld = '',
    [int]$OwnerId = 0,
    [long]$OwnerStartTicks = 0
)
$ErrorActionPreference = 'Stop'
try {
    . (Join-Path $PSScriptRoot '..\lib\dev-preview-rules.ps1')
    if ($GraceSeconds -lt 0) { $GraceSeconds = $script:DevPreviewWatchGraceSeconds }
    if ($PollSeconds -lt 1) { $PollSeconds = $script:DevPreviewWatchPollSeconds }

    # Held as a handle, so HasExited answers for THIS process even after its pid is reused.
    $target = [Diagnostics.Process]::GetProcessById($ProcessId)
    if ($StartTicks -and $target.StartTime.ToFileTimeUtc() -ne $StartTicks) { exit 0 }

    # THE OWNER (#3620), held as a handle too. One already gone, or a pid that is now another process, is an
    # owner that has ended: the server is stopped at the first poll.
    $owner = $null
    $ownerGone = $false
    if ($OwnerId -gt 0) {
        try {
            $owner = [Diagnostics.Process]::GetProcessById($OwnerId)
            if ($OwnerStartTicks -and $owner.StartTime.ToFileTimeUtc() -ne $OwnerStartTicks) { $ownerGone = $true }
        } catch { $ownerGone = $true }
    }

    $forced = @($ForceState -split '\s+' | Where-Object { $_ } | ForEach-Object { [int]$_ })
    if (-not $forced.Count) {
        Add-Type -Namespace DkjDevPreview -Name Wts -MemberDefinition @'
[DllImport("wtsapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern bool WTSQuerySessionInformation(IntPtr server, int sessionId, int infoClass, out IntPtr buffer, out int bytes);
[DllImport("wtsapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern bool WTSEnumerateSessions(IntPtr server, int reserved, int version, out IntPtr sessions, out int count);
[DllImport("wtsapi32.dll")]
static extern void WTSFreeMemory(IntPtr memory);
[DllImport("kernel32.dll")]
static extern int WTSGetActiveConsoleSessionId();
[StructLayout(LayoutKind.Sequential)]
struct SessionInfo { public int SessionId; public IntPtr WinStationName; public int State; }
static int Listed(int session) {
    IntPtr list; int count;
    if (!WTSEnumerateSessions(IntPtr.Zero, 0, 1, out list, out count)) { return -1; }
    try {
        int size = Marshal.SizeOf(typeof(SessionInfo));
        for (int i = 0; i < count; i++) {
            SessionInfo s = (SessionInfo)Marshal.PtrToStructure(new IntPtr(list.ToInt64() + (long)i * size), typeof(SessionInfo));
            if (s.SessionId == session) { return s.State; }
        }
        return -1;
    } finally { WTSFreeMemory(list); }
}
public static int ConnectState() {
    int own = System.Diagnostics.Process.GetCurrentProcess().SessionId;
    IntPtr buffer; int bytes; int state;
    // WTS_CURRENT_SERVER_HANDLE, this process's own session, WTSConnectState
    if (!WTSQuerySessionInformation(IntPtr.Zero, own, 8, out buffer, out bytes)) { return -1; }
    try { state = bytes >= 4 ? Marshal.ReadInt32(buffer) : -1; }
    finally { WTSFreeMemory(buffer); }
    if (state != 4) { return state; }
    // A disconnect is acted on only when two other sources agree (#3597): the active console session is
    // never disconnected, and the session list must read WTSDisconnected too. A contradiction is uncertain.
    if (WTSGetActiveConsoleSessionId() == own) { return -1; }
    return Listed(own) == 4 ? 4 : -1;
}
'@
    }

    $since = $null
    $armed = $false
    $poll = 0
    while (-not $target.HasExited) {
        if ($ownerGone -or ($owner -and $owner.HasExited)) {
            & taskkill.exe /T /F /PID $ProcessId 2>&1 | Out-Null
            break
        }
        $state = if ($forced.Count) { $forced[[Math]::Min($poll, $forced.Count - 1)] } else { try { [DkjDevPreview.Wts]::ConnectState() } catch { -1 } }
        $poll++
        # THE HOLD (#3798), read only for a disconnect: the process table is the expensive look. A table that
        # cannot be read is uncertain, and an uncertain read never stops a server.
        $held = $false
        if ($state -eq 4) {
            if ($forced.Count) { $held = ($ForceHeld -eq '1') }
            else {
                try {
                    $own = [Diagnostics.Process]::GetCurrentProcess().SessionId
                    $rows = @(Get-CimInstance Win32_Process -Filter "SessionId = $own" -Property Name, SessionId, CommandLine -ErrorAction Stop)
                    $held = Test-DevPreviewSessionHeld -SessionId $own -Processes $rows
                } catch { $held = $true }
            }
        }
        $step = Get-DevPreviewWatchStep -State $state -Since $since -Now (Get-Date) -GraceSeconds $GraceSeconds -Armed $armed -Held $held
        $armed = $step.Armed
        if ($step.Stop) {
            # Read again just before the kill: a server gone since the last look leaves its pid free for reuse.
            if ($target.HasExited) { break }
            & taskkill.exe /T /F /PID $ProcessId 2>&1 | Out-Null
            break
        }
        $since = $step.Since
        [void]$target.WaitForExit($PollSeconds * 1000)
    }
} catch { }
exit 0
