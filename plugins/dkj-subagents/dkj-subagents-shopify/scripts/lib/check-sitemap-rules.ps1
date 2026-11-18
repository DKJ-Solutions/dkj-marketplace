<#
.SYNOPSIS
    The pure rules behind check-sitemap.ps1 (#4290): reading an XML sitemap, deriving locale and kind
    from a sub-sitemap URL, grouping the store's market rows by domain, the rate-limit backoff, the
    catalogue paging, and the comparisons the report is built from. No real network, no repo access.

.DESCRIPTION
    Dot-source this file after which-theme-rules.ps1 (Get-MarketRowValue, Test-BotProtection). Split out of
    the script because the script crawls a store and a suite must not reach one, so everything that can
    be wrong without a network lives here, where scripts/tests/shopify-check-sitemap.tests.ps1 measures it.
    The two functions that DO fetch (Invoke-BodyWithBackoff, Get-CatalogHandles) take the fetcher as a
    scriptblock, so the suite drives them with a fake one.

    No Set-StrictMode here: dot-sourcing would change the strict mode of the calling script.
    Pure ASCII (repo convention for .ps1).
#>

# Shopify cuts products.json (and the other public JSON lists) off at page * limit <= 25000 and answers
# above that with HTTP 400. The number is a constant because it is the reason a big catalogue cannot be a
# reference list; if Shopify moves the limit, that conclusion moves with it.
$script:PublicJsonCeiling = 25000

function Get-SitemapLocs {
    <#
    .SYNOPSIS
        The <loc> values of a sitemap or sitemap index, with the XML entities decoded.
    .NOTES
        THE DECODING IS NOT TIDINESS. The index carries its sub-sitemaps as
        'sitemap_products_1.xml?from=123&amp;to=456'. Fetched undecoded, that is a URL with a literal
        '&amp;' in it; Shopify ignores the unknown parameter and answers with a DIFFERENT sitemap than
        the one meant -- HTTP 200, valid XML, wrong content, and a report that counts on over it.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Xml)
    $out = [System.Collections.Generic.List[string]]::new()
    foreach ($m in [regex]::Matches($Xml, '(?is)<loc>\s*(.*?)\s*</loc>')) {
        $out.Add([System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value))
    }
    return $out.ToArray()
}

function Get-SitemapFacts {
    <#
    .SYNOPSIS
        Locale, kind, file name and a display label for a sub-sitemap URL.
    .NOTES
        Locale is the path part BEFORE the file name ('/en/sitemap_products_1.xml' -> 'en'); the main
        locale has none and is called '(root)'. Kind is the middle of the file name; a name without a
        number ('sitemap_agentic_discovery.xml') keeps its whole kind.

        Label is what the report shows for "in which sitemap": the file name alone is NOT unique within
        a domain ('/sitemap_products_1.xml' and '/en/sitemap_products_1.xml' share it), so a locale
        sitemap is labelled 'en/sitemap_products_1.xml'.
    #>
    param([Parameter(Mandatory = $true)][string]$Url)
    $path = ([uri]$Url).AbsolutePath
    $file = $path.Substring($path.LastIndexOf('/') + 1)
    $dir = $path.Substring(0, $path.LastIndexOf('/')).Trim('/')
    $localeName = if ($dir) { $dir } else { '(root)' }

    $kind = 'other'
    $km = [regex]::Match($file, '^sitemap_(.+?)(_\d+)?\.xml$')
    if ($km.Success) { $kind = $km.Groups[1].Value }

    $label = if ($dir) { "$dir/$file" } else { $file }
    [pscustomobject]@{ Url = $Url; Locale = $localeName; Kind = $kind; File = $file; Label = $label }
}

function Get-UrlPath {
    <# The path of a URL, percent-decoded, so it compares against a handle read from JSON. #>
    param([Parameter(Mandatory = $true)][string]$Url)
    $p = ([uri]$Url).AbsolutePath
    # A handle with an accent is raw in the JSON and percent-encoded in the sitemap; without the decode
    # every such item reads as "missing from the sitemap", a finding that looks like a find.
    try { return [uri]::UnescapeDataString($p) } catch { return $p }
}

function Get-DomainGroups {
    <#
    .SYNOPSIS
        The store's market rows grouped by Domain (case-insensitive), in the order the store lists them.
    .NOTES
        WHY BY DOMAIN. Shopify serves ONE sitemap index per domain, at /sitemap.xml, and puts every locale
        of that domain in it: a market with a PathPrefix (one domain, locale prefixes) has no sitemap of
        its own, it shares the domain's. So the unit that is fetched is the domain, and a market is
        attributed to a locale of it afterwards (Get-MarketsForLocale). A store with a domain per market
        simply gets one group per row.

        Each group is { Domain, Markets (labels), Rows (Market + Locale) }; Locale is '(root)' for an
        empty PathPrefix and the prefix without slashes otherwise. Throws on a row without Market or
        Domain, or with a Domain that is not a bare host (the same refusal Get-ProbeTargets makes).
    #>
    param([object[]]$Rows)
    $groups = [ordered]@{}
    foreach ($row in @($Rows | Where-Object { $_ })) {
        $market = [string](Get-MarketRowValue -Row $row -Name 'Market')
        $domain = [string](Get-MarketRowValue -Row $row -Name 'Domain')
        $prefix = [string](Get-MarketRowValue -Row $row -Name 'PathPrefix')
        if (-not $market) { throw 'a market row has no Market label.' }
        if (-not $domain) { throw "market '$market' has no Domain." }
        if ($domain -match '^[a-zA-Z][a-zA-Z0-9+.-]*://' -or $domain.EndsWith('/')) {
            throw "market '$market' has Domain '$domain'; it must be a bare host with no scheme and no trailing slash."
        }
        $key = $domain.ToLowerInvariant()
        if (-not $groups.Contains($key)) {
            $groups[$key] = [pscustomobject]@{
                Domain  = $domain
                Markets = [System.Collections.Generic.List[string]]::new()
                Rows    = [System.Collections.Generic.List[object]]::new()
            }
        }
        $loc = $prefix.Trim().Trim('/')
        if (-not $loc) { $loc = '(root)' }
        $groups[$key].Markets.Add($market)
        $groups[$key].Rows.Add([pscustomobject]@{ Market = $market; Locale = $loc })
    }
    return @($groups.Values)
}

function Get-MarketsForLocale {
    <# The market label(s) of a domain group that sit on this locale, joined by '/'; '' when none does. #>
    param([Parameter(Mandatory = $true)]$Group, [Parameter(Mandatory = $true)][string]$Locale)
    $hit = @($Group.Rows | Where-Object { $_.Locale -ieq $Locale } | ForEach-Object { $_.Market })
    return ($hit -join '/')
}

function Get-RetryWaitSeconds {
    <# The wait before retry number $Attempt (1-based) after a rate limit: 5, 15, 45, 135 seconds. #>
    param([Parameter(Mandatory = $true)][int]$Attempt)
    return [int](5 * [Math]::Pow(3, $Attempt - 1))
}

function Invoke-BodyWithBackoff {
    <#
    .SYNOPSIS
        Fetch a URL as text through -Fetch, retrying a rate limit with a growing wait. Throws when it
        does not work out after all attempts.
    .PARAMETER Fetch
        Scriptblock taking the URL and returning { Status (0 = no HTTP response), Body, Message }.
    .NOTES
        THE BACKOFF IS NOT TIDINESS, IT IS THE CONDITION FOR BEING ABLE TO RUN THIS AT ALL. Measured on a
        store with ~200 sitemaps, unthrottled: 19 sitemaps came in, then 188 times HTTP 429 with the
        bot-protection page. A complete report exists only if the crawl paces itself.

        A bot-protection page that arrives with HTTP 200 counts as a 429 too: it is valid HTML, and
        without that rule it would pass as an empty sitemap -- zero URLs, no error, a report that
        counts on.

        -Sleep, -Pause and -OnWait are injectable so a suite can run the whole schedule without waiting.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][scriptblock]$Fetch,
        [int]$MaxRetries = 4,
        [int]$DelayMs = 0,
        [scriptblock]$Sleep = { param($Seconds) Start-Sleep -Seconds $Seconds },
        [scriptblock]$Pause = { param($Milliseconds) Start-Sleep -Milliseconds $Milliseconds },
        [scriptblock]$OnWait
    )
    $attempt = 0
    while ($true) {
        $r = & $Fetch $Url
        $limited = ($r.Status -eq 429) -or ($r.Status -eq 200 -and (Test-BotProtection -Html ([string]$r.Body)))
        if ($r.Status -eq 200 -and -not $limited) {
            if ($DelayMs -gt 0) { & $Pause $DelayMs }
            return [string]$r.Body
        }
        if (-not $limited) {
            if ($r.Status -eq 0) { throw "no HTTP response for $Url ($($r.Message))" }
            throw "HTTP $($r.Status) for $Url"
        }
        if ($attempt -ge $MaxRetries) {
            throw ("HTTP 429 - Shopify bot protection / rate limit, still there after {0} retry(ies). Raise -DelayMs, or measure again later." -f $MaxRetries)
        }
        $attempt++
        $wait = Get-RetryWaitSeconds -Attempt $attempt
        if ($OnWait) { & $OnWait $wait $attempt $MaxRetries }
        & $Sleep $wait
    }
}

function Get-CatalogKinds {
    <# The public storefront lists a sitemap is compared against: name, endpoint, JSON key, URL prefix. #>
    return @(
        @{ Name = 'products'; Endpoint = 'products.json'; Key = 'products'; Prefix = '/products/' },
        @{ Name = 'collections'; Endpoint = 'collections.json'; Key = 'collections'; Prefix = '/collections/' },
        @{ Name = 'pages'; Endpoint = 'pages.json'; Key = 'pages'; Prefix = '/pages/' }
    )
}

function Get-CatalogHandles {
    <#
    .SYNOPSIS
        All handles of a public JSON list, page by page, through -GetBody (a scriptblock taking a URL and
        returning the JSON text). Reports whether the list was cut off at the 25000 ceiling.
    .NOTES
        Stops on an empty page AND at the ceiling, and says so when it hits it: a cut-off list passing
        for complete would report every item after the cut as missing from the sitemap.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Domain,
        [Parameter(Mandatory = $true)][string]$Endpoint,
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(Mandatory = $true)][scriptblock]$GetBody
    )
    $handles = [System.Collections.Generic.List[string]]::new()
    $limit = 250
    $page = 1
    $truncated = $false
    while ($true) {
        if (($page * $limit) -gt $script:PublicJsonCeiling) { $truncated = $true; break }
        $json = & $GetBody ("https://{0}/{1}?limit={2}&page={3}" -f $Domain, $Endpoint, $limit, $page)
        $data = $json | ConvertFrom-Json
        $items = @($data.$Key)
        if ($items.Count -eq 0) { break }
        foreach ($i in $items) { $handles.Add([string]$i.handle) }
        $page++
    }
    [pscustomobject]@{ Handles = $handles.ToArray(); Truncated = $truncated }
}

function Compare-CatalogToSitemap {
    <#
    .SYNOPSIS
        Both directions of catalogue against sitemap for one kind: in the catalogue but not in the
        sitemap (the real gap), and in the sitemap but not in the catalogue (a removed or unpublished
        item that lingers). Paths are compared under -Prefix only.
    #>
    param(
        [string[]]$CatalogPaths,
        [string[]]$SitemapPaths,
        [Parameter(Mandatory = $true)][string]$Prefix
    )
    $cat = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($p in @($CatalogPaths)) { [void]$cat.Add($p) }
    $map = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($p in @($SitemapPaths)) { if ($p.StartsWith($Prefix)) { [void]$map.Add($p) } }
    [pscustomobject]@{
        CatalogCount = $cat.Count
        SitemapCount = $map.Count
        Missing      = @($cat | Where-Object { -not $map.Contains($_) } | Sort-Object)
        Extra        = @($map | Where-Object { -not $cat.Contains($_) } | Sort-Object)
    }
}

function Test-RobotsNoindex {
    <# True when the HTML carries a robots meta tag with noindex. #>
    param([string]$Html)
    return [bool]([regex]::IsMatch($Html, '(?is)<meta[^>]+name\s*=\s*["'']robots["''][^>]*noindex'))
}

function Get-DuplicateUrls {
    <# The URLs that sit in more than one sitemap, sorted. -Where maps url -> list of sitemap labels. #>
    param([Parameter(Mandatory = $true)][hashtable]$Where)
    return @($Where.Keys | Where-Object { $Where[$_].Count -gt 1 } | Sort-Object)
}

function Get-LocaleKindRows {
    <#
    .SYNOPSIS
        The cross-locale comparison: per kind, the URL count in every locale and a verdict.
    .PARAMETER Counts
        Hashtable "locale<TAB>kind" -> URL count.
    .PARAMETER Locales
        The locales measured.
    .NOTES
        THIS COMPARES COUNTS PER KIND, NOT PATHS, and that is a correction from a measurement. Shopify
        TRANSLATES the handle per locale, so '/products/x-orange' and '/en/products/x-strap-orange' are
        one product under two names, and the sitemap carries no hreflang alternate to pair them (measured:
        no 'xhtml:link' in a <url> block). Putting paths side by side reported ~200,000 'missing' paths
        on a sitemap with nothing wrong. A count is translation-independent: a product missing from one
        locale lowers that locale's count whatever its handle is.

        A kind present in at most ONE locale is not a gap (an '/agents.md' discovery sitemap is
        locale-less and should exist once); State says so. Otherwise State is Equal or Differs, and
        Difference is max minus min.
    #>
    param([Parameter(Mandatory = $true)][hashtable]$Counts, [Parameter(Mandatory = $true)][string[]]$Locales)
    $sorted = @($Locales | Sort-Object)
    $kinds = @($Counts.Keys | ForEach-Object { $_.Split("`t")[1] } | Sort-Object -Unique)
    $rows = [System.Collections.Generic.List[object]]::new()
    foreach ($kind in $kinds) {
        $perLocale = [ordered]@{}
        foreach ($loc in $sorted) {
            $k = "$loc`t$kind"
            $perLocale[$loc] = $(if ($Counts.ContainsKey($k)) { $Counts[$k] } else { 0 })
        }
        $values = @($perLocale.Values)
        $present = @($values | Where-Object { $_ -gt 0 }).Count
        $state = 'Equal'
        $difference = 0
        if ($present -le 1) { $state = 'LocaleLess' }
        elseif (@($values | Sort-Object -Unique).Count -gt 1) {
            $state = 'Differs'
            $difference = ($values | Measure-Object -Maximum).Maximum - ($values | Measure-Object -Minimum).Minimum
        }
        $line = ($sorted | ForEach-Object { "{0} {1}" -f $_, $perLocale[$_] }) -join '  |  '
        $rows.Add([pscustomobject]@{ Kind = $kind; Line = $line; State = $state; Difference = $difference })
    }
    return $rows.ToArray()
}
