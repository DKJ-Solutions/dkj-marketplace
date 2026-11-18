<#
.SYNOPSIS
    Tests for dkj-subagents-shopify's check-jsonld: the pure rules in scripts/lib/check-jsonld-rules.ps1,
    the comma split in scripts/lib/comma-list.ps1 and the shared market reader (issue #4290).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell. Exit code 0 if everything passes, 1 on a failure.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/shopify-check-jsonld.tests.ps1

    No network. The script is driven only with -PlanOnly, which builds the targets and stops before any
    request. It is called through `powershell -File` ON PURPOSE: that is exactly the invocation form that
    sets the comma trap (with -File a list argument arrives as ONE string), so a direct call could not
    reproduce the bug and could not guard against it either.

    Why this script deserves tests, and why these: check-jsonld exists to prove structured data
    mechanically, so it may do anything except produce a silent green measurement over a page nobody
    asked for. That is what happened once in a store: two paths asked, ONE measured (the list arrived as a
    single path with a comma in it, Shopify resolved that to the product page), "all valid", exit 0.

    Made-up fixtures only (this repo is public): no real store name, domain or theme id.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot  = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Plugin    = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify'
$Lib       = Join-Path $Plugin 'scripts\lib'
$Script    = Join-Path $Plugin 'scripts\task\check-jsonld.ps1'
$RulesLib  = Join-Path $Lib 'check-jsonld-rules.ps1'
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

# A fixture store: a temp root whose scripts/repo-config.ps1 answers the market seam.
$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("check-jsonld-fixture-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts') -Force | Out-Null
Set-Content -LiteralPath (Join-Path $fixture 'scripts\repo-config.ps1') -Encoding ASCII -Value @'
function Get-StorefrontMarkets {
    @(
        @{ Market = 'de'; Domain = 'shop.example.de'; PathPrefix = '' },
        [pscustomobject]@{ Market = 'NL'; Domain = 'www.example.com'; PathPrefix = '/nl' }
    )
}
'@
$bareFixture = Join-Path ([System.IO.Path]::GetTempPath()) ("check-jsonld-bare-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $bareFixture -Force | Out-Null

function Invoke-Target {
    param([string[]]$Arguments, [string]$Root = $fixture)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @Arguments -RootOverride $Root 2>&1
    return [pscustomobject]@{ Text = (@($out | ForEach-Object { "$_" }) -join "`n"); Code = $LASTEXITCODE }
}

try {
    Write-Group '1. Expand-CommaList'
    Assert-Equal 'a|b|c' ((Expand-CommaList -Value 'a,b,c') -join '|') 'one comma string becomes three elements'
    Assert-Equal 'a|b|c' ((Expand-CommaList -Value @(' a ', 'b,c')) -join '|') 'trims, and splits only inside an element'
    Assert-Equal 0 @(Expand-CommaList -Value @('', ' , ')).Count 'empty elements are dropped'
    Assert-Equal 0 @(Expand-CommaList -Value @()).Count 'an empty collection gives an empty result'
    $defs = @(Get-ChildItem -LiteralPath (Join-Path $Plugin 'scripts') -Recurse -Filter '*.ps1' |
        Where-Object { (Get-Content -LiteralPath $_.FullName -Raw) -match '(?m)^\s*function\s+Expand-CommaList\b' })
    Assert-Equal 1 $defs.Count 'exactly ONE definition of Expand-CommaList in the plugin (a second one works, then drifts)'

    Write-Group '2. Get-TargetShapeErrors'
    Assert-Equal 0 @(Get-TargetShapeErrors -Value @('/', '/pages/x?a=1') -Kind Path).Count 'paths starting with / pass'
    Assert-Equal 'b|pages/x' ((Get-TargetShapeErrors -Value @('/a', 'b', 'pages/x') -Kind Path) -join '|') 'a fragment or a path without a leading slash is returned'
    Assert-Equal 0 @(Get-TargetShapeErrors -Value @('https://x.example/', 'http://y.example/') -Kind Url).Count 'http(s) URLs pass'
    Assert-Equal 'x.example' ((Get-TargetShapeErrors -Value @('x.example') -Kind Url) -join '|') 'a URL without a scheme is returned'
    Assert-Equal 0 @(Get-TargetShapeErrors -Value @() -Kind Path).Count 'an empty list has no errors'

    Write-Group '3. Select-MarketRows'
    $rows = @(
        @{ Market = 'de'; Domain = 'a.example' },
        [pscustomobject]@{ Market = 'NL'; Domain = 'b.example' },
        @{ Market = 'UK'; Domain = 'c.example' }
    )
    Assert-Equal 3 @(Select-MarketRows -Markets $rows -Market @()).Count 'no -Market: every row'
    $sel = @(Select-MarketRows -Markets $rows -Market @('uk', 'DE'))
    Assert-Equal 2 $sel.Count 'two named markets: two rows'
    Assert-Equal 'de' (Get-MarketRowValue -Row $sel[0] -Name 'Market') 'the store''s own order is kept'
    $msg = Get-Threw { Select-MarketRows -Markets $rows -Market @('FR') }
    Assert-True ($msg -match "Unknown market 'FR'" -and $msg -match 'de, NL, UK') 'an unknown market throws and lists the known ones'

    Write-Group '4. Get-JsonLdBlocks and Get-JsonLdType'
    $html = '<html><script type="application/ld+json">{"@type":"Product","name":"a"}</script><script>var x=1;</script>' +
            "<SCRIPT TYPE='application/ld+json' id=z>`n {""@type"" : ""FAQPage""} `n</SCRIPT></html>"
    $blocks = @(Get-JsonLdBlocks -Html $html)
    Assert-Equal 2 $blocks.Count 'two ld+json blocks, the plain script is ignored (either quote style, any case)'
    Assert-Equal '{"@type" : "FAQPage"}' $blocks[1] 'a block is trimmed'
    Assert-Equal 'Product' (Get-JsonLdType -Raw $blocks[0]) 'the type of the first block'
    Assert-Equal 'FAQPage' (Get-JsonLdType -Raw $blocks[1]) 'spaces around the colon are fine'
    Assert-Equal '?' (Get-JsonLdType -Raw '{"name":"x"}') 'no @type: ?'
    Assert-Equal 0 @(Get-JsonLdBlocks -Html '<p>none</p>').Count 'no blocks: an empty array'
    Assert-Equal 2 (Get-ProtocolRelativeImageCount -Raw @('{"image":"//cdn.example/a.png"}', '{"image" : "//cdn.example/b.png"}', '{"image":"https://x/c.png"}')) 'protocol-relative images are counted'

    Write-Group '5. Get-BlockFindings per type'
    $f = @(Get-BlockFindings -Type 'Product' -Obj ('{"@type":"Product","url":"https://x.example/p","offers":[{"priceCurrency":"EUR","price":"9.95","availability":"InStock"}],"aggregateRating":{"ratingValue":"4.5","ratingCount":"12"}}' | ConvertFrom-Json))
    Assert-True (($f.Text -join "`n") -match 'EUR 9.95') 'Product: first offer shown'
    Assert-True (($f.Text -join "`n") -match 'rating   : 4.5 / 12') 'Product: ratingCount is the fallback for reviewCount'
    $f = @(Get-BlockFindings -Type 'Product' -Obj ('{"@type":"Product","url":"u"}' | ConvertFrom-Json))
    Assert-Equal 'Dim' $f[-1].Level 'Product without a rating says so, dimmed'
    $f = @(Get-BlockFindings -Type 'BreadcrumbList' -Obj ('{"itemListElement":[{"position":1,"item":{"name":"Home","@id":"https://x.example/"}}]}' | ConvertFrom-Json))
    Assert-True ($f[0].Text -match '1\. Home  ->  https://x.example/') 'BreadcrumbList: position, name and @id'
    $f = @(Get-BlockFindings -Type 'ItemList' -Obj ('{"itemListElement":[{"item":{"aggregateRating":{"ratingValue":"5"}}},{"item":{"aggregateRating":{"ratingValue":"5"}}}]}' | ConvertFrom-Json))
    Assert-True ((@($f | Where-Object { $_.Level -eq 'Warn' -and $_.Text -match 'ALL 5' }).Count) -eq 1) 'ItemList: identical per-product ratings are flagged'
    $f = @(Get-BlockFindings -Type 'NewsArticle' -Obj ('{"headline":"h"}' | ConvertFrom-Json))
    Assert-True ((@($f | Where-Object { $_.Level -eq 'Warn' -and $_.Text -match 'NewsArticle instead of BlogPosting' }).Count) -eq 1) 'NewsArticle is flagged'
    $f = @(Get-BlockFindings -Type 'Thing' -Obj ('{}' | ConvertFrom-Json))
    Assert-True ($f[0].Text -match 'no summary for Thing') 'an unknown type gets the no-summary line'

    Write-Group '6. FAQPage answers: the four broken shapes and the clean one'
    $faq = '{"@type":"FAQPage","mainEntity":[' +
        '{"acceptedAnswer":{"text":"Plain answer."}},' +
        '{"acceptedAnswer":{"text":""}},' +
        '{"acceptedAnswer":{"text":"{\"type\":\"root\",\"children\":[]}"}},' +
        '{"acceptedAnswer":{"text":"<div class=\"metafield-rich_text_field\">x</div>"}},' +
        '{"acceptedAnswer":{"text":"<p>tagged</p>"}},' +
        '{"acceptedAnswer":{"text":"it&#39;s"}}]}'
    $t = (@(Get-BlockFindings -Type 'FAQPage' -Obj ($faq | ConvertFrom-Json)).Text) -join "`n"
    Assert-True ($t -match '2 of 6 answers empty or still the rich-text object') 'empty and rich-text-object answers are counted together'
    Assert-True ($t -match '1 of 6 answers carry the metafield wrapper div') 'the metafield wrapper is counted'
    Assert-True ($t -match '1 of 6 answers still carry HTML tags') 'a tag is counted'
    Assert-True ($t -match '1 of 6 answers carry an HTML entity') 'an entity is counted'
    $clean = '{"@type":"FAQPage","mainEntity":[{"acceptedAnswer":{"text":"One."}},{"acceptedAnswer":{"text":"Two."}}]}'
    $f = @(Get-BlockFindings -Type 'FAQPage' -Obj ($clean | ConvertFrom-Json))
    Assert-Equal 'Ok' $f[-1].Level 'clean answers end on a green line'

    Write-Group '7. Get-StorefrontMarketRows (the shared seam reader)'
    $m = @(Get-StorefrontMarketRows -RepoRoot $fixture)
    Assert-Equal 2 $m.Count 'the fixture store answers two rows'
    Assert-Equal 0 @(Get-StorefrontMarketRows -RepoRoot $bareFixture).Count 'no repo-config.ps1: unanswered, empty'

    Write-Group '8. the script through powershell -File, -PlanOnly (the comma trap, measured)'
    $r = Invoke-Target -Arguments @('-ThemeId', '123', '-Path', '/collections/some-collection,/products/some-product', '-Market', 'nl', '-PlanOnly')
    Assert-Equal 0 $r.Code 'two comma-bound paths: exit 0'
    Assert-True ($r.Text -match '2 target\(s\):') 'TWO targets, not one'
    Assert-True ($r.Text -match 'https://www\.example\.com/nl/collections/some-collection\?preview_theme_id=123&_ab=0&_fd=0&_sc=1') 'the collection page is a target of its own, with the preview parameters'
    Assert-True ($r.Text -match 'https://www\.example\.com/nl/products/some-product\?') 'the product page is a target of its own'
    $planLines = @($r.Text -split "`n" | Where-Object { $_ -match '->\s+https?://' })
    Assert-Equal 0 @($planLines | Where-Object { $_ -match '->.*,' }).Count 'no target URL carries a comma'

    $r = Invoke-Target -Arguments @('-Path', '/collections/all?filter=a,b', '-PlanOnly')
    Assert-Equal 1 $r.Code 'a comma inside a query string leaves a fragment: refused, exit 1'
    Assert-True ($r.Text -match 'Invalid -Path argument\(s\)' -and $r.Text -match "'b'") 'names the argument and the mangled fragment'
    Assert-True ($r.Text -notmatch 'target\(s\):') 'builds no target list on a mangled path'

    $r = Invoke-Target -Arguments @('-Path', 'pages/reviews', '-PlanOnly')
    Assert-Equal 1 $r.Code 'a path without a leading slash: refused'
    Assert-True ($r.Text -notmatch 'example\.depages') 'never glued onto the domain'

    $r = Invoke-Target -Arguments @('-Url', 'shop.example.de', '-PlanOnly')
    Assert-Equal 1 $r.Code 'a -Url without a scheme: refused'
    Assert-True ($r.Text -match 'Invalid -Url argument\(s\)') 'names -Url'

    $r = Invoke-Target -Arguments @('-Url', 'https://a.example/,https://b.example/', '-PlanOnly')
    Assert-True ($r.Code -eq 0 -and $r.Text -match '2 target\(s\):') '-Url as a comma list: two targets'
    Assert-True ($r.Text -notmatch 'preview_theme_id') '-Url gets no preview suffix'

    $r = Invoke-Target -Arguments @('-Path', '/', '-Market', 'DE,nl', '-PlanOnly')
    Assert-True ($r.Code -eq 0 -and $r.Text -match '2 target\(s\):') '-Market as a comma list: both markets'
    Assert-True ($r.Text -match 'https://shop\.example\.de/' -and $r.Text -match 'https://www\.example\.com/nl') 'both domains, the prefix kept on the second'

    $r = Invoke-Target -Arguments @('-Path', '/,/pages/reviews', '-PlanOnly')
    Assert-True ($r.Code -eq 0 -and $r.Text -match '4 target\(s\):') 'paths x markets stays a cross product'

    $r = Invoke-Target -Arguments @('-Path', '/', '-Market', 'FR', '-PlanOnly')
    Assert-True ($r.Code -eq 1 -and $r.Text -match "REFUSED: Unknown market 'FR'") 'an unknown market is refused loudly'

    $r = Invoke-Target -Arguments @('-Path', '/', '-PlanOnly') -Root $bareFixture
    Assert-True ($r.Code -eq 1 -and $r.Text -match 'Get-StorefrontMarkets' -and $r.Text -match '-Url') 'no market table: -Path refuses and names the seam and -Url'

    $r = Invoke-Target -Arguments @('-Path', '/', '-PlanOnly')
    Assert-True ($r.Text -match 'nothing fetched') '-PlanOnly says nothing was fetched'
    Assert-True ($r.Text -notmatch 'block\(s\) tested') 'and prints no measurement without a request'

    Write-Group '9. static guards on the script'
    $src = Get-Content -LiteralPath $Script -Raw
    Assert-True ($src.Contains('$Path = Expand-CommaList -Value $Path')) '-Path is split'
    Assert-True ($src.Contains('Expand-CommaList -Value $Market')) '-Market is split'
    Assert-True ($src.Contains('$Url = Expand-CommaList -Value $Url')) '-Url is split'
    Assert-True ($src.Contains("Get-TargetShapeErrors -Value `$Path -Kind 'Path'") -and $src.Contains("Get-TargetShapeErrors -Value `$Url -Kind 'Url'")) 'the shape check sits on both target kinds'
    Assert-True ($src -match 'Get-StorefrontMarketRows' -and $src -match 'Get-ProbeTargets') 'markets come from the shared reader and the shared target builder'
    Assert-True ($src -notmatch 'market-domains|market-urls|curl\.exe') 'no store lib, no native curl'
    Assert-True ($src -notmatch 'Invoke-Expression') 'no Invoke-Expression'
    Assert-Equal 0 @($src -split "`n" | Where-Object { $_ -match '^\s*&?\s*shopify\s' }).Count 'read-only: no line starts shopify as a command'

    Write-Group '10. the files are ASCII'
    foreach ($p in @($Script, $RulesLib, $CommaLib, $MarketLib)) {
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
