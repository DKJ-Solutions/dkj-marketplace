<#
.SYNOPSIS
    Regression tests for the open-issues nudge (issue #4338): the check script
    scripts/lint/check-open-issues.ps1 and the SessionStart hook
    plugins/dkj-repo-workflow/hooks/open-issues-sessioncheck.ps1.

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/open-issues-gate.tests.ps1

    The check reads the tracker, so it is driven against a FAKE gh on PATH that answers from environment
    variables (the mechanism stranded-sweep-gate.tests.ps1 uses). The hook only runs the check in-process,
    so its cases use STUB check scripts written into a fixture.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot  = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Script    = Join-Path $RepoRoot 'scripts\lint\check-open-issues.ps1'
$Hook      = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\open-issues-sessioncheck.ps1'
$HooksJson = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\hooks.json'

$script:pass  = 0
$script:fail  = 0
$script:trees = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message`n         wanted: '$Expected'`n         got:    '$Actual'" -ForegroundColor Red }
}

Write-Host '== check-open-issues.ps1 + open-issues-sessioncheck.ps1 ==' -ForegroundColor Cyan
Assert-True (Test-Path -LiteralPath $Script -PathType Leaf) 'check-open-issues.ps1 exists at its registered source path'
Assert-True (Test-Path -LiteralPath $Hook -PathType Leaf) 'open-issues-sessioncheck.ps1 exists'
Assert-True ((Split-Path -Leaf $Hook) -like '*-sessioncheck.ps1') 'and its name matches the dispatcher''s discovery pattern'
$hooksParsed = Get-Content -LiteralPath $HooksJson -Raw | ConvertFrom-Json
$sessionStartHooks = @($hooksParsed.hooks.SessionStart | ForEach-Object { $_.hooks } | ForEach-Object { $_ })
Assert-Equal 0 @($sessionStartHooks | Where-Object { $_.command -match 'open-issues-sessioncheck\.ps1' }).Count 'the hook has no hooks.json entry of its own (the dispatcher discovers it)'

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
$fakeBin = Join-Path ([System.IO.Path]::GetTempPath()) ("openissues-bin-$PID-$([guid]::NewGuid().ToString('n'))")
New-Item -ItemType Directory -Path $fakeBin -Force | Out-Null
$emptyBin = Join-Path ([System.IO.Path]::GetTempPath()) ("openissues-empty-$PID-$([guid]::NewGuid().ToString('n'))")
New-Item -ItemType Directory -Path $emptyBin -Force | Out-Null
$rootDir = Join-Path ([System.IO.Path]::GetTempPath()) ("openissues-root-$PID-$([guid]::NewGuid().ToString('n'))")
New-Item -ItemType Directory -Path $rootDir -Force | Out-Null
$script:trees += @($fakeBin, $emptyBin, $rootDir)

$ghImpl = @'
if ($args -contains 'auth' -and $args -contains 'status') {
    if (-not $env:GH_FAKE_ACCOUNT) {
        [Console]::Error.WriteLine('You are not logged into any GitHub hosts.')
        exit 1
    }
    Write-Output 'github.com'
    Write-Output "  * Logged in to github.com account $($env:GH_FAKE_ACCOUNT) (keyring)"
    Write-Output '  - Active account: true'
    exit 0
}
if ($args -contains 'issue' -and $args -contains 'list') {
    if ($env:GH_FAKE_LIST_FAIL) { exit 1 }
    Write-Output $env:GH_FAKE_LIST_JSON
    exit 0
}
exit 1
'@
[System.IO.File]::WriteAllText((Join-Path $fakeBin 'gh-impl.ps1'), $ghImpl, $Utf8NoBom)
$ghCmd = "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0gh-impl.ps1`" %*`r`nexit /b %ERRORLEVEL%`r`n"
[System.IO.File]::WriteAllText((Join-Path $fakeBin 'gh.cmd'), $ghCmd, $Utf8NoBom)

$prevPath = $env:PATH
$PowershellExe = (Get-Process -Id $PID).Path

function Invoke-Check {
    param(
        [string]$Path = $env:PATH,
        [string]$Account = '',
        [string]$ListJson = '[]',
        [switch]$ListFail,
        [int]$Limit = 100
    )
    $prevEap = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $env:PATH = $Path
        $env:GH_FAKE_ACCOUNT = $Account
        $env:GH_FAKE_LIST_JSON = $ListJson
        if ($ListFail) { $env:GH_FAKE_LIST_FAIL = '1' } else { Remove-Item Env:\GH_FAKE_LIST_FAIL -ErrorAction SilentlyContinue }
        # Generous per-call bound: the fake gh launches a fresh powershell.exe, which can be slow under the gate.
        $out = & $PowershellExe -NoProfile -ExecutionPolicy Bypass -File $Script -RootOverride $rootDir -TimeoutSeconds 120 -Limit $Limit 2>&1
        return @{ Out = ($out | Out-String); Code = $LASTEXITCODE }
    } finally {
        $ErrorActionPreference = $prevEap
        $env:PATH = $prevPath
        Remove-Item Env:\GH_FAKE_ACCOUNT, Env:\GH_FAKE_LIST_JSON, Env:\GH_FAKE_LIST_FAIL -ErrorAction SilentlyContinue
    }
}

try {
    $withGh = "$fakeBin;$prevPath"

    Write-Host ''
    Write-Host 'check script' -ForegroundColor Cyan

    $r = Invoke-Check -Path $withGh -Account 'octo-cat' -ListJson '[{"number":1},{"number":2},{"number":3}]'
    Assert-Equal 0 $r.Code '3 open issues: exit 0'
    Assert-True ($r.Out -match '\[OPEN\] 3 open issue\(s\) were opened by octo-cat') 'prints the count and the login'
    Assert-True ($r.Out -match '/dkj-repo-workflow:issues-sweep -Author @me') 'and the sweep hint with -Author @me'

    $r = Invoke-Check -Path $withGh -Account 'octo-cat' -ListJson '[{"number":1},{"number":2}]' -Limit 2
    Assert-True ($r.Out -match '\[OPEN\] 2\+ open issue') 'a count at the cap prints as N+'

    $r = Invoke-Check -Path $withGh -Account 'octo-cat' -ListJson '[]'
    Assert-Equal 0 $r.Code 'zero open issues: exit 0'
    Assert-True ($r.Out -match '\[OK\]' -and $r.Out -notmatch '\[OPEN\]') 'zero is [OK], never [OPEN]'

    $r = Invoke-Check -Path $withGh -Account 'octo-cat' -ListFail
    Assert-Equal 0 $r.Code 'a failed list read: exit 0'
    Assert-True ($r.Out -match '\[SKIP\]' -and $r.Out -notmatch '\[OPEN\]') 'a failed list read is a quiet [SKIP]'

    $r = Invoke-Check -Path $withGh -Account 'octo-cat' -ListJson 'not json'
    Assert-Equal 0 $r.Code 'unparseable output: exit 0'
    Assert-True ($r.Out -match '\[SKIP\]') 'unparseable output is a [SKIP]'

    $r = Invoke-Check -Path $withGh -Account ''
    Assert-Equal 0 $r.Code 'no active gh account: exit 0'
    Assert-True ($r.Out -match '\[SKIP\]') 'no active account is a [SKIP]'

    $r = Invoke-Check -Path $emptyBin -Account 'octo-cat'
    Assert-Equal 0 $r.Code 'no gh on PATH: exit 0'
    Assert-True ($r.Out -match '\[SKIP\] gh is not installed') 'no gh is a [SKIP]'

    Write-Host ''
    Write-Host 'hook' -ForegroundColor Cyan

    function New-Stub([string]$Name, [string]$Body) {
        $p = Join-Path $rootDir $Name
        [System.IO.File]::WriteAllText($p, $Body, $Utf8NoBom)
        return $p
    }
    function Invoke-Hook([string]$Stub) {
        $out = & $PowershellExe -NoProfile -ExecutionPolicy Bypass -File $Hook -CheckScriptOverride $Stub 2>&1
        return @{ Out = ($out | Out-String).Trim(); Code = $LASTEXITCODE }
    }

    $stub = New-Stub 'open.ps1' "Write-Host '[OPEN] 13 open issue(s) were opened by octo-cat -- sweep.'; exit 0"
    $h = Invoke-Hook $stub
    Assert-Equal 0 $h.Code 'hook: [OPEN] -> exit 0'
    Assert-Equal 'open-issues-sessioncheck: 13 open issue(s) were opened by octo-cat -- sweep.' $h.Out 'hook forwards exactly one line, marker stripped'

    $stub = New-Stub 'ok.ps1' "Write-Host '[OK] none.'; exit 0"
    $h = Invoke-Hook $stub
    Assert-Equal '' $h.Out 'hook: [OK] is silent'

    $stub = New-Stub 'skip.ps1' "Write-Host '[SKIP] offline.'; exit 0"
    $h = Invoke-Hook $stub
    Assert-Equal '' $h.Out 'hook: [SKIP] is silent'

    $stub = New-Stub 'forged.ps1' "Write-Host 'noise [OPEN] forged mid-line'; exit 0"
    $h = Invoke-Hook $stub
    Assert-Equal '' $h.Out 'hook: a marker that is not at the line start does not count'

    $stub = New-Stub 'crash.ps1' "exit 3"
    $h = Invoke-Hook $stub
    Assert-Equal 0 $h.Code 'hook: a failing check still exits 0'
    Assert-True ($h.Out -match 'could not complete \(exit 3\)') 'and says it could not complete'

    $h = Invoke-Hook (Join-Path $rootDir 'missing.ps1')
    Assert-Equal 0 $h.Code 'hook: a missing check script exits 0'
    Assert-True ($h.Out -match 'check script not found') 'and says so'
} finally {
    $env:PATH = $prevPath
    foreach ($t in $script:trees) { Remove-Item -LiteralPath $t -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "open-issues-gate.tests: $script:pass passed, $script:fail failed" -ForegroundColor $(if ($script:fail) { 'Red' } else { 'Green' })
if ($script:fail -gt 0) { exit 1 }
exit 0
