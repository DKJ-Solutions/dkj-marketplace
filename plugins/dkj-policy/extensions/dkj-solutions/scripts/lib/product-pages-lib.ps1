<#
.SYNOPSIS
    The product's page layout (#3831): the mobile-first frame every DKJ-Solutions product page stands in -- the site
    header, the breadcrumb bar and the page column -- and the stylesheet it needs, house-product.css beside this
    plugin's assets.

.DESCRIPTION
    WHY IT IS HERE AND NOT IN DKJ-POLICY. dkj-policy draws Admin, which renders in every repo running it, BWJ-Development
    repos included; the product layout is DKJ-Solutions' alone (Maikel, November 5, 2026, on #3831). So the markup moved
    with the stylesheet: dkj-policy's Format-GeneralPageHtml and Format-RepoHomeHeadHtml draw the desktop shell only and
    refuse -BrandTag 'product' with a pointer here, and one plugin owns both the product's markup and its style.

    LOAD ORDER. Dot-source dkj-policy's apps/admin/lib/general-pages-lib.ps1 first: this lib builds on its shared parts
    (Format-GeneralPageHeadHtml, Get-BreadcrumbSep, Get-PageInfoGlyph, Get-LongPageWarningHtml, Get-PageInfoScript,
    Format-FitAlarmHtml, ConvertTo-GeneralPageText), so a product page and an Admin page share one head and cannot drift.
    Join-HouseStyleSpecimens also needs dkj-policy's apps/admin/lib/plugins-page-lib.ps1 (Split-HouseStyleSpecimens).
    Every page links /house-style.css and then /house-product.css: the server that serves a product page serves both.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/dev-pages.tests.ps1 in the source repo.
#>

function Get-ProductStylesheets {
    <# The sheets a product page links after the core house-style.css, in order: the product layer (#3831). #>
    return [string[]]@('/house-product.css')
}

function Format-ProductBreadcrumbBarHtml {
    <#
        The product's breadcrumb bar (house-product.css, "Breadcrumbs"): -HomeLabel linking -HomeHref, then -Trail (each
        @{ Label; Href }, linked), then -Current, the page itself, unlinked. With no -Current the home crumb is the
        current page. Every label is escaped here.
    #>
    param([string]$HomeHref = '/', [string]$HomeLabel = 'Home', [AllowEmptyCollection()][object[]]$Trail = @(), [AllowEmptyString()][string]$Current = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('<div class="breadcrumbs-bar"><div class="container"><nav class="breadcrumbs" aria-label="Breadcrumb"><ol>')
    if (-not $Current) {
        [void]$sb.AppendLine('<li><span aria-current="page">' + (& $e $HomeLabel) + '</span></li>')
    } else {
        $sep = Get-BreadcrumbSep
        [void]$sb.AppendLine('<li><a href="' + (& $e $HomeHref) + '">' + (& $e $HomeLabel) + '</a></li>')
        foreach ($c in @($Trail | Where-Object { $_ })) { [void]$sb.AppendLine('<li>' + $sep + '<a href="' + (& $e $c.Href) + '">' + (& $e $c.Label) + '</a></li>') }
        [void]$sb.AppendLine('<li>' + $sep + '<span aria-current="page">' + (& $e $Current) + '</span></li>')
    }
    [void]$sb.AppendLine('</ol></nav></div></div>')
    return $sb.ToString()
}
function Format-SiteHeaderHtml {
    <#
        The house site header (house-product.css, "Site header"): the app's -Name on the primary, linking -Href
        (home). No mark (Dave, November 2, 2026), and no settings button (Maikel, November 3, 2026): the
        theme is chosen on its own /settings page, so the header no longer mounts #settings, and the pages' own
        DKJTheme.settings call finds no element and draws nothing. -Tag is the quieter word after the name
        ('admin', 'product'), left out when empty. Both are escaped here.
        -Menu is the app's main pages, each @{ Label; Href }, in order (house-product.css, "Site header menu"; Maikel,
        November 2, 2026): drawn after the brand, and again as the drawer a phone opens from
        the toggle. -Current is the Href of the one the page sits under, marked aria-current. No -Menu, no menu.
    #>
    param([Parameter(Mandatory = $true)][string]$Name, [string]$Href = '/', [AllowEmptyString()][string]$Tag = '',
        [AllowEmptyCollection()][object[]]$Menu = @(), [AllowEmptyString()][string]$Current = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $label = if ($Tag) { "$Name $Tag" } else { $Name }
    $tagHtml = if ($Tag) { ' <span class="site-header__tag">' + (& $e $Tag) + '</span>' } else { '' }
    $items = @($Menu | Where-Object { $_ -and $_.Label -and $_.Href })
    $nav = ''; $drawer = ''
    if ($items.Count) {
        $cur = { param($i) if ($Current -and $i.Href -eq $Current) { ' aria-current="page"' } else { '' } }
        $links = ($items | ForEach-Object { '<li><a href="' + (& $e $_.Href) + '"' + (& $cur $_) + '>' + (& $e $_.Label) + '</a></li>' }) -join ''
        $nav = '<nav class="site-header__nav" aria-label="Main"><ul class="site-header__menu">' + $links + '</ul>' +
            '<button class="site-header__menu-toggle" type="button" aria-controls="site-menu" aria-expanded="false" aria-label="Menu">' +
            '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 6h16M4 12h16M4 18h16"/></svg></button></nav>'
        $chevron = '<svg class="menu-item__chevron" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" focusable="false"><path fill="currentColor" fill-rule="evenodd" d="M9.793 16.707a1 1 0 0 1 0-1.414L13.086 12 9.793 8.707a1 1 0 0 1 1.414-1.414l4 4a1 1 0 0 1 0 1.414l-4 4a1 1 0 0 1-1.414 0" clip-rule="evenodd"/></svg>'
        $rows = ($items | ForEach-Object { '<a class="menu-item" href="' + (& $e $_.Href) + '"' + (& $cur $_) + '><span class="menu-item__label">' + (& $e $_.Label) + '</span>' + $chevron + '</a>' }) -join ''
        $drawer = '<dialog class="dialog dialog--drawer site-menu" id="site-menu" aria-label="Menu"><div class="dialog__body">' +
            '<div class="dialog__head"><p class="dialog__title">Menu</p></div>' +
            '<button class="dialog__close" type="button" aria-label="Close"><svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg></button>' +
            '<nav class="menu-list" aria-label="Main">' + $rows + '</nav></div></dialog>'
    }
    return '<header class="site-header"><div class="container"><a class="site-header__brand" href="' + (& $e $Href) + '" aria-label="' +
        (& $e $label) + ', home"><span class="site-header__name">' + (& $e $Name) +
        $tagHtml + '</span></a>' + $nav + '</div>' + $drawer + '</header>' + "`n"
}

function Get-SiteHeaderMenuCurrent {
    <#
        Which -Menu item a page sits under: the Href of its first parent crumb when it has one, else the item whose Label
        is the page's -Title. '' when neither names an item.
    #>
    param([AllowEmptyCollection()][object[]]$Menu = @(), [AllowEmptyString()][string]$Title = '', [AllowEmptyCollection()][object[]]$ParentCrumbs = @())
    $first = @($ParentCrumbs | Where-Object { $_ })[0]
    foreach ($i in @($Menu)) { if ($first -and $i.Href -eq $first.Href) { return $i.Href } }
    foreach ($i in @($Menu)) { if (-not $first -and $Title -and $i.Label -eq $Title) { return $i.Href } }
    return ''
}

function Format-ProductPageHtml {
    <#
        A product's whole page around -Body (#3540; moved here from dkj-policy's Format-GeneralPageHtml in #3831): the
        house site header with -Brand (the app's name) and -BrandTag (the word after it) linking -AdminHref, -Menu as its
        menu, then the breadcrumb bar from -HomeLabel through -ParentCrumbs to -Title, and the page column. No general
        banner: the banner is Admin's alone (Dave, November 4, 2026). Without -Brand there is no header, and the
        settings button floats instead.
        -Title is the page's own name: the last crumb, the h1 and the <title> (after -SiteName). -Lead is the page's
        <meta name="description">, never a paragraph under the h1 (#3585). -Style is the page's own layer. -Lead,
        -FooterNote, -HeadAside and -Info are markup the caller has escaped.
        -Bare leaves out the h1 above -Body, for a page that opens on its own content. -HeadAside sits at the far
        right of the h1's row, which is then the house page-header row (main > header). -Info is what the page is
        about, behind a drawn "?" right of the h1 (Get-PageInfoScript places its tooltip).
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Lead,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Body,
        [AllowEmptyString()][string]$Style = '',
        [AllowEmptyString()][string]$FooterNote = '',
        [string]$ThemeKey = 'general-pages',
        [AllowEmptyString()][string]$SiteName = '',
        [string]$AdminHref = '/',
        [AllowEmptyString()][string]$Brand = '',
        [AllowEmptyString()][string]$BrandTag = 'product',
        [switch]$Bare,
        [AllowEmptyCollection()][object[]]$ParentCrumbs = @(),
        [AllowEmptyString()][string]$HeadAside = '',
        [string]$HomeLabel = 'Home',
        [AllowEmptyString()][string]$Info = '',
        [AllowEmptyCollection()][object[]]$Menu = @()
    )
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append((Format-GeneralPageHeadHtml -Title $Title -Lead $Lead -Style $Style -ThemeKey $ThemeKey -SiteName $SiteName -Stylesheets (Get-ProductStylesheets)))
    if ($Brand) { [void]$sb.Append((Format-SiteHeaderHtml -Name $Brand -Href $AdminHref -Tag $BrandTag -Menu $Menu -Current (Get-SiteHeaderMenuCurrent -Menu $Menu -Title $Title -ParentCrumbs $ParentCrumbs))) }
    [void]$sb.Append((Format-ProductBreadcrumbBarHtml -HomeHref $AdminHref -HomeLabel $HomeLabel -Trail $ParentCrumbs -Current $Title))
    if (-not $Brand) { [void]$sb.AppendLine('<div id="settings" class="theme-settings--floating"></div>') }
    [void]$sb.AppendLine('<main class="page-column">')
    if (-not $Bare) {
        if ($HeadAside) { [void]$sb.AppendLine('<header>') }
        [void]$sb.AppendLine('<div>')
        if ($Info) {
            # The h1 and its "?" on one row; the tooltip is fixed, placed by Get-PageInfoScript beside the button. The
            # glyph is drawn, so it never leans on a font's baseline; its ring is the button's CSS border, in a 44px
            # button that is all tap target (Maikel, October 31, 2026).
            [void]$sb.AppendLine('<div class="page-title"><h1>' + (& $e $Title) + '</h1><button class="page-info-button" type="button" id="page-info-button" aria-label="About ' + (& $e $Title) + '" aria-describedby="page-info" aria-expanded="false">' + (Get-PageInfoGlyph) + '</button></div>')
            [void]$sb.AppendLine('<div class="tooltip tooltip--explain" id="page-info" role="tooltip">' + $Info + '</div>')
        } else {
            [void]$sb.AppendLine('<h1>' + (& $e $Title) + '</h1>')
        }
        [void]$sb.AppendLine('</div>')
        if ($HeadAside) { [void]$sb.AppendLine($HeadAside); [void]$sb.AppendLine('</header>') }
    }
    $longWarn = Get-LongPageWarningHtml -Body $Body
    if ($longWarn) { [void]$sb.AppendLine($longWarn) }
    [void]$sb.Append($Body)
    if ($FooterNote) { [void]$sb.AppendLine('<p class="note">' + $FooterNote + '</p>') }
    [void]$sb.AppendLine('</main>')
    [void]$sb.AppendLine('<script>DKJTheme.settings(document.getElementById("settings"), { label: "Settings", title: "Settings", theme: "Theme", reset: "Reset theme", light: "Light", dark: "Dark", widths: false });</script>')
    if ($Info -and -not $Bare) { [void]$sb.AppendLine((Get-PageInfoScript)) }
    [void]$sb.AppendLine((Format-FitAlarmHtml))
    [void]$sb.AppendLine('</body>')
    [void]$sb.AppendLine('</html>')
    return $sb.ToString()
}

function Format-ProductHomeHeadHtml {
    <#
        The top of a product's home page on '/' (#3540; moved here from dkj-policy's Format-RepoHomeHeadHtml in
        #3831): the site header with -Brand and -BrandTag, -Menu as its menu (the home page sits under none of its
        items), the breadcrumb bar with its one crumb, -HomeLabel, and the opening of <main>. Under a site header there
        is no intro: the header names the product, and the page goes straight to its sections (owner, October 22,
        2026). Without -Brand the settings button floats and the intro is the h1 -RepoName (escaped by the caller), in
        a <div>, never a <header>, which the house style lays out as a flex row. The caller writes the <head> and
        '<body>' before it, linking /house-style.css and then /house-product.css, and the sections and </main> after it.
    #>
    param([Parameter(Mandatory = $true)][string]$RepoName, [AllowEmptyString()][string]$Brand = '', [AllowEmptyString()][string]$BrandTag = 'product',
        [string]$HomeLabel = 'Home', [AllowEmptyCollection()][object[]]$Menu = @())
    $sb = New-Object System.Text.StringBuilder
    if ($Brand) { [void]$sb.Append((Format-SiteHeaderHtml -Name $Brand -Href '/' -Tag $BrandTag -Menu $Menu)) }
    [void]$sb.Append((Format-ProductBreadcrumbBarHtml -HomeLabel $HomeLabel))
    if (-not $Brand) { [void]$sb.AppendLine('<div id="settings" class="theme-settings--floating"></div>') }
    [void]$sb.AppendLine('<main class="page-column">')
    if (-not $Brand) {
        [void]$sb.AppendLine('<div>')
        [void]$sb.AppendLine('<h1>' + $RepoName + '</h1>')
        [void]$sb.AppendLine('</div>')
    }
    return $sb.ToString()
}
function Join-HouseStyleSpecimens {
    <#
        The whole brand book's specimens as one body (#3831): dkj-policy's assets/dkj-brandbook/specimens.html (-Core)
        joined with this plugin's assets/dkj-brandbook-product/specimens.html (-Product), in the one shape
        Split-HouseStyleSpecimens reads, so the product server shows every specimen while Admin, which renders without
        the product layer, shows the core file alone. A product section whose slug the core also has adds its cards
        after the core's, under the core's head line; any other comes after the product section before it (or first),
        so the original order holds. The head is the core's (the .spec-* layout and the hs-* sprite both files use),
        and the tail the product's dialogs before the core's script, which opens them and draws the theme picker. An
        empty -Product returns -Core as it came.
    #>
    param([AllowEmptyString()][string]$Core = '', [AllowEmptyString()][string]$Product = '')
    if (-not $Product.Trim()) { return $Core }
    $c = Split-HouseStyleSpecimens -Body $Core
    $p = Split-HouseStyleSpecimens -Body $Product
    $list = New-Object System.Collections.Generic.List[hashtable]
    foreach ($s in @($c.Sections)) { $list.Add(@{ Grid = $s.Grid; Slug = $s.Slug; Title = $s.Title; Sub = $s.Sub; Inner = $s.Inner }) }
    $at = -1
    foreach ($s in @($p.Sections)) {
        $i = -1
        for ($k = 0; $k -lt $list.Count; $k++) { if ($list[$k].Slug -ceq $s.Slug) { $i = $k; break } }
        if ($i -ge 0) { $list[$i].Inner += $s.Inner; $at = $i }
        else { $at++; $list.Insert($at, @{ Grid = $s.Grid; Slug = $s.Slug; Title = $s.Title; Sub = $s.Sub; Inner = $s.Inner }) }
    }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append($c.Head)
    [void]$sb.Append('<div class="spec-page">' + "`n")
    foreach ($s in $list) {
        [void]$sb.Append('<div class="' + $s.Grid + '">' + "`n" + '  <div class="grid__head"><h2 id="hs-' + $s.Slug + '">' + [System.Net.WebUtility]::HtmlEncode($s.Title) +
            '</h2><p class="card__sub">' + $s.Sub + '</p></div>' + "`n" + $s.Inner + '</div>' + "`n")
    }
    [void]$sb.Append('</div>' + "`n")
    [void]$sb.Append($p.Tail.TrimEnd() + "`n" + $c.Tail)
    return $sb.ToString()
}