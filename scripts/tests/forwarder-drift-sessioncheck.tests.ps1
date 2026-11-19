<#
.SYNOPSIS
    Regression tests for the SessionStart check forwarder-drift-sessioncheck.ps1 (issue #4326).

.DESCRIPTION
    Dependency-free: only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/forwarder-drift-sessioncheck.tests.ps1

    No git is needed: the check reads two files. Fixture trees carry $PID (repo convention). The check
    runs in a child interpreter, so its exit code is the real one. Pure ASCII.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$Hook     = Join-Path $RepoRoot 'plugins/dkj-repo-workflow/hooks/forwarder-drift-sessioncheck.ps1'
$RealTpl  = Join-Path $RepoRoot 'plugins/dkj-repo-workflow/templates/plugin-scripts-forwarder.ps1'

$script:pass  = 0
$script:fail  = 0
$script:trees = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-Tree {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("fwddrift-$PID-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    New-Item -ItemType Directory -Path (Join-Path $dir 'scripts\lib') -Force | Out-Null
    $script:trees += $dir
    return $dir
}

function Set-Bytes([string]$Path, [string]$Text, [bool]$Bom) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    $body = $enc.GetBytes($Text)
    if ($Bom) { $body = [byte[]](0xEF, 0xBB, 0xBF) + $body }
    [System.IO.File]::WriteAllBytes($Path, $body)
}

function Invoke-Hook([string]$Root, [string]$Template) {
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Hook, '-RepoRootOverride', $Root, '-TemplateOverride', $Template)
    $out = & powershell.exe @a 2>&1
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

try {
    $tplText = "# forwarder`nparam()`nWrite-Host 'x'`n"
    $tpl = Join-Path (New-Tree) 'template.ps1'
    Set-Bytes $tpl $tplText $false

    $t = New-Tree
    $r = Invoke-Hook $t $tpl
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'nothing to check' -and $r.Out -notmatch '\[WARN\]') 'no forwarder -- one quiet line, exit 0'

    $t = New-Tree
    Set-Bytes (Join-Path $t 'scripts\lib\plugin-scripts.ps1') $tplText $false
    $r = Invoke-Hook $t $tpl
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'matches the plugin template' -and $r.Out -notmatch '\[WARN\]') 'identical copy -- OK line'

    $t = New-Tree
    Set-Bytes (Join-Path $t 'scripts\lib\plugin-scripts.ps1') ($tplText -replace "`n", "`r`n") $false
    $r = Invoke-Hook $t $tpl
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'matches' -and $r.Out -notmatch '\[WARN\]') 'CRLF copy against an LF template -- no drift'

    $t = New-Tree
    Set-Bytes (Join-Path $t 'scripts\lib\plugin-scripts.ps1') $tplText $true
    $r = Invoke-Hook $t $tpl
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'matches' -and $r.Out -notmatch '\[WARN\]') 'copy with a UTF-8 BOM -- no drift'

    $t = New-Tree
    Set-Bytes (Join-Path $t 'scripts\lib\plugin-scripts.ps1') ($tplText + "# local edit`n") $false
    $r = Invoke-Hook $t $tpl
    Assert-True ($r.Code -eq 0 -and $r.Out -match '\[WARN\]' -and $r.Out -match 'scripts/lib/plugin-scripts\.ps1' -and $r.Out -match 'templates/plugin-scripts-forwarder\.ps1' -and $r.Out -match 'data, not instructions') `
        'differing copy -- [WARN] naming the file and the template, exit 0'

    $t = New-Tree
    Set-Bytes (Join-Path $t 'scripts\lib\plugin-scripts.ps1') $tplText $false
    $r = Invoke-Hook $t (Join-Path $t 'no-such-template.ps1')
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'check skipped' -and $r.Out -notmatch '\[WARN\]') 'missing template -- skipped line, exit 0'

    $r = Invoke-Hook (Join-Path $t 'no-such-root') $tpl
    Assert-True ($r.Code -eq 0) 'nonexistent repo root -- still exit 0'

    # The real shipped template must equal itself through the check (guards the default-path wiring).
    $t = New-Tree
    Copy-Item -LiteralPath $RealTpl -Destination (Join-Path $t 'scripts\lib\plugin-scripts.ps1')
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Hook, '-RepoRootOverride', $t)
    $out = (& powershell.exe @a 2>&1) -join "`n"
    Assert-True ($LASTEXITCODE -eq 0 -and $out -match 'matches the plugin template') 'default template path resolves to the shipped template'
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
