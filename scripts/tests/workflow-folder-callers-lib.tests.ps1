<#
.SYNOPSIS
    Tests for scripts/lib/workflow-folder-callers-lib.ps1 (issue #4537): the two CI gate callers
    adopt-workflow-folder.ps1 places, held to the template this plugin version composes, their release pin
    aside -- and the [BEHIND] line check-script-contract.ps1 and its session hook carry from that comparison.

.DESCRIPTION
    Same shape as ci-floor-runners-lib.tests.ps1 (#4529). The states a placed caller can be in: the same as
    the template, different only in its pin (a tag, main, main with scripts-ref: main), different in its
    body, absent -- plus the live branch (#4374), which is part of the template, and the two readers that
    print the result.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'scripts\lib\workflow-folder-callers-lib.ps1')
$Check = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\scripts\sync\check-script-contract.ps1'
$Hook  = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\script-contract-sessioncheck.ps1'
$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) "workflow-folder-callers-test-$PID-$([guid]::NewGuid().ToString('n'))"

$script:pass = 0
$script:fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}

$Nl = "`n"
$entryRel = '.github/workflows/branch-entry.yml'
$budgetRel = '.github/workflows/always-on-budget.yml'

function New-Consumer {
    <# A consumer tree with both callers placed as adopt-workflow-folder would place them at -Ref. #>
    param([string]$Ref = 'v7.7.0', [string]$Live = '', [switch]$WithLibs)
    $root = Join-Path $Fixture ([guid]::NewGuid().ToString('n'))
    New-Item -ItemType Directory -Path (Join-Path $root '.github\workflows') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $root 'scripts') -Force | Out-Null
    if ($Live) {
        [System.IO.File]::WriteAllText((Join-Path $root 'scripts\repo-config.ps1'), "function Get-ShopifyLiveDeployBranch { '$Live' }$Nl")
    }
    foreach ($t in @(Get-WorkflowFolderCallerTargets -GateRef $Ref -LiveBranch $Live)) {
        [System.IO.File]::WriteAllText((Join-Path $root ($t.Rel -replace '/', '\')), $t.Content)
    }
    if ($WithLibs) {
        New-Item -ItemType Directory -Path (Join-Path $root 'scripts\lib') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $root '.dkj\dkj-repo-workflow') -Force | Out-Null
        Copy-Item (Join-Path $RepoRoot 'scripts\lib\branch-info.ps1') (Join-Path $root 'scripts\lib\branch-info.ps1')
        if (-not $Live) { Copy-Item (Join-Path $RepoRoot 'scripts\repo-config.ps1') (Join-Path $root 'scripts\repo-config.ps1') }
    }
    return $root
}
function Get-Stale { param([object[]]$Drift) return @($Drift | Where-Object { $_.Stale } | ForEach-Object { $_.Rel }) }

try {
    Write-Host '== workflow-folder-callers-lib.tests: scripts/lib/workflow-folder-callers-lib.ps1 ==' -ForegroundColor Cyan

    # --- 1. The composition ---------------------------------------------------------------------------
    Write-Host '-- 1. the two callers, composed --' -ForegroundColor Cyan
    $targets = @(Get-WorkflowFolderCallerTargets -GateRef 'v7.7.0')
    Assert-Equal "$entryRel,$budgetRel" (($targets | ForEach-Object { $_.Rel }) -join ',') 'two callers, in the order the command places them'
    $entry = ($targets | Where-Object { $_.Rel -eq $entryRel }).Content
    Assert-True ($entry -match '(?m)^    uses: DKJ-Solutions/dkj-marketplace/\.github/workflows/reusable-branch-entry\.yml@v7\.7\.0$') 'the caller is pinned to the ref passed in'
    Assert-True ($entry -match '(?m)^      scripts-ref: v7\.7\.0$') 'and passes the same ref as scripts-ref'
    Assert-True ($entry -match '(?m)^    branches: \[main\]$') 'without a live branch the trigger lists main only'
    Assert-True ($entry -notmatch "`r") 'LF only'
    $liveTargets = @(Get-WorkflowFolderCallerTargets -GateRef 'v7.7.0' -LiveBranch 'live-prod')
    $live = ($liveTargets | Where-Object { $_.Rel -eq $entryRel }).Content
    Assert-True ($live -match '(?m)^    branches: \[main, live-prod\]$') 'a live branch joins the branch-entry trigger'
    $liveBudget = ($liveTargets | Where-Object { $_.Rel -eq $budgetRel }).Content
    Assert-True ($liveBudget -match '(?m)^    branches: \[main\]$') 'and never the always-on budget one'

    # --- 1b. The live-branch resolution ----------------------------------------------------------------
    Write-Host '-- 1b. the live branch, resolved from repo-config --' -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $Fixture -Force | Out-Null
    $cfg = Join-Path $Fixture 'repo-config.ps1'
    $r = Resolve-WorkflowFolderLiveBranch -RepoConfigPath (Join-Path $Fixture 'absent.ps1')
    Assert-Equal '|' "$($r.Branch)|$($r.Note)" 'no config file: nothing answered'
    foreach ($case in @(@('live-prod', 'live-prod', $false), @('main', '', $true), @('refs/heads/x', '', $true), @('a..b', '', $true), @('-x', '', $true))) {
        [System.IO.File]::WriteAllText($cfg, "function Get-ShopifyLiveDeployBranch { '$($case[0])' }$Nl")
        $r = Resolve-WorkflowFolderLiveBranch -RepoConfigPath $cfg
        Assert-Equal $case[1] $r.Branch "answer '$($case[0])': branch is '$($case[1])'"
        Assert-Equal $case[2] ([bool]$r.Note) "answer '$($case[0])': the note is $(if ($case[2]) { 'set' } else { 'empty' })"
    }
    [System.IO.File]::WriteAllText($cfg, "function Get-ShopifyLiveDeployBranch { throw 'x' }$Nl")
    $r = Resolve-WorkflowFolderLiveBranch -RepoConfigPath $cfg
    Assert-Equal '|' "$($r.Branch)|$($r.Note)" 'a seam that throws degrades to unanswered'

    # --- 2. Current, at any pin -----------------------------------------------------------------------
    Write-Host '-- 2. a caller as placed, at any pin, is current --' -ForegroundColor Cyan
    foreach ($ref in @('v7.7.0', 'v6.0.0', 'main')) {
        $c = New-Consumer -Ref $ref
        $d = @(Get-WorkflowFolderCallerDrift -RepoRoot $c)
        Assert-Equal 2 $d.Count "pin '$ref': both callers are reported"
        Assert-Equal '' ((Get-Stale $d) -join ',') "pin '$ref': neither is behind -- the pin is not drift"
    }
    # The @main shape adopt-workflow-folder placed before #4237: @main with scripts-ref: main.
    $c = New-Consumer -Ref 'v7.7.0'
    foreach ($rel in @($entryRel, $budgetRel)) {
        $abs = Join-Path $c ($rel -replace '/', '\')
        [System.IO.File]::WriteAllText($abs, ([System.IO.File]::ReadAllText($abs) -replace '@v7\.7\.0', '@main' -replace 'scripts-ref: v7\.7\.0', 'scripts-ref: main'))
    }
    Assert-Equal '' ((Get-Stale @(Get-WorkflowFolderCallerDrift -RepoRoot $c)) -join ',') '@main with scripts-ref: main reads current'
    $abs = Join-Path $c ($entryRel -replace '/', '\')
    [System.IO.File]::WriteAllText($abs, ([System.IO.File]::ReadAllText($abs) -replace "`n", "`r`n"))
    Assert-Equal '' ((Get-Stale @(Get-WorkflowFolderCallerDrift -RepoRoot $c)) -join ',') 'a CRLF checkout is current'

    # --- 3. Behind ----------------------------------------------------------------------------------------
    Write-Host '-- 3. a caller whose body changed is behind --' -ForegroundColor Cyan
    $c = New-Consumer
    $abs = Join-Path $c ($entryRel -replace '/', '\')
    $text = [System.IO.File]::ReadAllText($abs)
    [System.IO.File]::WriteAllText($abs, ($text -replace 'types: \[opened, synchronize, reopened, edited\]', 'types: [opened, synchronize]'))
    $d = @(Get-WorkflowFolderCallerDrift -RepoRoot $c)
    Assert-Equal $entryRel ((Get-Stale $d) -join ',') 'a changed trigger line is behind, and only that caller'
    $expectLine = [array]::IndexOf(@($text -split "`n"), '    types: [opened, synchronize, reopened, edited]') + 1
    Assert-True ($expectLine -gt 1) "fixture: the changed line sits at line $expectLine"
    Assert-Equal $expectLine (($d | Where-Object { $_.Rel -eq $entryRel }).Line) 'the first differing line is named'
    Assert-Equal 0 (($d | Where-Object { $_.Rel -eq $budgetRel }).Line) 'the current caller reports line 0'
    Assert-True (-not ($d | Where-Object { $_.PSObject.Properties.Name -contains 'Content' })) 'no text from the placed file is returned'
    # A call into somebody else's workflow is not ours to neutralise.
    $c = New-Consumer
    $abs = Join-Path $c ($budgetRel -replace '/', '\')
    [System.IO.File]::WriteAllText($abs, ([System.IO.File]::ReadAllText($abs) -replace 'DKJ-Solutions/dkj-marketplace/', 'someone/else/'))
    Assert-Equal $budgetRel ((Get-Stale @(Get-WorkflowFolderCallerDrift -RepoRoot $c)) -join ',') 'a uses: of another repo reads behind'
    [System.IO.File]::WriteAllText($abs, '')
    Assert-Equal $budgetRel ((Get-Stale @(Get-WorkflowFolderCallerDrift -RepoRoot $c)) -join ',') 'an empty placed caller is behind'

    # --- 3b. The live branch is part of the template ----------------------------------------------------
    Write-Host '-- 3b. the live branch --' -ForegroundColor Cyan
    $c = New-Consumer -Live 'live-prod'
    Assert-Equal '' ((Get-Stale @(Get-WorkflowFolderCallerDrift -RepoRoot $c)) -join ',') 'a caller placed with the declared live branch is current'
    $livePlaced = [System.IO.File]::ReadAllText((Join-Path $c ($entryRel -replace '/', '\')))
    Assert-True ($livePlaced -match 'branches: \[main, live-prod\]') 'fixture: the placed caller lists the live branch'
    $c = New-Consumer
    [System.IO.File]::WriteAllText((Join-Path $c 'scripts\repo-config.ps1'), "function Get-ShopifyLiveDeployBranch { 'live-prod' }$Nl")
    Assert-Equal $entryRel ((Get-Stale @(Get-WorkflowFolderCallerDrift -RepoRoot $c)) -join ',') 'a caller that predates a declared live branch is behind'

    # --- 4. Absent ---------------------------------------------------------------------------------------
    Write-Host '-- 4. an absent caller is not this check''s to report --' -ForegroundColor Cyan
    $c = New-Consumer
    Remove-Item -LiteralPath (Join-Path $c ($entryRel -replace '/', '\'))
    Assert-Equal 1 @(Get-WorkflowFolderCallerDrift -RepoRoot $c).Count 'one record: the absent caller is [UNADOPTED]''s'

    # --- 5. The readers ------------------------------------------------------------------------------------
    Write-Host '-- 5. check-script-contract prints [BEHIND], non-counting, and the hook forwards it --' -ForegroundColor Cyan
    $c = New-Consumer -WithLibs
    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Check -ConsumerPathOverride $c -SkipReachability) -join $Nl
    Assert-Equal 0 ([regex]::Matches($out, '\[BEHIND\]')).Count 'current callers: no [BEHIND] line'
    Assert-True ($out -match '\[OK\]\s+workflow-folder caller: \.github/workflows/branch-entry\.yml matches') 'current callers: an [OK] line'

    $abs = Join-Path $c ($entryRel -replace '/', '\')
    [System.IO.File]::WriteAllText($abs, ([System.IO.File]::ReadAllText($abs) -replace 'types: \[opened, synchronize, reopened, edited\]', 'types: [opened]'))
    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Check -ConsumerPathOverride $c -SkipReachability) -join $Nl
    $code = $LASTEXITCODE
    Assert-Equal 1 ([regex]::Matches($out, '\[BEHIND\]')).Count 'stale caller: one [BEHIND] line'
    Assert-True ($out -match '\[BEHIND\] \.github/workflows/branch-entry\.yml differs .*first at line \d+.*re-run adopt-workflow-folder\.ps1 -Apply') 'it names the file, the line and the way to take the change'
    Assert-Equal 0 $code 'and it counts toward nothing'

    $hookOut = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Hook -CheckScriptOverride $Check -ConsumerPathOverride $c) -join $Nl
    Assert-True ($hookOut -match '(?m)^\s+\[BEHIND\] \.github/workflows/branch-entry\.yml') 'the session hook forwards the line into the session'

    # Declined: naming adopt-workflow-folder silences it, and naming adopt-ci-floor does not.
    $cfg = Join-Path $c 'scripts\repo-config.ps1'
    $cfgOriginal = [System.IO.File]::ReadAllText($cfg)
    [System.IO.File]::WriteAllText($cfg, $cfgOriginal + "${Nl}function Get-DeclinedAdoptions { @('adopt-ci-floor') }$Nl")
    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Check -ConsumerPathOverride $c -SkipReachability) -join $Nl
    Assert-Equal 1 ([regex]::Matches($out, '\[BEHIND\] \.github/workflows/branch-entry')).Count 'declining adopt-ci-floor does not silence the callers'
    [System.IO.File]::WriteAllText($cfg, $cfgOriginal + "${Nl}function Get-DeclinedAdoptions { @('adopt-workflow-folder') }$Nl")
    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Check -ConsumerPathOverride $c -SkipReachability) -join $Nl
    Assert-Equal 0 ([regex]::Matches($out, '\[BEHIND\] \.github/workflows/branch-entry')).Count 'declined: no [BEHIND] line for the callers'
} finally {
    if (Test-Path -LiteralPath $Fixture) { Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "workflow-folder-callers-lib.tests: $script:pass passed, $script:fail failed." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
