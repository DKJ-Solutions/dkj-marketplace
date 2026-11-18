<#
.SYNOPSIS
    Report the layout of a store's Shopify sitemap per domain and market: how many sitemaps there are
    and why, which sitemap holds a URL, whether a URL sits in two, and what the catalogue has that the
    sitemap does not.

.DESCRIPTION
    Shopify generates the sitemap index itself, splits product sitemaps at 1,000 URLs and puts every
    locale of a domain in the same index. There is no theme file or setting to change that, so this
    script does not make the sitemap shorter; it makes it VISIBLE and checks it for mistakes.

    Read-only: it fetches public storefront URLs and writes nothing to the store. No Shopify CLI, no
    theme, no push.

    WHAT IT REPORTS

      1. The INDEX per domain, split by locale and kind, with the reason next to the number.
      2. Per locale the URL count, the unique count and every DUPLICATE: a URL that sits in more than
         one sitemap, with the sitemaps.
      3. The difference BETWEEN LOCALES of one domain, as a COUNT PER KIND. This is the only
         completeness check that says anything at product level, and it deliberately compares no paths:
         Shopify TRANSLATES the handle per locale, so '/products/x-orange' and '/en/products/x-strap-orange'
         are one product under two names, and the sitemap carries no hreflang alternate to pair them.
         Measured on a full crawl (211 sitemaps, 205,499 URLs): putting the paths side by side reported
         ~200,000 'missing' paths on a sitemap with nothing wrong, and the exit code could never go
         green. A count per kind is translation-independent.
      4. With -Catalog: the catalogue against the sitemap (products, collections, pages, read from the
         public products.json, collections.json and pages.json), in both directions: in the catalogue
         but not in the sitemap (the real gap), and in the sitemap but not in the catalogue (a removed or
         unpublished item that lingers).
      5. With -Find: which sitemap holds a URL.
      6. With -CsvOut: the same answer as 5 as a file, one row per URL.

    MARKETS AND DOMAINS. The store's markets come from its Get-StorefrontMarkets seam (rows with Market,
    Domain and optional PathPrefix), read by the same reader which-theme and check-jsonld use. Shopify
    serves ONE sitemap index per domain, so rows that share a Domain (one domain with locale prefixes)
    share one /sitemap.xml: this script groups the selected rows by Domain, fetches each index once, and
    attributes a locale of that index to a market by its PathPrefix ('(root)' is the row without a
    prefix, 'en' the row with '/en'). The report is per domain; the CSV and the locale lines name the
    market that sits on a locale. A locale no market row names is still reported, with no market.
    -Market picks the domains to measure, it does not narrow the locales of a shared domain: use
    -Locale for that.

    A NOINDEX PAGE IS CHECKED BEFORE IT COUNTS AS MISSING. Shopify leaves a noindex page out of the
    sitemap on purpose, so its absence is the right state, not a gap. Measured: the only two of 81
    catalogue pages missing from a sitemap both carried a robots noindex.

    WHY A BIG PRODUCT CATALOGUE CANNOT BE THE REFERENCE LIST. Shopify cuts the public JSON lists off at
    page * limit <= 25,000 and answers above that with HTTP 400 ('Page * Limit exceeds the 25000
    limit.'). A comparison on the first 25,000 would produce a list of 'missing' products that merely
    says where the limit is, and that is the dangerous kind of result: it looks complete. So when a list
    is cut off the comparison for that kind is skipped and the output says so, instead of comparing half.
    Articles are not compared either: no public endpoint lists them. The locale difference (3) is what
    remains for those, and it is complete at product level.

    MIND THE INVOCATION FORM. `powershell -File <script> -Market A,B` binds the WHOLE list as ONE string:
    with -File every argument is a bare string and PowerShell does not split on commas. This script
    splits itself (Expand-CommaList from scripts/lib/comma-list.ps1).

    RATE LIMIT, MEASURED. A full run over a large index fetches 200+ sitemaps (~80 MB). Unthrottled,
    Shopify pinches: the first 19 sitemaps came in, the next 188 gave HTTP 429 with the bot-protection
    page. So the script paces itself (-DelayMs 500) and retries a 429 with a growing wait
    (-MaxRetries, 5s, 15s, 45s, 135s). If a domain stays stuck it STOPS that domain after -AbortAfter
    consecutive failures instead of printing two hundred identical lines.

    AN INCOMPLETE RUN DRAWS NO CONCLUSION. The first measurement reported 'DUPLICATES: none' over a crawl
    in which 188 of 207 sitemaps were never fetched. 'None found' and 'none' are not the same, and the
    difference is exactly what a reader of a report cannot see. As soon as one sitemap is missing, every
    conclusion below carries INCOMPLETE and the green outcome is withheld.

    Exit code 1 on a fetch failure, a duplicate, a locale difference or (with -Catalog) a catalogue item
    missing from the sitemap. Otherwise 0.

    Moved here from a store repo (#4290).

.PARAMETER Market
    Markets to measure (the Market labels of the store's Get-StorefrontMarkets rows, case-insensitive);
    their domains are fetched, once each. Default: all. A comma separates markets, also inside one argument.

.PARAMETER Locale
    Limit to one or more locales of the index, e.g. 'en'. The main locale without a path prefix is
    called '(root)'. Default: every locale the index carries.

.PARAMETER Find
    One or more search terms. Reports which sitemap(s) hold a URL containing the term (case-insensitive).
    A whole URL is fine, so is a handle.

.PARAMETER Catalog
    Compare the sitemap with the catalogue (products.json, collections.json, pages.json) of the main
    locale. See the description for what cannot be compared.

.PARAMETER IndexOnly
    Fetch and split only the sitemap index; leave the sub-sitemaps unread. One request per domain
    instead of 200+.

.PARAMETER CsvOut
    Write the full URL-to-sitemap table as CSV (columns: Domain, Market, Locale, Kind, Url, Sitemap).

.PARAMETER SaveTo
    Folder to keep the fetched XML in, for closer inspection.

.PARAMETER DelayMs
    Pause between two requests, in milliseconds. Default 500: unthrottled, Shopify pinches after about
    twenty requests.

.PARAMETER MaxRetries
    How often an HTTP 429 is retried, with a growing wait. Default 4. At 0 every 429 is a fetch failure.

.PARAMETER AbortAfter
    Stop a domain after this many CONSECUTIVE failed sitemaps. Default 5. 0 disables the stop.

.PARAMETER PlanOnly
    Print the index URLs this script would fetch, then stop. Touches no network. Meant for checking the
    invocation form before measuring.

.PARAMETER RootOverride
    A fixture root for the seam read; a consumer never types it.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-sitemap.ps1 -IndexOnly

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-sitemap.ps1 -Market NL -Catalog -CsvOut sitemap-nl.csv

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-sitemap.ps1 -Find 'some-product-handle'

.NOTES
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI, so a
    literal non-ASCII character in the source would be decoded wrongly.

    No native exe here, so no stderr trap: everything goes through Invoke-WebRequest, with one web
    session for the whole run so cookies survive the redirects Shopify sends.
#>
[CmdletBinding()]
param(
    [string[]]$Market,
    [string[]]$Locale,
    [string[]]$Find,
    [switch]$Catalog,
    [switch]$IndexOnly,
    [string]$CsvOut,
    [string]$SaveTo,
    [int]$DelayMs = 500,
    [int]$MaxRetries = 4,
    [int]$AbortAfter = 5,
    [switch]$PlanOnly,
    [string]$RootOverride = ''
)
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\command-probe-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\fetch-failure.ps1')
. (Join-Path $PSScriptRoot '..\lib\which-theme-rules.ps1')
. (Join-Path $PSScriptRoot '..\lib\storefront-markets-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\comma-list.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-sitemap-rules.ps1')

# One web session for the whole run: cookies Shopify sets survive its redirects.
$script:WebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

function Show {
    <# A console line whose text may carry server or store-config text: it goes through the prose guard. #>
    param([string]$Text, [string]$Color = '')
    $t = Format-SafeProseToken -Value $Text -MaxLength 1000
    if ($Color) { Write-Host $t -ForegroundColor $Color } else { Write-Host $t }
}

function Safe {
    <# One foreign value (server or store-config text) made safe to embed in a padded column line. #>
    param([AllowEmptyString()][string]$Value)
    return (Format-SafeProseToken -Value $Value -MaxLength 200)
}

function Invoke-SitemapFetch {
    <#
        One request, never throwing: { Status, Body, Message }. Status is the HTTP status, or 0 when
        there was no response. A 4xx/5xx throws in Invoke-WebRequest, so the status is read from the
        failure evidence; that is also how a 429 reaches the backoff instead of passing as empty content.
    #>
    param([Parameter(Mandatory = $true)][string]$Url)
    try {
        $resp = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 120 -WebSession $script:WebSession
        $body = $resp.Content
        if ($body -is [byte[]]) { $body = [System.Text.Encoding]::UTF8.GetString($body) }
        return [pscustomobject]@{ Status = [int]$resp.StatusCode; Body = [string]$body; Message = '' }
    }
    catch {
        $evidence = Get-FetchFailureEvidence -ErrorRecord $_ -Url $Url
        $status = if ($null -ne $evidence.StatusCode) { [int]$evidence.StatusCode } else { 0 }
        return [pscustomobject]@{ Status = $status; Body = ''; Message = $_.Exception.Message }
    }
}

function Get-Body {
    <# A URL as text, with backoff on a rate limit; throws when it does not work out. #>
    param([Parameter(Mandatory = $true)][string]$Url)
    Invoke-BodyWithBackoff -Url $Url -Fetch { param($u) Invoke-SitemapFetch -Url $u } `
        -MaxRetries $MaxRetries -DelayMs $DelayMs `
        -OnWait { param($wait, $attempt, $max) Show ("    rate limit -- waiting {0}s and trying again (attempt {1}/{2})" -f $wait, $attempt, $max) 'DarkGray' }
}

function Test-PathIsNoindex {
    <# $true, $false, or $null when the page could not be fetched. Only called for the (short) missing list. #>
    param([Parameter(Mandatory = $true)][string]$Domain, [Parameter(Mandatory = $true)][string]$Path)
    try { $html = Get-Body -Url ("https://{0}{1}" -f $Domain, $Path) }
    catch { return $null }
    return (Test-RobotsNoindex -Html $html)
}

# -- Pick the markets, group them by domain -----------------------------------------------------------
$repoRoot = Resolve-RepoRootOrFail -Override $RootOverride -ScriptName 'check-sitemap.ps1' -OverrideName '-RootOverride'
$allMarkets = @(Get-StorefrontMarketRows -RepoRoot ([string]$repoRoot))
if ($allMarkets.Count -eq 0) {
    Write-Host ("REFUSED: check-sitemap needs the store's market table, and this repo has not answered it. Add " +
        "Get-StorefrontMarkets to scripts/repo-config.ps1 (rows with Market, Domain and PathPrefix).") -ForegroundColor Red
    exit 1
}
try {
    # -Market carries the same comma trap, so it is split here too.
    $wanted = if ($Market) { @(Expand-CommaList -Value $Market) } else { @() }
    $rows = @(Select-MarketRows -Markets $allMarkets -Market $wanted)
    $groups = @(Get-DomainGroups -Rows $rows)
    # Attribution of a locale to a market uses EVERY row of the store, not just the selected ones: -Market
    # picks the domains, and a shared domain's other locales still belong to their own markets.
    $attribution = @{}
    foreach ($ag in @(Get-DomainGroups -Rows $allMarkets)) { $attribution[$ag.Domain.ToLowerInvariant()] = $ag }
}
catch {
    Write-Host "REFUSED: $(Format-SafeProseToken -Value $_.Exception.Message -MaxLength 500)" -ForegroundColor Red
    exit 1
}
$localeFilter = if ($Locale) { @(Expand-CommaList -Value $Locale) } else { @() }
$needles = if ($Find) { @(Expand-CommaList -Value $Find) } else { @() }

if ($PlanOnly) {
    Write-Host ("{0} index(es):" -f $groups.Count) -ForegroundColor Cyan
    foreach ($g in $groups) {
        Show ("  {0}  ->  https://{1}/sitemap.xml" -f ($g.Markets -join ', '), $g.Domain)
    }
    if ($localeFilter.Count -gt 0) { Show ("  locale filter: {0}" -f ($localeFilter -join ', ')) }
    if ($needles.Count -gt 0) { Show ("  search terms : {0}" -f ($needles -join ', ')) }
    Write-Host ""
    Write-Host "-PlanOnly: nothing fetched." -ForegroundColor DarkGray
    exit 0
}

if ($SaveTo -and -not (Test-Path -LiteralPath $SaveTo)) { New-Item -ItemType Directory -Path $SaveTo | Out-Null }

$findings = 0
$csvRows = [System.Collections.Generic.List[object]]::new()

foreach ($grp in $groups) {
    $domain = $grp.Domain
    $label = ($grp.Markets -join ', ')
    $fileKey = ($domain -replace '[^\w\.\-]', '_')
    Write-Host ""
    Show ("===== {0}  ({1})" -f $label, $domain) 'Cyan'

    try { $indexXml = Get-Body -Url ("https://{0}/sitemap.xml" -f $domain) }
    catch { Show ("  fetching the index failed: {0}" -f $_.Exception.Message) 'Red'; $findings++; continue }
    if ($SaveTo) { Set-Content -LiteralPath (Join-Path $SaveTo "$fileKey-sitemap.xml") -Value $indexXml -Encoding UTF8 }

    $subs = @(Get-SitemapLocs -Xml $indexXml | ForEach-Object { Get-SitemapFacts -Url $_ })

    # --- 1. The index, split --------------------------------------------------------------------
    Write-Host ""
    Write-Host ("  INDEX: {0} sub-sitemaps" -f $subs.Count) -ForegroundColor White
    foreach ($g in ($subs | Group-Object Locale, Kind | Sort-Object Name)) {
        $first = $g.Group[0]
        Write-Host ("    {0,-8} {1,-20} {2,4}" -f (Safe $first.Locale), (Safe $first.Kind), $g.Count)
    }
    $locales = @($subs | ForEach-Object { $_.Locale } | Sort-Object -Unique)
    if ($locales.Count -gt 1) {
        Write-Host ("    -> this index carries {0} locales of one domain: {1}" -f $locales.Count, ($locales -join ', ')) -ForegroundColor DarkGray
    }
    foreach ($loc in $locales) {
        $mk = Get-MarketsForLocale -Group $attribution[$domain.ToLowerInvariant()] -Locale $loc
        if ($mk) { Write-Host ("       {0,-8} is market {1}" -f (Safe $loc), (Safe $mk)) -ForegroundColor DarkGray }
    }

    if ($localeFilter.Count -gt 0) {
        $unknown = @($localeFilter | Where-Object { $locales -notcontains $_ })
        if ($unknown.Count -gt 0) {
            Show ("Unknown locale(s) '{0}' for {1}. Known: {2}." -f ($unknown -join ', '), $domain, ($locales -join ', ')) 'Red'
            exit 1
        }
        $subs = @($subs | Where-Object { $localeFilter -contains $_.Locale })
        Write-Host ("    (locale filter active: {0} sub-sitemaps remain)" -f $subs.Count) -ForegroundColor DarkGray
    }

    if ($IndexOnly) {
        Write-Host ""
        Write-Host "  -IndexOnly: the sub-sitemaps were not read." -ForegroundColor DarkGray
        continue
    }

    # --- 2. Walk the sub-sitemaps ---------------------------------------------------------------
    # url -> sitemap labels it sits in. A hashtable and not Group-Object over the whole list: at
    # ~200,000 URLs that is the difference between seconds and minutes.
    $where = @{}
    $perLocale = @{}
    # "locale<TAB>kind" -> URL count: what the cross-locale check stands on.
    $perLocaleKind = @{}
    $n = 0
    $failed = 0
    $inARow = 0
    $aborted = $false
    foreach ($s in $subs) {
        $n++
        Write-Progress -Activity "$domain sitemaps" -Status $s.Label -PercentComplete ([int](100 * $n / [Math]::Max(1, $subs.Count)))
        try { $xml = Get-Body -Url $s.Url }
        catch {
            Show ("  {0} fetch failed: {1}" -f $s.Label, $_.Exception.Message) 'Red'
            $findings++; $failed++; $inARow++
            if ($AbortAfter -gt 0 -and $inARow -ge $AbortAfter) {
                $failed += ($subs.Count - $n)
                Show ("  {0} failures in a row -- this domain is aborted; {1} sitemap(s) remain unread." -f $inARow, ($subs.Count - $n)) 'Red'
                $aborted = $true
                break
            }
            continue
        }
        $inARow = 0
        if ($SaveTo) { Set-Content -LiteralPath (Join-Path $SaveTo ("{0}-{1}" -f $fileKey, ($s.Label -replace '[^\w\.\-]', '_'))) -Value $xml -Encoding UTF8 }

        $lkKey = "$($s.Locale)`t$($s.Kind)"
        if (-not $perLocale.ContainsKey($s.Locale)) { $perLocale[$s.Locale] = [System.Collections.Generic.List[string]]::new() }
        if (-not $perLocaleKind.ContainsKey($lkKey)) { $perLocaleKind[$lkKey] = 0 }
        $marketOfLocale = if ($CsvOut) { Get-MarketsForLocale -Group $attribution[$domain.ToLowerInvariant()] -Locale $s.Locale } else { '' }
        foreach ($u in (Get-SitemapLocs -Xml $xml)) {
            if (-not $where.ContainsKey($u)) { $where[$u] = [System.Collections.Generic.List[string]]::new() }
            $where[$u].Add($s.Label)
            $perLocale[$s.Locale].Add($u)
            $perLocaleKind[$lkKey]++
            if ($CsvOut) {
                $csvRows.Add([pscustomobject]@{ Domain = $domain; Market = $marketOfLocale; Locale = $s.Locale; Kind = $s.Kind; Url = $u; Sitemap = $s.Label })
            }
        }
    }
    Write-Progress -Activity "$domain sitemaps" -Completed

    # THE INCOMPLETENESS FLAG. Everything below is a conclusion about the COLLECTED URLs, and that set
    # is complete only if every sitemap arrived. Without it a crawl in which 188 of 207 sitemaps failed
    # reports 'DUPLICATES: none' -- measured on the first run. 'Not found' is then not 'not present',
    # and nothing in the output says which of the two you are reading.
    $complete = ($failed -eq 0)
    $flag = if ($complete) { '' } else { '  [INCOMPLETE]' }
    if (-not $complete) {
        Write-Host ""
        Write-Host ("  NOTE: {0} of {1} sitemaps were NOT fetched{2}." -f $failed, $subs.Count, $(if ($aborted) { ' (aborted)' } else { '' })) -ForegroundColor Red
        Write-Host "  Every conclusion below is about PART of the sitemap and proves nothing about the whole." -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "  URLS PER LOCALE$flag" -ForegroundColor White
    foreach ($loc in ($perLocale.Keys | Sort-Object)) {
        $all = $perLocale[$loc]
        $unique = @($all | Sort-Object -Unique).Count
        Write-Host ("    {0,-8} {1,8} URLs, {2,8} unique, {3} duplicate" -f (Safe $loc), $all.Count, $unique, ($all.Count - $unique))
    }

    # --- 3. Duplicates --------------------------------------------------------------------------
    $dups = @(Get-DuplicateUrls -Where $where)
    Write-Host ""
    if ($dups.Count -eq 0 -and -not $complete) {
        Write-Host "  DUPLICATES: none found, but the crawl is INCOMPLETE -- this does not prove there are none." -ForegroundColor Red
    }
    elseif ($dups.Count -eq 0) {
        Write-Host "  DUPLICATES: none. No URL sits in more than one sitemap." -ForegroundColor Green
    }
    else {
        $findings++
        Write-Host ("  DUPLICATES: {0} URL(s) sit in more than one sitemap" -f $dups.Count) -ForegroundColor Yellow
        foreach ($d in ($dups | Select-Object -First 25)) {
            Show ("    {0}" -f $d)
            Show ("      in: {0}" -f (($where[$d] | Sort-Object) -join ', ')) 'DarkGray'
        }
        if ($dups.Count -gt 25) { Write-Host ("    ... and {0} more (use -CsvOut for the full list)" -f ($dups.Count - 25)) -ForegroundColor DarkGray }
    }

    # --- 4. The difference between the locales of one domain ------------------------------------
    # COUNTS PER KIND, NOT PATHS: see the description and Get-LocaleKindRows for the measurement.
    $measured = @($perLocale.Keys)
    if ($measured.Count -gt 1 -and -not $complete) {
        Write-Host ""
        Write-Host "  LOCALE DIFFERENCE: SKIPPED -- an unread sitemap lowers a count by definition, and that" -ForegroundColor Red
        Write-Host "  reads here as a missing item. Measure again with a higher -DelayMs." -ForegroundColor Red
    }
    elseif ($measured.Count -gt 1) {
        Write-Host ""
        Write-Host "  LOCALE DIFFERENCE (count per kind)" -ForegroundColor White
        Write-Host "    Paths are NOT comparable here: Shopify translates the handle per locale and the sitemap" -ForegroundColor DarkGray
        Write-Host "    carries no hreflang alternates, so a translated path cannot be tied to its counterpart." -ForegroundColor DarkGray
        foreach ($r in (Get-LocaleKindRows -Counts $perLocaleKind -Locales $measured)) {
            switch ($r.State) {
                'LocaleLess' { Write-Host ("    {0,-20} {1}   (locale-less -- belongs in one locale only)" -f (Safe $r.Kind), (Safe $r.Line)) -ForegroundColor DarkGray }
                'Equal' { Write-Host ("    {0,-20} {1}   equal" -f (Safe $r.Kind), (Safe $r.Line)) -ForegroundColor Green }
                default { $findings++; Write-Host ("    {0,-20} {1}   DIFFERS by {2}" -f (Safe $r.Kind), (Safe $r.Line), $r.Difference) -ForegroundColor Yellow }
            }
        }
    }

    # --- 5. Where does this URL sit? ------------------------------------------------------------
    if ($needles.Count -gt 0) {
        Write-Host ""
        Write-Host "  FOUND" -ForegroundColor White
        foreach ($needle in $needles) {
            $hits = @($where.Keys | Where-Object { $_.IndexOf($needle, [StringComparison]::OrdinalIgnoreCase) -ge 0 } | Sort-Object)
            if ($hits.Count -eq 0) {
                $why = if ($complete) { 'NOT in the sitemap of' } else { 'not found in the READ part of the sitemap of' }
                Show ("    '{0}': {1} {2}" -f $needle, $why, $domain) 'Yellow'
                $findings++
                continue
            }
            foreach ($h in ($hits | Select-Object -First 10)) {
                Show ("    {0}" -f $h) 'Green'
                Show ("      in: {0}" -f (($where[$h] | Sort-Object) -join ', ')) 'DarkGray'
            }
            if ($hits.Count -gt 10) { Show ("    ... and {0} more for '{1}'" -f ($hits.Count - 10), $needle) 'DarkGray' }
        }
    }

    # --- 6. The catalogue against the sitemap ---------------------------------------------------
    if ($Catalog -and -not $complete) {
        Write-Host ""
        Write-Host "  CATALOGUE AGAINST THE SITEMAP: SKIPPED -- with an unread sitemap every item would be" -ForegroundColor Red
        Write-Host "  reported as 'missing from the sitemap', and that is the dangerous kind of finding: it" -ForegroundColor Red
        Write-Host "  looks like a find. Measure again with a higher -DelayMs." -ForegroundColor Red
    }
    elseif ($Catalog) {
        Write-Host ""
        Write-Host "  CATALOGUE AGAINST THE SITEMAP (main locale)" -ForegroundColor White
        $rootPaths = @()
        if ($perLocale.ContainsKey('(root)')) { $rootPaths = @($perLocale['(root)'] | ForEach-Object { Get-UrlPath -Url $_ }) }

        foreach ($kind in (Get-CatalogKinds)) {
            try { $cat = Get-CatalogHandles -Domain $domain -Endpoint $kind.Endpoint -Key $kind.Key -GetBody { param($u) Get-Body -Url $u } }
            catch { Show ("    {0}: fetch failed: {1}" -f $kind.Name, $_.Exception.Message) 'Red'; $findings++; continue }

            if ($cat.Truncated) {
                # Not a finding: it is a limit of the public endpoint, and the comparison it would feed is
                # the one that looks complete and is not. Say it, do not compare half.
                Write-Host ("    {0,-12} NO reference list: cut off at the {1} limit of the public JSON endpoint, so no comparison is made" -f $kind.Name, $script:PublicJsonCeiling) -ForegroundColor DarkGray
                continue
            }

            $cmp = Compare-CatalogToSitemap -CatalogPaths @($cat.Handles | ForEach-Object { $kind.Prefix + $_ }) -SitemapPaths $rootPaths -Prefix $kind.Prefix
            Write-Host ("    {0,-12} catalogue {1,6} | sitemap {2,6} | not in sitemap {3,4} | not in catalogue {4,4}" -f $kind.Name, $cmp.CatalogCount, $cmp.SitemapCount, $cmp.Missing.Count, $cmp.Extra.Count)

            if ($cmp.Missing.Count -gt 0) {
                # Find out WHY the path is missing before counting it: a noindex page does not belong in
                # the sitemap, so its absence is the right state.
                $reallyGone = [System.Collections.Generic.List[string]]::new()
                $unknownState = [System.Collections.Generic.List[string]]::new()
                $noindex = [System.Collections.Generic.List[string]]::new()
                foreach ($p in ($cmp.Missing | Select-Object -First 25)) {
                    switch (Test-PathIsNoindex -Domain $domain -Path $p) {
                        $true { $noindex.Add($p) }
                        $false { $reallyGone.Add($p) }
                        default { $unknownState.Add($p) }
                    }
                }
                if ($cmp.Missing.Count -gt 25) { foreach ($p in ($cmp.Missing | Select-Object -Skip 25)) { $unknownState.Add($p) } }

                if ($noindex.Count -gt 0) {
                    Show ("      {0} of these carry a robots noindex and so belong OUT of the sitemap:" -f $noindex.Count) 'DarkGray'
                    foreach ($p in ($noindex | Select-Object -First 10)) { Show ("        (noindex, rightly left out) {0}" -f $p) 'DarkGray' }
                    if ($noindex.Count -gt 10) { Show ("        ... and {0} more" -f ($noindex.Count - 10)) 'DarkGray' }
                }
                if ($reallyGone.Count -gt 0) {
                    $findings++
                    foreach ($p in ($reallyGone | Select-Object -First 10)) { Show ("      missing from sitemap (indexable): {0}" -f $p) 'Yellow' }
                    if ($reallyGone.Count -gt 10) { Show ("      ... and {0} more" -f ($reallyGone.Count - 10)) 'DarkGray' }
                }
                if ($unknownState.Count -gt 0) {
                    $findings++
                    foreach ($p in ($unknownState | Select-Object -First 10)) { Show ("      missing from sitemap, noindex could NOT be determined: {0}" -f $p) 'Yellow' }
                    if ($unknownState.Count -gt 10) { Show ("      ... and {0} more" -f ($unknownState.Count - 10)) 'DarkGray' }
                }
            }
            if ($cmp.Extra.Count -gt 0) {
                foreach ($p in ($cmp.Extra | Select-Object -First 10)) { Show ("      in sitemap, not in catalogue: {0}" -f $p) 'DarkGray' }
                if ($cmp.Extra.Count -gt 10) { Show ("      ... and {0} more" -f ($cmp.Extra.Count - 10)) 'DarkGray' }
            }
        }

        # These lines are not a disclaimer but the outcome: they say what was NOT measured and why, so a
        # reader does not mistake the comparison above for complete.
        Write-Host "    articles     NO reference list: the storefront has no public endpoint that lists them." -ForegroundColor DarkGray
        Write-Host "    A cut-off list is not compared (see above); 'LOCALE DIFFERENCE' still checks the COUNT per kind," -ForegroundColor DarkGray
        Write-Host "    which catches a missing product but does not say which." -ForegroundColor DarkGray
    }
}

if ($CsvOut -and $csvRows.Count -gt 0) {
    $csvRows | Export-Csv -LiteralPath $CsvOut -NoTypeInformation -Encoding UTF8
    Write-Host ""
    Show ("CSV written: {0} ({1} rows)" -f $CsvOut, $csvRows.Count) 'Cyan'
}

Write-Host ""
if ($findings -eq 0) {
    Write-Host "No findings." -ForegroundColor Green
    exit 0
}
Write-Host ("{0} finding(s) -- see above." -f $findings) -ForegroundColor Yellow
exit 1
