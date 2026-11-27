<#
.SYNOPSIS
    Tests for scripts/lib/ci-floor-runners-lib.ps1 (issue #4529): a placed CI-floor runner held to the
    template this plugin version composes, its shared-scripts pin aside -- and the [BEHIND] line
    check-script-contract.ps1 and its session hook carry from that comparison.

.DESCRIPTION
    The measured case: a consumer's fold-on-merge.yml from v7.0.0 had no #4479 retry, stood down on a
    moved trunk and stranded five entries, while no session check said a word. So the scenarios are the
    four states a placed runner can be in -- the same as the template, different only in its pin,
    different in its body, and absent -- plus the trunk and line-ending differences that must not read as
    drift, and the two readers that print the result.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'scripts\lib\ref-print-lib.ps1')
. (Join-Path $RepoRoot 'scripts\lib\write-target-lib.ps1')
. (Join-Path $RepoRoot 'scripts\lib\ci-floor-runners-lib.ps1')
$Check = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\scripts\sync\check-script-contract.ps1'
$Hook  = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\script-contract-sessioncheck.ps1'
$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) "ci-floor-runners-test-$PID-$([guid]::NewGuid().ToString('n'))"

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

$Pin = '3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.7.0'
$Nl = "`n"

function New-Consumer {
    <# A consumer tree with the five runners placed as adopt-ci-floor would place them at -Pin. #>
    param([string]$Trunk = 'main', [string]$Ref = $Pin, [switch]$WithLibs)
    $root = Join-Path $Fixture ([guid]::NewGuid().ToString('n'))
    New-Item -ItemType Directory -Path (Join-Path $root '.github\workflows') -Force | Out-Null
    # The tree's own pull_request workflow, which is what merge-on-green's wake list is read off: adoption
    # in a repo with none places the CI skeleton under exactly this name.
    [System.IO.File]::WriteAllText((Join-Path $root '.github\workflows\ci.yml'), "name: CI${Nl}on:${Nl}  pull_request:${Nl}jobs:${Nl}  ci:${Nl}    runs-on: ubuntu-latest${Nl}")
    foreach ($t in @(Get-CiFloorRunnerTargets -Trunk $Trunk -WriteRunnerRef $Ref -WakeNames @('CI'))) {
        [System.IO.File]::WriteAllText((Join-Path $root ($t.Rel -replace '/', '\')), $t.Content)
    }
    if ($WithLibs) {
        New-Item -ItemType Directory -Path (Join-Path $root 'scripts\lib') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $root '.dkj\dkj-repo-workflow') -Force | Out-Null
        Copy-Item (Join-Path $RepoRoot 'scripts\lib\branch-info.ps1') (Join-Path $root 'scripts\lib\branch-info.ps1')
        Copy-Item (Join-Path $RepoRoot 'scripts\repo-config.ps1') (Join-Path $root 'scripts\repo-config.ps1')
    }
    return $root
}

function Get-Stale { param([object[]]$Drift) return @($Drift | Where-Object { $_.Stale } | ForEach-Object { $_.Rel }) }

$foldRel = '.github/workflows/fold-on-merge.yml'

try {
    Write-Host '== ci-floor-runners-lib.tests: scripts/lib/ci-floor-runners-lib.ps1 ==' -ForegroundColor Cyan

    # --- 1. The composition ---------------------------------------------------------------------------
    Write-Host '-- 1. the five runners, composed --' -ForegroundColor Cyan
    $targets = @(Get-CiFloorRunnerTargets -Trunk 'main' -WriteRunnerRef $Pin -WakeNames @('CI'))
    Assert-Equal 5 $targets.Count 'five runners are composed'
    $fold = ($targets | Where-Object { $_.Rel -eq $foldRel }).Content
    Assert-True ($fold -match 'attempt \$attempt of 3 \(#4479\)') 'the fold runner carries the #4479 retry -- the change the measured consumer never received'
    Assert-True ($fold -match ('(?m)^\s+ref: ' + [regex]::Escape($Pin) + '$')) 'the shared scripts are checked out at the ref passed in'
    $mog = ($targets | Where-Object { $_.Rel -eq '.github/workflows/merge-on-green.yml' }).Content
    Assert-True ($mog -match '(?m)^    workflows: \["CI"\]$') 'merge-on-green wakes on the names passed in'

    # --- 2. In sync, and different only in the pin -------------------------------------------------------
    Write-Host '-- 2. a runner as placed, at any pin, is current --' -ForegroundColor Cyan
    foreach ($ref in @($Pin, 'v6.0.0', 'main', '0123456789abcdef0123456789abcdef01234567 # v1.0.0')) {
        $c = New-Consumer -Ref $ref
        $d = @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'main')
        Assert-Equal 5 $d.Count "pin '$ref': every placed runner is reported"
        Assert-Equal '' ((Get-Stale $d) -join ',') "pin '$ref': none of them is behind -- the pin is adopt-ci-floor's own verdict, not drift"
    }

    # CRLF on disk (core.autocrlf=true) is the same runner.
    $c = New-Consumer
    $abs = Join-Path $c ($foldRel -replace '/', '\')
    [System.IO.File]::WriteAllText($abs, ([System.IO.File]::ReadAllText($abs) -replace "`n", "`r`n"))
    Assert-Equal '' ((Get-Stale @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'main')) -join ',') 'a CRLF checkout of a current runner is current'

    # A non-main trunk: composed with the trunk this tree declares.
    $c = New-Consumer -Trunk 'trunk'
    Assert-Equal '' ((Get-Stale @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'trunk')) -join ',') 'a non-main trunk, read with that trunk, is current'
    Assert-True ((Get-Stale @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'main')).Count -gt 0) 'and read against main it is not -- the trunk is part of the template'

    # --- 3. Behind: the measured case -------------------------------------------------------------------
    Write-Host '-- 3. a runner missing a later change is behind --' -ForegroundColor Cyan
    $c = New-Consumer
    $abs = Join-Path $c ($foldRel -replace '/', '\')
    $old = [System.IO.File]::ReadAllText($abs) -replace '(?ms)^\s+\$attempt = 0.*?^\s+if \(\$foldExitCode -eq 2\) \{.*?^\s+\}\n', ''
    Assert-True ($old -notmatch '#4479\)\."') 'fixture: the retry loop is gone from the placed copy'
    [System.IO.File]::WriteAllText($abs, $old)
    $d = @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'main')
    Assert-Equal $foldRel ((Get-Stale $d) -join ',') 'the pre-#4479 fold runner is behind, and only that one'
    $rec = $d | Where-Object { $_.Rel -eq $foldRel }
    Assert-True ($rec.Line -gt 1) "the first differing line is named ($($rec.Line))"

    # An empty file is behind too, not current.
    [System.IO.File]::WriteAllText($abs, '')
    Assert-Equal $foldRel ((Get-Stale @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'main')) -join ',') 'an empty placed runner is behind'

    # A new pull_request workflow after adoption changes merge-on-green's wake list, and only that runner:
    # the delete-and-re-run remedy composes the new list, so reporting it is right (code review on #4529).
    $c = New-Consumer
    [System.IO.File]::WriteAllText((Join-Path $c '.github\workflows\lint.yml'), "name: Lint${Nl}on:${Nl}  pull_request:${Nl}jobs:${Nl}  lint:${Nl}    runs-on: ubuntu-latest${Nl}")
    Assert-Equal '.github/workflows/merge-on-green.yml' ((Get-Stale @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'main')) -join ',') 'a pull_request workflow added after adoption puts merge-on-green behind, and only it'

    # --- 4. Absent -------------------------------------------------------------------------------------
    Write-Host '-- 4. an absent runner is not this check''s to report --' -ForegroundColor Cyan
    $c = New-Consumer
    Remove-Item -LiteralPath (Join-Path $c ($foldRel -replace '/', '\'))
    $d = @(Get-CiFloorRunnerDrift -RepoRoot $c -Trunk 'main')
    Assert-Equal 4 $d.Count 'four records: the absent runner is [UNADOPTED]''s, not this one''s'

    # --- 5. The readers: check-script-contract and its hook ------------------------------------------------
    Write-Host '-- 5. check-script-contract prints [BEHIND], non-counting, and the hook forwards it --' -ForegroundColor Cyan
    $c = New-Consumer -WithLibs
    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Check -ConsumerPathOverride $c -SkipReachability) -join $Nl
    Assert-Equal 0 ([regex]::Matches($out, '\[BEHIND\]')).Count 'current floor: no [BEHIND] line'
    Assert-True ($out -match '\[OK\]\s+ci-floor runner: \.github/workflows/fold-on-merge\.yml matches') 'current floor: an [OK] line on a deliberate run'

    $abs = Join-Path $c ($foldRel -replace '/', '\')
    [System.IO.File]::WriteAllText($abs, $old)
    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Check -ConsumerPathOverride $c -SkipReachability) -join $Nl
    $code = $LASTEXITCODE
    Assert-Equal 1 ([regex]::Matches($out, '\[BEHIND\]')).Count 'stale fold: one [BEHIND] line'
    Assert-True ($out -match '\[BEHIND\] \.github/workflows/fold-on-merge\.yml differs .*first at line \d+.*re-run adopt-ci-floor\.ps1 -Apply') 'it names the file, the line and the way to take the change'
    Assert-Equal 0 $code 'and it counts toward nothing -- the exit code is the contract''s, not the floor''s'

    $hookOut = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Hook -CheckScriptOverride $Check -ConsumerPathOverride $c) -join $Nl
    Assert-True ($hookOut -match 'a CI-floor runner in this repo is behind') 'the session hook leads the block'
    Assert-True ($hookOut -match '(?m)^\s+\[BEHIND\] \.github/workflows/fold-on-merge\.yml') 'and forwards the line into the session'

    # Declined: a repo that named adopt-ci-floor in Get-DeclinedAdoptions hears nothing about its runners.
    $cfg = Join-Path $c 'scripts\repo-config.ps1'
    [System.IO.File]::AppendAllText($cfg, "${Nl}function Get-DeclinedAdoptions { @('adopt-ci-floor') }$Nl")
    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Check -ConsumerPathOverride $c -SkipReachability) -join $Nl
    Assert-Equal 0 ([regex]::Matches($out, '\[BEHIND\]')).Count 'declined: no [BEHIND] line'
} finally {
    if (Test-Path -LiteralPath $Fixture) { Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "ci-floor-runners-lib.tests: $script:pass passed, $script:fail failed." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
