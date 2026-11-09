<#
.SYNOPSIS
    Tests for plugins/dkj-policy/apps/admin/lib/dayplan-sync-lib.ps1 -- the day plan's shared copy (#3924): which repo it
    is shared through, the ASCII payload and the bounds on another machine's, the merge of one day's copies, and two
    machines planning, adding to and reading one day through a bare remote of the tests' own.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\dayplan-sync-lib.ps1')
$Script = Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\pages\day-plan.ps1'

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
# A statement that throws is skipped under 'Continue', so count it instead (as dayplan.tests.ps1 does).
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -eq "$Actual") ($Name + $(if ("$Expected" -ne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

$it = { param([string]$t, [double]$h, [string]$at = '') $o = [pscustomobject]@{ title = $t; hours = $h; mode = 'go'; ref = ''; added = [bool]$at }; if ($at) { $o | Add-Member -NotePropertyName addedAt -NotePropertyValue $at }; $o }
$copy = { param([string]$planned, [object[]]$items, $close = $null) [pscustomobject]@{ date = '2026-11-09'; goal = 'G'; items = $items; notToday = @(); overrides = @(); close = $close; planned = $planned } }

$savedShare = $env:DKJ_DAYPLAN_REPO
$savedState = $env:DKJ_ADMIN_STATE_DIR
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('dayplan-sync-tests-' + [guid]::NewGuid().ToString('N'))
try {
    [void](New-Item -ItemType Directory -Path $tmp -Force)

    Write-Host '-- the home repo' -ForegroundColor Cyan
    $settings = Join-Path $tmp 'settings.json'
    [System.IO.File]::WriteAllText($settings, '{"env":{"DKJ_DAYPLAN_REPO":"me/days"}}')
    $env:DKJ_DAYPLAN_REPO = $null
    Assert-Equal 'me/days' (Get-DayPlanShareRepo -SettingsPath $settings) 'unset in the environment, the repo is read from the settings env block'
    $env:DKJ_DAYPLAN_REPO = 'off'
    Assert-Equal '' (Get-DayPlanShareRepo -SettingsPath $settings) '''off'' in the environment is an explicit no, whatever the settings say'
    $env:DKJ_DAYPLAN_REPO = 'other/repo'
    Assert-Equal 'other/repo' (Get-DayPlanShareRepo -SettingsPath $settings) 'the environment wins over the settings file'
    $env:DKJ_DAYPLAN_REPO = 'https://evil.example/x'
    Assert-Equal '' (Get-DayPlanShareRepo -SettingsPath $settings) 'a value that is not owner/name shares nothing'
    $env:DKJ_DAYPLAN_REPO = 'off'
    $r = Invoke-DayPlanSync -GitDir (Join-Path $tmp 'none.git') -MachineId 'abcdef01' -Fetch -Publish
    Assert-True (-not $r.Shared -and $r.Note -match '^not shared: ' -and -not (Test-Path (Join-Path $tmp 'none.git'))) 'with no repo the sync says not shared and sets nothing up'

    Write-Host '-- the payload' -ForegroundColor Cyan
    $accent = 'Caf' + [char]0x00E9 + ' plan'
    $day = [pscustomobject]@{ date = '2026-11-09'; goal = $accent; items = @((& $it 'A' 3), (& $it 'B' 3 '2026-11-09T10:00:00.000Z')); notToday = @('later'); overrides = @(); close = $null; planned = '2026-11-09T07:00:00.000Z' }
    $json = ConvertTo-DayPlanSharedJson -MachineId 'abcdef01' -Days @{ '2026-11-09' = $day }
    Assert-True ($json -cmatch '^[\x00-\x7E]*$' -and -not $json.Contains("`r")) 'the payload is pure ASCII with LF line ends, an accent included'
    $back = ConvertFrom-DayPlanSharedJson -Text $json
    Assert-True ($back.Machine -eq 'abcdef01' -and @($back.Days).Count -eq 1 -and $back.Days[0].goal -eq $accent) 'it reads back with its machine and the accent intact'
    Assert-True ($back.Days[0].items[1].addedAt -eq '2026-11-09T10:00:00.000Z' -and -not ($back.Days[0].items[0].PSObject.Properties.Name -contains 'addedAt')) 'an added item keeps when it was added; a planned item carries no such stamp'
    Assert-True ($null -eq (ConvertFrom-DayPlanSharedJson -Text 'nope') -and $null -eq (ConvertFrom-DayPlanSharedJson -Text '{"machine":"NOPE","days":[]}')) 'text that is not a payload, or names no machine id, is no payload'
    $poison = '{"machine":"abcdef01","days":[' +
        '{"date":"2026-11-08","goal":"bad","items":[{"title":"X","hours":"NaN","mode":"go"}]},' +
        '{"date":"not a date","goal":"g","items":[{"title":"X","hours":1,"mode":"go"}]},' +
        '{"date":"2026-11-09","goal":"' + ('G' * 400) + '","items":[{"title":"X","hours":1,"mode":"go"}],' +
        '"close":{"at":"2026-11-09T18:00:00Z","done":[0,5,"x"],"carried":[],"unplanned":[{"ref":"o/r#1","title":"T","url":"javascript:alert(1)","kind":"pr"},{"ref":"bad ref","title":"T","url":"","kind":"pr"}],"prs":2,"issues":1,"verdict":"partly"}}]}'
    $pz = ConvertFrom-DayPlanSharedJson -Text $poison
    Assert-True ($pz -and @($pz.Days).Count -eq 1 -and $pz.Days[0].date -eq '2026-11-09') 'a day with an item that does not hold, or no date, is dropped, and the rest still reads'
    Assert-True ($pz.Days[0].goal.Length -eq 300 -and (@($pz.Days[0].close.done) -join ',') -eq '0') 'another machine''s goal is cut, and a done index outside its own items is dropped'
    Assert-True (@($pz.Days[0].close.unplanned).Count -eq 1 -and $pz.Days[0].close.unplanned[0].url -eq '') 'an unplanned entry with a bad ref is dropped, and a url that is not GitHub''s is blanked'

    Write-Host '-- the merge' -ForegroundColor Cyan
    $a = & $copy '2026-11-09T07:00:00.000Z' @((& $it 'A' 3), (& $it 'B' 3))
    $b = & $copy '2026-11-09T07:00:00.000Z' @((& $it 'A' 3), (& $it 'B' 3), (& $it 'C' 1 '2026-11-09T11:00:00.000Z'))
    $c = & $copy '' @((& $it 'D' 1 '2026-11-09T09:00:00.000Z'))
    $m = Merge-DayPlanCopies -Copies @($a, $b, $c)
    Assert-Equal 'A,B,D,C' ((@($m.items) | ForEach-Object { $_.title }) -join ',') 'the plan is the base, and every item added after it joins once, in the order it was added'
    Assert-Equal 'A,B,C' ((@((Merge-DayPlanCopies -Copies @($b, $a)).items) | ForEach-Object { $_.title }) -join ',') 'an item another machine already copied is not added twice'
    $cased = & $copy '' @((& $it 'Y' 1 '2026-11-09T09:00:00.000Z'), (& $it 'y' 1 '2026-11-09T09:30:00.000Z'))
    Assert-Equal 'A,B,Y,y' ((@((Merge-DayPlanCopies -Copies @($a, $cased)).items) | ForEach-Object { $_.title }) -join ',') 'two items that differ only in case stay two items'
    $env:DKJ_ADMIN_STATE_DIR = Join-Path $tmp 'ahead'
    [void](New-Item -ItemType Directory -Path (Get-DayPlanDir) -Force)
    $ahead = (Get-Date).Date.AddDays(3).ToString('yyyy-MM-dd')
    [System.IO.File]::WriteAllText((Join-Path (Get-DayPlanDir) "$ahead.json"), '{"date":"' + $ahead + '","goal":"G","items":[]}')
    Assert-True ((Get-DayPlanLocalDays).ContainsKey($ahead)) 'a day planned ahead is among the days this machine publishes'
    $env:DKJ_ADMIN_STATE_DIR = $savedState
    $replaced = & $copy '2026-11-09T12:00:00.000Z' @((& $it 'New' 6))
    Assert-Equal 'New' ((@((Merge-DayPlanCopies -Copies @($b, $replaced)).items) | ForEach-Object { $_.title }) -join ',') 'a newer plan (a -Replace) is the base, and an item added before it does not come back'
    $closed = & $copy '2026-11-09T07:00:00.000Z' @((& $it 'A' 3)) ([pscustomobject]@{ at = '2026-11-09T18:00:00.000Z'; done = @(0); carried = @(); unplanned = @(); prs = 1; issues = 0; verdict = 'reached' })
    Assert-True ([object]::ReferenceEquals((Merge-DayPlanCopies -Copies @($b, $closed)), $closed)) 'a closed copy wins whole, since its done list counts its own items'
    Assert-True ($null -eq (Merge-DayPlanCopies -Copies @()) -and ((@((Merge-DayPlanCopies -Copies @($a)).items) | ForEach-Object { $_.title }) -join ',') -eq 'A,B') 'no copies is no day; one copy is that day'
    Assert-Equal 'later,soon' ((@((Merge-DayPlanCopies -Copies @(([pscustomobject]@{ date = '2026-11-09'; goal = 'G'; items = @((& $it 'A' 6)); notToday = @('later'); overrides = @(); close = $null; planned = '' }), ([pscustomobject]@{ date = '2026-11-09'; goal = 'G'; items = @((& $it 'A' 6)); notToday = @('later', 'soon'); overrides = @(); close = $null; planned = '' }))).notToday)) -join ',') 'not-today lines are the union'

    Write-Host '-- two machines, one day' -ForegroundColor Cyan
    $origin = Join-Path $tmp 'origin.git'
    & git init --quiet --bare $origin 2>$null
    $stateA = Join-Path $tmp 'machine-a'; $stateB = Join-Path $tmp 'machine-b'
    $today = (Get-Date).ToString('yyyy-MM-dd')
    $env:DKJ_DAYPLAN_REPO = 'off'
    $run = {
        param([string]$State, [string[]]$a)
        $env:DKJ_ADMIN_STATE_DIR = $State
        $o = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @a -SyncRemote $origin 2>&1
        [pscustomobject]@{ Out = ($o -join "`n"); Code = $LASTEXITCODE }
    }
    $planPath = Join-Path $tmp 'plan.json'
    [System.IO.File]::WriteAllText($planPath, '{"goal":"One day","items":[{"title":"A","hours":3,"mode":"go"},{"title":"B","hours":3,"mode":"plan"}]}')
    $r = & $run $stateA @('-PlanFile', $planPath, '-Apply')
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'Shared: shared through the test remote') 'machine A plans the day and publishes it'
    Assert-True (@(& git -C $origin for-each-ref --format='%(refname)' refs/dayplan).Count -eq 1 -and @(& git -C $origin branch --list).Count -eq 0) 'as one ref of its own, and no branch'
    $ident = @(& git -C $origin log -1 '--format=%an <%ae>|%ai' (@(& git -C $origin for-each-ref --format='%(refname)' refs/dayplan)[0]))[0]
    Assert-True ($ident -like 'dayplan <dayplan@noreply.invalid>|* +0000') 'the commit names a neutral identity and a UTC date'

    $r = & $run $stateB @('-Add', '-Title', 'C', '-Hours', '1', '-Mode', 'go')
    Assert-True ($r.Code -eq 0 -and $r.Out -match '3\. \[go\] C' -and $r.Out -match 'Total: 7 h') 'machine B adds to the day A planned, held against the whole day'
    $r = & $run $stateB @('-PlanFile', $planPath, '-Apply')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'already planned') 'and B cannot plan a second day over it'
    $r = & $run $stateB @('-Add', '-Title', 'Huge', '-Hours', '2', '-Mode', 'go')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'does not fit') 'an addition that takes the merged day over 8 h is refused'

    [void](& $run $stateA @('-Sync'))
    $r = & $run $stateA @('-Status')
    $sm = try { $r.Out | ConvertFrom-Json } catch { $null }
    Assert-True ($sm -and (((@($sm.day.items) | ForEach-Object { $_.title }) -join ',') -eq 'A,B,C') -and $sm.shared -match 'with 1 other machine') 'after a sync, machine A''s Today reads B''s addition and names the other machine'
    $r = & $run $stateA @('-Add', '-Title', 'D', '-Hours', '1', '-Mode', 'go')
    [void](& $run $stateB @('-Sync'))
    $r = & $run $stateB @('-Status')
    $sb = try { $r.Out | ConvertFrom-Json } catch { $null }
    Assert-Equal 'A,B,C,D' ((@($sb.day.items) | ForEach-Object { $_.title }) -join ',') 'and B reads A''s addition back, each item once'
    Assert-True ([System.IO.File]::ReadAllText((Join-Path $stateB 'dayplan\sync.log')) -match 'shared through the test remote') 'the last sync''s outcome is in sync.log beside the day files'
} finally {
    $env:DKJ_DAYPLAN_REPO = $savedShare
    $env:DKJ_ADMIN_STATE_DIR = $savedState
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host "dayplan-sync: $script:pass passed, $script:fail failed"
if ($script:fail) { exit 1 }
exit 0
