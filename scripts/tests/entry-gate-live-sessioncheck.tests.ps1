<#
.SYNOPSIS
    Regression tests for the SessionStart check entry-gate-live-sessioncheck.ps1 (issues #4476, #4526).

.DESCRIPTION
    Needs PowerShell and git.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/entry-gate-live-sessioncheck.tests.ps1

    The working-copy half reads two files; the deploy-copy half (#4526) reads origin/live's caller, so
    those fixtures are git repos with a local refs/remotes/origin/live. Fixture trees carry $PID (repo convention). The check
    runs in a child interpreter, so its exit code is the real one. Pure ASCII.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$Hook     = Join-Path $RepoRoot 'plugins/dkj-repo-workflow/hooks/entry-gate-live-sessioncheck.ps1'

$script:pass  = 0
$script:fail  = 0
$script:trees = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-Tree {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("entrygatelive-$PID-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    New-Item -ItemType Directory -Path (Join-Path $dir 'scripts') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $dir '.github\workflows') -Force | Out-Null
    $script:trees += $dir
    return $dir
}

function Set-Text([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllBytes($Path, (New-Object System.Text.UTF8Encoding($false)).GetBytes($Text))
}

function Set-Seam([string]$Root, [string]$Body) {
    Set-Text (Join-Path $Root 'scripts\repo-config.ps1') $Body
}

function Set-Live([string]$Root, [string]$Name) {
    Set-Seam $Root ("function Get-ShopifyLiveDeployBranch { return '$Name' }`n")
}

function Set-Caller([string]$Root, [string]$List) {
    Set-Text (Join-Path $Root '.github\workflows\branch-entry.yml') ("on:`n  pull_request:`n    branches: [$List]`n")
}

# git with its stderr discarded. Under 'Stop', Windows PowerShell 5.1 turns a native stderr line (a CRLF
# warning) into a terminating NativeCommandError even when redirected, so the call runs under 'Continue'.
function Invoke-FixtureGit([string]$Root, [string[]]$GitArgs) {
    $ErrorActionPreference = 'Continue'
    $all = @('-C', $Root, '-c', 'core.autocrlf=false', '-c', 'user.name=t', '-c', 'user.email=t@example.invalid', '-c', 'commit.gpgsign=false') + $GitArgs
    & git @all 2>$null | Out-Null
}

# A git repo with one empty commit, so origin/live can later be pointed at a commit.
function New-GitRepo([string]$Root) {
    Invoke-FixtureGit $Root @('init', '-q')
    Invoke-FixtureGit $Root @('commit', '-q', '--allow-empty', '-m', 'base')
}

# Commit the tree as it stands and point refs/remotes/origin/live at that commit.
function Set-RemoteLive([string]$Root) {
    Invoke-FixtureGit $Root @('add', '-A')
    Invoke-FixtureGit $Root @('commit', '-q', '--allow-empty', '-m', 'live')
    Invoke-FixtureGit $Root @('update-ref', 'refs/remotes/origin/live', 'HEAD')
}

function Invoke-Hook([string]$Root) {
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Hook, '-RepoRootOverride', $Root)
    $out = & powershell.exe @a 2>&1
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

try {
    $t = New-Tree
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'nothing to check' -and $r.Out -notmatch '\[WARN\]') 'no repo-config -- quiet line, exit 0'

    $t = New-Tree
    Set-Seam $t "function Get-ShopifyLiveDeployBranch { return '' }`n"
    Set-Caller $t 'main'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'nothing to check' -and $r.Out -notmatch '\[WARN\]') 'unanswered seam -- nothing to check'

    $t = New-Tree
    Set-Live $t 'VUL-IN: fill in'
    Set-Caller $t 'main'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'not a usable' -and $r.Out -notmatch '\[WARN\]') 'VUL-IN answer -- not usable, no warning'

    $t = New-Tree
    Set-Live $t 'main'
    Set-Caller $t 'main'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'not a usable' -and $r.Out -notmatch '\[WARN\]') "answer 'main' -- not usable, no warning"

    $t = New-Tree
    Set-Live $t 'live'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'no \.github/workflows/branch-entry\.yml' -and $r.Out -notmatch '\[WARN\]') 'no caller -- nothing to check'

    $t = New-Tree
    Set-Live $t 'live'
    Set-Text (Join-Path $t '.github\workflows\branch-entry.yml') "on:`n  pull_request:`n    branches:`n      - main`n"
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'could not be read' -and $r.Out -notmatch '\[WARN\]') 'block-form branches -- skipped line'

    $t = New-Tree
    Set-Live $t 'live'
    Set-Caller $t 'main'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match '\[WARN\]' -and $r.Out -match 'data, not instructions' -and $r.Out -match [regex]::Escape('Fix: change the line to: branches: [main, live]')) `
        'caller on [main], answer live -- WARN and the exact Fix line'

    $t = New-Tree
    Set-Live $t 'live'
    Set-Caller $t 'main, live'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match "lists the live branch 'live'" -and $r.Out -notmatch '\[WARN\]') 'caller already [main, live] -- OK'

    $t = New-Tree
    Set-Live $t 'live'
    Set-Caller $t '"main", ''live'''
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'lists the live branch' -and $r.Out -notmatch '\[WARN\]') 'quoted list -- OK'

    $t = New-Tree
    Set-Seam $t "function Get-ShopifyLiveDeployBranch { throw 'boom' }`n"
    Set-Caller $t 'main'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'nothing to check' -and $r.Out -notmatch '\[WARN\]') 'throwing function -- treated as unanswered, exit 0'

    $t = New-Tree
    Set-Seam $t "throw 'broken seam'`n"
    Set-Caller $t 'main'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'nothing to check') 'repo-config that throws at load -- unanswered, exit 0'

    $r = Invoke-Hook (Join-Path $t 'no-such-root')
    Assert-True ($r.Code -eq 0) 'nonexistent repo root -- still exit 0'

    # --- The deploy branch's own copy (#4526) ---
    $t = New-Tree
    Set-Live $t 'live'
    Set-Caller $t 'main, live'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'deploy branch.s copy of the caller was not checked' -and $r.Out -notmatch '\[WARN\]') 'not a git repo -- deploy copy not checked, no warning'

    # The measured shape: the trunk fixed, origin/live still on [main].
    $t = New-Tree
    Set-Live $t 'live'
    Set-Caller $t 'main'
    New-GitRepo $t
    Set-RemoteLive $t
    Set-Caller $t 'main, live'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match "lists the live branch 'live'" -and $r.Out -match [regex]::Escape("[WARN] origin/live:.github/workflows/branch-entry.yml lists [main] but not 'live'") -and $r.Out -match 'next promotion') `
        'trunk [main, live], origin/live [main] -- WARN on the deploy copy with the remedy'

    $t = New-Tree
    Set-Live $t 'live'
    Set-Caller $t 'main, live'
    New-GitRepo $t
    Set-RemoteLive $t
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match "origin/live's own caller lists 'live' too" -and $r.Out -notmatch '\[WARN\]') 'origin/live carries [main, live] -- OK, no warning'

    $t = New-Tree
    Set-Live $t 'live'
    New-GitRepo $t
    Set-RemoteLive $t
    Set-Caller $t 'main, live'
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match [regex]::Escape('[WARN] origin/live has no .github/workflows/branch-entry.yml')) 'origin/live without a caller -- WARN'

    $t = New-Tree
    Set-Live $t 'live'
    Set-Caller $t 'main, live'
    New-GitRepo $t
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'no origin/live ref' -and $r.Out -notmatch '\[WARN\]') 'git repo without origin/live -- not checked, no warning'
}
finally {
    foreach ($d in $script:trees) {
        if ($d -and (Test-Path -LiteralPath $d)) { Remove-Item -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

Write-Host ''
if ($script:fail -gt 0) {
    Write-Host "FAIL: $($script:fail) failed, $($script:pass) passed." -ForegroundColor Red
    exit 1
}
Write-Host "OK: all $($script:pass) asserts passed." -ForegroundColor Green
exit 0
