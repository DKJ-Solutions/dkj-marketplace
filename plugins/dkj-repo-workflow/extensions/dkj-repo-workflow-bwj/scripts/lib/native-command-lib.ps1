<#
.SYNOPSIS
    Invoke-Native -- run one native command, reading its stdout, its exit code and a missing
    executable instead of throwing on them. The one definition the go-live scripts share.

.DESCRIPTION
    WHY THIS IS A LIB (issue #4292). build-golive-block.ps1, notify-live.ps1 and prepare-release.ps1
    each carried their own copy of this function, and the copies had drifted: golive's had no catch
    and returned Output/Code, notify-live's returned stringified Lines, and prepare-release's returned
    Lines trimmed with blank lines dropped. One definition replaces the three; each caller keeps its
    old behaviour through what it reads (Output, Lines) or through -Compact.

    THE SHAPE. '2>$null' under EAP=Stop turns every stderr line into a terminating error, which is the
    trap repo-root-lib.ps1 documents. The command therefore runs inside try/finally with
    $ErrorActionPreference = 'Continue', the shape the repo-wide redirect guard in
    scripts/tests/shared-scripts.tests.ps1 exonerates. Do not restructure it without reading that guard.

    AND A CATCH, because a MISSING executable is not an exit code: it throws CommandNotFoundException,
    which would take the run down at the first gh call instead of reporting that step as skipped --
    measured by prepare-release.ps1's copy edit. It comes back as a failed call (Code -1) with no output.

    API: Invoke-Native -Command { ... } [-Compact]
      Output  the raw stdout objects, as an array
      Lines   stdout stringified, one string per line, blank lines kept; with -Compact each line is
              trimmed and blank lines are dropped
      Code    the exit code, or -1 where the executable is missing

    Pure ASCII (repo convention for .ps1).
#>

function Invoke-Native {
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Command,
        [switch]$Compact
    )
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $out = @()
    try {
        $out  = & $Command 2>$null
        $code = $LASTEXITCODE
    } catch {
        $code = -1
    } finally {
        $ErrorActionPreference = $prev
    }
    $lines = @(@($out) | ForEach-Object { "$_" })
    if ($Compact) { $lines = @($lines | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }
    return [pscustomobject]@{ Output = @($out); Lines = $lines; Code = $code }
}
