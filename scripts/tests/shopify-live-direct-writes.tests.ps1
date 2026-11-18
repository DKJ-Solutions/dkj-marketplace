<#
.SYNOPSIS
    Tests for dkj-subagents-shopify's live-direct-writes: the pure rules in
    scripts/lib/live-direct-writes-rules.ps1 and the script itself against a tiny local git repo and a
    stand-in gh (issue #4289).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell. Exit code 0 if everything passes, 1 on a failure.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/shopify-live-direct-writes.tests.ps1

    No network. The rules are driven on commit bodies in the two shapes measured on a Git-connected live
    deploy branch. The MOST IMPORTANT ASSERT RUNS THE OTHER WAY ROUND: a theme-EDITOR save ('Theme last
    edited by:') is the sanctioned route and must NEVER produce an issue -- a check that reports every
    editor save is ignored within a week. The script is driven against a throw-away repo built with
    'git init' and a gh stand-in that answers from files (the stand-in is a .cmd, so that group runs on
    Windows only). The workflow scaffold that places the check is covered in adopt-shopify-floor.tests.ps1.

    Made-up fixtures only (this repo is public): no real store, person or domain names.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Plugin   = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify'
$Script   = Join-Path $Plugin 'scripts\task\live-direct-writes.ps1'

. (Join-Path $RepoRoot 'scripts\lib\fixture-git-lib.ps1')
. (Join-Path $Plugin 'scripts\lib\live-direct-writes-rules.ps1')

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Label)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label" -ForegroundColor Red }
}
function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Write-Group { param([string]$Title) Write-Host ""; Write-Host "== $Title" -ForegroundColor Cyan }

$fileWrite  = "Committed from shop: example-store.example`nChanged by: Alex Example`n`nFiles:`n- modified assets/variant.js (editor not recorded)`n- modified assets/main.css (Alex Example)`n"
$editorSave = "Committed from shop: example-store.example`nTheme last edited by: Alex Example`n"

Write-Group '1. the two measured body shapes'
Assert-Equal 'Alex Example' (Get-DirectWriteEditor -Body $fileWrite) 'Changed by: is a file write and names the person'
Assert-Equal '' (Get-DirectWriteEditor -Body $editorSave) 'Theme last edited by: (an editor save) is NOT a file write'
Assert-Equal '' (Get-DirectWriteEditor -Body '') 'empty body: not a file write'
Assert-Equal 'X Y' (Get-DirectWriteEditor -Body "Changed by: X Y`r`nFiles:") 'CRLF body: the person without the \r'
Assert-Equal '!--evil-- team' (Get-DirectWriteEditor -Body "Changed by: <!--evil--> ``@team``") 'a name carries no fence, mention or comment characters'
Assert-Equal 'ab' (ConvertTo-DirectWritePlainText ("a" + [char]1 + "b")) 'control characters are dropped'
Assert-Equal 0 @(Get-DirectWriteFiles -Body "- not a file`nChanged by: X").Count 'without a Files: heading: no file lines'
$files = @(Get-DirectWriteFiles -Body $fileWrite)
Assert-Equal 2 $files.Count 'two file lines'
Assert-Equal 'modified assets/main.css (Alex Example)' $files[1] 'a file line as written'

Write-Group '2. parsing git log records'
$us = [string][char]0x1f; $rs = [string][char]0x1e
$raw = "aaaa1111${us}shopify[bot]${us}2026-11-02T10:31:52Z${us}Update from Shopify${us}$fileWrite$rs`n" +
       "bbbb2222${us}shopify[bot]${us}2026-10-30T15:09:25Z${us}Update from Shopify${us}$editorSave$rs`n" +
       "cccc3333${us}A Person${us}2026-10-30T10:00:00Z${us}fix: something${us}Changed by: Someone$rs"
$commits = @(ConvertFrom-DirectWriteGitLog -Raw $raw)
Assert-Equal 3 $commits.Count 'three records'
Assert-Equal 'bbbb2222' $commits[1].Sha 'the sha of the second record'
Assert-Equal 0 @(ConvertFrom-DirectWriteGitLog -Raw '').Count 'empty output: no records'

Write-Group '3. selection and dedupe'
$hits = @(Select-DirectWrites -Commits $commits)
Assert-Equal 1 $hits.Count 'only the bot file write; the editor save and the human commit drop out'
Assert-Equal 'aaaa1111' $hits[0].Sha 'the right commit'
$reported = @(Get-ReportedShas -Bodies @("text`n<!-- live-direct-write:AAAA1111 -->`n", $null, 'no marker'))
Assert-Equal 1 $reported.Count 'one marker read'
Assert-Equal 0 @(Select-DirectWrites -Commits $commits -Reported $reported).Count 'already reported (case-insensitive): nothing new'
Assert-Equal 'live-direct-write' (Get-DirectWriteLabel) 'the label is the one a store''s dedupe history already carries'

Write-Group '4. the issue text'
$text = New-DirectWriteIssueText -Hits $hits -Repo 'o/r'
Assert-True ($text.Title -like '*1 commit by Alex Example*') 'the title names the count and the person'
Assert-True ($text.Body.Contains('<!-- live-direct-write:aaaa1111 -->')) 'the body carries the marker the next run reads'
Assert-Equal 1 @(Get-ReportedShas -Bodies @($text.Body)).Count 'its own body reads back as reported'
Assert-True ($text.Body -notmatch '#\d{3,}') 'no tracker number of any store leaks into the text'

Write-Group '5. the inputs a run hands to git and gh'
Assert-True (Test-DirectWriteSince '2026-11-18') 'a UTC date is a floor'
Assert-True (Test-DirectWriteSince '2026-11-18T10:00:00Z') 'a UTC date and time is a floor'
Assert-True (-not (Test-DirectWriteSince '2026-11-18 ; x')) 'anything else is not'
Assert-True (-not (Test-DirectWriteSince 'yesterday')) 'a relative date is not (the floor must be one unambiguous instant)'
Assert-True (Test-DirectWriteRef 'origin/live') 'a branch ref is plain'
Assert-True (Test-DirectWriteRef 'HEAD~3') 'a relative revision is plain'
Assert-True (-not (Test-DirectWriteRef '--output=x')) 'a ref that reads as an option is refused'
Assert-True (-not (Test-DirectWriteRef 'a b')) 'a ref with whitespace is refused'
Assert-True (Test-DirectWriteRepo 'owner/name') 'owner/name'
Assert-True (-not (Test-DirectWriteRepo 'owner')) 'a bare owner is not a repo'

# ---------------------------------------------------------------------------------------------
Write-Group '6. the script against a throw-away repo and a stand-in gh'

$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) "live-direct-writes-fixture-$PID-$([guid]::NewGuid().ToString('n'))"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$prevPath = $env:PATH
try {
    New-Item -ItemType Directory -Force -Path $Fixture | Out-Null
    $repo = Join-Path $Fixture 'store'
    $bin  = Join-Path $Fixture 'bin'
    New-Item -ItemType Directory -Force -Path $repo, $bin | Out-Null

    function Invoke-FixtureGit {
        param([string[]]$GitArgs)
        Invoke-FixtureGitIn $repo -c commit.gpgsign=false @GitArgs
    }
    function Add-FixtureCommit {
        param([string]$Name, [string]$Email, [string]$Subject, [string]$Body, [string]$Date)
        $msg = Join-Path $Fixture 'msg.txt'
        [System.IO.File]::WriteAllText($msg, "$Subject`n`n$Body", $utf8)
        [System.IO.File]::WriteAllText((Join-Path $repo 'f.txt'), "$([guid]::NewGuid())`n", $utf8)
        Invoke-FixtureGit @('add', '-A')
        $env:GIT_AUTHOR_DATE = $Date; $env:GIT_COMMITTER_DATE = $Date
        try { Invoke-FixtureGit @('-c', "user.name=$Name", '-c', "user.email=$Email", 'commit', '-q', '-F', $msg) }
        finally { Remove-Item Env:\GIT_AUTHOR_DATE, Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue }
    }
    Invoke-FixtureGit @('init', '-q')
    Invoke-FixtureGit @('symbolic-ref', 'HEAD', 'refs/heads/live')
    # Oldest first: git log --since stops at the first commit older than the floor, as it does on any real history.
    Add-FixtureCommit 'A Person' 'p@local.invalid' 'init' 'start' '2026-08-01T10:00:00Z'
    Add-FixtureCommit 'shopify[bot]' 'bot@local.invalid' 'Update from Shopify' "Changed by: Old Editor`n`nFiles:`n- modified assets/old.js (Old Editor)`n" '2026-09-01T10:00:00Z'
    Add-FixtureCommit 'shopify[bot]' 'bot@local.invalid' 'Update from Shopify' $fileWrite '2026-11-02T10:31:52Z'
    Add-FixtureCommit 'shopify[bot]' 'bot@local.invalid' 'Update from Shopify' $editorSave '2026-11-03T09:00:00Z'

    $isWindows = ($env:OS -eq 'Windows_NT')
    if (-not $isWindows) {
        Write-Host '  [skip] the stand-in gh is a .cmd; this group runs on Windows only' -ForegroundColor DarkGray
    } else {
        # The stand-in answers from files and logs every call, so a run can be judged on what it asked.
        [System.IO.File]::WriteAllText((Join-Path $bin 'gh.cmd'), (@(
            '@echo off',
            'echo %*>>"%~dp0gh.log"',
            'echo %*|findstr /C:"label list" >nul',
            'if not errorlevel 1 (type "%~dp0labels.json" & exit /b 0)',
            'echo %*|findstr /C:"issue list" >nul',
            'if not errorlevel 1 (type "%~dp0issues.json" & exit /b 0)',
            'echo https://example.invalid/issues/1',
            'exit /b 0'
        ) -join "`r`n") + "`r`n", $utf8)
        $env:PATH = "$bin;$prevPath"

        function Invoke-Ldw {
            param([string[]]$Extra = @())
            $log = Join-Path $bin 'gh.log'
            if (Test-Path -LiteralPath $log) { Remove-Item -LiteralPath $log }
            $argv = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Script, '-RepoPath', $repo, '-Repo', 'o/r') + $Extra
            $prev = $ErrorActionPreference
            try { $ErrorActionPreference = 'Continue'; $out = & powershell @argv 2>&1 } finally { $ErrorActionPreference = $prev }
            $calls = if (Test-Path -LiteralPath $log) { @(Get-Content -LiteralPath $log) } else { @() }
            return [pscustomobject]@{ Code = $LASTEXITCODE; Out = (($out | ForEach-Object { "$_" }) -join "`n"); Calls = $calls }
        }

        # No label yet: nothing was ever reported.
        [System.IO.File]::WriteAllText((Join-Path $bin 'labels.json'), '[]', $utf8)
        [System.IO.File]::WriteAllText((Join-Path $bin 'issues.json'), '[]', $utf8)

        $r = Invoke-Ldw -Extra @('-DryRun')
        Assert-Equal 0 $r.Code 'dry run: exits 0'
        Assert-True ($r.Out -match 'Scanned 3 shopify\[bot\] commit\(s\).*2 new direct') 'dry run: with no floor all three bot commits are read and both file writes are new'
        Assert-True ($r.Out -match '\[dry-run\] would open: Direct file write') 'dry run: says which issue it would open'
        Assert-True (-not ($r.Calls | Where-Object { $_ -match 'issue create|label create' })) 'dry run: opens nothing and creates no label'

        $r = Invoke-Ldw -Extra @('-DryRun', '-Since', '2026-10-15')
        Assert-True ($r.Out -match 'Scanned 2 shopify\[bot\] commit\(s\).*1 new direct') 'the floor drops the older bot commit; the editor save is read but never reported'
        Assert-True ($r.Out -notmatch 'Old Editor') 'the commit below the floor is not named'
        Assert-True ($r.Out -match 'Alex Example') 'the file write is named'

        $r = Invoke-Ldw -Extra @('-Since', '2026-10-15')
        Assert-Equal 0 $r.Code 'a real run: exits 0'
        Assert-True ([bool]($r.Calls | Where-Object { $_ -match 'label create live-direct-write' })) 'a real run creates the label once, when it is missing'
        Assert-True ([bool]($r.Calls | Where-Object { $_ -match 'issue create.*--label live-direct-write.*--body-file' })) 'and opens ONE issue, its body in a file'
        Assert-Equal 1 @($r.Calls | Where-Object { $_ -match 'issue create' }).Count 'exactly one issue per run'
        Assert-True ($r.Out -match '::warning::Direct write') 'and raises a workflow warning'

        # The dedupe: an issue the CI account wrote, naming the sha, silences the commit.
        $shas = @(& git -C $repo log --since=2026-11-01 --format='%H' --author='shopify')
        $fileSha = $null
        foreach ($s in $shas) { if ((& git -C $repo log -1 --format='%b' $s) -match 'Changed by:') { $fileSha = $s } }
        [System.IO.File]::WriteAllText((Join-Path $bin 'labels.json'), '[{"name":"live-direct-write"}]', $utf8)
        [System.IO.File]::WriteAllText((Join-Path $bin 'issues.json'), ('[{"number":1,"body":"x <!-- live-direct-write:' + $fileSha + ' -->","author":{"login":"app/github-actions"}}]'), $utf8)
        $r = Invoke-Ldw -Extra @('-Since', '2026-10-15')
        Assert-Equal 0 $r.Code 'a reported commit: exits 0'
        Assert-True ($r.Out -match '1 already reported; 0 new') 'a commit a CI-written marker names is quiet'
        Assert-True (-not ($r.Calls | Where-Object { $_ -match 'issue create|label create' })) 'and nothing is opened'

        # A marker a person wrote does not count.
        [System.IO.File]::WriteAllText((Join-Path $bin 'issues.json'), ('[{"number":1,"body":"<!-- live-direct-write:' + $fileSha + ' -->","author":{"login":"a-person"}}]'), $utf8)
        $r = Invoke-Ldw -Extra @('-DryRun', '-Since', '2026-10-15')
        Assert-True ($r.Out -match '0 already reported; 1 new') 'a hand-written marker cannot silence a report'
    }

    # Refusals need no gh at all.
    $r = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -RepoPath $repo -Repo 'o/r' -Since 'yesterday' 2>&1
    Assert-True (($r | Out-String) -match 'FAILED: -Since') 'a floor that is not a UTC date is refused before anything runs'
    $r = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -RepoPath $repo -Repo 'o/r' -Ref '--output=x' 2>&1
    Assert-True (($r | Out-String) -match 'FAILED: -Ref') 'a ref that reads as an option is refused'
    $savedRepoEnv = $env:GITHUB_REPOSITORY
    $env:GITHUB_REPOSITORY = ''
    $r = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -RepoPath $repo 2>&1
    $env:GITHUB_REPOSITORY = $savedRepoEnv
    Assert-True (($r | Out-String) -match 'No repository') 'no repository: refused, naming the parameter and the variable'
}
finally {
    $env:PATH = $prevPath
    Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue
}

Write-Host ""
# A broken fixture is said before the verdict and fails the run (issue #1635).
$fixtureBroken = Write-FixtureGitSummary -Subject 'live-direct-writes.ps1'
Write-Host "Summary: $script:pass passed, $script:fail failed" -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0 -or $fixtureBroken) { exit 1 }
exit 0
