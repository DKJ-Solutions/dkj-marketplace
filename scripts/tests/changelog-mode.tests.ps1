<#
.SYNOPSIS
    Regression tests for the changelog mode (issue #4213): scripts/lib/changelog-mode-lib.ps1, and the
    scripts that stand down under Get-ChangelogMode 'none' -- new-branch (no park commit), park-cycle,
    check-branch-entry, check-unfolded-entry, fold-changelog-entry -- and cut-release, which refuses.

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/changelog-mode.tests.ps1

    THE ISSUE'S "DONE WHEN" IS THE INTEGRATION HALF: in a repo answering 'none', a branch opened by
    new-branch carries one work commit and no 'park:' commit, its document is uncommitted and ignored by
    git, and every gate that would have spoken about that document stays quiet. Each script runs as a
    child process from a copy of scripts/ inside a throwaway git repo, so nothing here touches this
    checkout.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'scripts\lib\changelog-mode-lib.ps1')
$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) "changelog-mode-$PID-$([guid]::NewGuid().ToString('n'))"

$script:pass = 0
$script:fail = 0
function Assert-True([bool]$Condition, [string]$Message) {
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function Invoke-Git {
    param([string]$Repo, [Parameter(ValueFromRemainingArguments)][string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & git -C $Repo @GitArgs 2>&1
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $prev }
    if ($code -ne 0) { throw "fixture git $($GitArgs -join ' ') failed ($code): $($out | Out-String)" }
    return (@($out) | ForEach-Object { "$_" })
}

function Invoke-Child {
    <# Runs a script as a child powershell; returns Output (text) and ExitCode. #>
    param([string]$Script, [string[]]$ScriptArgs = @(), [string]$WorkDir)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $prevLoc = Get-Location
    $prevProj = $env:CLAUDE_PROJECT_DIR
    try {
        Set-Location -LiteralPath $WorkDir
        $env:CLAUDE_PROJECT_DIR = $WorkDir
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @ScriptArgs 2>&1
        $code = $LASTEXITCODE
    } finally {
        Set-Location $prevLoc
        $env:CLAUDE_PROJECT_DIR = $prevProj
        $ErrorActionPreference = $prev
    }
    return [pscustomobject]@{ Output = (@($out) | ForEach-Object { "$_" }) -join "`n"; ExitCode = $code }
}

$ConfigNone = @'
function Get-RepoName { 'example/fixture' }
function Get-RepoBlobUrl { 'https://example.invalid/blob/main' }
function Get-LintScript { 'scripts\lint\none.ps1' }
function Get-ChangelogMode { 'none' }
'@

try {
    # --- 1. The resolver ------------------------------------------------------------------------------
    Write-Host ''
    Write-Host 'Get-ChangelogModeName reads the seam, and only an exact none drops the changelog'
    Assert-True ((Get-ChangelogModeName) -eq 'fold') 'no seam defined -> fold (the default)'
    $cases = @(
        @{ Value = 'none';    Expected = 'none'; Why = "'none' -> none" },
        @{ Value = ' NONE ';  Expected = 'none'; Why = 'case and surrounding space are ignored' },
        @{ Value = 'fold';    Expected = 'fold'; Why = "'fold' -> fold" },
        @{ Value = 'nope';    Expected = 'fold'; Why = 'an unknown answer reads as fold, the route that keeps the record' },
        @{ Value = '';        Expected = 'fold'; Why = 'an empty answer reads as fold' }
    )
    foreach ($c in $cases) {
        $v = $c.Value
        Set-Item -Path Function:\Get-ChangelogMode -Value ([scriptblock]::Create("'$v'"))
        Assert-True ((Get-ChangelogModeName) -eq $c.Expected) $c.Why
    }
    Set-Item -Path Function:\Get-ChangelogMode -Value { throw 'broken seam' }
    Assert-True ((Get-ChangelogModeName) -eq 'fold') 'a seam that throws reads as fold'
    Set-Item -Path Function:\Get-ChangelogMode -Value { 'none' }
    Assert-True (Test-ChangelogModeNone) 'Test-ChangelogModeNone is true for none'
    Remove-Item Function:\Get-ChangelogMode
    Assert-True (-not (Test-ChangelogModeNone)) 'and false once the seam is gone'

    # --- 2. The local exclude ------------------------------------------------------------------------
    Write-Host ''
    Write-Host 'Add-/Remove-BranchDocumentLocalExclude keep the document out of git without touching the tree'
    $ex = Join-Path $Fixture 'exclude'
    New-Item -ItemType Directory -Path $ex -Force | Out-Null
    Invoke-Git $ex init -q | Out-Null
    $excludeFile = Join-Path $ex '.git\info\exclude'
    $before = if (Test-Path -LiteralPath $excludeFile) { [System.IO.File]::ReadAllText($excludeFile) } else { '' }
    $rel = '.dkj/dkj-policy/feat-1-x.md'
    New-Item -ItemType Directory -Path (Join-Path $ex '.dkj\dkj-policy') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $ex ($rel -replace '/', '\')) -Value 'doc'
    Assert-True (Add-BranchDocumentLocalExclude -RepoRoot $ex -RelPath $rel) 'the line is written'
    Assert-True (Add-BranchDocumentLocalExclude -RepoRoot $ex -RelPath $rel) 'a second call is idempotent'
    $lines = @([System.IO.File]::ReadAllText($excludeFile) -split "`r?`n" | Where-Object { $_ -eq "/$rel" })
    Assert-True ($lines.Count -eq 1) 'the line appears exactly once'
    $status = (Invoke-Git $ex status --porcelain --untracked-files=all) -join "`n"
    Assert-True ($status -notmatch 'feat-1-x') 'git status no longer reports the document'
    Invoke-Git $ex add -A | Out-Null
    $staged = (Invoke-Git $ex diff --cached --name-only) -join "`n"
    Assert-True ($staged -notmatch 'feat-1-x') 'git add -A does not stage it'
    Remove-BranchDocumentLocalExclude -RepoRoot $ex -RelPath $rel
    $after = [System.IO.File]::ReadAllText($excludeFile)
    Assert-True ($after.TrimEnd() -eq $before.TrimEnd()) 'removing it restores the exclude file as it was (comments kept)'
    Remove-BranchDocumentLocalExclude -RepoRoot $ex -RelPath $rel
    Assert-True ($true) 'removing an absent line is silent'

    # CRLF is the user's choice and survives a round trip; only the one line comes and goes.
    $crlf = "# a comment`r`n*.tmp`r`n"
    [System.IO.File]::WriteAllText($excludeFile, $crlf)
    Add-BranchDocumentLocalExclude -RepoRoot $ex -RelPath $rel | Out-Null
    Assert-True ([System.IO.File]::ReadAllText($excludeFile) -eq ($crlf + "/$rel`r`n")) 'a CRLF exclude file gets a CRLF line'
    Remove-BranchDocumentLocalExclude -RepoRoot $ex -RelPath $rel
    Assert-True ([System.IO.File]::ReadAllText($excludeFile) -eq $crlf) 'and removing it leaves the file byte-identical'

    # A linked worktree: .git is a FILE, and the exclude that counts is the common directory's. Under a
    # non-ASCII path, which is what reading rev-parse output got wrong (#4213 review).
    Invoke-Git $ex commit -q --allow-empty -m 'base' | Out-Null
    $wt = Join-Path $Fixture ('lane-' + [char]0x00EB)
    Invoke-Git $ex worktree add -q $wt -b lane | Out-Null
    Assert-True ((Get-GitInfoExcludePath -RepoRoot $wt) -eq [System.IO.Path]::GetFullPath($excludeFile)) 'a linked worktree under a non-ASCII path resolves to the common exclude file'
    Assert-True (Add-BranchDocumentLocalExclude -RepoRoot $wt -RelPath $rel) 'and writes the line there'
    Assert-True (@([System.IO.File]::ReadAllText($excludeFile) -split "`r?`n") -contains "/$rel") 'which the common exclude file now carries'
    Remove-BranchDocumentLocalExclude -RepoRoot $wt -RelPath $rel
    Assert-True ([System.IO.File]::ReadAllText($excludeFile) -eq $crlf) 'and removes it again'
    $nogit = Join-Path $Fixture 'not-a-repo'
    New-Item -ItemType Directory -Path $nogit -Force | Out-Null
    Assert-True (-not (Add-BranchDocumentLocalExclude -RepoRoot $nogit -RelPath $rel)) 'outside a repo it returns false and creates nothing'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $nogit '.git'))) 'no .git directory is invented'

    # --- 3. A consumer answering none, end to end ----------------------------------------------------
    Write-Host ''
    Write-Host "A consumer answering 'none': one work commit, no park, no fold, and quiet gates"
    $repo = Join-Path $Fixture 'consumer'
    New-Item -ItemType Directory -Path $repo -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'scripts\lib') -Destination (Join-Path $repo 'scripts\lib') -Recurse
    foreach ($d in @('task', 'release', 'lint')) {
        Copy-Item -LiteralPath (Join-Path $RepoRoot "scripts\$d") -Destination (Join-Path $repo "scripts\$d") -Recurse
    }
    Set-Content -LiteralPath (Join-Path $repo 'scripts\repo-config.ps1') -Value $ConfigNone -Encoding ASCII
    Set-Content -LiteralPath (Join-Path $repo 'README.md') -Value '# fixture' -Encoding ASCII
    Invoke-Git $repo init -q -b main | Out-Null
    Invoke-Git $repo config user.name 'fixture' | Out-Null
    Invoke-Git $repo config user.email 'fixture@example.invalid' | Out-Null
    Invoke-Git $repo config commit.gpgsign false | Out-Null
    Invoke-Git $repo add -A | Out-Null
    Invoke-Git $repo commit -q -m 'init' | Out-Null
    $trunkTip = (Invoke-Git $repo rev-parse HEAD) -join ''

    $nb = Invoke-Child -Script (Join-Path $repo 'scripts\task\new-branch.ps1') -WorkDir $repo `
        -ScriptArgs @('-Name', 'feat/7-light-route', '-Title', 'A light route', '-RepoRoot', $repo)
    Assert-True ($nb.ExitCode -eq 0) "new-branch exits 0 (exit $($nb.ExitCode))"
    if ($nb.ExitCode -ne 0) { Write-Host $nb.Output -ForegroundColor DarkGray }
    Assert-True ($nb.Output -match "Get-ChangelogMode with 'none'") 'new-branch says which seam it read'
    $branchNow = (Invoke-Git $repo rev-parse --abbrev-ref HEAD) -join ''
    Assert-True ($branchNow -eq 'feat/7-light-route') 'the branch is checked out'
    $headNow = (Invoke-Git $repo rev-parse HEAD) -join ''
    Assert-True ($headNow -eq $trunkTip) 'no park commit: the branch still points at the trunk tip'
    $docs = @(Get-ChildItem -LiteralPath (Join-Path $repo '.dkj\dkj-policy') -Filter 'feat-7-*.md' -ErrorAction SilentlyContinue)
    Assert-True ($docs.Count -eq 1) 'the branch document is written'
    $status = (Invoke-Git $repo status --porcelain --untracked-files=all) -join "`n"
    Assert-True ($status -notmatch 'feat-7-') 'and git does not see it'

    Set-Content -LiteralPath (Join-Path $repo 'change.txt') -Value 'the one-file change' -Encoding ASCII
    Invoke-Git $repo add -A | Out-Null
    Invoke-Git $repo commit -q -m 'feat: the one-file change' | Out-Null
    $files = (Invoke-Git $repo diff --name-only "$trunkTip..HEAD") -join "`n"
    Assert-True ($files -eq 'change.txt') "the branch carries the one file and nothing else (got: $files)"
    $subjects = (Invoke-Git $repo log --format=%s "$trunkTip..HEAD") -join "`n"
    Assert-True ($subjects -notmatch '^park:') 'and no park: subject'

    $pc = Invoke-Child -Script (Join-Path $repo 'scripts\task\park-cycle.ps1') -WorkDir $repo -ScriptArgs @('-RepoRoot', $repo)
    Assert-True ($pc.ExitCode -eq 0) 'park-cycle exits 0'
    $subjects = (Invoke-Git $repo log --format=%s "$trunkTip..HEAD") -join "`n"
    Assert-True ($subjects -notmatch 'park:') 'park-cycle adds no park: commit'

    $be = Invoke-Child -Script (Join-Path $repo 'scripts\lint\check-branch-entry.ps1') -WorkDir $repo -ScriptArgs @('-Branch', 'feat/7-light-route', '-RootOverride', $repo)
    Assert-True ($be.ExitCode -eq 0) "check-branch-entry exits 0 (exit $($be.ExitCode))"
    Assert-True ($be.Output -match '\[OK\].*owes no entry') 'and says the branch owes no entry'

    $ue = Invoke-Child -Script (Join-Path $repo 'scripts\lint\check-unfolded-entry.ps1') -WorkDir $repo -ScriptArgs @('-RootOverride', $repo)
    Assert-True ($ue.ExitCode -eq 0) "check-unfolded-entry exits 0 (exit $($ue.ExitCode))"
    Assert-True ($ue.Output -match '\[OK\]' -and $ue.Output -notmatch '\[ERROR\]') 'and reports nothing stranded'

    Invoke-Git $repo checkout -q main | Out-Null
    Invoke-Git $repo merge -q --no-ff -m 'merge: feat/7-light-route' 'feat/7-light-route' | Out-Null
    $mainBefore = (Invoke-Git $repo rev-parse HEAD) -join ''
    $fold = Invoke-Child -Script (Join-Path $repo 'scripts\release\fold-changelog-entry.ps1') -WorkDir $repo `
        -ScriptArgs @('-Branch', 'feat/7-light-route', '-RepoRoot', $repo, '-Commit')
    Assert-True ($fold.ExitCode -eq 0) "fold-changelog-entry exits 0 (exit $($fold.ExitCode))"
    Assert-True ($fold.Output -match 'nothing to fold') 'and says there is nothing to fold'
    Assert-True (((Invoke-Git $repo rev-parse HEAD) -join '') -eq $mainBefore) 'no fold: commit lands on the trunk'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $repo '.dkj\dkj-policy\CHANGELOG.md'))) 'and no CHANGELOG.md is created'
    $mainSubjects = (Invoke-Git $repo log --format=%s "$trunkTip..main") -join "`n"
    Assert-True ($mainSubjects -notmatch '(?m)^(park|fold):') 'the trunk carries no park: and no fold: commit'

    $cut = Invoke-Child -Script (Join-Path $repo 'scripts\release\cut-release.ps1') -WorkDir $repo -ScriptArgs @('-Bump', 'patch')
    Assert-True ($cut.ExitCode -ne 0) "cut-release refuses (exit $($cut.ExitCode))"
    Assert-True ($cut.Output -match 'Get-ChangelogMode') 'and names the seam'
    Assert-True (((Invoke-Git $repo rev-parse HEAD) -join '') -eq $mainBefore) 'and changes nothing'
}
finally {
    if (Test-Path -LiteralPath $Fixture) { Remove-Item -LiteralPath $Fixture -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "Result: $script:pass pass, $script:fail fail." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
