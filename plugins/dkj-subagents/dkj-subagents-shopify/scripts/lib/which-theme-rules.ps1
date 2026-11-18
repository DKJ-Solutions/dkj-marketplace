<#
.SYNOPSIS
    The pure rules behind which-theme.ps1 (#4289): URL building, reading the served theme out of the
    HTML, bot-protection detection and fingerprint evaluation. No network, no repo access.

.DESCRIPTION
    Dot-source this file. Split out of the script for the same reason sync-rules.ps1 is split out of
    sync-main.ps1: the script fetches pages, and a suite must not reach a store, so everything that can
    be wrong without a network lives here where scripts/tests/shopify-which-theme.tests.ps1 measures it.

    No Set-StrictMode here: dot-sourcing would change the strict mode of the calling script.
    Pure ASCII (repo convention for .ps1).
#>

# The three parameters the Shopify admin itself hangs on a preview link. Without them the preview
# hangs on the cookie alone and is lost at the first internal link. A fact about Shopify's preview,
# identical in every store, so deliberately not a seam answer.
$script:WhichThemePreviewExtra = '_ab=0&_fd=0&_sc=1'

function Add-Query {
    <# Append a query string to a URL, with '?' or '&' as the URL needs. #>
    param([string]$Target, [string]$Query)
    if (-not $Query) { return $Target }
    # .Contains and not `-like '*?*'`: in -like the ? is a WILDCARD for any one character, so that test
    # is true for every non-empty string. It produced an '&' where a '?' belonged -- a URL that looks
    # right and does nothing.
    $sep = if ($Target.Contains('?')) { '&' } else { '?' }
    return "$Target$sep$Query"
}

function Get-ProbeUrl {
    <# The URL actually requested: the target plus the preview parameters and/or a cache buster. #>
    param(
        [string]$Target,
        [string]$ThemeId,
        [switch]$NoCache,
        [string]$CacheBuster = ''
    )
    $out = $Target
    if ($ThemeId) { $out = Add-Query -Target $out -Query "preview_theme_id=$ThemeId&$($script:WhichThemePreviewExtra)" }
    if ($NoCache) {
        if (-not $CacheBuster) { $CacheBuster = [guid]::NewGuid().ToString('N').Substring(0, 12) }
        $out = Add-Query -Target $out -Query "cachebust=$CacheBuster"
    }
    return $out
}

function Get-MarketRowValue {
    <# One field of a market row, whether the seam answered a hashtable or an object. #>
    param($Row, [string]$Name)
    if ($null -eq $Row) { return $null }
    if ($Row -is [System.Collections.IDictionary]) { return $Row[$Name] }
    $prop = $Row.PSObject.Properties[$Name]
    if ($prop) { return $prop.Value }
    return $null
}

function Get-ProbeTargets {
    <#
        The (label, target) pairs to fetch, as a plain array (callers wrap the call in @() anyway: a
        single unrolled object has no .Count in Windows PowerShell 5.1).

        -Url gives one row per URL. Otherwise every path is crossed with every market row from the
        store's own Get-StorefrontMarkets seam: rows with Market, Domain and an optional PathPrefix. The
        URL is https://<Domain><PathPrefix><path>. Throws a message naming the way out when there is
        nothing to build from.
    #>
    param(
        [string[]]$Url,
        [string[]]$Path = @('/'),
        [object[]]$Markets
    )
    $list = [System.Collections.Generic.List[object]]::new()
    if ($Url) {
        foreach ($u in $Url) { $list.Add([pscustomobject]@{ Label = $u; Target = $u }) }
        return $list.ToArray()
    }
    $rows = @($Markets | Where-Object { $_ })
    if ($rows.Count -eq 0) {
        throw ("-Path needs the store's market table, and this repo has not answered it. Add " +
               "Get-StorefrontMarkets to scripts/repo-config.ps1 (rows with Market, Domain and PathPrefix), " +
               "or pass full addresses with -Url.")
    }
    foreach ($p in $Path) {
        $clean = if ($p.StartsWith('/')) { $p } else { "/$p" }
        foreach ($row in $rows) {
            $market = [string](Get-MarketRowValue -Row $row -Name 'Market')
            $domain = [string](Get-MarketRowValue -Row $row -Name 'Domain')
            $prefix = [string](Get-MarketRowValue -Row $row -Name 'PathPrefix')
            if (-not $market) { throw "a market row has no Market label." }
            if (-not $domain) { throw "market '$market' has no Domain." }
            if ($domain -match '^[a-zA-Z][a-zA-Z0-9+.-]*://' -or $domain.EndsWith('/')) {
                throw "market '$market' has Domain '$domain'; it must be a bare host with no scheme and no trailing slash."
            }
            $target = if ($clean -eq '/' -and $prefix) { "https://$domain$prefix" } else { "https://$domain$prefix$clean" }
            $list.Add([pscustomobject]@{
                Label  = ("{0,-3} {1}" -f $market.ToUpper(), $clean)
                Target = $target
            })
        }
    }
    return $list.ToArray()
}

function Test-BotProtection {
    <# True when the HTML is a bot-protection challenge, which is valid HTML but not the page. #>
    param([string]$Html)
    return [bool]($Html -match 'Verifying your connection' -or $Html -match '_cf_chl_opt')
}

function Get-ServedTheme {
    <# The theme id and name Shopify embedded in the HTML ("theme":{"id":...,"name":"..."}), '' when absent. #>
    param([string]$Html)
    [pscustomobject]@{
        Id   = ([regex]::Match($Html, '"theme"\s*:\s*\{\s*"id"\s*:\s*(\d+)')).Groups[1].Value
        Name = ([regex]::Match($Html, '"theme"\s*:\s*\{[^}]*?"name"\s*:\s*"([^"]*)"')).Groups[1].Value
    }
}

function Test-Fingerprint {
    <# One fingerprint check: Ok is true when the needle is present (Contain) or absent (NotContain). #>
    param([string]$Html, [string]$Needle, [ValidateSet('Contain', 'NotContain')][string]$Kind)
    $present = $Html.Contains($Needle)
    [pscustomobject]@{
        Needle  = $Needle
        Kind    = $Kind
        Present = $present
        Ok      = if ($Kind -eq 'Contain') { $present } else { -not $present }
    }
}
