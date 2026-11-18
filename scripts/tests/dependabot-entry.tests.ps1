<#
.SYNOPSIS
    Regression tests for scripts/task/dependabot-entry.ps1 (inbound #4287): writing the branch
    development document onto a Dependabot PR's own branch.

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell. The fixture, the child runner and the asserts
    are new-branch-fixture.ps1's (this script calls the real new-branch.ps1, so it needs the same
    throwaway repo with a bare origin):

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/dependabot-entry.tests.ps1

    Nothing here touches a network: the PR is handed over through the -PrJson test seam instead of gh.

    THE CASES: the refusals reachable without a remote (dirty tree, PR not open, fork, not Dependabot,
    a quote in the title), then the whole run against a fixture origin that carries a `dependabot/...`
    branch the trunk has moved past -- the trunk is merged in, the document is written under the PR's OWN
    branch name (no `-v1` sibling is created, #1224), only the document is committed, the commit is
    pushed -- then a second run (nothing is inserted twice), a local branch that is ahead of origin
    (refused, work untouched), and -NoPush. The last case runs the plugin mirror from its own directory.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'new-branch-fixture.ps1')

$DepSrc    = Join-Path $RepoRoot 'scripts\task\dependabot-entry.ps1'
$DepMirror = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\scripts\task\dependabot-entry.ps1'
$Branch    = 'dependabot/npm_and_yarn/postcss-8.5.6'

function New-DepFixture {
    <# new-branch-fixture's repo (new-branch.ps1 and its libs, an initial commit on main), plus this script. #>
    param([Parameter(Mandatory = $true)][string]$Label)
    $dir = New-Fixture -Label $Label
    Copy-Item -LiteralPath $DepSrc -Destination (Join-Path $dir 'scripts\task\dependabot-entry.ps1') -Force
    Add-FixtureRepoConfig -Dir $dir -RepoName 'example/fixture'
    # Committed, so the tree is clean when the script starts.
    Invoke-FixtureGitIn $dir add -A
    Invoke-FixtureGitIn $dir commit -q -m 'fixture: scripts and config'
    return $dir
}

function New-PrJson {
    param([string]$State = 'OPEN', [string]$Author = 'app/dependabot', [bool]$Fork = $false, [string]$Head = $Branch, [string]$Title = 'Bump postcss from 8.5.5 to 8.5.6')
    return ([pscustomobject]@{
        number = 77; title = $Title; headRefName = $Head; state = $State
        author = [pscustomobject]@{ login = $Author }; isCrossRepository = $Fork
    } | ConvertTo-Json -Compress)
}

function Invoke-Dep {
    param([Parameter(Mandatory = $true)][string]$Dir, [string]$Json = (New-PrJson), [string[]]$Extra = @(), [string]$ScriptPath = '')
    if (-not $ScriptPath) { $ScriptPath = Join-Path $Dir 'scripts\task\dependabot-entry.ps1' }
    $prevPd = $env:CLAUDE_PROJECT_DIR
    $prevEap = $ErrorActionPreference
    $prevLoc = (Get-Location).Path
    try {
        Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue
        Set-Location -LiteralPath $Dir
        $ErrorActionPreference = 'Continue'
        return (Invoke-CapturedChild -WorkDir $Dir -ChildArgs (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $ScriptPath, '-PullRequest', '77', '-PrJson', $Json) + $Extra))
    } finally {
        $ErrorActionPreference = $prevEap
        Set-Location -LiteralPath $prevLoc
        if ($null -eq $prevPd) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue } else { $env:CLAUDE_PROJECT_DIR = $prevPd }
    }
}

function Get-GitText {
    param([string]$Dir, [string[]]$GitArgs)
    $prevEap = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        return ((& git -C $Dir @GitArgs 2>$null | Out-String).Trim())
    } finally { $ErrorActionPreference = $prevEap }
}

function Get-DocumentText {
    <# The text of every markdown file under .dkj of the fixture, joined: the document's own path is the resolver's business. #>
    param([string]$Dir)
    $root = Join-Path $Dir '.dkj'
    if (-not (Test-Path -LiteralPath $root)) { return '' }
    return ((Get-ChildItem -LiteralPath $root -Recurse -Filter '*.md' -File | ForEach-Object { [System.IO.File]::ReadAllText($_.FullName) }) -join "`n")
}

try {
    # --- 1. The refusals that need no remote -----------------------------------------------------------
    Write-Host 'dependabot-entry.ps1 -- refusals before anything is touched' -ForegroundColor Cyan
    $fx = New-DepFixture -Label 'dep-refuse'
    $headBefore = Get-GitText $fx @('rev-parse', 'HEAD')

    [System.IO.File]::WriteAllText((Join-Path $fx 'junk.txt'), "stray`n", (New-Object System.Text.UTF8Encoding $false))
    $r = Invoke-Dep -Dir $fx
    Assert-True ($r.Code -ne 0) 'a dirty tree is refused (non-zero exit)'
    Assert-True (Test-Phrase -Text $r.Out -Phrase 'not clean') 'and the refusal says the tree is not clean'
    Assert-True (-not (Test-Phrase -Text $r.Out -Phrase 'PR #77')) 'and it stopped before it read the PR'
    Remove-Item -LiteralPath (Join-Path $fx 'junk.txt') -Force

    $r = Invoke-Dep -Dir $fx -Json (New-PrJson -State 'MERGED')
    Assert-True ($r.Code -ne 0 -and (Test-Phrase -Text $r.Out -Phrase "'MERGED'")) 'a PR that is not open is refused, naming its state'
    $r = Invoke-Dep -Dir $fx -Json (New-PrJson -Fork $true)
    Assert-True ($r.Code -ne 0 -and (Test-Phrase -Text $r.Out -Phrase 'from a fork')) 'a PR from a fork is refused'
    $r = Invoke-Dep -Dir $fx -Json (New-PrJson -Author 'someone')
    Assert-True ($r.Code -ne 0 -and (Test-Phrase -Text $r.Out -Phrase "not from Dependabot")) 'a PR from another author is refused'
    $r = Invoke-Dep -Dir $fx -Json (New-PrJson -Author 'not-dependabot-at-all')
    Assert-True ($r.Code -ne 0) 'an author that merely CONTAINS the word is refused too'
    $r = Invoke-Dep -Dir $fx -Json 'this is not json'
    Assert-True ($r.Code -ne 0 -and (Test-Phrase -Text $r.Out -Phrase 'not valid JSON')) 'unreadable PR data is refused'
    $r = Invoke-Dep -Dir $fx -Extra @('-Title', 'say "hi"')
    Assert-True ($r.Code -ne 0 -and (Test-Phrase -Text $r.Out -Phrase 'double quote')) 'a title with a double quote is refused'
    Assert-True ((Get-GitText $fx @('rev-parse', 'HEAD')) -eq $headBefore -and (Get-GitText $fx @('status', '--porcelain')) -eq '') 'none of the refusals touched the checkout'

    # --- 2. The whole run -----------------------------------------------------------------------------
    Write-Host 'dependabot-entry.ps1 -- the whole run against a fixture origin' -ForegroundColor Cyan
    $fx2   = New-DepFixture -Label 'dep-run'
    $bare2 = New-BareOrigin -Dir $fx2 -Label 'dep-run'
    Publish-FixtureTrunk -Dir $fx2
    Add-OriginBranch -Bare $bare2 -Label 'dep-run' -Branch $Branch -MarkerFile 'lockfile-bump.txt'
    # The trunk moves on AFTER the bot cut its branch, which is the stale-base case step 4 exists for.
    Add-OriginCommits -Bare $bare2 -Label 'dep-run' -Count 2

    $r = Invoke-Dep -Dir $fx2
    Assert-ExitCode 0 $r 'the run exits 0'
    Assert-True ((Get-GitText $fx2 @('symbolic-ref', '--short', 'HEAD')) -eq $Branch) 'the PR branch is checked out'
    Assert-True (Test-Path -LiteralPath (Join-Path $fx2 'lockfile-bump.txt')) "the bot's own work is there (the branch was resumed, not forked)"
    $branches = Get-GitText $fx2 @('branch', '--format=%(refname:short)', '--list', '*v1*')
    Assert-True ($branches -eq '') 'no second "-v1" branch was created for a name this script does not own (#1224)'
    $remoteHeads = Get-GitText $bare2 @('for-each-ref', '--format=%(refname:short)', 'refs/heads')
    Assert-True (-not ($remoteHeads -match 'v1')) 'and none appeared on origin either'
    $containsMain = Get-GitText $fx2 @('rev-list', '--count', 'HEAD..origin/main')
    Assert-True ($containsMain -eq '0') 'the current origin/main was merged into the branch'
    $doc = Get-DocumentText $fx2
    Assert-True ($doc -match 'Where the package enters') 'the DEPLOY section carries the three bump questions'
    $scoreAt = $doc.IndexOf('**Score:**', $doc.IndexOf('DEPLOY'))
    $askAt   = $doc.IndexOf('the package manager''s audit')
    Assert-True ($askAt -gt 0 -and $scoreAt -gt $askAt) 'and they sit above the first **Score:** line'
    Assert-True ($doc.Contains('example/fixture/pull/77')) 'with a pointer to the PR'
    Assert-True ((Get-GitText $fx2 @('log', '-1', '--format=%s')) -eq 'chore: changelog entry for Dependabot PR #77') 'the commit message is English and names the PR'
    $files = @((Get-GitText $fx2 @('show', '--name-only', '--format=', 'HEAD')) -split "`r?`n" | Where-Object { $_ })
    Assert-True ($files.Count -eq 1 -and $files[0] -like '.dkj/*') 'only the branch document was committed'
    Assert-True ((Get-GitText $fx2 @('rev-parse', 'HEAD')) -eq (Get-GitText $bare2 @('rev-parse', "refs/heads/$Branch"))) 'the commit was pushed to the PR branch on origin'
    Assert-True (Test-Phrase -Text $r.Out -Phrase 'Follow-up') 'the follow-up steps are printed'

    Write-Host 'dependabot-entry.ps1 -- a second run changes nothing' -ForegroundColor Cyan
    $tip = Get-GitText $fx2 @('rev-parse', 'HEAD')
    $docBefore = Get-DocumentText $fx2
    Invoke-FixtureGitIn $fx2 checkout -q main
    $r = Invoke-Dep -Dir $fx2
    Assert-ExitCode 0 $r 'a rerun exits 0'
    Assert-True ((Get-GitText $fx2 @('rev-parse', 'HEAD')) -eq $tip) 'and makes no new commit'
    Assert-True ((Get-DocumentText $fx2) -eq $docBefore) 'and inserts the questions only once'

    Write-Host 'dependabot-entry.ps1 -- a local branch ahead of origin is never touched' -ForegroundColor Cyan
    [System.IO.File]::WriteAllText((Join-Path $fx2 'mine.txt'), "my own work`n", (New-Object System.Text.UTF8Encoding $false))
    Invoke-FixtureGitIn $fx2 add -A
    Invoke-FixtureGitIn $fx2 commit -q -m 'my own work on the bot branch'
    $mine = Get-GitText $fx2 @('rev-parse', 'HEAD')
    Invoke-FixtureGitIn $fx2 checkout -q main
    $r = Invoke-Dep -Dir $fx2
    Assert-True ($r.Code -ne 0 -and (Test-Phrase -Text $r.Out -Phrase 'ahead of origin')) 'it refuses, saying the branch is ahead of origin'
    Assert-True ((Get-GitText $fx2 @('rev-parse', $Branch)) -eq $mine) 'and the local commit is exactly where it was'

    Write-Host 'dependabot-entry.ps1 -- -NoPush commits and does not push' -ForegroundColor Cyan
    $fx3   = New-DepFixture -Label 'dep-nopush'
    $bare3 = New-BareOrigin -Dir $fx3 -Label 'dep-nopush'
    Publish-FixtureTrunk -Dir $fx3
    Add-OriginBranch -Bare $bare3 -Label 'dep-nopush' -Branch $Branch -MarkerFile 'lockfile-bump.txt'
    $originTip = Get-GitText $bare3 @('rev-parse', "refs/heads/$Branch")
    $r = Invoke-Dep -Dir $fx3 -Extra @('-NoPush', '-SkipMergeMain')
    Assert-ExitCode 0 $r '-NoPush: exits 0'
    Assert-True ((Get-GitText $bare3 @('rev-parse', "refs/heads/$Branch")) -eq $originTip) '-NoPush: origin is where it was'
    Assert-True ((Get-GitText $fx3 @('rev-list', '--count', "origin/$Branch..$Branch")) -eq '1') '-NoPush: exactly one commit is waiting locally'

    # --- 3. The plugin mirror, run from its own directory ------------------------------------------------
    Write-Host 'dependabot-entry.ps1 -- both shipped copies resolve their libs from their own directory' -ForegroundColor Cyan
    $fx4 = New-DepFixture -Label 'dep-mirror'
    [System.IO.File]::WriteAllText((Join-Path $fx4 'junk.txt'), "stray`n", (New-Object System.Text.UTF8Encoding $false))
    foreach ($copy in @(@{ Label = 'the source copy'; Path = $DepSrc }, @{ Label = 'the plugin mirror'; Path = $DepMirror })) {
        Assert-True (Test-Path -LiteralPath $copy.Path -PathType Leaf) "$($copy.Label) exists"
        $prevPd = $env:CLAUDE_PROJECT_DIR
        try {
            $env:CLAUDE_PROJECT_DIR = $fx4
            $r = Invoke-CapturedChild -WorkDir $fx4 -ChildArgs @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $copy.Path, '-PullRequest', '77', '-PrJson', (New-PrJson))
        } finally {
            if ($null -eq $prevPd) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue } else { $env:CLAUDE_PROJECT_DIR = $prevPd }
        }
        Assert-True ($r.Code -ne 0 -and (Test-Phrase -Text $r.Out -Phrase 'not clean')) "$($copy.Label) loads and refuses the dirty fixture tree"
    }
} finally {
    Remove-NewBranchFixtures
}

Complete-NewBranchSuite
