<#
.SYNOPSIS
    SessionStart hook of the workflow plugin: on session start it says how many open issues THIS gh
    account opened in the repo, and how to sweep only those (issue #4338).

.DESCRIPTION
    Runs in every repo that has the plugin. Like stranded-sweep-sessioncheck.ps1, it runs the mirrored
    check script (${CLAUDE_PLUGIN_ROOT}/scripts/lint/check-open-issues.ps1) in-process against the
    current repo; that script reads the tracker with ONE bounded `gh issue list`. See its header for
    why the nudge exists (sessions file findings as issues, and a person who does not know the
    workflow never sees the receipt) and for the ways it fails quiet.

    Deliberately soft, mirroring its siblings:
      - check script not found -> a notice and done (exit 0);
      - [OPEN] -> the one signal this hook exists to surface, forwarded as one line (data, not
        instructions);
      - [OK] (nothing open) and [SKIP] (no gh, no account, an unreadable tracker) -> SILENT: nothing to
        act on, and a skip is the ordinary state of some machines;
      - a run that could not complete -> one notice, because a crash must not read as a clean tracker;
      - the script ALWAYS ends with exit 0 -- a session start must never strand here.

    Read-only: nothing is created, labelled, commented on or closed.

    Matcher note: hooks.json matches "startup|resume|clear|compact" -- see roster-sessioncheck.ps1's
    docstring for why a startup-only matcher goes silent after the first /compact.

.PARAMETER CheckScriptOverride
    (Optional, for tests) Use this check-script path instead of the ${CLAUDE_PLUGIN_ROOT} one.

.PARAMETER ConsumerPathOverride
    (Optional, for tests) Passed through to check-open-issues.ps1 as -RootOverride.
#>
[CmdletBinding()]
param(
    [string]$CheckScriptOverride = '',
    [string]$ConsumerPathOverride = ''
)

Set-StrictMode -Version Latest

try {
    if ($CheckScriptOverride) {
        $checkScript = $CheckScriptOverride
    } elseif ($env:CLAUDE_PLUGIN_ROOT) {
        $checkScript = Join-Path $env:CLAUDE_PLUGIN_ROOT 'scripts\lint\check-open-issues.ps1'
    } else {
        $checkScript = $null
    }

    if (-not $checkScript -or -not (Test-Path -LiteralPath $checkScript -PathType Leaf)) {
        Write-Host 'open-issues-sessioncheck: check script not found -- check skipped.'
        exit 0
    }

    # Dot-sourced below the "not found" guard, for the reason stranded-sweep-sessioncheck.ps1 gives.
    . (Join-Path $PSScriptRoot '..\scripts\lib\hook-check-lib.ps1')

    # A HASHTABLE, NEVER AN ARRAY -- trap 1 in hook-check-lib.ps1's header.
    $checkArgs = @{}
    if ($ConsumerPathOverride) { $checkArgs['RootOverride'] = $ConsumerPathOverride }

    $result = Invoke-CheckScript -Path $checkScript -Arguments $checkArgs
    $out  = @($result.Output)
    $code = $result.ExitCode

    # Anchored and case-exact (issue #2142): the marker counts only where the check wrote it.
    $open = @(Select-CheckMarkerLine -Output $out -Marker '[OPEN]')

    if ($open.Count -gt 0) {
        $text = ([string]$open[0]).Trim() -replace '^\[OPEN\]\s*', ''
        Write-Host "open-issues-sessioncheck: $text"
    } elseif ($code -eq 0) {
        # [OK] and [SKIP] stay silent: nothing to act on, or a tracker this machine cannot read.
    } else {
        Write-Host "open-issues-sessioncheck: the open-issues check could not complete (exit $code)."
    }
} catch {
    # INLINED STRIP, NOT A LIB CALL -- the reason is in stranded-sweep-sessioncheck.ps1's own catch (#2271).
    $safe = (((($_.Exception.Message) -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')'
    Write-Host ('open-issues-sessioncheck skipped due to an error: ' + $safe.Trim())
}
exit 0
