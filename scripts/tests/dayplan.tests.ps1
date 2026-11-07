<#
.SYNOPSIS
    Tests for plugins/dkj-policy/hub/lib/dayplan-lib.ps1 and plugins/dkj-policy/hub/pages/day-plan.ps1 -- the day plan
    (#3859): reading a proposed plan, the 6-8 h band that Paula holds both ways, the measured pace, matching the plan
    against GitHub's finished work, the carry-over, the texts, and the script's refusals and day file.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'plugins\dkj-policy\hub\lib\dayplan-lib.ps1')
$Script = Join-Path $RepoRoot 'plugins\dkj-policy\hub\pages\day-plan.ps1'

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
# A statement that throws is skipped under 'Continue', so count it instead (as goals.tests.ps1 does).
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -eq "$Actual") ($Name + $(if ("$Expected" -ne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

$item = { param([string]$t, [double]$h, [string]$m = 'go', [string]$r = '') [pscustomobject]@{ title = $t; hours = $h; mode = $m; ref = $r; added = $false } }

Write-Host '-- reading a plan' -ForegroundColor Cyan
$ok = ConvertTo-DayPlan -Repo 'o/r' -Json '{"goal":"Ship it","items":[{"title":"A","hours":3,"mode":"go","ref":"#12"},{"title":"B","hours":"2.5","mode":"PLAN","ref":"x/y#7"},{"title":"C","hours":1,"mode":"go","ref":"https://github.com/p/q/pull/9"}],"notToday":["later"," "]}'
Assert-Equal '' $ok.Error 'a well-formed plan reads without error'
Assert-Equal 'o/r#12|x/y#7|p/q#9' ((@($ok.Plan.items) | ForEach-Object { $_.ref }) -join '|') 'a ref is #n against the repo, owner/repo#n, or an issue/PR URL, all as owner/repo#n'
Assert-Equal 'plan' $ok.Plan.items[1].mode 'the mode is read case-insensitively'
Assert-Equal 2.5 $ok.Plan.items[1].hours 'an hour estimate may be a decimal string'
Assert-Equal 'later' (@($ok.Plan.notToday) -join '|') 'a blank not-today line is dropped'
Assert-True ((ConvertTo-DayPlan -Json '{"items":[{"title":"A","hours":1,"mode":"go"}]}').Error -match 'no goal') 'a plan without a day goal is refused'
Assert-True ((ConvertTo-DayPlan -Json '{"goal":"g","items":[{"title":"A","hours":0,"mode":"go"}]}').Error -match 'hour estimate') 'an item without an hour estimate is refused'
Assert-True ((ConvertTo-DayPlan -Json '{"goal":"g","items":[{"title":"A","hours":9,"mode":"go"}]}').Error -match 'hour estimate') 'one item longer than the whole day is refused'
Assert-True ((ConvertTo-DayPlan -Json '{"goal":"g","items":[{"title":"A","hours":1,"mode":"later"}]}').Error -match "'plan'") 'a mode other than plan or go is refused'
Assert-True ((ConvertTo-DayPlan -Json '{"goal":"g","items":[{"title":"A","hours":"NaN","mode":"go"}]}').Error -match 'hour estimate' -and (ConvertTo-DayPlan -Json '{"goal":"g","items":[{"title":"A","hours":"Infinity","mode":"go"}]}').Error -match 'hour estimate') 'NaN and Infinity are refused, since NaN passes every comparison and would read as inside the band'
Assert-True ((ConvertTo-DayPlan -Json '{"goal":"g","items":[{"title":"A","hours":1,"mode":"go","ref":"#5"}]}').Error -match 'ref') 'a bare #n with no repo to resolve it against is refused'
Assert-True ((ConvertTo-DayPlan -Json 'not json').Error -match 'not valid JSON') 'text that is not JSON is refused'
Assert-True ($null -eq (ConvertTo-DayPlanRef -Ref ('o/r' + [char]0x1B + '[2J#5')) -and $null -eq (ConvertTo-DayPlanRef -Ref ('o/r' + [char]0x202E + '#5'))) 'a ref carrying a control or format character is refused, so it never reaches the console'

Write-Host '-- the band, strict both ways' -ForegroundColor Cyan
Assert-Equal 'under' (Test-DayPlanBudget -Items @((& $item 'A' 3), (& $item 'B' 2.5))).Verdict '5.5 h is not a full day'
Assert-Equal 'ok' (Test-DayPlanBudget -Items @((& $item 'A' 3), (& $item 'B' 3))).Verdict '6 h is the bottom of the band'
Assert-Equal 'ok' (Test-DayPlanBudget -Items @((& $item 'A' 4), (& $item 'B' 4))).Verdict '8 h is the top of the band'
$over = Test-DayPlanBudget -Items @((& $item 'A' 5), (& $item 'B' 3.5))
Assert-True ($over.Verdict -eq 'over' -and $over.Message -match '0\.5 h over') 'over 8 h is too much, and the message says by how much'
Assert-True ((Test-DayPlanBudget -Items @()).Message -match '-Override') 'a refusal names the way past it'

Write-Host '-- the measured pace' -ForegroundColor Cyan
Assert-Equal 2 (Get-DayPlanMedian -Values @(1, 2, 9)) 'the median of an odd list is the middle'
Assert-Equal 1.5 (Get-DayPlanMedian -Values @(0, 1, 2, 9)) 'the median of an even list is the mean of the middle two'
Assert-Equal 0 (Get-DayPlanMedian -Values @()) 'no values is 0'
$mon = [datetime]'2026-11-02'
$merged = @([datetime]'2026-11-02T10:00', [datetime]'2026-11-02T11:00', [datetime]'2026-11-02T15:00', [datetime]'2026-11-04T09:00', [datetime]'2026-11-07T12:00')
$cap = Get-DayPlanCapacity -MergedAt $merged -From $mon -To ([datetime]'2026-11-09')
Assert-Equal 5 $cap.Days 'only Monday to Friday are working days'
Assert-Equal 0 $cap.Median 'a working day with nothing merged counts as 0 (3,0,1,0,0), and a weekend merge does not count'

Write-Host '-- reading GitHub''s answer' -ForegroundColor Cyan
$json = '[{"number":3,"title":"T","url":"https://github.com/o/r/pull/3","repository":{"nameWithOwner":"o/r"},"closedAt":"2026-11-07T10:00:00Z"},{"number":3,"title":"T","url":"https://github.com/o/r/pull/3","repository":{"nameWithOwner":"o/r"},"closedAt":"2026-11-07T10:00:00Z"},{"number":4,"title":"U","url":"https://github.com/o/s/issues/4","repository":{},"closedAt":null}]'
$f = @(ConvertFrom-DayPlanSearch -Json $json -Kind 'pr')
Assert-Equal 2 $f.Count 'a JSON array reads as its elements, deduplicated on ref (5.1 emits an array as one object)'
Assert-Equal 'o/s#4' $f[1].ref 'a missing repository is read off the URL'
Assert-True ($f[0].closedAt -is [datetime] -and $null -eq $f[1].closedAt) 'closedAt is a DateTime, or null when GitHub gives none'
Assert-Equal 0 @(ConvertFrom-DayPlanSearch -Json '' -Kind 'pr').Count 'no answer is no records'

Write-Host '-- matching the plan against what got done' -ForegroundColor Cyan
$items = @((& $item 'A' 2 'go' 'o/r#1'), (& $item 'B' 2 'plan' 'o/r#2'), (& $item 'C' 2 'go' ''))
$fin = @([pscustomobject]@{ ref = 'o/r#1'; title = 'A' }, [pscustomobject]@{ ref = 'o/r#9'; title = 'Z' })
$c = Compare-DayPlanDone -Items $items -Finished $fin -MarkedDone @(2)
Assert-Equal '0,2' (@($c.Done) -join ',') 'an item is done by its ref, or by the owner marking it'
Assert-Equal '1' (@($c.Carried) -join ',') 'what is not done is carried to tomorrow'
Assert-Equal 'o/r#9' (@($c.Unplanned | ForEach-Object { $_.ref }) -join ',') 'finished work no item names is extra'
Assert-Equal 'partly' $c.Verdict 'some done is partly reached'
Assert-Equal 'reached' (Compare-DayPlanDone -Items $items -Finished $fin -MarkedDone @(1, 2)).Verdict 'all done is reached'
Assert-Equal 'missed' (Compare-DayPlanDone -Items $items -Finished @()).Verdict 'none done is missed'
$pair = @([pscustomobject]@{ ref = 'o/r#50'; title = 'Fix B'; kind = 'pr'; closes = @('o/r#2') }, [pscustomobject]@{ ref = 'o/r#2'; title = 'B'; kind = 'issue'; closes = @() },
          [pscustomobject]@{ ref = 'o/r#60'; title = 'Fix Y'; kind = 'pr'; closes = @('o/r#61') }, [pscustomobject]@{ ref = 'o/r#61'; title = 'Y'; kind = 'issue'; closes = @() })
$pc = Compare-DayPlanDone -Items $items -Finished $pair
Assert-True (@($pc.Done) -contains 1) 'a planned issue a merged PR closed is done'
Assert-Equal 'o/r#60' (@($pc.Unplanned | ForEach-Object { $_.ref }) -join ',') 'the PR that closed a planned issue is not extra, and an unplanned PR with its issue is one extra, not two'
$onlyPr = Compare-DayPlanDone -Items $items -Finished @([pscustomobject]@{ ref = 'o/r#50'; title = 'Fix B'; kind = 'pr'; closes = @('o/r#2') })
Assert-True (@($onlyPr.Done) -contains 1) 'the PR alone marks its planned issue done, even before the issue''s own close is found'
$gq = '[{"number":50,"title":"Fix B","url":"https://github.com/o/r/pull/50","repository":{"nameWithOwner":"o/r"},"closedAt":"2026-11-07T10:00:00Z","closingIssuesReferences":{"nodes":[{"number":2,"repository":{"nameWithOwner":"o/r"}},{"number":3,"repository":{}}]}}]'
Assert-Equal 'o/r#2,o/r#3' ((@(ConvertFrom-DayPlanSearch -Json $gq -Kind 'pr')[0].closes) -join ',') 'a PR node carries the issues it closed, a missing repository taken as the PR''s own'
Assert-True ((Get-DayPlanPrQuery) -match 'closingIssuesReferences' -and (Get-DayPlanPrQuery) -match '\$after: String' -and (Get-DayPlanPrQuery) -notmatch '"') 'the PR query reads closing issues, pages with a cursor, and holds no quote a command line could mangle'

Write-Host '-- the carry-over' -ForegroundColor Cyan
$closed = [pscustomobject]@{ items = $items; close = [pscustomobject]@{ carried = @(1) } }
Assert-Equal 'B' ((@(Get-DayPlanCarryOver -Day $closed) | ForEach-Object { $_.title }) -join ',') 'a closed day leaves its carried items'
Assert-Equal 'A,B,C' ((@(Get-DayPlanCarryOver -Day ([pscustomobject]@{ items = $items; close = $null })) | ForEach-Object { $_.title }) -join ',') 'a day never closed leaves every item'
Assert-Equal 0 @(Get-DayPlanCarryOver -Day $null).Count 'no day leaves nothing'

Write-Host '-- the texts' -ForegroundColor Cyan
$day = [pscustomobject]@{ goal = 'Ship it'; items = $items; notToday = @('later'); overrides = @([pscustomobject]@{ at = 'start'; reason = 'half day' }) }
$t = Format-DayPlanText -Day $day
Assert-True ($t -match '1\. \[go\] A -- 2 h  o/r#1' -and $t -match '\[plan first\] B' -and $t -match 'Total: 6 h of 8 h' -and $t -match 'Not today:' -and $t -match 'Override \(start\): half day') 'the plan shows mode, hours, ref, the total, not-today and the override'
$day | Add-Member -NotePropertyName close -NotePropertyValue ([pscustomobject]@{ done = @(0, 2); carried = @(1); unplanned = @([pscustomobject]@{ ref = 'o/r#9'; title = 'Z' }); prs = 2; issues = 1; verdict = 'partly' })
$ct = Format-DayCloseText -Day $day
Assert-True ($ct -match 'Day goal partly reached: Ship it' -and $ct -match 'tomorrow B' -and $ct -match 'extra    Z' -and $ct -match '2 of 3 planned done, 1 extra' -and $ct -match 'override \(start\): half day' -and $ct -match 'You can close the day\.') 'the receipt says what got done, what moves, the override, and that the day can be closed'
$wk = Get-DayPlanWeek -Date ([datetime]'2026-11-07') -Days @{ '2026-11-02' = $day; '2026-11-09' = $day; '2026-11-05' = ([pscustomobject]@{ goal = 'open day'; items = $items; close = $null }) }
Assert-Equal '2026-11-02' $wk.Monday.ToString('yyyy-MM-dd') 'a Saturday''s week starts on the Monday before'
Assert-Equal '2' @($wk.Rows).Count 'the week holds its own days only'
$wt = Format-DayPlanWeekText -Week $wk -Prs 7 -Issues 3
Assert-True ($wt -match 'Mon 02' -and $wt -match 'not closed' -and $wt -match '7 PR\(s\) merged, 3 issue\(s\) closed' -and $wt -match 'reached on 0 of 2') 'the week shows each day, the totals, and how often the goal was reached'

Write-Host '-- the script' -ForegroundColor Cyan
$state = Join-Path ([System.IO.Path]::GetTempPath()) ('dkj-dayplan-tests-' + [guid]::NewGuid().ToString('N'))
$prevState = $env:DKJ_HUB_STATE_DIR
$env:DKJ_HUB_STATE_DIR = $state
try {
    [void](New-Item -ItemType Directory -Path $state -Force)
    $planPath = Join-Path $state 'plan.json'
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $run = { param([string[]]$a) $o = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @a 2>&1; [pscustomobject]@{ Out = ($o -join "`n"); Code = $LASTEXITCODE } }
    $date = '2026-11-03'
    $file = Join-Path $state "dayplan\$date.json"

    [System.IO.File]::WriteAllText($planPath, '{"goal":"G","items":[{"title":"A","hours":3,"mode":"go","ref":"o/r#1"},{"title":"B","hours":2,"mode":"plan"}]}', $utf8)
    $r = & $run @('-PlanFile', $planPath, '-Apply', '-Date', $date)
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'not a full day' -and -not (Test-Path $file)) 'a plan under the band is refused and nothing is written'
    Assert-True ($r.Out -match '(?m)^  1\. \[go\] A') 'the plan prints one line per item, not one stripped line'

    $r = & $run @('-PlanFile', $planPath, '-Apply', '-Date', $date, '-Override', 'dentist in the afternoon')
    $saved = if (Test-Path $file) { [System.IO.File]::ReadAllText($file, $utf8) | ConvertFrom-Json } else { $null }
    Assert-True ($r.Code -eq 0 -and $saved -and $saved.overrides[0].reason -eq 'dentist in the afternoon' -and $saved.overrides[0].at -eq 'start') 'an override writes the day and keeps the reason'

    $r = & $run @('-Add', '-Title', 'Huge', '-Hours', '4', '-Mode', 'plan', '-Date', $date)
    Assert-True ($r.Code -eq 1 -and $r.Out -match "adding 'Huge'.*does not fit" -and @(([System.IO.File]::ReadAllText($file, $utf8) | ConvertFrom-Json).items).Count -eq 2) 'an addition that takes the day over 8 h is refused, and the day is unchanged'

    $r = & $run @('-Add', '-Title', 'Small', '-Hours', '1', '-Mode', 'go', '-Date', $date)
    $saved = [System.IO.File]::ReadAllText($file, $utf8) | ConvertFrom-Json
    Assert-True ($r.Code -eq 0 -and @($saved.items).Count -eq 3 -and $saved.items[2].added) 'an addition inside the band is added, marked as added during the day'

    $r = & $run @('-PlanFile', $planPath, '-Apply', '-Date', $date, '-Override', 'again')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'already planned' -and @(([System.IO.File]::ReadAllText($file, $utf8) | ConvertFrom-Json).items).Count -eq 3) 'applying over a day already planned is refused, so its additions are not lost'

    $r = & $run @('-Close', '-Done', '7', '-Date', $date, '-Author', 'nobody-at-all')
    Assert-True ($r.Code -eq 1 -and $r.Out -match '-Done 7 is not an item') 'a -Done that names no item is refused before GitHub is asked'

    $r = & $run @('-Add', '-Title', 'X', '-Hours', '1', '-Mode', 'go', '-Date', '2026-11-04')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'no plan for 2026-11-04') 'an addition to a day with no plan is refused'

    [System.IO.File]::WriteAllText($planPath, ('{"goal":"G","items":[{"title":"A' + [char]0x1B + '[2J","hours":3,"mode":"later"}]}'), $utf8)
    $r = & $run @('-PlanFile', $planPath, '-Date', $date)
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'needs a mode' -and $r.Out -notmatch [char]0x1B) 'a refusal quoting a plan title prints it stripped'

    [System.IO.File]::WriteAllText((Join-Path $state 'dayplan\2026-11-05.json'), '{ not json', $utf8)
    $r = & $run @('-Add', '-Title', 'X', '-Hours', '1', '-Mode', 'go', '-Date', '2026-11-05')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'does not parse') 'a day file that does not parse is refused, never read as no plan and overwritten'

    $r = & $run @('-Context', '-Close')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'exactly one') 'two modes at once are refused'
} finally {
    $env:DKJ_HUB_STATE_DIR = $prevState
    Remove-Item -LiteralPath $state -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host "dayplan: $script:pass passed, $script:fail failed"
if ($script:fail) { exit 1 }
exit 0
