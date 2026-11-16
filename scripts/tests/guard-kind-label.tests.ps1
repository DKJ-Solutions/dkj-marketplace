<#
.SYNOPSIS
    Tests for plugins/dkj-policy/extensions/bwj-development/hooks/guard-kind-label.ps1 and its lib,
    scripts/lib/kind-label-rules.ps1 -- the PreToolUse hook that refuses a gh issue create on a store
    repo carrying none, or several, of bug / feature / research (inbound #4197).

.DESCRIPTION
    THREE GROUPS.
      1. THE LIB, in-process: the labels Get-GhIssueLabelCall reads, and Get-KindLabelVerdict's answer.
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
$PluginRoot = Join-Path $RepoRoot 'plugins\dkj-policy\extensions\bwj-development'
$Hook       = Join-Path $PluginRoot 'hooks\guard-kind-label.ps1'
$HooksJson  = Join-Path $PluginRoot 'hooks\hooks.json'

. (Join-Path $PluginRoot 'scripts\lib\kind-label-rules.ps1')

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
function Get-Verdict { param([string]$Command) (Get-KindLabelVerdict -Call @(Get-GhIssueLabelCall -Command $Command)[0]).Verdict }

Write-Host '== 1. the lib =='
$c = @(Get-GhIssueLabelCall -Command "gh issue create --repo BWJ-Development/smartwatchbanden --label bug,minor -l research --body x")
Assert-Equal 'bug,minor,research' (@($c[0].Labels) -join ',') 'every --label/-l value is read, comma lists split'
Assert-Equal 1 @(Get-GhIssueLabelCall -Command "gh issue create --title x").Count 'a create with no label is still a call'
Assert-Equal 0 @(Get-GhIssueLabelCall -Command "git commit -m 'gh issue create'").Count 'a mention inside a commit message is not a call'

Assert-Equal 'pass'      (Get-Verdict "gh issue create --label bug --body x") 'one kind passes'
Assert-Equal 'pass'      (Get-Verdict "gh issue create --label Feature,minor --body x") 'in any case, beside the reach label'
Assert-Equal 'pass'      (Get-Verdict "gh issue create --label bug --label bug --body x") 'the same kind twice is still one kind'
Assert-Equal 'refuse'    (Get-Verdict "gh issue create --label minor --body x") 'no kind is refused'
Assert-Equal 'refuse'    (Get-Verdict "gh issue create --title x --body x") 'nor is no label at all'
Assert-Equal 'refuse'    (Get-Verdict "gh issue create --label bug,feature --body x") 'two kinds are refused'
Assert-Equal 'unchecked' (Get-Verdict 'gh issue create --label $kind --body x') 'a label built at run time is not judged'
Assert-Equal 'unchecked' (Get-Verdict "gh issue create --template bug_report") 'nor one a template sets'
Assert-Equal 'unchecked' (Get-Verdict "gh issue create --web") 'nor one set in the browser'
Assert-Equal 'refuse'    (Get-Verdict "gh issue create --template x --label bug,research") 'but two kinds on the command line are refused even then'
Assert-Equal 'pass'      (Get-Verdict "gh issue edit 12 --add-label minor") 'an edit is not judged'

Assert-True ($script:KindLabelRepos -contains 'smartwatchbanden') 'the stores are judged'
Assert-True ($script:KindLabelRepos -notcontains 'dkj-marketplace') 'the source repo is not: inbound issues there carry feature-inbound or bug-inbound'
Assert-True ($script:KindLabelRepos -notcontains 'dkj-claude-plugins') 'nor its old name'

Write-Host '== 2. the hook =='
function Invoke-Hook {
    param([string]$Command)
    $payload = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress
    $out = $payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook 2>&1 | ForEach-Object { "$_" }
    return [pscustomobject]@{ Text = ($out -join "`n"); Code = $LASTEXITCODE }
}
$store = '--repo BWJ-Development/smartwatchbanden'

$r = Invoke-Hook "gh issue create $store --title 'Belgium pop-up' --body 'It shows twice.'"
Assert-Equal 2 $r.Code 'the measured case (#4197): a create with no kind label is refused'
Assert-True ($r.Text -match 'BLOCKED \(guard-kind-label\)') 'with the guard named'
Assert-True ($r.Text -match 'BWJ-Development/smartwatchbanden carries none of them') 'naming the repo and what is missing'
Assert-True ($r.Text -match '--label research') 'and listing the three'
Assert-True ($r.Text -notmatch 'Belgium|shows twice') 'and prints no title or body'

$r = Invoke-Hook "gh issue create $store --label feature,bug --body x"
Assert-Equal 2 $r.Code 'two kinds are refused'
Assert-True ($r.Text -match 'carries feature and bug') 'naming both'

$r = Invoke-Hook "gh issue create $store --label bug --label minor --body x"
Assert-Equal 0 $r.Code 'one kind passes'
Assert-True ($r.Text.Trim() -eq '') 'silently'

$r = Invoke-Hook "gh issue create $store --web"
Assert-Equal 0 $r.Code 'labels set in the browser pass'
Assert-True ($r.Text -match 'did NOT judge it') 'with a warning'

$r = Invoke-Hook "gh issue create --repo DKJ-Solutions/dkj-marketplace --label feature-inbound --body x"
Assert-Equal 0 $r.Code 'an inbound issue on the source repo passes'
$r = Invoke-Hook "gh issue create --repo DaveKJohn/some-other-repo --body x"
Assert-Equal 0 $r.Code 'a repo report-issue does not admit is none of this guard''s business'
$r = Invoke-Hook "gh issue edit 1283 $store --add-label minor"
Assert-Equal 0 $r.Code 'an edit passes'
$r = Invoke-Hook "echo 'gh issue create' > notes.txt"
Assert-Equal 0 $r.Code 'a mention passes'

Write-Host '== 3. the registration =='
$hooks = Get-Content -Raw -LiteralPath $HooksJson | ConvertFrom-Json
$entry = @($hooks.hooks.PreToolUse | Where-Object { @($_.hooks | Where-Object { $_.command -match 'guard-kind-label\.ps1' }).Count -gt 0 })
Assert-Equal 1 $entry.Count 'hooks.json registers the hook once'
Assert-Equal 'Bash|PowerShell' $entry[0].matcher 'on the shell tools'
Assert-True ($entry[0].hooks[0].command -match 'issue\[\[:space:\]\]\+create') 'behind a gh issue create pre-filter'

Write-Host ''
Write-Host "guard-kind-label: $script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
exit 0
