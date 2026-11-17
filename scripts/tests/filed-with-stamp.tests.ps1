<#
.SYNOPSIS
    Tests for plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-bwj/hooks/filed-with-stamp.ps1 and its lib,
    scripts/lib/filed-with-rules.ps1 -- the PostToolUse hook that stamps a new store issue with the
    plugin versions the filing session ran (inbound #4220).

.DESCRIPTION
    THREE GROUPS.
      1. THE LIB, in-process: the created-issue URL read, the version read, the stamp and its append.
      2. THE HOOK, as a process, on every path that makes no network call.
      3. THE REGISTRATION: hooks.json runs the file on the shell tools behind a gh issue create
         pre-filter, as a PostToolUse hook.

    THE TEST GAP, NAMED. The read and edit of a real issue need gh with tracker credentials, which this
    suite does not have in CI, so the stamping path itself is not run here.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'
$RepoRoot   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$PluginRoot = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
$Hook       = Join-Path $PluginRoot 'hooks\filed-with-stamp.ps1'
$HooksJson  = Join-Path $PluginRoot 'hooks\hooks.json'

. (Join-Path $PluginRoot 'scripts\lib\filed-with-rules.ps1')

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

Write-Host '== 1. the lib =='
$out = "Creating issue in BWJ-Development/smartwatchbanden`n`nhttps://github.com/BWJ-Development/smartwatchbanden/issues/1390`n"
$r = @(Get-CreatedIssueRef -Text $out)
Assert-Equal 1 $r.Count 'the URL gh prints on its own line is read'
Assert-Equal 'BWJ-Development/smartwatchbanden' $r[0].Repo 'with its repo'
Assert-Equal 1390 $r[0].Number 'and its number'
Assert-Equal 2 @(Get-CreatedIssueRef -Text "https://github.com/a/b/issues/1`r`nhttps://github.com/a/b/issues/2`nhttps://github.com/a/b/issues/1").Count 'two creates are two, a repeat is one'
Assert-Equal 0 @(Get-CreatedIssueRef -Text 'see https://github.com/a/b/issues/7 for context').Count 'a URL inside a sentence is not a creation'
Assert-Equal 0 @(Get-CreatedIssueRef -Text 'https://github.com/a/b/pull/7').Count 'nor is a pull request'

$resp = [pscustomobject]@{ stdout = "x`nhttps://github.com/a/b/issues/3"; stderr = ''; nested = @{ more = @('https://github.com/a/b/issues/4') } }
Assert-Equal '3,4' ((@(Get-CreatedIssueRef -Text @(Get-FiledWithResponseText -Value $resp)) | ForEach-Object { $_.Number }) -join ',') 'every string of the tool response is read, whatever its shape'
Assert-Equal 1 @(Get-CreatedIssueRef -Text @(Get-FiledWithResponseText -Value 'https://github.com/a/b/issues/5')).Count 'a bare string response too'

$admin = '{"version":2,"plugins":{
  "dkj-repo-workflow@dkj-marketplace":[{"scope":"project","projectPath":"C:\\repo\\store","version":"6.18.0"},{"scope":"project","projectPath":"C:\\repo\\other","version":"6.10.0"}],
  "dkj-repo-workflow-bwj@dkj-marketplace":[{"scope":"user","version":"6.17.0"}],
  "dkj-subagents-alpha@dkj-marketplace":[{"scope":"project","projectPath":"C:\\repo\\store","version":"6.18.0"},{"scope":"project","projectPath":"C:\\repo\\store\\","version":"6.16.0"}]
}}' | ConvertFrom-Json
Assert-Equal '6.18.0' (Get-FiledWithVersion -Admin $admin -Name 'dkj-repo-workflow' -ProjectDir 'c:\repo\store\') 'this checkout''s record, matched case-insensitively and without the trailing separator'
Assert-Equal '6.17.0' (Get-FiledWithVersion -Admin $admin -Name 'dkj-repo-workflow-bwj' -ProjectDir 'C:\repo\store') 'a pathless record where none names this checkout'
Assert-Equal '' (Get-FiledWithVersion -Admin $admin -Name 'dkj-subagents-alpha' -ProjectDir 'C:\repo\store') 'two disagreeing records are no one version'
Assert-Equal '' (Get-FiledWithVersion -Admin $admin -Name 'dkj-repo-workflow' -ProjectDir 'C:\repo\gone') 'no record for this checkout is no version'
Assert-Equal '' (Get-FiledWithVersion -Admin $null -Name 'dkj-repo-workflow' -ProjectDir 'C:\repo\store') 'nor is an unreadable file'

$v = [ordered]@{ 'dkj-repo-workflow' = '6.18.0'; 'dkj-repo-workflow-bwj' = '' }
$stamp = Get-FiledWithStamp -Versions $v
Assert-Equal '<!-- filed-with: dkj-repo-workflow 6.18.0, dkj-repo-workflow-bwj unknown -->' $stamp 'the stamp names each plugin, an unread version as unknown'
Assert-Equal '<!-- filed-with: dkj-repo-workflow unknown -->' (Get-FiledWithStamp -Versions ([ordered]@{ 'dkj-repo-workflow' = '6.18 -->evil' })) 'a version that is not a version is not written into the body'
Assert-Equal "## Body`n`n$stamp" (Add-FiledWithStamp -Body "## Body`n`n" -Stamp $stamp) 'appended after one blank line'
Assert-Equal $stamp (Add-FiledWithStamp -Body '' -Stamp $stamp) 'an empty body becomes the stamp'
Assert-True ($null -eq (Add-FiledWithStamp -Body "x`n`n<!-- filed-with: dkj-repo-workflow 6.17.0 -->" -Stamp $stamp)) 'a stamped body is never stamped twice'

Assert-True ($script:KindLabelRepos -contains 'smartwatchbanden') 'the stores are stamped'
Assert-True ($script:KindLabelRepos -notcontains 'dkj-marketplace') 'the source repo is not'

Write-Host '== 2. the hook =='
function Invoke-Hook {
    param([string]$Command, $Response)
    $payload = @{ tool_name = 'Bash'; tool_input = @{ command = $Command }; tool_response = $Response } | ConvertTo-Json -Compress -Depth 5
    $o = $payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook 2>&1 | ForEach-Object { "$_" }
    return [pscustomobject]@{ Text = ($o -join "`n"); Code = $LASTEXITCODE }
}
$r = Invoke-Hook 'git status' @{ stdout = 'https://github.com/BWJ-Development/smartwatchbanden/issues/1' }
Assert-Equal 0 $r.Code 'another command passes'
Assert-True ($r.Text.Trim() -eq '') 'silently'
$r = Invoke-Hook 'gh issue create --repo DKJ-Solutions/dkj-marketplace --label feature-inbound --body x' @{ stdout = 'https://github.com/DKJ-Solutions/dkj-marketplace/issues/9' }
Assert-Equal 0 $r.Code 'an inbound issue on the source repo is not stamped'
Assert-True ($r.Text.Trim() -eq '') 'and nothing is said'
$r = Invoke-Hook 'gh issue create --repo BWJ-Development/smartwatchbanden --label bug --body x' @{ stdout = ''; stderr = 'HTTP 422' }
Assert-Equal 0 $r.Code 'a create that printed no URL passes'
Assert-True ($r.Text.Trim() -eq '') 'silently'
$r = Invoke-Hook "echo 'gh issue create' > notes.txt" @{ stdout = '' }
Assert-Equal 0 $r.Code 'a mention passes'

Write-Host '== 3. the registration =='
$hooks = Get-Content -Raw -LiteralPath $HooksJson | ConvertFrom-Json
$entry = @($hooks.hooks.PostToolUse | Where-Object { @($_.hooks | Where-Object { $_.command -match 'filed-with-stamp\.ps1' }).Count -gt 0 })
Assert-Equal 1 $entry.Count 'hooks.json registers the hook once, as PostToolUse'
Assert-Equal 'Bash|PowerShell' $entry[0].matcher 'on the shell tools'
Assert-True ($entry[0].hooks[0].command -match 'issue\[\[:space:\]\]\+create') 'behind a gh issue create pre-filter'
Assert-Equal 0 @($hooks.hooks.PreToolUse | Where-Object { @($_.hooks | Where-Object { $_.command -match 'filed-with-stamp\.ps1' }).Count -gt 0 }).Count 'and never before the create'

Write-Host ''
Write-Host "filed-with-stamp: $script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
exit 0
