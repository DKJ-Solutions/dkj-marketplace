<#
.SYNOPSIS
    Tests for plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-bwj/hooks/guard-asana-origin.ps1 and its
    lib, scripts/lib/asana-origin-rules.ps1 -- the PreToolUse hook that refuses a gh issue create on a store
    repo whose body names a requester or quotes a task but links no Asana task (inbound #4477).

.DESCRIPTION
    THREE GROUPS.
      1. THE LIB, in-process: the signal, the settled test, and the verdict.
      2. THE HOOK, as a process, on every path that makes no network call: every create names its repo
         with --repo.
      3. THE REGISTRATION: hooks.json runs the file on the shell tools behind a gh issue create
         pre-filter.

    THE TEST GAP, NAMED. A create with no --repo is judged on the checkout's repo, which needs gh to
    answer, so that path is not run here -- this suite runs in CI without tracker credentials.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'
$RepoRoot   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$PluginRoot = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
$Hook       = Join-Path $PluginRoot 'hooks\guard-asana-origin.ps1'
$HooksJson  = Join-Path $PluginRoot 'hooks\hooks.json'

. (Join-Path $PluginRoot 'scripts\lib\asana-origin-rules.ps1')

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
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
function Get-Verdict { param([string]$Body) (Get-AsanaOriginVerdict -Body $Body).Verdict }

# The measured body (smartwatchbanden#1567), with the names replaced.
$measured = 'Requested by Alex (task "remember own smartwatch: cases link per model"), passed on by Sam.'
$marker   = "`n`nAsana: https://app.asana.com/1/1/project/2/task/1220890291690892`n<!-- asana-task: 1220890291690892 -->"

Write-Host '== 1. the lib =='
Assert-Equal 'names a requester,quotes a task' (@(Get-AsanaOriginSignal -Body $measured) -join ',') 'the measured body names a requester and quotes a task'
Assert-Equal 'refuse' (Get-Verdict $measured) 'and is refused without a link (#4477)'
Assert-Equal 'pass'   (Get-Verdict ($measured + $marker)) 'with the marker it passes'
Assert-Equal 'pass'   (Get-Verdict ($measured + "`nhttps://app.asana.com/0/123/456")) 'a sole task URL is a link too'
Assert-Equal 'pass'   (Get-Verdict ($measured + "`nhttps://app.asana.com/0/1/2 and https://app.asana.com/0/1/3")) 'several task URLs are not this guard''s question'
Assert-Equal 'pass'   (Get-Verdict ($measured + "`n<!-- no-asana-task -->")) 'the opt-out passes'
Assert-Equal 'refuse' (Get-Verdict ($measured + "`n<!-- asana-task: none -->")) 'a marker with no number is not the opt-out'
Assert-Equal 'pass'   (Get-Verdict 'The Belgium pop-up shows twice on mobile.') 'a body naming no colleague passes'
Assert-Equal 'pass'   (Get-Verdict '') 'an empty body passes'
Assert-Equal 'pass'   (Get-Verdict 'The task runner times out after 30 seconds.') 'the word task alone is not a quoted task'

foreach ($b in @('Reported by Jordy via Asana.', 'Asked by the CRO team.', 'Filed on behalf of the SEO team.',
                 'Aangevraagd door Jordy.', 'Op verzoek van Alejandro.', 'Doorgegeven door Sam.', 'Namens de klantenservice.')) {
    Assert-Equal 'names a requester' (@(Get-AsanaOriginSignal -Body $b) -join ',') "requester: '$b'"
}
$curly = 'See task ' + [char]0x201C + 'cases link' + [char]0x201D + ' on the board.'
foreach ($b in @('See taak "cases-link per model".', $curly, 'This is the Asana task for the header.', 'Uit het Asana-ticket van gisteren.', "Task: 'header fix'")) {
    Assert-Equal 'quotes a task' (@(Get-AsanaOriginSignal -Body $b) -join ',') "task: '$b'"
}

Assert-True ($script:AsanaOriginRepos -contains 'smartwatchbanden') 'the stores are judged'
Assert-True ($script:AsanaOriginRepos -notcontains 'dkj-marketplace') 'the source repo is not: an inbound issue quotes a store requester as evidence'
Assert-True ($script:AsanaOriginRepos -notcontains 'dkj-claude-plugins') 'nor its old name'

Write-Host '== 2. the hook =='
function Invoke-Hook {
    param([string]$Command)
    $payload = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
    $out = $payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook 2>&1 | ForEach-Object { "$_" }
    return [pscustomobject]@{ Text = ($out -join "`n"); Code = $LASTEXITCODE }
}
$store = '--repo BWJ-Development/smartwatchbanden'

$r = Invoke-Hook "gh issue create $store --label feature --title 'Cases link' --body '$measured'"
Assert-Equal 2 $r.Code 'the measured case (#4477): a create naming a requester and a task, with no link, is refused'
Assert-True ($r.Text -match 'BLOCKED \(guard-asana-origin\)') 'with the guard named'
Assert-True ($r.Text -match 'smartwatchbanden names a requester and quotes a task') 'naming the repo and what it found'
Assert-True ($r.Text -match 'no-asana-task') 'and the opt-out'
Assert-True ($r.Text -notmatch 'Alex|Sam|cases link per model') 'and prints no body text'

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("guard-asana-origin-" + [guid]::NewGuid().ToString('N') + '.md')
try {
    [System.IO.File]::WriteAllText($tmp, $measured)
    $r = Invoke-Hook "gh issue create $store --label feature --title x --body-file '$tmp'"
    Assert-Equal 2 $r.Code 'a body file is read and judged'
    [System.IO.File]::WriteAllText($tmp, $measured + $marker)
    $r = Invoke-Hook "gh issue create $store --label feature --title x --body-file '$tmp'"
    Assert-Equal 0 $r.Code 'and passes once it links the task'
    Assert-True ($r.Text.Trim() -eq '') 'silently'
} finally { Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue }

$r = Invoke-Hook "gh issue create $store --label bug --title x --body 'It shows twice.'"
Assert-Equal 0 $r.Code 'an ordinary finding passes'
Assert-True ($r.Text.Trim() -eq '') 'silently'

$r = Invoke-Hook "gh issue create $store --label bug --title x --body-file -"
Assert-Equal 0 $r.Code 'a body on stdin passes'
Assert-True ($r.Text -match 'did NOT judge it') 'with a warning'

$r = Invoke-Hook ('gh issue create ' + $store + ' --label bug --title x --body "Requested by $who"')
Assert-Equal 0 $r.Code 'a run-time body naming a requester passes'
Assert-True ($r.Text -match 'body built at run time') 'with a warning saying why'

$r = Invoke-Hook "gh issue create --repo DKJ-Solutions/dkj-marketplace --label feature-inbound --title x --body '$measured'"
Assert-Equal 0 $r.Code 'an inbound issue on the source repo passes'
$r = Invoke-Hook "gh issue create --repo DaveKJohn/some-other-repo --title x --body '$measured'"
Assert-Equal 0 $r.Code 'a repo report-issue does not admit is none of this guard''s business'
$r = Invoke-Hook "gh issue edit 12 $store --body '$measured'"
Assert-Equal 0 $r.Code 'an edit is not judged'
$r = Invoke-Hook 'R=BWJ-Development/smartwatchbanden; gh issue create -R $R --label bug --title x --body "Requested by Alex"'
Assert-Equal 0 $r.Code 'a repo given as a variable passes (#4293)'
Assert-True ($r.Text -match 'repo given as a variable') 'with the warning that it was not judged'

Write-Host '== 3. the registration =='
$hooks = Get-Content -Raw -LiteralPath $HooksJson | ConvertFrom-Json
$entry = @($hooks.hooks.PreToolUse | Where-Object { @($_.hooks | Where-Object { $_.command -match 'guard-asana-origin\.ps1' }).Count -gt 0 })
Assert-Equal 1 $entry.Count 'hooks.json registers the hook once'
Assert-Equal 'Bash|PowerShell' $entry[0].matcher 'on the shell tools'
Assert-True ($entry[0].hooks[0].command -match 'issue\[\[:space:\]\]\+create') 'behind a gh issue create pre-filter'

Write-Host ''
Write-Host "guard-asana-origin: $script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
exit 0
