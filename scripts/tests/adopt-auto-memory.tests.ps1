<#
.SYNOPSIS
    Regression tests for scripts/task/adopt-auto-memory.ps1 -- issue #4341, Part 6 of
    'adopt-dkj-repo-workflow'.

.DESCRIPTION
    Dependency-free: only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/adopt-auto-memory.tests.ps1

    Every case runs against its own fixture repo, passed with -RootOverride, because this command writes
    into .claude/ and the repo running the suite has a settings file of its own. The value is in the
    refusals: an existing value is never replaced, a file that does not parse is never rewritten, and the
    bytes around the inserted member stay as they were (#2505).

    Fixture paths carry $PID (repo convention). Pure ASCII.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Script   = Join-Path $RepoRoot 'scripts\task\adopt-auto-memory.ps1'

$script:pass  = 0
$script:fail  = 0
$script:trees = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-FixtureRepo([string]$Label) {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("adoptmem-$PID-$Label-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $script:trees += $dir
    return (Resolve-Path -LiteralPath $dir).Path
}

function Set-Settings([string]$Root, [string]$Text, [bool]$Bom = $false) {
    $dir = Join-Path $Root '.claude'
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $body = (New-Object System.Text.UTF8Encoding($false)).GetBytes($Text)
    if ($Bom) { $body = [byte[]](0xEF, 0xBB, 0xBF) + $body }
    [System.IO.File]::WriteAllBytes((Join-Path $dir 'settings.json'), $body)
}

function Get-SettingsBytes([string]$Root) { return [System.IO.File]::ReadAllBytes((Join-Path $Root '.claude\settings.json')) }
function Get-SettingsText([string]$Root) { return [System.IO.File]::ReadAllText((Join-Path $Root '.claude\settings.json')) }

function Invoke-Adopt([string]$Root, [switch]$Apply) {
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Script, '-RootOverride', $Root)
    if ($Apply) { $a += '-Apply' }
    $out = @(& powershell @a 2>&1 | ForEach-Object { "$_" })
    return [pscustomobject]@{ Out = ($out -join "`n"); Code = $LASTEXITCODE }
}

try {
    Write-Host ''
    Write-Host '== adopt-auto-memory ==' -ForegroundColor Cyan

    # 1. the default writes nothing
    $root = New-FixtureRepo 'dry'
    $r = Invoke-Adopt $root
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'would write' -and $r.Out -match '"autoMemoryEnabled": false') 'dry run: says what it would add, exit 0'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $root '.claude\settings.json'))) 'dry run: no settings file is written'

    # 2. no settings file -> created with the key
    $root = New-FixtureRepo 'new'
    $r = Invoke-Adopt $root -Apply
    $parsed = Get-SettingsText $root | ConvertFrom-Json
    Assert-True ($r.Code -eq 0 -and $parsed.autoMemoryEnabled -is [bool] -and -not $parsed.autoMemoryEnabled) 'apply on no file: settings.json created with autoMemoryEnabled false'

    # 3. an existing file keeps every byte it had: blank line, CRLF, BOM, trailing newline
    $root = New-FixtureRepo 'bytes'
    $orig = "{`r`n    `"a`": 1,`r`n`r`n    `"b`": [1, 2]`r`n}`r`n"
    Set-Settings $root $orig $true
    $r = Invoke-Adopt $root -Apply
    $bytes = Get-SettingsBytes $root
    $text = (New-Object System.Text.UTF8Encoding($false)).GetString($bytes, 3, $bytes.Length - 3)
    $expected = "{`r`n    `"a`": 1,`r`n`r`n    `"b`": [1, 2],`r`n    `"autoMemoryEnabled`": false`r`n}`r`n"
    Assert-True ($r.Code -eq 0 -and $text -ceq $expected) 'apply: member inserted in the file''s own indent and line ending, nothing else changed'
    Assert-True ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) 'apply: the BOM is kept'

    # 4. a re-run finds nothing to do
    $before = Get-SettingsText $root
    $r = Invoke-Adopt $root -Apply
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'already sets autoMemoryEnabled to false' -and (Get-SettingsText $root) -ceq $before) 're-run: [keep], file unchanged'

    # 5. an existing true is never replaced
    $root = New-FixtureRepo 'true'
    Set-Settings $root "{`n  `"autoMemoryEnabled`": true`n}`n"
    $before = Get-SettingsText $root
    $r = Invoke-Adopt $root -Apply
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'left exactly as it is' -and (Get-SettingsText $root) -ceq $before) 'existing true: left alone, said so'

    # 6. an unparseable file is refused, not rewritten
    $root = New-FixtureRepo 'bad'
    Set-Settings $root "{ `"a`": 1, "
    $before = Get-SettingsText $root
    $r = Invoke-Adopt $root -Apply
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'does not parse' -and (Get-SettingsText $root) -ceq $before) 'unparseable: refused with exit 1, file byte for byte'

    # 7. an empty object takes the member without a stray comma
    $root = New-FixtureRepo 'empty'
    Set-Settings $root "{}`n"
    $r = Invoke-Adopt $root -Apply
    $parsed = $null; try { $parsed = Get-SettingsText $root | ConvertFrom-Json } catch { }
    Assert-True ($r.Code -eq 0 -and $null -ne $parsed -and -not $parsed.autoMemoryEnabled) 'empty object: valid JSON with the key'

    # 8. the source repo's own settings carry the key (the repo that prescribes it runs it)
    $own = Get-Content -LiteralPath (Join-Path $RepoRoot '.claude\settings.json') -Raw | ConvertFrom-Json
    Assert-True ($own.autoMemoryEnabled -is [bool] -and -not $own.autoMemoryEnabled) 'this repo''s own .claude/settings.json sets autoMemoryEnabled false'
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
