<#
.SYNOPSIS
    Read the store's Get-StorefrontMarkets seam, the one way every storefront check of this plugin does
    it (which-theme #4289, check-jsonld #4290). Needs command-probe-lib.ps1 (Test-FunctionDefined).

.DESCRIPTION
    Dot-source this file. The market table is per store, so nothing is shipped here: the rows come from
    the optional Get-StorefrontMarkets function in the repo's scripts/repo-config.ps1 (Market, Domain
    and optional PathPrefix). Turning rows into URLs is Get-ProbeTargets in which-theme-rules.ps1; this
    file only reads the seam, so there is exactly one market-table reader.

    The file is read in a child scope with StrictMode off and inside a try: it belongs to the consumer,
    so a fault in it must degrade to "unanswered" rather than take the calling script down.

    No Set-StrictMode here. Pure ASCII (repo convention for .ps1).
#>

function Get-StorefrontMarketRows {
    <# The seam's rows as the store answered them, or an empty array when it is unanswered. #>
    param([Parameter(Mandatory = $true)][string]$RepoRoot)
    $root = ([string]$RepoRoot).Trim() -replace '/', '\'
    return @(& {
        Set-StrictMode -Off
        $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
        if (Test-Path -LiteralPath $configPath -PathType Leaf) {
            try { . $configPath } catch { }
        }
        if (Test-FunctionDefined 'Get-StorefrontMarkets') { return @(Get-StorefrontMarkets) }
    } $root)
}
