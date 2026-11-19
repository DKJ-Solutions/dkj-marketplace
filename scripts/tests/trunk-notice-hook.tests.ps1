<#
.SYNOPSIS
    Tests for plugins/dkj-repo-workflow/hooks/trunk-notice-hook.ps1 (#4325): the one-line notice on a prompt made
    while HEAD is on the trunk -- the pure decision, and the hook script end to end against fixture checkouts.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Hook = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\trunk-notice-hook.ps1'
. (Join-Path $PSScriptRoot '..\lib\fixture-git-lib.ps1')
$HooksJson = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\hooks.json'

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -ceq "$Actual") ($Name + $(if ("$Expected" -cne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

# Run the hook as a child process with a payload on stdin; returns the stdout text and the exit code.
function Invoke-Hook {
    param([string]$Root, [string]$Stdin = '{"session_id":"s1","prompt":"secret words"}')
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell'
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Hook`" -RepoRoot `"$Root`""
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $p = [System.Diagnostics.Process]::Start($psi)
    $p.StandardInput.Write($Stdin); $p.StandardInput.Close()
    $stdout = $p.StandardOutput.ReadToEnd()
    [void]$p.StandardError.ReadToEnd()
    $p.WaitForExit()
    [pscustomobject]@{ Out = $stdout.Trim(); Code = $p.ExitCode }
}

function New-Fixture {
    param([string]$Name, [string]$Branch = 'main', [switch]$NoGit)
    $d = Join-Path $script:scratch $Name
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    if (-not $NoGit) {
        Invoke-FixtureGitIn $d init -q -b $Branch
        Invoke-FixtureGitIn $d -c user.name=t -c user.email=t@example.invalid commit -q --allow-empty -m init
    }
    $d
}
function Set-Settings {
    param([string]$Dir, [string]$Name, [string]$Text)
    New-Item -ItemType Directory -Path (Join-Path $Dir '.claude') -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $Dir ".claude\$Name"), $Text)
}

$script:scratch = Join-Path ([System.IO.Path]::GetTempPath()) ('trunk-notice-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $script:scratch -Force | Out-Null
$bwjOn = '{"enabledPlugins":{"dkj-repo-workflow-bwj@dkj-marketplace":true}}'
$bwjOff = '{"enabledPlugins":{"dkj-repo-workflow-bwj@dkj-marketplace":false}}'
try {
    Write-Host '-- the decision' -ForegroundColor Cyan
    . $Hook
    Assert-Equal '' (Get-TrunkNoticeLine -Branch 'feat/x' -Trunk 'main' -StartSkill 's') 'off the trunk: no line'
    Assert-Equal '' (Get-TrunkNoticeLine -Branch 'HEAD' -Trunk 'main' -StartSkill 's') 'a detached HEAD: no line'
    Assert-Equal '' (Get-TrunkNoticeLine -Branch 'Main' -Trunk 'main' -StartSkill 's') 'the comparison is ordinal'
    $l = Get-TrunkNoticeLine -Branch 'main' -Trunk 'main' -StartSkill 'p:new-branch'
    Assert-True ($l -clike "*'main'*p:new-branch*" -and $l -notmatch "[\r\n]") 'on the trunk: one line naming the trunk and the skill'

    Write-Host '-- the hook, end to end' -ForegroundColor Cyan
    $d = New-Fixture 'on-trunk'
    $r = Invoke-Hook $d
    Assert-Equal 0 $r.Code 'on the trunk: exit 0'
    Assert-True ($r.Out -clike "[[]trunk-notice] HEAD is on the trunk 'main'*dkj-repo-workflow:new-branch skill*") 'on the trunk: the line names new-branch'
    Assert-True ($r.Out -cnotlike '*secret words*') 'the prompt is never printed'

    $d = New-Fixture 'off-trunk' 'feat/x'
    $r = Invoke-Hook $d
    Assert-True ($r.Code -eq 0 -and $r.Out -eq '') 'off the trunk: exit 0, nothing printed'

    $d = New-Fixture 'develop-trunk' 'develop'
    New-Item -ItemType Directory -Path (Join-Path $d 'scripts') -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $d 'scripts\repo-config.ps1'), "function Get-TrunkBranchName { 'develop' }`n")
    $r = Invoke-Hook $d
    Assert-True ($r.Code -eq 0 -and $r.Out -clike "*trunk 'develop'*") 'the trunk is read from the repo-config seam'
    $d = New-Fixture 'main-vs-develop' 'main'
    New-Item -ItemType Directory -Path (Join-Path $d 'scripts') -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $d 'scripts\repo-config.ps1'), "function Get-TrunkBranchName { 'develop' }`n")
    $r = Invoke-Hook $d
    Assert-True ($r.Code -eq 0 -and $r.Out -eq '') 'a branch named main is not the trunk when the seam says develop'

    $d = New-Fixture 'bwj-on'
    Set-Settings $d 'settings.json' $bwjOn
    Assert-True ((Invoke-Hook $d).Out -clike '*dkj-repo-workflow-bwj:start-task skill*') 'BWJ extension enabled in settings.json: start-task'

    $d = New-Fixture 'bwj-off'
    Set-Settings $d 'settings.json' $bwjOff
    Assert-True ((Invoke-Hook $d).Out -clike '*dkj-repo-workflow:new-branch skill*') 'BWJ extension false in settings.json: new-branch'

    $d = New-Fixture 'bwj-local-off'
    Set-Settings $d 'settings.json' $bwjOn
    Set-Settings $d 'settings.local.json' $bwjOff
    Assert-True ((Invoke-Hook $d).Out -clike '*dkj-repo-workflow:new-branch skill*') 'settings.local.json false overrides settings.json true: new-branch'

    $d = New-Fixture 'bwj-local-on'
    Set-Settings $d 'settings.local.json' $bwjOn
    Assert-True ((Invoke-Hook $d).Out -clike '*dkj-repo-workflow-bwj:start-task skill*') 'enabled only in settings.local.json: start-task'

    $d = New-Fixture 'bad-settings'
    Set-Settings $d 'settings.json' '{ not json'
    $r = Invoke-Hook $d
    Assert-True ($r.Code -eq 0 -and $r.Out -clike '*dkj-repo-workflow:new-branch skill*') 'malformed settings.json: new-branch, exit 0'

    $d = New-Fixture 'empty-stdin'
    $r = Invoke-Hook $d ''
    Assert-True ($r.Code -eq 0 -and $r.Out -eq '') 'empty stdin: exit 0, nothing printed'
    $r = Invoke-Hook $d '{ not json'
    Assert-True ($r.Code -eq 0 -and $r.Out -eq '') 'unparseable stdin: exit 0, nothing printed'

    $d = New-Fixture 'no-git' -NoGit
    $r = Invoke-Hook $d
    Assert-True ($r.Code -eq 0 -and $r.Out -eq '') 'not a git repo: exit 0, nothing printed'

    Write-Host '-- the wiring' -ForegroundColor Cyan
    $cfg = Get-Content -LiteralPath $HooksJson -Raw | ConvertFrom-Json
    $cmds = @($cfg.hooks.UserPromptSubmit | ForEach-Object { $_.hooks } | ForEach-Object { $_.command })
    Assert-True (@($cmds | Where-Object { $_ -clike '*hooks/trunk-notice-hook.ps1*' }).Count -eq 1) 'hooks.json wires the script once under UserPromptSubmit'
    Assert-True (@($cfg.hooks.Stop | ForEach-Object { $_.hooks } | ForEach-Object { $_.command } | Where-Object { $_ -clike '*trunk-notice*' }).Count -eq 0) 'it is not wired under Stop'
}
finally {
    Remove-Item -LiteralPath $script:scratch -Recurse -Force -ErrorAction SilentlyContinue
}

$fixtureBroken = Write-FixtureGitSummary -Subject 'trunk-notice-hook.ps1'
Write-Host ''
Write-Host "Passed: $script:pass  Failed: $script:fail"
if ($script:fail -gt 0 -or $fixtureBroken) { exit 1 }
exit 0
