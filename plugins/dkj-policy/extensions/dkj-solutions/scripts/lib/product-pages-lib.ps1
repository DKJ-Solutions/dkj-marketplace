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
        November 2, 2026): drawn after the brand, and again as the full-screen menu a phone opens from
        the toggle. -Current is the Href of the one the page sits under, marked aria-current. No -Menu, no menu.
        -Back (@{ Label; Href }, the parent page) and -PageTitle (the page's own name) are what a phone shows in place
        of the breadcrumb bar (#4048, house-product.css "Site header on a phone"): a back cell first in the header and
        the title after the brand, both hidden on a wide header. A page below home passes both; home passes neither.
        THE MENU (#4095) opens full screen (dialog.dialog--screen.site-menu, Figma Product / Menu row, Menu section head
        and Menu footer): a Pages section with -Menu's items (each may carry a Sub line), a Settings section with one
        gear row to -SettingsHref where the app has a settings page (the gear's place on a phone, #4124), and an About section ending in
        the app's -Name and -MenuNote (e.g. the brand book version), each left out when its input is.
        THE ACTIONS SHEET (#4095, Figma Product / Sheet): -Actions, the page's own actions (each @{ Label; Href }),
        adds a More cell that opens them as a sheet titled -PageTitle, from two actions up. A single action is drawn
        directly as its own icon cell, a.site-header__action, with no sheet (#4123); its optional Icon is 'download'
        (the default) or 'print'.
        -Path is accepted and does nothing: the phone's title is plain text, never a button opening the path as a
        sheet (Dave, November 15, 2026; dkj-lifehub's header has none). Kept so a caller that still passes it does not
        fail on a parameter that is gone; the back cell is the way up.
        -NoMenuToggle leaves the three-line toggle out while the links and the menu stay (#4094): a page with a bottom
        bar opens the menu from its More instead (Figma Menu toggle=false).
        -NoMenuDialog leaves the full-screen menu out too (#4125): a page whose bottom bar's More is a page of its own
        (Format-BottomBarHtml -MoreHref) has nothing to open it, so the dialog would be dead markup. The links stay.
    #>
    param([Parameter(Mandatory = $true)][string]$Name, [string]$Href = '/', [AllowEmptyString()][string]$Tag = '',
        [AllowEmptyCollection()][object[]]$Menu = @(), [AllowEmptyString()][string]$Current = '',
        [object]$Back = $null, [AllowEmptyString()][string]$PageTitle = '',
        [AllowEmptyCollection()][object[]]$Path = @(), [AllowEmptyCollection()][object[]]$Actions = @(),
        [AllowEmptyString()][string]$SettingsHref = '', [AllowEmptyString()][string]$MenuNote = '', [switch]$NoMenuToggle, [switch]$NoMenuDialog)
    $e = { param($v) ConvertTo-GeneralPageText $v }
    # The house chevron, mirrored to point left (back).
    $chevLeft = '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path transform="matrix(-1 0 0 1 24 0)" fill="currentColor" fill-rule="evenodd" d="' + (Get-MenuChevronPath) + '" clip-rule="evenodd"/></svg>'
    $row = { param($i, [string]$cur) Format-MenuItemHtml -Item $i -Current $cur }
    $sheet = {
        param([string]$Id, [string]$Label, [string]$Title, [string]$Rows)
        '<dialog class="dialog dialog--sheet" id="' + $Id + '" aria-label="' + (& $e $Label) + '"><div class="dialog__body"><span class="dialog__handle" aria-hidden="true"></span>' +
            $(if ($Title) { '<p class="dialog__title">' + (& $e $Title) + '</p>' } else { '' }) +
            '<nav class="menu-list" aria-label="' + (& $e $Label) + '">' + $Rows + '</nav></div></dialog>'
    }
    $backHtml = ''; $titleHtml = ''; $dialogs = ''
    if ($Back -and $Back.Href) {
        $backHtml = '<a class="site-header__back" href="' + (& $e $Back.Href) + '" aria-label="Back to ' + (& $e $Back.Label) + '">' + $chevLeft + '</a>'
        if ($PageTitle) { $titleHtml = '<span class="site-header__title" aria-hidden="true">' + (& $e $PageTitle) + '</span>' }
    }
    $label = if ($Tag) { "$Name $Tag" } else { $Name }
    $tagHtml = if ($Tag) { ' <span class="site-header__tag">' + (& $e $Tag) + '</span>' } else { '' }
    $acts = @($Actions | Where-Object { $_ -and $_.Label -and $_.Href })
    $moreHtml = ''
    if ($acts.Count -eq 1) {
        # One action is shown directly, as its own icon cell: three dots opening a sheet of one item is an extra tap
        # and an empty promise (#4123). The action's Icon names the glyph, 'download' (the default) or 'print'.
        $a = $acts[0]
        $glyph = if ("$($a.Icon)" -eq 'print') {
            'M7 3h10v4h2a2 2 0 0 1 2 2v7h-4v5H7v-5H3V9a2 2 0 0 1 2-2h2zm2 2v2h6V5zm0 10v4h6v-4z'
        } else { 'M11 4h2v8.586l3.293-3.293 1.414 1.414L12 16.414l-5.707-5.707 1.414-1.414L11 12.586zM5 18h14v2H5z' }
        $moreHtml = '<a class="site-header__action" href="' + (& $e $a.Href) + '" aria-label="' + (& $e $a.Label) + '" title="' + (& $e $a.Label) + '">' +
            '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path fill="currentColor" fill-rule="evenodd" d="' + $glyph + '"/></svg></a>'
    } elseif ($acts.Count) {
        $moreHtml = '<button class="site-header__more" type="button" aria-controls="site-actions" aria-expanded="false" aria-haspopup="dialog" aria-label="More actions">' +
            '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg></button>'
        $dialogs += & $sheet 'site-actions' 'Actions' $PageTitle (($acts | ForEach-Object { & $row $_ '' }) -join '')
    }
    $items = @($Menu | Where-Object { $_ -and $_.Label -and $_.Href })
    $nav = ''
    if ($items.Count) {
        $cur = { param($i) if ($Current -and $i.Href -eq $Current) { ' aria-current="page"' } else { '' } }
        $links = ($items | ForEach-Object { '<li><a href="' + (& $e $_.Href) + '"' + (& $cur $_) + '>' + (& $e $_.Label) + '</a></li>' }) -join ''
        $toggle = if ($NoMenuToggle) { '' } else {
            '<button class="site-header__menu-toggle" type="button" aria-controls="site-menu" aria-expanded="false" aria-label="Menu">' + (Get-MenuLinesGlyph) + '</button>' }
        $nav = '<nav class="site-header__nav" aria-label="Main"><ul class="site-header__menu">' + $links + '</ul>' + $toggle + '</nav>'
        if (-not $NoMenuDialog) {
            $dialogs = '<dialog class="dialog dialog--screen site-menu" id="site-menu" aria-label="Menu"><div class="dialog__body">' +
                '<div class="dialog__head dialog__head--back"><p class="dialog__title">Menu</p></div>' +
                '<button class="dialog__close dialog__close--back" type="button" aria-label="Close the menu">' + $chevLeft + '</button>' +
                (Format-SiteMenuSectionsHtml -Name $Name -Menu $items -Current $Current -SettingsHref $SettingsHref -MenuNote $MenuNote) + '</div></dialog>' + $dialogs
        }
    }
    return '<header class="site-header"><div class="container">' + $backHtml + '<a class="site-header__brand" href="' + (& $e $Href) + '" aria-label="' +
        (& $e $label) + ', home"><span class="site-header__name">' + (& $e $Name) +
        $tagHtml + '</span></a>' + $titleHtml + $moreHtml + $nav + '</div>' + $dialogs + '</header>' + "`n"
}

function Get-MenuChevronPath {
    <# The house chevron's path, pointing right: a menu row's end, and mirrored, the header's back cell. #>
    return 'M9.793 16.707a1 1 0 0 1 0-1.414L13.086 12 9.793 8.707a1 1 0 0 1 1.414-1.414l4 4a1 1 0 0 1 0 1.414l-4 4a1 1 0 0 1-1.414 0'
}

function Format-MenuItemHtml {
    <#
        One .menu-item row (house-product.css, "Full-screen dialog" and "Sheet"): -Item is @{ Label; Href; Sub; Value;
        Icon }, the label, sub line and value escaped here; Icon is markup this lib drew itself (the gear), never caller
        text. -Current is the attribute text that marks the page it sits under (' aria-current="page"'), or ''.
    #>
    param([Parameter(Mandatory = $true)][object]$Item, [AllowEmptyString()][string]$Current = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $sub = if ($Item.Sub) { '<span class="menu-item__sub">' + (& $e $Item.Sub) + '</span>' } else { '' }
    $aside = if ($Item.Value) { '<span class="menu-item__aside">' + (& $e $Item.Value) + '</span>' } else { '' }
    $icon = if ($Item.Icon) { [string]$Item.Icon } else { '' }
    $chevron = '<svg class="menu-item__chevron" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" focusable="false"><path fill="currentColor" fill-rule="evenodd" d="' + (Get-MenuChevronPath) + '" clip-rule="evenodd"/></svg>'
    return '<a class="menu-item" href="' + (& $e $Item.Href) + '"' + $Current + '>' + $icon + '<span class="menu-item__label">' + (& $e $Item.Label) + $sub + '</span>' + $aside + $chevron + '</a>'
}

function Format-SiteMenuSectionsHtml {
    <#
        The site menu's sections (#4095), one renderer for its two places (#4125): inside the full-screen dialog the
        header draws, and on the More page a bottom bar links to (Format-ProductMoreBodyHtml). A Pages section with
        -Menu's items (each @{ Label; Href }, optionally Sub), the one whose Href is -Current marked; a Settings section
        with one gear row to -SettingsHref (#4124); an About section; and the foot with the app's -Name and -MenuNote.
        Each is left out when its input is. Every label is escaped here.
    #>
    param([Parameter(Mandatory = $true)][string]$Name, [AllowEmptyCollection()][object[]]$Menu = @(), [AllowEmptyString()][string]$Current = '',
        [AllowEmptyString()][string]$SettingsHref = '', [AllowEmptyString()][string]$MenuNote = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $items = @($Menu | Where-Object { $_ -and $_.Label -and $_.Href })
    $sections = '<p class="menu-section">Pages</p>' + (($items | ForEach-Object {
        Format-MenuItemHtml -Item $_ -Current $(if ($Current -and $_.Href -eq $Current) { ' aria-current="page"' } else { '' }) }) -join '')
    if ($SettingsHref) {
        # The gear means settings in every DKJ product (#4124), so the row carries the house gear house-theme.js draws.
        $gear = '<svg class="menu-item__icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false" fill="currentColor"><path fill-rule="evenodd" d="' +
            'M9.79 4.31L10.55 1.7L13.45 1.7L14.21 4.31A8 8 0 0 1 15.88 5L18.26 3.69L20.31 5.74L19 8.12A8 8 0 0 1 19.69 9.79L22.3 10.55L22.3 13.45L19.69 14.21' +
            'A8 8 0 0 1 19 15.88L20.31 18.26L18.26 20.31L15.88 19A8 8 0 0 1 14.21 19.69L13.45 22.3L10.55 22.3L9.79 19.69A8 8 0 0 1 8.12 19L5.74 20.31L3.69 18.26' +
            'L5 15.88A8 8 0 0 1 4.31 14.21L1.7 13.45L1.7 10.55L4.31 9.79A8 8 0 0 1 5 8.12L3.69 5.74L5.74 3.69L8.12 5A8 8 0 0 1 9.79 4.31Z' +
            'M16.85 12a4.85 4.85 0 1 0-9.7 0a4.85 4.85 0 1 0 9.7 0z"/></svg>'
        $sections += '<p class="menu-section">Settings</p>' + (Format-MenuItemHtml -Item @{ Label = 'Settings'; Sub = 'Light or dark, theme, width'; Href = $SettingsHref; Icon = $gear })
    }
    $sections += '<p class="menu-section">About</p>'
    $footer = '<div class="menu-footer"><p class="menu-footer__name">' + (& $e $Name) + '</p>' +
        $(if ($MenuNote) { '<p class="menu-footer__note">' + (& $e $MenuNote) + '</p>' } else { '' }) + '</div>'
    return '<nav class="menu-list" aria-label="Main">' + $sections + '</nav>' + $footer
}

function Get-MenuLinesGlyph {
    <# The three lines that open the site menu: the header's toggle and, by default, the bottom bar's More (#4094). #>
    return '<svg viewBox="0 0 24 24" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 6h16M4 12h16M4 18h16"/></svg>'
}

function Format-BottomBarHtml {
    <#
        The bottom bar (house-product.css, "Bottom bar"; #4094): -Items are the app's sections, three or four, each
        @{ Label; Href; Icon }, then More, always last, a button opening the site menu (#site-menu, which
        Format-SiteHeaderHtml draws from its -Menu). So the bar has four slots or five. -Current is the Href of the
        section the page sits under, marked aria-current. Icon is optional markup the caller supplies (an inline <svg>,
        not escaped); a label is escaped here. -MoreLabel and -MoreIcon name and draw More (the menu's three lines by
        default). Any other count of items throws: the bar has no room for a sixth slot, and two slots are no bar.
        -MoreHref makes More a destination like the other slots (#4125): a link to the product's More page
        (Format-ProductMoreBodyHtml), marked aria-current where -Current is that Href, so it has a URL, the phone's back
        gesture leaves it as it leaves any page, and the bar says where you are. Without it More stays the button that
        opens the full-screen menu.
    #>
    param([Parameter(Mandatory = $true)][object[]]$Items, [AllowEmptyString()][string]$Current = '',
        [string]$MoreLabel = 'More', [AllowEmptyString()][string]$MoreIcon = '', [AllowEmptyString()][string]$MoreHref = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $list = @($Items | Where-Object { $_ -and $_.Label -and $_.Href })
    if ($list.Count -lt 3 -or $list.Count -gt 4) { throw "Format-BottomBarHtml: a bottom bar takes 3 or 4 sections before More (4 or 5 slots), got $($list.Count)." }
    $icon = { param($svg) if ($svg) { '<span class="bottom-bar__icon">' + $svg + '</span>' } else { '' } }
    $slots = ($list | ForEach-Object {
        $cur = if ($Current -and $_.Href -eq $Current) { ' aria-current="page"' } else { '' }
        '<a class="bottom-bar__item" href="' + (& $e $_.Href) + '"' + $cur + '>' + (& $icon ([string]$_.Icon)) + '<span class="bottom-bar__label">' + (& $e $_.Label) + '</span></a>'
    }) -join ''
    $moreSvg = if ($MoreIcon) { $MoreIcon } else { Get-MenuLinesGlyph }
    $more = if ($MoreHref) {
        $moreCur = if ($Current -and $MoreHref -eq $Current) { ' aria-current="page"' } else { '' }
        '<a class="bottom-bar__item" href="' + (& $e $MoreHref) + '"' + $moreCur + '>' + (& $icon $moreSvg) + '<span class="bottom-bar__label">' + (& $e $MoreLabel) + '</span></a>'
    } else {
        '<button class="bottom-bar__item bottom-bar__more" type="button" aria-controls="site-menu" aria-expanded="false">' +
            (& $icon $moreSvg) + '<span class="bottom-bar__label">' + (& $e $MoreLabel) + '</span></button>'
    }
    return '<nav class="bottom-bar" aria-label="Sections">' + $slots + $more + '</nav>' + "`n"
}

function Get-SiteHeaderBack {
    <#
        The page a phone's back cell goes to (#4048): the last crumb of -Trail, else home (-HomeLabel at -HomeHref) --
        one level up, as the breadcrumb bar it replaces would.
    #>
    param([string]$HomeHref = '/', [string]$HomeLabel = 'Home', [AllowEmptyCollection()][object[]]$Trail = @())
    $last = @($Trail | Where-Object { $_ -and $_.Href }) | Select-Object -Last 1
    if ($last) { return @{ Label = [string]$last.Label; Href = [string]$last.Href } }
    return @{ Label = $HomeLabel; Href = $HomeHref }
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

function Assert-BottomBarHasMenu {
    <# A bottom bar's More opens the menu the site header draws from -Menu, or links to the page that renders it (#4125), so a bar without both has a dead More (#4094). #>
    param([AllowEmptyCollection()][object[]]$BottomBar = @(), [AllowEmptyString()][string]$Brand = '', [AllowEmptyCollection()][object[]]$Menu = @())
    if (@($BottomBar).Count -and -not ($Brand -and @($Menu | Where-Object { $_ -and $_.Label -and $_.Href }).Count)) {
        throw 'A -BottomBar needs -Brand and -Menu: its More opens the site menu the header draws from -Menu.'
    }
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
        -Actions, -SettingsHref and -MenuNote go to the site header as they are (#4095): the page's own actions behind
        the More cell, the Settings row of the full-screen menu, and the menu's foot line.
        -BottomBar is the app's sections for a phone's bottom bar (Format-BottomBarHtml, #4094), three or four, with
        -MoreLabel naming its last slot; the header then leaves its toggle out, since More opens the menu. It needs
        -Brand and -Menu, because More opens the menu the header draws from -Menu.
        -MoreHref makes More a link to the product's More page (#4125, Format-ProductMoreBodyHtml), which renders that
        same menu; the header then leaves the dialog out as well, and More is current on the More page (the page whose
        -Title is -MoreLabel) and on every page whose first parent crumb is it.
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
        [AllowEmptyCollection()][object[]]$Menu = @(),
        [AllowEmptyCollection()][object[]]$Actions = @(),
        [AllowEmptyString()][string]$SettingsHref = '',
        [AllowEmptyString()][string]$MenuNote = '',
        [AllowEmptyCollection()][object[]]$BottomBar = @(),
        [string]$MoreLabel = 'More',
        [AllowEmptyString()][string]$MoreHref = ''
    )
    Assert-BottomBarHasMenu -BottomBar $BottomBar -Brand $Brand -Menu $Menu
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append((Format-GeneralPageHeadHtml -Title $Title -Lead $Lead -Style $Style -ThemeKey $ThemeKey -SiteName $SiteName -Stylesheets (Get-ProductStylesheets)))
    if ($Brand) { [void]$sb.Append((Format-SiteHeaderHtml -Name $Brand -Href $AdminHref -Tag $BrandTag -Menu $Menu -Current (Get-SiteHeaderMenuCurrent -Menu $Menu -Title $Title -ParentCrumbs $ParentCrumbs) `
        -Back (Get-SiteHeaderBack -HomeHref $AdminHref -HomeLabel $HomeLabel -Trail $ParentCrumbs) -PageTitle $Title `
        -Actions $Actions -SettingsHref $SettingsHref -MenuNote $MenuNote -NoMenuToggle:([bool]@($BottomBar).Count) -NoMenuDialog:([bool](@($BottomBar).Count -and $MoreHref)))) }
    [void]$sb.Append((Format-ProductBreadcrumbBarHtml -HomeHref $AdminHref -HomeLabel $HomeLabel -Trail $ParentCrumbs -Current $Title))
    if (@($BottomBar).Count) {
        # More counts as a section of its own once it is a page (#4125), so the More page and the pages under it mark it.
        $slots = @($BottomBar) + $(if ($MoreHref) { @(@{ Label = $MoreLabel; Href = $MoreHref }) } else { @() })
        [void]$sb.Append((Format-BottomBarHtml -Items $BottomBar -MoreLabel $MoreLabel -MoreHref $MoreHref -Current (Get-SiteHeaderMenuCurrent -Menu $slots -Title $Title -ParentCrumbs $ParentCrumbs)))
    }
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
    # .page-source: the source note leaves a phone, where the wireframes draw none (#4113).
    if ($FooterNote) { [void]$sb.AppendLine('<p class="note page-source">' + $FooterNote + '</p>') }
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
        -BottomBar, -MoreLabel and -MoreHref are Format-ProductPageHtml's (#4094, #4125); the home section is current where
        its Href is '/'.
    #>
    param([Parameter(Mandatory = $true)][string]$RepoName, [AllowEmptyString()][string]$Brand = '', [AllowEmptyString()][string]$BrandTag = 'product',
        [string]$HomeLabel = 'Home', [AllowEmptyCollection()][object[]]$Menu = @(), [AllowEmptyCollection()][object[]]$BottomBar = @(), [string]$MoreLabel = 'More',
        [AllowEmptyString()][string]$MoreHref = '')
    Assert-BottomBarHasMenu -BottomBar $BottomBar -Brand $Brand -Menu $Menu
    $sb = New-Object System.Text.StringBuilder
    if ($Brand) { [void]$sb.Append((Format-SiteHeaderHtml -Name $Brand -Href '/' -Tag $BrandTag -Menu $Menu -NoMenuToggle:([bool]@($BottomBar).Count) -NoMenuDialog:([bool](@($BottomBar).Count -and $MoreHref)))) }
    [void]$sb.Append((Format-ProductBreadcrumbBarHtml -HomeLabel $HomeLabel))
    if (@($BottomBar).Count) { [void]$sb.Append((Format-BottomBarHtml -Items $BottomBar -MoreLabel $MoreLabel -MoreHref $MoreHref -Current '/')) }
    if (-not $Brand) { [void]$sb.AppendLine('<div id="settings" class="theme-settings--floating"></div>') }
    [void]$sb.AppendLine('<main class="page-column">')
    if (-not $Brand) {
        [void]$sb.AppendLine('<div>')
        [void]$sb.AppendLine('<h1>' + $RepoName + '</h1>')
        [void]$sb.AppendLine('</div>')
    }
    return $sb.ToString()
}
function Format-ProductMoreBodyHtml {
    <#
        The body of a product's More page (#4125): the page a bottom bar's More links to (Format-BottomBarHtml
        -MoreHref), holding the site menu's own sections (Format-SiteMenuSectionsHtml) in a .menu-page, so they read as
        they do in the full-screen dialog. The caller wraps it with Format-ProductPageHtml -Title <its More label>
        -MoreHref <this page>, which marks More current. Arguments as Format-SiteMenuSectionsHtml's.
    #>
    param([Parameter(Mandatory = $true)][string]$Name, [AllowEmptyCollection()][object[]]$Menu = @(), [AllowEmptyString()][string]$Current = '',
        [AllowEmptyString()][string]$SettingsHref = '', [AllowEmptyString()][string]$MenuNote = '')
    return '<div class="menu-page">' + (Format-SiteMenuSectionsHtml -Name $Name -Menu $Menu -Current $Current -SettingsHref $SettingsHref -MenuNote $MenuNote) + '</div>' + "`n"
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