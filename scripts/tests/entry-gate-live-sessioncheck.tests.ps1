<#
.SYNOPSIS
    Regression tests for the SessionStart check entry-gate-live-sessioncheck.ps1 (issue #4476).

.DESCRIPTION
    Dependency-free: only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/entry-gate-live-sessioncheck.tests.ps1

    No git is needed: the check reads two files. Fixture trees carry $PID (repo convention). The check
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
