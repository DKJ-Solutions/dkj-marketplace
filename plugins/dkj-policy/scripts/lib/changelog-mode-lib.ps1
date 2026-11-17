<#
.SYNOPSIS
    The changelog mode (issue #4213): whether this repo keeps a changelog at all. Get-ChangelogModeName
    reads the optional Get-ChangelogMode seam in scripts/repo-config.ps1 -- 'fold' (the default, today's
    route) or 'none' -- and the two exclude helpers keep a branch document out of every commit under 'none'.

.DESCRIPTION
    WHY A SEAM. Measured on a private consumer over the 30 days up to November 17, 2026: 830 commits, 459
    of them (55%) 'park:', 'fold:' or 'merge:', in a repo whose changelog has no reader -- no plugin, no live
    stage, nobody reading its release notes. Nothing a consumer could answer switched that ceremony off, and
    switching it off locally would mean editing the shared scripts, which a consumer must not do.

    WHAT 'none' MEANS, in one place so every reader agrees:
      * new-branch still writes the branch document -- the plan and the DEPLOY section keep their value for
        the session, and open-pr still builds the PR body from it -- but it NEVER COMMITS it: the path is
        named in this clone's .git/info/exclude (local, never committed), so there is no 'park:' commit and
        a `git add -A` cannot sweep the document onto the branch;
      * park-cycle (the cycle-autopark Stop hook) parks nothing;
      * open-pr's branch-entry gates and the CI 'Branch entry' check stand down -- the record moves into
        the PR body rather than into a changelog;
      * ship-pr skips the fold, so nothing lands on the trunk after the merge, and deletes the local
        document and its exclude line once the merge is in;
      * fold-changelog-entry, check-unfolded-entry (and its session check) stand down;
      * cut-release refuses, naming this seam.

    A LEAF, AND DELIBERATELY NOT PART OF seam-lib.ps1. park-cycle runs after every turn and does not load
    seam-lib (measured at 96 ms per dot-source, closeout-gate-lib.ps1 has the numbers), so the resolver
    lives here and needs only the function-table probe.

    Dot-source this file:

        . (Join-Path $PSScriptRoot 'changelog-mode-lib.ps1')

    Pure ASCII (repo convention for .ps1).
#>

. (Join-Path $PSScriptRoot 'command-probe-lib.ps1')

function Get-ChangelogModeName {
    <#
        'fold' or 'none'. Reads the optional Get-ChangelogMode seam; anything it returns other than
        'none' (case-insensitive, trimmed) reads as 'fold', because the safe misreading of a typo is the
        route that keeps the record rather than the one that drops it. A seam that throws reads as 'fold'
        for the same reason.
    #>
    if (-not (Test-FunctionDefined 'Get-ChangelogMode')) { return 'fold' }
    try { $raw = Get-ChangelogMode } catch { return 'fold' }
    if ($null -ne $raw -and ([string]$raw).Trim().ToLowerInvariant() -eq 'none') { return 'none' }
    return 'fold'
}

function Test-ChangelogModeNone {
    <# $true where the repo answered Get-ChangelogMode with 'none' -- see Get-ChangelogModeName. #>
    return ((Get-ChangelogModeName) -eq 'none')
}

function Get-ChangelogModeNoneNote {
    <# The one sentence every stand-down prints, so the seam is named the same way everywhere. #>
    return "this repo answers Get-ChangelogMode with 'none' (scripts/repo-config.ps1): it keeps no changelog, so there is no branch entry to park, gate or fold."
}

function Get-GitInfoExcludePath {
    <#
        The absolute path of this checkout's info/exclude, asked of git so a worktree (whose .git is a
        file) resolves to the common directory's copy. $null where git does not answer.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot)
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & git -C $RepoRoot rev-parse --git-common-dir 2>$null
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $prevEap }
    if ($code -ne 0 -or -not $out) { return $null }
    $dir = ([string]@($out)[0]).Trim()
    if (-not $dir) { return $null }
    if (-not [System.IO.Path]::IsPathRooted($dir)) { $dir = Join-Path $RepoRoot $dir }
    return (Join-Path (Join-Path $dir 'info') 'exclude')
}

function ConvertTo-ExcludeLine {
    param([Parameter(Mandatory)][string]$RelPath)
    return '/' + $RelPath.Replace([string][char]0x5C, '/').TrimStart('/')
}

function Add-BranchDocumentLocalExclude {
    <#
        Keep the branch document out of every commit by naming it in info/exclude -- local to this clone,
        never committed, so the repo's tree is unchanged. Idempotent; $true when the line is present
        afterwards. $RelPath is repo-relative.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$RelPath)
    $excludePath = Get-GitInfoExcludePath -RepoRoot $RepoRoot
    if (-not $excludePath) { return $false }
    $line = ConvertTo-ExcludeLine -RelPath $RelPath
    $dir = Split-Path -Parent $excludePath
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $raw = if (Test-Path -LiteralPath $excludePath) { [System.IO.File]::ReadAllText($excludePath) } else { '' }
    $lines = @($raw -split "`r?`n")
    if ($lines -contains $line) { return $true }
    $prefix = if ($raw.Length -gt 0 -and -not $raw.EndsWith("`n")) { "`n" } else { '' }
    [System.IO.File]::AppendAllText($excludePath, $prefix + $line + "`n", (New-Object System.Text.UTF8Encoding($false)))
    return $true
}

function Remove-BranchDocumentLocalExclude {
    <#
        The inverse, run once the branch has shipped, so info/exclude does not grow by one line per
        branch. Silent where there is nothing to remove.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$RelPath)
    $excludePath = Get-GitInfoExcludePath -RepoRoot $RepoRoot
    if (-not $excludePath -or -not (Test-Path -LiteralPath $excludePath)) { return }
    $line = ConvertTo-ExcludeLine -RelPath $RelPath
    $raw = [System.IO.File]::ReadAllText($excludePath)
    $lines = @($raw -split "`r?`n")
    if ($lines -notcontains $line) { return }
    $kept = @($lines | Where-Object { $_ -ne $line })
    $text = ($kept -join "`n").TrimEnd("`n")
    if ($text) { $text += "`n" }
    [System.IO.File]::WriteAllText($excludePath, $text, (New-Object System.Text.UTF8Encoding($false)))
}
