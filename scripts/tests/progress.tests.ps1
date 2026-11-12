<#
.SYNOPSIS
    Tests for plugins/dkj-policy/apps/admin/lib/progress-lib.ps1 -- the Progress page (#4004): a milestone's kind
    from its labels, the team's numbers from the Logbook's runs, and the page itself.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$lib = Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib'
. (Join-Path $lib 'general-pages-lib.ps1')
. (Join-Path $lib 'stopwatch-lib.ps1')
. (Join-Path $lib 'goals-lib.ps1')
. (Join-Path $lib 'progress-lib.ps1')

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -eq "$Actual") ($Name + $(if ("$Expected" -ne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

Write-Host '-- a milestone''s kind' -ForegroundColor Cyan
Assert-Equal 'built' (Get-ProgressMilestoneKind -Labels @()) 'a milestone with no label is built'
Assert-Equal 'built' (Get-ProgressMilestoneKind -Labels @('prio-2', 'feature')) 'and so is one with only other labels'
Assert-Equal 'used' (Get-ProgressMilestoneKind -Labels @('Used ')) 'used is read case-blind and trimmed'
Assert-Equal 'measured' (Get-ProgressMilestoneKind -Labels @('used', 'measured')) 'measured wins over used where both are set'

Write-Host '-- the goals query carries a milestone''s labels' -ForegroundColor Cyan
$q = Get-GoalsGraphQuery
Assert-Equal 1 ([regex]::Matches($q, 'labels\(first: 10\)')).Count 'labels are read on one level only'
Assert-True ($q -match 'labels\(first: 10\) \{ nodes \{ name \} \} subIssues\(first: 50\)') 'and that level is the milestone, right before its tasks'
$node = { param([int]$n, [string]$state = 'OPEN', [string[]]$labels = $null, [object[]]$subs = @())
    $o = [pscustomobject]@{ number = $n; title = "Item $n"; url = "https://github.com/o/r/issues/$n"; state = $state
        assignees = [pscustomobject]@{ nodes = @() }; subIssues = [pscustomobject]@{ nodes = @($subs) } }
    if ($null -ne $labels) { $o | Add-Member labels ([pscustomobject]@{ nodes = @($labels | ForEach-Object { [pscustomobject]@{ name = $_ } }) }) }
    $o }
$data = [pscustomobject]@{ data = [pscustomobject]@{ repository = [pscustomobject]@{ issues = [pscustomobject]@{ nodes = @(
    (& $node 10 'OPEN' $null @((& $node 11 'CLOSED' @('used')), (& $node 12 'CLOSED' @()), (& $node 13 'OPEN' @('measured') @((& $node 131 'OPEN'))), (& $node 14 'OPEN' @())))) } } } }
$goals = ConvertFrom-GoalsGraph -Data $data
Assert-Equal 'used' (@($goals[0].Milestones[0].Labels) -join ',') 'a milestone keeps its labels in the model'
Assert-Equal 0 @($goals[0].Labels).Count 'a node read without labels has none, never an error'

Write-Host '-- the team''s numbers' -ForegroundColor Cyan
$t0 = [datetime]'2026-11-01T10:00:00Z'
$runs = @(
    @{ Id = 'a'; Label = 'first'; Start = $t0; End = $t0.AddMinutes(30) },
    @{ Id = 'b'; Label = 'second'; Start = $t0.AddHours(1); End = $t0.AddHours(1).AddMinutes(60) },
    @{ Id = 'c'; Label = 'not covered'; Start = $t0.AddHours(3); End = $t0.AddHours(3).AddMinutes(10) },
    @{ Id = 'd'; Label = 'going'; Start = $t0.AddHours(4) }
)
$work = @{ a = @{ Work = 1200; Waiting = 600 }; b = @{ Work = 2400; Waiting = 1200 } }
$s = ConvertTo-ProgressTeamStats -Runs $runs -WorkTimes $work
Assert-Equal 3 $s.Count 'every finished run is an assignment, a going one not'
Assert-Equal 2 $s.Measured 'only the runs the transcripts covered are measured'
Assert-Equal '3600/1800' ("$($s.Work)/$($s.Waiting)") 'work and waiting add up over the measured runs'
Assert-Equal 33 $s.Share 'the share is waiting of the whole, rounded'
Assert-Equal 'first,second' ((@($s.Rows) | ForEach-Object { $_.Label }) -join ',') 'the chart rows are the measured runs, oldest first'
$many = @(1..25 | ForEach-Object { @{ Id = "r$_"; Label = "run $_"; Start = $t0.AddHours($_); End = $t0.AddHours($_).AddMinutes(5) } })
$manyWork = @{}; 1..25 | ForEach-Object { $manyWork["r$_"] = @{ Work = 200; Waiting = 100 } }
$sm = ConvertTo-ProgressTeamStats -Runs $many -WorkTimes $manyWork
Assert-Equal "20/run 6/run 25" ("$(@($sm.Rows).Count)/$($sm.Rows[0].Label)/$($sm.Rows[-1].Label)") 'the chart keeps the newest twenty'
$none = ConvertTo-ProgressTeamStats -Runs @() -WorkTimes @{}
Assert-Equal '0/0' ("$($none.Count)/$($none.Share)") 'no run is zero, never a division by zero'

Write-Host '-- the page' -ForegroundColor Cyan
$html = Format-ProgressPageHtml -Goals $goals -Runs $runs -WorkTimes $work -RepoName 'demo'
Assert-True ($html -match '<h1[^>]*>Progress</h1>') 'the page is called Progress'
Assert-True ($html -match '<h2>How far the app is</h2>' -and $html -match '<h2>How the team ran</h2>') 'it has the two sections the issue asks for, and no more'
Assert-True ($html -match '2 of 4 milestones') 'a goal says how many of its milestones are closed'
Assert-Equal 4 ([regex]::Matches($html, 'role="listitem"')).Count 'one segment per milestone'
Assert-True ($html -match 'class="is-done" style="--c: var\(--graph-2\)"') 'a closed used milestone is filled in the used colour'
Assert-True ($html -match 'class="is-done" style="--c: var\(--graph-1\)"') 'a closed milestone without a kind label is filled as built'
Assert-True ($html -match '#13 Item 13: open, the next step is here"[^>]*class="is-now"') 'the open milestone holding Now is outlined, and says so to a screen reader'
Assert-True ($html -match 'Questions asked</div><div class="v num">not recorded yet') 'a signal nobody records says so instead of showing a number'
Assert-True ($html -match '33%') 'the share waiting is shown'
Assert-Equal 2 ([regex]::Matches($html, '<g class="bar"')).Count 'one chart column per measured run'
Assert-True ($html -notmatch [char]0x2014) 'no em dash anywhere on the page (the brand book)'
$empty = Format-ProgressPageHtml -Goals @() -Runs @() -WorkTimes @{}
Assert-True ($empty -match 'No goal yet' -and $empty -match 'No finished assignment') 'with nothing to show, both cards say so'
Assert-True ($empty -match 'Claude worked</div><div class="v num">&ndash;') 'and a time nothing measured is a dash, not 0s'
$err = Format-ProgressPageHtml -Goals $null -GoalsError 'gh exited 1' -LogbookError 'the store is not JSON'
Assert-True ($err -match 'could not be read from GitHub: gh exited 1' -and $err -match 'The Logbook could not be read: the store is not JSON') 'a read error is shown on its card, never a blank page'
$evil = ConvertFrom-GoalsGraph -Data ([pscustomobject]@{ data = [pscustomobject]@{ repository = [pscustomobject]@{ issues = [pscustomobject]@{ nodes = @(
    [pscustomobject]@{ number = 1; title = '<script>x</script>'; url = 'javascript:alert(1)'; state = 'OPEN'; assignees = [pscustomobject]@{ nodes = @() }
        subIssues = [pscustomobject]@{ nodes = @([pscustomobject]@{ number = 2; title = '"><img src=x>'; url = 'https://github.com/o/r/issues/2'; state = 'OPEN'; assignees = [pscustomobject]@{ nodes = @() }; subIssues = [pscustomobject]@{ nodes = @() } }) } }) } } } })
$eh = Format-ProgressPageHtml -Goals $evil -Runs @(@{ Id = 'x'; Label = '<b>run</b>'; Start = $t0; End = $t0.AddMinutes(1) }) -WorkTimes @{ x = @{ Work = 30; Waiting = 30 } }
Assert-True ($eh -notmatch '<script>x' -and $eh -notmatch '"><img' -and $eh -notmatch '<b>run' -and $eh -notmatch 'javascript:') 'titles, labels and urls are escaped, and a non-GitHub url is dropped'

Write-Host ''
Write-Host "progress: $script:pass passed, $script:fail failed"
if ($script:fail) { exit 1 }
exit 0
