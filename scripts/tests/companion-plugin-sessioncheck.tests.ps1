<#
.SYNOPSIS
    Tests for plugins/dkj-policy/hooks/companion-plugin-sessioncheck.ps1 -- the session check that reports
    a plugin enabled without the companion it requires (#4216).

.DESCRIPTION
    What is pinned is WHEN it speaks: silent when both halves are enabled or neither is required, one
    [ERROR] naming the companion and the install line when the core team is enabled alone, the companion
    looked for in the requiring plugin's own marketplace, an explicit `false` read as not enabled, and
    the user layer counted like any other. Each case runs the hook as a child process against a scratch
    fixture, with the repo root and the user home passed in, so the machine's own settings are never read.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Hook     = Join-Path $RepoRoot 'plugins\dkj-policy\hooks\companion-plugin-sessioncheck.ps1'
# $PID and a guid in the fixture path: the test gate runs suites in parallel.
$Fixture  = Join-Path ([System.IO.Path]::GetTempPath()) "companion-plugin-sessioncheck-$PID-$([guid]::NewGuid().ToString('n'))"

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}

function New-Case {
    <# A repo root and a user home under the fixture, each with the settings JSON given (or none). #>
    param([string]$Label, [string]$RepoJson = '', [string]$UserJson = '')
    $repo = Join-Path $Fixture "$Label\repo"
    $home_ = Join-Path $Fixture "$Label\home"
    New-Item -ItemType Directory -Force -Path (Join-Path $repo '.claude'), (Join-Path $home_ '.claude') | Out-Null
    if ($RepoJson) { [System.IO.File]::WriteAllText((Join-Path $repo '.claude\settings.json'), $RepoJson) }
    if ($UserJson) { [System.IO.File]::WriteAllText((Join-Path $home_ '.claude\settings.json'), $UserJson) }
    return [pscustomobject]@{ Repo = $repo; Home = $home_ }
}

function Invoke-Hook {
    param($Case)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook -RepoRootOverride $Case.Repo -UserHomeOverride $Case.Home 2>&1 | ForEach-Object { "$_" }
    return [pscustomobject]@{ Text = ($out -join "`n"); Code = $LASTEXITCODE }
}

try {
    $both = New-Case -Label 'both' -RepoJson '{ "enabledPlugins": { "dkj-subagents-alpha@dkj-marketplace": true, "dkj-subagents-developers@dkj-marketplace": true } }'
    $r = Invoke-Hook $both
    Assert-True ($r.Text.Trim() -eq '') 'both halves enabled is silent'
    Assert-True ($r.Code -eq 0) 'and exits 0'

    $alone = New-Case -Label 'alone' -RepoJson '{ "enabledPlugins": { "dkj-subagents-alpha@dkj-marketplace": true, "dkj-policy@dkj-marketplace": true } }'
    $r = Invoke-Hook $alone
    Assert-True ($r.Text -match "\[ERROR\] 'dkj-subagents-alpha@dkj-marketplace' is enabled \(in \.claude/settings\.json\) but 'dkj-subagents-developers@dkj-marketplace' is not") 'the measured case (#4216): the core team alone is one [ERROR] naming the companion and the layer'
    Assert-True ($r.Text -match '"dkj-subagents-developers@dkj-marketplace": true') 'it prints the enabledPlugins line to paste'
    Assert-True ($r.Text -match 'claude plugin install dkj-subagents-developers@dkj-marketplace --scope project') 'and the install command'
    Assert-True ($r.Code -eq 0) 'a finding still exits 0'
    Assert-True (@(([regex]'\[ERROR\]').Matches($r.Text)).Count -eq 1) 'exactly one finding'

    $off = New-Case -Label 'off' -RepoJson '{ "enabledPlugins": { "dkj-subagents-alpha@dkj-marketplace": true, "dkj-subagents-developers@dkj-marketplace": false } }'
    $r = Invoke-Hook $off
    Assert-True ($r.Text -match '\[ERROR\]') 'a companion enabled as false counts as not enabled'

    $fork = New-Case -Label 'fork' -RepoJson '{ "enabledPlugins": { "dkj-subagents-alpha@a-fork": true, "dkj-subagents-developers@dkj-marketplace": true } }'
    $r = Invoke-Hook $fork
    Assert-True ($r.Text -match "'dkj-subagents-developers@a-fork' is not") 'the companion is looked for in the requiring plugin''s own marketplace'

    $developersOnly = New-Case -Label 'devonly' -RepoJson '{ "enabledPlugins": { "dkj-subagents-developers@dkj-marketplace": true } }'
    $r = Invoke-Hook $developersOnly
    Assert-True ($r.Text.Trim() -eq '') 'a plugin with no table row is never a finding'

    $none = New-Case -Label 'none'
    $r = Invoke-Hook $none
    Assert-True ($r.Text.Trim() -eq '' -and $r.Code -eq 0) 'no settings file at all is silent'

    $user = New-Case -Label 'user' -UserJson '{ "enabledPlugins": { "dkj-subagents-alpha@dkj-marketplace": true } }'
    $r = Invoke-Hook $user
    Assert-True ($r.Text -match "is enabled \(in user ~/\.claude/settings\.json\)") 'an enable from the user layer is reported with that layer'

    $split = New-Case -Label 'split' -UserJson '{ "enabledPlugins": { "dkj-subagents-developers@dkj-marketplace": true } }' -RepoJson '{ "enabledPlugins": { "dkj-subagents-alpha@dkj-marketplace": true } }'
    $r = Invoke-Hook $split
    Assert-True ($r.Text.Trim() -eq '') 'the companion enabled in another layer of the chain counts'

    $broken = New-Case -Label 'broken' -RepoJson '{ not json'
    $r = Invoke-Hook $broken
    Assert-True ($r.Code -eq 0 -and $r.Text -notmatch '\[ERROR\]') 'an unparseable settings file is not a finding and exits 0'
} finally {
    if (Test-Path -LiteralPath $Fixture) { Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "companion-plugin-sessioncheck: $script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
exit 0
