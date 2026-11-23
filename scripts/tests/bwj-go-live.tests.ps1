<#
.SYNOPSIS
    Regression tests for go-live's decisions -- plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-bwj/
    scripts/lib/go-live-rules.ps1 (#4402) -- and for the shape of go-live.ps1 itself.

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/bwj-go-live.tests.ps1

    go-live reaches gh, git and a real store at every step, so the script is not driven; what can be
    judged from data is in the lib and asserted here: the step order, the app-deploy switch the owner made
    part of the go-live word, the check states the merge waits on, the paths the live theme is verified on,
    the content-hash comparison, the record rewrite a skipped app deploy makes, and the resume line, which
    must never carry a marker. Read from the script's source: that it prints no marker and never deletes
    the promotion's head branch.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Ext      = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
$LibPath  = Join-Path $Ext 'scripts\lib\go-live-rules.ps1'
$Script   = Join-Path $Ext 'scripts\task\go-live.ps1'

$script:pass = 0
$script:fail = 0
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}

. $LibPath
. (Join-Path $Ext 'scripts\lib\live-record-lib.ps1')

Write-Host '== bwj-go-live.tests: the go-live decisions (#4402) ==' -ForegroundColor Cyan

Write-Host 'the steps' -ForegroundColor Cyan
Assert-Equal 'preflight,promote,checks,merge,verify,app,cut,notify' ((Get-GoLiveSteps) -join ',') 'the eight steps, in the order they run'
Assert-Equal 'verify,app,cut,notify' ((Get-GoLiveResumeSteps) -join ',') 'a resume starts only after the merge'

Write-Host 'the version' -ForegroundColor Cyan
Assert-True (Test-GoLiveVersion '3.2.0') 'X.Y.Z is a version'
Assert-True (Test-GoLiveVersion 'v3.2.0') "a leading 'v' is accepted"
Assert-True (-not (Test-GoLiveVersion '3.2')) 'X.Y is not'
Assert-True (-not (Test-GoLiveVersion ('3.2.' + [char]0x0663))) 'a non-ASCII digit is not'
Assert-True (-not (Test-GoLiveVersion '')) 'empty is not'

Write-Host 'the app-deploy switch on the line' -ForegroundColor Cyan
$d = Get-GoLiveAppDecision -AppRoot 'extensions'
Assert-True (-not $d.Ok) 'an app root and neither switch refuses'
Assert-True ($d.Message -match '-AppDeploy or -SkipAppDeploy') 'and names both switches'
Assert-True (-not (Get-GoLiveAppDecision -AppRoot 'extensions' -AppDeploy -SkipAppDeploy).Ok) 'both switches refuse'
Assert-Equal 'deploy' (Get-GoLiveAppDecision -AppRoot 'extensions' -AppDeploy).Mode '-AppDeploy deploys'
Assert-Equal 'hold' (Get-GoLiveAppDecision -AppRoot 'extensions' -SkipAppDeploy).Mode '-SkipAppDeploy holds'
Assert-Equal 'none' (Get-GoLiveAppDecision -AppRoot 'extensions' -AppDeploy -AppChanged $false).Mode 'no app file in the range: nothing to deploy'
Assert-True (-not (Get-GoLiveAppDecision -AppRoot '' -AppDeploy).Ok) 'no app root and -AppDeploy refuses'
Assert-Equal 'none' (Get-GoLiveAppDecision -AppRoot '').Mode 'no app root and no switch: none'
Assert-Equal 'none' (Get-GoLiveAppDecision -AppRoot '' -SkipAppDeploy).Mode 'no app root and -SkipAppDeploy: none'

Write-Host 'the required checks' -ForegroundColor Cyan
function New-Check([string]$Bucket) { [pscustomobject]@{ name = 'c'; bucket = $Bucket } }
Assert-Equal 'none' (Get-GoLiveCheckState -Checks @()) 'no checks: none'
Assert-Equal 'pass' (Get-GoLiveCheckState -Checks @((New-Check 'pass'), (New-Check 'skipping'))) 'pass and skipping: pass'
Assert-Equal 'pending' (Get-GoLiveCheckState -Checks @((New-Check 'pass'), (New-Check 'pending'))) 'one pending: pending'
Assert-Equal 'fail' (Get-GoLiveCheckState -Checks @((New-Check 'pending'), (New-Check 'fail'))) 'a failure wins over pending'
Assert-Equal 'fail' (Get-GoLiveCheckState -Checks @((New-Check 'cancel'))) 'a cancelled check fails'
Assert-Equal 'pending' (Get-GoLiveCheckState -Checks @((New-Check 'mystery'))) 'an unknown bucket is waited on, never merged over'
Assert-Equal 'pending' (Get-GoLiveCheckState -Checks @() -Required @('Shopify theme check')) 'a required check that has not reported is pending, not none'
Assert-Equal 'pending' (Get-GoLiveCheckState -Checks @((New-Check 'pass')) -Required @('other')) 'a required context missing from the reported checks is pending'
Assert-Equal 'pass' (Get-GoLiveCheckState -Checks @([pscustomobject]@{ name = 'Shopify theme check'; bucket = 'pass' }) -Required @('shopify theme check')) 'a required context that passed (any case) passes'
$rulesJson = '[{"type":"pull_request"},{"type":"required_status_checks","parameters":{"required_status_checks":[{"context":"Shopify theme check"},{"context":"lint"}]}}]'
Assert-Equal 'Shopify theme check,lint' ((Get-GoLiveRequiredContexts -RulesJson $rulesJson) -join ',') 'the required contexts are read off the branch rules'
$noRules = Get-GoLiveRequiredContexts -RulesJson '[]'   # assigned first, as go-live does
Assert-True (($null -ne $noRules) -and (@($noRules).Count -eq 0)) 'no rules: an empty list, not $null'
Assert-True ($null -eq (Get-GoLiveRequiredContexts -RulesJson 'not json')) 'an unreadable answer is $null, never "none required"'

Write-Host 'the verify paths and the comparison' -ForegroundColor Cyan
$v = @(Get-GoLiveVerifyPaths -Live @('sections/a.liquid', 'extensions/fn/src/run.js', 'extensions-old/x.liquid') -AppRoot 'extensions')
Assert-Equal 'sections/a.liquid,extensions-old/x.liquid' ($v -join ',') 'app files are left out, a sibling folder with the same prefix is not'
Assert-Equal 2 @(Get-GoLiveVerifyPaths -Live @('a/b', 'c/d') -AppRoot '').Count 'no app root: every live path'
$exp = @{ 'sections/a.liquid' = 'ABC'; 'snippets/gone.liquid' = '' }
Assert-Equal 0 @(Compare-GoLiveTheme -Expected $exp -Actual @{ 'sections/a.liquid' = 'abc' }).Count 'equal ids (any case) and an expected-absent file absent: no mismatch'
Assert-Equal 'sections/a.liquid' ((Compare-GoLiveTheme -Expected $exp -Actual @{ 'sections/a.liquid' = 'def' }) -join ',') 'a different id is a mismatch'
Assert-Equal 'snippets/gone.liquid' ((Compare-GoLiveTheme -Expected $exp -Actual @{ 'sections/a.liquid' = 'abc'; 'snippets/gone.liquid' = 'abc' }) -join ',') 'a deleted file still on live is a mismatch'
Assert-Equal 'sections/a.liquid' ((Compare-GoLiveTheme -Expected $exp -Actual @{}) -join ',') 'a file missing from the pull is a mismatch'

Assert-True (Test-GoLiveGlobPath 'templates/product.[handle].json') 'a bracketed template name is glob-shaped'
Assert-True (-not (Test-GoLiveGlobPath 'sections/a-b_c.liquid')) 'an ordinary path is not'
$chunks = @(Split-GoLiveChunks -Paths @(1..95 | ForEach-Object { "s/$_.liquid" }) -Size 40)
Assert-Equal '40,40,15' (($chunks | ForEach-Object { @($_.Paths).Count }) -join ',') 'the pull list is split in chunks of 40'
$one = @(Split-GoLiveChunks -Paths @('a/b', 'c/d') -Size 40)
Assert-Equal 1 $one.Count 'two paths are one chunk -- not flattened into two'
Assert-Equal 2 @($one[0].Paths).Count 'and that chunk holds both'

Write-Host 'the record, when the app deploy is skipped' -ForegroundColor Cyan
$rec = "# live-push record`n# promoted abcdef1 to live`nlive sections/a.liquid`nlive extensions/fn/run.js`nhold extensions/fn/old.js`nlive extensions-old/x.liquid`n"
$held = Set-GoLiveRecordAppHold -Text $rec -AppRoot 'extensions'
$parsed = ConvertFrom-LivePushRecord -Text $held
Assert-Equal 'sections/a.liquid,extensions-old/x.liquid' (@($parsed.Live) -join ',') 'only the app lines turn to hold'
Assert-True (@($parsed.Hold) -contains 'extensions/fn/run.js') 'the app file is held'
Assert-Equal 'abcdef1' (Get-LivePushRecordPromotion -Text $held).Sha 'the promotion line survives'
Assert-Equal ($rec -replace 'live extensions/fn/run\.js', 'hold extensions/fn/run.js') $held 'byte for byte apart from that line'

Write-Host 'the resume line' -ForegroundColor Cyan
$line = Format-GoLiveResumeLine -From 'cut' -RecordPath 'C:\Temp\live-push-record-x.txt' -Version 'v3.2.0' -AppSwitch '-SkipAppDeploy'
Assert-Equal "go-live.ps1 -Version 3.2.0 -ResumeFrom cut -LivePushRecord 'C:\Temp\live-push-record-x.txt' -SkipAppDeploy" $line 'the resume line names step, record, version and switch'
Assert-True ($line -notmatch 'AUTHORIZED') 'and never a marker'
Assert-True ((Format-GoLiveResumeLine -From 'verify' -RecordPath 'C:\Users\DAVEK_~2\AppData\Local\Temp\r.txt') -match [regex]::Escape("-LivePushRecord 'C:\Users\DAVEK_~2\AppData\Local\Temp\r.txt'")) 'an 8.3 TEMP path is kept (Victor''s review)'
Assert-True ((Format-GoLiveResumeLine -From 'cut' -RecordPath 'C:\a$(calc).txt') -match [regex]::Escape("'C:\a`$(calc).txt'")) 'a dollar sign is inert inside the single quotes'
Assert-True ((Format-GoLiveResumeLine -From 'cut' -RecordPath "C:\it's.txt") -match [regex]::Escape("'C:\it''s.txt'")) 'a quote in the path is doubled'
Assert-True ((Format-GoLiveResumeLine -From 'cut' -RecordPath "C:\a`nb.txt") -notmatch 'LivePushRecord') 'a path with a control character is left out'

Write-Host 'the script' -ForegroundColor Cyan
$src = [System.IO.File]::ReadAllText($Script)
Assert-True ($src -notmatch '(?i)LIVE-PUSH-AUTHORIZED[''"]') 'go-live composes no marker string'
Assert-True ($src -notmatch 'Get-ShopifyLivePushMarker') 'go-live never reads the marker seam'
Assert-True ($src -notmatch 'gh pr merge[^\r\n]*--delete-branch') 'the promotion merge never deletes its head branch'
Assert-True ($src -match 'gh pr merge \$pr --merge --admin --match-head-commit \$promotedSha') 'the promotion merges as a merge commit, only at the preflight''s commit'
Assert-True ($src -match 'isCrossRepository == false') 'a fork''s PR is never reused'
foreach ($f in @($LibPath, $Script)) {
    $bytes = [System.IO.File]::ReadAllBytes($f)
    Assert-True (-not ($bytes | Where-Object { $_ -gt 127 })) "$(Split-Path -Leaf $f) is pure ASCII"
}

Write-Host ''
Write-Host "Result: $script:pass pass, $script:fail fail." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
