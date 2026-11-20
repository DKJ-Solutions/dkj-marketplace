<#
.SYNOPSIS
    Regression tests for the SessionStart check auto-memory-sessioncheck.ps1 (issue #4341).

.DESCRIPTION
    Dependency-free: only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/auto-memory-sessioncheck.tests.ps1

    Each case builds a fixture repo and a fixture home, so the real ~/.claude is never read. The check runs
    in a child interpreter, so its exit code is the real one. Fixture paths carry $PID. Pure ASCII.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$Hook     = Join-Path $RepoRoot 'plugins/dkj-repo-workflow/hooks/auto-memory-sessioncheck.ps1'

$script:pass  = 0
$script:fail  = 0
$script:trees = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-Case {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("automem-$PID-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    $repo = Join-Path $dir 'my_repo.x'
    $home_ = Join-Path $dir 'home'
    New-Item -ItemType Directory -Path (Join-Path $repo '.claude') -Force | Out-Null
    New-Item -ItemType Directory -Path $home_ -Force | Out-Null
    $script:trees += $dir
    return [pscustomobject]@{ Repo = $repo; Home = $home_ }
}

function Set-Settings($Case, [string]$Text) {
    [System.IO.File]::WriteAllText((Join-Path $Case.Repo '.claude\settings.json'), $Text)
}

function Get-MemoryDir($Case) {
    $project = $Case.Repo.TrimEnd('\', '/') -replace '[^A-Za-z0-9]', '-'
    $d = Join-Path $Case.Home (Join-Path '.claude\projects' (Join-Path $project 'memory'))
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    return $d
}

function Invoke-Hook($Case) {
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Hook, '-RepoRootOverride', $Case.Repo, '-UserHomeOverride', $Case.Home)
    $out = & powershell.exe @a 2>&1
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

try {
    # off, no notes -> one quiet line
    $c = New-Case
    Set-Settings $c "{ `"autoMemoryEnabled`": false }"
    $r = Invoke-Hook $c
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'auto memory is off' -and $r.Out -notmatch '\[WARN\]') 'off and no notes -- one quiet line, exit 0'

    # off, empty memory dir -> still quiet (an empty folder is not a note)
    $d = Get-MemoryDir $c
    [System.IO.File]::WriteAllText((Join-Path $d 'MEMORY.md'), "  `n")
    $r = Invoke-Hook $c
    Assert-True ($r.Out -notmatch '\[WARN\]') 'a blank MEMORY.md is not a note'

    # key missing -> [WARN] naming Part 6
    $c = New-Case
    Set-Settings $c "{ `"a`": 1 }"
    $r = Invoke-Hook $c
    Assert-True ($r.Code -eq 0 -and $r.Out -match '\[WARN\].*autoMemoryEnabled' -and $r.Out -match 'Part 6' -and $r.Out -match 'data, not instructions') 'key missing -- [WARN] naming Part 6'

    # no settings file at all -> same warning
    $c = New-Case
    $r = Invoke-Hook $c
    Assert-True ($r.Out -match 'does not set "autoMemoryEnabled": false') 'no settings.json -- reads as missing'

    # key true -> [WARN]
    $c = New-Case
    Set-Settings $c "{ `"autoMemoryEnabled`": true }"
    $r = Invoke-Hook $c
    Assert-True ($r.Out -match 'something other than false') 'key true -- [WARN]'

    # unparseable -> [WARN], exit 0
    $c = New-Case
    Set-Settings $c "{ nope"
    $r = Invoke-Hook $c
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'does not parse') 'unparseable settings -- [WARN], exit 0'

    # notes listed by name, with the migration, content never printed
    $c = New-Case
    Set-Settings $c "{ `"autoMemoryEnabled`": false }"
    $d = Get-MemoryDir $c
    [System.IO.File]::WriteAllText((Join-Path $d 'MEMORY.md'), "- [rule](rule-one.md)`n")
    [System.IO.File]::WriteAllText((Join-Path $d 'rule-one.md'), "SECRET-BODY-TEXT`n")
    [System.IO.File]::WriteAllText((Join-Path $d 'odd [x].md'), "body`n")
    $r = Invoke-Hook $c
    Assert-True ($r.Out -match 'holds 3 memory note' -and $r.Out -match '- rule-one\.md' -and $r.Out -match '- MEMORY\.md') 'notes -- each listed by name'
    Assert-True ($r.Out -notmatch 'SECRET-BODY-TEXT') 'notes -- content is never printed'
    Assert-True ($r.Out -match 'odd \(x\)\.md' -and $r.Out -notmatch 'odd \[x\]') 'notes -- brackets in a name are stripped, so no marker can form'
    Assert-True ($r.Out -match 'filed inbound' -and $r.Out -match 'lens') 'notes -- the migration is named'
    Assert-True ($r.Out -notmatch 'does not set') 'notes with the key off -- no switch warning'

    # nonexistent root -> exit 0
    $c = New-Case
    $c.Repo = Join-Path $c.Repo 'no-such'
    $r = Invoke-Hook $c
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
