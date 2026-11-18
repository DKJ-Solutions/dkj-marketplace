<#
.SYNOPSIS
    The pure rules behind check-jsonld.ps1 (#4290): target-shape checks, market filtering, JSON-LD
    block extraction and the per-type findings. No network, no repo access.

.DESCRIPTION
    Dot-source this file (after which-theme-rules.ps1 for Get-MarketRowValue). Split out of the script
    because the script fetches pages and a suite must not reach a store, so everything that can be
    wrong without a network lives here, where scripts/tests/shopify-check-jsonld.tests.ps1 measures it.

    No Set-StrictMode here: dot-sourcing would change the strict mode of the calling script.
    Pure ASCII (repo convention for .ps1).
#>

function Get-TargetShapeErrors {
    <#
    .SYNOPSIS
        The elements of a -Path or -Url list that have the wrong shape (empty array when all are fine).
    .NOTES
        The second half of the pair described in comma-list.ps1, and deliberately NOT part of that lib:
        splitting is generic, but what a valid element looks like is known only to the caller. Without
        this check a mangled path is glued onto a domain and the script measures something other than
        what was asked; with it the run stops before any request goes out.
    #>
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Value,
        [Parameter(Mandatory = $true)][ValidateSet('Path', 'Url')][string]$Kind
    )
    return @($Value | Where-Object {
            if ($Kind -eq 'Path') { -not $_.StartsWith('/') } else { $_ -notmatch '^https?://' }
        })
}

function Select-MarketRows {
    <#
    .SYNOPSIS
        The market rows named in -Market (case-insensitive, by the row's Market label), in the order
        the store lists them; every row when -Market is empty. Throws on a name the store does not list.
    #>
    param([object[]]$Markets, [string[]]$Market)
    $rows = @($Markets | Where-Object { $_ })
    if (-not $Market -or @($Market).Count -eq 0) { return $rows }
    $known = @($rows | ForEach-Object { [string](Get-MarketRowValue -Row $_ -Name 'Market') })
    foreach ($m in $Market) {
        if (-not ($known | Where-Object { $_ -ieq $m })) {
            throw "Unknown market '$m'. The store's Get-StorefrontMarkets lists: $($known -join ', ')."
        }
    }
    return @($rows | Where-Object {
            $label = [string](Get-MarketRowValue -Row $_ -Name 'Market')
            @($Market | Where-Object { $_ -ieq $label }).Count -gt 0
        })
}

function Get-JsonLdBlocks {
    <# The raw (trimmed) text of every <script type="application/ld+json"> block in the HTML. #>
    param([string]$Html)
    return @([regex]::Matches($Html, '(?is)<script[^>]*type=["'']application/ld\+json["''][^>]*>(.*?)</script>') |
        ForEach-Object { $_.Groups[1].Value.Trim() })
}

function Get-JsonLdType {
    <# The first "@type" in a raw block, or '?' when there is none. #>
    param([string]$Raw)
    $t = ([regex]::Match($Raw, '"@type"\s*:\s*"([^"]+)"')).Groups[1].Value
    if ($t) { return $t }
    return '?'
}

function Get-ProtocolRelativeImageCount {
    <# How many "image": "//..." values the blocks carry; Google wants an absolute URL there. #>
    param([string[]]$Raw)
    return ([regex]::Matches(($Raw -join "`n"), '"image"\s*:\s*"//')).Count
}

function New-Finding {
    param([string]$Text, [string]$Level = 'Info')
    [pscustomobject]@{ Text = $Text; Level = $Level }
}

function Get-BlockFindings {
    <#
    .SYNOPSIS
        The summary lines for one parsed block: only the fields that tend to go wrong. Level is Info,
        Dim, Warn or Ok, which the script maps to a colour.
    #>
    param([string]$Type, $Obj)
    $out = [System.Collections.Generic.List[object]]::new()
    switch -Regex ($Type) {
        'BreadcrumbList' {
            foreach ($item in @($Obj.itemListElement)) {
                $out.Add((New-Finding ("      {0}. {1}  ->  {2}" -f $item.position, $item.item.name, $item.item.'@id')))
            }
        }
        '^Product$' {
            $out.Add((New-Finding ("      url      : {0}" -f $Obj.url)))
            $off = $Obj.offers; if ($off -is [array]) { $off = $off[0] }
            if ($off) { $out.Add((New-Finding ("      offer    : {0} {1}  {2}" -f $off.priceCurrency, $off.price, $off.availability))) }
            if ($Obj.aggregateRating) {
                # Schema.org knows both reviewCount and ratingCount; stores use either.
                $count = $Obj.aggregateRating.reviewCount
                if (-not $count) { $count = $Obj.aggregateRating.ratingCount }
                $out.Add((New-Finding ("      rating   : {0} / {1}" -f $Obj.aggregateRating.ratingValue, $count)))
            }
            else { $out.Add((New-Finding "      rating   : (none)" 'Dim')) }
        }
        '^(Organization|WebSite)$' {
            $out.Add((New-Finding ("      name     : {0}" -f $Obj.name)))
            $out.Add((New-Finding ("      url      : {0}" -f $Obj.url)))
            if ($Obj.contactPoint) { $out.Add((New-Finding ("      phone    : {0}" -f $Obj.contactPoint.telephone))) }
            if ($Obj.aggregateRating) { $out.Add((New-Finding ("      rating   : {0} / {1}" -f $Obj.aggregateRating.ratingValue, $Obj.aggregateRating.reviewCount))) }
            if ($Obj.sameAs) { $out.Add((New-Finding ("      sameAs   : {0}" -f (@($Obj.sameAs) -join ' | ')))) }
            if ($Obj.review) { $out.Add((New-Finding ("      reviews  : {0}" -f @($Obj.review).Count))) }
        }
        'ItemList' {
            $out.Add((New-Finding ("      items: {0}" -f @($Obj.itemListElement).Count)))
            # Flat per-product ratings (the same value on every product) are the known problem here.
            $ratings = @($Obj.itemListElement | ForEach-Object { $_.item.aggregateRating.ratingValue } | Where-Object { $_ })
            if ($ratings.Count -gt 1) {
                $unique = @($ratings | Sort-Object -Unique)
                $msg = "      per-product ratings: {0} of {1} products, {2} unique value(s)" -f $ratings.Count, @($Obj.itemListElement).Count, $unique.Count
                if ($unique.Count -eq 1) { $out.Add((New-Finding ($msg + " -> ALL $($unique[0])") 'Warn')) }
                else { $out.Add((New-Finding $msg)) }
            }
        }
        '^(Blog|BlogPosting|NewsArticle|Article)$' {
            $out.Add((New-Finding ("      headline : {0}" -f $Obj.headline)))
            if ($Type -eq 'NewsArticle') { $out.Add((New-Finding "      !! NewsArticle instead of BlogPosting" 'Warn')) }
            if ($Obj.mainEntityOfPage) { $out.Add((New-Finding ("      @id      : {0}" -f $Obj.mainEntityOfPage.'@id'))) }
            if ($Obj.blogPost) { $out.Add((New-Finding ("      blogPost : {0}" -f @($Obj.blogPost).Count))) }
        }
        'FAQPage' {
            $questions = @($Obj.mainEntity)
            $out.Add((New-Finding ("      questions: {0}" -f $questions.Count)))
            # The ANSWER is what breaks, not the question: three rounds of FAQ-schema repair in a store
            # each broke acceptedAnswer.text while the Liquid was valid, the JSON was valid and the page
            # looked right. A check that only counted questions let all three through.
            $empty = 0; $wrapper = 0; $html = 0; $entity = 0
            foreach ($q in $questions) {
                $text = $q.acceptedAnswer.text
                # Round 1: .value on a rich-text metafield gave the rich-text OBJECT instead of the text,
                # so {"type":"root",...} stood where the answer belonged -- or nothing.
                if ([string]::IsNullOrWhiteSpace($text) -or $text -match '"type"\s*:\s*"root"') { $empty++ }
                # Round 2: metafield_tag wraps its output in <div class="metafield-...">, and that div
                # reached the schema unchanged.
                elseif ($text -match '^\s*<div class="metafield-') { $wrapper++ }
                # Round 3: plain text is wanted, so any tag (<p>, <br />, <li>, ...) counts now.
                elseif ($text -match '</?[a-zA-Z][^>]*>') { $html++ }
                # An entity (&#39;) counts too: a bare strip_html leaves it standing literally.
                if ($text -match '&(#\d+|#x[0-9a-fA-F]+|[a-zA-Z]+);') { $entity++ }
            }
            $n = $questions.Count
            if ($empty)   { $out.Add((New-Finding ("      !! {0} of {1} answers empty or still the rich-text object" -f $empty, $n) 'Warn')) }
            if ($wrapper) { $out.Add((New-Finding ("      !! {0} of {1} answers carry the metafield wrapper div" -f $wrapper, $n) 'Warn')) }
            if ($html)    { $out.Add((New-Finding ("      !! {0} of {1} answers still carry HTML tags" -f $html, $n) 'Warn')) }
            if ($entity)  { $out.Add((New-Finding ("      !! {0} of {1} answers carry an HTML entity" -f $entity, $n) 'Warn')) }
            if (-not ($empty + $wrapper + $html + $entity) -and $n) {
                $out.Add((New-Finding ("      answers: {0} of {0} plain text, no tags or entities" -f $n) 'Ok'))
            }
        }
        default { $out.Add((New-Finding ("      (no summary for {0}; -Full for the raw JSON)" -f $Type) 'Dim')) }
    }
    return $out.ToArray()
}
