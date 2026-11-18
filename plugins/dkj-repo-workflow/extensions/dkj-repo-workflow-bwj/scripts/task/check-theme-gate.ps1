<#
.SYNOPSIS
    Check that this store's theme-check gate has the right SHAPE: the required CI check enforces theme
    check's outcome, and the check names in .theme-check.yml are real. One script for both BWJ stores.

.DESCRIPTION
    Reads .github/workflows/theme-check.yml and .theme-check.yml from the store's repo root and holds them
    to the rules in scripts\lib\theme-check-gate-rules.ps1, which also says why each rule exists. It runs
    no theme check itself (that needs the Shopify CLI and the network). Exit 0 = right shape, 1 = at least
    one finding or a file is missing.

    A store reaches it through its own forwarder (Resolve-PluginScript, never a hard-coded plugin path),
    from a thin suite or a gate.

    THE ONE OPTIONAL SEAM, in the store's scripts/repo-config.ps1:

        Get-ThemeCheckExtraChecks   string[] of theme-check check names, beyond ValidJSON and
                                    LiquidHTMLSyntaxError, that this store's .theme-check.yml enables.
                                    Every name must have been MEASURED to exist -- theme check ignores
                                    an unknown name without a word. Leave it out and only the two
                                    required names are accepted.

.PARAMETER Path
    The store's repo root. Default: found from the current directory.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-theme-gate.ps1

    Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param([string]$Path)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\theme-check-gate-rules.ps1')

$Root = Resolve-BwjRepoRoot -Override $Path

$extra = & {
    Set-StrictMode -Off
    $names = @()
    $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
    if (Test-Path -LiteralPath $configPath -PathType Leaf) {
        . $configPath
        if ([bool](@($ExecutionContext.InvokeCommand.GetCommands('Get-ThemeCheckExtraChecks', 'Function', $false)).Count)) {
            $names = @(Get-ThemeCheckExtraChecks)
        }
    }
    return , $names
} $Root

$workflow = Join-Path $Root '.github\workflows\theme-check.yml'
$config   = Join-Path $Root '.theme-check.yml'
$missing  = @(@($workflow, $config) | Where-Object { -not (Test-Path -LiteralPath $_ -PathType Leaf) })
if ($missing.Count -gt 0) {
    foreach ($m in $missing) { Write-Host "FAIL: missing $m" -ForegroundColor Red }
    exit 1
}

$findings = @(Get-ThemeCheckGateFindings `
    -WorkflowText (Get-Content -LiteralPath $workflow -Raw -Encoding UTF8) `
    -ConfigText   (Get-Content -LiteralPath $config -Raw -Encoding UTF8) `
    -ExtraChecks  @($extra))

if ($findings.Count -eq 0) { Write-Host 'PASS: the theme-check gate has the right shape.' -ForegroundColor Green; exit 0 }
foreach ($x in $findings) { Write-Host "  [FAIL] $x" -ForegroundColor Red }
Write-Host ("FAIL: {0} finding(s) in the theme-check gate." -f $findings.Count) -ForegroundColor Red
exit 1
