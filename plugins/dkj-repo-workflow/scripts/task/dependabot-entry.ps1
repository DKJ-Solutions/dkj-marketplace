<#
.SYNOPSIS
    Writes the branch development document onto a Dependabot PR's own branch, so the PR passes the
    branch-entry CI gate (inbound #4287).

.DESCRIPTION
    THE PROBLEM. Dependabot opens its pull requests itself and knows nothing of this workflow's entry
    convention: there is no written branch development document on its branch, so the branch-entry gate
    refuses the PR. Fixing that by hand is the same handful of steps every time, which is exactly what
    the automation-first rule says to script.

    THE GATE STAYS. This script relaxes nothing: it is deliberately NOT an exemption for `dependabot/*`
    in the gate. The entry is where the distinction a lockfile diff does not show lands -- whether the
    package sits in the dev or the production branch of the lockfile, where it enters, and whether
    there is a real attack route. An exemption would remove exactly that explanation. So the script
    takes over only the mechanical part; the body stays handwork.

    WHAT IT DOES, in this order, stopping at the first objection:
      1. Checks that the working tree is clean.
      2. Reads the PR with gh (number, title, branch, state, author, fork flag). Refuses a PR that is
         not open, comes from a fork (that branch cannot be pushed from here), or is not from
         Dependabot (`app/dependabot` or `dependabot[bot]`): this script pushes to a branch it did not
         create, which is only acceptable on the bot's own branches.
      3. Checks the branch out. A local branch that is AHEAD of origin is never touched: it holds work
         this script does not know about, so it stops. Otherwise the local branch is fast-forwarded
         (ff-only), or created tracking origin when there is no local one.
      4. Merges the current origin/<trunk> into the branch, unless -SkipMergeMain. A Dependabot branch is
         often days old; without this the gates run against a stale base and the diff against the trunk
         says more than the PR changes. On a conflict the merge is aborted and the script stops.
      5. Has the shared new-branch.ps1 write the branch development document. new-branch uses the name
         EXACTLY as given and resumes a branch that already exists (it checks it out and skips what is
         there), so a branch whose name this script does not own is not renamed or duplicated: the
         `<name>-v1` completion that once created a second branch for a Dependabot PR (#1224) was
         removed from new-branch in September 2026, and this script passes the PR's own branch name
         and nothing else. The branch type for an unknown prefix falls back to the repo's fallback type.
         new-branch is run with -NoPush: this script makes the one commit and the one push itself.
      6. Inserts the three bump questions into the DEPLOY section above its first **Score:** line, only
         while the DEPLOY body is still unwritten; whatever a person already wrote stays.
      7. Commits ONLY the branch document (`git commit -F <file> -- <path>`) and pushes the branch,
         unless -NoPush.

    WHAT IT DOES NOT DO. It runs no gates, does not merge, does not fold, and does not fill the reach
    scores: which tier a bump touches is the judgement this script knows nothing about. The output
    prints those steps as the follow-up.

    Where the document lives is asked of the shared lib (Resolve-BranchFilePath), never written here;
    the repo root, trunk name and repo name come from the same seams the sibling scripts read.

    Pure ASCII (repo convention for .ps1).

.PARAMETER PullRequest
    The number of the Dependabot PR.

.PARAMETER Title
    Title for the entry. Default: the PR title. It becomes the entry's branch title and so the PR title
    when the PR later goes through open-pr. A double quote in it is refused.

.PARAMETER Intent
    The body of the DEPLOY section. Default: a scaffold with the three questions every bump should
    answer; answer them by hand before the merge.

.PARAMETER SkipMergeMain
    Skip step 4 (do not merge the trunk into the branch). Only sensible when the trunk has not moved
    since the PR was opened.

.PARAMETER NoPush
    Commit the branch document but do not push.

.PARAMETER PrJson
    TEST SEAM. The JSON `gh pr view --json number,title,headRefName,state,author,isCrossRepository`
    would print, so a suite can exercise the refusals without a network. Not for typing.

.EXAMPLE
    ./scripts/task/dependabot-entry.ps1 -PullRequest 215
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][int]$PullRequest,
    [string]$Title = '',
    [string]$Intent = '',
    [switch]$SkipMergeMain,
    [switch]$NoPush,
    [string]$PrJson = ''
)
$ErrorActionPreference = 'Stop'

# THE SOURCE-REPO GUARD (same block as park-branch.ps1): refuses a released copy running in the repo
# that maintains it. Guarded dot-source, so a tree without the lib behaves as before.
$guardLib = Join-Path $PSScriptRoot '..\lib\source-repo-guard-lib.ps1'
if (Test-Path -LiteralPath $guardLib -PathType Leaf) { . $guardLib; Assert-OwnCopy -ScriptPath $PSCommandPath }

# Repo root, dual context: CLAUDE_PROJECT_DIR in a consumer running the plugin mirror, else the git root.
# No --show-toplevel (repo-root-lib's reason); the refusing resolver is the one the siblings use.
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
$repoRoot = Resolve-RepoRootOrFail -ScriptName 'dependabot-entry.ps1'

# Native calls go through Invoke-NativeCapture (git writes progress to stderr, which under EAP=Stop
# would be a terminating NativeCommandError before the exit code could be judged).
. (Join-Path $PSScriptRoot '..\lib\native-capture-lib.ps1')

# The repo-owned seams, optional here: Get-RepoName / Get-PrMergeMethod / Get-LintScript from
# repo-config.ps1 and Get-BranchInfo from branch-info.ps1. new-branch.ps1 (step 5) is what insists on
# branch-info.ps1; this script degrades without either. Loaded BEFORE the entry lib, whose probes read them.
$configPath = Join-Path $repoRoot 'scripts\repo-config.ps1'
if (Test-Path -LiteralPath $configPath -PathType Leaf) { . $configPath }
$branchInfoPath = Join-Path $repoRoot 'scripts\lib\branch-info.ps1'
if (Test-Path -LiteralPath $branchInfoPath -PathType Leaf) { . $branchInfoPath }

# Get-BranchFilePaths / Resolve-BranchFilePath, Split-Development, Get-DevelopmentEntryPattern and
# Get-BranchTrunkName: the one definition of where the document is and where its DEPLOY section starts.
. (Join-Path $PSScriptRoot '..\lib\entry-scaffold-lib.ps1')

# $ghRepo, not $repoName: repo-config backs Get-RepoName with $script:RepoName, and at script top level a
# same-named local IS that variable (PowerShell names are case-insensitive).
$ghRepo = ''
if (Test-FunctionDefined 'Get-RepoName') { $ghRepo = [string](Get-RepoName) }

function Stop-Run {
    param([string]$Message)
    Write-Error $Message
    exit 1
}

function Invoke-GitHere {
    <# git against the resolved root. Output is the merged text lines; the exit code is the caller's to judge. #>
    param([string[]]$GitArgs, [switch]$Utf8)
    $res = Invoke-NativeCapture -FilePath 'git' -Arguments (@('-C', $repoRoot) + $GitArgs) -Utf8:$Utf8
    return $res
}

function Show-Output {
    param($Res)
    foreach ($l in @($Res.Output)) { if ("$l".Trim()) { Write-Host "  $l" -ForegroundColor DarkGray } }
}

function Get-CommitCount {
    <# 'git rev-list --count A..B' as a number; a failed call is a refusal, not a conversion error. #>
    param([string]$Range)
    $res = Invoke-GitHere -GitArgs @('rev-list', '--count', $Range) -Utf8
    $text = (@($res.Output) -join '').Trim()
    if ($res.ExitCode -ne 0 -or $text -notmatch '^\d+$') {
        Stop-Run "Could not count the commits in '$Range'; do both refs exist?"
    }
    return [int]$text
}

function Get-DependabotPrRefusal {
    <#
        The judgement on a PR as gh described it: '' when this script may work on it, else the refusal.
        A function so the verdicts can be tested without a network or a repository.
    #>
    param([Parameter(Mandatory)]$Pr, [Parameter(Mandatory)][int]$Number)
    if ([string]$Pr.state -ne 'OPEN') {
        return "PR #$Number is '$($Pr.state)'. This script only works on an open PR."
    }
    if ($Pr.isCrossRepository) {
        return "PR #$Number comes from a fork; that branch cannot be pushed from here. Resolve it by hand."
    }
    # Dependabot is 'app/dependabot' in gh's author.login and 'dependabot[bot]' in git. Deliberately
    # strict: this script pushes to a branch it did not create, which is acceptable only on the bot's own.
    $author = [string]$Pr.author.login
    if ($author -notmatch '(^|/)dependabot(\[bot\])?$') {
        return "PR #$Number is from '$author', not from Dependabot. For your own work, open a branch with new-branch.ps1."
    }
    $head = [string]$Pr.headRefName
    if (-not $head -or $head.StartsWith('-')) {
        return "PR #$Number names no usable head branch ('$head')."
    }
    return ''
}

function Test-DeployBodyWritten {
    <#
        Has anybody written the DEPLOY body yet? The boundary comes from Split-Development, and what is
        counted is prose: a guidance comment, a blank line, a heading and the bare **Score:** line are no
        answer. Test-BranchChangelogIsFilled is NOT this test -- it answers "does the document belong to a
        branch", which is true right after new-branch.
    #>
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $false }
    $split = Split-Development -Text ([System.IO.File]::ReadAllText($Path))
    if (-not $split.Found) { return $false }
    $inComment = $false
    foreach ($line in ([string]$split.Entry -split '\r?\n')) {
        $trim = $line.Trim()
        if (-not $inComment -and $trim.StartsWith('<!--')) {
            if (-not $trim.EndsWith('-->')) { $inComment = $true }
            continue
        }
        if ($inComment) { if ($trim.EndsWith('-->')) { $inComment = $false }; continue }
        if ($trim -eq '') { continue }
        if ($trim.StartsWith('#')) { continue }
        if ($trim -eq '**Score:**') { return $false }
        return $true
    }
    return $false
}

# ---- 1. A clean working tree ----------------------------------------------------------------------
$status = Invoke-GitHere -GitArgs @('status', '--porcelain') -Utf8
if ($status.ExitCode -ne 0) { Stop-Run "git status failed in $repoRoot." }
if (@($status.Output | Where-Object { "$_".Trim() }).Count -gt 0) {
    Stop-Run 'The working tree is not clean. Commit or stash your changes first.'
}

# ---- 2. Read and judge the PR ---------------------------------------------------------------------
if ($PrJson) {
    $json = $PrJson
} else {
    $ghArgs = @('pr', 'view', "$PullRequest")
    if ($ghRepo) { $ghArgs += @('--repo', $ghRepo) }
    $ghArgs += @('--json', 'number,title,headRefName,state,author,isCrossRepository')
    $read = Invoke-NativeCapture -FilePath 'gh' -Arguments $ghArgs -Utf8 -DiscardStderr
    if ($read.ExitCode -ne 0) {
        # Re-ask with stderr kept, so the refusal can carry gh's own reason (no auth, no such PR, ...).
        $why = Invoke-NativeCapture -FilePath 'gh' -Arguments $ghArgs -Utf8
        Stop-Run "Could not read PR #$PullRequest with gh (repo: $(if ($ghRepo) { $ghRepo } else { 'per gh' })).`n  gh said: $((@($why.Output) -join ' ').Trim())"
    }
    $json = (@($read.Output) -join "`n")
}
try { $pr = $json | ConvertFrom-Json } catch { Stop-Run "The PR data for #$PullRequest is not valid JSON." }
$refusal = Get-DependabotPrRefusal -Pr $pr -Number $PullRequest
if ($refusal) { Stop-Run $refusal }

$branch = [string]$pr.headRefName
$author = [string]$pr.author.login
$cycleRel = [string](Resolve-BranchFilePath -Kind 'File' -RepoRoot $repoRoot -Branch $branch)
if (-not $Title) { $Title = [string]$pr.title }
# A double quote would break the argument hand-over to the shared script; refuse rather than half-create.
if ($Title.Contains('"')) {
    Stop-Run 'The title contains a double quote, which breaks the hand-over to new-branch. Pass a -Title without one.'
}

# The entry type: the repo's own table where it knows the prefix, else its fallback type, else Chore.
# 'dependabot' is no prefix of the shared table, so the fallback is the normal case.
$entryType = ''
if (Test-FunctionDefined 'Get-BranchInfo') {
    $info = Get-BranchInfo -Branch $branch
    if ($info.IsKnown) { $entryType = [string]$info.Type }
}
if (-not $entryType -and (Test-FunctionDefined 'Get-EntryFallbackType')) { $entryType = [string](Get-EntryFallbackType) }
if (-not $entryType) { $entryType = 'Chore' }

Write-Host "PR #$PullRequest ($author)" -ForegroundColor Cyan
Write-Host "  branch   : $branch" -ForegroundColor Gray
Write-Host "  document : $cycleRel (type $entryType)" -ForegroundColor Gray

# ---- 3. Check the branch out ----------------------------------------------------------------------
$fetch = Invoke-GitHere -GitArgs @('fetch', 'origin', '--prune')
if ($fetch.ExitCode -ne 0) { Show-Output $fetch; Stop-Run 'git fetch origin failed.' }
$remoteProbe = Invoke-GitHere -GitArgs @('rev-parse', '--verify', '--quiet', "refs/remotes/origin/$branch")
if ($remoteProbe.ExitCode -ne 0) { Stop-Run "origin has no branch '$branch' (merged or deleted since the PR was read?)." }
$localProbe = Invoke-GitHere -GitArgs @('rev-parse', '--verify', '--quiet', "refs/heads/$branch")
if ($localProbe.ExitCode -eq 0) {
    $co = Invoke-GitHere -GitArgs @('checkout', $branch)
    if ($co.ExitCode -ne 0) { Show-Output $co; Stop-Run "Could not switch to branch '$branch'." }
    # A local branch ahead of origin holds work this script does not know about: never touch it.
    $ahead = Get-CommitCount "origin/$branch..$branch"
    if ($ahead -gt 0) {
        Stop-Run "Local branch '$branch' is $ahead commit(s) ahead of origin. Find out what is there first; this script never overwrites your own work."
    }
    $ff = Invoke-GitHere -GitArgs @('merge', '--ff-only', "origin/$branch")
    if ($ff.ExitCode -ne 0) { Show-Output $ff; Stop-Run "Could not fast-forward '$branch' to origin." }
} else {
    $co = Invoke-GitHere -GitArgs @('checkout', '-b', $branch, '--track', "origin/$branch")
    if ($co.ExitCode -ne 0) { Show-Output $co; Stop-Run "Could not check out '$branch' from origin." }
}

# ---- 4. Merge the current trunk in ----------------------------------------------------------------
if (-not $SkipMergeMain) {
    $trunk = Get-BranchTrunkName
    $behind = Get-CommitCount "$branch..origin/$trunk"
    if ($behind -gt 0) {
        Write-Host "Branch is $behind commit(s) behind $trunk -> merging origin/$trunk in..." -ForegroundColor Yellow
        $mg = Invoke-GitHere -GitArgs @('merge', "origin/$trunk", '--no-edit')
        if ($mg.ExitCode -ne 0) {
            $null = Invoke-GitHere -GitArgs @('merge', '--abort')
            Stop-Run "Merging origin/$trunk into '$branch' conflicted; the merge was aborted. Resolve it by hand (or run with -SkipMergeMain to keep the old base on purpose)."
        }
    } else {
        Write-Host "Branch is up to date with $trunk." -ForegroundColor Gray
    }
}

# ---- 5. The document, via the shared new-branch.ps1 -----------------------------------------------
# -NoPush: new-branch would otherwise commit and push its own park commit; this script makes the one
# commit (step 7) after the questions are in. -SkipStaleBase: the base is this branch's own history, not
# a base being chosen. The name goes in exactly as the PR carries it (no -v1; see the header).
if (-not $Intent) {
    $Intent = @"
TODO: complete this before the merge. What a lockfile diff does NOT show, and what belongs here:

1. Where the package enters (the dependency path, e.g. the package manager's "why" or "list" command)
   and whether it sits in the dev branch of the lockfile or the production branch.
2. Why the bump is worth taking: security advisories and their reach, or plain maintenance -- and
   whether this project has a real attack route.
3. The outcome of the gates, including the package manager's audit before and after.

Source: https://github.com/$ghRepo/pull/$PullRequest
"@
}
$alreadyWritten = Test-DeployBodyWritten -Path (Join-Path $repoRoot ($cycleRel -replace '/', '\'))

$newBranch = Join-Path $PSScriptRoot 'new-branch.ps1'
if (-not (Test-Path -LiteralPath $newBranch -PathType Leaf)) {
    Stop-Run "Cannot find new-branch.ps1 next to this script -- expected at $newBranch"
}
& $newBranch -Name $branch -Title $Title -RepoRoot $repoRoot -NoPush -SkipStaleBase
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
    Stop-Run "The shared new-branch.ps1 ended with exit $LASTEXITCODE -- the branch document was not written."
}

# ---- 6. The three questions, in the DEPLOY body ---------------------------------------------------
$cycleFile = Join-Path $repoRoot ($cycleRel -replace '/', '\')
if (-not (Test-Path -LiteralPath $cycleFile -PathType Leaf)) {
    Stop-Run "new-branch did not leave the branch document at '$cycleRel'."
}
if (-not $alreadyWritten) {
    $lines = @([System.IO.File]::ReadAllLines($cycleFile))
    $deployRx = Get-DevelopmentEntryPattern
    $head = -1
    for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match $deployRx) { $head = $i; break } }
    $score = -1
    if ($head -ge 0) {
        for ($i = $head + 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '**Score:**') { $score = $i; break } }
    }
    if ($score -lt 0) {
        Write-Host "WARNING: no DEPLOY section with a Score line in '$cycleRel'; the questions were not inserted." -ForegroundColor Yellow
    } else {
        $body = New-Object System.Collections.Generic.List[string]
        foreach ($l in ($Intent -split "`r?`n")) { $body.Add($l) }
        $body.Add('')
        $out = @()
        $out += $lines[0..($score - 1)]
        $out += $body.ToArray()
        $out += $lines[$score..($lines.Count - 1)]
        [System.IO.File]::WriteAllLines($cycleFile, $out, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "The bump questions are in the DEPLOY section of '$cycleRel'." -ForegroundColor Green
    }
} else {
    Write-Host 'The DEPLOY section already carries text -- the questions were not inserted again.' -ForegroundColor Gray
}

# ---- 7. Commit only the document, then push -------------------------------------------------------
$pending = Invoke-GitHere -GitArgs @('status', '--porcelain', '--', $cycleRel) -Utf8
if (@($pending.Output | Where-Object { "$_".Trim() }).Count -eq 0) {
    Write-Host 'The document was already committed and nothing new needs committing.' -ForegroundColor Yellow
} else {
    $add = Invoke-GitHere -GitArgs @('add', '--', $cycleRel)
    if ($add.ExitCode -ne 0) { Show-Output $add; Stop-Run "git add of $cycleRel failed." }
    # English, via a message file and never -m: a branch or title may carry characters that break argv.
    $commitType = $entryType.ToLowerInvariant()
    $msgFile = [System.IO.Path]::GetTempFileName()
    try {
        [System.IO.File]::WriteAllText($msgFile, "${commitType}: changelog entry for Dependabot PR #$PullRequest`n", (New-Object System.Text.UTF8Encoding $false))
        $cm = Invoke-GitHere -GitArgs @('commit', '-F', $msgFile, '--', $cycleRel)
    } finally {
        Remove-Item -LiteralPath $msgFile -Force -ErrorAction SilentlyContinue
    }
    if ($cm.ExitCode -ne 0) { Show-Output $cm; Stop-Run 'git commit failed.' }
}

if ($NoPush) {
    Write-Host '-NoPush: not pushed. Push yourself with: git push' -ForegroundColor Yellow
} else {
    $push = Invoke-GitHere -GitArgs @('push', 'origin', $branch)
    if ($push.ExitCode -ne 0) { Show-Output $push; Stop-Run "git push of '$branch' failed." }
}

$lint = if (Test-FunctionDefined 'Get-LintScript') { [string](Get-LintScript) } else { "the repo's lint gate" }
$method = if (Test-FunctionDefined 'Get-PrMergeMethod') { [string](Get-PrMergeMethod) } else { 'merge' }
Write-Host ''
Write-Host 'Done. Follow-up (not done by this script):' -ForegroundColor Green
Write-Host "  1. Answer the three questions in the DEPLOY section of $cycleRel -- they are already in it." -ForegroundColor Gray
Write-Host '  2. Fill the reach tiers: tier 0 always a number; tiers 1 and 2 a number, or N/A with a reason.' -ForegroundColor Gray
Write-Host "  3. Update the PLAN/CREATE/TEST steps in $cycleRel; no step may stay '- [ ]'." -ForegroundColor Gray
Write-Host "  4. Run the gates: $lint and the test suites." -ForegroundColor Gray
Write-Host '  5. Commit that, wait for the checks and ship:' -ForegroundColor Gray
Write-Host "     gh pr merge $PullRequest$(if ($ghRepo) { " --repo $ghRepo" }) --$method --delete-branch" -ForegroundColor Gray
Write-Host '  6. Fold the entry into the changelog (the fold step of the branch flow).' -ForegroundColor Gray
