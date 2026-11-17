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
      * the fold ship-pr runs is a no-op (the fold script stands down), so nothing lands on the trunk after the merge, and deletes the local
        document and its exclude line once the merge is in -- and where a ship exits before that,
        prune-merged sweeps what no live branch owns (Remove-OrphanBranchDocumentExclude, #4228);
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
# Get-DocumentNewline (#1832): the exclude file's own newline style, read in one place.
. (Join-Path $PSScriptRoot 'document-newline-lib.ps1')

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
        The absolute path of this checkout's info/exclude, or $null. A primary checkout's .git is the
        directory; a linked worktree's .git is a FILE naming its gitdir, whose 'commondir' file names the
        shared directory that holds info/exclude.

        READ FROM THOSE FILES, NEVER FROM `git rev-parse` OUTPUT. In a linked worktree rev-parse answers an
        absolute path, which Windows PowerShell 5.1 decodes with the console code page -- so under a
        non-ASCII path (C:\Users\Zoe-with-a-diaeresis\...) it named a directory that does not exist, and the
        exclude silently went nowhere (measured in review, #4213). The two files are read as UTF-8 and every
        path is joined onto $RepoRoot, which PowerShell already holds correctly.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot)
    $dotGit = Join-Path $RepoRoot '.git'
    $common = $null
    if (Test-Path -LiteralPath $dotGit -PathType Container) {
        $common = $dotGit
    } elseif (Test-Path -LiteralPath $dotGit -PathType Leaf) {
        $m = [regex]::Match([System.IO.File]::ReadAllText($dotGit, [System.Text.Encoding]::UTF8), '(?m)^gitdir:\s*(.+?)\s*$')
        if (-not $m.Success) { return $null }
        $gitDir = $m.Groups[1].Value
        if (-not [System.IO.Path]::IsPathRooted($gitDir)) { $gitDir = Join-Path $RepoRoot $gitDir }
        $commonFile = Join-Path $gitDir 'commondir'
        $common = $gitDir
        if (Test-Path -LiteralPath $commonFile -PathType Leaf) {
            $c = ([System.IO.File]::ReadAllText($commonFile, [System.Text.Encoding]::UTF8)).Trim()
            if ($c) { $common = if ([System.IO.Path]::IsPathRooted($c)) { $c } else { Join-Path $gitDir $c } }
        }
    }
    # The common directory must already exist: this never creates a git directory, only a file inside one.
    if (-not $common -or -not (Test-Path -LiteralPath $common -PathType Container)) { return $null }
    return [System.IO.Path]::GetFullPath((Join-Path (Join-Path $common 'info') 'exclude'))
}

function ConvertTo-ExcludeLine {
    param([Parameter(Mandatory)][string]$RelPath)
    return '/' + $RelPath.Replace([string][char]0x5C, '/').TrimStart('/')
}

function Add-BranchDocumentLocalExclude {
    <#
        Keep the branch document out of every commit by naming it in info/exclude -- local to this clone,
        never committed, so the repo's tree is unchanged. Idempotent; $true when the line is present
        afterwards, $false where the exclude file could not be resolved (the caller warns).

        ONE TREE ONLY, by construction: the document is untracked, so it exists in the working tree that
        new-branch wrote it in. A second worktree of the same branch has none, and open-pr there names the
        PR from -Title instead.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$RelPath)
    $excludePath = Get-GitInfoExcludePath -RepoRoot $RepoRoot
    if (-not $excludePath) { return $false }
    $line = ConvertTo-ExcludeLine -RelPath $RelPath
    $dir = Split-Path -Parent $excludePath
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $raw = if (Test-Path -LiteralPath $excludePath) { [System.IO.File]::ReadAllText($excludePath) } else { '' }
    if (@($raw -split "`r?`n") -contains $line) { return $true }
    $nl = Get-DocumentNewline -Content $raw
    $prefix = if ($raw.Length -gt 0 -and -not $raw.EndsWith("`n")) { $nl } else { '' }
    [System.IO.File]::AppendAllText($excludePath, $prefix + $line + $nl, (New-Object System.Text.UTF8Encoding($false)))
    return $true
}

function Remove-BranchDocumentLocalExclude {
    <#
        The inverse, run once the branch has shipped, so info/exclude does not grow by one line per
        branch. Removes that one line with its own terminator and touches nothing else -- the file is the
        user's, so its line endings and blank lines stay as they were. Silent where there is nothing to remove.
    #>
    param([Parameter(Mandatory)][string]$RepoRoot, [Parameter(Mandatory)][string]$RelPath)
    $excludePath = Get-GitInfoExcludePath -RepoRoot $RepoRoot
    if (-not $excludePath -or -not (Test-Path -LiteralPath $excludePath)) { return }
    $line = ConvertTo-ExcludeLine -RelPath $RelPath
    $raw = [System.IO.File]::ReadAllText($excludePath)
    $rx = '(?m)^' + [regex]::Escape($line) + '(\r?\n|\z)'
    if (-not [regex]::IsMatch($raw, $rx)) { return }
    [System.IO.File]::WriteAllText($excludePath, [regex]::Replace($raw, $rx, ''), (New-Object System.Text.UTF8Encoding($false)))
}

function Remove-OrphanBranchDocumentExclude {
    <#
        The sweep behind ship-pr's own cleanup (issue #4228). ship-pr removes a 'none' branch document and
        its exclude line on two exits only -- its ordinary end and "already merged -- nothing to ship" --
        so the merge-queue exit, the merge-held exit and an `exit 1` after the merge leave both behind, and
        info/exclude grows one line per such branch. prune-merged calls this after its reap, with every
        branch still standing locally or on the remote, and it removes what no live branch owns.

        ONE EXCLUDE LINE AT A TIME, AND ONLY A BRANCH DOCUMENT'S. A line is considered only when its path
        is a per-branch development document (Test-IsPerBranchDocumentPath); every other line in the file
        is the user's and is never read further. Then:

          * the document exists, is UNTRACKED, declares a branch, and that branch is in -LiveBranches
            -> kept: work in flight;
          * the same, but the declared branch is NOT live -> the document is deleted, then its line;
          * the document is tracked, or declares no branch -> kept: not ours to judge;
          * the document is gone -> the line goes: it excludes nothing, and new-branch writes it again
            should the document ever come back.

        Returns one object per removal ({ Path; Branch; What = 'document' | 'line' }), so the caller
        prints and the suite asserts on the same answer. -DryRun returns the same list and changes nothing.

        NEEDS entry-scaffold-lib (the path predicate and the declared-branch reader). Where either is not
        loaded it returns nothing rather than guessing -- this file stays a leaf for park-cycle's sake.
    #>
    param(
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]]$LiveBranches,
        [switch]$DryRun
    )
    $removed = New-Object System.Collections.Generic.List[object]
    if (-not (Test-FunctionDefined 'Test-IsPerBranchDocumentPath') -or -not (Test-FunctionDefined 'Get-BranchFileDeclaredBranch')) { return @() }
    $excludePath = Get-GitInfoExcludePath -RepoRoot $RepoRoot
    if (-not $excludePath -or -not (Test-Path -LiteralPath $excludePath -PathType Leaf)) { return @() }
    $live = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    foreach ($b in $LiveBranches) { if ($b) { [void]$live.Add($b.Trim()) } }

    foreach ($line in @([System.IO.File]::ReadAllText($excludePath) -split "`r?`n")) {
        if (-not $line.StartsWith('/')) { continue }
        $rel = $line.Substring(1)
        if (-not $rel -or -not (Test-IsPerBranchDocumentPath -RelativePath $rel)) { continue }
        $full = Join-Path $RepoRoot ($rel -replace '/', '\')
        $declared = ''
        if (Test-Path -LiteralPath $full -PathType Leaf) {
            $declared = [string](Get-BranchFileDeclaredBranch -Text ([System.IO.File]::ReadAllText($full)))
            if (-not $declared -or $live.Contains($declared)) { continue }
            # Tracked means somebody committed it: an exclude line has no effect on it, and deleting it
            # would leave a dirty tree. ls-files prints the path only when it is tracked.
            $prev = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try { $tracked = @(& git -C $RepoRoot ls-files -- $rel 2>$null) -join '' } finally { $ErrorActionPreference = $prev }
            if ($tracked) { continue }
            if (-not $DryRun) { Remove-Item -LiteralPath $full -Force }
            $removed.Add([pscustomobject]@{ Path = $rel; Branch = $declared; What = 'document' })
        }
        if (-not $DryRun) { Remove-BranchDocumentLocalExclude -RepoRoot $RepoRoot -RelPath $rel }
        $removed.Add([pscustomobject]@{ Path = $rel; Branch = $declared; What = 'line' })
    }
    return @($removed.ToArray())
}
