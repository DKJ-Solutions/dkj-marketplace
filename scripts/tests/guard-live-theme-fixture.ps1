<#
.SYNOPSIS
    Shared setup, assert helpers and guard runners for the two guard-live-theme suites -- the tests for
    plugins/dkj-subagents/dkj-subagents-shopify/hooks/guard-live-theme.ps1 and the session check beside it.

.DESCRIPTION
    NOT NAMED *.tests.ps1 ON PURPOSE: the test gate globs that pattern, and this file asserts nothing.
    It is dot-sourced by the two suites that do:

      guard-live-theme.tests.ps1         groups 1 to 9, the session check, and rule 5's git push to the
                                         deploy branch (#3014)
      guard-live-theme-deploy.tests.ps1  rule 5's other routes onto the deploy branch (#4329) and
                                         group 10, the merged-only live push (#3758)

    WHY IT IS MORE THAN ONE FILE (#4430, November 23, 2026). The gate parallelises per FILE, and the
    single file measured 465s in CI (measure-suites over PR runs 45154073407, 45156109457 and
    45152244349) against an ideal shard of ~458s over 20 lanes -- a whole lane on its own, so it pinned
    whichever lane it landed in. Cut at the section boundary that balances measured time: standalone on
    one workstation the single file took 147s, and the two parts take about 74s and 72s of it.

    THE CUT COST ONE PROLOGUE. Part 2 used four fixtures part 1 built ($conn, its lane, and the
    placeholder and narrowed deploy-branch repos), so it rebuilds them in the state part 1 left them in.
    Every runner and constant both parts use lives here, the degraded (no-lib) guard among them, so no
    part holds a second copy of one.

    NOTHING WAS REMOVED TO BUY THE TIME. The two suites carry the same cases. One assert was ADDED back:
    in group 9, two Assert-Equal calls had been typed on one line, so PowerShell bound the second as
    extra arguments to the first and the case 'with no live id configured, any theme write is refused'
    never ran. It is on its own line now.

    Pure ASCII (repo convention for .ps1).
#># 'Continue', not 'Stop': the guard writes its refusal to stderr, and PowerShell 5.1 turns native
# stderr from a child process into a terminating NativeCommandError when the preference is 'Stop'.
# That stderr IS the expected output of a blocking case, so it must not end the run.
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
# Rule 5's fixtures need a git repo, built through the judged helper so a failed git is seen (#1635).
. (Join-Path $PSScriptRoot '..\lib\fixture-git-lib.ps1')
$Guard   = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify\hooks\guard-live-theme.ps1'
$Check    = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify\hooks\shopify-floor-sessioncheck.ps1'
# Fixture paths carry $PID: the test gate is a throttled PARALLEL scheduler, so two runs at one fixed
# temp path tear down each other's tree mid-assert.
$Fixture  = Join-Path ([System.IO.Path]::GetTempPath()) "guard-live-theme-fixture-$PID-$([guid]::NewGuid().ToString('n'))"

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:pass = 0
$script:fail = 0
$LF = "`n"
$LIVE = '190793613653'

function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red
    }
}

function New-FixtureRepo {
    <# A consuming repo with the seam answers under test, or none at all. #>
    param([string]$Label, [string]$ConfigBody = $null)
    $root = Join-Path $Fixture "repo-$Label"
    if (Test-Path -LiteralPath $root) { Remove-Item -Recurse -Force -LiteralPath $root }
    New-Item -ItemType Directory -Force -Path (Join-Path $root 'scripts') | Out-Null
    if ($null -ne $ConfigBody) {
        [System.IO.File]::WriteAllText((Join-Path $root 'scripts\repo-config.ps1'), $ConfigBody, $Utf8NoBom)
    }
    return $root
}

function Initialize-MergedFixture {
    <#
        Turn a fixture repo into a checkout whose theme files ARE the trunk: one commit, with
        refs/remotes/origin/main pointing at it. Since #3758 an authorised live push is held to
        origin/<trunk>, so every case that asserts the marker AUTHORISES needs this ground under it.
        autocrlf is pinned off so the stored bytes are the bytes written, whatever this machine's config.
    #>
    param([string]$Root, [string]$Trunk = 'main')
    New-Item -ItemType Directory -Force -Path (Join-Path $Root 'assets'), (Join-Path $Root 'layout') | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $Root 'assets\x.css'), "body { color: red; }`n", $Utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $Root 'layout\theme.liquid'), "<html>`n{{ content_for_layout }}`n</html>`n", $Utf8NoBom)
    Invoke-FixtureGitIn $Root init -q
    Invoke-FixtureGitIn $Root symbolic-ref HEAD "refs/heads/$Trunk"
    Invoke-FixtureGitIn $Root config core.autocrlf false
    Invoke-FixtureGitIn $Root config user.name fixture
    Invoke-FixtureGitIn $Root config user.email fixture@example.com
    Invoke-FixtureGitIn $Root add -A
    Invoke-FixtureGitIn $Root commit -q -m init
    Invoke-FixtureGitIn $Root update-ref "refs/remotes/origin/$Trunk" HEAD
}

function Invoke-Guard {
    <# Returns the exit code. The payload is the shape the harness sends, built rather than typed. #>
    param([string]$Command, [string]$Root)
    $payload = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
    $prev = $env:CLAUDE_PROJECT_DIR
    $env:CLAUDE_PROJECT_DIR = $Root
    try {
        $payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $Guard 2>&1 | Out-Null
        return $LASTEXITCODE
    } finally {
        if ($null -eq $prev) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue }
        else { $env:CLAUDE_PROJECT_DIR = $prev }
    }
}

function Get-GuardRefusal {
    <#
        The refusal TEXT rather than the exit code. Invoke-Guard discards stderr on purpose -- forty
        cases care only whether the command was blocked -- but the wording is itself a guard property
        since inbound #1032, and a sentence nothing asserts is a sentence the next edit removes.
    #>
    param([string]$Command, [string]$Root)
    $payload = @{ tool_name = 'PowerShell'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
    $prev = $env:CLAUDE_PROJECT_DIR
    $env:CLAUDE_PROJECT_DIR = $Root
    try {
        $out = $payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $Guard 2>&1
        return (($out | ForEach-Object { "$_" }) -join "`n")
    } finally {
        if ($null -eq $prev) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue }
        else { $env:CLAUDE_PROJECT_DIR = $prev }
    }
}

function Invoke-FloorCheck {
    param([string]$Root)
    $prev = $env:CLAUDE_PROJECT_DIR
    $env:CLAUDE_PROJECT_DIR = $Root
    try {
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Check 2>&1
        return [pscustomobject]@{ Code = $LASTEXITCODE; Out = (($out | ForEach-Object { "$_" }) -join "`n") }
    } finally {
        if ($null -eq $prev) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue }
        else { $env:CLAUDE_PROJECT_DIR = $prev }
    }
}

# The deploy-branch seam answered: the live theme deploys from 'live' (rule 5, #3014).
$deployCfg = @"
function Get-ShopifyLiveThemeId { return '$LIVE' }
function Get-ShopifyLiveDeployBranch { return 'live' }
"@

# A payload carrying the harness's cwd, for the cases that read HEAD where the command starts.
$cwdPayload = { param($c, $cwd) @{ tool_name = 'Bash'; cwd = $cwd; tool_input = @{ command = $c } } | ConvertTo-Json -Compress -Depth 5 }

# A MISSING LIB DEGRADES TOWARDS CHECKING, which is where this guard parts company with its sibling
# guard-working-copy.ps1: that one exits 0 and says the guard is off, because a working copy can be
# restored from origin and a published theme cannot be un-published. Run from a directory with no
# scripts\lib beside it, which is exactly what a broken or half-updated install looks like. The copy is
# placed on first use, under this run's own $Fixture.
$noLibGuard = Join-Path $Fixture 'nolib\hooks\guard-live-theme.ps1'

function Invoke-DegradedGuard {
    param([string]$Command, [Parameter(Mandatory = $true)][string]$Root)
    if (-not (Test-Path -LiteralPath $noLibGuard)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $noLibGuard) | Out-Null
        Copy-Item -LiteralPath $Guard -Destination $noLibGuard -Force
    }
    $payload = @{ tool_name = 'Bash'; tool_input = @{ command = $Command } } | ConvertTo-Json -Compress -Depth 5
    $prev = $env:CLAUDE_PROJECT_DIR
    $env:CLAUDE_PROJECT_DIR = $Root
    try {
        $err = ($payload | & powershell -NoProfile -ExecutionPolicy Bypass -File $noLibGuard 2>&1 | Out-String)
        return @{ Code = $LASTEXITCODE; Out = $err }
    } finally {
        if ($null -eq $prev) { Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue }
        else { $env:CLAUDE_PROJECT_DIR = $prev }
    }
}
