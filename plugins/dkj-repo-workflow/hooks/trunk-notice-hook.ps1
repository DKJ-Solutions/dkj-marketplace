<#
.SYNOPSIS
    The Claude Code hook behind the trunk notice (#4325): on every prompt made while HEAD is on the trunk, print one
    line saying so and naming the skill that opens a branch.

.DESCRIPTION
    Wired up in this plugin's hooks/hooks.json as a UserPromptSubmit hook, in every repo that runs dkj-repo-workflow:

        powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/hooks/trunk-notice-hook.ps1"

    Why: the orchestrator ends every assignment with the checkout back on the trunk, so the next assignment starts
    there. A UserPromptSubmit hook's stdout is injected into the session's context, so the line reminds the model to
    open a branch before the first edit. It is a reminder only: it NEVER BLOCKS.

    The trunk is read from the repo's scripts\repo-config.ps1 seam (Get-TrunkBranchName), default 'main', as
    logbook-hook.ps1 does. The branch-start skill is dkj-repo-workflow-bwj:start-task where the repo enables the BWJ
    extension (enabledPlugins in .claude\settings.json, overridden by .claude\settings.local.json), else
    dkj-repo-workflow:new-branch.

    IT ALWAYS EXITS 0 AND SWALLOWS EVERY ERROR. Off the trunk, on a detached HEAD, outside a git repo, or on any
    failure it prints nothing. The payload on stdin is only checked to parse, never printed. No network, no gh.

    -RepoRoot is for the tests; hooks.json passes none.

    Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = ''
)

# The pure decision: '' when the branch is not the trunk, else the one-line notice.
function Get-TrunkNoticeLine {
    param([string]$Branch, [string]$Trunk, [string]$StartSkill)
    if (-not $Branch -or -not $Trunk -or $Branch -cne $Trunk) { return '' }
    return "[trunk-notice] HEAD is on the trunk '$Trunk'. Work that changes a file starts on a branch -- open one with the $StartSkill skill before the first edit."
}

# True when the repo's settings enable the BWJ extension; settings.local.json overrides settings.json per key.
function Test-BwjExtensionEnabled {
    param([string]$Root)
    $enabled = @{}
    foreach ($name in 'settings.json', 'settings.local.json') {
        $p = Join-Path $Root ".claude\$name"
        if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { continue }
        try {
            $j = Get-Content -LiteralPath $p -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
            if ($j -and $j.enabledPlugins) {
                foreach ($prop in $j.enabledPlugins.PSObject.Properties) {
                    if ($prop.Name -clike 'dkj-repo-workflow-bwj@*') { $enabled[$prop.Name] = ($prop.Value -eq $true) }
                }
            }
        } catch { }
    }
    return [bool](@($enabled.Values | Where-Object { $_ }).Count)
}

# Dot-sourced by the tests to reach the functions without running the hook.
if ($MyInvocation.InvocationName -eq '.') { return }

$ErrorActionPreference = 'Stop'
try {
    $raw = ''
    if ([Console]::IsInputRedirected) {
        $reader = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), (New-Object System.Text.UTF8Encoding($false)))
        $raw = $reader.ReadToEnd()
    }
    if (-not $raw.Trim()) { exit 0 }
    $null = $raw | ConvertFrom-Json

    $root = if ($RepoRoot) { $RepoRoot } elseif ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
    $root = [System.IO.Path]::GetFullPath($root).TrimEnd('\', '/')

    $trunk = 'main'
    $cfg = Join-Path $root 'scripts\repo-config.ps1'
    if (Test-Path -LiteralPath $cfg -PathType Leaf) {
        try { . (Join-Path $PSScriptRoot '..\scripts\lib\command-probe-lib.ps1'); . $cfg *> $null; if (Test-FunctionDefined 'Get-TrunkBranchName') { $t = [string](Get-TrunkBranchName); if ($t.Trim()) { $trunk = $t.Trim() } } } catch { }
    }
    # Windows PowerShell 5.1 turns a native command's stderr line into a terminating error under 'Stop', so git runs
    # under 'Continue' and is judged by its exit code and output (as in logbook-hook.ps1).
    $ErrorActionPreference = 'Continue'
    $branch = ''
    $out = @(git -C $root rev-parse --abbrev-ref HEAD 2>$null)
    if ($LASTEXITCODE -eq 0 -and $out.Count) { $branch = ([string]$out[0]).Trim() }
    $ErrorActionPreference = 'Stop'
    if ($branch -cne $trunk) { exit 0 }

    $skill = if (Test-BwjExtensionEnabled -Root $root) { 'dkj-repo-workflow-bwj:start-task' } else { 'dkj-repo-workflow:new-branch' }
    $line = Get-TrunkNoticeLine -Branch $branch -Trunk $trunk -StartSkill $skill
    if ($line) { [Console]::Out.WriteLine($line) }
} catch {
}
exit 0
