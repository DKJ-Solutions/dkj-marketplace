<#
.SYNOPSIS
    Regression tests for the PreToolUse hook guard-live-pr-entry.ps1 (issue #4532).

.DESCRIPTION
    Dependency-free: only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/guard-live-pr-entry.tests.ps1

    The hook runs as a child process with a real PreToolUse payload on stdin, so its exit code and its
    stdout JSON are the real ones. The entry states come from the real formatters (entry-scaffold-lib),
    never from a literal here, for the reason branch-entry-gate.tests.ps1 gives. The fixtures need no git:
    the head is passed with --head, and the one case without it is the fail-open. Fixture paths carry $PID
    (repo convention). Pure ASCII.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Hook     = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\guard-live-pr-entry.ps1'
. (Join-Path $RepoRoot 'scripts\lib\entry-scaffold-lib.ps1')

$script:pass  = 0
$script:fail  = 0
$script:trees = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-Tree {
    param([string]$Live = 'live')
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("livepr-$PID-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    New-Item -ItemType Directory -Path (Join-Path $dir 'scripts') -Force | Out-Null
    $script:trees += $dir
    if ($Live) {
        [System.IO.File]::WriteAllText((Join-Path $dir 'scripts\repo-config.ps1'), "function Get-ShopifyLiveDeployBranch { return '$Live' }`n")
    }
    return $dir
}

function Set-Entry {
    param([string]$Dir, [AllowEmptyString()][string[]]$Lines)
    $target = Join-Path $Dir ((Get-BranchFilePaths).File -replace '/', '\')
    New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
    [System.IO.File]::WriteAllText($target, (($Lines -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding($false)))
}

function Set-WrittenEntry([string]$Dir) {
    Set-Entry -Dir $Dir -Lines (Format-EntryBlock -Branch 'fix/hot' -Type 'Fix' `
        -Description 'The banner shows again.' -Body 'The banner shows again.' `
        -ImpactRows @([pscustomobject]@{ Tier = 0; Score = 2; Why = 'Maintainers notice it.' }))
}

function Set-ScaffoldEntry([string]$Dir) {
    Set-Entry -Dir $Dir -Lines (Format-EntryBlock -Branch 'fix/hot' -Description '' -Type 'Fix' -Body '')
}

function Invoke-Hook {
    param([string]$Root, [string]$Command)
    $payload = @{ tool_name = 'Bash'; tool_input = @{ command = $Command }; cwd = $Root } | ConvertTo-Json -Compress
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Hook`" -RepoRootOverride `"$Root`""
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $p.StandardInput.Write($payload)
    $p.StandardInput.Close()
    $o = $p.StandardOutput.ReadToEndAsync()
    $e = $p.StandardError.ReadToEndAsync()
    $p.WaitForExit()
    return [pscustomobject]@{ Code = $p.ExitCode; Out = [string]$o.Result; Err = [string]$e.Result }
}

try {
    Write-Host 'silent where nothing applies'

    $t = New-Tree
    Set-ScaffoldEntry $t
    $r = Invoke-Hook $t 'git status'
    Assert-True ($r.Code -eq 0 -and -not $r.Out -and -not $r.Err) 'no gh pr create -- exit 0, nothing printed'

    $r = Invoke-Hook $t 'gh pr create --base main --head fix/hot --title x --body y'
    Assert-True ($r.Code -eq 0 -and -not $r.Out) '--base main is untouched -- exit 0, silent'

    $r = Invoke-Hook $t 'gh pr create --head fix/hot --title x --body y'
    Assert-True ($r.Code -eq 0 -and -not $r.Out) 'no --base (gh targets the default branch) -- silent'

    $r = Invoke-Hook $t 'grep -n "gh pr create --base live" notes.md'
    Assert-True ($r.Code -eq 0 -and -not $r.Out) 'a grep that only mentions the command -- silent'

    $none = New-Tree -Live ''
    Set-ScaffoldEntry $none
    $r = Invoke-Hook $none 'gh pr create --base live --head fix/hot'
    Assert-True ($r.Code -eq 0 -and -not $r.Out) 'no live branch declared -- silent, whatever the base'

    $vul = New-Tree -Live 'VUL-IN: fill in'
    Set-ScaffoldEntry $vul
    $r = Invoke-Hook $vul 'gh pr create --base live --head fix/hot'
    Assert-True ($r.Code -eq 0 -and -not $r.Out) 'a VUL-IN live answer -- silent'

    Write-Host ''
    Write-Host 'a PR to the live branch'

    $r = Invoke-Hook $t 'gh pr create --base live --head fix/hot --title x --body y'
    Assert-True ($r.Code -eq 2 -and $r.Err -match 'BLOCKED \(guard-live-pr-entry\)' -and $r.Err -match "'fix/hot'" -and $r.Err -match "live branch 'live'") 'scaffolded entry, --base live -- refused, naming head and live'
    Assert-True ($r.Err -match 'check-branch-entry said' -and $r.Err -match 'TO FIX') 'and the refusal carries the check''s findings and the fix'

    $r = Invoke-Hook $t 'gh pr create --base=live --head=fix/hot'
    Assert-True ($r.Code -eq 2) '--base=live / --head= forms -- refused too'

    $r = Invoke-Hook $t 'gh pr create -B live -H owner:fix/hot'
    Assert-True ($r.Code -eq 2 -and $r.Err -match "'fix/hot'") '-B / -H owner:branch -- refused, owner prefix dropped'

    $r = Invoke-Hook $t 'cd somewhere && gh pr create --base live --head fix/hot'
    Assert-True ($r.Code -eq 2) 'a second segment of a compound command -- still seen'

    $r = Invoke-Hook $t 'gh pr create --base Live --head fix/hot'
    Assert-True ($r.Code -eq 0) 'base compared case-sensitively, as git compares branch names'

    $ok = New-Tree
    Set-WrittenEntry $ok
    $r = Invoke-Hook $ok 'gh pr create --base live --head fix/hot --title x --body y'
    Assert-True ($r.Code -eq 0 -and -not $r.Out) 'written entry, --base live -- allowed, silent'

    Write-Host ''
    Write-Host 'fail-open, said to the session'

    $r = Invoke-Hook $t 'gh pr create --base $live --head fix/hot'
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'additionalContext' -and $r.Out -match 'could not read the --base') 'a variable base -- allowed, with additionalContext'

    $r = Invoke-Hook $t 'gh pr create --base live'
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'additionalContext' -and $r.Out -match 'could not tell which branch') 'no --head and no git checkout -- allowed, with additionalContext'
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
