<#
.SYNOPSIS
    Tests for plugins/dkj-policy/apps/admin/lib/goals-lib.ps1 -- the Goals page and the plan-goal skill (#3816): the query,
    the model read from GitHub's answer, the step to take Now and the ones Next, the "what now?" text, the plan a
    breakdown is filed from, and the page itself.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\general-pages-lib.ps1')
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\goals-lib.ps1')

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
# A statement that throws is skipped under 'Continue', so count it instead (as logbook.tests.ps1 does).
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -eq "$Actual") ($Name + $(if ("$Expected" -ne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

Write-Host '-- the query' -ForegroundColor Cyan
$q = Get-GoalsGraphQuery
Assert-Equal 'goal' (Get-GoalLabel) 'a goal is an issue labelled goal'
Assert-True ($q -notmatch '"' -and $q -match '\$owner: String!' -and $q -match '\$name: String!' -and $q -match '\$label: String!' -and $q -match 'labels: \[\$label\]') 'the label is a variable like owner and name, so the query holds no quote a Windows command line could mangle'
Assert-True ($q -match 'states: OPEN' -and $q -match 'direction: ASC' -and ([regex]::Matches($q, 'subIssues\(first: \d+\)')).Count -eq 2) 'it reads the open goals oldest first, and two levels of sub-issues under each: milestones and their tasks'

Write-Host '-- the model' -ForegroundColor Cyan
$node = { param([int]$n, [string]$title, [string]$state = 'OPEN', [object[]]$subs = @(), [string[]]$who = @())
    [pscustomobject]@{ number = $n; title = $title; url = "https://github.com/o/r/issues/$n"; state = $state
        assignees = [pscustomobject]@{ nodes = @($who | ForEach-Object { [pscustomobject]@{ login = $_ } }) }
        subIssues = [pscustomobject]@{ nodes = @($subs) } } }
$graph = { param([object[]]$goals) [pscustomobject]@{ data = [pscustomobject]@{ repository = [pscustomobject]@{ issues = [pscustomobject]@{ nodes = @($goals) } } } } }

$recipes = & $node 100 'A replacement for HelloFresh' 'OPEN' @(
    (& $node 101 'Recipe base' 'CLOSED' @((& $node 111 'Data model' 'CLOSED'), (& $node 112 'Leftover task' 'OPEN'))),
    (& $node 102 'Weekly menu' 'OPEN' @((& $node 121 'Pick five' 'CLOSED'), (& $node 122 'Portions' 'OPEN' @() @('dave')), (& $node 123 'Swap a recipe' 'OPEN'))),
    (& $node 103 'Shopping list' 'OPEN' @()),
    (& $node 104 'In the kitchen' 'OPEN' @((& $node 141 'Step view' 'OPEN'), (& $node 142 'Timers' 'OPEN')))
)
$m = ConvertFrom-GoalsGraph -Data (& $graph @($recipes, (& $node 200 'Bare goal')))
Assert-Equal 2 @($m).Count 'every goal in the answer is in the model, the data member read through'
$g = $m[0]
Assert-Equal '101,102,103,104' ((@($g.Milestones) | ForEach-Object { $_.Number }) -join ',') 'the milestones keep GitHub''s own order'
Assert-Equal '3/3' ("$($g.Milestones[1].Total)/" + ($g.Milestones[1].Tasks.Count)) 'a milestone counts its tasks'
Assert-Equal '0/1' ("$($g.Milestones[2].Done)/$($g.Milestones[2].Total)") 'a milestone with no task counts as one item, not done while it is open'
Assert-Equal '3/8' ("$($g.Done)/$($g.Total)") 'the goal adds up its milestones: done of total'
Assert-Equal '2/2' ("$($g.Milestones[0].Done)/$($g.Milestones[0].Total)") 'a closed milestone is done whole, its leftover task included'
Assert-Equal 122 $g.Now.Item.Number 'Now is the first open task of the first open milestone, skipping a closed milestone''s leftovers'
Assert-Equal 'dave' (@($g.Now.Item.Assignees) -join ',') 'and it carries who holds it'
Assert-Equal '123,103,141' ((@($g.Next) | ForEach-Object { $_.Item.Number }) -join ',') 'Next is the three after it, an unplanned milestone among them as a step of its own'
Assert-True ($g.Next[1].Unplanned -and -not $g.Next[0].Unplanned) 'the unplanned milestone is marked so'
$bare = $m[1]
Assert-True ($null -eq $bare.Now -and @($bare.Next).Count -eq 0 -and @($bare.Milestones).Count -eq 0 -and $bare.Total -eq 0) 'a goal with no milestone has no Now, no Next and nothing to count -- and no list of one empty list'
$one = ConvertFrom-GoalsGraph -Data (& $graph @((& $node 300 'One' 'OPEN' @((& $node 301 'Only milestone' 'OPEN' @((& $node 311 'Only task')))))))
Assert-True (@($one).Count -eq 1 -and $one[0].Now.Item.Number -eq 311 -and @($one[0].Next).Count -eq 0) 'one goal with one milestone with one task reads as such, not unrolled to nothing'
$done = ConvertFrom-GoalsGraph -Data (& $graph @((& $node 400 'Done' 'OPEN' @((& $node 401 'M' 'CLOSED' @((& $node 411 'T' 'CLOSED')))))))
Assert-True ($null -eq $done[0].Now -and $done[0].Done -eq 1 -and $done[0].Total -eq 1) 'a goal whose milestones are all closed has no Now'
Assert-Equal 0 @(ConvertFrom-GoalsGraph -Data $null | Where-Object { $_ }).Count 'no answer is no goal, never an error'
Assert-Equal 2 @(ConvertFrom-GoalsGraph -Data (& $graph @($recipes)) -NextCount 2)[0].Next.Count '-NextCount bounds Next'
$evil = ConvertFrom-GoalsGraph -Data (& $graph @([pscustomobject]@{ number = 5; title = 't'; url = 'javascript:alert(1)'; state = 'OPEN'; assignees = $null; subIssues = $null }))
Assert-Equal '' $evil[0].Url 'a url that is not a GitHub link is dropped'
Assert-Equal 33 (Get-GoalPercent -Done 3 -Total 9) 'the percentage rounds down'
Assert-Equal 0 (Get-GoalPercent -Done 0 -Total 0) 'and an empty total is 0, not a division by zero'

Write-Host '-- what now?' -ForegroundColor Cyan
$t = Format-GoalFocusText -Goal $g
Assert-True ($t -match '(?m)^Goal #100 A replacement for HelloFresh -- 3 of 8 done$' -and $t -match '(?m)^  Now:  #122 Portions  \(milestone #102\)  \[claimed: dave\]$') 'it names the goal, its progress, and Now with its milestone and who holds it'
Assert-True ($t -match '(?m)^  Next: #123 Swap a recipe$' -and $t -match '(?m)^  Next: break down milestone #103 Shopping list$') 'and Next, an unplanned milestone as a breakdown to do'
Assert-True ((Format-GoalFocusText -Goal $bare) -match 'not broken down yet -- run plan-goal') 'a goal with no milestone says to plan it'
Assert-True ((Format-GoalFocusText -Goal $done[0]) -match 'every milestone is done') 'a finished goal says so'

Write-Host '-- the plan' -ForegroundColor Cyan
$ok = ConvertTo-GoalPlan -Json '{"goal":{"title":" A replacement for \"HelloFresh\" ","body":"why"},"labels":["prio-2"],"milestones":[{"title":"Recipe base","tasks":[{"title":"Data model"},{"title":"Favourites"}]},{"number":42,"tasks":[{"title":"Sum"}]}]}'
Assert-Equal '' $ok.Error 'a well-formed plan holds'
Assert-Equal 'A replacement for "HelloFresh"' $ok.Plan.Goal.Title 'titles are trimmed and keep their quotes'
Assert-Equal '2,1' ((@($ok.Plan.Milestones) | ForEach-Object { @($_.Tasks).Count }) -join ',') 'every milestone keeps its tasks, a single one too'
Assert-Equal 42 $ok.Plan.Milestones[1].Number 'a number names an existing milestone'
Assert-Equal 'prio-2' (@($ok.Plan.Labels) -join ',') 'the labels are read'
$single = ConvertTo-GoalPlan -Json '{"goal":{"number":7},"milestones":[{"title":"Only","tasks":[{"title":"One"}]}]}'
Assert-True (-not $single.Error -and $single.Plan.Goal.Number -eq 7 -and @($single.Plan.Milestones).Count -eq 1 -and @($single.Plan.Milestones[0].Tasks).Count -eq 1) 'one milestone with one task, under an existing goal, is not unrolled to nothing'
$tree = Format-GoalPlanText -Plan $ok.Plan
Assert-True ($tree -match '(?m)^Goal: A replacement for "HelloFresh"$' -and $tree -match '(?m)^  1\. Recipe base$' -and $tree -match '(?m)^       - Favourites$' -and $tree -match '(?m)^  2\. #42 \(existing milestone\)$' -and $tree -match '(?m)^       - Sum$' -and $tree -match 'Labels on every milestone and task: prio-2') 'the tree shows what would be filed, an existing milestone by its number'
$bad = @{
    'not json'                                                                                         = 'not valid JSON'
    '{"milestones":[{"title":"m"}]}'                                                                   = 'the goal has no title'
    '{"goal":{"title":"g"}}'                                                                           = '1 to 8 milestones'
    '{"goal":{"title":"g"},"milestones":[{"tasks":[]}]}'                                               = 'milestone 1 has no title'
    '{"goal":{"title":"g"},"milestones":[{"title":"m","tasks":[{"number":5}]}]}'                       = 'a task is always filed new'
    '{"goal":{"title":"g"},"labels":["a,b"],"milestones":[{"title":"m"}]}'                             = 'is not a label name'
    '{"goal":{"number":"x"},"milestones":[{"title":"m"}]}'                                             = 'not an issue number'
}
foreach ($k in $bad.Keys) { Assert-True ((ConvertTo-GoalPlan -Json $k).Error -match [regex]::Escape($bad[$k])) "a broken plan is refused: $($bad[$k])" }
$nine = '{"goal":{"title":"g"},"milestones":[' + ((1..9 | ForEach-Object { '{"title":"m' + $_ + '"}' }) -join ',') + ']}'
Assert-True ((ConvertTo-GoalPlan -Json $nine).Error -match '1 to 8 milestones') 'more than eight milestones is refused'
$thirteen = '{"goal":{"title":"g"},"milestones":[{"title":"m","tasks":[' + ((1..13 | ForEach-Object { '{"title":"t' + $_ + '"}' }) -join ',') + ']}]}'
Assert-True ((ConvertTo-GoalPlan -Json $thirteen).Error -match 'more than 12 tasks: split it') 'a milestone of more than twelve tasks is refused'
Assert-True ((ConvertTo-GoalPlan -Json ('{"goal":{"title":"' + ('x' * 201) + '"},"milestones":[{"title":"m"}]}')).Error -match 'over 200') 'a title over 200 characters is refused'

Write-Host '-- the page' -ForegroundColor Cyan
$page = Format-GoalsPageHtml -Model $m -RepoName 'o/r' -GeneratedAt '2026-11-05 10:00:00'
Assert-True ($page -match '<h1>Goals</h1>' -and $page -match 'class="shell shell--no-aside"' -and $page -match 'class="nav-item" href="/dev/goals" aria-current="page"') 'it stands in Admin''s desktop shell, the navigation on Goals'
Assert-True ($page -match '<section class="card goal" id="goal-100">\s*<div class="goal__head"><h2><a class="dp-link" href="https://github.com/o/r/issues/100"[^>]*>#100</a> A replacement for HelloFresh</h2>' -and $page -match '<h1>Goals</h1>' -and $page -notmatch 'class="toolbar"') 'each goal is a card whose head is an h2 linking its issue, under the page header''s h1'
Assert-True ($page -match '(?s)<div class="goal-now"><span class="goal-now__pill">Now</span><p class="goal-now__title"><a [^>]*>#122</a> Portions</p><p class="goal-now__sub">Milestone: Weekly menu[^<]*claimed by dave</p>') 'one prominent Now block names the step, its milestone and who holds it'
Assert-True ($page -match '<h3>Next</h3><ul class="goal-next">' -and $page -match '<li><span class="goal-next__title">Break down <a [^>]*>#103</a> Shopping list</span></li>' -and $page -match '<span class="goal-next__meta">Milestone: Weekly menu</span>') 'a Next list follows, an unplanned milestone as a breakdown'
Assert-Equal 4 ([regex]::Matches(($page -split 'id="goal-200"')[0], '<details class="goal-milestone">')).Count 'the milestones are collapsed, one disclosure each'
$want = @(@($m)[0].Milestones | Where-Object { [int]$_.Total -gt 0 -and [int]$_.Done -ge [int]$_.Total }).Count
Assert-True ($page -match 'class="goal-progress"><span class="goal-progress__bar"><span class="meter meter--info" role="img" aria-label="\d+% done"><span style="width: \d+%"></span></span><span class="num">' + $want + ' of 4 milestones</span>') 'the goal carries a progress bar over its milestones, as the wireframes count it'
Assert-True ($page -notmatch '<span class="num">3 of 8 milestones</span>') 'the goal''s count names what it counts: milestones done of milestones, not its items (3 of 8 is items)'
Assert-True ($page -match 'aria-label="100% done"' -and $page -match 'class="meter meter--good"') 'a finished milestone''s bar is good'
Assert-True ($page -match '(?s)id="goal-200".*?<p class="goal-now__title">Break this goal down</p>') 'a goal with no milestone says to break it down'
Assert-True ($page -match 'href="/refresh\?page=goals"' -and $page -match 'read 2026-11-05 10:00:00') 'the footer says when it was read and offers a re-read'
$empty = Format-GoalsPageHtml -Model @() -RepoName 'o/r'
Assert-True ($empty -match '<section class="empty-state" role="status">' -and $empty -match '<h2>No goal yet</h2>' -and $empty -match 'plan-goal' -and $empty -match 'data-copy-prompt="plan a goal"[^>]*>Copy prompt: plan a goal</button>' -and $empty -notmatch 'class="card goal"') 'no goal is an empty state with a copy-prompt button that says how to make one'
$err = Format-GoalsPageHtml -Model $null -ReadError 'gh api graphql exited 1'
Assert-True ($err -match 'msg--warn" role="alert">The goals could not be read from GitHub: gh api graphql exited 1\.' -and $err -notmatch 'No goal yet') 'a failed read is a warning, and not mistaken for an empty tracker'
$xss = Format-GoalsPageHtml -Model (ConvertFrom-GoalsGraph -Data (& $graph @((& $node 9 '<script>alert(1)</script>'))))
Assert-True ($xss -notmatch '<script>alert' -and $xss -match '&lt;script&gt;') 'a title is escaped'

Write-Host '-- Admin' -ForegroundColor Cyan
$gp = @(Get-GeneralPages | Where-Object { $_.Href -eq '/dev/goals' })
Assert-True ($gp.Count -eq 1 -and $gp[0].Label -eq 'Goals' -and -not $gp[0].Group -and -not $gp[0].GitHub -and (Get-AdminIconSvg -Name $gp[0].Icon) -match '<svg') 'Goals is a general page of its own, with an icon'
Assert-Equal 'Goals' (@(Get-AdminMenu)[2].Label) 'it is the second of Admin''s own items, right after Today (#3860)'

Write-Host '-- plan-goal -Apply in a repo with no goal label (#3959)' -ForegroundColor Cyan
# THE MEASURED FAILURE: under the script's 'Stop', Windows PowerShell 5.1 turned the label probe's 404 into a
# terminating error despite 2>$null, so '-Apply' printed '[FAILED] gh: Not Found (HTTP 404)' and filed
# nothing. Run under powershell.exe (5.1) on purpose: that is the host the defect lives in.
$pgDir = Join-Path ([System.IO.Path]::GetTempPath()) ('dkj-plan-goal-test-' + [guid]::NewGuid().ToString('N'))
$pgBin = Join-Path $pgDir 'bin'
[void](New-Item -ItemType Directory -Path $pgBin -Force)
$pgUtf8 = New-Object System.Text.UTF8Encoding($false)
$pgLog = Join-Path $pgDir 'gh-calls.log'
$pgImpl = @'
Add-Content -LiteralPath $env:PG_GH_LOG -Value ($args -join ' ')
if ($args -contains '--silent') { [Console]::Error.WriteLine('gh: Not Found (HTTP 404)'); exit 1 }
if ($args -contains 'POST' -and ($args | Where-Object { $_ -match '/labels$' })) { Write-Output '{"name":"goal"}'; exit 0 }
if ($args -contains 'POST' -and ($args | Where-Object { $_ -match '/sub_issues$' })) { Write-Output '{}'; exit 0 }
if ($args -contains 'POST' -and ($args | Where-Object { $_ -match '/issues$' })) { Write-Output '{"number":101,"id":9001}'; exit 0 }
exit 1
'@
[System.IO.File]::WriteAllText((Join-Path $pgBin 'gh-impl.ps1'), $pgImpl, $pgUtf8)
[System.IO.File]::WriteAllText((Join-Path $pgBin 'gh.cmd'), "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0gh-impl.ps1`" %*`r`nexit /b %ERRORLEVEL%`r`n", $pgUtf8)
$pgPlan = Join-Path $pgDir 'plan.json'
[System.IO.File]::WriteAllText($pgPlan, '{"goal":{"title":"A goal","body":"why"},"milestones":[{"title":"A milestone","tasks":[{"title":"A task"}]}]}', $pgUtf8)
$pgSavedPath = $env:PATH
try {
    $env:PATH = "$pgBin;$env:PATH"
    $env:PG_GH_LOG = $pgLog
    $pgOut = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\pages\plan-goal.ps1') -PlanFile $pgPlan -Apply -Repo 'o/n' 2>&1 | Out-String)
    $pgExit = $LASTEXITCODE
} finally {
    $env:PATH = $pgSavedPath
    Remove-Item Env:\PG_GH_LOG -ErrorAction SilentlyContinue
}
$pgCalls = if (Test-Path -LiteralPath $pgLog) { Get-Content -LiteralPath $pgLog } else { @() }
Assert-Equal 0 $pgExit 'a 404 on the label probe does not end the run'
Assert-True ($pgOut -notmatch '\[FAILED\]') 'and nothing is reported as failed'
Assert-True ($pgOut -match "created the label") 'the missing label is created'
Assert-True (@($pgCalls | Where-Object { $_ -match 'POST' -and $_ -match 'repos/o/n/labels( |$)' }).Count -eq 1) 'exactly one label create reaches gh'
Assert-True ($pgOut -match '\[OK\] filed 3 issue') 'and the goal, milestone and task are filed after it'
Remove-Item -LiteralPath $pgDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ''
Write-Host "goals: $script:pass passed, $script:fail failed"
if ($script:fail) { exit 1 }
exit 0
