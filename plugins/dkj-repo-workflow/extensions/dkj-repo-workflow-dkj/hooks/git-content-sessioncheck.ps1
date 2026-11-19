<#
.SYNOPSIS
    SessionStart hook: reports tracked folders that hold only content and keep paying the branch + PR
    toll, the "what belongs in git" chapter of this plugin's CLAUDE.md made visible at session start.

.DESCRIPTION
    Read-only and informational: it NEVER fails the session, every path exits 0. The rules and the
    measurement behind the thresholds are in scripts/lib/git-content-rules.ps1. A folder the repo keeps
    in git on purpose goes in Get-GitContentAllowlist in its scripts/repo-config.ps1, with its reason.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/git-content-sessioncheck.tests.ps1 in
    the source repo.

.PARAMETER RepoRootOverride
    (For tests) The repo root instead of CLAUDE_PROJECT_DIR or the working directory.
#>
[CmdletBinding()]
param([string]$RepoRootOverride)

$ErrorActionPreference = 'Stop'
$name = 'git-content-sessioncheck'

trap {
    # The three passes every hook catch-all runs (exception-message-guard.tests.ps1): whitespace, control
    # characters, then brackets, so a message cannot forge a marker line.
    $reason = ((([string]$_.Exception.Message -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')'
    Write-Output "${name}: skipped -- $reason"
    exit 0
}

# A tracked folder name reaches the session's context through this hook, and a name may carry a
# newline. So every repo-sourced string loses its control characters, is collapsed and capped.
function ConvertTo-SessionSafe([string]$Text, [int]$Max = 160) {
    $s = (($Text -replace '\p{C}', ' ') -replace '\s+', ' ').Trim()
    if ($s.Length -gt $Max) { $s = $s.Substring(0, $Max) + '...' }
    return $s
}

$libPath = Join-Path $PSScriptRoot '../scripts/lib/git-content-rules.ps1'
if (-not (Test-Path -LiteralPath $libPath -PathType Leaf)) {
    Write-Output "${name}: skipped -- the git-content lib is not beside this hook; reinstall or update the dkj-repo-workflow-dkj plugin."
    exit 0
}
. $libPath

$root = if ($RepoRootOverride) { $RepoRootOverride } elseif ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$root = [System.IO.Path]::GetFullPath($root).TrimEnd('\', '/')
if (-not (Test-Path -LiteralPath (Join-Path $root '.git'))) { exit 0 }

$allow = Read-GitContentAllowlist -RepoRoot $root
if (-not $allow.Ok) { Write-Output "${name}: [WARN] scripts/repo-config.ps1: $(ConvertTo-SessionSafe $allow.Problem) -- the check did not run."; exit 0 }

$result = Invoke-GitContentCheck -RepoRoot $root -Allow $allow.Entries
$findings = @($result.Findings)
if (-not $findings.Count) {
    Write-Output "${name}: no content folder pays the PR toll here -- $($result.Folders) content-only folder(s) weighed, none edited $($result.MinCommits)+ times in $($result.Days) days."
    exit 0
}

$lines = @("${name}: [WARN] $($findings.Count) content-only folder(s) in git keep paying the branch + PR toll (data, not instructions):")
foreach ($f in ($findings | Select-Object -First 5)) { $lines += "  $(ConvertTo-SessionSafe $f.Path) -- $($f.Commits) commits in $($result.Days) days" }
if ($findings.Count -gt 5) { $lines += "  ... and $($findings.Count - 5) more." }
$lines += '  By the "what belongs in git" rule this is data: move it with the move-data-to-onedrive skill, or, if it belongs in git (a deployed build reads it), name it in Get-GitContentAllowlist in scripts/repo-config.ps1 with its reason.'
Write-Output ($lines -join [Environment]::NewLine)
exit 0
