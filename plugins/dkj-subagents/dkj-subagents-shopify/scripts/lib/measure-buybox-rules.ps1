<#
.SYNOPSIS
    The pure rules of measure-buybox (issue #4290): the seam answer made into one validated config, the
    URL to measure, the harness input, the JSON line out of the harness output, the verdict, and the
    report as lines. Dot-source this file; it touches no network and runs no browser.

.DESCRIPTION
    Needs command-probe-lib.ps1 (Test-FunctionDefined) and which-theme-rules.ps1 (Get-MarketRowValue,
    Get-ProbeTargets, Get-ProbeUrl) loaded first, and storefront-markets-lib.ps1 for the market rows.

    THE SPLIT. The measuring mechanism lives in this plugin (the driver, the node harness, the viewport
    emulation, the report). Everything that is a fact about ONE store's theme -- which element is the buy
    box, which one the add-to-cart button, which blocks are worth listing, which element is the sticky bar,
    and what offset the store expects -- is the store's, answered through its Get-ShopifyBuyBox seam in
    scripts/repo-config.ps1. Nothing in the harness or here names a theme selector.

    No Set-StrictMode here (dot-sourcing would change the caller's). Pure ASCII (repo convention for .ps1).
#>

# The prose guard the report puts around every foreign value. Loaded here, as a lib that calls it must
# (the exception-message guard suite holds every caller of Format-SafeProseToken to that).
. (Join-Path $PSScriptRoot 'check-report-lib.ps1')

function Get-BuyBoxSeamAnswer {
    <#
        The store's Get-ShopifyBuyBox answer exactly as given, or $null when the seam is unanswered. Read in
        a child scope with StrictMode off and inside a try: repo-config.ps1 belongs to the consumer, so a
        fault in it degrades to "unanswered" rather than taking the script down.
    #>
    param([Parameter(Mandatory = $true)][string]$RepoRoot)
    $root = ([string]$RepoRoot).Trim() -replace '/', '\'
    $answer = & {
        Set-StrictMode -Off
        $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
        if (Test-Path -LiteralPath $configPath -PathType Leaf) {
            try { . $configPath } catch { }
        }
        if (Test-FunctionDefined 'Get-ShopifyBuyBox') {
            try { return (Get-ShopifyBuyBox) } catch { return $null }
        }
    } $root
    return $answer
}

function Get-BuyBoxSeamHelp {
    <# The sentence that names the seam and its row shape; used by every refusal about it. #>
    return ("Add Get-ShopifyBuyBox to scripts/repo-config.ps1, returning a hashtable: BoxSelector (the buy box), " +
        "AtcSelector (the add-to-cart button inside it), optional BlockSelectors (a list of block selectors to " +
        "report), StickySelector (the sticky add-to-cart bar), MobileMaxWidth (default 749), and optional " +
        "expectations AtcMaxTop (px from the top of the buy box) with AtWidth (the viewport width it applies to). " +
        "Or pass -BoxSelector and -AtcSelector for a one-off run.")
}

function Test-SelectorText {
    <# A selector is one non-empty line of text. $true or $false. #>
    param($Value)
    if ($Value -isnot [string]) { return $false }
    $s = [string]$Value
    return ($s.Trim().Length -gt 0 -and $s -notmatch '[\x00-\x1f\x7f]')
}

function Resolve-BuyBoxConfig {
    <#
        The seam answer plus the one-off overrides as ONE validated config, or a throw whose message says
        what to fix. A -BoxSelector / -AtcSelector given on the command line wins over the seam; with both
        given the seam is not needed at all. Unanswered seam and a selector still missing: the throw names
        the seam and its row shape.
    #>
    param($Seam, [string]$BoxSelector = '', [string]$AtcSelector = '')

    if ($null -ne $Seam -and $Seam -isnot [System.Collections.IDictionary] -and $Seam -isnot [pscustomobject]) {
        throw "Get-ShopifyBuyBox must return one hashtable, not a $($Seam.GetType().Name). $(Get-BuyBoxSeamHelp)"
    }
    $get = { param($n) if ($null -eq $Seam) { return $null } else { return (Get-MarketRowValue -Row $Seam -Name $n) } }

    $box = if ($BoxSelector) { $BoxSelector } else { & $get 'BoxSelector' }
    $atc = if ($AtcSelector) { $AtcSelector } else { & $get 'AtcSelector' }
    if (-not $box -or -not $atc) {
        $missing = @()
        if (-not $box) { $missing += 'BoxSelector' }
        if (-not $atc) { $missing += 'AtcSelector' }
        $who = if ($null -eq $Seam) { 'this repo has not answered the Get-ShopifyBuyBox seam' } else { "the Get-ShopifyBuyBox answer has no $($missing -join ' or ')" }
        throw "measure-buybox needs the store's buy box selectors, and $who (missing: $($missing -join ', ')). $(Get-BuyBoxSeamHelp)"
    }
    foreach ($pair in @(@('BoxSelector', $box), @('AtcSelector', $atc))) {
        if (-not (Test-SelectorText $pair[1])) { throw "$($pair[0]) must be one non-empty line of selector text." }
    }

    $blocks = @()
    $rawBlocks = & $get 'BlockSelectors'
    foreach ($b in @($rawBlocks)) {
        if ($null -eq $b) { continue }
        if (-not (Test-SelectorText $b)) { throw 'BlockSelectors must be a list of non-empty one-line selector strings.' }
        $blocks += [string]$b
    }
    # The ATC button is always among the measured blocks, so its offset sits in the same list.
    if ($blocks -notcontains [string]$atc) { $blocks = @([string]$atc) + $blocks }

    $sticky = [string](& $get 'StickySelector')
    if ($sticky -and -not (Test-SelectorText $sticky)) { throw 'StickySelector must be one line of selector text.' }

    $mobile = 749
    $rawMobile = & $get 'MobileMaxWidth'
    if ($null -ne $rawMobile -and "$rawMobile" -ne '') {
        $n = 0
        if (-not [int]::TryParse("$rawMobile", [ref]$n) -or $n -lt 1) { throw "MobileMaxWidth must be a positive whole number of px, not '$rawMobile'." }
        $mobile = $n
    }

    $maxTop = $null; $atWidth = $null
    $rawTop = & $get 'AtcMaxTop'
    $rawAt = & $get 'AtWidth'
    $hasTop = ($null -ne $rawTop -and "$rawTop" -ne '')
    $hasAt = ($null -ne $rawAt -and "$rawAt" -ne '')
    if ($hasTop -or $hasAt) {
        if (-not ($hasTop -and $hasAt)) {
            throw 'AtcMaxTop and AtWidth go together: an offset limit means nothing without the viewport width it applies to.'
        }
        $t = 0; $w = 0
        if (-not [int]::TryParse("$rawTop", [ref]$t) -or $t -lt 0) { throw "AtcMaxTop must be a whole number of px, not '$rawTop'." }
        if (-not [int]::TryParse("$rawAt", [ref]$w) -or $w -lt 1) { throw "AtWidth must be a positive whole number of px, not '$rawAt'." }
        $maxTop = $t; $atWidth = $w
    }

    return [pscustomobject]@{
        BoxSelector    = [string]$box
        AtcSelector    = [string]$atc
        BlockSelectors = @($blocks)
        StickySelector = $sticky
        MobileMaxWidth = $mobile
        AtcMaxTop      = $maxTop
        AtWidth        = $atWidth
    }
}

function Get-MeasureUrl {
    <#
        The page to measure. -Url wins and must be an http(s) address; otherwise -Market plus -Path (and
        optionally -PreviewThemeId) are built from the store's market rows, with the full preview
        parameters Get-ProbeUrl adds. Throws a message naming the way out.
    #>
    param(
        [string]$Url = '',
        [string]$Market = '',
        [string]$Path = '',
        [string]$PreviewThemeId = '',
        [object[]]$MarketRows = @()
    )
    if ($Url) {
        if ($Url -notmatch '^https?://\S+$') { throw '-Url must be one address starting with http:// or https://.' }
        return $Url
    }
    if (-not $Market -or -not $Path) { throw 'Give -Url, or both -Market and -Path.' }
    if (-not $Path.StartsWith('/')) { throw "-Path must start with '/'." }
    $rows = @(Select-MarketRows -Markets $MarketRows -Market @($Market))
    $built = @(Get-ProbeTargets -Path @($Path) -Markets $rows)
    return (Get-ProbeUrl -Target $built[0].Target -ThemeId $PreviewThemeId)
}

function ConvertTo-BuyBoxInput {
    <# The single argument the harness reads: the config as UTF-8 JSON, base64-encoded. #>
    param([Parameter(Mandatory = $true)]$Config)
    $obj = [ordered]@{
        boxSelector    = $Config.BoxSelector
        atcSelector    = $Config.AtcSelector
        blockSelectors = @($Config.BlockSelectors)
        stickySelector = $Config.StickySelector
        mobileMaxWidth = $Config.MobileMaxWidth
    }
    $json = ConvertTo-Json -InputObject $obj -Compress
    return [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($json))
}

function Get-BuyBoxJsonLine {
    <# The last output line that is a JSON object (the harness's one stdout line), or $null. #>
    param($Lines)
    $hits = @(@($Lines) | Where-Object { $null -ne $_ -and "$_".TrimStart().StartsWith('{') })
    if ($hits.Count -eq 0) { return $null }
    return ([string]$hits[$hits.Count - 1]).Trim()
}

function Get-BuyBoxVerdict {
    <#
        What the measurement says against the store's expectation. State is one of:
          NoExpectation  the store gave no AtcMaxTop: measure only
          NotJudged      an expectation exists but it applies to another width than the one measured
          NoAtc          the add-to-cart element is not on the page
          Pass / Fail    the ATC offset against AtcMaxTop, at the width it applies to
        The width compared is the MEASURED innerWidth, never the requested one: a viewport that came out
        wrong must not borrow a verdict meant for the right one.
    #>
    param([Parameter(Mandatory = $true)]$Measurement, [Parameter(Mandatory = $true)]$Config)
    $atc = if ($Measurement.PSObject.Properties.Name -contains 'atc') { $Measurement.atc } else { $null }
    if ($null -eq $atc) { return [pscustomobject]@{ State = 'NoAtc'; Text = 'ATC button: NOT found on this page.' } }
    if ($null -eq $Config.AtcMaxTop) {
        return [pscustomobject]@{ State = 'NoExpectation'; Text = 'No expectation was given by the store (AtcMaxTop), so this run only measures.' }
    }
    if ([int]$Measurement.innerWidth -ne [int]$Config.AtWidth) {
        return [pscustomobject]@{
            State = 'NotJudged'
            Text  = ("The store's expectation (ATC <= {0}px) applies at {1}px; this run measured at {2}px, so it is not judged." -f `
                    $Config.AtcMaxTop, $Config.AtWidth, $Measurement.innerWidth)
        }
    }
    $top = [int]$atc.top
    if ($top -le [int]$Config.AtcMaxTop) {
        return [pscustomobject]@{ State = 'Pass'; Text = ("PASS: the ATC button is at {0}px, within the store's limit of {1}px at {2}px wide." -f $top, $Config.AtcMaxTop, $Config.AtWidth) }
    }
    return [pscustomobject]@{ State = 'Fail'; Text = ("FAIL: the ATC button is at {0}px, over the store's limit of {1}px at {2}px wide." -f $top, $Config.AtcMaxTop, $Config.AtWidth) }
}

function Get-BuyBoxReport {
    <#
        The human report as { Text, Color } lines (Color '' for the default). Page titles, class names and
        selectors are foreign text, so each such VALUE goes through Format-SafeProseToken before it is
        embedded in a padded line (the guard collapses whitespace, so it cannot be applied to a whole
        padded line).
    #>
    param(
        [Parameter(Mandatory = $true)]$Measurement,
        [Parameter(Mandatory = $true)]$Config,
        [Parameter(Mandatory = $true)][int]$RequestedWidth
    )
    $m = $Measurement
    $lines = [System.Collections.Generic.List[object]]::new()
    $add = { param($t, $c = '') $lines.Add([pscustomobject]@{ Text = $t; Color = $c }) }
    $safe = { param($v) Format-SafeProseToken -Value ([string]$v) -MaxLength 200 }

    & $add ''
    if ([int]$m.innerWidth -ne $RequestedWidth) {
        & $add ("viewport: MEASURED AT {0}px, REQUESTED {1}px -- the measurement does not hold for {1}px." -f $m.innerWidth, $RequestedWidth) 'Red'
    } else {
        & $add ("viewport : {0}px (mobile media query: {1})" -f $m.innerWidth, $m.mobileMQ) 'Green'
    }
    & $add ("page     : {0}" -f (& $safe $m.title))

    if ($m.PSObject.Properties.Name -contains 'error') {
        & $add ''
        & $add ("No buy box found: {0}" -f (& $safe $m.error)) 'Red'
        return $lines.ToArray()
    }

    & $add ''
    & $add 'Blocks in the buy box, top to bottom:' 'Cyan'
    & $add ('  {0,5}  {1,5}  {2}' -f 'top', 'high', 'class')
    foreach ($c in @($m.order)) { & $add ('  {0,5}  {1,5}  {2}' -f $c.top, $c.h, (& $safe $c.cls)) }

    & $add ''
    & $add "The store's listed blocks, measured apart:" 'Cyan'
    foreach ($p in $m.blocks.PSObject.Properties) {
        if ($null -eq $p.Value) { & $add ('  {0,-34} (not on this page)' -f (& $safe $p.Name)) 'DarkGray' }
        else { & $add ('  {0,-34} top {1,5}   high {2,5}' -f (& $safe $p.Name), $p.Value.top, $p.Value.h) }
    }

    $verdict = Get-BuyBoxVerdict -Measurement $m -Config $Config
    & $add ''
    if ($verdict.State -eq 'NoAtc') {
        & $add $verdict.Text 'Red'
        return $lines.ToArray()
    }
    & $add ("ATC button is {0}px from the top of the buy box." -f $m.atc.top) 'Yellow'
    $color = switch ($verdict.State) { 'Pass' { 'Green' } 'Fail' { 'Red' } default { 'DarkGray' } }
    & $add $verdict.Text $color

    # THESE LINES ARE NOT EXTRAS -- THEY PREVENT THE WRONG CONCLUSION. The offset above is counted from the
    # top of the buy box, which is NOT the fold: the box itself starts below the gallery. And a sticky bar
    # with an ATC button of its own may be pinned to the bottom of the window, outside the box, so it does
    # not move with the offset. Without these lines a missed offset reads as "the button is unreachable",
    # and that is the mistake a person made on the first manual measurement here: they looked, saw a
    # button standing neatly, and were right.
    & $add ''
    & $add 'And this is what the offset above does NOT say:' 'Cyan'
    & $add ('  the buy box itself starts at       {0,5}px from the top of the page' -f $m.page.buyBoxTop)
    if ($null -ne $m.page.atcFromPageTop) {
        & $add ('  so the ATC button is at            {0,5}px from the top of the page (window {1}px high)' -f $m.page.atcFromPageTop, $m.viewportHeight)
    }
    if ($null -eq $m.sticky) {
        $what = if ($Config.StickySelector) { 'NONE on this page' } else { 'not measured (the store named no StickySelector)' }
        & $add ('  sticky ATC bar                     {0}' -f $what) 'Yellow'
    } else {
        $seen = if ($m.sticky.onScreen) { 'ON SCREEN' } else { 'not on screen' }
        & $add ('  sticky ATC bar ({0,-6})            {1} at {2}px, {3}px high' -f (& $safe $m.sticky.position), $seen, $m.sticky.top, $m.sticky.height)
        if ($m.sticky.onScreen) { & $add '  -> an ATC button is pinned on screen, whatever the offset above says.' }
    }
    return $lines.ToArray()
}
