<#
.SYNOPSIS
    Tests for dkj-subagents-shopify's check-sitemap: the pure rules in scripts/lib/check-sitemap-rules.ps1,
    the shared market selection and the script's invocation form (issue #4290).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell. Exit code 0 if everything passes, 1 on a failure.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/shopify-check-sitemap.tests.ps1

    No network. The script is driven only with -PlanOnly (through `powershell -File`, the form that sets
    the comma trap), and the two functions that fetch take their fetcher as a scriptblock, so a fake one
    drives the backoff and the catalogue paging.

    Why this script deserves tests, and why these: check-sitemap is a REPORT. Its result goes to a
    colleague who does not read the sitemap, so nobody catches a mistake by looking. Three things can go
    wrong silently, and each produces an outcome that looks complete:

      1. THE XML ENTITY IN THE INDEX. Shopify carries its sub-sitemaps as
         'sitemap_products_1.xml?from=1&amp;to=2'. Fetched undecoded that is HTTP 200 and valid XML --
         of ANOTHER sitemap, because Shopify ignores the unknown '&amp;to' parameter.
      2. AN INCOMPLETE CRAWL DRAWING A CONCLUSION. A first run reported 'DUPLICATES: none' over a crawl
         in which 188 of 207 sitemaps were never fetched. The flag that stops that is asserted below.
      3. WHAT THE LOCALE DIFFERENCE MAY BE. A COUNT per kind, not a path comparison: Shopify translates
         the handle per locale, so paths side by side reported the whole catalogue as a gap on a healthy
         sitemap. Both sides are guarded, because the old form does not fail, it works.

    Made-up fixtures only (this repo is public): no real store name, domain or id.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot  = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Plugin    = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify'
$Lib       = Join-Path $Plugin 'scripts\lib'
$Script    = Join-Path $Plugin 'scripts\task\check-sitemap.ps1'
$RulesLib  = Join-Path $Lib 'check-sitemap-rules.ps1'
$CommaLib  = Join-Path $Lib 'comma-list.ps1'
$MarketLib = Join-Path $Lib 'storefront-markets-lib.ps1'

. (Join-Path $Lib 'command-probe-lib.ps1')
. (Join-Path $Lib 'which-theme-rules.ps1')
. $CommaLib
. $MarketLib
. $RulesLib

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Label)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label" -ForegroundColor Red }
}
function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Write-Group { param([string]$Title) Write-Host ""; Write-Host "== $Title" -ForegroundColor Cyan }
function Get-Threw { param([scriptblock]$Block) try { & $Block | Out-Null; return $null } catch { return $_.Exception.Message } }

# A fixture store: two markets with a domain of their own, two that share one domain by locale prefix.
$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("check-sitemap-fixture-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts') -Force | Out-Null
Set-Content -LiteralPath (Join-Path $fixture 'scripts\repo-config.ps1') -Encoding ASCII -Value @'
function Get-StorefrontMarkets {
    @(
        @{ Market = 'nl'; Domain = 'shop.example.nl'; PathPrefix = '' },
        @{ Market = 'UK'; Domain = 'shop.example.co.uk'; PathPrefix = '' },
        [pscustomobject]@{ Market = 'de'; Domain = 'www.example.com'; PathPrefix = '/de' },
        [pscustomobject]@{ Market = 'FR'; Domain = 'WWW.example.com'; PathPrefix = '/fr' }
    )
}
'@
$bareFixture = Join-Path ([System.IO.Path]::GetTempPath()) ("check-sitemap-bare-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $bareFixture -Force | Out-Null

function Invoke-Target {
    param([string[]]$Arguments, [string]$Root = $fixture)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @Arguments -RootOverride $Root 2>&1
    return [pscustomobject]@{ Text = (@($out | ForEach-Object { "$_" }) -join "`n"); Code = $LASTEXITCODE }
}

try {
    Write-Group '1. the XML entity in the index'
    $indexXml = @'
<?xml version="1.0" encoding="UTF-8"?>
<sitemapindex>
  <sitemap><loc>https://shop.example.nl/sitemap_products_1.xml?from=111&amp;to=222</loc></sitemap>
  <sitemap><loc>https://shop.example.nl/en/sitemap_products_1.xml?from=1&amp;to=2</loc></sitemap>
  <sitemap><loc>https://shop.example.nl/sitemap_collections_1.xml</loc></sitemap>
</sitemapindex>
'@
    $locs = @(Get-SitemapLocs -Xml $indexXml)
    Assert-Equal 3 $locs.Count 'three sub-sitemaps from the index'
    Assert-True ($locs[0].Contains('from=111&to=222')) 'the ampersand is decoded'
    Assert-Equal 0 @($locs | Where-Object { $_ -match '&amp;' }).Count 'no URL still carries a literal &amp;'
    $l2 = @(Get-SitemapLocs -Xml "<urlset><url><loc>`n   https://shop.example.nl/pages/size-chart`n  </loc></url></urlset>")
    Assert-Equal 'https://shop.example.nl/pages/size-chart' $l2[0] 'whitespace around a <loc> does not count'
    Assert-Equal 0 @(Get-SitemapLocs -Xml '').Count 'an empty body: no locs, no error'

    Write-Group '2. locale, kind and label from a sub-sitemap URL'
    $f = Get-SitemapFacts -Url 'https://shop.example.nl/sitemap_products_1.xml?from=1&to=2'
    Assert-Equal '(root)' $f.Locale 'the main locale has no prefix: (root)'
    Assert-Equal 'products' $f.Kind 'kind products'
    Assert-Equal 'sitemap_products_1.xml' $f.File 'the query string is not part of the file name'
    Assert-Equal 'sitemap_products_1.xml' $f.Label 'a root sitemap is labelled by its file name'
    $f = Get-SitemapFacts -Url 'https://shop.example.nl/en/sitemap_products_97.xml'
    Assert-Equal 'en' $f.Locale "locale 'en'"
    Assert-Equal 'en/sitemap_products_97.xml' $f.Label 'a locale sitemap is labelled with its locale (the file name alone is not unique)'
    $f = Get-SitemapFacts -Url 'https://shop.example.nl/sitemap_agentic_discovery.xml'
    Assert-Equal 'agentic_discovery' $f.Kind 'no volume number: the whole kind survives'
    foreach ($k in @('products', 'collections', 'blogs', 'pages')) {
        Assert-Equal $k (Get-SitemapFacts -Url ("https://shop.example.nl/sitemap_{0}_1.xml" -f $k)).Kind "kind $k"
    }
    Assert-Equal ('/pages/caf' + [char]0xE9) (Get-UrlPath -Url 'https://x.example/pages/caf%C3%A9') 'a percent-encoded path is decoded (a handle in JSON is raw)'

    Write-Group '3. market rows grouped by domain'
    $rows = @(
        @{ Market = 'nl'; Domain = 'shop.example.nl'; PathPrefix = '' },
        [pscustomobject]@{ Market = 'de'; Domain = 'www.example.com'; PathPrefix = '/de' },
        [pscustomobject]@{ Market = 'FR'; Domain = 'WWW.example.com'; PathPrefix = '/fr/' },
        @{ Market = 'uk'; Domain = 'shop.example.co.uk' }
    )
    $groups = @(Get-DomainGroups -Rows $rows)
    Assert-Equal 3 $groups.Count 'four rows on three domains: three groups (one index each)'
    Assert-Equal 'shop.example.nl|www.example.com|shop.example.co.uk' (($groups | ForEach-Object { $_.Domain }) -join '|') "the store's order is kept, a domain differing only in case is one group"
    Assert-Equal 'de, FR' ($groups[1].Markets -join ', ') 'the shared domain names both markets'
    Assert-Equal 'de' (Get-MarketsForLocale -Group $groups[1] -Locale 'de') 'locale de belongs to market de'
    Assert-Equal 'FR' (Get-MarketsForLocale -Group $groups[1] -Locale 'fr') 'a prefix with a trailing slash still names locale fr'
    Assert-Equal '' (Get-MarketsForLocale -Group $groups[1] -Locale '(root)') 'a locale no market row names has no market'
    Assert-Equal 'nl' (Get-MarketsForLocale -Group $groups[0] -Locale '(root)') 'an empty prefix is the (root) locale'
    Assert-Equal 'uk' (Get-MarketsForLocale -Group $groups[2] -Locale '(root)') 'a row without a PathPrefix property is (root)'
    $r = Invoke-Target -Arguments @('-Market', 'fr,de', '-PlanOnly')
    Assert-True ($r.Code -eq 0 -and $r.Text -match '1 index\(es\):' -and $r.Text -match 'de, FR') 'two markets on one domain: one index, both named'
    Assert-True ((Get-Threw { Get-DomainGroups -Rows @(@{ Market = 'x'; Domain = 'https://a.example' }) }) -match 'bare host') 'a Domain with a scheme is refused'
    Assert-True ((Get-Threw { Get-DomainGroups -Rows @(@{ Market = 'x' }) }) -match "no Domain") 'a row without a Domain is refused'
    Assert-True ((Get-Threw { Get-DomainGroups -Rows @(@{ Domain = 'a.example' }) }) -match 'no Market label') 'a row without a Market label is refused'

    Write-Group '4. Select-MarketRows (one definition, shared with check-jsonld)'
    $sel = @(Select-MarketRows -Markets $rows -Market @('UK', 'DE'))
    Assert-Equal 2 $sel.Count 'two named markets: two rows'
    Assert-Equal 'de' (Get-MarketRowValue -Row $sel[0] -Name 'Market') "the store's own order is kept"
    Assert-Equal 4 @(Select-MarketRows -Markets $rows -Market @()).Count 'no -Market: every row'
    Assert-True ((Get-Threw { Select-MarketRows -Markets $rows -Market @('BE') }) -match "Unknown market 'BE'") 'an unknown market throws'
    $defs = @(Get-ChildItem -LiteralPath (Join-Path $Plugin 'scripts') -Recurse -Filter '*.ps1' |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Raw) -match '(?m)^\s*function\s+Select-MarketRows\b' })
    Assert-Equal 1 $defs.Count 'exactly ONE definition of Select-MarketRows in the plugin (a second one works, then drifts)'
    $defs = @(Get-ChildItem -LiteralPath (Join-Path $Plugin 'scripts') -Recurse -Filter '*.ps1' |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Raw) -match '(?m)^\s*function\s+Expand-CommaList\b' })
    Assert-Equal 1 $defs.Count 'exactly ONE definition of Expand-CommaList in the plugin'

    Write-Group '5. the backoff on a rate limit'
    Assert-Equal '5,15,45,135' ((1..4 | ForEach-Object { Get-RetryWaitSeconds -Attempt $_ }) -join ',') 'the waits grow 5, 15, 45, 135 seconds'
    $noSleep = { param($s) }
    $state = @{ calls = 0; waits = [System.Collections.Generic.List[int]]::new(); pauses = 0 }
    $okAfterTwo = { param($u) $state.calls++; if ($state.calls -le 2) { [pscustomobject]@{ Status = 429; Body = ''; Message = '' } } else { [pscustomobject]@{ Status = 200; Body = '<urlset/>'; Message = '' } } }
    $body = Invoke-BodyWithBackoff -Url 'https://x.example/a.xml' -Fetch $okAfterTwo -MaxRetries 4 -DelayMs 7 -Sleep { param($s) $state.waits.Add($s) } -Pause { param($ms) $state.pauses += $ms }
    Assert-Equal '<urlset/>' $body 'two 429s then a 200: the body comes back'
    Assert-Equal '5,15' ($state.waits -join ',') 'it waited 5 then 15 seconds'
    Assert-Equal 7 $state.pauses 'the pacing delay runs once, after the success'

    $state = @{ calls = 0 }
    $always429 = { param($u) $state.calls++; [pscustomobject]@{ Status = 429; Body = ''; Message = '' } }
    $msg = Get-Threw { Invoke-BodyWithBackoff -Url 'https://x.example/a.xml' -Fetch $always429 -MaxRetries 2 -Sleep $noSleep }
    Assert-True ($msg -match 'HTTP 429' -and $msg -match '2 retry') 'a stuck 429 throws after -MaxRetries and says so'
    Assert-Equal 3 $state.calls 'one try plus two retries'
    $state = @{ calls = 0 }
    $null = Get-Threw { Invoke-BodyWithBackoff -Url 'https://x.example/a.xml' -Fetch $always429 -MaxRetries 0 -Sleep $noSleep }
    Assert-Equal 1 $state.calls '-MaxRetries 0: every 429 is a failure at once'

    $state = @{ calls = 0 }
    $botPage = { param($u) $state.calls++; [pscustomobject]@{ Status = 200; Body = '<html>Verifying your connection...</html>'; Message = '' } }
    $msg = Get-Threw { Invoke-BodyWithBackoff -Url 'https://x.example/a.xml' -Fetch $botPage -MaxRetries 1 -Sleep $noSleep }
    Assert-True ($null -ne $msg -and $state.calls -eq 2) 'a bot-protection page served with HTTP 200 is a rate limit, not an empty sitemap'

    $state = @{ calls = 0 }
    $notFound = { param($u) $state.calls++; [pscustomobject]@{ Status = 404; Body = ''; Message = '' } }
    $msg = Get-Threw { Invoke-BodyWithBackoff -Url 'https://x.example/a.xml' -Fetch $notFound -MaxRetries 4 -Sleep $noSleep }
    Assert-True ($msg -match 'HTTP 404 for https://x.example/a.xml' -and $state.calls -eq 1) 'any other status throws at once, no retry'
    $noResp = { param($u) [pscustomobject]@{ Status = 0; Body = ''; Message = 'name not resolved' } }
    Assert-True ((Get-Threw { Invoke-BodyWithBackoff -Url 'https://x.example/a.xml' -Fetch $noResp -Sleep $noSleep }) -match 'no HTTP response.*name not resolved') 'no response throws with the reason'

    Write-Group '6. catalogue paging and the 25000 ceiling'
    $state = @{ urls = [System.Collections.Generic.List[string]]::new() }
    $pages = {
        param($u)
        $state.urls.Add($u)
        if ($u -match 'page=1$') { '{"collections":[{"handle":"a"},{"handle":"b"}]}' } else { '{"collections":[]}' }
    }
    $cat = Get-CatalogHandles -Domain 'shop.example.nl' -Endpoint 'collections.json' -Key 'collections' -GetBody $pages
    Assert-Equal 'a,b' ($cat.Handles -join ',') 'handles are collected'
    Assert-True (-not $cat.Truncated) 'an empty page ends the list: not truncated'
    Assert-Equal 'https://shop.example.nl/collections.json?limit=250&page=1' $state.urls[0] 'the first request'
    Assert-Equal 2 $state.urls.Count 'it stops on the first empty page'

    $state = @{ n = 0 }
    $endless = { param($u) $state.n++; '{"products":[{"handle":"p"}]}' }
    $cat = Get-CatalogHandles -Domain 'shop.example.nl' -Endpoint 'products.json' -Key 'products' -GetBody $endless
    Assert-True $cat.Truncated 'a list that never ends is cut at the ceiling and says so'
    Assert-Equal 100 $state.n 'page 100 * limit 250 = 25000 is the last page asked for'

    Write-Group '7. Compare-CatalogToSitemap and the noindex test'
    $c = Compare-CatalogToSitemap -CatalogPaths @('/pages/a', '/pages/b', '/pages/c') -SitemapPaths @('/pages/a', '/pages/z', '/products/q') -Prefix '/pages/'
    Assert-Equal '/pages/b,/pages/c' ($c.Missing -join ',') 'in the catalogue, not in the sitemap'
    Assert-Equal '/pages/z' ($c.Extra -join ',') 'in the sitemap, not in the catalogue (other kinds are ignored)'
    Assert-Equal '3|2' ("$($c.CatalogCount)|$($c.SitemapCount)") 'counts are per kind prefix'
    $c = Compare-CatalogToSitemap -CatalogPaths @() -SitemapPaths @() -Prefix '/pages/'
    Assert-Equal 0 ($c.Missing.Count + $c.Extra.Count) 'two empty sides: nothing missing'
    Assert-True (Test-RobotsNoindex -Html '<head><meta name="robots" content="noindex, follow"></head>') 'a robots noindex is recognised'
    Assert-True (Test-RobotsNoindex -Html "<META NAME='robots' content='NOINDEX'>") 'either quote style, any case'
    Assert-True (-not (Test-RobotsNoindex -Html '<meta name="robots" content="index, follow">')) 'index, follow is not noindex'
    Assert-True (-not (Test-RobotsNoindex -Html '<meta name="description" content="noindex">')) 'only the robots tag counts'
    Assert-Equal 1 @(Get-DuplicateUrls -Where @{ 'https://x/a' = @('s1', 's2'); 'https://x/b' = @('s1') }).Count 'a URL in two sitemaps is a duplicate'
    Assert-Equal 0 @(Get-DuplicateUrls -Where @{}).Count 'nothing collected: no duplicates'

    Write-Group '8. the locale difference counts per kind and compares no paths'
    $counts = @{
        "(root)`tproducts" = 100; "en`tproducts" = 100;
        "(root)`tcollections" = 10; "en`tcollections" = 9;
        "(root)`tagentic_discovery" = 1
    }
    $r = @(Get-LocaleKindRows -Counts $counts -Locales @('en', '(root)'))
    $by = @{}; foreach ($x in $r) { $by[$x.Kind] = $x }
    Assert-Equal 'Equal' $by['products'].State 'same count in both locales: equal'
    Assert-Equal 'Differs' $by['collections'].State 'a count that differs is flagged'
    Assert-Equal 1 $by['collections'].Difference 'by max minus min'
    Assert-Equal 'LocaleLess' $by['agentic_discovery'].State 'a kind in one locale only is not a gap'
    Assert-True ($by['products'].Line -match '\(root\) 100  \|  en 100' -or $by['products'].Line -match 'en 100  \|  \(root\) 100') 'the line shows every locale and its count'
    $zero = @(Get-LocaleKindRows -Counts @{ "(root)`tproducts" = 5 } -Locales @('(root)', 'en'))
    Assert-Equal 'LocaleLess' $zero[0].State 'a kind present in one of two locales is locale-less, not a difference of 5'

    Write-Group '9. the script through powershell -File, -PlanOnly (the comma trap)'
    $r = Invoke-Target -Arguments @('-PlanOnly')
    Assert-Equal 0 $r.Code 'no arguments: exit 0'
    Assert-True ($r.Text -match '3 index\(es\):') 'four rows on three domains: three indexes, the shared domain once'
    Assert-True ($r.Text -match 'de, FR\s+->\s+https://www\.example\.com/sitemap\.xml') 'the shared domain names both markets'
    Assert-True ($r.Text -match 'https://shop\.example\.nl/sitemap\.xml' -and $r.Text -match 'https://shop\.example\.co\.uk/sitemap\.xml') 'the other two domains'
    Assert-True ($r.Text -match 'nothing fetched' -and $r.Text -notmatch 'INDEX:') '-PlanOnly fetches nothing and prints no measurement'

    $r = Invoke-Target -Arguments @('-Market', 'nl,UK', '-PlanOnly')
    Assert-True ($r.Code -eq 0 -and $r.Text -match '2 index\(es\):') '-Market as a comma list: two indexes, not one'
    $r = Invoke-Target -Arguments @('-Market', 'de', '-PlanOnly')
    Assert-True ($r.Code -eq 0 -and $r.Text -match '1 index\(es\):' -and $r.Text -match 'de\s+->\s+https://www\.example\.com') '-Market de picks the shared domain once (-Locale narrows the locales)'
    $r = Invoke-Target -Arguments @('-Market', 'BE', '-PlanOnly')
    Assert-True ($r.Code -eq 1 -and $r.Text -match "REFUSED: Unknown market 'BE'" -and $r.Text -notmatch 'index\(es\):') 'an unknown market is refused before anything is planned'
    $r = Invoke-Target -Arguments @('-PlanOnly') -Root $bareFixture
    Assert-True ($r.Code -eq 1 -and $r.Text -match 'Get-StorefrontMarkets') 'no market table: refuses and names the seam'
    $r = Invoke-Target -Arguments @('-PlanOnly', '-Locale', 'en,fr', '-Find', 'a,b')
    Assert-True ($r.Text -match 'locale filter: en, fr' -and $r.Text -match 'search terms : a, b') '-Locale and -Find are split on commas too'

    Write-Group '10. static guards on the script'
    $src = Get-Content -LiteralPath $Script -Raw
    $code = [regex]::Replace($src, '(?s)<#.*?#>', '')
    $codeLines = @($code -split "`n" | Where-Object { $_ -notmatch '^\s*#' })
    $rules = Get-Content -LiteralPath $RulesLib -Raw

    # THE INCOMPLETENESS FLAG: the worst fault of this script was a green conclusion over 9% of the data.
    Assert-True ($code.Contains('$complete = ($failed -eq 0)')) 'the incompleteness flag is set from the failure count'
    Assert-True ($code.Contains('the crawl is INCOMPLETE -- this does not prove there are none')) 'the duplicates conclusion is withdrawn when incomplete'
    Assert-True ($code.Contains('LOCALE DIFFERENCE: SKIPPED')) 'the locale difference is skipped when incomplete'
    Assert-True ($code.Contains('CATALOGUE AGAINST THE SITEMAP: SKIPPED')) 'the catalogue comparison is skipped when incomplete'
    Assert-True ($code.Contains('not found in the READ part of the sitemap of')) '-Find says which part was searched'
    # The count per kind stays, the path comparison stays gone.
    Assert-True ($code.Contains('$perLocaleKind[$lkKey]++')) 'URLs are counted per locale and kind'
    Assert-True ($code -notmatch 'same path, other locale|path\(s\) missing in') 'the path comparison between locales does not come back'
    # The 25000 ceiling and the noindex check.
    Assert-True ($rules.Contains('$script:PublicJsonCeiling = 25000') -and $rules.Contains('Truncated = $truncated')) 'the ceiling is a constant and a cut-off list is reported as such'
    Assert-True ($code.Contains('Test-PathIsNoindex -Domain $domain -Path $p') -and $code.Contains('rightly left out')) 'a missing page is tested for noindex first'
    Assert-True ($code.Contains('noindex could NOT be determined')) 'an undeterminable noindex is not read as green'
    Assert-True ($rules.Contains('[System.Net.WebUtility]::HtmlDecode')) 'the entity decoding stays in Get-SitemapLocs'
    Assert-True ($src.Contains('[int]$DelayMs = 500') -and $code.Contains('if ($AbortAfter -gt 0 -and $inARow -ge $AbortAfter)')) 'the default paces itself and a domain stops after consecutive failures'
    # Shared pieces, no native exe.
    Assert-True ($code -match 'Get-StorefrontMarketRows' -and $code -match 'Select-MarketRows' -and $code -match 'Get-DomainGroups') 'markets come from the shared reader and selection'
    Assert-True ($code.Contains('Expand-CommaList -Value $Market') -and $code.Contains('Expand-CommaList -Value $Locale') -and $code.Contains('Expand-CommaList -Value $Find')) 'every list parameter is split'
    Assert-True ($code -notmatch 'market-domains|native-cli|Invoke-Native|curl') 'no store lib, no native curl'
    Assert-Equal 0 @($codeLines | Where-Object { $_ -match '^\s*&?\s*(curl(\.exe)?|shopify)\s' }).Count 'no line starts curl or shopify as a command'
    Assert-True ($code -notmatch 'Invoke-Expression|theme push|theme publish') 'read-only: no push, no publish, no Invoke-Expression'
    Assert-True ($code.Contains('Invoke-WebRequest') -and $code.Contains('Get-FetchFailureEvidence')) 'fetching is Invoke-WebRequest with the shared failure evidence'
    # Every exception message that reaches the console is stripped.
    $bareMsg = @($codeLines | Where-Object { $_ -match 'Write-Host(?!.*Format-SafeProseToken).*\$_\.Exception\.Message' })
    Assert-Equal 0 $bareMsg.Count 'no exception message goes to Write-Host unstripped'

    Write-Group '11. the files are ASCII'
    foreach ($p in @($Script, $RulesLib, $MarketLib)) {
        $nonAscii = @([System.IO.File]::ReadAllBytes($p) | Where-Object { $_ -gt 127 }).Count
        Assert-Equal 0 $nonAscii ("{0} is pure ASCII" -f (Split-Path -Leaf $p))
    }
}
finally {
    Remove-Item -LiteralPath $fixture, $bareFixture -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host ("{0} passed, {1} failed" -f $script:pass, $script:fail) -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
