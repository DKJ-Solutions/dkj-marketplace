<#
.SYNOPSIS
    Tests for scripts/lib/dev-pages-lib.ps1 -- Admin and the test-gate page of the dev server
    (#3097) -- and for the plugin libs it reuses: plugins/dkj-policy/apps/admin/lib/general-pages-lib.ps1 -- the page
    shell, the number formats and the three general pages (SessionStart, Issues, Release notes) that
    moved there in #3119, and to dkj-policy in #3198. Pure: the servers that serve them are
    exercised by consumer-dashboard.tests.ps1 and dev-preview-sessionstart.tests.ps1.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $RepoRoot 'scripts\lib\dev-pages-lib.ps1')
# The Test gate page's lib, which this suite also covers: the plugin's since #3470, and no longer loaded by
# dev-pages-lib now that the Test gate is the plugin admin's alone (#3540).
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\test-gate-lib.ps1')

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
# A statement that throws -- a malformed -match pattern inside an assert, #3257 -- is skipped under
# 'Continue', so the suite would end green without ever evaluating it. Count it instead (as #1881 does).
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -eq "$Actual") ($Name + $(if ("$Expected" -ne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

Write-Host '-- the number formats' -ForegroundColor Cyan
Assert-Equal '58,895' (Format-DevNumber 58895) 'thousands separators, whatever the culture'
Assert-Equal '--' (Format-DevNumber $null) 'a value not read is --'
Assert-Equal '7.6s' (Format-DevSeconds 7.6) 'under a minute: seconds with one decimal'
Assert-Equal '23:22' (Format-DevSeconds 1402) 'from a minute: m:ss'
Assert-Equal '59.6s' (Format-DevSeconds 59.6) 'just under a minute stays in seconds'
Assert-Equal '1:38:47' (Format-DevSeconds 5927) 'from an hour: h:mm:ss, so a long sum does not read as minutes'
Assert-Equal '59:59' (Format-DevSeconds 3599) 'and just under an hour stays m:ss'

Write-Host '-- the page shell' -ForegroundColor Cyan
$shell = Format-DevPageHtml -Title 'A <b>page' -Lead 'lead' -Body '<p>body</p>' -FooterNote 'note'
Assert-True ($shell.IndexOf('<div class="breadcrumbs-bar">') -lt $shell.IndexOf('<main')) 'the breadcrumb bar comes before <main>'
Assert-True ($shell -match '<li><a href="/">Home</a></li>') 'the trail starts at Home, linked'
Assert-True ($shell -match 'breadcrumbs__sep" aria-hidden="true"><svg\ viewBox="0\ 0\ 24\ 24"><path\ fill="currentColor"\ fill-rule="evenodd"\ d="M9\.793\ 16\.707a1\ 1\ 0\ 0\ 1\ 0-1\.414L13\.086\ 12\ 9\.793\ 8\.707a1\ 1\ 0\ 0\ 1\ 1\.414-1\.414l4\ 4a1\ 1\ 0\ 0\ 1\ 0\ 1\.414l-4\ 4a1\ 1\ 0\ 0\ 1-1\.414\ 0"\ clip-rule="evenodd"/></svg></span><span aria-current="page">A &lt;b&gt;page</span>') 'and ends at the page, unlinked and escaped'
Assert-True ($shell -match '<h1>A &lt;b&gt;page</h1>') 'the h1 is the page name, escaped'
Assert-True ($shell -match 'data-theme-key="general-pages"') 'the theme key is the general pages'' own, so a theme picked on any page Admin serves holds on all of them (#3168)'
Assert-True ($shell -match '<p class="note">note</p>') 'the footer note closes the column'

Write-Host '-- the general page shell (the plugin''s)' -ForegroundColor Cyan
$gshell = Format-GeneralPageHtml -Title 'An <i>issue' -Lead 'lead' -Body '<p>body</p>' -SiteName 'Org/some<repo>'
Assert-True ($gshell -match '<li><a href="/">Home</a></li>') 'the first crumb goes to the general server''s own root, /'
# A ADMIN PAGE STANDS IN THE DESKTOP SHELL (#3811): the repo's name now lives in the <title> alone; no site header, no eyebrow.
Assert-True ($gshell -match '<title>Org/some&lt;repo&gt; -- An &lt;i&gt;issue</title>' -and ([regex]::Replace($gshell, '<title>.*?</title>', '')) -notmatch 'Org/some' -and $gshell -notmatch 'class="eyebrow"') 'the <title> carries the repo''s name, escaped, and it is the only place the name stands: an Admin page has no site header and a named page needs no eyebrow'
Assert-True ($gshell -match 'class="shell shell--no-aside"' -and $gshell -notmatch 'site-header' -and $gshell -notmatch 'breadcrumbs-bar' -and $gshell -notmatch 'page-title') 'an Admin page stands in the desktop shell: no site header, no breadcrumb bar (#3811)'
Assert-True ($shell -match 'class="breadcrumbs-bar"' -and $shell -notmatch 'class="shell' -and (Format-ProductPageHtml -Title 'P' -Lead '' -Body '' -Brand 'prod') -match 'class="site-header"' -and (Format-ProductPageHtml -Title 'P' -Lead '' -Body '' -Brand 'prod') -match 'class="breadcrumbs-bar"' -and (Format-ProductPageHtml -Title 'P' -Lead '' -Body '' -Brand 'prod') -notmatch 'class="shell') 'a product page keeps the site header and the breadcrumb bar, and takes no shell (#3811; drawn by dkj-solutions since #3831)'
$refused = ''; try { $null = Format-GeneralPageHtml -Title 'P' -Lead '' -Body '' -Brand 'prod' -BrandTag 'product' } catch { $refused = $_.Exception.Message }
Assert-True ($refused -match 'Format-ProductPageHtml' -and $refused -match '#3831') 'dkj-policy draws Admin pages only: -BrandTag product is refused, naming the dkj-solutions renderer (#3831)'
$prodPage = Format-ProductPageHtml -Title 'P' -Lead '' -Body ''
Assert-True ($prodPage.IndexOf('<link rel="stylesheet" href="/house-style.css">') -ge 0 -and $prodPage.IndexOf('<link rel="stylesheet" href="/house-product.css">') -gt $prodPage.IndexOf('<link rel="stylesheet" href="/house-style.css">') -and $gshell -notmatch 'house-product\.css') 'a product page links the product layer after the core, and an Admin page never links it (#3831)'
Assert-True ($gshell -match 'data-theme-key="general-pages"') 'the theme key is the general server''s own'
Assert-True ($gshell -notmatch 'dkj-claude-plugins') 'and nothing of this repo is built into it'
$gIntro = $gshell.IndexOf('<h1>')
$gScroll = $gshell.IndexOf('<div class="shell__list tb-scroll">')
Assert-True ($gshell.Contains((Format-RepoAdminBanner)) -and $gScroll -ge 0 -and $gshell.IndexOf('id="admin-banner"') -gt $gScroll -and $gshell.IndexOf('id="admin-banner"') -lt $gshell.IndexOf('<main class="shell__body">') -and $gshell.IndexOf('<main class="shell__body">') -lt $gshell.IndexOf('<p>body</p>') -and ([regex]::Matches($gshell, 'id="admin-banner"')).Count -eq 1) 'every page carries the general banner once, as the first thing in the scroll pane, above its own blocks, in the pane body (#3297; owner, October 24, 2026; in the shell, #3811)'
Assert-True ($gshell -match '<div class="shell__list tb-scroll">?
<div class="notice" id="admin-banner"' -and $gshell -match '<main class="shell__body">?
<div class="page-head"><div class="page-head__title"><h1>An &lt;i&gt;issue</h1></div></div>?
<p>body</p>' -and $gshell.IndexOf('<h1>') -gt $gshell.IndexOf('id="admin-banner"') -and $gshell -notmatch 'class="toolbar"') 'the page''s h1 is the page header''s, the first thing in the pane body after the banner, with its own blocks beneath, and no toolbar above the pane (the Figma wireframes, November 12, 2026)'
# THE SITE HEADER (October 22, 2026): only where a caller asks for it with -Brand, so every other repo's pages stay as they were.
$anon = Format-GeneralPageHtml -Title 'T' -Lead 'L' -Body ''
Assert-True ($anon -notmatch 'site-header' -and $anon -match 'class="shell shell--no-aside"' -and $anon -notmatch 'theme-settings--floating') 'a page that names no site draws no site header and no floating settings button: it stands in the shell (#3811)'
Assert-True ((ConvertTo-SiteHeaderName -RepoName 'DKJ-Solutions/dkj-x') -eq 'dkj-x' -and (ConvertTo-SiteHeaderName -RepoName 'a/b<c>') -eq 'a/b<c>') 'a GitHub slug loses its owner in the header; any other name stays whole'
$bshell = Format-GeneralPageHtml -Title 'T' -Lead 'L' -Body '' -Brand 'r<x>' -AdminHref '/home'
Assert-True ($bshell -notmatch 'site-header' -and $bshell -notmatch 'r&lt;x&gt;' -and $bshell -match '<li><a href="/home">Home</a></li>' -and $bshell -notmatch 'id="settings"') 'with -Brand an Admin page draws no site header and names no brand anywhere; its first crumb links -AdminHref (Maikel, November 3, 2026; in the shell, #3811)'
Assert-True ((Format-SiteHeaderHtml -Name 'n' -Tag 'p<q>') -match 'aria-label="n p&lt;q&gt;, home">.*site-header__name">n <span class="site-header__tag">p&lt;q&gt;</span></span>' -and $bshell -notmatch 'site-header__tag') 'a -Tag follows the name, escaped, and is left out when empty'
$mshell = Format-SiteHeaderHtml -Name 'n' -Menu @(@{ Label = 'A<b>'; Href = '/a' }, @{ Label = 'C'; Href = '/c' }) -Current '/c'
Assert-True ($mshell -match '</a><nav class="site-header__nav" aria-label="Main"><ul class="site-header__menu"><li><a href="/a">A&lt;b&gt;</a></li><li><a href="/c" aria-current="page">C</a></li></ul><button class="site-header__menu-toggle" type="button" aria-controls="site-menu"' -and $mshell -match '</div><dialog class="dialog dialog--drawer site-menu" id="site-menu".*<a class="menu-item" href="/c" aria-current="page">.*</dialog></header>') 'a -Menu draws its links, escaped, between the brand and the settings, marks -Current, and again as the drawer inside the header after its container'
Assert-True ($bshell -notmatch 'site-header__nav|<dialog') 'no -Menu, no menu and no drawer'
Assert-True (((Get-AdminMenu) | ForEach-Object { $_.Href }) -join ' ' -eq '/dev/repository /dev/today /dev/goals /dev/progress /dev/release-notes /dev/claude /dev/plugins /settings') 'Admin''s menu is GitHub, then Admin''s own cards in their order, Today first of them (#3860), then Goals (#3816) and Progress (#4004)'
$st = Format-AdminSettingsPageHtml -RepoName 'o/r'
Assert-True ($st -match '<h1>Settings</h1>' -and $st -match '<h2>Theme</h2>' -and $st -match 'DKJTheme\.picker\(el, ') 'the Settings page opens with its h1, then the Theme h2 over the brand book''s own picker'
Assert-True ($st -match '<div class="card-grid hs-theme" id="settings-theme-grid"><div class="grid__head"><h2>Theme</h2></div><div class="controls grid__full"><span class="seg" id="settings-theme-mode" role="group" aria-label="Mode"><button type="button" data-mode="light" aria-pressed="true">Light</button><button type="button" data-mode="dark" aria-pressed="false">Dark</button></span></div>') 'under the Theme h2 a Light/Dark toggle, the house .seg in a .controls row of its own, one of the two pressed'
Assert-True ($st -match 'DKJTheme\.themes\.forEach\(function \(t\) \{' -and $st -match 'card\.innerHTML = "<div></div>";' -and $st -notmatch '<h3>' -and $st -match 'card\.setAttribute\("data-mode", t\.mode\);' -and $st -match 'swatches\.appendChild\(card\);') 'a card per theme of the brand book, with no h3 (the swatch names itself), marked with its mode, in the swatches grid'
Assert-True ($st -match 'if \(s\.getAttribute\("data-id"\) !== t\.id\) \{ s\.parentNode\.removeChild\(s\); \}' -and $st -match 'row\.parentNode\.replaceChild\(row\.querySelector\("\.theme-picker__swatches"\), row\)') 'each card keeps the brand book''s picker with its own swatch alone, unwrapped from its row'
Assert-True ($st -match 'card\.addEventListener\("click", function \(\) \{ DKJTheme\.set\(t\.id\); \}\);' -and $st -match '\.hs-swatch\[data-mode\] \{ cursor: pointer; \}') 'a theme card is clickable as a whole, picking its theme through the brand book''s own set'
Assert-True ($st -match '\.hs-swatch:hover \{ background: var\(--bg-4\); \}' -and $st -notmatch '\.hs-reset:hover') 'every card in the row, theme and reset alike, takes the one --bg-4 hover'
Assert-True ($st -match '\.hs-swatch:has\(\.theme-swatch\[aria-pressed="true"\]\) \{ border-color: var\(--primary\); \}') 'the card holding the active swatch takes the selected theme''s primary as its border'
Assert-True ($st -match '\.hs-swatch \.theme-swatch\[aria-pressed="true"\]:not\(:focus-visible\) \{ outline: 0; \}') 'so the active swatch''s own ring goes there, the keyboard''s focus ring kept'
Assert-True ($st -match 'c\.hidden = c\.getAttribute\("data-mode"\) !== mode;' -and $st -match 'show\(modeOf\(DKJTheme\.current\(\)\)\);') 'the toggle shows only its mode''s cards, and opens on the mode of the theme in force'
Assert-True ($st -match 'DKJTheme\.reset\(\); show\(modeOf\(DKJTheme\.current\(\)\)\);') 'a reset moves the toggle to the mode the default theme lands in'
Assert-True ($st -match '<div class="hs-swatches" id="settings-theme-swatches"></div><button type="button" class="card hs-swatch hs-reset" id="settings-theme-foot">Reset</button></div>' -and $st -match '\.hs-swatches \{ display: flex; flex-wrap: wrap; gap: var\(--spacing-3\); \}' -and $st -match '\.hs-swatches > \.card \{ margin-top: 0; background: var\(--bg-3\); border-color: var\(--bg-5\); \}' -and $st -match '\.hs-theme > \.hs-reset \{ border-color: var\(--bg-5\); \}' -and $st -match 'grid\.querySelectorAll\("\.card\[data-mode\]"\)') 'the reset closes the swatches'' row as a card that is itself the button, hovering on --bg-4 as a link card does, and the toggle never hides it'
Assert-True ($st -match 'card\.className = "card hs-swatch";' -and $st -match '\.hs-theme \{ display: flex; flex-wrap: wrap; gap: var\(--spacing-5\); \}' -and $st -match '\.hs-swatch \{ margin-top: 0; padding: var\(--spacing-2\); \}') 'the group is a house .card-grid whose own row lets each card hug its swatch, so a mode''s six stand side by side'
Assert-True ($st -match 'foot\.addEventListener\("click", function \(\) \{ DKJTheme\.reset\(\);' -and $st -match '\.hs-reset \{ font: inherit; color: var\(--fg-1\); cursor: pointer;' -and $st -notmatch 'settings-theme-reset') 'a click anywhere on the reset card resets, and no button sits inside it'
Assert-True ($st -match '<span aria-current="page">Settings</span>') 'the Settings page is its own last crumb'
# Admin has one width, full (Maikel, November 4, 2026): it is read in VS Code's Simple Browser at about 16:9, so a
# width choice is a product port's, never Admin's. No Width group on Settings, and no width in any settings panel.
Assert-True ($st -notmatch '<h2>Width</h2>' -and $st -notmatch 'settings-width' -and $st -notmatch 'data-width=') 'the Settings page offers no width: Admin has one'
Assert-True ($st -notmatch 'fluid: "Fluid"' -and $st -notmatch 'DKJTheme\.settings\(' -and $st -notmatch 'theme-settings--floating') 'an Admin page draws no floating settings panel at all, so no width is offered there either (the Settings page is where the theme is picked; #3811)'
Assert-True ((Get-AdminWidthScript) -eq '<script>DKJTheme.setWidth("full");</script>') 'Admin pins its width to full through the brand book''s own setWidth, so a stored Phone or Fluid is overwritten'
$pinAt = $st.IndexOf((Get-AdminWidthScript)); $themeAt = $st.IndexOf('<script src="/house-theme.js"></script>')
Assert-True ($themeAt -ge 0 -and $pinAt -gt $themeAt -and $pinAt -lt $st.IndexOf('</head>')) 'every general page pins it in <head>, right after house-theme.js, so it never paints in another width'
Assert-True ($st -match '\.hs-theme \.controls \.seg \{ height: var\(--spacing-11\); border-color: var\(--bg-5\); \}' -and $st -match '\.hs-theme \.controls \.seg button \+ button \{ border-left-color: var\(--bg-5\); \}') 'the Mode toggle stands --spacing-11 tall, with a --bg-5 border on the outside and between its buttons'
Assert-True ($st -match '\.hs-theme \.controls \.seg button\[aria-pressed="true"\] \{ background: var\(--primary\); \}') 'the pressed option of a toggle is the primary itself, not the muted grey'
Assert-True ($st -match '\.hs-theme \.controls \.seg button \{ width: var\(--spacing-28\); flex: 0 1 auto; min-width: 0; \}' -and $st -notmatch 'seg \{ width:') 'every option of a toggle is the same --spacing-28 wide'
$tpage = Format-GeneralPageHtml -Title 'Stopwatch' -Lead '' -Body '' -SiteName 'o/r' -ParentCrumbs @(@{ Label = 'Claude'; Href = '/dev/claude' })
Assert-True ($tpage -match '<a class="nav-item" href="/dev/claude" aria-current="page">' -and ([regex]::Matches($tpage, 'aria-current="page"')).Count -eq 2 -and (Format-GeneralPageHtml -Title 'Release notes' -Lead '' -Body '' -SiteName 'o/r') -match '<a class="nav-item" href="/dev/release-notes" aria-current="page">') 'an Admin page carries the navigation, marking the item it sits under (its first crumb, else its own title) with aria-current: the one item, beside the trail''s own last crumb (#3811, #3815)'
Assert-True ($tpage -match '<nav class="shell__nav" aria-label="Main"><a class="shell__brand" href="/"><span class="shell__brand__mark" aria-hidden="true"></span>Admin</a><div class="nav-search"' -and $tpage -match '</script><div class="nav-section"><ul class="nav-list"><li><a class="nav-item" href="/"[^>]*><span class="nav-item__label">Home</span>' -and $tpage -match '<p class="pane-head" id="admin-nav-\d+">Development</p><ul class="nav-list" aria-labelledby="admin-nav-\d+"><li><a class="nav-item" href="/dev/repository">' -and $tpage -notmatch 'class="tree' -and $tpage -notmatch '<ul class="nav-list"[^>]*>(?:(?!</ul>).)*<ul') 'the navigation opens on Home, then a Development heading over its flat list -- no tree, nothing nested (#3815)'
Assert-True ($tpage -match '<div class="nav-section shell__nav-foot"><ul class="nav-list"><li><a class="nav-item" href="/settings"><span class="nav-item__label">Settings</span></a></li></ul></div></nav>' -and $tpage -notmatch '>Product</p>') 'Settings is pinned to the foot, and with no product stated there is no Product section (#3815)'
Assert-True ($tpage -match '<div class="nav-search" role="search"><input class="nav-search__input" type="search" placeholder="Search" aria-label="Search Admin"[^>]*data-admin-search><kbd class="nav-search__key">Ctrl K</kbd></div><ul class="nav-list" data-admin-search-results aria-label="Search results" hidden>' -and $tpage -match '\(ev\.ctrlKey \|\| ev\.metaKey\)[^\n]*ev\.key === "k"[^\n]*field\.focus\(\)') 'the navigation opens on a search field, and Ctrl K (or Cmd K) focuses it from anywhere on the page (#3817)'
Assert-True ($tpage -match '<li data-admin-find="rules the rules claude works by" hidden><a class="nav-item" href="/dev/claude/rules" title="The rules Claude works by"><span class="nav-item__label">Rules</span></a></li>' -and $tpage -match '<li data-admin-find="stopwatch [^"]*" hidden><a class="nav-item" href="/dev/stopwatch"' -and $tpage -notmatch 'data-admin-find="clock ' -and ([regex]::Matches($tpage, 'data-admin-find="[^"]*" hidden><a class="nav-item" href="/dev/claude"')).Count -eq 1) 'it finds every navigation item, every group page and every page under one, once each -- Rules two levels down included, a Section heading not (#3817)'
Assert-True ($tpage -match 'r\.hidden = !on' -and $tpage -match 'rest\.forEach\(function \(n\) \{ n\.hidden = words\.length > 0; \}\)' -and ($tpage -split 'data-admin-search-results')[1] -notmatch 'innerHTML|insertAdjacentHTML|document\.write') 'typing only toggles what the server drew -- matches shown, the navigation''s own lists hidden -- and writes nothing typed into the page (#3817)'
$sitems = @(Get-AdminSearchItems -Nav @(@{ Heading = ''; Items = @(@{ Label = 'Home'; Href = '/'; External = $false }, @{ Label = 'Dup'; Href = '/dev/issues'; External = $false }) }))
Assert-True ($sitems[0].Href -eq '/' -and @($sitems | Where-Object { $_.Href -eq '/dev/issues' }).Count -eq 1 -and @($sitems | Where-Object { $_.Href -eq '/dev/issues' })[0].Label -eq 'Dup') 'the navigation''s own items come first, and a page reached twice is listed once (#3817)'
$evilNav = Format-AdminNavSearch -Nav @(@{ Heading = ''; Items = @(@{ Label = '<b>x"'; Href = '/x"><script>'; External = $false }) })
Assert-True ($evilNav -notmatch '<b>x' -and $evilNav -notmatch 'href="/x"><script>' -and $evilNav -match 'data-admin-find="&lt;b&gt;x&quot; "') 'every value in the search list is escaped (#3817)'
Set-AdminProductUrl 'http://localhost:4870/'
$ppage = Format-GeneralPageHtml -Title 'Stopwatch' -Lead '' -Body '' -SiteName 'o/r'
Set-AdminProductUrl ''
Assert-True ($ppage -match '<p class="pane-head" id="admin-nav-\d+">Product</p><ul class="nav-list" aria-labelledby="admin-nav-\d+"><li><a class="nav-item" href="http://localhost:4870/"><span class="nav-item__label">Storefront</span>' -and $ppage.IndexOf('>Product</p>') -lt $ppage.IndexOf('>Development</p>')) 'with a product stated, a Product section links its storefront, above Development (#3815)'
Set-AdminProductUrl 'javascript:alert(1)'
Assert-True ((Format-GeneralPageHtml -Title 'x' -Lead '' -Body '' -SiteName 'o/r') -notmatch '>Product</p>') 'a product address that is not http(s) is never linked'
Set-AdminProductUrl 'http://localhost:4870/'
Set-AdminObjects -Items @(@{ Label = 'Tracks'; Href = '/tracks'; Count = 1204 }, @{ Label = 'Playlists'; Href = 'https://music.example/playlists'; Count = 38 }, @{ Label = 'Artists'; Href = '/artists'; Count = $null }, @{ Label = ''; Href = '/x' }, @{ Label = 'Bad'; Href = 'javascript:alert(1)' }, @{ Label = 'Proto'; Href = '//evil.example/' }, @{ Label = 'Neg'; Href = '/neg'; Count = -3 })
$opage = Format-GeneralPageHtml -Title 'Stopwatch' -Lead '' -Body '' -SiteName 'o/r'
Assert-True ($opage -match '<ul class="nav-list"><li><a class="nav-item" href="/"[^>]*><span class="nav-item__label">Home</span></a></li><li><a class="nav-item" href="http://localhost:4870/tracks"><span class="nav-item__label">Tracks</span><span class="nav-item__count">1,204</span></a></li><li><a class="nav-item" href="https://music.example/playlists"><span class="nav-item__label">Playlists</span><span class="nav-item__count">38</span></a></li><li><a class="nav-item" href="http://localhost:4870/artists"><span class="nav-item__label">Artists</span></a></li><li><a class="nav-item" href="http://localhost:4870/neg"><span class="nav-item__label">Neg</span></a></li></ul>') 'a repo''s domain objects stand right under Home with their counts as badges, a path resolved on the repo''s own server (#3818)'
Assert-True ($opage -notmatch 'javascript:' -and $opage -notmatch 'evil\.example' -and $opage -notmatch '>Bad<' -and $opage -notmatch 'nav-item__count">-') 'an object without a label, with an address that is not http(s) or a root path, or with a count that is not a whole number is dropped or left without a badge (#3818)'
Set-AdminProductUrl ''
$npage = Format-GeneralPageHtml -Title 'Stopwatch' -Lead '' -Body '' -SiteName 'o/r'
Assert-True ($npage -notmatch '>Tracks<' -and $npage -match '>Playlists<') 'with no product to resolve against, an object given as a path is left out, and one given as a URL stays (#3818)'
Set-AdminObjects -Items @(1..20 | ForEach-Object { @{ Label = "O$_"; Href = "https://x.example/$_" } })
Assert-True (@(Get-AdminNav)[0].Items.Count -eq 13) 'at most 12 objects are kept, so a seam cannot push Development off the screen (#3818)'
Set-AdminObjects -Items @()
Assert-True (@(Get-AdminNav)[0].Items.Count -eq 1) 'a repo that states no objects has Home alone at the top (#3818)'
$gp = [IO.File]::ReadAllText((Join-Path $PSScriptRoot '..\..\plugins\dkj-policy\apps\admin\pages\serve-general-pages.ps1'))
Assert-True ($gp -match "Select-String -LiteralPath \`$cfg -Pattern '\\bfunction\\s\+Get-AdminObjects\\b' -Quiet" -and $gp -match "-TimeoutSeconds 20[^\n]*\n[^\n]*-EncodedCommand" -and $gp -match 'TotalSeconds -ge 60\) \{ \$aoCache = Get-AdminObjectsModel \}' -and $gp -match 'Set-AdminObjects -Items \$aoCache\.Items') 'the server reads the seam in a bounded child, only where repo-config.ps1 names it, at most once a minute (#3818)'
Set-AdminProductUrl ''
Assert-Equal '/dev/test-gate/suites/x?y=1|/dev/claude|/dev/clock||||' ((Resolve-AdminLegacyPath '/test-gate/suites/x?y=1'), (Resolve-AdminLegacyPath '/claude'), (Resolve-AdminLegacyPath '/clock'), (Resolve-AdminLegacyPath '/settings'), (Resolve-AdminLegacyPath '/dev/claude'), (Resolve-AdminLegacyPath '/'), (Resolve-AdminLegacyPath '/claudex') -join '|') 'an address from before #3815 moves under /dev with its path and query; Home, Settings, /dev itself and a lookalike do not'
Assert-Equal '/|/?x=1|/||' ((Resolve-AdminLegacyPath '/hub'), (Resolve-AdminLegacyPath '/hub?x=1'), (Resolve-AdminLegacyPath '/hub/'), (Resolve-AdminLegacyPath '/hubs'), (Resolve-AdminLegacyPath '/admin') -join '|') 'the home page''s address before #3873, /hub, moves to / with its query; a lookalike and /admin do not'
Assert-Equal '|' ((Resolve-AdminLegacyPath "/hub?a=1`r`nX-Evil: 1"), (Resolve-AdminLegacyPath "/claude?a=1`nX-Evil: 1") -join '|') 'a CR or LF in the request target is never carried into a Location header'
Assert-True ((ConvertTo-AdminBrandTag 'toolbox') -eq 'admin' -and (ConvertTo-AdminBrandTag 'product') -eq 'product' -and (Format-RepoHomeHeadHtml -RepoName 'r' -Lead 'l' -Brand 'r' -BrandTag 'toolbox') -match 'class="shell shell--no-aside"') 'the old tag toolbox is still read as admin for one release (#3815)'
Assert-True ((Format-ProductHomeHtml) -match '<li><a href="/consumers">Consumers</a></li><li><a href="/plugins">Plugins</a></li>' -and $tpage -notmatch '/consumers') 'the product carries its own pages as its menu, an Admin Admin''s'
Assert-True ((Format-ProductHomeHtml) -match 'site-header__name">dkj-marketplace <span class="site-header__tag">product</span>' -and (Format-MarketplacePluginsPageHtml -Plugins @()) -match '>product</span>') 'every page this server builds says product: it is this repo''s product port again (#3540)'
Assert-True ((Format-ProductHomeHeadHtml -RepoName 'r') -match '<h1>r</h1>\s*</div>' -and (Format-ProductHomeHeadHtml -RepoName 'r') -match 'theme-settings--floating') 'without a site header a product''s home keeps its h1 and floats the settings button, with no lead under it (#3585)'
$refusedHome = ''; try { $null = Format-RepoHomeHeadHtml -RepoName 'r' -Lead 'l' -BrandTag 'product' } catch { $refusedHome = $_.Exception.Message }
Assert-True ($refusedHome -match 'Format-ProductHomeHeadHtml' -and (Format-RepoHomeHeadHtml -RepoName 'r' -Lead 'l') -match 'class="shell shell--no-aside"') 'Admin''s home head is the shell whatever the tag, and a product''s is refused with the dkj-solutions pointer (#3831)'
Assert-True ($gshell -notmatch 'class="lead"' -and $gshell.Contains('<meta name="description" content="lead">')) 'a page''s lead is its description, never a paragraph under its h1 (#3585)'
Assert-True ((Format-GeneralPageHtml -Title 't' -Lead 'The <code>a"b</code> line' -Body '').Contains('<meta name="description" content="The a&quot;b line">')) 'and the description drops the lead''s tags and keeps its attribute closed'
Assert-True ((Format-GeneralPageHtml -Title 't' -Lead '' -Body '') -notmatch 'name="description"') 'an empty lead writes no description'
Assert-True ($bshell -notmatch 'class="eyebrow"' -and $bshell -notmatch 'theme-settings--floating' -and $bshell -notmatch 'class="site-header"' -and $bshell -notmatch 'breadcrumbs-bar') 'and it has no eyebrow, no floating button, no site header and no breadcrumb bar (#3811)'

Write-Host '-- the product: the home page on / (#3540)' -ForegroundColor Cyan
$pages = @(Get-ProductPages)
Assert-Equal '/consumers,/plugins,/docs-coverage,/settings' (($pages | ForEach-Object { $_.Href }) -join ',') 'the product links its two pages: Consumers and Plugins, Specialists a card on the Plugins page since October 28, 2026 (the owner), the DKJ repos on GitHub a section of /consumers/dkj since #3549, and Docs coverage since #3906; the general pages are the plugin admin''s (#3540)'
Assert-Equal '/dev/issues,/dev/today,/dev/goals,/dev/progress,/dev/release-notes,/dev/sessionstart,/dev/test-gate,/dev/stopwatch,/dev/logbook,/dev/plugins,/settings' ((Get-GeneralPages | ForEach-Object { $_.Href }) -join ',') 'the plugin lists the eleven general pages, in order: Today first of Admin''s own (#3860), then Goals (#3816) and Progress (#4004), Test gate, Stopwatch and Logbook every repo''s since #3470, Plugins since #3482, Settings last (Dave, November 2, 2026)'
Assert-Equal 'Admin=/admin,Consumers=/consumers,Plugins=/plugins,Docs coverage=/docs-coverage,Settings=/settings' ((@(Get-ProductMenu) | ForEach-Object { $_.Label + '=' + $_.Href }) -join ',') 'the site header menu opens on Admin, through the server''s /admin redirect, then the product''s own pages, in the home page''s card order (Maikel, November 3, 2026)'
# The product has one width, full, as Admin has: another screen is judged in the Simple Browser's own device
# emulation (Dave, November 4, 2026), so its Settings page carries the theme alone.
$ps = Format-ProductSettingsHtml
Assert-True ($ps -match '<h1>Settings</h1>' -and $ps -match '<h2>Theme</h2>' -and $ps -match 'site-header__tag">product</span>') 'the product has a Settings page of its own, in the product''s shell'
Assert-True ($ps -notmatch '<h2>Width</h2>' -and $ps -notmatch 'settings-width' -and $ps -notmatch 'data-width=') 'the product''s Settings page offers no width either'
Assert-True ($ps -match 'house-theme\.js"></script>\s*<script>DKJTheme\.setWidth\("full"\);</script>' -and (Format-DevPageHtml -Title 'x' -Lead '' -Body '') -match 'DKJTheme\.setWidth\("full"\);') 'every product page pins the width to full, as Admin does'
Assert-True ((Format-ProductHomeHtml) -match '<a class="menu-item" href="/settings">') 'the product home links Settings as a card'
$ph = Format-ProductHomeHtml -AdminUrl 'http://localhost:4890' -SourceCommit 'abc1234'
Assert-True ($ph -match '<title>dkj-marketplace -- Home</title>' -and $ph -notmatch '<h1' -and $ph -notmatch 'class="lead"') 'under the site header the home page has no intro at all, and its title says Home'
Assert-True ($ph -match 'house-theme\.js"></script>\s*<script>DKJTheme\.setWidth\("full"\);</script>' -and $ph -notmatch 'width-bar') 'the product home pins the width to full and draws no width bar'
Assert-True ($ph -match '(?s)<body>\s*<header class="site-header">.*?</header>\s*<div class="breadcrumbs-bar"><div class="container"><nav class="breadcrumbs" aria-label="Breadcrumb"><ol>\s*<li><span aria-current="page">Home</span></li>\s*</ol>') 'the site header opens <body> under it and the bar right under that, its trail the one crumb Home'
Assert-True ($ph -match 'site-header__name">dkj-marketplace <span class="site-header__tag">product</span>' -and $ph -match '<header class="site-header"><div class="container"><a class="site-header__brand" href="/"') 'the site header names the repo with product after it, and goes home'
Assert-True ($ph -notmatch 'class="eyebrow"' -and ([regex]::Matches($ph, '<header')).Count -eq 1 -and $ph -notmatch 'theme-settings--floating' -and $ph -notmatch 'id="settings"') 'no eyebrow, no <header> but the site header, and no settings button anywhere'
Assert-True ($ph -match '<style>\r?\n\.ph-cards \{' -and $ph -notmatch 'class="grid-3"' -and $ph -match '<div class="ph-cards">\r?\n<section class="card card--link"><nav class="menu-list" aria-label="Admin"><a class="menu-item" href="http://localhost:4890">') 'the cards stand in the Admin home''s .ph-cards, never a .grid-3 (Maikel, November 3, 2026), and open on the Admin card, linking the plugin admin'
$phBody = $ph.Substring($ph.IndexOf('</header>'))   # the cards, not the site header's menu, which lists the same pages
Assert-True ($phBody.IndexOf('aria-label="Admin"') -ge 0 -and $phBody.IndexOf('aria-label="Admin"') -lt $phBody.IndexOf('href="/consumers"') -and $phBody.IndexOf('href="/consumers"') -lt $phBody.IndexOf('href="/plugins"') -and $ph -notmatch 'href="/dkj-repos"' -and $ph -notmatch 'href="/specialists"') 'then Consumers and Plugins, in that order, and no DKJ repos (#3549) or Specialists card of its own'
Assert-Equal 5 ([regex]::Matches($ph, '<section class="card card--link"><nav class="menu-list" aria-label="[^"]+"><a class="menu-item" href="[^"]+"><svg class="menu-item__icon"')).Count 'five cards (Admin, Consumers, Plugins, Docs coverage, Settings), each a .card--link with its icon first'
Assert-True ($ph -notmatch 'href="/(repository|test-gate|stopwatch|logbook|issues|release-notes|sessionstart|brandbook)"') 'and no general page of its own: those are the plugin admin''s (#3540); its /plugins is its own, what the marketplace ships'
Assert-True ($ph -match 'class="note">[^\n]*serve-consumer-dashboard\.ps1</code>, from <code>abc1234</code>') 'the footer names the server and the commit it loaded'
Assert-True ((Format-ProductHomeHtml) -notmatch ', from <code>') 'and leaves the commit out when it could not be read'
$down = Format-ProductHomeHtml
Assert-True ($down -match '<section class="card"><p role="status">Admin is not running' -and $down -notmatch 'aria-label="Admin"' -and $down -match 'href="/consumers"') 'with no admin known one card says it is not running, and the product''s own pages stay linked'
Assert-True ((Format-ProductHomeHtml -AdminUrl 'http://evil.example:4890') -match 'Admin is not running' -and (Format-ProductHomeHtml -AdminUrl 'javascript:alert(1)') -notmatch 'javascript:') 'an admin url that is not plain loopback is no admin at all'
Assert-True (@(@($pages) + @(Get-GeneralPages) | Where-Object { -not (Get-AdminIconSvg -Name $_.Icon) }).Count -eq 0) 'every page an admin or the product links names an icon Admin has'
Assert-True (@(Get-AdminGroups | Where-Object { -not (Get-AdminIconSvg -Name $_.Icon) }).Count -eq 0) 'and every group page an admin card links names one too'

Write-Host '-- the Clock group page (the owner, October 27, 2026)' -ForegroundColor Cyan
Assert-Equal '/dev/stopwatch,/dev/logbook' ((Get-GeneralPages | Where-Object { $_.Group -eq '/dev/clock' } | ForEach-Object { $_.Href }) -join ',') 'Stopwatch and Logbook belong to the Clock group, in that order; the Test gate went to GitHub (the owner, November 2, 2026)'
Assert-Equal '/dev/issues,/dev/test-gate' ((Get-GeneralPages | Where-Object { $_.GitHub } | ForEach-Object { $_.Href }) -join ',') 'Issues and the Test gate are the GitHub page''s, in that order, and in no group'
Assert-True (@(Get-GeneralPages | Where-Object { $_.GitHub -and $_.Group }).Count -eq 0) 'a GitHub page sits in no group'
$clockCards = @(Format-AdminPageCardsHtml -Pages @(Get-GeneralPages | Where-Object { -not $_.GitHub }))
Assert-True ($clockCards.Count -eq 7 -and @($clockCards | Where-Object { $_ -notmatch '^<section class="card card--link">' }).Count -eq 0 -and @($clockCards | Where-Object { ([regex]::Matches($_, '<a ')).Count -ne 1 }).Count -eq 0) 'Admin draws seven cards for the nine pages it holds, each a .card--link holding exactly one link'
Assert-True ($clockCards[0] -match 'href="/dev/today"' -and $clockCards[1] -match 'href="/dev/goals"' -and $clockCards[2] -match 'href="/dev/progress"' -and $clockCards[4] -match 'href="/dev/claude"' -and $clockCards[4] -match '<h[23]>Claude<' -and -not ($clockCards -match 'href="/(performance|sessionstart|clock|test-gate|stopwatch|logbook|issues)"')) 'the Claude card takes SessionStart''s place, as the group Performance now sits in; nothing under it, and no GitHub page, has an admin card of its own (the owner, November 2, 2026)'
Assert-Equal '/dev/claude' ((Get-AdminGroups | Where-Object { $_.Href -eq '/dev/performance' }).Group) 'Performance sits in Claude'
Assert-True (@(Get-AdminGroups | Where-Object { $_.Href -in '/dev/clock', '/dev/performance/context' -and $_.Group -eq '/dev/performance' -and $_.Section }).Count -eq 2) 'Clock and Context are Sections of Performance (Dave, November 3, 2026)'
Assert-Equal '/dev/performance/context' ((Get-GeneralPages | Where-Object { $_.Href -eq '/dev/sessionstart' }).Group) 'SessionStart sits in the Context section'
$perfPage = Format-AdminGroupPageHtml -Href '/dev/performance' -RepoName 'dkj-claude-plugins'
$perfHeads = ([regex]::Matches($perfPage, '<h[23]>[^<]+</h[23]>') | ForEach-Object { $_.Value }) -join ','
Assert-Equal '<h2>Clock</h2>,<h2>Context</h2>' $perfHeads 'the /performance page is an h2 Clock over a table of the Stopwatch and Logbook rows, then an h2 Context over a table holding the SessionStart row, with no h3 card titles (Admin''s form, #3830)'
Assert-True ($perfPage -match '<div class="page-head"><div class="page-head__title"><h1>Performance</h1></div></div>' -and ([regex]::Matches($perfPage, '<section class="admin-list"><h2>')).Count -eq 2 -and (([regex]::Matches($perfPage, '<tr><td class="col-start"><a href="[^"]+">([^<]+)</a>') | ForEach-Object { $_.Groups[1].Value }) -join ',') -eq 'Stopwatch,Logbook,SessionStart' -and $perfPage -notmatch 'href="/(test-gate|clock)"' -and $perfPage -notmatch 'class="ph-cards"|card--link|class="grid-3"') 'three rows in two tables, no Clock page linked, and no card grid above the sections'
Assert-True ($perfPage -match 'aria-current="page">Performance</span>' -and $perfPage -match '<li><a href="/">Home</a></li>\s*<li><span class="breadcrumbs__sep"[^>]*>.*?</span><a href="/dev/claude">Claude</a></li>' -and $perfPage -notmatch '<a href="/dev/performance">') 'its trail reads Home > Claude > Performance'
Assert-Equal '/dev/claude,/dev/performance' ((Get-AdminGroupCrumbs -Href '/dev/clock' | ForEach-Object { $_.Href }) -join ',') 'a page in the Clock section trails through Claude and Performance; the section is no crumb'
Assert-Equal '/dev/claude,/dev/claude/specialists' ((Get-AdminGroupCrumbs -Href '/dev/claude/specialists' | ForEach-Object { $_.Href }) -join ',') 'and a group in Claude runs through Claude'
Assert-True ($null -eq (Format-AdminGroupPageHtml -Href '/dev/clock' -RepoName 'dkj-claude-plugins')) 'the Clock has no page of its own any more: it is a section, and /clock moves to /performance'
Assert-True ($null -eq (Format-AdminGroupPageHtml -Href '/nope') -and $null -eq (Format-AdminGroupPageHtml -Href '/Clock')) 'a path no group has is no group page'

Write-Host '-- the Claude page: Rules, Skills, Specialists, Performance (Maikel, October 30 and November 2, 2026)' -ForegroundColor Cyan
Assert-True (@($clockCards -match 'href="/dev/claude"').Count -eq 1 -and -not ($clockCards -match 'href="/dev/claude/') -and -not ($clockCards -match 'href="/ai')) 'the Claude card is on Admin once, no nested group has an admin card of its own, and no AI card is left'
$claudePage = Format-AdminGroupPageHtml -Href '/dev/claude' -RepoName 'dkj-claude-plugins'
Assert-True ($claudePage -match '<div class="page-head"><div class="page-head__title"><h1>Claude</h1></div></div>' -and $claudePage -notmatch 'grid__head' -and $claudePage -match 'aria-current="page">Claude</span>' -and $claudePage -match '<li><a href="/">Home</a></li>') 'the /claude page has Claude as its h1 in the page header, under Tools, with no section heading of its own (Maikel, November 2, 2026)'
Assert-True (([regex]::Matches($claudePage, '<tr><td class="col-start"><a href=')).Count -eq 4 -and $claudePage -notmatch '<h2>' -and $claudePage.IndexOf('href="/dev/claude/rules"') -lt $claudePage.IndexOf('href="/dev/claude/skills"') -and $claudePage.IndexOf('href="/dev/claude/skills"') -lt $claudePage.IndexOf('href="/dev/claude/specialists"') -and $claudePage.IndexOf('href="/dev/claude/specialists"') -lt $claudePage.IndexOf('href="/dev/performance"') -and $claudePage -notmatch 'href="/(sessionstart|clock)"') 'and under it Rules, Skills, Specialists and Performance, in that order, each a row of one table, and nothing of Performance''s own (the owner, November 2, 2026)'
Assert-True ($claudePage -match '<section class="admin-list"><table class="table table--dense">' -and $claudePage -notmatch 'class="ph-cards"|class="grid-3"|\.ph-cards \{' -and $perfPage -notmatch 'class="grid-3"') 'the rows stand in one dense table on the page, never in a .ph-cards or a .grid-3 surface (Maikel, November 2, 2026; Admin''s form, #3830)'
$specBare = Format-AdminGroupPageHtml -Href '/dev/claude/specialists' -RepoName 'x'
Assert-True ($specBare -match '<section class="admin-list"><h2>Lenses</h2><table class="table table--dense">' -and $specBare -notmatch '\.ph-cards \{|class="grid-3"') 'a Section is its h2 over a table of its own, and a page with no card grid carries no .ph-cards rules'
Assert-True ($null -eq (Format-AdminGroupPageHtml -Href '/ai')) 'there is no /ai page any more'
Assert-True ($claudePage -notmatch 'Lenses') 'the Lenses are not on /claude'
$specPage = Format-AdminGroupPageHtml -Href '/dev/claude/specialists' -RepoName 'x'
Assert-True ($specPage -match '<section class="admin-list"><h2>Lenses</h2>' -and $specPage -notmatch 'Nothing on this page yet' -and $specPage -match '(?s)<h2>Lenses</h2><table[^>]*>.*?<td class="col-start" colspan="2" role="status">Nothing here yet\.') 'the Specialists page holds a Lenses section, which with no repo to read says it has nothing yet'
$lensRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('admin-lenses-' + [guid]::NewGuid().ToString('N'))
$lensDir = Join-Path $lensRoot '.claude\specialists\lenses'
New-Item -ItemType Directory -Path $lensDir -Force | Out-Null
try {
    [System.IO.File]::WriteAllText((Join-Path $lensDir 'specialist-05-05-lens.md'), "---`nid: 05`n---`n`n# Derek - the DevOps Engineer`n`nBody <b>text</b>.`n")
    [System.IO.File]::WriteAllText((Join-Path $lensDir 'specialist-01-01-lens.md'), "# Chris - the Chief of Staff`n")
    [System.IO.File]::WriteAllText((Join-Path $lensDir 'notes.md'), "# Not a lens`n")
    $lenses = @(Get-AdminLensPages -RepoRoot $lensRoot)
    Assert-Equal 'specialist-01-01-lens,specialist-05-05-lens' (($lenses | ForEach-Object { $_.Label }) -join ',') 'the lenses are the repo''s specialist-NN-NN-lens files, by name, and nothing else in the folder'
    Assert-Equal 'Derek - the DevOps Engineer' $lenses[1].Sub 'a lens card''s sub line is its own # title, past the frontmatter'
    $specLens = Format-AdminGroupPageHtml -Href '/dev/claude/specialists' -RepoName 'x' -RepoRoot $lensRoot
    Assert-True ($specLens -match 'href="/dev/claude/specialists/lenses/specialist-01-01-lens"' -and $specLens -match '<a href="[^"]+">specialist-05-05-lens</a>' -and ([regex]::Matches($specLens, '<tr><td class="col-start"><a href=')).Count -eq 2) 'with a repo the Lenses table holds one row per lens'
    $lensPage = Format-AdminLensPageHtml -Name 'specialist-05-05-lens' -RepoRoot $lensRoot -RepoName 'x'
    Assert-True ($lensPage -match '<h1>specialist-05-05-lens</h1>' -and $lensPage -match '<a href="/dev/claude">Claude</a>' -and $lensPage -match '<a href="/dev/claude/specialists">Specialists</a>') 'a lens''s page is titled as its card on the Specialists page reads, under Home > Claude > Specialists'
    $lensJson = [regex]::Match($lensPage, '<script type="application/json" id="lens-md">(.*?)</script>').Groups[1].Value
    $lensMd = ConvertFrom-Json $lensJson
    Assert-True ($lensMd.intro -eq 'Body <b>text</b>.' -and $lensMd.body -eq '') 'its text travels as JSON for the renderer, past the frontmatter and its own # title (a second h1), the opening paragraph as the intro'
    Assert-True ($lensJson -notmatch '<' -and $lensPage -match 'renderMd\(md\.body\)' -and $lensPage -match 'function renderMd\(' -and $lensPage -match '<div class="dp-lens" id="lens-intro"><noscript><p>Body &lt;b&gt;text&lt;/b&gt;\.</p>' -and $lensPage.IndexOf('id="lens-intro"') -lt $lensPage.IndexOf('id="lens-body"')) 'with no raw < in that JSON, the house renderer inlined to draw it, the intro under the h1 above the card, and the escaped text for a reader without JavaScript'
    [System.IO.File]::WriteAllText((Join-Path $lensDir 'specialist-02-02-lens.md'), "# Title`n`n# Another top heading`n`n``````md`n# kept in code`n```````n")
    $twoJson = [regex]::Match((Format-AdminLensPageHtml -Name 'specialist-02-02-lens' -RepoRoot $lensRoot), '<script type="application/json" id="lens-md">(.*?)</script>').Groups[1].Value
    Assert-Equal "## Another top heading`n`n``````md`n# kept in code`n```````n" (ConvertFrom-Json $twoJson).body 'any other # heading drops to ##, so the page keeps one h1, while a # inside a code fence is left as written'
    $split = Split-AdminLensIntro -Text "> where the lens sits`n`nThis repo is special.`nIt says so.`n`n- a list`n`n## A`n`n> kept quote`n"
    Assert-True ($split.Intro -eq "This repo is special.`nIt says so." -and $split.Body -eq "- a list`n`n## A`n`n> kept quote`n") 'the paragraphs before the first heading are the intro, a quote there goes, a list there stays in the body, and a quote under a heading is kept'
    Assert-Equal "> note`n`n## A`n`ntext`n`n### a1`n" (ConvertTo-AdminLensBody -Text "---`nid: 01`n---`n# T`n`n## Specific to this repo (x)`n`n> note`n`n### A`n`ntext`n`n#### a1`n") 'a lone ## wrapping ### sections goes, and the sections become h2s, their parts h3s'
    Assert-Equal "## A`n`n## B`n" (ConvertTo-AdminLensBody -Text "# T`n`n### A`n`n### B`n") 'a lens with only ### sections shows them as h2s'
    Assert-Equal "## Specific to this repo (VUL-IN)`n`nfill`n" (ConvertTo-AdminLensBody -Text "# T`n`n## Specific to this repo (VUL-IN)`n`nfill`n") 'a lone ## with nothing under it stays'
    Assert-Equal "## A`n`n## B`n`n### b`n" (ConvertTo-AdminLensBody -Text "# T`n`n## A`n`n## B`n`n### b`n") 'a body that already opens on h2s is left as it is'
    Assert-Equal "## S`n`nSee [x](/dev/claude/specialists/lenses/specialist-05-05-lens) and [y](../other.md).`n" (ConvertTo-AdminLensBody -Text "# T`n`n## S`n`nSee [x](specialist-05-05-lens.md#a-part) and [y](../other.md).`n") 'a link to another lens file becomes a link to its page, anchor dropped; any other relative link is left as written'
    $leadIn = "# T`n`n## S`n`n- **One.** first`n  more`n- **Two:** " + [char]0x2014 + " second`n`n## U`n`n- **Only** x`n- plain`n"
    Assert-Equal "## S`n`n### One`n`nFirst`nmore`n`n### Two`n`nSecond`n`n## U`n`n- **Only** x`n- plain`n" (ConvertTo-AdminLensBody -Text $leadIn) 'a list under an h2 whose every item opens bold becomes h3s over their text; a list with one plain item stays a list'
    Assert-Equal "## S`n`n### A lead that wraps`n`nOnto two lines.`n`n### B`n`nText`n" (ConvertTo-AdminLensBody -Text "# T`n`n## S`n`n- **A lead that`n  wraps** onto two lines.`n- **B.** text`n") 'a bold lead that wraps onto its next line is still a lead'
    Assert-True ($lensPage -match '<section class="card dp-lens">' -and $lensPage -match '\.dp-lens \{ max-width: 800px; \}') 'its card is never wider than 800px'
    Assert-True ($null -eq (Format-AdminLensPageHtml -Name 'notes' -RepoRoot $lensRoot) -and $null -eq (Format-AdminLensPageHtml -Name '..\..\x' -RepoRoot $lensRoot) -and $null -eq (Format-AdminLensPageHtml -Name 'specialist-09-09-lens' -RepoRoot $lensRoot)) 'a name that is no lens of the repo has no page'
} finally { Remove-Item -LiteralPath $lensRoot -Recurse -Force -ErrorAction SilentlyContinue }
$skillsPage = Format-AdminGroupPageHtml -Href '/dev/claude/skills' -RepoName 'dkj-claude-plugins'
Assert-True ($skillsPage -match '<li><a href="/">Home</a></li>' -and $skillsPage -match '<a href="/dev/claude">Claude</a>' -and $skillsPage -match 'Nothing on this page yet\.' -and $skillsPage -notmatch 'card--link') 'the /claude/skills page is a landing page of its own, under Home > Claude, with nothing on it yet'

Write-Host '-- the Rules page: what is in the repo''s .claude/rules folder, and nothing else (Maikel, November 3, 2026)' -ForegroundColor Cyan
$rulesBare = Format-AdminGroupPageHtml -Href '/dev/claude/rules' -RepoName 'x'
Assert-True ($rulesBare -match '<li><a href="/">Home</a></li>' -and $rulesBare -match '<a href="/dev/claude">Claude</a>' -and $rulesBare -notmatch '<h2>' -and $rulesBare -notmatch 'grid__head' -and $rulesBare -match 'Nothing on this page yet\.') 'the /claude/rules page has no heading under its h1, and with no repo to read says it has nothing yet'
$ruleRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('admin-rules-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $ruleRoot '.claude\rules'), (Join-Path $ruleRoot 'plugins\pol') -Force | Out-Null
try {
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot 'CLAUDE.md'), "# CLAUDE.md`n`n@plugins/pol/CLAUDE.md`n")
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot 'plugins\pol\CLAUDE.md'), "# The constitution`n")
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot '.claude\rules\this-repo.md'), "# This repo`n`n## Facts`n`nTrunk is main.`n")
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot '.claude\rules\layers.md'), "---`npaths:`n  - `"scripts/**`"`n---`n`n# Layers`n`nDetail.`n")
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot '.claude\rules\lang.md'), ("# Language " + [char]0x2014 + " which layers are English`n"))
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot '.claude\rules\repo.md'), ("# This repo " + [char]0x2014 + " dkj-x`n"))
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot '.claude\rules\described.md'), "---`ndescription: `"Facts about this repo`"`n---`n`n# Described " + [char]0x2014 + " x`n")
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot '.claude\rules\both.md'), "---`ndescription: The layers`npaths:`n  - `"a/**`"`n---`n`n# Both`n")
    [System.IO.File]::WriteAllText((Join-Path $ruleRoot '.claude\rules\notes.txt'), "not markdown`n")
    $rules = @(Get-AdminRulePages -RepoRoot $ruleRoot)
    Assert-Equal 'both,described,lang,layers,repo,this-repo' (($rules | ForEach-Object { $_.Label }) -join ',') 'the rules are the .claude/rules markdown files by name -- not a CLAUDE.md the root imports, not a file that is no markdown'
    Assert-True ($rules[5].Sub -eq 'This repo' -and $rules[5].Display -eq '.claude/rules/this-repo.md' -and $rules[3].Sub -eq 'Layers (path-scoped)') 'a rule card''s sub line is its own # title, and a path-scoped rule says so in two words'
    Assert-True ($rules[2].Sub -ceq 'Which layers are English' -and $rules[4].Sub -ceq 'dkj-x') 'a title''s lead before its em dash goes, since the card''s own title names the subject; a plain word then opening it is raised, an identifier is not (Maikel, November 3, 2026)'
    Assert-True ($rules[1].Sub -ceq 'Facts about this repo' -and $rules[0].Sub -ceq 'The layers (path-scoped)') 'a description: in the frontmatter is the sub line in place of the title, its quotes gone, and beside paths: it still says path-scoped (Maikel, November 3, 2026)'
    $rulesPage = Format-AdminGroupPageHtml -Href '/dev/claude/rules' -RepoName 'x' -RepoRoot $ruleRoot
    Assert-True ((Format-AdminRulePageHtml -Name 'described' -RepoRoot $ruleRoot) -notmatch 'description:') 'the description is frontmatter, so the rule''s page does not show it as text'
    Assert-True (([regex]::Matches($rulesPage, '<tr><td class="col-start"><a href=')).Count -eq 6 -and $rulesPage -match 'href="/dev/claude/rules/layers"' -and $rulesPage -match '<a href="[^"]+">this-repo</a>' -and $rulesPage -match '<section class="admin-list"><table class="table table--dense">' -and $rulesPage -notmatch '<h2>|grid__head|Repo rules|ph-cards' -and $rulesPage -notmatch 'href="/dev/claude/rules/pol"' -and $rulesPage -notmatch 'Nothing') 'with a repo the page holds one row per rule file in one table, with no section heading over them (Maikel, November 3, 2026)'
    $rulePage = Format-AdminRulePageHtml -Name 'this-repo' -RepoRoot $ruleRoot -RepoName 'x'
    $ruleMd = ConvertFrom-Json ([regex]::Match($rulePage, '<script type="application/json" id="lens-md">(.*?)</script>').Groups[1].Value)
    Assert-True ($rulePage -match '<h1>this-repo</h1>' -and $rulePage -match '<a href="/dev/claude">Claude</a>' -and $rulePage -match '<a href="/dev/claude/rules">Rules</a>' -and $rulePage -match 'Read from <code>\.claude/rules/this-repo\.md</code>' -and $ruleMd.body -eq "## Facts`n`nTrunk is main.`n") 'a rule file''s page is rendered as a lens''s is, titled as its card, under Home > Claude > Rules, naming the file it was read from'
    Assert-True ((Format-AdminRulePageHtml -Name 'layers' -RepoRoot $ruleRoot) -notmatch 'paths:' -and $null -eq (Format-AdminRulePageHtml -Name 'pol' -RepoRoot $ruleRoot) -and $null -eq (Format-AdminRulePageHtml -Name '..' -RepoRoot $ruleRoot) -and $null -eq (Format-AdminRulePageHtml -Name 'notes' -RepoRoot $ruleRoot)) 'a path-scoped rule''s frontmatter is not body, and a name that is no rule file of the repo has no page'
    Assert-True (@(Get-AdminRulePages -RepoRoot '').Count -eq 0) 'no repo, no rule files'
} finally { Remove-Item -LiteralPath $ruleRoot -Recurse -Force -ErrorAction SilentlyContinue }
Assert-True ((Get-AdminIconSvg -Name '') -eq '' -and (Get-AdminIconSvg -Name 'nope') -eq '' -and (Format-AdminCardLinkHtml -Href '/x' -Label 'X') -notmatch 'menu-item__icon') 'a card that names no icon, or one Admin lacks, draws none'
Assert-True (@($script:AdminIcons.Keys | Where-Object { (Get-AdminIconSvg -Name $_) -notmatch '^<svg class="menu-item__icon" viewBox="-?[\d.]+ -?[\d.]+ 24 24" width="32" height="32"' }).Count -eq 0) 'every icon is drawn in the same 32px square, a 24-unit viewBox (Maikel, November 2, 2026)'
Assert-True (@($script:AdminIconOffsets.Keys | Where-Object { -not $script:AdminIcons.ContainsKey($_) }).Count -eq 0 -and (Get-AdminIconSvg -Name 'rules') -match 'viewBox="-0.25 0 24 24"' -and (Get-AdminIconSvg -Name 'claude') -match 'viewBox="0 0 24 24"') 'an off-centre drawing moves its viewBox to stand in the middle of that square, and the offsets name only icons Admin has'
$houseCss = [System.IO.File]::ReadAllText((Join-Path $RepoRoot 'plugins\dkj-policy\assets\dkj-brandbook\house-style.css'))
Assert-True ($houseCss -match '\.card--link \{ position: relative; display: flex; flex-direction: column; justify-content: center; \}' -and $houseCss -match '\.card--link a::after \{ content: ""; position: absolute; inset: 0; \}') 'the house style stretches a .card--link''s one link over the card, its content in the middle of the card''s height'
Assert-True (([regex]::Matches($ph, '(?s)<style>(.*?)</style>') | ForEach-Object { $_.Groups[1].Value.Trim() }) -join '|' -ceq (Get-AdminCardGridStyle) -and $ph -notmatch 'grid__head') 'the home page restyles nothing but Admin''s own .ph-cards, as Admin home does, and has no group heading (#3133)'
Assert-True ($ph -notmatch 'id="admin-banner"' -and (Format-ProductSettingsHtml) -notmatch 'id="admin-banner"') 'no product page carries the airsquats banner: it is Admin''s alone (Dave, November 4, 2026)'
$tbHome = Format-RepoHomeHeadHtml -RepoName 'r' -Lead 'l' -Brand 'r' -BrandTag 'admin'
Assert-True ($tbHome.IndexOf('<div class="notice" id="admin-banner"') -gt $tbHome.IndexOf('<div class="shell__list tb-scroll">') -and $tbHome.IndexOf('<div class="shell__list tb-scroll">') -gt 0 -and $tbHome -notmatch 'class="site-header"' -and $tbHome -notmatch '<div class="toolbar">' -and $tbHome -match '<span aria-current="page">Home</span>') 'Admin home opens its scroll pane on the airsquats banner, in the shell with no site header and no toolbar (#3811)'
$bannerHtml = Format-RepoAdminBanner
Assert-True ($bannerHtml.Contains('data-admin-timer') -and $bannerHtml.Contains('<input type="checkbox" data-admin-done> <span data-admin-count>10</span> due') -and $bannerHtml.Contains('data-admin-due hidden')) 'it counts down to the hour, and its "10 due" box stays hidden until an hour has passed, on the same one-row line as the timer'
Assert-True (([regex]::Matches((Format-RepoAdminBanner), '<p[ >]')).Count -eq 1) 'the banner is one row: the timer and the box owed share a single paragraph, never a second line (Dave, October 24, 2026)'
$bannerJs = Format-RepoAdminBanner
Assert-True ($bannerJs -match '<div class="notice" id="admin-banner"[^>]*style="position: fixed; left: calc\(var\(--shell-nav-w, 0px\) \+ var\(--spacing-4\)\); bottom: var\(--spacing-4\);[^"]*box-shadow: var\(--shadow-pop\)"' -and $bannerJs -match 'translateY\(calc\(100% \+ 2rem\)\)' -and $bannerJs -notmatch 'border-radius: 0') 'the banner is a toast fixed bottom-left in house tokens, popping up from below the edge rather than a strip under the header (Maikel, November 4, 2026)'
Assert-True ($bannerJs -notmatch 'localStorage' -and $bannerJs -match 'fetch\(path' -and ([regex]::Matches($bannerJs, '"/api/airsquats')).Count -eq 1 -and $bannerJs -notmatch 'XMLHttpRequest|WebSocket|sendBeacon|eval\(|new Function|document\.cookie') 'its state is the server''s, shared by every admin and machine: it asks /api/airsquats on its own origin and nothing else (#3438)'
Assert-True ($bannerJs -match 'ask\("POST", API \+ "/clear"\)' -and $bannerJs -match '\(s\.per \|\| 10\) \* owed' -and $bannerJs -match 'if \(s\.announce\) \{ tone\(\); \}') 'ticking the box is a POST to /clear, the box shows 10 per hour owed, and the server says when to play the tone'
Assert-True ($bannerJs -match '<span data-admin-owner hidden[^>]*> &middot; <span data-admin-account></span></span><button' -and $bannerJs -match 'account\.textContent = s\.account; owner\.hidden = false;' -and $bannerJs -notmatch 'innerHTML') 'the row ends on the Windows account Admin runs under, written as text and shown only once the server names one (#3476)'
Assert-True ($bannerJs -match '<div class="notice" id="admin-banner"[^>]* hidden>' -and $bannerJs -match 'slide\(\(owed > hush\) \|\| \(!offline\.hidden && !quiet\)\);' -and $bannerJs -match 'asked = Date\.now\(\); slide\(false\);' -and $bannerJs -match 'box\.animate\(' -and $bannerJs -match 'prefers-reduced-motion: reduce' -and $bannerJs -match 'if \(first \|\| still \|\| !box\.animate\)') 'the banner is hidden until something is due, slides down when it comes due and up once ticked, and opens without the slide on load or under reduced motion (Dave, October 27, 2026)'
Assert-True ($bannerJs -match '<span class="msg--warn" data-admin-offline hidden> &middot; admin offline, this hour is not counted</span>' -and $bannerJs -match 'OFFLINE = 2' -and $bannerJs -match 'function \(\) \{ down\(\); return null; \}' -and $bannerJs -match 'function \(r\) \{ up\(\); return r\.ok') 'the banner opens on "admin offline" after two polls whose request fails outright, and the first answer clears it -- an hour the server never saw cannot be recovered (#3596)'
Assert-True ($bannerJs -match 'due\.hidden = !\(owed > 0\);') 'and a cleared "due" box is hidden again, so an offline strip never shows a stale count'
Assert-True ($bannerJs -match '<button type="button" class="icon-btn icon-btn--ghost" data-admin-close aria-label="Close"' -and $bannerJs -match 'closer\.addEventListener\("click", function \(\) \{\s+keep\(owed\);' -and $bannerJs -match 'sessionStorage\.setItem\(HUSH' -and $bannerJs -match 'if \(owed < hush\) \{ keep\(owed\); \}') 'a ghost close button sinks the toast without clearing the count on the server, and it stays down in this tab until another hour is owed (#3820)'
$ix = @('class="site-header"', 'class="breadcrumbs-bar"', 'class="ph-cards"', 'class="note"') | ForEach-Object { $ph.IndexOf($_) }
Assert-True ((@($ix | Where-Object { $_ -lt 0 }).Count -eq 0) -and ((($ix | Sort-Object) -join ',') -eq ($ix -join ','))) 'the blocks stand in the form''s order'
$evil = Format-ProductHomeHtml -Pages @(@{ Href = '/x"><script>'; Label = '<b>'; Sub = '' })
Assert-True ($evil -notmatch 'x"><script>' -and $evil -match 'href="/x&quot;&gt;&lt;script&gt;"' -and $evil -notmatch '<b>') 'every value is escaped'

Write-Host '-- the test-gate model' -ForegroundColor Cyan
$json = '{ "seconds": { "a.tests.ps1": 10, "b.tests.ps1": 30, "gone.tests.ps1": 5 }, "recordedFrom": { "runs": ["111", "222"], "date": "2026-10-07", "machine": "m", "method": "mean" } }' | ConvertFrom-Json
$m = ConvertFrom-SuiteDurations -Durations $json -SuiteFiles @('a.tests.ps1', 'b.tests.ps1', 'new.tests.ps1')
Assert-Equal 'b.tests.ps1,a.tests.ps1,gone.tests.ps1' (($m.Suites | ForEach-Object { $_.Name }) -join ',') 'suites slowest first'
Assert-Equal 45 $m.Total 'the sum of every recorded suite'
Assert-Equal 'new.tests.ps1' ($m.Missing -join ',') 'a suite on disk the file does not record is missing'
Assert-Equal 'gone.tests.ps1' ($m.Stale -join ',') 'a recorded suite no longer on disk is stale'
Assert-Equal '111,222' ($m.Runs -join ',') 'the runs it was recorded from'
$empty = ConvertFrom-SuiteDurations -Durations $null -SuiteFiles @('a.tests.ps1')
Assert-Equal 0 @($empty.Suites).Count 'no file: no suites'
Assert-Equal 'a.tests.ps1' ($empty.Missing -join ',') 'and every suite on disk is missing'

Write-Host '-- Format-AdminLinkTableHtml: a set of links as Admin draws it (#3830)' -ForegroundColor Cyan
$alt = Format-AdminLinkTableHtml -Items @(@{ Href = '/a'; Label = 'Alpha'; Sub = 'First' }, @{ Href = '/b'; Label = 'Beta'; SubHtml = '<code>second</code>' })
Assert-True ($alt -match '^<section class="admin-list"><table class="table table--dense"><thead><tr><th class="col-start">Name</th><th class="col-start">About</th></tr></thead><tbody>' -and $alt -match '</tbody></table></section>$' -and $alt -notmatch '<h2') 'a set of links is one dense table, a row per link, with no heading and no card'
Assert-True ($alt.Contains('<tr><td class="col-start"><a href="/a">Alpha</a></td><td class="col-start">First</td></tr><tr><td class="col-start"><a href="/b">Beta</a></td><td class="col-start"><code>second</code></td></tr>') -and ([regex]::Matches($alt, '<a ')).Count -eq 2) 'the label is the first column and the row''s one link, the description the second, Sub escaped and SubHtml taken as the caller''s markup, in the caller''s order'
Assert-True ($alt -notmatch '<th>' -and ([regex]::Matches($alt, '<td')).Count -eq 4) 'with no item carrying a Value there is no Value column: two cells to a row'
$altEsc = Format-AdminLinkTableHtml -Items @(@{ Href = '/x?a=1&b="2"'; Label = '<b>L</b>'; Sub = 'S & <i>t</i>'; Id = 'i"d'; Class = 'c"x' }) -Heading 'H <h>' -Id 'sec"id' -NameHead '<N>' -SubHead '<S>' -Empty '<none>'
Assert-True ($altEsc.Contains('<section class="admin-list" id="sec&quot;id"><h2>H &lt;h&gt;</h2>') -and $altEsc.Contains('<th class="col-start">&lt;N&gt;</th><th class="col-start">&lt;S&gt;</th>') -and $altEsc -notmatch '<b>L|<i>t|<h>|<N>|<S>') 'the heading, the section id and the column heads are escaped, and the heading is an h2 over the table, never a class'
Assert-True ($altEsc.Contains('<tr id="i&quot;d" class="c&quot;x"><td class="col-start"><a href="/x?a=1&amp;b=&quot;2&quot;">&lt;b&gt;L&lt;/b&gt;</a></td><td class="col-start">S &amp; &lt;i&gt;t&lt;/i&gt;</td></tr>')) 'a row''s Id and Class go on its <tr>, and its href, label and Sub are escaped'
$altVal = Format-AdminLinkTableHtml -Items @(@{ Href = '/a'; Label = 'A'; Sub = 's'; ValueHtml = '<span class="num">9</span>' }, @{ Href = '/b'; Label = 'B'; Sub = 't' }) -ValueHead 'Size' -Id 'g'
Assert-True ($altVal.Contains('<th class="col-start">About</th><th>Size</th></tr></thead>') -and $altVal.Contains('<td class="col-start">s</td><td><span class="num">9</span></td></tr>') -and $altVal.Contains('<td class="col-start">t</td><td></td></tr>') -and $altVal.Contains('<section class="admin-list" id="g">')) 'a Value column is drawn once any item has one: its head, the value as markup, and an empty cell on the rows with none'
$altBadge = Format-AdminLinkTableHtml -Items @(@{ Href = '/a'; Label = 'A'; Sub = 's'; BadgeHtml = '<span class="badge">!</span>'; TitleBadgeHtml = '<span class="tag">T</span>' })
Assert-True ($altBadge.Contains('<td class="col-start"><a href="/a">A</a> <span class="badge">!</span><span class="tag">T</span></td>')) 'a badge and a title badge stand beside the link in the first column, outside the link'
$altObj = Format-AdminLinkTableHtml -Items @([pscustomobject]@{ Href = '/o'; Label = 'Obj'; Sub = 'from an object' }, $null)
Assert-True ($altObj.Contains('<a href="/o">Obj</a></td><td class="col-start">from an object</td>') -and ([regex]::Matches($altObj, '<tr>')).Count -eq 2) 'items may be objects as well as hashtables, and a null item is no row'
$altEmpty = Format-AdminLinkTableHtml -Items @()
Assert-True ($altEmpty.Contains('<tbody><tr><td class="col-start" colspan="2" role="status">Nothing here yet.</td></tr></tbody>') -and $altEmpty -notmatch '<a ') 'an empty set is one row saying so, spanning the two columns, with no link'
Assert-True ((Format-AdminLinkTableHtml -Items @() -Empty 'Nothing <yet>').Contains('role="status">Nothing &lt;yet&gt;</td>') -and (Format-AdminLinkTableHtml).Contains('role="status">Nothing here yet.</td>')) 'the empty line is the caller''s, escaped, and a call with no -Items at all is the empty set too'
foreach ($slot in 'SubHtml', 'ValueHtml', 'BadgeHtml', 'TitleBadgeHtml') {
    $thrown = $null
    try { [void](Format-AdminLinkTableHtml -Items @(@{ Href = '/a'; Label = 'Lbl'; $slot = 'x <a href="/y">link</a>' })) } catch { $thrown = $_.Exception.Message }
    Assert-True ($thrown -and $thrown -match "-$slot of 'Lbl' holds an <a>") "an <a> in $slot throws, naming the slot and the row, since the label is already the row's one link (#3610)"
}
$noThrow = $null
try { [void](Format-AdminLinkTableHtml -Items @(@{ Href = '/a'; Label = 'L'; SubHtml = '<abbr title="x">t</abbr><article>y</article>' })) } catch { $noThrow = $_.Exception.Message }
Assert-True ($null -eq $noThrow) 'markup that merely starts with <a, an <abbr> or an <article>, is not a link and does not throw'

Write-Host '-- the test-gate overview' -ForegroundColor Cyan
$tg = Format-TestGatePageHtml -Model $m
Assert-True ($tg -match '<h1>Test gate</h1>') 'the overview is named Test gate'
Assert-True ($tg -match '<li><a href="/">Home</a></li>' -and (Format-TestGatePageHtml -Model $m -AdminHref '/elsewhere') -match '<li><a href="/elsewhere">Home</a></li>') 'its Home crumb is the general server''s root, or the address the caller names'
Assert-True ($tg -match '<span aria-current="page">Test gate</span>' -and $tg -notmatch 'href="/dev/test-gate">Test gate</a>') 'the overview is the trail''s last crumb, not a link to itself'
Assert-True ($tg -match '<tr id="group-suites" class="tg-card"><td class="col-start"><a href="/dev/test-gate/suites">All suites</a></td>') 'without groups it drills into one list, All suites, a row of the groups table'
Assert-True ($tg -match '<tr id="recorded" class="tg-card"><td class="col-start"><a href="/dev/test-gate/measured">Where it was measured</a></td><td class="col-start"><span class="num">2026-10-07 . 2 CI runs . 1 not recorded</span>') 'the measurement is a row of its own, with its date, its run count and the suites not recorded'
Assert-True ($tg -notmatch 'Not recorded yet, so the gate charges' -and $tg -notmatch 'class="tiles"') 'the overview has no tiles (the owner, October 27, 2026), and names the unrecorded suites one level down'
Assert-True ($tg -match '<section class="admin-list" id="groups"><table class="table table--dense">' -and $tg -notmatch 'card-grid tg-cards|card--link') 'its groups are one dense table, with no card grid to stand four to a row (the owner, October 27, 2026; Admin''s form, #3830)'
Assert-True ($tg -match 'class="note">Read from the repo') 'the overview closes on where it reads from'
$none = Format-TestGatePageHtml -Model (ConvertFrom-SuiteDurations -Durations $null -SuiteFiles @('a.tests.ps1')) -ReadError 'the file is not there'
Assert-True ($none -match 'No test gate has been measured in this repo yet' -and $none -notmatch 'could not be read' -and $none -match 'No suite durations are recorded in this repo') 'a repo with no suite-durations.json gets the empty state, not a warning (#3470)'
Assert-True ($tg -match '<li><a href="/">Home</a></li>\s*<li><span class="breadcrumbs__sep"[^>]*>.*?</span><a href="/dev/repository">GitHub</a></li>\s*<li><span class="breadcrumbs__sep"[^>]*>.*?</span><span aria-current="page">Test gate</span></li>') 'and its trail reads Home > GitHub > Test gate (the owner, November 2, 2026)'
$bad = Format-TestGatePageHtml -Model $empty -ReadError 'it is not valid JSON'
Assert-True ($bad -match 'msg--warn" role="alert">scripts/tests/suite-durations.json could not be read: it is not valid JSON') 'an unreadable file is a warning'
Assert-True ($bad -match 'No suite durations are recorded\.') 'and the cards say it is empty rather than vanishing'
Assert-True ($null -eq (Format-TestGatePageHtml -Model $m -Path 'nope') -and $null -eq (Format-TestGatePageHtml -Model $m -Path 'suites/nope.tests.ps1') -and $null -eq (Format-TestGatePageHtml -Model $m -Path 'suites/a.tests.ps1/x')) 'a path no page has is $null, which the server answers with a 404'

Write-Host '-- a list''s page and a suite''s' -ForegroundColor Cyan
$all = Format-TestGatePageHtml -Model $m -Path 'suites'
Assert-True ($all -match '<a href="/dev/test-gate">Test gate</a>' -and $all -match '<span aria-current="page">All suites</span>') 'a list''s page sits under Test gate in the trail'
Assert-True ($all.IndexOf('<code>b</code>') -lt $all.IndexOf('<code>a</code>')) 'it lists the slowest first'
Assert-True ($all -match 'href="/dev/test-gate/suites/a.tests.ps1" title="a.tests.ps1"><code>a</code></a>') 'each suite links to its own page, its name without the .tests.ps1 every suite shares'
Assert-True ($all -match '<code>b</code></a></td><td class="num">30.0</td><td class="dp-left"><span class="dp-bar" aria-hidden="true"><span style="width: 100%">' -and $all -match '<code>a</code></a></td><td class="num">10.0</td><td class="dp-left"><span class="dp-bar" aria-hidden="true"><span style="width: 33.33%">') 'each bar is drawn against the slowest suite'
Assert-True ($all -match '<code>gone</code></a> <span class="badge badge--sm badge--neutral">no longer on disk') 'a stale suite is marked'
Assert-True ($all -match '<code>new</code></a> <span class="badge badge--sm badge--neutral">not recorded yet</span></td><td class="num">--</td>') 'an unrecorded suite closes the list, marked'
Assert-True ($all -match '(?s)<div class="page-head"><div class="page-head__title"><h1>[^<]*</h1></div><div class="page-head__end">.*<dt>Suites</dt><dd class="num">4</dd>.*<dt>Sum, one after another</dt><dd class="num">45.0s</dd>.*?</div></div>' -and $all.IndexOf('<dt>Suites</dt>') -lt $all.IndexOf('<table class="table">') -and $all.IndexOf('<dt>Suites</dt>') -gt $all.IndexOf('<main class="shell__body">')) 'its totals stand at the right end of the page header, beside its h1, above the table (#3811)'
Assert-True ($all -notmatch 'class="note"') 'and it spends no height on the source note'
$rows = 1..25 | ForEach-Object { 'r{0:00}.tests.ps1' -f $_ }
$bigJson = ('{ "seconds": { ' + (($rows | ForEach-Object { '"' + $_ + '": 1' }) -join ', ') + ' } }') | ConvertFrom-Json
$big = Format-TestGatePageHtml -Model (ConvertFrom-SuiteDurations -Durations $bigJson -SuiteFiles $rows) -Path 'suites'
Assert-True ([regex]::Matches($big, '<table').Count -eq 3 -and $big -match 'style="--tg-cols: 3"') 'a list of more than twelve suites spreads over tables side by side, at most twelve rows each'
$one = Format-TestGatePageHtml -Model $m -Path 'suites/a.tests.ps1'
Assert-True ($one -match '<h1>a.tests.ps1</h1>' -and $one -match '<a href="/dev/test-gate">Test gate</a>' -and $one -match '<a href="/dev/test-gate/suites">All suites</a>') 'a suite''s page sits under its list in the trail, named whole'
Assert-True ($one -match '<dt>Seconds on CI</dt><dd class="num">10.0s</dd>' -and $one -match '<dt>Share of the sum</dt><dd class="num">22.2%</dd>' -and $one -match '<dt>Rank</dt><dd class="num">2 of 3, slowest first</dd>') 'it says what the suite costs and where it ranks'
Assert-True ((Format-TestGatePageHtml -Model $m -Path 'suites/new.tests.ps1') -match 'not recorded yet') 'an unrecorded suite has a page too, saying so'
$hostile = ConvertFrom-SuiteDurations -Durations ('{ "seconds": { "<x>.tests.ps1": 1 }, "recordedFrom": { "runs": ["1\" onclick=\"x"] } }' | ConvertFrom-Json)
$hp = Format-TestGatePageHtml -Model $hostile -Path 'suites'
Assert-True ($hp -match '&lt;x&gt;' -and $hp -notmatch '<x>') 'a suite name is escaped'

Write-Host '-- where it was measured' -ForegroundColor Cyan
$ms = Format-TestGatePageHtml -Model $m -Path 'measured'
Assert-True ((Format-TestGatePageHtml -Model $m -Path 'measured' -RepoSlug 'DKJ-Solutions/dkj-marketplace') -match 'href="https://github.com/DKJ-Solutions/dkj-marketplace/actions/runs/111"') 'each run links to its CI run, in the repo the origin remote names'
Assert-True ($ms -notmatch 'actions/runs/' -and $ms -match '<dt>CI runs</dt><dd>111, 222</dd>' -and (Format-TestGatePageHtml -Model $m -Path 'measured' -RepoSlug 'x" onclick="y') -notmatch 'actions/runs/') 'without an owner/name it names each run by its number and links nowhere (#3470)'
Assert-True ($ms -match '<dt>Not recorded yet</dt><dd><code>new.tests.ps1</code></dd>') 'the unrecorded suites are named here'
Assert-True ($ms -match 'one after another' -and $ms -match 'never on a workstation') 'and the notes say how to read the numbers'
Assert-True ((Format-TestGatePageHtml -Model $hostile -Path 'measured') -notmatch 'onclick') 'a run id that is not a number is not linked'

Write-Host '-- the test-gate groups' -ForegroundColor Cyan
$groupsJson = '[ { "key": "one", "title": "Step <one>", "guards": "the first step", "tips": ["Mind <this>", "And that"], "split": "this <and> that.", "suites": ["a.tests.ps1", "new.tests.ps1", "away.tests.ps1"] }, { "key": "two", "title": "Step two", "guards": "the second", "suites": ["b.tests.ps1"] } ]' | ConvertFrom-Json
$gm = ConvertFrom-SuiteDurations -Durations $json -SuiteFiles @('a.tests.ps1', 'b.tests.ps1', 'new.tests.ps1') -Groups $groupsJson
Assert-Equal 'one,two' (($gm.Groups | ForEach-Object { $_.Key }) -join ',') 'the groups keep the file''s order, not their cost'
Assert-Equal 'a.tests.ps1' (($gm.Groups[0].Suites | ForEach-Object { $_.Name }) -join ',') 'a group holds its recorded suites only'
Assert-Equal 10 $gm.Groups[0].Total 'and its total is theirs'
Assert-Equal 'new.tests.ps1' ($gm.Groups[0].Unmeasured -join ',') 'a grouped suite on disk with no recorded duration is unmeasured, not dropped'
Assert-Equal 'gone.tests.ps1' ($gm.Ungrouped -join ',') 'a suite no group holds is ungrouped'
Assert-Equal 'away.tests.ps1' ($gm.Unknown -join ',') 'a grouped name not on disk is unknown'
Assert-Equal 0 (@($m.Groups).Count + @($m.Ungrouped).Count) 'with no groups there are no groups, and nothing is called ungrouped'
Assert-Equal 'one,two,ungrouped' ((Get-TestGateLists -Model $gm | ForEach-Object { $_.Key }) -join ',') 'the lists are the groups in order, then the suites no group holds'
$gp = Format-TestGatePageHtml -Model $gm
Assert-True ($gp -match '<tr id="group-one" class="tg-card"><td class="col-start"><a href="/dev/test-gate/one">Step &lt;one&gt;</a></td><td class="col-start"><span class="num">2 suites . 10.0s . 22.2%</span>' -and $gp -notmatch 'Step <one>') 'each group is a row linking its own page, with its count, its sum and its share, escaped'
Assert-True ($gp.IndexOf('id="group-one"') -lt $gp.IndexOf('id="group-two"') -and $gp.IndexOf('id="group-two"') -lt $gp.IndexOf('id="group-ungrouped"')) 'the cards keep the file''s order, the ungrouped last'
Assert-True ($gp -match 'role="alert">In no group of scripts/tests/suite-groups.json: <code>gone.tests.ps1</code>' -and $gp -match '<a href="/dev/test-gate/ungrouped">Not grouped</a>') 'an ungrouped suite is a warning, and still has a list'
Assert-True ($gp -match 'Grouped but no longer on disk: <code>away.tests.ps1</code>') 'a grouped name not on disk is named'
$g1 = Format-TestGatePageHtml -Model $gm -Path 'one'
Assert-True ($g1 -match '<span aria-current="page">Step &lt;one&gt;</span>' -and $g1 -match '<p class="tg-guards">Guards the first step\.</p>') 'a group''s page is named by its title and says what it guards'
Assert-True ($g1 -match '<h3>Points to note</h3><ul><li>Mind &lt;this&gt;</li><li>And that</li><li>Could be split into this &lt;and&gt; that.</li></ul>') 'its notes are escaped, its split advice last'
Assert-True ($g1.IndexOf('</table>') -lt $g1.IndexOf('Points to note')) 'and they come after its table'
Assert-True ($g1 -match 'href="/dev/test-gate/one/a.tests.ps1"' -and $g1 -match 'href="/dev/test-gate/one/new.tests.ps1"' -and $g1 -notmatch 'b\.tests\.ps1') 'it lists its own suites, recorded and not, and no other group''s'
Assert-True ((Format-TestGatePageHtml -Model $gm -Path 'two') -notmatch '<h3>') 'a group with no tips has no notes'
Assert-True ($null -eq (Format-TestGatePageHtml -Model $gm -Path 'one/b.tests.ps1')) 'a suite is found only under its own group'
Assert-True ((Format-TestGatePageHtml -Model $gm -Path 'ungrouped/gone.tests.ps1') -match '<dt>Listed under</dt><dd><a class="dp-link" href="/dev/test-gate/ungrouped">Not grouped</a>') 'an ungrouped suite''s page says where it is listed'
Assert-True ((Format-TestGatePageHtml -Model $gm -Path 'measured') -match '<li>Candidates to split, largest first: Step &lt;one&gt; \(2 suites, 22%\)\. Each one&#39;s own notes say how\.') 'the measurement''s page names the split candidates with their measured size, and only those the file gives a split for'
$gf = Format-TestGatePageHtml -Model $m -GroupsError 'the file is not there'
Assert-True ($gf -match 'suite-groups.json could not be read: the file is not there, so the suites are listed ungrouped' -and $gf -match 'href="/dev/test-gate/suites"') 'without the groups file the page falls back to one list, and says why'

Write-Host '-- what a suite protects, and why this change selects it (#3309, lever 3)' -ForegroundColor Cyan
$header = "<#`r`n.SYNOPSIS`r`n    Tests for x-lib.ps1 -- the thing`r`n    it pins.`r`n`r`n.DESCRIPTION`r`n    Long.`r`n#>`r`nexit 0"
Assert-Equal 'Tests for x-lib.ps1 -- the thing it pins.' (Get-SuiteSynopsis -Text $header) 'the synopsis is the paragraph under .SYNOPSIS, on one line'
Assert-Equal 'Short.' (Get-SuiteSynopsis -Text "<#`n.SYNOPSIS`n    Short.`n#>") 'a synopsis that runs into the closing of the header ends there'
Assert-Equal '' (Get-SuiteSynopsis -Text "exit 0") 'a file with no synopsis has none'
Assert-Equal 20 (Get-SuiteSynopsis -Text ("<#`n.SYNOPSIS`n" + ('w ' * 40) + "`n`n#>") -Max 20).Length 'and a long one is capped'
$sm = ConvertFrom-SuiteDurations -Durations $json -SuiteFiles @('a.tests.ps1', 'b.tests.ps1') -Synopses @{ 'a.tests.ps1' = 'Pins <the> fold' }
Assert-True ((Format-TestGatePageHtml -Model $sm -Path 'suites/a.tests.ps1') -match '<meta name="description" content="Pins &lt;the&gt; fold">') 'a suite''s page describes what it protects, escaped'
Assert-True ((Format-TestGatePageHtml -Model $sm -Path 'suites') -notmatch 'Pins') 'and the list leaves it to that page'
$sp = Format-TestGatePageHtml -Model $sm
Assert-True ($sp -notmatch 'id="selection"' -and $null -eq (Format-TestGatePageHtml -Model $sm -Path 'selection')) 'without a selection there is no change card and no change page'
$selection = @{ Base = 'origin/main'; Changed = @('brandbook/src/<x>.css'); Proven = $true; Reason = ''; PoolCount = 165
                Selected = @('scripts/tests/a.tests.ps1', 'scripts/tests/b.tests.ps1'); Why = @{ 'scripts/tests/a.tests.ps1' = 'it reaches <lib>'; 'scripts/tests/b.tests.ps1' = 'its walk scope covers it' }
                CiText = 'only stylesheets change' }
$selCard = Format-TestGatePageHtml -Model $sm -Selection $selection
Assert-True ($selCard -match '<tr id="selection" class="tg-card"><td class="col-start"><a href="/dev/test-gate/selection">This checkout&#39;s change</a></td><td class="col-start"><span class="num">2 of 165 suites</span>') 'the change is a row on the overview, with what it selects'
$sel = Format-TestGatePageHtml -Model $sm -Selection $selection -Path 'selection'
Assert-True ($sel -match '<dt>Locally</dt><dd>2 of 165 suites</dd>' -and $sel -match '<dt>On CI</dt><dd>only stylesheets change</dd>') 'its page says what runs locally and on CI'
Assert-True ($sel -match 'brandbook/src/&lt;x&gt;.css' -and $sel -match 'it reaches &lt;lib&gt;' -and $sel -notmatch '<lib>') 'the changed paths and the reasons are escaped'
Assert-True ($sel.IndexOf('>b.tests.ps1<') -lt $sel.IndexOf('>a.tests.ps1<') -and $sel -match 'href="/dev/test-gate/suites/a.tests.ps1"') 'the selected suites are listed slowest first, each linking its own page'
$none = Format-TestGatePageHtml -Model $sm -Path 'selection' -Selection @{ Base = 'origin/main'; Changed = @(); Proven = $false; Reason = 'Nothing differs from origin/main, so nothing is selected'; Selected = @(); Why = @{}; PoolCount = 0; CiText = '' }
Assert-True ($none -match 'Nothing differs from origin/main, so nothing is selected\.') 'a clean checkout says there is nothing to select'
$whole = Format-TestGatePageHtml -Model $sm -Path 'selection' -Selection @{ Base = 'origin/main'; Changed = @('scripts/lib/gate-lib.ps1'); Proven = $false; Reason = 'the change touches the selection'; Selected = @(); Why = @{}; PoolCount = 165; CiText = '' }
Assert-True ($whole -match '<dt>Locally</dt><dd>every suite -- the change touches the selection</dd>' -and $whole -notmatch 'Why it runs') 'an unproven selection says every suite runs, and why, with no table'
$allSel = Format-TestGatePageHtml -Model $sm -Path 'selection' -Selection @{ Base = 'origin/main'; Changed = @('x.ps1'); Proven = $true; Reason = ''; Selected = @('scripts/tests/a.tests.ps1', 'scripts/tests/b.tests.ps1'); Why = @{}; PoolCount = 2; CiText = '' }
Assert-True ($allSel -match '<dt>Locally</dt><dd>every suite -- the change can affect all 2</dd>') 'a selection of the whole pool says every suite, not "2 of 2" (Victor)'
Assert-True ($sel -match 'The suites the affected-suite selection picks for it, against origin/main') 'and the page claims the selection, not the whole gate, which may skip the suites first (Victor)'

Write-Host '-- the fit alarm (the owner, October 27, 2026)' -ForegroundColor Cyan
$fit = Format-FitAlarmHtml
Assert-True ($tg -match 'id="fit-alarm"' -and $all -match 'id="fit-alarm"') 'every page the shell draws carries the fit alarm'
Assert-True ($fit -match 'id="fit-alarm" role="alert" hidden' -and $fit -match 'd\.scrollHeight - window\.innerHeight' -and $fit -match 'd\.scrollWidth - d\.clientWidth') 'it starts hidden and judges the document against the window it is read in, both ways'
# The product server's two shells that do not go through Format-GeneralPageHtml carry it too (#3558).
$fitHome = Format-ProductHomeHtml
$fitCd = Format-ConsumerDashboardHtml -Consumers @() -Meta @{ GeneratedAt = 'now' }
Assert-True ($fitHome.Contains($fit) -and $fitHome.IndexOf('id="fit-alarm"') -lt $fitHome.LastIndexOf('</body>') -and $fitCd.Contains($fit) -and $fitCd.IndexOf('id="fit-alarm"') -lt $fitCd.LastIndexOf('</body>')) 'the product''s home page and its Consumers page carry the fit alarm before </body>'
Assert-True ($fit -match 'window\.innerWidth < 1000' -and $fit -match 'ResizeObserver' -and $fit -match 'addEventListener\("resize"') 'it stays quiet in the narrow layout, and judges again on every resize'
Assert-True ($fit -match 'alarm\.textContent = ' -and $fit -notmatch 'innerHTML|fetch\(|XMLHttpRequest') 'it writes text only, and asks nothing of any server'
Assert-True ($fit -match 'querySelectorAll\("h1"\), function \(h\) \{ var m = h\.closest\("dialog"\); return !\(m && m\.matches\(":modal"\)\); \}\)\.length') 'an h1 inside an open modal dialog is left out of the count: a popup opens on its own h1 (#3937)'
Assert-True ($fit -match 'querySelectorAll\("h1"\)' -and $fit -match 'h1 > 1 \|\| \(h1 === 0 && crumbs !== 1\)' -and $fit -match 'querySelectorAll\(trail \+ " li"\)' -and $fit -match 'trail = shell \? "\.shell__bar \.breadcrumbs" : "\.breadcrumbs"') 'the same alarm says so when a page carries more than one h1, or none outside the home page''s one-crumb trail, the trail being the shell bar''s in Admin (#3745; #3830)'
$fitJudge = $fit.Substring($fit.IndexOf('function judge'))
Assert-True ($fitJudge.IndexOf('querySelectorAll("h1")') -gt $fitJudge.IndexOf('window.innerWidth < 1000') -and $fitJudge -notmatch 'innerWidth < 1000 \|\|') 'and the h1 half is not width-gated: the narrow layout silences only the fit half (#3745)'
Assert-Equal 0 ([regex]::Matches($fit, '<h1[\s>]')).Count 'the alarm itself adds no h1 to the page it judges'
Assert-True ($fit -match 'words\(document\.querySelector\(head\)\)' -and $fit -match 'words\(document\.querySelector\(trail \+ " \[aria-current=\\"page\\"\]"\)\)' -and $fit -match 'if \(named > 2\)') 'it warns when the page''s h1 or its current crumb runs past two words (#3797)'
Assert-True ($fit -match 'shell = document\.querySelector\("\.shell:not\(\.shell--fit\) \.shell__list"\)') 'only the page''s own shell switches the alarm into shell mode: a .shell--fit specimen on a brand book page does not, so that page''s own h1 is not called loose (#4030)'
Assert-True ($fit -match 'shell = document\.querySelector\("\.shell:not\(\.shell--fit\) \.shell__list"\)' -and $fit -match 'head = shell \? "\.toolbar > h1, \.page-head h1" : "h1"' -and $fit -match 'The h1 stands loose in the pane, where Admin''s h1 is the toolbar''s or the page header''s') 'in Admin''s shell it reads the toolbar''s h1 and the bar''s trail, and says so when an h1 stands in the pane (#3830)'
Assert-True ($fit -match 'split\(/\\s\+/\)' -and $fit -match '\[\\p\{L\}\\p\{N\}\]/u') 'a word is a whitespace-separated run holding a letter or digit, so a hyphenated word counts once and a lone dash not at all (#3797)'
$fitNamed = $fitJudge.Substring($fitJudge.IndexOf('var named'))
Assert-True ($fitNamed -notmatch 'innerWidth') 'and the page-name half is not width-gated either (#3797)'

Write-Host '-- suite-groups.json against the tree' -ForegroundColor Cyan
# The file is a reading aid and nothing selects suites by it, so the only way it goes wrong is by going
# stale: a suite added without a group, or a group still naming a suite that was removed or renamed.
$realGroups = @((Get-Content -LiteralPath (Join-Path $RepoRoot 'scripts\tests\suite-groups.json') -Raw -Encoding UTF8 | ConvertFrom-Json).groups)
$grouped = @($realGroups | ForEach-Object { @($_.suites) })
$onDisk = @(Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'scripts\tests') -Filter '*.tests.ps1' -File | ForEach-Object { $_.Name })
$noGroup = @($onDisk | Where-Object { $grouped -notcontains $_ })
Assert-True ($noGroup.Count -eq 0) ('every suite is in a group of scripts/tests/suite-groups.json -- add it to the group whose workflow step it guards' + $(if ($noGroup.Count) { ': ' + ($noGroup -join ', ') } else { '' }))
$twice = @($grouped | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
Assert-True ($twice.Count -eq 0) ('and in one group only' + $(if ($twice.Count) { ': ' + ($twice -join ', ') } else { '' }))
$gone = @($grouped | Where-Object { $onDisk -notcontains $_ })
Assert-True ($gone.Count -eq 0) ('and no group names a suite that is not on disk' + $(if ($gone.Count) { ': ' + ($gone -join ', ') } else { '' }))
Assert-True (@($realGroups | Where-Object { -not ($_.key -match '^[a-z-]+$' -and $_.title -and $_.guards) }).Count -eq 0) 'every group has a key, a title and what it guards'
Assert-True (@($realGroups | Where-Object { -not @(@($_.tips) | Where-Object { $_ }).Count }).Count -eq 0) 'and at least one point to note'

Write-Host '-- the SessionStart page' -ForegroundColor Cyan
$ssModel = @{
    Total = 1000; Budget = 4000; State = 'inside'; Ok = $true; Tokens = 320; GeneratedAt = '2026-10-18 00:00:00'; Seconds = 1.2
    Documents = @(
        @{ Display = 'CLAUDE.md'; Bytes = 100; Source = 'measured' },
        @{ Display = '~/persona.md'; Bytes = 900; Source = 'carried' },
        @{ Display = 'lost.md'; Bytes = 0; Source = 'unmeasured' })
}
$ss = Format-SessionStartPageHtml -Model $ssModel
$ssDocs = Format-SessionStartPageHtml -Model $ssModel -Section 'documents'
Assert-True ($ss -match '<h1>SessionStart</h1>') 'the overview is named SessionStart'
Assert-True ($ss -match '<tr id="documents" class="ss-card"><td class="col-start"><a href="/dev/sessionstart/documents">Always-on documents</a></td>') 'each section is a row on the overview, linking its own page (the Stopwatch''s shape)'
Assert-True ($ss -match '<td><span class="num">1,000 B of 4,000 B</span></td>') 'and the documents'' row carries the path against the budget'
Assert-True (([regex]::Matches($ss, '<table')).Count -eq 1 -and $ss -match 'table--dense') 'the overview holds one dense table of its sections, not the documents'' own table'
Assert-True ($ssDocs -match '<h1>Always-on documents</h1>' -and $ssDocs -match '<a href="/dev/performance">Performance</a></li>\s*<li><span class="breadcrumbs__sep"[^>]*>.*?</span><a href="/dev/sessionstart">SessionStart</a>') 'a section''s page is named after it, with a crumb back to the overview, under Performance'
Assert-True ($ssDocs -match 'Headroom \(B\)</div><div class="v num">3,000') 'inside the budget: the headroom'
Assert-True ($ssDocs.IndexOf('~/persona.md') -lt $ssDocs.IndexOf('<code>CLAUDE.md</code></td>')) 'the documents are listed largest first'
Assert-True ($ssDocs -match '~/persona.md</code></td><td class="num">900</td>.*?<td>90.0%</td><td class="dp-left">from the baseline') 'a carried document says so'
Assert-True ($ssDocs -match 'role="status">Not counted.*lost.md') 'an unmeasured document is named, not counted as zero'
Assert-True ($ss.Replace((Format-RepoAdminBanner), '').Replace((Format-FitAlarmHtml), '') -notmatch 'msg--warn' -and $ssDocs.Replace((Format-RepoAdminBanner), '').Replace((Format-FitAlarmHtml), '') -notmatch 'msg--warn') 'no warning inside the budget (the general banner''s own hidden line and the hidden fit alarm aside, #3297)'
Assert-True ($null -eq (Format-SessionStartPageHtml -Model $ssModel -Section 'nope')) 'a slug no section has is no page, which the server answers with a 404'
$ssModel.Total = 5000; $ssModel.Ok = $false; $ssModel.State = 'over-growing'
$over = Format-SessionStartPageHtml -Model $ssModel -Section 'documents'
Assert-True ($over -match 'Over the budget \(B\)</div><div class="v num">1,000') 'over the budget: by how much'
Assert-True ($over -match 'msg--warn" role="alert">The always-on path is over its limit \(over-growing\)') 'and a warning naming the state'
Assert-True ((Format-SessionStartPageHtml -Model $ssModel) -match 'role="alert">The always-on path is over its limit') 'which the overview carries too'
$failed = Format-SessionStartPageHtml -Model $null -ReadError 'boom <x>'
Assert-True ($failed -match 'could not be measured: boom &lt;x&gt;') 'a failed measurement is a warning, escaped'
Assert-True ($failed -match '<td><span class="num">Not measured</span></td>') 'and its row says it was not measured'
Assert-True ((Format-SessionStartPageHtml -Model $null -ReadError 'boom' -Section 'documents') -match 'No always-on document was measured') 'and its page says the table is empty'

Write-Host '-- the SessionStart snapshot' -ForegroundColor Cyan
Assert-True ($ss -notmatch 'id="last-measurement"') 'without a snapshot the overview shows only the live card'
Assert-True ($null -eq (Format-SessionStartPageHtml -Model $ssModel -Section 'layers')) 'and a snapshot section has no page'
$snap = @'
{ "asOf": "2026-10-02", "header": { "eyebrow": "the fourth", "lede": "About **47k** in `CLAUDE.md` <b>" },
  "items": [
    { "id": "a", "name": "Docs", "influence": "direct", "tokens": 600, "measured": true, "source": "s", "previousTokens": 700 },
    { "id": "b", "name": "Stubs", "influence": "setting", "tokens": 100, "measured": false, "source": "s" },
    { "id": "c", "name": "Tools", "influence": "none", "tokens": 300, "measured": false, "source": "s" } ],
  "actions": { "lede": "ranked", "items": [
    { "id": "x", "influence": "direct", "done": true, "tokens": 50, "title": "Old one", "text": "t" },
    { "id": "y", "influence": "setting", "done": false, "tokens": 900, "title": "Open one", "text": "t", "caveat": "careful" } ] },
  "none": { "items": [ { "title": "Harness", "text": "fixed" } ] },
  "advice": { "heading": "Do this", "lede": "the verdict", "steps": [ { "title": "1", "text": "first" } ], "dont": { "label": "Do not", "text": "that" } },
  "footer": "method", "previous": { "noneTokens": 200, "totalTokens": 1000 },
  "source": { "title": "Session-start context", "copied": "2026-10-18" } }
'@ | ConvertFrom-Json
$sp = Format-SessionStartPageHtml -Model $ssModel -Snapshot $snap
$ids = @([regex]::Matches($sp, '<tr id="([a-z-]+)" class="ss-card">') | ForEach-Object { $_.Groups[1].Value })
Assert-Equal 'documents,last-measurement,layers,actions,no-influence,advice,method' ($ids -join ',') 'the snapshot''s sections follow the live card, one card each'
Assert-True ($sp -match 'Efficiency score 30 / 100 \(was 20\)</span>') 'the score card is the no-influence share, against the previous one'
Assert-True ($sp -match '1 open, 1 done</span>' -and $sp -match '<a href="/dev/sessionstart/advice">Do this</a>') 'the actions'' row counts them, and the advice row takes its heading'
$page = { param($slug) Format-SessionStartPageHtml -Model $ssModel -Snapshot $snap -Section $slug }
$lm = & $page 'last-measurement'
Assert-True ($lm -match 'About <strong>47k</strong> in <code>CLAUDE.md</code> &lt;b&gt;') 'the lede renders bold and code, and escapes the rest'
Assert-True ($lm -match 'Direct \(tokens\)</div><div class="v num">~600 \(60%\)') 'the influence tiles sum the layers'
Assert-True ($lm.IndexOf('Direct (tokens)') -lt $lm.IndexOf('About <strong>47k')) 'the lede follows the tiles it sums up, never opens the page (#3591)'
$adv = & $page 'advice'
Assert-True ($adv.IndexOf('first') -lt $adv.IndexOf('the verdict')) 'the advice''s lede follows its steps (#3591)'
$ly = & $page 'layers'
Assert-True ($ly.IndexOf('>Docs') -lt $ly.IndexOf('>Stubs') -and $ly.IndexOf('>Stubs') -lt $ly.LastIndexOf('>Tools')) 'the layers are grouped direct, setting, none'
Assert-True ($ly -match '<td class="num">-100</td>') 'a layer that shrank shows by how much'
Assert-True ($ly -match '<td class="num">~100</td>') 'an estimated layer is marked as one'
$ac = & $page 'actions'
Assert-True ($ac.IndexOf('Open one') -lt $ac.IndexOf('Old one')) 'open actions come before done ones'
Assert-True ($ac -match 'Old one.*?&#10003;</span>Done') 'a done action says so'
Assert-True ($ac -match '<em>Caveat:</em> careful') 'an action carries its caveat'
Assert-True ((& $page 'no-influence') -match '<dt>Harness</dt><dd>fixed</dd>' -and (& $page 'advice') -match '<strong>Do not:</strong> that') 'what cannot change, and the advice, are shown'
Assert-True ((& $page 'method') -notmatch 'claude.ai|Artifact') 'the method card links no Artifact: nothing is published (#3772)'
$badSnap = Format-SessionStartPageHtml -Model $ssModel -SnapshotError 'it is not valid JSON'
Assert-True ($badSnap -match 'session-start-snapshot.json could not be read: it is not valid JSON') 'an unreadable snapshot is a warning'

Write-Host '-- the release-notes page, as the dev server serves it (#3108)' -ForegroundColor Cyan
# The real template, so a change to its shape that would leave the served copy undressed goes red here.
$tpl = [System.IO.File]::ReadAllText((Join-Path $RepoRoot 'scripts\release\release-notes-page-template.html'))
$rn = Format-ReleaseNotesDevPage -Html $tpl
Assert-True ($rn -ne $tpl) 'the template has the shape the dressing needs'
Assert-True (([regex]::Matches($rn, 'id="admin-banner"')).Count -eq 1 -and $rn -match 'class="shell shell--no-aside"' -and $rn -notmatch 'breadcrumbs-bar') 'the release notes carry the general banner once, and stand in Admin''s shell even unnamed: the breadcrumb bar is the product layer''s (#3297, #3831)'
Assert-True ($rn -match '<html lang="en" data-theme-default="lilac" data-width-default="full" data-theme-key="general-pages">') 'it takes the theme key and the lilac default every other page of the general server uses (#3162)'
Assert-True ($rn -match 'house-theme\.js"></script>\s*<script>DKJTheme\.setWidth\("full"\);</script>' -and $rn -notmatch 'fluid: "Fluid"') 'the release notes pin Admin''s one width too, and offer no width choice'
Set-GeneralPagesThemeDefault 'teal'
Assert-True ((Format-ReleaseNotesDevPage -Html $tpl) -match 'data-theme-default="teal"' -and (Format-GeneralPageHtml -Title 't' -Lead '' -Body '') -match 'data-theme-default="teal"') 'a repo''s DefaultTheme reaches the release notes and every general page (#3390)'
Set-GeneralPagesThemeDefault 'x"y'
Assert-True ((Format-GeneralPageHtml -Title 't' -Lead '' -Body '') -match 'data-theme-default="x&quot;y"') 'and is escaped there, whatever was handed in'
Set-GeneralPagesThemeDefault 'blue/sky'
$pairRn = Format-ReleaseNotesDevPage -Html $tpl
$pairGp = Format-GeneralPageHtml -Title 't' -Lead '' -Body ''
Assert-True ($pairRn -match '<html lang="en" data-theme-light="blue" data-theme-dark="sky" data-width-default="full"' -and $pairGp -match '<html lang="en" data-theme-light="blue" data-theme-dark="sky" data-width-default="full"' -and $pairGp -notmatch 'data-theme-default=') 'a light/dark pair reaches the release notes and every general page as data-theme-light/dark (#3608)'
Set-GeneralPagesThemeDefault 'a"/b<'
Assert-True ((Format-GeneralPageHtml -Title 't' -Lead '' -Body '') -match 'data-theme-light="a&quot;" data-theme-dark="b&lt;"') 'and both halves are escaped'
Set-GeneralPagesThemeDefault ''
Assert-True ((Format-ReleaseNotesDevPage -Html $tpl -ThemeKey 'k"x' -AdminHref '/') -match 'data-theme-key="k&quot;x"' -and (Format-ReleaseNotesDevPage -Html $tpl -AdminHref '/') -match '<li><a href="/">Home</a></li>') 'a caller may name the theme key and the Admin crumb''s target, both escaped'
$tplStyleEnd = $rn.IndexOf('</style>')
$houseAt = $rn.IndexOf('<link rel="stylesheet" href="/house-style.css">')
Assert-True ($houseAt -gt $tplStyleEnd -and $tplStyleEnd -gt 0) 'the house stylesheet loads after the template''s own style, so the house body wins'
$tplStyle = $rn.Substring(0, $tplStyleEnd)
Assert-True ($tpl.Contains('var(--code-bg)') -and -not ([regex]'var\(--(bg|panel|ink|ink-soft|ink-faint|line|accent|accent-soft|code-bg)\)').IsMatch($tplStyle) -and $tplStyle.Contains('var(--bg-1)') -and $tplStyle.Contains('var(--primary)')) 'the served template style reads house colour tokens only, never its own palette (owner, October 27, 2026)'
Assert-True (-not $rn.Contains('--panel: var(--bg-2)')) 'so no layer pointing the template''s tokens at house ones is left'
$undeclaredRn = @($script:ReleaseNotesHouseColors.Values | Sort-Object -Unique | Where-Object { $houseCss -notmatch ('--' + [regex]::Escape($_) + '\s*:') })
Assert-Equal '' ($undeclaredRn -join ', ') 'every house token the release-notes rewrite composes is one house-style.css declares, so a rename cannot leave the map behind (#3716)'
Assert-True ((ConvertTo-ReleaseNotesHouseColors -Html '<style>a{color:var(--accent-soft);b:var(--accent)}</style><script>var(--accent)</script>') -eq '<style>a{color:var(--bg-2);b:var(--primary)}</style><script>var(--accent)</script>') 'the rewrite takes the longest name first and stops at the first </style>'
Assert-True ($rn.IndexOf('.wrap { max-width: 1080px; display: grid;') -gt $houseAt -and $rn.Contains('header.masthead h1 { font-family: inherit; font-size: var(--text-h1);') -and $rn.Contains('footer.colophon { margin: 0; padding: 0; border: 0; color: var(--primary-muted);')) 'and its column, h1 and colophon take the Stopwatch page''s measures (owner, October 25, 2026)'
Assert-True ($rn.IndexOf('<script src="/house-theme.js"></script>') -lt $rn.IndexOf('<body')) 'the theme script loads in the head'
Assert-True (($rn -replace '<span class="eyebrow">[^<]*</span>\s*', '') -ceq (Format-ReleaseNotesDevPage -Html $tpl -RepoName 'Org/r')) 'unnamed, the page is the named one but for the template''s eyebrow, which names whose releases these are (#3831)'
Assert-True ($rn -match '<li><a href="/">Home</a></li>\s*<li><span class="breadcrumbs__sep" aria-hidden="true"><svg\ viewBox="0\ 0\ 24\ 24"><path\ fill="currentColor"\ fill-rule="evenodd"\ d="M9\.793\ 16\.707a1\ 1\ 0\ 0\ 1\ 0-1\.414L13\.086\ 12\ 9\.793\ 8\.707a1\ 1\ 0\ 0\ 1\ 1\.414-1\.414l4\ 4a1\ 1\ 0\ 0\ 1\ 0\ 1\.414l-4\ 4a1\ 1\ 0\ 0\ 1-1\.414\ 0"\ clip-rule="evenodd"/></svg></span><span aria-current="page">Release notes</span></li>') 'its trail runs from Admin, on /admin of the general server, to this page'
Assert-True ($rn -notmatch 'DKJTheme\.settings\(' -and $rn -notmatch 'id="settings"') 'no floating settings button: Admin''s theme is chosen on its own /settings page'
Assert-True ($rn.Contains((Format-FitAlarmHtml)) -and $rn.IndexOf('id="fit-alarm"') -gt $rn.IndexOf('@@PAGE_MAIN@@') -and $rn.IndexOf('id="fit-alarm"') -lt $rn.LastIndexOf('</body>') -and ([regex]::Matches($rn, 'id="fit-alarm"')).Count -eq 1) 'and the fit alarm once, closing the body as every other admin page does (#3558)'
Assert-True ($rn.Contains('<div class="wrap">') -and $rn.Contains('@@PAGE_MAIN@@') -and $rn.Contains('@@PAGE_STYLE@@')) 'the template''s own content is left alone'
# The settings panel's width reaches main and .container only, and the template's column is neither, so the
# template answers data-width itself -- every width the theme script offers but fluid, which is its own column.
Assert-True ($tpl.Contains(':root[data-width="phone"] .wrap {') -and $tpl.Contains(':root[data-width="full"] .wrap { max-width: none; }')) 'the template''s column follows the page-width setting'
Assert-Equal '<html>fixture</html>' (Format-ReleaseNotesDevPage -Html '<html>fixture</html>') 'a page without the template''s shape is served as it came'
$rnNamed = Format-ReleaseNotesDevPage -Html $tpl -RepoName 'Org/repo'
Assert-True ($rnNamed -notmatch 'class="site-header"' -and $rnNamed -notmatch 'class="breadcrumbs-bar"' -and $rnNamed -match 'class="shell shell--no-aside"' -and $rnNamed -match 'class="nav-item" href="/dev/release-notes" aria-current="page"' -and $rnNamed -notmatch 'class="eyebrow"' -and $rnNamed -match '<div class="toolbar"><h1>@@PAGE_HEADING@@</h1></div>' -and ([regex]::Matches($rnNamed, '<h1>')).Count -eq 1 -and $rnNamed -match '<header class="masthead">\s*@@PAGE_BACK@@\s*@@PAGE_MASTHEAD@@\s*<') 'an Admin''s release notes stand in the desktop shell, no site header, the navigation on Release notes, and the masthead''s h1 lifted into the toolbar, with no eyebrow (#3423, #3811, #3830)'
$rnCardsHtml = $tpl.Replace('@@PAGE_MAIN@@', '<div class="card-grid cards" id="cards"><a class="card" id="v2-39" href="/dev/release-notes/v2.39.0" title="Fold &lt;x&gt;"><span class="card-head"><span class="sv">2.39</span><span class="chip accent sc">LIVE</span></span><span class="sd">2026-10-01</span></a><a class="card" id="v2-38" href="/dev/release-notes/v2.38.0" title="Older"><span class="card-head"><span class="sv">2.38</span></span><span class="sd">2026-09-01</span></a></div>')
$rnRows = Format-ReleaseNotesDevPage -Html $rnCardsHtml -RepoName 'Org/repo'
Assert-True ($rnRows -match '<section class="admin-list" id="cards"><table class="table table--dense"><thead><tr><th class="col-start">Version</th><th class="col-start">Title</th><th>Date</th></tr></thead><tbody>' -and $rnRows -notmatch '<a class="card"|card-grid cards') 'an Admin''s release overview is one dense table, Version, Title and Date, in place of the card grid (#3830)'
Assert-True ($rnRows.Contains('<tr><td class="col-start"><a href="/dev/release-notes/v2.39.0">2.39</a> <span class="tag">LIVE</span></td><td class="col-start">Fold &lt;x&gt;</td><td>2026-10-01</td></tr><tr><td class="col-start"><a href="/dev/release-notes/v2.38.0">2.38</a></td><td class="col-start">Older</td><td>2026-09-01</td></tr>')) 'a release row is its version linking its page, the LIVE chip beside it as a tag only where it has one, its title escaped, and its date'
Assert-True ($rnNamed.IndexOf('class="tb-scroll"') -lt $rnNamed.IndexOf('<div class="wrap">') -and $rnNamed.IndexOf('<div class="wrap">') -lt $rnNamed.LastIndexOf('</div></div></div>') -and $rnNamed -notmatch '<main class="page-column">') 'and the template''s own column sits in the scroll pane, with no page column of the shell around it'
Assert-True ($rn -match '<span class="eyebrow">@@PAGE_TITLE@@</span>' -and $tpl -match '<span class="eyebrow">@@PAGE_TITLE@@</span>') 'and with no site header the eyebrow stays, as it does in the template the Worker serves'

$rnEmpty = Format-ReleaseNotesEmptyPageHtml -RepoName 'Org/repo'
Assert-True ($rnEmpty -match '<h1>Release notes</h1>' -and $rnEmpty -match 'role="status">No release has been cut yet' -and $rnEmpty -notmatch 'role="alert">No release') 'before the first cut the index is an empty state, not a warning (#3580)'
$srv = [System.IO.File]::ReadAllText((Join-Path $repoRoot 'plugins\dkj-policy\apps\admin\pages\serve-general-pages.ps1'))
Assert-True ($srv -match '\$run\.ExitCode -eq 3\) \{ \$noRelease = \$true \}' -and $srv -match 'Format-ReleaseNotesEmptyPageHtml') 'the server reads the builder''s exit 3 as that empty state (#3580)'

Write-Host '-- a release''s own page, as the dev server serves it (owner, October 25, 2026)' -ForegroundColor Cyan
$relPage = $tpl.Replace('@@PAGE_BACK@@', '<a class="back" href="/dev/release-notes">&larr; All releases</a>').Replace('@@PAGE_HEADING@@', 'Version 2.39')
$rel = Format-ReleaseNotesDevPage -Html $relPage -Release
Assert-True ($rel -match '<li><span class="breadcrumbs__sep"[^>]*>.*?</span><a href="/dev/release-notes">Release notes</a></li>\s*<li><span class="breadcrumbs__sep"[^>]*>.*?</span><span aria-current="page">Version 2\.39</span></li>') 'its trail runs Home > Release notes > the version read off its own h1, with Release notes a link'
Assert-True ($rel -notmatch 'class="back"') 'and its own way back is taken out, because that crumb already is one'
Assert-True ($rn.IndexOf('.cards > .card { padding: var(--spacing-3) var(--spacing-4); margin-top: 0; }') -gt $rn.IndexOf('/house-style.css')) 'the release cards take a tighter padding than the house .card, after the house file so it holds (owner, October 25, 2026)'
Assert-True ($rn.IndexOf('.cards > .card { gap: var(--spacing-1); }') -gt $rn.IndexOf('/house-style.css') -and $rn.Contains('.cards .card-head .chip { padding: var(--spacing-0-5) var(--spacing-2); font-size: var(--text-xs); line-height: 1.2;') -and $rn -notmatch 'margin-block: calc\(-1') 'the version and its date stand --spacing-1 apart, and the LIVE chip takes the house .tag size so it keeps the card''s padding and stretches no row (Maikel, October 29, 2026)'
Assert-True ((Format-ReleaseNotesDevPage -Html ($tpl.Replace('@@PAGE_HEADING@@', '<b>x</b>')) -Release) -match 'aria-current="page">Release</span>') 'an h1 not of the builder''s own shape never reaches the crumb'
Assert-True ((Format-ReleaseNotesDevPage -Html $relPage) -match 'class="back"') 'while the index keeps whatever the page carries'
$rnIdx = 'C:\r\dkj-policy\releases\page\release-notes.html'
$q = Resolve-ReleaseNotesRequest -Path '/dev/release-notes' -IndexFile $rnIdx
Assert-True ($q.File -eq $rnIdx -and $q.Version -eq '') '/dev/release-notes is the index'
$q = Resolve-ReleaseNotesRequest -Path '/dev/release-notes/v2.39.0/' -IndexFile $rnIdx
Assert-True ($q.File -eq 'C:\r\dkj-policy\releases\page\release-notes\v2.39.0.html' -and $q.Version -eq '2.39.0') 'a release''s address is its page in the folder named after the index, a trailing slash ignored'
Assert-Equal 'C:\r\dkj-policy\releases\page\release-notes\v2.39.0.html' (Resolve-ReleaseNotesRequest -Path '/dev/release-notes/v2.39' -IndexFile $rnIdx).File 'and the version as the page shows it reaches the same page'
Assert-True ($null -eq (Resolve-ReleaseNotesRequest -Path '/dev/release-notes/..\..\x' -IndexFile $rnIdx) -and $null -eq (Resolve-ReleaseNotesRequest -Path '/release-notesx' -IndexFile $rnIdx) -and $null -eq (Resolve-ReleaseNotesRequest -Path '/dev/issues' -IndexFile $rnIdx)) 'anything but a version is not the release notes'' to answer, so no request names a file outside that folder'
$rnFix = Join-Path ([System.IO.Path]::GetTempPath()) ('rn-built-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Force -Path $rnFix | Out-Null
    $rnFixIdx = Join-Path $rnFix 'release-notes.html'
    [System.IO.File]::WriteAllText($rnFixIdx, 'x')
    Assert-True ($null -eq (Get-ReleaseNotesBuiltTime -IndexFile $rnFixIdx)) 'an index built before releases had pages of their own counts as not built, so it is rebuilt'
    New-Item -ItemType Directory -Force -Path (Join-Path $rnFix 'release-notes') | Out-Null
    Assert-True ($null -ne (Get-ReleaseNotesBuiltTime -IndexFile $rnFixIdx)) 'and one with its release folder beside it is built'
    Assert-True ($null -eq (Get-ReleaseNotesBuiltTime -IndexFile (Join-Path $rnFix 'absent.html'))) 'and no index is not built either'
} finally { Remove-Item -Recurse -Force -LiteralPath $rnFix -ErrorAction SilentlyContinue }

Write-Host '-- the Issues model' -ForegroundColor Cyan
$now = [DateTime]::new(2026, 10, 18, 12, 0, 0, [DateTimeKind]::Utc)
$isOpen = '[ { "number": 7, "title": "Free <b>", "url": "https://github.com/Org/some-repo/issues/7", "state": "OPEN", "labels": [ { "name": "bug" }, { "name": "prio-3" } ], "assignees": [], "createdAt": "2026-10-16T12:00:00Z", "closedAt": null },
  { "number": 8, "title": "Parked", "url": "javascript:alert(1)", "state": "OPEN", "labels": [ { "name": "feature" }, { "name": "awaiting-decision-dev" } ], "assignees": [ { "login": "a" } ], "createdAt": "2026-10-10T12:00:00Z", "closedAt": null },
  { "number": 9, "title": "Claimed", "state": "OPEN", "labels": [ { "name": "bug-inbound" }, { "name": "bug" }, { "name": "prio-3" } ], "assignees": [ { "login": "b" } ], "createdAt": "2026-08-01T12:00:00Z", "closedAt": null } ]' | ConvertFrom-Json
$isRecent = '[ { "number": 1, "title": "Done", "state": "CLOSED", "stateReason": "COMPLETED", "labels": [ { "name": "bug" }, { "name": "prio-2" } ], "assignees": [], "createdAt": "2026-10-17T00:00:00Z", "closedAt": "2026-10-17T10:00:00Z" },
  { "number": 1, "title": "Done", "state": "CLOSED", "stateReason": "COMPLETED", "labels": [ { "name": "bug" }, { "name": "prio-2" } ], "assignees": [], "createdAt": "2026-10-17T00:00:00Z", "closedAt": "2026-10-17T10:00:00Z" },
  { "number": 2, "title": "Old one closed", "state": "CLOSED", "stateReason": "NOT_PLANNED", "labels": [], "assignees": [], "createdAt": "2026-09-01T00:00:00Z", "closedAt": "2026-10-01T00:00:00Z" },
  { "number": 3, "title": "Closed before the window", "state": "CLOSED", "stateReason": "COMPLETED", "labels": [], "assignees": [], "createdAt": "2026-09-01T00:00:00Z", "closedAt": "2026-09-02T00:00:00Z" },
  { "number": 7, "title": "Free <b>", "url": "https://github.com/Org/some-repo/issues/7", "state": "OPEN", "labels": [ { "name": "bug" }, { "name": "prio-3" } ], "assignees": [], "createdAt": "2026-10-16T12:00:00Z", "closedAt": null } ]' | ConvertFrom-Json
$im = ConvertFrom-IssueList -Open @($isOpen | ForEach-Object { $_ }) -Recent @($isRecent | ForEach-Object { $_ }) -Now $now -Days 28
Assert-Equal '7,9,8' ((@($im.Open) | ForEach-Object { $_.Number }) -join ',') 'open issues, highest priority first, then by number'
Assert-Equal 'Free,Claimed,Parked' ((@($im.Open) | ForEach-Object { $_.Board }) -join ',') 'a parking label wins over an assignee; an assignee makes it claimed'
Assert-Equal 'bug-inbound' (@($im.Open)[1].Kind) 'an inbound label names the kind before bug'
Assert-Equal 3 $im.Opened 'opened in the window: #7, #8 and #1, #1 counted once'
Assert-Equal 2 $im.Closed 'closed in the window: #1 and #2, not #3'
Assert-Equal 1 $im.Matrix['3'].Free 'the matrix counts the free prio-3 issue...'
Assert-Equal 1 $im.Matrix['3'].Claimed '...and the claimed one'
Assert-Equal 1 $im.Matrix['0'].Parked 'an issue without a priority lands in row 0'
Assert-Equal 4 @($im.Weeks).Count 'a 28-day window is four weeks'
Assert-Equal 2 @($im.Weeks)[-1].Opened 'the last week holds the openings of #7 and #1'
Assert-Equal 1 @($im.Weeks)[-1].Closed 'and the one close of that week'
Assert-Equal 365.0 ([double]$im.MedianCloseHours) 'the median of 10 h and 720 h is their mean'
Assert-Equal 'completed,not planned' ((@($im.ClosedBy.Reason) | ForEach-Object { $_.Name }) -join ',') 'closed-as reasons, lowercase'

Write-Host '-- the Issues page' -ForegroundColor Cyan
$ip = Format-IssuesPageHtml -Model $im -GeneratedAt '2026-10-18 14:00:00' -Seconds 3.2
Assert-True ($ip -match '<h1>Issues</h1>' -and $ip -match '<span aria-current="page">Issues</span>') 'the page is named Issues, in the h1 and the trail'
Assert-True ($ip -match 'Open now</div><div class="v num">3<') 'the tile counts the open issues'
Assert-True ($ip.Contains('Free &lt;b&gt;') -and -not $ip.Contains('Free <b>')) 'an issue title is escaped'
Assert-True ($ip.Contains('href="https://github.com/Org/some-repo/issues/7"')) 'an open issue links to the url gh gave it, not to a repo this lib knows'
Assert-True ($ip -notmatch 'href="javascript' -and $ip.Contains('#8 Parked')) 'an issue whose url is not a GitHub issue link is shown without an href'
Assert-True ($ip -notmatch 'dkj-claude-plugins') 'and nothing of this repo is built into the page'
Assert-True ($ip -match '<div class="grid__head"><h2>Closed</h2>' -and ([regex]::Matches($ip, '<h3>')).Count -eq 3 -and $ip -match '<section class="card grid__full">\r?\n<div class="card__head"><h3>Closed as</h3>') 'the three closed breakdowns stand under one h2, each card titled with an h3 (#3175)'
Assert-True ($ip -notmatch '<h2 class="card' -and ([regex]::Matches($ip, '<h2>')).Count -eq ([regex]::Matches($ip, '<div class="grid__head"><h2>')).Count) 'every h2 on the page stands in a grid__head, above its cards'
Assert-True ((Format-IssuesPageHtml -Model $im -RepoName 'Org/some<repo>') -match 'name="description" content="The GitHub issues of Org/some&lt;repo&gt;:' -and (Format-IssuesPageHtml -Model $im -RepoName 'Org/x') -match '<title>Org/x -- Issues</title>') 'the repo''s name, escaped, is in the description and the title (#3585)'
Assert-Equal '' (ConvertTo-IssueRow -Issue ('{ "number": 1, "title": "t", "url": "https://github.com/a/b/issues/1x" }' | ConvertFrom-Json)).Url 'a url with anything after the number is not kept'
Assert-Equal 'https://github.com/a/b/issues/1' (ConvertTo-IssueRow -Issue ('{ "number": 1, "title": "t", "url": "https://github.com/a/b/issues/1" }' | ConvertFrom-Json)).Url 'a GitHub issue url is kept'
Assert-Equal '' (ConvertTo-IssueRow -Issue ('{ "number": 1, "title": "t" }' | ConvertFrom-Json)).Url 'an issue without a url has none'
Assert-True ($ip.Contains('/refresh?page=issues')) 'the footer offers a fresh read'
$ipNone = Format-IssuesPageHtml -Model (ConvertFrom-IssueList -Now $now)
Assert-True ($ipNone.Contains('No open issue')) 'no open issue says so instead of an empty table'
$ipFailed = Format-IssuesPageHtml -Model $null -ReadError 'gh issue list exited 1'
Assert-True ($ipFailed.Contains('msg--warn') -and $ipFailed.Contains('gh issue list exited 1')) 'a failed read is a warning on the page'
Write-Host '-- the repo name and the always-on lib, as the general server finds them (#3119)' -ForegroundColor Cyan
Assert-Equal 'Foo/bar' (ConvertFrom-GitRemoteUrl 'https://github.com/Foo/bar.git') 'an https remote reads as owner/name'
Assert-Equal 'Foo/bar' (ConvertFrom-GitRemoteUrl 'git@github.com:Foo/bar.git') 'and so does an scp-style ssh remote'
Assert-Equal 'Foo/bar.js' (ConvertFrom-GitRemoteUrl 'ssh://git@github.com/Foo/bar.js') 'a dot in the name stays, and ssh:// is read'
Assert-Equal 'Foo/bar' (ConvertFrom-GitRemoteUrl 'https://user@github.com/Foo/bar/') 'a user and a trailing slash are dropped'
Assert-Equal '' (ConvertFrom-GitRemoteUrl 'https://gitlab.com/Foo/bar.git') 'a host that is not github.com is no repo name'
Assert-Equal '' (ConvertFrom-GitRemoteUrl 'https://github.com/Foo/bar baz') 'nor is a name with a space'
Assert-Equal '' (ConvertFrom-GitRemoteUrl 'https://github.com/Foo/..') 'nor a dot-dot'
Assert-Equal '' (ConvertFrom-GitRemoteUrl '') 'nor is no remote'
$cands = @(Get-AlwaysOnBudgetLibCandidates -RepoRoot 'C:\r\repo' -PluginRoot 'C:\r\mkt\plugins\dkj-policy')
Assert-Equal 'C:\r\repo\scripts\lib\always-on-budget-lib.ps1' $cands[0] 'the repo''s own copy is tried first'
Assert-Equal 'C:\r\mkt\plugins\dkj-policy\scripts\lib\always-on-budget-lib.ps1' $cands[1] 'then the dkj-policy plugin the server runs from (#3198)'
Assert-Equal 2 $cands.Count 'and nothing else: the server is dkj-policy''s, so no other version is searched for'
$cands = @(Get-DkjPolicyScriptCandidates -RepoRoot 'C:\r\repo' -PluginRoot 'C:\cache\mkt\dkj-policy\5.26.0\' -RelativePath 'scripts\release\build-release-notes-page.ps1')
Assert-Equal 'C:\r\repo\scripts\release\build-release-notes-page.ps1' $cands[0] 'the release-notes builder is looked for the same way: the repo''s own copy first (#3189)'
Assert-Equal 'C:\cache\mkt\dkj-policy\5.26.0\scripts\release\build-release-notes-page.ps1' $cands[1] 'then in the cached dkj-policy version the server runs from, the same release as the server'
Write-Host '-- when /release-notes builds its page first (#3189)' -ForegroundColor Cyan
$built = [datetime]'2026-10-19 10:00'
Assert-Equal 'absent' (Get-ReleaseNotesPageNeed -PageTime $null -NewestInputTime $built) 'no page is built'
Assert-Equal 'absent' (Get-ReleaseNotesPageNeed -PageTime $null -NewestInputTime $null) 'even where there is nothing to build it from: the build says why'
Assert-Equal 'stale' (Get-ReleaseNotesPageNeed -PageTime $built -NewestInputTime $built.AddMinutes(1)) 'a page older than a release document is rebuilt'
Assert-Equal '' (Get-ReleaseNotesPageNeed -PageTime $built -NewestInputTime $built) 'one as new as the newest document is served as it is'
Assert-Equal '' (Get-ReleaseNotesPageNeed -PageTime $built -NewestInputTime $null) 'and so is a page with no document beside it'


Write-Host '-- the Specialists model' -ForegroundColor Cyan
# The emoji and the em dash as code points: the script layer is ASCII.
$compass = [char]::ConvertFromUtf32(0x1F9ED)
$agentText = "---`nname: paula`nid: 09`ndescription: >`n  Project Planner -- tracks`n  deadlines.`ntools: Read`n---`n`nYou are **Paula $compass**, the Project Planner. Your playbook`nlives here.`n"
$sa = ConvertTo-SpecialistRow -Id '02-09' -Plugin 'dkj-subagents-alpha' -Form subagent -Text $agentText -ManualBytes 1000 -LensBytes $null -Enabled $true
Assert-Equal 'Paula' $sa.Name 'a subagent''s name comes from its "You are" line'
Assert-Equal $compass $sa.Emoji 'and its emoji beside it'
Assert-Equal 'Project Planner' $sa.Title 'and its title, without "the"'
Assert-Equal '09' $sa.Number 'the number is the id''s second half'
Assert-Equal ([Text.Encoding]::UTF8.GetByteCount('Project Planner -- tracks deadlines.')) $sa.ListingBytes 'the listing is the folded description, its lines joined'
Assert-Equal ([Text.Encoding]::UTF8.GetByteCount("`nYou are **Paula $compass**, the Project Planner. Your playbook`nlives here.`n")) $sa.DefinitionBytes 'the definition is the file without its frontmatter'
Assert-True ($null -eq $sa.LensBytes) 'no lens is $null, not 0'
Assert-Equal ($sa.ListingBytes + $sa.DefinitionBytes + 1000) $sa.TotalBytes 'the full read sums the parts that exist'
$personaText = "---`nid: 01`ngroup: 01`n---`n`n# Chris $compass " + [char]0x2014 + " the Chief of Staff (*Chief of Staff Chris*)`n`nBody.`n"
$pa = ConvertTo-SpecialistRow -Id '01-01' -Plugin 'dkj-subagents-alpha' -Form persona -Text $personaText -Enabled $true
Assert-Equal 'Chris|Chief of Staff|0' ($pa.Name + '|' + $pa.Title + '|' + $pa.ListingBytes) 'a persona''s name and title come from its h1, and it has no listing'
Assert-True $pa.AlwaysOn 'the orchestrator''s persona is always-on'
$empty = ConvertTo-SpecialistRow -Id '02-09' -Plugin 'x' -Form subagent -Text "---`n---`nYou are **Ann**, the Tester. Body`n"
Assert-Equal 'Ann|0' ($empty.Name + '|' + $empty.ListingBytes) 'an empty frontmatter block is cut cleanly, with no listing'
Assert-Equal '07-77' (ConvertTo-SpecialistRow -Id '07-77' -Plugin 'x' -Form subagent -Text 'no shape').Name 'a file of no known shape is named by its id'

Write-Host '-- the specialist teams, as the Plugins pages group them' -ForegroundColor Cyan
$evil = ConvertTo-SpecialistRow -Id '06-99' -Plugin 'dkj-subagents-ecomm' -Form subagent -Text "---`ndescription: <b>x</b>`n---`nYou are **Eve <i>**, the Bad <b>. Body`n" -ManualBytes 99999
$offOnly = ConvertTo-SpecialistRow -Id '07-01' -Plugin 'dkj-subagents-aaa' -Form subagent -Text 'x'
$onAddOn = ConvertTo-SpecialistRow -Id '07-02' -Plugin 'dkj-subagents-zzz' -Form subagent -Text 'x' -Enabled $true
$order = @(Get-SpecialistPlugins -Rows @($evil, $offOnly, $onAddOn, $sa) | ForEach-Object { $_.Short }) -join ','
Assert-Equal 'alpha,zzz,aaa,ecomm' $order 'the core team, then add-on teams enabled here, then the off ones by name'
Write-Host '-- the old Specialists addresses (the owner, October 28, 2026)' -ForegroundColor Cyan
Assert-Equal '/plugins/dkj-subagents|/plugins/dkj-subagents/dkj-subagents-alpha|/plugins/dkj-subagents/dkj-subagents-alpha/paula|/plugins/dkj-subagents' ((Resolve-SpecialistsRedirect -Path '/specialists'), (Resolve-SpecialistsRedirect -Path '/specialists/alpha'), (Resolve-SpecialistsRedirect -Path '/specialists/alpha/paula'), (Resolve-SpecialistsRedirect -Path '/specialists/') -join '|') 'every Specialists address lands on the teams'' Plugins pages, the team and the specialist kept'
Assert-Equal '||' ((Resolve-SpecialistsRedirect -Path '/dev/plugins'), (Resolve-SpecialistsRedirect -Path '/specialistsx'), (Resolve-SpecialistsRedirect -Path '/Specialists') -join '|') 'and nothing else is one'
Write-Host '-- the Plugins page: every plugin the marketplace ships (the owner, October 27, 2026)' -ForegroundColor Cyan
Assert-Equal '/plugins|/plugins/dkj-policy|/plugins/dkj-subagents/dkj-subagents-alpha/paula|/plugins/dkj-policy/dkj-brandbook/tokens/color|/plugins|||' ((Resolve-MarketplaceRedirect -Path '/marketplace'), (Resolve-MarketplaceRedirect -Path '/marketplace/dkj-policy'), (Resolve-MarketplaceRedirect -Path '/marketplace/dkj-subagents/dkj-subagents-alpha/paula'), (Resolve-MarketplaceRedirect -Path '/marketplace/dkj-policy/dkj-brandbook/tokens/color'), (Resolve-MarketplaceRedirect -Path '/marketplace/'), (Resolve-MarketplaceRedirect -Path '/plugins'), (Resolve-MarketplaceRedirect -Path '/marketplacex'), (Resolve-MarketplaceRedirect -Path '/marketplace/A') -join '|') 'an old Marketplace address lands on the same level under /plugins, the brand book''s token pages included, the url following the h1 back to Plugins (#4011); nothing else is one, /plugins itself least of all'
$mpAt = { param($p) $a = Resolve-MarketplaceAddress -Path $p; if ($a) { $a.Group + '>' + $a.Plugin + '>' + $a.Specialist } else { 'none' } }
Assert-Equal '>>|dkj-subagents>>|dkj-subagents>dkj-subagents-alpha>|dkj-subagents>dkj-subagents-alpha>paula|>dkj-policy>|dkj-policy>bwj-development>|none|none' ((& $mpAt '/plugins'), (& $mpAt '/plugins/dkj-subagents/'), (& $mpAt '/plugins/dkj-subagents/dkj-subagents-alpha'), (& $mpAt '/plugins/dkj-subagents/dkj-subagents-alpha/paula'), (& $mpAt '/plugins/dkj-policy'), (& $mpAt '/plugins/dkj-policy/bwj-development'), (& $mpAt '/marketplacex'), (& $mpAt '/plugins/A') -join '|') 'a /plugins address names its levels, and /plugins/dkj-subagents alone is the teams'' group page, never a plugin of that name (it was a 404 after the add-ons'' move)'
Assert-Equal 'core team|add-on team|workflow|add-on to dkj-policy|plugin' ((Get-MarketplacePluginKind -Name 'dkj-subagents-alpha'), (Get-MarketplacePluginKind -Name 'dkj-subagents-shopify'), (Get-MarketplacePluginKind -Name 'dkj-policy' -Source './plugins/dkj-policy'), (Get-MarketplacePluginKind -Name 'dkj-solutions' -Source './plugins/dkj-policy/extensions/dkj-solutions'), (Get-MarketplacePluginKind -Name 'x' -Source './plugins/x') -join '|') 'a plugin''s kind: the core team, an add-on team, the workflow, an add-on to it, or a plain plugin'
$plOn = @{ Name = 'dkj-policy'; Kind = 'workflow'; Source = './plugins/dkj-policy'; Version = '5.34.0'; Enabled = $true; Summary = 'The <way>.'; Description = 'All of it.'; Subagents = 0; Personas = 0; Skills = 26; Hooks = 1 }
$plOff = @{ Name = 'bwj-development'; Kind = 'add-on to dkj-policy'; Source = './plugins/dkj-policy/extensions/bwj-development'; Version = ''; Enabled = $false; Summary = ''; Description = ''; Subagents = 0; Personas = 0; Skills = 7; Hooks = 0 }
$tmAlpha = @{ Name = 'dkj-subagents-alpha'; Kind = 'core team'; Source = './plugins/dkj-subagents/dkj-subagents-alpha'; Version = '5.34.0'; Enabled = $true; Summary = 'The core.'; Description = ''; Subagents = 15; Personas = 4; Skills = 4; Hooks = 1 }
$tmEcomm = @{ Name = 'dkj-subagents-ecomm'; Kind = 'add-on team'; Source = './plugins/dkj-subagents/dkj-subagents-ecomm'; Version = '5.34.0'; Enabled = $false; Summary = ''; Description = ''; Subagents = 3; Personas = 0; Skills = 0; Hooks = 0 }
$market = @($tmAlpha, $tmEcomm, $plOn, $plOff)
$pp = Format-MarketplacePluginsPageHtml -Plugins $market
Assert-True ($pp -match '<h1>Plugins</h1>' -and $pp -match '<span aria-current="page">Plugins</span>' -and $pp -match '>product</span>') 'the overview is named Plugins, in the h1 and the trail, on the product''s site header'
Assert-Equal 2 ([regex]::Matches($pp, 'menu-item__label"><h2>')).Count 'one card per plugin, its label the h2 -- the teams sharing one, and dkj-policy''s add-ons on its page'
Assert-True ($pp.Contains('<div class="grid-3" id="plugins">') -and -not $pp.Contains('<h2>dkj-marketplace</h2>') -and -not $pp.Contains('grid__head')) 'no section h2 above the cards: each card''s title is the h2 (Maikel, October 30, 2026)'
Assert-True ($pp -notmatch 'href="/specialists') 'and no Specialists card: the specialists are on their teams'' pages (the owner, October 28, 2026)'
Assert-True ($pp.Contains('<section class="card card--link pl-card" id="group-dkj-subagents">') -and $pp.Contains('href="/plugins/dkj-subagents"') -and $pp.Contains('menu-item__label"><h2>dkj-subagents</h2><span class="menu-item__sub">2 specialist teams &middot; 1 enabled here</span>')) 'the specialist teams are one card of their own, linking their page and counting them (the owner, October 27, 2026)'
Assert-True (-not $pp.Contains('id="plugin-dkj-subagents-alpha"') -and -not $pp.Contains('href="/plugins/dkj-subagents-')) 'and no team has a card of its own on the overview'
Assert-True ($pp.IndexOf('id="group-dkj-subagents"') -lt $pp.IndexOf('id="plugin-dkj-policy"') -and -not $pp.Contains('id="plugin-bwj-development"') -and -not $pp.Contains('/plugins/bwj-development')) 'the teams'' card stands where the first team does, the rest in the marketplace''s order, and no add-on of dkj-policy has a card here (Maikel, October 30, 2026)'
Assert-True ($pp.Contains('<section class="card card--link pl-card" id="plugin-dkj-policy">') -and $pp.Contains('href="/plugins/dkj-policy"') -and $pp.Contains('menu-item__label"><h2>dkj-policy</h2><span class="menu-item__sub">workflow &middot; v5.34.0 &middot; enabled here</span>')) 'each other card is a link to its own page, saying only what it is, its version and whether it is on here'
Assert-True (-not $pp.Contains('<dl class="facts">') -and -not $pp.Contains('The &lt;way&gt;') -and -not $pp.Contains('All of it.')) 'the facts and the descriptions are on the plugin''s own page, not the overview (the owner, October 27, 2026)'
Assert-True ((Format-MarketplacePluginsPageHtml -Plugins @($tmEcomm)).Contains('card--link pl-card pl-card--off" id="group-dkj-subagents"')) 'the teams'' card is muted only when no team is on here'
Assert-True ((Format-MarketplacePluginsPageHtml -Plugins @()).Contains('No plugin was found') -and (Format-MarketplacePluginsPageHtml -Plugins @() -ReadError 'm.json').Contains('msg--warn')) 'none found says so, and a failed read is a warning on the page'

Write-Host '-- the specialist teams'' page, /plugins/dkj-subagents' -ForegroundColor Cyan
$tg = Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents' -SpecialistRows @($sa, $pa, $evil) -CharsPerToken 3.12
Assert-True ($tg -match '<h1>dkj-subagents</h1>' -and $tg.Contains('<a href="/plugins">Plugins</a>') -and $tg.Contains('<span aria-current="page">dkj-subagents</span>') -and $tg -notmatch 'class="lead"') 'its trail is Home > Plugins > dkj-subagents, and it opens on its cards'
Assert-True ($tg.Contains('href="/plugins/dkj-subagents/dkj-subagents-alpha"') -and $tg.Contains('card--link pl-card pl-card--off" id="plugin-dkj-subagents-ecomm"') -and $tg.IndexOf('id="plugin-dkj-subagents-alpha"') -lt $tg.IndexOf('id="plugin-dkj-subagents-ecomm"') -and $tg -notmatch 'id="plugin-dkj-policy"') 'one card per team, in order, each linking its page under the group, and nothing else'
$atA = $tg.IndexOf('<h2>Alpha</h2>'); $atE = $tg.IndexOf('<h2>Extensions</h2>')
Assert-True ($atA -ge 0 -and $atA -lt $tg.IndexOf('id="plugin-dkj-subagents-alpha"') -and $tg.IndexOf('id="plugin-dkj-subagents-alpha"') -lt $atE -and $atE -lt $tg.IndexOf('id="plugin-dkj-subagents-ecomm"')) 'the core team stands alone under an Alpha h2, the other teams under an Extensions h2 (Maikel, October 30, 2026)'
Assert-True (-not (Format-MarketplacePluginsPageHtml -Plugins @($tmEcomm) -Group 'dkj-subagents').Contains('<h2>Alpha</h2>')) 'and a section with no team is left out'
Assert-True ($tg.Contains('menu-item__label"><h3>dkj-subagents-alpha</h3><span class="menu-item__sub">core team &middot; v5.34.0 &middot; enabled here &middot; 2 specialists &middot; full read ~' + (Format-DevNumber ([Math]::Round(($sa.TotalBytes + $pa.TotalBytes) / 3.12))) + '</span>') -and $tg.Contains('off here &middot; 1 specialist &middot;')) 'a team''s card counts its specialists and sums their full read (the owner, October 28, 2026)'
Assert-True ((Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents').Contains('enabled here</span>')) 'and with no specialists read it says only what the team is'
Assert-True ($null -eq (Format-MarketplacePluginsPageHtml -Plugins @($plOn) -Group 'dkj-subagents') -and $null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Group 'other')) 'no teams, or a group that is not the teams'', is $null'

Write-Host '-- a plugin''s own page, /plugins/<name> or /plugins/dkj-subagents/<team> (the owner, October 27, 2026)' -ForegroundColor Cyan
$one = Format-MarketplacePluginsPageHtml -Plugins $market -Plugin 'dkj-policy'
Assert-True ($one -match '<h1>dkj-policy</h1>' -and $one.Contains('<a href="/plugins">Plugins</a>') -and $one.Contains('<span aria-current="page">dkj-policy</span>') -and -not $one.Contains('href="/plugins/dkj-subagents"')) 'its trail is Home > Plugins > the plugin'
Assert-True ($one -match 'name="description" content="The &lt;way&gt;\.">') 'the marketplace''s line is its description, escaped'
Assert-True ($one.Contains('<div class="grid-3" id="add-ons"><div class="grid__head"><h2>Add-ons (Optional)</h2></div>') -and $one.Contains('href="/plugins/dkj-policy/bwj-development"') -and $one.Contains('menu-item__label"><h3>bwj-development</h3>') -and $one.IndexOf('id="add-ons"') -lt $one.IndexOf('id="about"')) 'dkj-policy''s page carries its add-ons above its facts, each an h3 card linking its page under dkj-policy (Maikel, October 30, 2026)'
Assert-True ($one.IndexOf('id="assets"') -ge 0 -and $one.IndexOf('id="assets"') -lt $one.IndexOf('id="add-ons"')) 'and its house style stands above its add-ons (Maikel, October 31, 2026)'
Assert-True ($one.Contains('id="assets"><div class="grid__head"><h2>Assets (Always on)</h2></div>')) 'that section is headed Assets (Always on), and the add-ons Add-ons (Optional) (Maikel, November 1, 2026)'
Assert-True ($one.Contains('menu-item__label"><h3>dkj-brandbook</h3>') -and -not $one.Contains('>Specimens</h3>')) 'and its card is named dkj-brandbook, no longer Specimens (Maikel, October 31, 2026)'
Assert-True ($one.Contains('card--link pl-card pl-card--off" id="plugin-bwj-development"') -and $one.Contains('add-on to dkj-policy &middot; off here')) 'an add-on not enabled here keeps its card, muted, and a missing version is left out'
Assert-True (-not (Format-MarketplacePluginsPageHtml -Plugins @($plOn) -Plugin 'dkj-policy').Contains('id="add-ons"')) 'and with no add-on there is no Add-ons section'
Assert-True ($one.Contains('<dt>Kind</dt><dd>workflow</dd>') -and $one.Contains('<dt>Version</dt><dd>v5.34.0</dd>') -and $one.Contains('<dt>Here</dt><dd>enabled</dd>') -and $one.Contains('<code>./plugins/dkj-policy</code>')) 'a facts card says what it is, its version, whether it is on here and where it lives'
$team = Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents' -Plugin 'dkj-subagents-alpha'
Assert-True ($team -match '<h1>dkj-subagents-alpha</h1>' -and $team.Contains('<a href="/plugins">Plugins</a>') -and $team.Contains('<a href="/plugins/dkj-subagents">dkj-subagents</a>')) 'a team''s trail is Home > Plugins > dkj-subagents > the team'
Assert-True ($null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Plugin 'dkj-subagents-alpha') -and $null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents' -Plugin 'dkj-policy')) 'a team is reached only under its group, and no other plugin is'
Assert-True ($one.Contains('<dd>26 skills &middot; 1 hook</dd>') -and $team.Contains('<dd>15 subagents &middot; 4 personas &middot; 4 skills &middot; 1 hook</dd>')) 'it counts what the plugin holds, singular where it is one and leaving out what it has none of'
$chap = Format-MarketplacePluginsPageHtml -Plugins @(@{ Name = 'x'; Kind = 'plugin'; Source = 's'; Enabled = $true; Summary = 'Add-on team (e.g. smartwatchbanden): one. Two follows.'; Description = 'Intro. THE HOUSE STYLE: tokens <b>.' }) -Plugin 'x'
Assert-True ($chap -match 'name="description" content="Add-on team \(e\.g\. smartwatchbanden\): one\.">' -and $chap -notmatch 'Two follows') 'the lead stops at the first sentence, a lower-case abbreviation not ending it'
Assert-True ($chap.Contains('role="tooltip"><p>Intro.</p><h3>The house style</h3><p>tokens &lt;b&gt;.</p></div>') -and $chap -notmatch '<h2>Description</h2>') 'the full description is in paragraphs behind the "?", each capitals lead-in an h3, escaped, and there is no Description card (Maikel, October 31, 2026)'
$offPage = Format-MarketplacePluginsPageHtml -Plugins @($plOff) -Group 'dkj-policy' -Plugin 'bwj-development'
Assert-True ($offPage.Contains('<a href="/plugins/dkj-policy">dkj-policy</a>') -and $offPage.Contains('<span aria-current="page">bwj-development</span>')) 'an add-on''s trail is Home > Plugins > dkj-policy > the add-on'
Assert-True ($null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Plugin 'bwj-development') -and $null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-policy' -Plugin 'dkj-policy') -and $null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-policy') -and $null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-policy' -Plugin 'bwj-development' -Specialist 'x')) 'an add-on is reached only under dkj-policy, nothing else is, and dkj-policy alone is no group page'
Assert-Equal '/plugins/dkj-policy/bwj-development||' ((Resolve-MarketplaceAddOnRedirect -Plugins $market -Name 'bwj-development'), (Resolve-MarketplaceAddOnRedirect -Plugins $market -Name 'dkj-policy'), (Resolve-MarketplaceAddOnRedirect -Plugins $market -Name 'nope') -join '|') 'an add-on''s top-level address redirects under dkj-policy, and no other plugin''s does'
Assert-True ($offPage.Contains('Not enabled in this repo') -and $offPage.Contains('<dd>off</dd>') -and $offPage.Contains('<span class="note">none stated</span>') -and $offPage -notmatch 'page-info-button') 'an off plugin''s page says so, a missing version is named, and with no description and no line there is no "?"'
Assert-True ($null -eq (Format-MarketplacePluginsPageHtml -Plugins @($plOn) -Plugin 'nope')) 'a plugin the marketplace does not list is $null, so the server answers 404'

Write-Host '-- a team''s page carries its specialists (#3550, #3551; one page since the owner, October 28, 2026)' -ForegroundColor Cyan
$rows3 = @($sa, $pa, $evil)
$al = Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents' -Plugin 'dkj-subagents-alpha' -SpecialistRows $rows3 -CharsPerToken 3.12
Assert-True ($al.Contains('<dt>Kind</dt><dd>core team</dd>') -and $al.IndexOf('id="about"') -lt $al.IndexOf('id="cards"')) 'the team''s facts come first, its specialists under them'
Assert-True ($al -match '<div class="card-grid sp-grid" id="cards">\r?\n<div class="grid__head"><h2>Specialists</h2></div>') 'the specialists are a group of their own, in the house .card-grid beside their own columns so it keeps the group''s padding and surface, its heading inside it (the owner, October 28, 2026)'
Assert-True ($al.Contains('<strong><a href="/plugins/dkj-subagents/dkj-subagents-alpha/paula">Paula') -and $al.Contains('<strong><a href="/plugins/dkj-subagents/dkj-subagents-alpha/chris">Chris') -and -not $al.Contains('>Eve')) 'it lists its own specialists and nobody else''s, each name a link to its page under the team'
Assert-True ($al.IndexOf('-alpha/paula">Paula') -lt $al.IndexOf('-alpha/chris">Chris')) 'the table puts the largest full read first'
Assert-True ($al.Contains('always-on</span>')) 'the orchestrator carries the always-on badge'
Assert-True ($al.Contains('~' + (Format-DevNumber ([Math]::Round(1000 / 3.12))) + '<')) 'tokens are the bytes at the given factor'
Assert-True ($al.Contains('3.12 characters per token') -and $al.Contains('.claude-plugin/marketplace.json')) 'the footer names both sources, and the factor, so the estimate is labelled as one'
Assert-True (-not $al.Contains('Not enabled in')) 'an enabled team carries no off notice'
Assert-True ($al.Contains('id="when"') -and $al.IndexOf('</table>') -lt $al.IndexOf('id="when"')) 'the column explanation sits under the table it explains'
Assert-True ($al.Contains('id="cards"') -and $al.IndexOf('id="cards"') -lt $al.IndexOf('<table')) 'one card per specialist, above the table (#3551)'
Assert-True ($al.Contains('.sp-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr));') -and $al.Contains('.pl-card--off')) 'the specialist cards sit four to a row, in a grid of their own, beside the page''s own style'
Assert-True ($al.Contains('<section class="card card--link sp-card" id="specialist-paula">') -and $al.Contains('<a class="menu-item" href="/plugins/dkj-subagents/dkj-subagents-alpha/chris">')) 'each card is the link to that specialist''s page'
Assert-True ($al.IndexOf('id="specialist-chris"') -lt $al.IndexOf('id="specialist-paula"')) 'the cards are in roster order, 01-01 before 02-09, where the table is by size'
Assert-True ($al.Contains('<span class="menu-item__label">Paula ' + $compass + '<span class="menu-item__sub">#09 &middot; Project Planner &middot; subagent &middot; full read ~') -and $al -notmatch 'menu-item__label"><h2>') 'a card names the specialist, its number, title, form and full read, untitled under the group''s heading (#206)'
$ec = Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents' -Plugin 'dkj-subagents-ecomm' -SpecialistRows $rows3 -CharsPerToken 3.12
Assert-True ($ec.Contains('Eve &lt;i&gt;') -and -not $ec.Contains('Eve <i>')) 'a name is escaped'
Assert-True ($ec.Contains('Not enabled in') -and $ec.Contains('style="width: 100%"')) 'an off team says so, and the bar is drawn against the largest on its own page'
$bare = Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents' -Plugin 'dkj-subagents-alpha' -SpecialistReadError 'x.md'
Assert-True ($bare.Contains('No specialist was found') -and $bare.Contains('msg--warn') -and -not $bare.Contains('<table')) 'with none read it says so, a failed read is a warning, and no empty table is drawn'
Assert-True (-not $one.Contains('id="cards"') -and -not $one.Contains('characters per token')) 'a plugin that is not a team shows no specialists'

Write-Host '-- a specialist''s own page, under its team (#3551)' -ForegroundColor Cyan
Assert-Equal 'paula|eve|07-77' ($sa.Slug + '|' + $evil.Slug + '|' + (ConvertTo-SpecialistRow -Id '07-77' -Plugin 'x' -Form subagent -Text 'no shape').Slug) 'the route segment is the name lowercased, or the id where the name is not a plain word'
$sa2 = ConvertTo-SpecialistRow -Id '02-09' -Plugin 'dkj-subagents-alpha' -Form subagent -Text $agentText -ManualBytes 1000 -LensBytes $null -Enabled $true `
    -DefinitionPath 'plugins/dkj-subagents/dkj-subagents-alpha/subagents/specialist-02-09-subagent.md' -ManualPath 'm.md' -LensPath 'l.md'
Assert-Equal 'm.md|' ($sa2.ManualPath + '|' + $sa2.LensPath) 'a path is kept only for a file that exists: no lens bytes, no lens path'
$spOf = { param($rows, $team, $slug) Format-MarketplacePluginsPageHtml -Plugins $market -Group 'dkj-subagents' -Plugin $team -Specialist $slug -SpecialistRows $rows -CharsPerToken 3.12 }
$pg = & $spOf @($sa2, $pa, $evil) 'dkj-subagents-alpha' 'paula'
Assert-True ($pg -match '<h1>Paula ' + $compass + '</h1>' -and $pg.Contains('<a href="/plugins">Plugins</a>') -and $pg.Contains('<a href="/plugins/dkj-subagents">dkj-subagents</a>') -and $pg.Contains('<a href="/plugins/dkj-subagents/dkj-subagents-alpha">dkj-subagents-alpha</a>') -and $pg -notmatch 'href="/specialists') 'its trail is Home > Plugins > dkj-subagents > the team > the specialist'
Assert-True ($pg -match 'Full read</div><div class="v num">~' -and $pg -match 'Lens</div><div class="v num">--<') 'its tiles are its own parts, a missing one a dash'
Assert-True ($pg.Contains('<dt>Number</dt><dd>#09') -and $pg.Contains('<dt>Title</dt><dd>Project Planner') -and $pg.Contains('<code>dkj-subagents-alpha</code>, the core team')) 'it says what the specialist is and which plugin ships it'
Assert-True ($pg.Contains('<code>plugins/dkj-subagents/dkj-subagents-alpha/subagents/specialist-02-09-subagent.md</code>') -and $pg.Contains('<dt>Lens</dt><dd><span class="note">none</span>')) 'it names where each file is, and none where there is none'
Assert-True ($pg.Contains('<p>Project Planner -- tracks deadlines.</p>') -and $pg.Contains('<details class="more"><summary>Show the definition</summary><pre class="sp-text">You are **Paula') -and $pg.Contains('.sp-text {')) 'it shows the listing, and the definition folded'
$cp = & $spOf @($sa, $pa) 'dkj-subagents-alpha' 'chris'
Assert-True ($cp.Contains('Imported on every turn') -and $cp.Contains('A persona has none')) 'the orchestrator''s page says it is always loaded and has no listing'
$ep = & $spOf @($sa, $pa, $evil) 'dkj-subagents-ecomm' 'eve'
Assert-True ($ep.Contains('Eve &lt;i&gt;') -and -not $ep.Contains('<i>') -and $ep.Contains('&lt;b&gt;x&lt;/b&gt;') -and $ep.Contains('Its plugin is not enabled')) 'its name, listing and definition are escaped, and an off plugin says so'
Assert-True ($null -eq (& $spOf @($sa, $pa) 'dkj-subagents-alpha' 'eve') -and $null -eq (& $spOf @($sa, $pa, $evil) 'dkj-subagents-alpha' 'eve')) 'a specialist its team does not ship is $null, a 404'
Assert-True ($null -eq (Format-MarketplacePluginsPageHtml -Plugins $market -Plugin 'dkj-policy' -Specialist 'paula' -SpecialistRows @($sa)) -and $null -eq (& $spOf @($sa) 'dkj-subagents-alpha' 'PAULA')) 'and so is one under a plugin that is not a team, or one not named as written'
Write-Host '-- the DKJ repos on GitHub (#3231), a section of /consumers/dkj since #3549: what it shows' -ForegroundColor Cyan
$gql = '{"data":{"organization":{"repositories":{"nodes":[' +
    '{"name":"dkj-lifehub","nameWithOwner":"DKJ-Solutions/dkj-lifehub","url":"https://github.com/DKJ-Solutions/dkj-lifehub","description":"<b>life</b>","visibility":"PRIVATE","isArchived":false,"pushedAt":"2026-10-20T10:00:00Z","issues":{"totalCount":3},"pullRequests":{"totalCount":0}},' +
    '{"name":"old","nameWithOwner":"DKJ-Solutions/old","url":"https://github.com/DKJ-Solutions/old","description":null,"visibility":"PUBLIC","isArchived":true,"pushedAt":"2025-01-01T00:00:00Z","issues":{"totalCount":0},"pullRequests":{"totalCount":0}}]}}}}'
$q = ConvertFrom-DkjRepoQuery -Json $gql
Assert-True ($q.Repos.Count -eq 1 -and (@($q.Archived) -join ',') -eq 'DKJ-Solutions/old' -and $q.Repos[0].Issues -eq 3 -and $q.Repos[0].Visibility -eq 'private' -and -not $q.Error) 'the query answer reads into live repos, with the archived ones counted and left out'
Assert-True ((ConvertFrom-DkjRepoQuery -Json '').Error -and (ConvertFrom-DkjRepoQuery -Json 'nope').Error -and (ConvertFrom-DkjRepoQuery -Json '{"errors":[{"message":"bad"}]}').Error -match 'bad' -and (ConvertFrom-DkjRepoQuery -Json '{"data":{}}').Error) 'no answer, no JSON, an error answer or a wrong shape is an Error, never an empty organisation'
Assert-True ((Get-DkjRepoQuery) -notmatch '"') 'the query holds no double quote, which Windows PowerShell 5.1 would split on its way to gh'
$co = @(@{ Repo = 'DKJ-Solutions/dkj-lifehub'; Path = 'C:\x\dkj-lifehub'; Branch = 'main'; Dirty = 2 }, @{ Repo = 'DKJ-Solutions/unlisted'; Path = 'C:\x\unlisted'; Branch = 'dev'; Dirty = 0 })
Write-Host '-- /consumers/dkj: a card per DKJ repo, each opening its own page (October 28, 2026)' -ForegroundColor Cyan
Assert-True ((Get-DkjRepoCardStyle) -match '\.dr-repos \.menu-item__label > h2 \{ font-size' -and (Get-DkjRepoCardStyle) -notmatch '(?:^|[\r\n}])[^{}]*?(?:\bh3\b|\.dr-repos \.menu-item__label \{)[^{}]*\{[^}]*font-size') 'the DKJ cards'' smaller title reaches their h2 alone, so an h3 card keeps the house --text-h3 (Maikel, October 30, 2026)'
$cdk = @(@{ Repo = 'DKJ-Solutions/dkj-lifehub'; Status = 'bad'; Visibility = 'private'; File = 'life-hub.json'; Checkout = @('../dkj-lifehub'); Plugins = @(@{ Id = 'dkj-policy'; Extensions = @() }); Signals = @(@{ Level = 'ERROR'; Plugin = 'dkj-policy'; Text = 'behind <x>' }); Present = $true; Git = $null; Notes = '' })
$dp = Format-DkjReposPageHtml -Query $q -Checkouts $co -Consumers $cdk -Meta @{ GeneratedAt = '2026-10-20 12:00:00'; Seconds = 1.2 } -CheckMeta @{ GeneratedAt = '2026-10-20 12:00:01'; Seconds = 0.4 }
Assert-True ($dp -match '<h1>DKJ repos</h1>' -and $dp.Contains('<a href="/consumers">Consumers</a>') -and $dp.Contains('<span aria-current="page">DKJ repos</span>') -and ([regex]::Matches($dp, '<h1')).Count -eq 1) 'the DKJ page is headed DKJ repos, under Home > Consumers'
Assert-True ($dp -match '<div class="card-grid dr-repos" id="repos">' -and $dp -match '\.dr-repos \{ display: grid; grid-template-columns: repeat\(4, ' -and ([regex]::Matches($dp, '<section class="card card--link"')).Count -eq 2 -and $dp -notmatch '<table' -and $dp -notmatch 'id="issues"' -and $dp -notmatch 'mini-card') 'it is a card per repo in Admin''s card form, four to a row (October 28, 2026): no table, no Issues card and no mini-card -- those are a repo''s own page'
Assert-True ($dp.Contains('href="/consumers/dkj/dkj-lifehub"') -and $dp.Contains('menu-item__label"><h2><span>dkj-lifehub</span>') -and $dp.Contains('href="/consumers/dkj/unlisted"')) 'each card opens its repo''s page, its name an h2, and a checkout GitHub did not list keeps its card'
Assert-True ($dp.Contains('<span class="menu-item__sub"><span class="dr-clip" title="private ' + [char]0x00B7 + ' 3 issues ' + [char]0x00B7 + ' 0 PRs ' + [char]0x00B7 + ' 2026-10-20">private &middot; 3 issues &middot; 0 PRs &middot; 2026-10-20</span></span>') -and $dp.Contains('<span class="menu-item__value"><span class="dr-clip" title="main 2 uncommitted"><code>main</code> 2 uncommitted</span></span>')) 'a card''s line is its GitHub facts and its value its checkout here, each one line cut off with an ellipsis and whole in its tooltip'
$cardLinks = [regex]::Matches(([regex]::Replace($dp, '(?s)<header class="site-header">.*?</header>', '')), '<a class="menu-item"[^>]*>(.*?)</a>')   # the cards, not the header's drawer
Assert-True ($cardLinks.Count -eq 2 -and @($cardLinks | Where-Object { $_.Groups[1].Value -match '<a[ >]' }).Count -eq 0 -and $dp -notmatch 'id="repos">[^\n]*dr-link') 'no link sits inside a card''s link: an <a> in an <a> is invalid, and the browser broke the card at the first one (Maikel''s screenshot, October 28, 2026)'
Assert-True ($dp -match 'id="repo-dkj-lifehub"><nav[^\n]*menu-item__label"><h2><span>dkj-lifehub</span><span class="badge badge--sm badge--bad" title="Needs action"[^>]*>!</span></h2>' -and $dp.Contains('menu-item__label"><h2>unlisted</h2>') -and $dp -notmatch 'id="repo-unlisted"><nav[^\n]*class="badge ') 'a registered repo''s status mark sits right after its name, in the h2 (October 28, 2026); an unregistered repo has none'
Assert-True ((Format-AdminCardLinkHtml -Href '/x' -Label 'a <b>' -TitleBadgeHtml '<i>m</i>' -Heading 2).Contains('menu-item__label"><h2><span>a &lt;b&gt;</span><i>m</i></h2>') -and (Format-AdminCardLinkHtml -Href '/x' -Label 'a' -Heading 2).Contains('menu-item__label"><h2>a</h2>')) 'the card link''s -TitleBadgeHtml puts a mark after the escaped label, in a span of its own; without it the label is unchanged'
$slotRefusals = @('SubHtml', 'ValueHtml', 'BadgeHtml', 'TitleBadgeHtml') | Where-Object {
    $slotArgs = @{ Href = '/x'; Label = 'x' }; $slotArgs[$_] = 'see <a href="/y">y</a>'
    try { Format-AdminCardLinkHtml @slotArgs | Out-Null; $false } catch { $_.Exception.Message -match '#3610' }
}
Assert-True (@($slotRefusals).Count -eq 4) 'the card link refuses an <a> in each of its four markup slots, since the card is already one link (#3610)'
Assert-True ((Format-AdminCardLinkHtml -Href '/x' -Label 'x' -SubHtml '<abbr>PR</abbr> <span>2</span>') -match '<abbr>PR</abbr>') 'and an element whose name merely starts with a, such as <abbr>, passes'
Assert-True ($dp -match '1 archived repo is left out' -and $dp -notmatch '/consumers/dkj/old"' -and $dp -notmatch 'data-copy=') 'an archived repo is counted, not listed, and no session command is on this page'
Assert-True ($dp -match 'href="/refresh\?page=consumers/dkj"' -and $dp -match 'gh api graphql</code> call[^<]*2026-10-20 12:00:00 in 1\.2s\. The status is read from <code>check-consumers\.ps1</code>, checked 2026-10-20 12:00:01 in 0\.4s\.') 'its footer names both reads and comes back to /consumers/dkj'
$dpArch = Format-DkjReposPageHtml -Query $q -Checkouts @(@{ Repo = 'DKJ-Solutions/old'; Path = 'C:\x\old'; Branch = 'main'; Dirty = 0 }) -Meta @{ GeneratedAt = 'x' }
Assert-True ($dpArch.Contains('href="/consumers/dkj/old"') -and $dpArch -match 'menu-item__sub"><span class="dr-clip"[^>]*>archived &middot; ' -and $dpArch -notmatch 'archived repo is left out') 'an archived repo checked out here is listed, marked archived, and not counted as left out'
$evil = @{ Repos = @(@{ Repo = 'DKJ-Solutions/x'; Name = 'x'; Url = 'javascript:alert(1)'; Description = '<b>d</b>'; Visibility = 'public'; PushedAt = ''; Issues = 1; Pulls = 0 }); Archived = @(); Error = '' }
Assert-True ((Format-DkjReposPageHtml -Query $evil -Checkouts @() -Meta @{ GeneratedAt = 'x' }) -notmatch 'javascript:') 'a link is built from owner/name, never from the url field'
$dpErr = Format-DkjReposPageHtml -Query (ConvertFrom-DkjRepoQuery -Json '') -Checkouts $co -Meta @{ GeneratedAt = 'x'; Seconds = $null } -CheckMeta @{ CheckFailed = 'boom <b>' }
Assert-True ($dpErr -match 'GitHub could not be read' -and $dpErr -match 'check-consumers\.ps1 could not be run: boom &lt;b&gt;' -and $dpErr.Contains('href="/consumers/dkj/dkj-lifehub"') -and $dpErr.IndexOf('msg--warn') -lt $dpErr.IndexOf('id="repos"')) 'when GitHub or the check cannot be read the page says so above the cards, and still lists the checkouts'
Assert-True ((Format-DkjReposPageHtml -Query @{ Repos = @(); Archived = @(); Error = '' } -Checkouts @() -Meta @{ GeneratedAt = 'x' }) -match 'No DKJ-Solutions repo was found') 'no repo at all says so'
$houseCss = [IO.File]::ReadAllText((Join-Path $RepoRoot 'plugins\dkj-policy\assets\dkj-brandbook\house-style.css'))
Assert-True ($houseCss.Contains('.card--link .menu-item__label { overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }') -and $houseCss.Contains('.card--link .menu-item__label > :is(h2, h3) { display: block; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; }') -and $houseCss.Contains('.card--link .menu-item__label > :is(h2, h3) > span:first-child { min-width: 0; overflow: hidden; text-overflow: ellipsis; }') -and $houseCss.Contains('.card--link .menu-item__label > :is(.menu-item__sub, .menu-item__value) { white-space: normal; }')) 'every card''s title is one line, cut off where it does not fit, a mark after it kept, its description still wrapping -- in the house style, not per page (owner, October 28, 2026)'Write-Host '-- a DKJ repo''s own page, /consumers/dkj/<name>: Repo, Consumer and Lenses (October 28, 2026)' -ForegroundColor Cyan
$set = Get-DkjRepoRows -Query $q -Checkouts $co
Assert-True ($set.Rows.Count -eq 2 -and $set.Rows[1].Name -eq 'unlisted' -and $set.ByRepo['DKJ-Solutions/dkj-lifehub'].Path -eq 'C:\x\dkj-lifehub') 'the repo rows are GitHub''s, then each checkout GitHub did not list, with each checkout by its repo'
$lc = Format-RepoLensesCardHtml -Lenses @(@{ Id = '05-05'; Bytes = 2048; Filled = $true; Marked = $false }) -Names @{ '05-05' = 'Derek' }
$rp = Format-DkjRepoPageHtml -Row $set.Rows[0] -Checkout $set.ByRepo['DKJ-Solutions/dkj-lifehub'] -Consumer $cdk[0] -LensesHtml $lc.Html -LensesStyle $lc.Style -Meta @{ GeneratedAt = '2026-10-28 10:00:00'; Seconds = 0.5 }
Assert-True ($rp.Contains('<h1>dkj-lifehub</h1>') -and $rp.Contains('<a href="/consumers">Consumers</a>') -and $rp.Contains('<a href="/consumers/dkj">DKJ repos</a>') -and $rp.Contains('<span aria-current="page">dkj-lifehub</span>')) 'a repo''s page is headed by its name, under Home > Consumers > DKJ repos'
Assert-True ($rp -match '<section class="card dr-card">\s*<div class="card__head"><h2>GitHub</h2></div>\s*<dl class="facts dr-facts">' -and $rp -match '<div class="card__head"><h2>This machine</h2></div>' -and $rp -notmatch 'dr-desc' -and $rp -notmatch '&lt;b&gt;life' -and $rp -notmatch '<b>life</b>' -and $rp -notmatch '<h2>Repo</h2>' -and $rp -notmatch 'dr-card grid__full' -and $rp.Contains('<div><dt>GitHub</dt><dd><a class="dr-link" href="https://github.com/DKJ-Solutions/dkj-lifehub">DKJ-Solutions/dkj-lifehub</a></dd></div>')) 'each card is titled with its own h2, with no group head and no description above the facts, and the GitHub card links GitHub (October 28, 2026)'
$lcCard = Format-DkjRepoCardHtml -Row $set.Rows[0] -Checkout $null -Consumer @{ Status = $cdk[0].Status; Plugins = @(); Signals = @(); Present = $true; File = 'x.json'; Git = @{ Trunk = 'main'; When = '4 minutes ago'; Subject = 'fold: <x> (#1)' } }
Assert-True ($lcCard.Contains('<div><dt>Last commit on main</dt><dd title="4 minutes ago &middot; fold: &lt;x&gt; (#1)">4 minutes ago &middot; fold: &lt;x&gt; (#1)</dd></div>') -and $lcCard -notmatch 'facts__detail') 'the last commit is ONE line, its age then its subject after a dot, escaped, whole on hover -- never a second line under it'
Assert-True ($rp.Contains('.dr-facts dd { min-width: 0; overflow: hidden; text-overflow: ellipsis; }') -and $rp.Contains('.dr-facts dt { flex: none; white-space: nowrap; }') -and $rp -notmatch 'white-space: normal; overflow-wrap') 'every fact stays one line: the label keeps its width, the value is cut off with an ellipsis'
Assert-True ($rp.Contains('data-copy="Set-Location -LiteralPath &#39;C:\x\dkj-lifehub&#39;; claude"') -and $rp -match 'execCommand\("copy"\)' -and $rp.Contains('<div><dt>Checkout</dt><dd><code>main</code> &middot; 2 uncommitted</dd></div>')) 'it names its checkout state and holds its session to copy, with the fallback the Simple Browser needs'
Assert-True ($rp.Contains('<dl class="facts dr-facts">') -and $rp -notmatch 'class="dr-line' -and $rp.Contains('<div><dt>Status</dt><dd><span class="cd-status"><span class="badge badge--sm badge--bad" aria-hidden="true">!</span>Needs action</span></dd></div>') -and $rp.Contains('<div><dt>Open issues</dt><dd><a class="dr-link" href="https://github.com/DKJ-Solutions/dkj-lifehub/issues">3</a></dd></div>') -and $rp.Contains('<div><dt>Open PRs</dt><dd>0</dd></div>')) 'the card is the house facts list, a label and a value a line -- not loose lines in as many styles (October 28, 2026)'
Assert-True ($rp.Contains('<div><dt>Plugins</dt><dd title="dkj-policy">dkj-policy</dd></div>') -and $rp.Contains('<div><dt>Checks</dt><dd>1 finding, listed below</dd></div>') -and $rp.Contains('<div><dt>Register</dt><dd><code>consumers/life-hub.json</code></dd></div>') -and $rp -match '</dl>\s*<ul class="cd-signals">\s*<li>[^\n]*<code>dkj-policy</code> behind &lt;x&gt;') 'a plugin is named without its marketplace, the checks are counted, and a finding is listed under the list, escaped'
$iRepo = $rp.IndexOf('id="repo"'); $iLens = $rp.IndexOf('<h2>Lenses</h2>')
$repoGroup = if ($iRepo -ge 0 -and $iLens -gt $iRepo) { $rp.Substring($iRepo, $iLens - $iRepo) } else { '' }
$iGh = $repoGroup.IndexOf('>GitHub</h2>'); $iMe = $repoGroup.IndexOf('>This machine</h2>')
$ghCard = if ($iGh -ge 0 -and $iMe -gt $iGh) { $repoGroup.Substring($iGh, $iMe - $iGh) } else { '' }
$meCard = if ($iMe -ge 0) { $repoGroup.Substring($iMe) } else { '' }
Assert-True ($repoGroup -and ([regex]::Matches($repoGroup, 'class="card[ "]')).Count -eq 2 -and $ghCard -and $meCard -and $repoGroup -notmatch 'mini-card' -and $rp -notmatch 'id="consumer"' -and $rp -notmatch 'dr-pair' -and $rp -notmatch '@dkj') 'the repo is TWO cards, GitHub then This machine (October 28, 2026) -- no card inside either, no marketplace suffix'
Assert-True ($ghCard -match '<dt>Open issues</dt>' -and $ghCard -match '<dt>Last push</dt>' -and $ghCard -notmatch '<dt>(Status|Checkout|Plugins|Checks|Register)</dt>' -and $meCard -match '<dt>Status</dt>' -and $meCard -match '<dt>Register</dt>' -and $meCard -match 'cd-signals' -and $meCard -match 'data-copy=' -and $meCard -notmatch '<dt>(Visibility|Open issues|Open PRs|Last push|GitHub)</dt>') 'GitHub''s facts sit on the GitHub card; the register check, the checkout, the findings and the session on This machine'
Assert-True ($rp.Contains('.dr-card { min-width: 0; }')) 'a Repo card may shrink below its one-line description and session, so the two side by side never scroll the page sideways'
Assert-True ($rp -match '\.dr-facts dd \{' -and $rp -match '\.cd-lenses \{' -and $rp -match '\.cd-signals \{' -and $rp.Contains('href="/refresh?page=consumers/dkj/dkj-lifehub"')) 'Repo, then Lenses, all styled, its footer reading the page again'
$rpUn = Format-DkjRepoPageHtml -Row $set.Rows[1] -Checkout $null -Consumer $null -Meta @{ GeneratedAt = 'x' }
Assert-True ($rpUn.Contains('<span class="badge badge--sm badge--neutral" aria-hidden="true">-</span>Not registered</span>') -and $rpUn.Contains('<div><dt>Register</dt><dd>Not under <code>consumers/</code>, so not checked</dd></div>') -and $rpUn.Contains('<div><dt>Checkout</dt><dd>Not checked out here</dd></div>') -and $rpUn -notmatch 'data-copy=' -and $rpUn -notmatch '<dt>Checks</dt>') 'a repo not registered says so, and one not checked out here has no session'
Write-Host '-- the Plugins page (#3482): plugin-versions -Json read into a model, and the page it draws' -ForegroundColor Cyan
. (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib\plugins-page-lib.ps1')
Assert-True ((Get-AdminIconSvg -Name 'plugins') -match '<svg') 'the Installed plugins card has an icon'
Assert-Equal 3 (@('plugins', 'marketplace', 'consumers' | ForEach-Object { Get-AdminIconSvg -Name $_ } | Where-Object { $_ } | Select-Object -Unique).Count) 'Installed plugins, Marketplace and Consumers each draw an icon of their own, so the three cards that once shared one plug read apart'
$pvJson = '{"Root":"C:\r","Consulted":"user and repo","Plugins":[' +
    '{"Id":"zeta@m","Name":"zeta","Marketplace":"m","InstVersion":"1.0.0","InstScope":"project","Code":"match","Verdict":"up to date","Action":"the clone advances only on: x","Description":"<i>z</i>"},' +
    '{"Id":"alpha@m","Name":"alpha","Marketplace":"m","InstVersion":"0.9.0","InstScope":"project","Code":"behind","Verdict":"the clone is <b>ahead</b>","Action":"claude plugin update alpha@m --scope project"},' +
    '{"Id":"beta@m","Name":"beta","Marketplace":"m","InstVersion":"1.0.0","Code":"match","InstallPathMissing":true,"Verdict":"up to date"},' +
    '{"Id":"gamma@m","Name":"gamma","Marketplace":"m","Code":"clone-behind","Verdict":"the clone is stale"}],' +
    '"Clones":[{"Marketplace":"m","Exists":true,"Head":"0123456789abcdef","HeadDate":"2026-10-25"}]}'
$pv = ConvertFrom-PluginVersionsJson -Text ("noise`n" + $pvJson)
Assert-True (-not $pv.Error -and $pv.Plugins.Count -eq 4 -and $pv.Clones.Count -eq 1 -and $pv.Consulted -eq 'user and repo') 'the last JSON line is the model, a stray line before it is harmless'
Assert-True ((ConvertFrom-PluginVersionsJson -Text '').Error -and (ConvertFrom-PluginVersionsJson -Text '{nope').Error -and (ConvertFrom-PluginVersionsJson -Text '').Plugins.Count -eq 0) 'no output or broken JSON is an Error and no plugins, never a throw'
Assert-Equal 'ok,ok,ok,error,error,warn,warn,warn' ((@('match', 'ver-match', 'unreleased', 'behind', 'not-installed', 'clone-behind', 'retired', 'indeterminate') | ForEach-Object { (Get-PluginRowStatus -Code $_).Level }) -join ',') 'each plugin-versions code is fine, an error or a warning'
Assert-Equal 'error' (Get-PluginRowStatus -Code 'match' -InstallPathMissing $true).Level 'an install folder gone from disk is an error whatever the version says'
$pp = Format-PluginsPageHtml -Model $pv -RepoName 'r'
Assert-True ($pp -match '<span aria-current="page">Installed plugins</span>' -and $pp -match '<h1>Installed plugins</h1>') 'the overview opens with the breadcrumb bar and its own h1'
Assert-Equal 4 ([regex]::Matches($pp, '<tr><td class="col-start"><a href="/dev/plugins/[a-z-]+">[a-z-]+</a> <span class="badge badge--sm badge--(good|warn|bad)" aria-hidden="true">(&#10003;|!|&#10007;)</span></td><td class="col-start">(Up to date|Behind|Install folder missing|Clone behind): ')).Count 'a row per plugin: its state as a decorative mark in the round badge beside its name, its name the one link, and the state in words in the second column (the owner, October 25, 2026)'
$ppMcp = Format-PluginsPageHtml -Model (ConvertFrom-PluginVersionsJson -Text '{"Consulted":"c","Plugins":[{"Id":"figma@claude-plugins-official","Name":"figma","Marketplace":"claude-plugins-official","Code":"match"},{"Id":"dkj-policy@dkj-marketplace","Name":"dkj-policy","Marketplace":"dkj-marketplace","Code":"match"}],"Clones":[]}')
Assert-True ($ppMcp.Contains('<h2>dkj-marketplace</h2>') -and $ppMcp.Contains('<h2>MCP</h2>') -and $ppMcp.IndexOf('<h2>dkj-marketplace</h2>') -lt $ppMcp.IndexOf('/dev/plugins/dkj-policy"') -and $ppMcp.IndexOf('/dev/plugins/dkj-policy"') -lt $ppMcp.IndexOf('<h2>MCP</h2>') -and $ppMcp.IndexOf('<h2>MCP</h2>') -lt $ppMcp.IndexOf('/dev/plugins/figma"')) 'the dkj-marketplace plugins sit under an h2 of that name, every other marketplace''s under MCP (the owner, October 30, 2026)'
Assert-True ($pp.Contains('<h2>MCP</h2>') -and -not $pp.Contains('<h2>dkj-marketplace</h2>')) 'a section with no card is not drawn'
Assert-True ($pp -notmatch 'class="tiles"' -and ([regex]::Matches($pp, '<table')).Count -eq 1 -and $pp -notmatch 'id="problems"' -and -not $pp.Contains('claude plugin update')) 'the overview stays compact: no tiles, no table but the one dense list of plugins, no problems block, no command -- those are on the plugin''s page'
Assert-True ($pp.IndexOf('/dev/plugins/alpha"') -lt $pp.IndexOf('/dev/plugins/beta"') -and $pp.IndexOf('/dev/plugins/beta"') -lt $pp.IndexOf('/dev/plugins/gamma"') -and $pp.IndexOf('/dev/plugins/gamma"') -lt $pp.IndexOf('/dev/plugins/zeta"')) 'errors first, then warnings, then the rest, each by name'
Assert-True ($pp.Contains('no longer on disk') -and $pp.Contains('Up to date: 1.0.0, project scope')) 'a card says what is wrong or which version is installed'
Assert-True ($pp.Contains('the clone is &lt;b&gt;ahead&lt;/b&gt;') -and $pp -notmatch '<b>ahead') 'every value from the script is escaped'
$ppOk = Format-PluginsPageHtml -Model (ConvertFrom-PluginVersionsJson -Text '{"Consulted":"c","Plugins":[{"Id":"a@m","Name":"a","Marketplace":"m","Code":"match"}],"Clones":[]}')
Assert-True ($ppOk.Replace((Format-FitAlarmHtml), '').Substring($ppOk.IndexOf('<main')) -notmatch '<p(?: role="[a-z]+")?>|class="msg--' -and $ppOk -notmatch 'class="lead"' -and $ppOk -match 'table--dense') 'the overview is its table alone: no status line and no lead (the owner, October 25, 2026)'
Assert-True ((Format-PluginsPageHtml -Model (ConvertFrom-PluginVersionsJson -Text '{"Consulted":"c","Plugins":[],"Clones":[]}')) -match 'No plugin is enabled') 'no enabled plugin says so'
$ppErr = Format-PluginsPageHtml -Model (ConvertFrom-PluginVersionsJson -Text '') -ReadError 'it <broke>'
Assert-True ($ppErr -match 'msg--warn' -and $ppErr.Contains('it &lt;broke&gt;') -and $ppErr -notmatch 'card--link') 'a failed read is an escaped warning, with no cards'
Assert-True ((Read-PluginsPageModel -Script (Join-Path $RepoRoot 'no-such.ps1') -RepoRoot $RepoRoot).Error -match 'not found') 'a missing script is a sentence, not a throw'
Assert-True ((Format-PluginsPageHtml -Model $pv -AdminHref '/') -match 'href="/"') 'an admin that serves the page itself points Home at its own root'
Write-Host '-- one plugin''s page (#3482): /plugins/<name>' -ForegroundColor Cyan
Assert-Equal '' (Resolve-PluginsPageRequest -Path '/dev/plugins').Name 'the overview is /plugins'
Assert-Equal 'dkj-policy' (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy').Name 'a plugin''s page is /plugins/<name>'
Assert-True ($null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/../x') -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/A') -and $null -eq (Resolve-PluginsPageRequest -Path '/pluginsx')) 'anything that is not a plugin slug is no Plugins page'
Assert-True ($null -eq (Find-PluginsPageRow -Model $pv -Name 'nope') -and (Find-PluginsPageRow -Model $pv -Name 'alpha').Status.Level -eq 'error') 'a name is found among the enabled plugins, with its state, or not at all'
$one = Format-PluginPageHtml -Row (Find-PluginsPageRow -Model $pv -Name 'alpha') -Model $pv -RepoName 'r'
Assert-True ($one -match '<a href="/">Home</a>' -and $one -match '<a href="/dev/plugins">Installed plugins</a>' -and $one -match '<span aria-current="page">alpha</span>' -and $one -match '<h1>alpha</h1>') 'its crumbs read Home > Installed plugins > the plugin'
Assert-True ($one.Contains('<code>claude plugin update alpha@m --scope project</code>') -and $one.Contains('the clone is &lt;b&gt;ahead&lt;/b&gt;') -and $one -match 'msg--warn') 'a problem is named, escaped, with the command that closes it'
$zeta = Format-PluginPageHtml -Row (Find-PluginsPageRow -Model $pv -Name 'zeta') -Model $pv
Assert-True ($zeta.Contains('&lt;i&gt;z&lt;/i&gt;') -and $zeta -notmatch 'role="status"' -and $zeta -notmatch 'To close it' -and $zeta -match 'committed 2026-10-25') 'a healthy plugin shows its description and the clone, and no verdict line or command'
$beta = Format-PluginPageHtml -Row (Find-PluginsPageRow -Model $pv -Name 'beta') -Model $pv
Assert-True ($beta.Contains('no longer on disk') -and $beta -notmatch 'To close it') 'a missing install folder says to reinstall, with no update command'
Write-Host '-- the brand book under the plugin whose files it documents (#3493, #3629, #3704): /plugins/dkj-policy/dkj-brandbook' -ForegroundColor Cyan
$hsReq = Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/dkj-brandbook'
Assert-True ($hsReq.Name -eq 'dkj-policy' -and $hsReq.Page -eq 'dkj-brandbook' -and -not $hsReq.Redirect -and (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy').Page -eq '') 'the specimens are a page below the dkj-policy plugin''s own, so every repo running Admin reaches them (#3629)'
Assert-True ($null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-subagents-alpha/house-style') -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-solutions/dkj-brandbook') -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/other')) 'and no other plugin, and no other page below it, is a route'
Assert-Equal '/dev/plugins/dkj-policy/dkj-brandbook' (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-solutions/house-style').Redirect 'the old address under dkj-solutions redirects to the new one, so a link to it still lands (#3629)'
Assert-Equal '/dev/plugins/dkj-policy/dkj-brandbook' (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/house-style').Redirect 'and so does the house-style address under dkj-policy, now the page has the brand book''s name (#3704)'
Assert-Equal '/dev/plugins/dkj-policy/dkj-brandbook/tokens' (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-solutions/house-style/tokens/').Redirect 'and an old section''s address redirects to that same section'
Assert-Equal '/dev/plugins/dkj-policy/dkj-brandbook/tokens' (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/house-style/tokens').Redirect 'under either old address'
Assert-True ($null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-solutions/house-style/A') -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/house-style/a/b')) 'an old address that was never a page is no redirect either'
Assert-True ($zeta -notmatch 'href="/dev/plugins/dkj-policy/dkj-brandbook"' -and $zeta -notmatch 'class="grid-3"|class="admin-list"') 'a plugin that ships no house style links none, and with no pages below it there is no table'
$zc = Format-PluginPageHtml -Row (Find-PluginsPageRow -Model $pv -Name 'zeta') -Model $pv -Cards @(@{ Href = '/dev/plugins/zeta/x'; Label = 'X <y>'; Sub = 's'; Icon = 'specialists' })
Assert-True ($zc -match '<section class="admin-list"><table class="table table--dense">' -and $zc -match '<a href="/dev/plugins/zeta/x">X &lt;y&gt;</a>' -and $zc -notmatch 'class="grid-3"|card--link') 'an admin''s own page below a plugin is a row on that plugin''s page, its label escaped'
$dsRow = (Find-PluginsPageRow -Model $pv -Name 'zeta').Clone(); $dsRow.Name = 'dkj-policy'
$ds = Format-PluginPageHtml -Row $dsRow -Model $pv -RepoName 'r'
Assert-True ($ds -match '<tr><td class="col-start"><a href="/dev/plugins/dkj-policy/dkj-brandbook">dkj-brandbook</a></td>') 'the dkj-policy page links its brand book as a row named dkj-brandbook, as the product''s card is (#3704)'
$dsOld = (Find-PluginsPageRow -Model $pv -Name 'zeta').Clone(); $dsOld.Name = 'dkj-solutions'
Assert-True ((Format-PluginPageHtml -Row $dsOld -Model $pv) -notmatch '(house-style|dkj-brandbook)"') 'and the dkj-solutions page no longer does: the rule stays there, the specimens moved (#3629)'
Write-Host '-- what a plugin ships (Dave, November 3, 2026): Specialists, Hooks and Skills, each item a card and a landing page' -ForegroundColor Cyan
$pcRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('pc-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
try {
    $pcU = New-Object System.Text.UTF8Encoding($false); $dash = [string][char]0x2014; $emo = [char]::ConvertFromUtf32(0x1F9D0)
    $pcW = { param($rel, $txt) $p = Join-Path $pcRoot $rel; [void](New-Item -ItemType Directory -Force -Path (Split-Path $p -Parent)); [System.IO.File]::WriteAllText($p, $txt, $pcU) }
    & $pcW '.claude-plugin\marketplace.json' '{"name":"m","plugins":[{"name":"zeta","source":"./plugins/zeta"},{"name":"beta","source":"../out"}]}'
    & $pcW 'plugins\zeta\subagents\specialist-06-19-subagent.md' "---`nname: victor`ndescription: >`n  Code Reviewer <b>x</b> --`n  the final look.`ntools: Read, Grep`nmodel: sonnet`n---`n`nYou are Victor.`n"
    & $pcW 'plugins\zeta\manuals\specialist-06-19-manual.md' "---`nid: 19`n---`n`n# Victor $emo $dash the Code Reviewer (*Code Reviewer Victor*)`n`n> A note.`n`nVictor reviews.`n`n## What Victor covers`n`n- a`n"
    & $pcW 'plugins\zeta\personas\specialist-05-05-persona.md' "---`nid: 05`n---`n`n# Derek $dash the DevOps Engineer`n`n> Part of it.`n`nDerek knows Git.`n"
    & $pcW 'plugins\zeta\skills\do-it\SKILL.md' "---`nname: do-it`ndescription: >-`n  Does it.`n---`n`n# Do it`n`nBody.`n"
    & $pcW 'plugins\zeta\skills\Bad Name\SKILL.md' "---`nname: bad`n---`n"
    & $pcW 'plugins\zeta\hooks\hooks.json' '{"hooks":{"SessionStart":[{"matcher":"startup","hooks":[{"type":"command","command":"powershell -File \"${CLAUDE_PLUGIN_ROOT}/hooks/check-a.ps1\"","timeout":30,"statusMessage":"checking"}]}],"Stop":[{"hooks":[{"type":"command","command":"powershell -File \"${CLAUDE_PLUGIN_ROOT}/hooks/check-a.ps1\""}]}]}}'
    & $pcW 'plugins\zeta\hooks\check-a.ps1' "<#`n.SYNOPSIS`n    Checks a.`n`n.DESCRIPTION`n    First para`n    wraps.`n`n    - one`n    - two`n#>`n"
    & $pcW '.claude\specialists\lenses\specialist-06-19-lens.md' "# Victor`n"
    $pcModel = @{ Plugins = @(); Clones = @(@{ Marketplace = 'm'; Dir = (Join-Path $pcRoot 'nowhere') }) }
    $pcRow = @{ Name = 'zeta'; Marketplace = 'm' }
    $pcDir = Resolve-PluginPayloadDir -Row $pcRow -Model $pcModel -RepoRoot $pcRoot
    Assert-Equal (Join-Path $pcRoot 'plugins\zeta') $pcDir 'the repo that is the marketplace finds the plugin by its entry''s relative source'
    Assert-True ('' -eq (Resolve-PluginPayloadDir -Row @{ Name = 'beta'; Marketplace = 'm' } -Model $pcModel -RepoRoot $pcRoot) -and '' -eq (Resolve-PluginPayloadDir -Row @{ Name = 'zeta'; Marketplace = 'other' } -Model $pcModel -RepoRoot $pcRoot)) 'a source that climbs out of the root, or another marketplace, finds nothing'
    $pcC = Get-PluginContents -Dir $pcDir
    Assert-Equal 'derek,victor' ((@($pcC.Specialists) | ForEach-Object { $_.Slug }) -join ',') 'a specialist per id under subagents, personas and manuals, in id order, its slug its name'
    $vic = $pcC.Specialists[1]
    Assert-True ($vic.Name -eq 'Victor' -and $vic.Emoji -eq $emo -and $vic.Title -eq 'Code Reviewer' -and $vic.Kind -eq 'subagent' -and $vic.Model -eq 'sonnet' -and $vic.Description -eq 'Code Reviewer <b>x</b> -- the final look.' -and $vic.DocLabel -eq 'manuals/specialist-06-19-manual.md') 'name, emoji and title from the heading, the rest from the subagent''s frontmatter, the manual its document'
    Assert-True ($pcC.Specialists[0].Kind -eq 'persona' -and $pcC.Specialists[0].Description -eq 'Derek knows Git.' -and $pcC.Specialists[0].Title -eq 'DevOps Engineer') 'a persona with no manual is described by its own opening paragraph'
    Assert-Equal 'do-it' ((@($pcC.Skills) | ForEach-Object { $_.Slug }) -join ',') 'a skill per folder with a SKILL.md whose name is a slug'
    Assert-True ($pcC.Hooks.Count -eq 1 -and $pcC.Hooks[0].Slug -eq 'check-a' -and $pcC.Hooks[0].Runs.Count -eq 2 -and $pcC.Hooks[0].Synopsis -eq 'Checks a.') 'a hook per script, whatever events run it, with its synopsis'
    $pcPage = Format-PluginPageHtml -Row (Find-PluginsPageRow -Model $pv -Name 'zeta') -Model $pv -Contents $pcC
    Assert-True ($pcPage.IndexOf('<h2>Specialists</h2>') -lt $pcPage.IndexOf('<h2>Hooks</h2>') -and $pcPage.IndexOf('<h2>Hooks</h2>') -lt $pcPage.IndexOf('<h2>Skills</h2>') -and $pcPage.Contains('href="/dev/plugins/zeta/specialists/victor"') -and $pcPage.Contains('href="/dev/plugins/zeta/hooks/check-a"') -and $pcPage.Contains('href="/dev/plugins/zeta/skills/do-it"') -and $pcPage -match '<a href="/dev/plugins/zeta/specialists/victor">Victor ' -and $pcPage -notmatch '<h3>|card--link' -and $pcPage.IndexOf('<h2>Skills</h2>') -lt $pcPage.IndexOf('id="facts"')) 'Specialists, Hooks and Skills, each an h2 over a table with a row per item opening its landing page, at the top of the page (Dave, November 3, 2026)'
    Assert-True ((Format-PluginPageHtml -Row (Find-PluginsPageRow -Model $pv -Name 'zeta') -Model $pv -Contents @{ Specialists = @(); Skills = @(); Hooks = @() }) -notmatch '<h2>(Specialists|Hooks|Skills)</h2>') 'a kind the plugin ships none of is not drawn'
    $req = Resolve-PluginsPageRequest -Path '/dev/plugins/zeta/specialists/victor'
    Assert-True ($req.Name -eq 'zeta' -and $req.Page -eq 'specialists' -and $req.Section -eq 'victor' -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/zeta/agents/victor') -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/zeta/skills/A')) 'an item''s page is /plugins/<plugin>/<specialists|skills|hooks>/<slug>, and nothing else is'
    $vp = Format-PluginItemPageHtml -Row $pcRow -Contents $pcC -Kind specialists -Slug victor -RepoRoot $pcRoot
    Assert-True ($vp -match '<a href="/dev/plugins/zeta">zeta</a>' -and $vp.Contains('<h2>Code Reviewer</h2>') -and $vp.Contains('&lt;b&gt;x&lt;/b&gt;') -and $vp.Contains('href="/dev/claude/specialists/lenses/specialist-06-19-lens"') -and $vp.Contains('<h2>Manual</h2>') -and $vp -match 'id="doc-md"') 'a specialist''s page: its title over what they do, escaped, the facts with its lens, and its manual rendered'
    Assert-True ((Format-PluginItemPageHtml -Row $pcRow -Contents $pcC -Kind specialists -Slug derek) -notmatch 'lenses/specialist-05-05') 'no lens link where the checkout has no lens'
    $hp = Format-PluginItemPageHtml -Row $pcRow -Contents $pcC -Kind hooks -Slug check-a
    Assert-True ($hp.Contains('<p>First para wraps.</p>') -and $hp.Contains('<li>one</li>') -and $hp.Contains('SessionStart <code>startup</code>, timeout 30 s') -and ([regex]::Matches($hp, '<dt>Runs on</dt>')).Count -eq 2) 'a hook''s page: its synopsis, every event that runs it, and its description as paragraphs and a list'
    Assert-True ((Format-PluginItemPageHtml -Row $pcRow -Contents $pcC -Kind skills -Slug do-it).Contains('<code>/zeta:do-it</code>') -and $null -eq (Format-PluginItemPageHtml -Row $pcRow -Contents $pcC -Kind skills -Slug nope)) 'a skill''s page says how it is invoked; a slug the plugin has none of is no page'
    Assert-Equal 0 (Get-PluginContents -Dir (Join-Path $pcRoot 'gone')).Specialists.Count 'a folder that is not there ships nothing'
} finally { Remove-Item -LiteralPath $pcRoot -Recurse -Force -ErrorAction SilentlyContinue }
$hsFix = "<style>.spec-x {}</style>`n<div class=`"spec-page`">`n`n<div class=`"grid-2`">`n  <div class=`"grid__head`"><h2 id=`"hs-alpha`">Alpha &amp; one</h2><p class=`"card__sub`">The <code>first</code> line</p></div>`n  <section class=`"card`" id=`"specimen-a1`"></section>`n  <section class=`"card grid__full`" id=`"specimen-a2`"></section>`n</div>`n`n" +
    "<div class=`"grid-3`">`n  <div class=`"grid__head`"><h2 id=`"hs-beta`">Beta</h2><p class=`"card__sub`">Second</p></div>`n  <section class=`"card`" id=`"specimen-b1`"></section>`n</div>`n`n</div>`n<dialog id=`"hs-modal`"></dialog>`n<script>/* s */</script>`n"
$hsSplit = Split-HouseStyleSpecimens -Body $hsFix
Assert-Equal 'alpha,beta' ((@($hsSplit.Sections) | ForEach-Object { $_.Slug }) -join ',') 'the specimens are cut at each column-0 grid opening on a grid__head h2, its slug the id without hs-'
Assert-True ($hsSplit.Sections[0].Cards -eq 2 -and $hsSplit.Sections[1].Cards -eq 1 -and $hsSplit.Sections[1].Grid -eq 'grid-3' -and $hsSplit.Head -match 'spec-x' -and $hsSplit.Tail -match '^<dialog' -and $hsSplit.Tail -match '<script>') 'each section counts its cards and keeps its grid; the style block before the page and the dialogs and script after it are kept apart'
$hs = Format-HouseStyleSpecimensPageHtml -Body $hsFix -RepoName 'r'
Assert-True ($hs -match '<a href="/dev/plugins">Installed plugins</a>' -and $hs -match '<a href="/dev/plugins/dkj-policy">dkj-policy</a>' -and $hs -match '<span aria-current="page">dkj-brandbook</span>' -and $hs -match 'href="/house-style.css"') 'the specimens overview sits under Installed plugins and dkj-policy, on the house stylesheet the server serves'
Assert-True ($hs.Contains('<tr><td class="col-start"><a href="/dev/plugins/dkj-policy/dkj-brandbook/alpha">Alpha &amp; one</a></td><td class="col-start">2 specimens</td></tr>') -and $hs -match '<td class="col-start">1 specimen</td>' -and $hs -notmatch 'card--link') 'the overview is one dense table (Format-AdminLinkTableHtml), a row per section linking its own page, its one line how many specimens it holds (#3563; Admin''s form, #3830)'
Assert-True ($hs -notmatch '<h3' -and $hs -notmatch 'card__title') 'and no hand-written card: no heading link inside a card'
Assert-True ($hs -notmatch 'id="specimen-a1"' -and ([regex]::Replace($hs, '(?s)<header class="site-header">.*?</header>', '')) -notmatch '<dialog' -and $hs -notmatch 'spec-x') 'and none of the specimens themselves'
$hsA = Format-HouseStyleSpecimensPageHtml -Body $hsFix -RepoName 'r' -Section 'alpha'
Assert-True ($hsA -match '<a href="/dev/plugins/dkj-policy/dkj-brandbook">dkj-brandbook</a>' -and $hsA -match '<span aria-current="page">Alpha &amp; one</span>' -and $hsA -match '<h1>Alpha &amp; one</h1>' -and $hsA -match '<meta name="description" content="The first line">' -and $hsA -notmatch 'class="lead"') 'a section''s page sits one crumb below the overview, its h1 the section''s name and its description the section''s line'
Assert-True ($hsA -match 'id="specimen-a1"' -and $hsA -match 'id="specimen-a2"' -and $hsA -notmatch 'id="specimen-b1"' -and $hsA -notmatch 'id="hs-alpha"' -and $hsA -match '<div class="grid-2">' -and $hsA -match 'spec-x' -and $hsA -match '<dialog id="hs-modal">') 'and holds that section alone, without its own grid__head, with the specimens'' style, dialogs and script'
Assert-True ($null -eq (Format-HouseStyleSpecimensPageHtml -Body $hsFix -Section 'gamma')) 'a section the specimens do not have is no page (the server''s 404)'
$hsSec = Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/dkj-brandbook/tokens'
Assert-True ($hsSec.Page -eq 'dkj-brandbook' -and $hsSec.Section -eq 'tokens' -and $hsReq.Section -eq '' -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/dkj-brandbook/A') -and $null -eq (Resolve-PluginsPageRequest -Path '/dev/plugins/dkj-policy/dkj-brandbook/a/b')) 'a section is one slug below the brand book, and nothing else is'
Assert-True ((Format-HouseStyleSpecimensPageHtml -Body '<p>no sections</p>') -match 'no section was found') 'specimens with no section say so, rather than drawing an empty grid'
$hsErr = Format-HouseStyleSpecimensPageHtml -Body $hsFix -ReadError 'gone <now>'
Assert-True ($hsErr -notmatch 'card--link' -and $hsErr -match 'could not be read: gone &lt;now&gt;') 'a read error replaces the specimens, escaped'
$specimens = [System.IO.File]::ReadAllText((Join-Path $RepoRoot 'plugins\dkj-policy\assets\dkj-brandbook\specimens.html'))
Assert-True ($specimens -notmatch '(?i)<(html|head|body)[ >]' -and $specimens -notmatch '(?i)<link ' -and $specimens -notmatch '(?i)<script[^>]+src=') 'the specimens ship beside the stylesheet as a body fragment: the shell, the stylesheet and the theme script are the server''s'
$realSplit = Split-HouseStyleSpecimens -Body $specimens
Assert-Equal ([regex]::Matches($specimens, 'class="grid__head"><h2').Count) @($realSplit.Sections).Count 'the real specimens split into every section they head, none lost to the cut (#3563)'
Assert-True ((@($realSplit.Sections) | Where-Object { $_.Cards -lt 1 }).Count -eq 0 -and $realSplit.Tail -match '^<script>' -and $realSplit.Tail -match 'DKJTheme\.picker' -and $realSplit.Head -match '<style>') 'every real section holds specimens, and the style and the script land on each section''s page (#3831: the core holds no dialog of its own)'
$productSpecimens = [System.IO.File]::ReadAllText((Join-Path $RepoRoot 'plugins\dkj-policy\extensions\dkj-solutions\assets\dkj-brandbook-product\specimens.html'))
$joined = Split-HouseStyleSpecimens -Body (Join-HouseStyleSpecimens -Core $specimens -Product $productSpecimens)
Assert-True ($joined.Tail -notmatch '<dialog[^>]*\bopen\b' -and $joined.Tail -notmatch 'class="spec-stage' -and $joined.Tail -match '^<dialog' -and $joined.Tail -match 'id="hs-modal"' -and $joined.Tail.IndexOf('id="hs-modal"') -lt $joined.Tail.IndexOf('<script>')) 'joined with the product''s, the tail is the closed modal specimens, then the script that opens them, never the open in-place dialogs of Overlays (#3703, #3831)'
$coreClasses = [regex]::Matches(([regex]::Replace([System.IO.File]::ReadAllText((Join-Path $RepoRoot 'plugins\dkj-policy\assets\dkj-brandbook\house-style.css')), '/\*[\s\S]*?\*/', '')), '\.([a-zA-Z][\w-]*)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
$specClasses = [regex]::Matches(($realSplit.Sections | ForEach-Object { $_.Inner }) -join '', 'class="([^"]+)"') | ForEach-Object { $_.Groups[1].Value -split '\s+' } | Where-Object { $_ -and $_ -notmatch '^spec-' } | Sort-Object -Unique
Assert-Equal '' (($specClasses | Where-Object { $coreClasses -notcontains $_ -and [regex]::IsMatch([System.IO.File]::ReadAllText((Join-Path $RepoRoot 'plugins\dkj-policy\extensions\dkj-solutions\assets\dkj-brandbook-product\house-product.css')), '\.' + [regex]::Escape($_) + '(?![\w-])') }) -join ', ') 'Admin''s specimens use no class only the product layer defines: Admin renders without it (#3831)'
Assert-Equal (([regex]::Matches($specimens, '<section class="card[ "]')).Count + ([regex]::Matches($productSpecimens, '<section class="card[ "]')).Count) (($joined.Sections | ForEach-Object { $_.Cards } | Measure-Object -Sum).Sum) 'the join loses no card: every core and product specimen is on the product''s pages (#3831)'
$fixIndented = '<div class="spec-page">' + "`n" + '<div class="grid-2">' + "`n" + '  <div class="grid__head"><h2 id="hs-o">O</h2><p class="card__sub">s</p></div>' + "`n" + '  <section class="card"><dialog class="dialog" open>in place</dialog></section>' + "`n" + '</div>' + "`n" + '</div>' + "`n" + '<dialog id="m">modal</dialog>'
Assert-Equal '<dialog id="m">modal</dialog>' (Split-HouseStyleSpecimens -Body $fixIndented).Tail 'an indented <dialog> inside a section does not start the tail; the first column-0 one does (#3703)'
$realPages = @(@(Format-HouseStyleSpecimensPageHtml -Body $specimens) + @(@($realSplit.Sections) | ForEach-Object { Format-HouseStyleSpecimensPageHtml -Body $specimens -Section $_.Slug }))
Assert-True ((@($realPages) | Where-Object { $_ -match 'sections in one column' }).Count -eq 0) 'the real house-style overview and every section page keep within the long-page rule'
Write-Host '-- the house style on the product, and Admin sending it there (Maikel, October 31, 2026)' -ForegroundColor Cyan
Assert-Equal '' (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy/dkj-brandbook').Section 'the product''s specimens overview is /plugins/dkj-policy/dkj-brandbook'
Assert-Equal 'tokens' (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy/dkj-brandbook/tokens/').Section 'and a section is one slug below it'
Assert-True ($null -eq (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy') -and $null -eq (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy/dkj-brandbook/A') -and $null -eq (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy/dkj-brandbook/a/b') -and $null -eq (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-solutions/house-style')) 'and nothing else is the product''s house style'
$phs = Format-ProductHouseStylePageHtml -Body $hsFix
Assert-True ($phs -match '<a href="/plugins">Plugins</a>' -and $phs -notmatch '<a href="/plugins/dkj-policy">dkj-policy</a>' -and $phs -match '<span aria-current="page">dkj-brandbook</span>' -and $phs -match '<h1>dkj-brandbook</h1>' -and $phs.Contains('<h3><a href="/plugins/dkj-policy/dkj-brandbook/alpha">Alpha &amp; one</a></h3><p class="card__sub">2 specimens</p>')) 'the product''s overview sits under Marketplace alone, a destination of its own (#4009), each section''s card linking its page and counting its specimens'
Assert-True ($phs -match 'site-header__tag">product<' -and $phs -match 'specimens\.html</code> on every request') 'in the product''s shell, naming the tree it reads'
$phsA = Format-ProductHouseStylePageHtml -Body $hsFix -Section 'alpha'
Assert-True ($phsA -match '<a href="/plugins/dkj-policy/dkj-brandbook">dkj-brandbook</a>' -and $phsA -match 'id="specimen-a1"' -and $phsA -notmatch 'id="specimen-b1"') 'a section''s page on the product holds that section alone, one crumb below the overview'
Assert-True ($null -eq (Format-ProductHouseStylePageHtml -Body $hsFix -Section 'gamma') -and (Format-ProductHouseStylePageHtml -Body '' -ReadError 'x <y>') -match 'could not be read: x &lt;y&gt;') 'a section none has is a 404 there too, and a read error is shown escaped'
Assert-Equal 'http://localhost:4870/plugins/dkj-policy/dkj-brandbook' (Resolve-HouseStyleProductUrl -IsSource $true -ProductUrl 'http://localhost:4870/') 'in the source repo Admin sends its house style to the product'
Assert-Equal 'http://localhost:4870/plugins/dkj-policy/dkj-brandbook/tokens' (Resolve-HouseStyleProductUrl -IsSource $true -ProductUrl 'http://localhost:4870' -Section 'tokens') 'and a section to that section'
Assert-Equal '/plugins/dkj-policy/dkj-brandbook' (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/house-style') 'the specimens'' older product address redirects to the brand book''s name (Maikel, October 31, 2026)'
Assert-Equal '/plugins/dkj-policy/dkj-brandbook/themes' (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/house-style/themes/') 'and an older section''s address to that same section'
Assert-Equal '/plugins/dkj-policy/dkj-brandbook#tokens' (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/house-style/tokens') 'the older Tokens address lands on the overview''s token groups too'
Assert-True ((Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/dkj-brandbook') -eq '' -and (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy') -eq '') 'and nothing else redirects'
Write-Host '-- the brand book''s overview opens on its token groups (Maikel, October 31, 2026)' -ForegroundColor Cyan
$tkReq = Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy/dkj-brandbook/tokens/color/'
Assert-True ($tkReq.Section -ceq 'tokens' -and $tkReq.Token -ceq 'color' -and (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy/dkj-brandbook/tokens').Token -eq '' -and $null -eq (Resolve-ProductHouseStyleRequest -Path '/plugins/dkj-policy/dkj-brandbook/themes/light')) 'a token group is one slug below tokens, and below no other section'
$bbOver = Format-ProductHouseStylePageHtml -Body $specimens
$tkAt = $bbOver.IndexOf('<div class="grid-3" id="tokens"><div class="grid__head"><h2>Tokens</h2></div>')
$cmAt = $bbOver.IndexOf('<div class="grid-3" id="components"><div class="grid__head"><h2>Components</h2></div>')
$tkLabels = @([regex]::Matches($bbOver.Substring([Math]::Max(0, $tkAt), [Math]::Max(0, $cmAt - $tkAt)), 'class="card bb-card" id="g-[a-z-]+"><div class="card__head"><h3><a href="/plugins/dkj-policy/dkj-brandbook/tokens/[a-z-]+">([^<]+)</a></h3>') | ForEach-Object { $_.Groups[1].Value })
Assert-True ($tkAt -ge 0 -and ($tkLabels -join ',') -ceq 'Color,Text,Scale') 'the overview opens on an h2 Tokens over the cards Color, Text and Scale, in that order: Radius, Spacing and Size are one group since #4009 (F6)'
Assert-True (-not $bbOver.Contains('href="/plugins/dkj-policy/dkj-brandbook/tokens"') -and $bbOver.Contains('<a class="chip" href="/plugins/dkj-policy/dkj-brandbook/themes">Themes</a>') -and $bbOver -notmatch 'id="preview"' -and $bbOver -notmatch 'id="g-themes"') 'the Tokens section''s own card gives way to the groups, and the themes are no card but a chip in the bar beside the theme switcher (#4009, F5)'
$cmLabels = @([regex]::Matches($bbOver.Substring([Math]::Max(0, $cmAt)), 'class="card bb-card" id="g-[a-z-]+"><div class="card__head"><h3><a href="[^"]+">([^<]+)</a></h3>') | ForEach-Object { $_.Groups[1].Value })
Assert-True ($cmAt -gt $tkAt -and $cmLabels.Count -gt 0 -and $cmLabels[0] -ceq 'Actions' -and $cmLabels -notcontains 'Themes' -and $cmLabels -notcontains 'Text') 'every other section follows under a second h2, Components, and the Text section is not there: it lives on the Text token page (Maikel, November 1, 2026)'
Write-Host '-- the overview previews, searches and names its tree; every page below it walks (#4009, #4002''s wireframe B plus C''s previous / next)' -ForegroundColor Cyan
$bbProv = Format-ProductHouseStylePageHtml -Body $specimens -Provenance 'feat/x<y> @ 1234abcd'
Assert-True ($bbProv.Contains('<span class="chip bb-prov" title="Read from this checkout on every request, uncommitted files included">working tree &middot; feat/x&lt;y&gt; @ 1234abcd</span>') -and -not $bbOver.Contains('class="chip bb-prov"')) 'the bar opens on a chip naming the branch and commit the pages were read from, escaped, and shows none where the server knows neither (F7)'
Assert-True ($bbOver.Contains('<input id="bb-q" class="nav-search__input" type="search"') -and $bbOver.Contains('<a class="chip" href="#tokens">Tokens</a><a class="chip" href="#components">Components</a>') -and $bbOver.Contains('id="bb-picker"') -and $bbOver.Contains('window.DKJTheme.picker(slot')) 'and holds the search, a jump chip per group and the theme switcher (B1.3-5)'
Assert-True ($bbOver.Contains('id="bb-empty" hidden') -and $bbOver.Contains('id="bb-clear"') -and $bbOver.Contains('id="bb-browse"') -and $bbOver.Contains('id="bb-suggest"')) 'nothing matching is no dead end: the empty state clears, browses and suggests the closest name (B3)'
$bbIdx = ConvertFrom-Json ([regex]::Match($bbOver, '<script type="application/json" id="bb-index">(.*?)</script>').Groups[1].Value)
$bbPages = @(Get-ProductBrandbookPages -Split (Split-HouseStyleSpecimens -Body $specimens))
Assert-True (@($bbIdx).Count -eq ($bbPages | ForEach-Object { @($_.Items).Count } | Measure-Object -Sum).Sum -and @($bbIdx | Where-Object { $_.h -cnotmatch '^/plugins/dkj-policy/dkj-brandbook/[a-z/-]+#[a-z0-9-]+\z' }).Count -eq 0) 'the search index holds every specimen of every page, each linking its page at its anchor'
$bbRadius = @($bbIdx | Where-Object { $_.t -ceq 'Radius' })[0]
$tkScale = Format-ProductHouseStylePageHtml -Body $specimens -Section 'tokens' -Token 'scale'
Assert-True ($bbRadius.g -ceq 'Scale' -and $tkScale.Contains('id="' + ($bbRadius.h -split '#')[1] + '"') -and $bbOver.Contains('<a class="chip" href="' + $bbRadius.h + '">Radius</a>')) 'and the anchor a result and a name chip link to is the one the page writes on that card (B2, B1.7)'
Assert-True ($bbOver -match 'id="g-color">[\s\S]*?class="bb-dot" style="background: var\(--primary\)"' -and $bbOver -match 'id="g-scale">[\s\S]*?class="bb-radius" style="border-radius: var\(--radius-pill\)"' -and $bbOver -notmatch 'style="[^"]*#[0-9a-fA-F]{3,8}')'a token group''s card previews its tokens, each a var() the theme switcher redraws (F2)'
$tkOrderS = @([regex]::Matches($tkScale, 'grid__head"><h2>([^<]+)</h2>|card__head"><h3>([^<]+)</h3>') | ForEach-Object { if ($_.Groups[1].Success) { '#' + $_.Groups[1].Value } else { $_.Groups[2].Value } })
Assert-Equal '#Radius,Radius,#Spacing,Spacing scale,#Size,Sizes and elevation' ($tkOrderS -join ',') 'the Scale page sets the three former groups each under an h2 of its own'
Assert-True ((Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/dkj-brandbook/tokens/radius') -ceq '/plugins/dkj-policy/dkj-brandbook/tokens/scale#s-radius' -and (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/dkj-brandbook/tokens/spacing/') -ceq '/plugins/dkj-policy/dkj-brandbook/tokens/scale#s-spacing-scale' -and (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/dkj-brandbook/tokens/size') -ceq '/plugins/dkj-policy/dkj-brandbook/tokens/scale#s-sizes-and-elevation') 'and the three former groups'' addresses land on their card there'
Assert-Equal 'Color,Text,Scale' ((@($bbPages | Where-Object { $_.Token }) | ForEach-Object { $_.Label }) -join ',') 'the walk opens on the token groups'
Assert-True ($bbPages[-1].Label -ceq 'Themes' -and @($bbPages | Where-Object { $_.Label -ceq 'Text' -and -not $_.Token }).Count -eq 0) 'and ends on the themes, with the Text section walked as the Text group'
$walkScale = [regex]::Match($tkScale, '<nav class="bb-walk"[\s\S]*?</nav>').Value
Assert-True ($walkScale.Contains('<a class="btn" rel="prev" href="/plugins/dkj-policy/dkj-brandbook/tokens/text">&larr; Text</a>') -and $walkScale.Contains('<span class="note">3 of ' + $bbPages.Count + '</span>') -and $walkScale.Contains('rel="next" href="' + $bbPages[3].Href + '"') -and ([regex]::Matches($tkScale, 'class="bb-walk"')).Count -eq 2 -and $tkScale.Contains('ArrowLeft')) 'a page carries previous / next and its position, above and below its cards, and the arrow keys follow them (C1.4, F3)'
$walkFirst = Format-BrandbookWalkHtml -Pages $bbPages -Index 0
$walkLast = Format-BrandbookWalkHtml -Pages $bbPages -Index ($bbPages.Count - 1)
Assert-True ($walkFirst -notmatch 'rel="prev"' -and $walkFirst -match 'rel="next"' -and $walkLast -match 'rel="prev"' -and $walkLast -notmatch 'rel="next"' -and (Format-BrandbookWalkHtml -Pages $bbPages -Index -1) -eq '') 'the first page has no previous, the last no next, and a page outside the walk no bar'
$bbTextSec = Format-ProductHouseStylePageHtml -Body $specimens -Section 'text'
Assert-True ($bbTextSec -match '<h1>Text</h1>' -and $bbTextSec -notmatch 'class="bb-walk"') 'the Text section keeps its own address, outside the walk'
Assert-True ($phsA -match 'class="bb-walk"' -and $phsA -match 'id="specimen-a1"' -and $phs.Contains('<p class="bb-names"></p>')) 'a card that names its own id keeps it and is counted, and a card with no title gets no chip'
$tkCards = Get-ProductBrandbookTokenCards -Inner ((Split-HouseStyleSpecimens -Body $specimens).Sections | Where-Object { $_.Slug -ceq 'tokens' }).Inner
$tkNamed = @($script:ProductBrandbookTokenGroups | ForEach-Object { $_.Cards })
Assert-True ($tkCards.Count -gt 0 -and @($tkCards | Where-Object { $tkNamed -cnotcontains $_.Title }).Count -eq 0 -and @($tkNamed | Where-Object { @($tkCards.Title) -cnotcontains $_ }).Count -eq 0) 'every specimen card of the real Tokens section is in exactly the groups that name it, and every group names a card the file holds'
$tkColor = Format-ProductHouseStylePageHtml -Body $specimens -Section 'tokens' -Token 'color'
$tkOrder = @([regex]::Matches($tkColor, '<h2>([^<]+)</h2>|card__head"><h3>([^<]+)</h3>') | ForEach-Object { if ($_.Groups[1].Success) { '#' + $_.Groups[1].Value } else { $_.Groups[2].Value } })
Assert-Equal '#Theme,60,30,10,#Graphs &amp; Status,Graphs,Status' ($tkOrder -join ',') 'the Color page sets its cards under the h2s Theme (60, 30, 10) and Graphs & Status (Graphs, Status) (Maikel, October 31 and November 1, 2026)'
$tkText = Format-ProductHouseStylePageHtml -Body $specimens -Section 'tokens' -Token 'text'
$txOrder = @([regex]::Matches($tkText, 'grid__head"><h2>([^<]+)</h2>|card__head"><h3>([^<]+)</h3>') | ForEach-Object { if ($_.Groups[1].Success) { '#' + $_.Groups[1].Value } else { $_.Groups[2].Value } })
Assert-Equal '#Tokens,Font size,Font family,Font weight,#Components,Headings,Running text,Numbers,Status' ($txOrder -join ',') 'the Text page sets its token cards under an h2 Tokens and the Text section''s cards under an h2 Components (Maikel, November 1, 2026)'
Assert-True ($bbOver -match 'dkj-brandbook/tokens/text"[\s\S]*?7 specimens') 'and the overview''s Text card counts both halves'
Assert-True ($null -eq (Format-ProductHouseStylePageHtml -Body ($specimens -replace 'id="hs-text"', 'id="hs-gone"') -Section 'tokens' -Token 'text')) 'a Text section gone from the file makes the Text page a 404 rather than an empty Components'
Assert-True ($tkColor -match '<h1>Color</h1>' -and $tkColor -match '<a href="/plugins/dkj-policy/dkj-brandbook">dkj-brandbook</a>' -and $tkColor -notmatch 'dkj-brandbook/tokens">' -and $tkColor.Contains('>60</h3>') -and $tkColor.Contains('>Status</h3>') -and -not $tkColor.Contains('>Radius</h3>')) 'a group''s page is its own cards alone, one crumb below dkj-brandbook (no Tokens crumb since November 1, 2026)'
Assert-True ($null -eq (Format-ProductHouseStylePageHtml -Body $specimens -Section 'tokens' -Token 'shadow') -and $null -eq (Format-ProductHouseStylePageHtml -Body $hsFix -Section 'tokens' -Token 'color')) 'a group none has, or specimens with no Tokens section, is a 404'
Assert-True ($null -eq (Format-ProductHouseStylePageHtml -Body $specimens -Section 'tokens')) 'and /tokens itself is no page (Maikel, November 1, 2026)'
Assert-True ((Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/dkj-brandbook/tokens') -ceq '/plugins/dkj-policy/dkj-brandbook#tokens' -and (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/dkj-brandbook/tokens/') -ceq '/plugins/dkj-policy/dkj-brandbook#tokens' -and (Resolve-ProductHouseStyleRedirect -Path '/plugins/dkj-policy/dkj-brandbook/tokens/color') -eq '') 'its address redirects to the overview''s token groups, and a group''s does not'
Assert-True ((Resolve-HouseStyleProductUrl -IsSource $false -ProductUrl 'http://localhost:4870') -eq '' -and (Resolve-HouseStyleProductUrl -IsSource $true -ProductUrl '') -eq '' -and (Resolve-HouseStyleProductUrl -IsSource $true -ProductUrl 'http://evil.example:4870') -eq '') 'every other repo, a repo with no product, and anything but a loopback url keep the page in Admin'
$mpPolicy = Format-MarketplacePluginsPageHtml -Plugins @(@{ Name = 'dkj-policy'; Kind = 'workflow'; Source = './plugins/dkj-policy'; Version = '1.0.0'; Enabled = $true; Summary = 's'; Description = 'd'; Subagents = 0; Personas = 0; Skills = 0; Hooks = 0 }) -Plugin 'dkj-policy'
Assert-True ($mpPolicy -match 'id="assets"' -and $mpPolicy -match 'href="/plugins/dkj-policy/dkj-brandbook"') 'the product''s dkj-policy page links the specimens as a card'
Write-Host '-- a plugin''s page explains itself behind a "?" right of its h1 (Maikel, October 31, 2026)' -ForegroundColor Cyan
$subRow = @{ Name = 'dkj-policy'; Kind = 'workflow'; Source = './plugins/dkj-policy'; Version = '1.0.0'; Enabled = $true; Summary = 'The line. More.'; Subagents = 0; Personas = 0; Skills = 0; Hooks = 0
             Description = 'One way of working, <packaged>: a & b. THE TEAM: not a team.' }
$subPage = Format-MarketplacePluginsPageHtml -Plugins @($subRow) -Plugin 'dkj-policy'
Assert-True ($subPage -match '<div class="page-title"><h1>dkj-policy</h1><button class="page-info-button" type="button" id="page-info-button" aria-label="About dkj-policy" aria-describedby="page-info" aria-expanded="false"><svg [^>]*aria-hidden="true"[^>]*><path [^>]*/></svg></button></div>') 'the h1 and a drawn "?" button share one row, the button naming what it explains (as mesowise draws it; its ring is a CSS border)'
Assert-True ($subPage.Contains('<div class="tooltip tooltip--explain" id="page-info" role="tooltip"><p>One way of working, &lt;packaged&gt;: a &amp; b.</p><h3>The team</h3><p>not a team.</p></div>')) 'the whole description, escaped and in paragraphs, is the tooltip the button describes'
Assert-True ($subPage -match 'getElementById\("page-info-button"\)' -and $subPage -match 'mouseenter' -and $subPage -match 'Escape' -and $subPage -notmatch 'class="sub"') 'a script opens it on hover or focus and closes it on Escape, and nothing sits under the h1 (#3585)'
$subRow.Description = ''
Assert-True ((Format-MarketplacePluginsPageHtml -Plugins @($subRow) -Plugin 'dkj-policy').Contains('role="tooltip"><p>The line. More.</p>')) 'with no description the marketplace''s line stands in'
Assert-True ((Format-MarketplacePluginsPageHtml -Plugins @($subRow)) -notmatch 'page-info-button' -and (Format-ProductHouseStylePageHtml -Body $hsFix) -notmatch 'page-info' -and (Format-GeneralPageHtml -Title 't' -Lead '' -Body '') -notmatch 'page-info') 'and no other page carries one: the overview, the specimens and a page with no -Info open on their h1 alone'
Write-Host '-- one card link, never a hand-written one (#3563, #3566)' -ForegroundColor Cyan
# Every `card card--link` in Admin's and the repo's page code, per file. Format-AdminCardLinkHtml is the one card, and the
# variants written before this guard have all moved onto it (#3566), so it is the list's only entry.
# A NEW site fails here: call Format-AdminCardLinkHtml instead of writing the card's markup by hand.
$cardSites = @{
    'plugins/dkj-policy/apps/admin/lib/general-pages-lib.ps1' = 1   # Format-AdminCardLinkHtml
}
$cardFiles = @(Get-ChildItem -Path (Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin'), (Join-Path $RepoRoot 'scripts\lib') -Filter '*.ps1' -Recurse -File)
$cardFound = @{}
foreach ($f in $cardFiles) {
    $n = [regex]::Matches([System.IO.File]::ReadAllText($f.FullName), 'card card--link').Count
    if ($n) { $cardFound[$f.FullName.Substring($RepoRoot.Length + 1).Replace('\', '/')] = $n }
}
$cardOver = @($cardFound.Keys | Where-Object { $cardFound[$_] -gt [int]$cardSites[$_] } | ForEach-Object { $_ + ' (' + $cardFound[$_] + ')' })
Assert-True ($cardOver.Count -eq 0) ('no card link is written by hand outside Format-AdminCardLinkHtml (#3566)' + $(if ($cardOver.Count) { ': ' + ($cardOver -join ', ') } else { '' }))
$cardStale = @($cardSites.Keys | Where-Object { [int]$cardFound[$_] -lt $cardSites[$_] })
Assert-True ($cardStale.Count -eq 0) ('and the list names no site that no longer writes one' + $(if ($cardStale.Count) { ': ' + ($cardStale -join ', ') } else { '' }))
Write-Host '-- a long page becomes cards with a page each (#3563)' -ForegroundColor Cyan
$secs = { param($n) (1..$n | ForEach-Object { "<div class=`"grid-2`"><div class=`"grid__head`"><h2>S$_</h2></div></div>" }) -join "`n" }
Assert-Equal 4 (Get-PageSectionCount -Body (& $secs 4)) 'a section is a grid__head opening on an h2'
Assert-Equal 0 (Get-PageSectionCount -Body '<div class="grid__head"><h1>Page</h1></div><section class="card"><h2>A card</h2></section><h2>loose</h2>') 'a grid__head holding the page''s h1, a card''s h2 and a loose h2 are no sections'
Assert-True ((Format-GeneralPageHtml -Title 't' -Lead '' -Body (& $secs 4)) -notmatch 'sections in one column') 'four sections is within the rule'
$long = Format-GeneralPageHtml -Title 't' -Lead '' -Body (& $secs 5)
Assert-True ($long -match '<p class="msg--warn" role="alert">This page holds 5 sections in one column\. A page with more than 4 becomes an overview of cards, each opening a page of its own: the house style''s page rule \(#3563\)\.</p>') 'five puts a warning on the page itself, naming the count and the rule'
Assert-True ($long.IndexOf('This page holds 5') -lt $long.IndexOf('<h2>S1</h2>')) 'above the first section, where it cannot be scrolled past'
Assert-True ($one.Contains('<p class="badge-row"><span class="badge badge--sm badge--bad" aria-hidden="true">&#10007;</span>Behind</p>') -and $one -notmatch 'aria-hidden="true">Behind') 'the plugin page shows its state as the house badge row: the mark, then the word'
Assert-Equal '<p>Intro. Two chapters.</p><h3>The house style</h3><p>tokens &lt;b&gt;.</p><h3>The tracker labels</h3><p>feature. Requires X.</p>' (ConvertTo-PluginDescriptionHtml 'Intro. Two chapters. THE HOUSE STYLE: tokens <b>. THE TRACKER LABELS: feature. Requires X.') 'a description is split into escaped paragraphs at each capitals lead-in, the lead-in an h3 in sentence case'
Assert-Equal '<p>One sentence. CHECK-HOUSE-STYLE gate holds.</p>' (ConvertTo-PluginDescriptionHtml 'One sentence. CHECK-HOUSE-STYLE gate holds.') 'capitals without a colon start no paragraph'
$headRow = [regex]::Match($one, '(?s)<div class="page-head"><div class="page-head__title"><h1>alpha</h1></div><div class="page-head__end"><p class="badge-row">.*?Behind</p></div></div>').Success
Assert-True $headRow 'the plugin page sets its state at the right end of the page header, beside the h1 (the owner, October 26, 2026; #3811)'

Write-Host '-- the Docs coverage pages (#3906)' -ForegroundColor Cyan
$dcItems = @(Get-DocsCoverageItems)
Assert-Equal 10 $dcItems.Count 'ten items, as #3906 lists them'
Assert-Equal ((3895..3904) -join ',') (($dcItems | ForEach-Object { $_.Issue }) -join ',') 'in the issue''s own order, one issue each'
Assert-Equal 10 (@($dcItems | ForEach-Object { $_.Slug } | Sort-Object -Unique)).Count 'every slug is unique'
Assert-True (@($dcItems | Where-Object { $_.Slug -cnotmatch '^[a-z0-9-]+\z' }).Count -eq 0) 'every slug matches the route''s own pattern'
Assert-True (@($dcItems | Where-Object { @($_.Label -split ' ').Count -gt 5 }).Count -eq 0) 'every label is five words at most (it is the page''s h1)'
Assert-True (@($dcItems | Where-Object { $_.Docs -cnotmatch '^https://code\.claude\.com/docs/' }).Count -eq 0) 'every item names its docs page'
Assert-Equal '--' (Get-DocsCoverageStatus $null) 'a status not read is --'
Assert-Equal 'Covered' (Get-DocsCoverageStatus @{ State = 'CLOSED'; StateReason = 'COMPLETED'; Labels = @(); Assigned = $false }) 'closed as completed is Covered, the same state as a docs page the repo already uses (the owner, November 9, 2026)'
Assert-Equal 'Declined' (Get-DocsCoverageStatus @{ State = 'CLOSED'; StateReason = 'NOT_PLANNED'; Labels = @(); Assigned = $false }) 'closed otherwise is Declined'
Assert-Equal 'In review' (Get-DocsCoverageStatus @{ State = 'OPEN'; Labels = @('prio-2', 'awaiting-review-dev'); Assigned = $true }) 'a look at a result comes first'
Assert-Equal 'Awaiting decision' (Get-DocsCoverageStatus @{ State = 'OPEN'; Labels = @('awaiting-decision-dev'); Assigned = $false }) 'then a decision'
Assert-Equal 'Waiting' (Get-DocsCoverageStatus @{ State = 'OPEN'; Labels = @('awaiting-pull'); Assigned = $true }) 'then any other wait, before the assignee'
Assert-Equal 'In progress' (Get-DocsCoverageStatus @{ State = 'OPEN'; Labels = @('prio-2'); Assigned = $true }) 'an assignee without a wait is In progress'
Assert-Equal 'Open' (Get-DocsCoverageStatus @{ State = 'OPEN'; Labels = @(); Assigned = $false }) 'and nothing at all is Open'
$dcQuery = Get-DocsCoverageQuery
Assert-True ($dcQuery -notmatch '"') 'the query holds no double quote (5.1 would split it on its way to gh)'
Assert-True ($dcQuery -match 'i3895: issue\(number: 3895\)' -and $dcQuery -match 'i3904: issue\(number: 3904\)') 'the query asks every item''s issue under an alias'
$dcJson = '{"data":{"repository":{"i3895":{"number":3895,"state":"OPEN","stateReason":null,"assignees":{"totalCount":0},"labels":{"nodes":[{"name":"awaiting-decision-dev"}]}},"i3904":{"number":3904,"state":"CLOSED","stateReason":"COMPLETED","assignees":{"totalCount":1},"labels":{"nodes":[]}},"i3896":null}}}'
$dcParsed = ConvertFrom-DocsCoverageQuery -Json $dcJson
Assert-Equal '' $dcParsed.Error 'a well-formed answer has no error'
Assert-Equal 'Awaiting decision' (Get-DocsCoverageStatus $dcParsed.ByIssue[3895]) 'the answer is read by issue number'
Assert-Equal 'Covered' (Get-DocsCoverageStatus $dcParsed.ByIssue[3904]) 'with its state reason'
Assert-True (-not $dcParsed.ByIssue.ContainsKey(3896)) 'an issue the answer could not resolve is left out, not a blank entry'
Assert-True ([bool](ConvertFrom-DocsCoverageQuery -Json '').Error) 'an empty answer is an error'
Assert-True ([bool](ConvertFrom-DocsCoverageQuery -Json 'not json').Error) 'so is one that is not JSON'
$dcMeta = @{ GeneratedAt = '2026-11-08 12:00:00'; Seconds = 0.4 }
$dcOver = Format-DocsCoveragePageHtml -Query $dcParsed -Meta $dcMeta -Catalog @()
Assert-Equal 10 ([regex]::Matches($dcOver, '<td class="col-start"><a href="https://code\.claude\.com/docs/en/[a-z0-9/-]+#[a-z0-9-]+">')).Count 'every item''s name links the docs heading it is about'
Assert-True ($dcOver -notmatch 'href="/docs-coverage/') 'and no item has a page of its own (the owner, November 9, 2026)'
Assert-True ($dcOver -match '<h1[^>]*>Docs coverage</h1>') 'the overview''s h1 is its crumb'
Assert-True ($dcOver -match '<table class="table" id="items">') 'the overview is a house table, not cards (the owner, November 9, 2026)'
Assert-True ($dcOver -notmatch 'ph-cards') 'and carries no card grid'
Assert-Equal 10 ([regex]::Matches($dcOver, '(?s)<tbody>.*?</tbody>').Value.Split([string[]]@('<tr>'), [StringSplitOptions]::None).Count - 1) 'one row per item'
Assert-True ($dcOver -match '<tr><td><a href="https://code.claude.com/docs/en/plugins/overview">Plugins</a></td><td class="col-start"><a href="https://code.claude.com/docs/en/plugins/create">Create plugins</a></td><td class="col-start"><a href="https://code.claude.com/docs/en/plugins/dependencies#declare-dependencies">Plugin dependencies</a></td><td class="col-start"><span class="dot dc-dot--awaiting-decision" aria-hidden="true"></span>Awaiting decision</td><td class="col-start">Tier-5</td><td><a href="https://github.com/DKJ-Solutions/dkj-marketplace/issues/3895">#3895</a></td><td class="col-end"><button class="dc-detail" type="button" aria-haspopup="dialog" aria-controls="row-detail" data-detail="detail-item-plugin-dependencies" aria-label="Details of Plugin dependencies"><svg [^>]+>.*?</svg></button></td></tr>') 'an item row: the docs section and group as links, its name linking the docs heading, its status, its impact tier, its issue, and a Details icon that opens its popup'
Assert-True ($dcOver -match '<tr><td><a href="[^"]+">Build with Claude Code</a></td><td class="col-start"><a href="[^"]+">Agents and parallel work</a></td><td class="col-start"><a href="[^"]+#supported-frontmatter-fields">Richer subagent frontmatter</a></td><td class="col-start">--</td><td class="col-start">Tier-6</td><td><a href="[^"]+/issues/3897">') 'an issue the answer left out reads --'
Assert-True ($dcOver -notmatch '>Docs <span class="arrow"') 'there is no Docs column: on a page row it repeated the title (the owner, November 9, 2026)'
Assert-True ($dcOver -match '(?s)<template id="detail-item-plugin-dependencies">.*?<p class="dialog__sub">Declare which plugins a plugin needs in its manifest</p>.*?<h3>Checked against the docs</h3><ul><li>The dependencies key exists') 'the Details popup gives the item''s one line and what the docs check found'
Assert-True (@($dcItems | Where-Object { -not $_.Section -or -not $_.Group }).Count -eq 0) 'every item names the docs section and group its page sits in'
Assert-True (@($dcItems | Where-Object { $_.SectionUrl -cnotmatch '^https://code\.claude\.com/docs/en/[a-z0-9/-]+\z' -or $_.GroupUrl -cnotmatch '^https://code\.claude\.com/docs/en/[a-z0-9/-]+\z' -or $_.DocsAnchor -cnotmatch '^[a-z0-9-]+\z' -or -not $_.DocsHeading }).Count -eq 0) 'and links each to a docs page, and its docs page to a heading'
Assert-Equal 'Section,Group,Item,Status,Impact,Issue' (([regex]::Matches($dcOver, '<button class="sort" type="button">([A-Za-z]+) <span class="arrow"') | ForEach-Object { $_.Groups[1].Value }) -join ',') 'every column head is the house''s sortable head, in this order'
Assert-Equal 6 ([regex]::Matches($dcOver, '<th scope="col"[^>]* aria-sort="none">')).Count 'and each starts unsorted'
Assert-True ($dcOver -match 'getElementById\("items"\)' -and $dcOver -match 'aria-sort", dir' -and $dcOver -match 'a\.dataset\.i - b\.dataset\.i') 'a script sorts the rows on a head''s click, keeping ties in the page''s order'
Assert-True ($dcOver -notmatch '>What</th>' -and $dcOver -notmatch 'dc-what') 'there is no What column (the owner, November 9, 2026): its text moved into the Details popup'
Assert-True ($dcOver -notmatch 'GitHub could not be read') 'a good read raises no warning'
Assert-True ($dcOver -notmatch 'info-button' -and $dcOver -notmatch 'role="tooltip"' -and $dcOver -notmatch '>\?</button>') 'no cell carries a "?" or a tooltip: the Details popup holds it all (the owner, November 9, 2026)'
Assert-Equal 2 (@($dcItems | Where-Object { $_.WhyDeclined })).Count 'the two items closed as not planned carry why'
$dcDeclined = ConvertFrom-DocsCoverageQuery -Json '{"data":{"repository":{"i3898":{"number":3898,"state":"CLOSED","stateReason":"NOT_PLANNED","assignees":{"totalCount":0},"labels":{"nodes":[]}},"i3901":{"number":3901,"state":"CLOSED","stateReason":"NOT_PLANNED","assignees":{"totalCount":0},"labels":{"nodes":[]}}}}}'
$dcDecl = Format-DocsCoveragePageHtml -Query $dcDeclined -Meta $dcMeta -Catalog @()
Assert-Equal 2 ([regex]::Matches($dcDecl, '<td class="col-start"><span class="dot dc-dot--declined" aria-hidden="true"></span>Declined</td>')).Count 'a declined item reads plain Declined in its cell, with or without a reason'
Assert-True ($dcDecl -match '(?s)<template id="detail-item-hook-if-async">.*?<h3>Why declined</h3><p>Measured: ') 'its reason is in the Details popup, under how this repo stands'
Assert-True ($dcDecl -notmatch 'info-button' -and $dcDecl -notmatch 'role="tooltip"' -and $dcDecl -notmatch 'mouseenter') 'and no "?", tooltip or hover script is left on the page'
$dcColors = Get-DocsCoverageStatusColors
Assert-Equal 'Covered,In progress,In review,Awaiting decision,Waiting,Open,Declined,Not relevant' (@($dcColors.Keys) -join ',') 'every status a row can show has a colour of its own (the owner, November 9, 2026)'
Assert-Equal $dcColors.Count (@($dcColors.Values | Sort-Object -Unique)).Count 'and no two statuses share one'
Assert-True (@($dcColors.Values | Where-Object { $_ -cnotmatch '^--[a-z0-9-]+\z' }).Count -eq 0) 'each colour is a house token, never a typed code'
$dcStyle = Get-DocsCoverageStatusStyle
Assert-True ($dcStyle -match '\.dc-dot--awaiting-decision \{ background: var\(--warning-3\); \}' -and $dcStyle -match '\.dc-dot--not-relevant \{ background: var\(--bg-3\); \}') 'the page''s own layer reads each status''s token through a class of its own'
Assert-True ($dcStyle -notmatch '#[0-9a-fA-F]{3,8}|rgb|hsl|color-mix') 'and types or derives no colour (the brand book)'
Assert-Equal '--' (Format-DocsCoverageStatusText '--') 'a status not read has no dot'
Assert-True ($dcOver -match '\.dc-dot--covered \{' -and $dcOver -notmatch 'dc-dot--done') 'the overview carries the status colours, and Done is no status of its own any more'
$dcCat = @(Get-DocsCoverageCatalog)
Assert-True ($dcCat.Count -ge 200) 'the catalog holds every docs page (228 on November 9, 2026)'
Assert-Equal $dcCat.Count (@($dcCat | ForEach-Object { $_.Path } | Sort-Object -Unique)).Count 'one entry per page'
Assert-True (@($dcCat | Where-Object { @('Covered', 'Open', 'Not relevant') -cnotcontains $_.Status }).Count -eq 0) 'every page carries one of the three fixed statuses'
Assert-True (@($dcCat | Where-Object { $_.Status -ceq 'Covered' -and @($_.Evidence | Where-Object { $_ }).Count -eq 0 }).Count -eq 0) 'a Covered page always names its evidence'
Assert-True (@($dcCat | Where-Object { -not $_.Note -or -not $_.Section -or -not $_.SectionPath -or ($_.Group -and -not $_.GroupPath) }).Count -eq 0) 'and every page has a note, a section and a link for its section and group'
Assert-True (@($dcCat | Where-Object { $_.Note -match [string][char]0x2014 }).Count -eq 0) 'no em dash in a note'
Assert-True (@($dcCat | Where-Object { $_.Status -ceq 'Open' -and (@('Adopt', 'Consider', 'Skip') -cnotcontains $_.Advice -or -not $_.AdviceWhy) }).Count -eq 0) 'every Open page says whether to take it up, and why (the owner, November 9, 2026)'
Assert-True (@($dcCat | Where-Object { $_.Status -cne 'Open' -and $_.Advice }).Count -eq 0) 'and only an Open page carries advice'
Assert-True (@($dcCat | Where-Object { $null -ne $_.Potential }).Count -eq 0) 'no page carries a Potential score: Impact took its place (the owner, November 9, 2026)'
$dcAdv = Format-DocsCoveragePageHtml -Query $dcParsed -Meta $dcMeta -Catalog @(@{ Path = 'sandboxing'; Title = 'Sandboxing'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Permissions and sandboxing'; GroupPath = 'permissions'
    Status = 'Open'; Note = 'No sandbox key in settings.json.'; Evidence = @(); Potential = 2; Impact = 2; Advice = 'Skip'; AdviceWhy = 'Native Windows support is limited.'; Desc = 'Isolate Bash.' })
Assert-True ($dcAdv -match '(?s)<template id="detail-page-sandboxing">.*?<dt>Impact</dt><dd>Tier-2</dd></div></dl><h2>Advice</h2><p>No sandbox key in settings\.json\. Our advice: skip it\. Native Windows support is limited\.</p>' -and $dcAdv -notmatch '<h3>Why (skip|consider|adopt)</h3>' -and $dcAdv -notmatch 'id="detail-page-sandboxing">(?:(?!</template>).)*<h3>Note</h3>') 'the Details popup of an Open page gives its impact, then one Advice paragraph: the note, the advice and why, and no Note of its own (the owner, November 9, 2026)'
$dcCatRow = @(@{ Path = 'statusline'; Title = 'Customize your status line'; Section = 'Configuration'; SectionPath = 'settings'; Group = 'Interface'; GroupPath = 'terminal-config'
    Status = 'Covered'; Impact = 3; Note = 'settings.json runs show-progress.ps1.'; Evidence = @('.claude/settings.json'); Desc = 'Configure a custom status line.' },
    @{ Path = 'agent-sdk/overview'; Title = 'Agent SDK overview'; Section = 'Agent SDK'; SectionPath = 'agent-sdk/overview'; Group = ''; GroupPath = ''
    Status = 'Not relevant'; Note = 'The repo does not build on the Agent SDK.'; Evidence = @(); Desc = 'Build agents.' })
$dcWithCat = Format-DocsCoveragePageHtml -Query $dcParsed -Meta $dcMeta -Catalog $dcCatRow
Assert-Equal 12 ([regex]::Matches($dcWithCat, '(?s)<tbody>.*?</tbody>').Value.Split([string[]]@('<tr>'), [StringSplitOptions]::None).Count - 1) 'a row per item and a row per docs page'
Assert-True ($dcWithCat -match '<tr><td><a href="https://code.claude.com/docs/en/settings">Configuration</a></td><td class="col-start"><a href="https://code.claude.com/docs/en/terminal-config">Interface</a></td><td class="col-start"><a href="https://code.claude.com/docs/en/statusline">Customize your status line</a></td><td class="col-start"><span class="dot dc-dot--covered" aria-hidden="true"></span>Covered</td><td class="col-start">Tier-3</td><td></td><td class="col-end"><button class="dc-detail" [^>]+data-detail="detail-page-statusline"[^>]*>.*?</button></td></tr>') 'a docs page row: its section and group links, its title linking the page, its status, its impact tier, no issue, and a Details icon'
Assert-True ($dcWithCat -match '(?s)<template id="detail-page-statusline">.*?<h3>Note</h3><p>settings\.json runs show-progress\.ps1\.</p><h3>Evidence</h3><ul><li><code>\.claude/settings\.json</code></li></ul>') 'the Details popup gives the note and the evidence'
Assert-True ($dcWithCat -match '(?s)<template id="detail-page-statusline">.*?<p class="dialog__sub">Configure a custom status line\.</p>') 'and the docs'' own description under its h1'
Assert-True ($dcWithCat -match '<tr><td><a href="[^"]+">Agent SDK</a></td><td class="col-start"></td>' -and $dcWithCat -match '(?s)<template id="detail-page-agent-sdk-overview">.*?<h3>Note</h3><p>The repo does not build on the Agent SDK\.</p></div></template>') 'a page with no group leaves the cell empty, and no evidence adds no Evidence block'
Assert-True ($dcWithCat -match 'if \(x === "" && y !== ""\) return 1') 'an empty cell sorts last in either direction'
Assert-True ($dcWithCat -match 'Not relevant</td><td class="col-start">N/A</td><td></td><td class="col-end">') 'a Not relevant page reads N/A in the Impact column (the owner, November 9, 2026)'
Assert-True ($dcWithCat -match 'if \(s === "N/A" \|\| s === "--"\) return "";' -and $dcWithCat -match 's\.replace\(/\^\(#\|Tier-\)/, ""\)') 'and the Impact column sorts by its tier number, N/A and -- last'
Assert-True ($dcOver -match '(?s)id="detail-item-plugin-dependencies">.*?<dt>Impact</dt><dd>Tier-5</dd>' -and $dcWithCat -match '(?s)id="detail-page-agent-sdk-overview">.*?<dt>Impact</dt><dd>N/A</dd>') 'the Details popup names the impact under how this repo stands'
Assert-Equal 'Tier-1' (Format-DocsCoverageImpact -Impact 1 -Status 'Open') 'an impact reads as its tier'
Assert-Equal 'Tier-8' (Format-DocsCoverageImpact -Impact 8 -Status 'Covered') 'up to Tier-8, the most important'
Assert-Equal 'N/A' (Format-DocsCoverageImpact -Impact 5 -Status 'Not relevant') 'Not relevant is N/A whatever impact it carries'
Assert-Equal '--' (Format-DocsCoverageImpact -Impact $null -Status 'Covered') 'a relevant row without an impact reads --'
Assert-Equal '--' (Format-DocsCoverageImpact -Impact 9 -Status 'Open') 'and so does one outside 1 to 8'
Assert-True (@($dcItems | Where-Object { @(1..8) -notcontains $_.Impact }).Count -eq 0) 'every item carries an impact from 1 to 8'
Assert-True (@($dcCat | Where-Object { $_.Status -cne 'Not relevant' -and @(1..8) -notcontains $_.Impact }).Count -eq 0) 'every Covered and Open page carries an impact from 1 to 8'
Assert-True (@($dcCat | Where-Object { $_.Status -ceq 'Not relevant' -and $null -ne $_.Impact }).Count -eq 0) 'and a Not relevant page carries none'
# The Details column (the owner, November 9, 2026): an icon per row that opens a popup with more about the row.
Assert-True ($dcOver -match '<th scope="col" class="col-end"><span class="sr-only">Details</span></th></tr></thead>') 'the last column is Details, with no sort and its name for a screen reader only'
Assert-Equal 10 ([regex]::Matches($dcOver, '<button class="dc-detail" ')).Count 'every item row carries a Details icon'
Assert-Equal 1 ([regex]::Matches($dcOver, '<dialog class="dialog dc-detail-dialog" id="row-detail"')).Count 'and they all open the one house dialog'
Assert-True ((Get-DocsCoverageStatusStyle) -match 'dialog\.dc-detail-dialog \{ width: 90vw; \}') 'the popup is the window''s width less 10% (the owner, November 9, 2026), on the page''s own class'
Assert-True ($dcOver -match '<template id="detail-item-plugin-dependencies"><div class="dialog__head"><div><h1 id="row-detail-title">Plugin dependencies</h1><p class="dialog__sub">Declare which plugins a plugin needs in its manifest</p></div></div><div class="dc-detail__body"><h2>Overview</h2><dl class="facts dc-detail__facts"><div><dt>Section</dt><dd><a href="https://code.claude.com/docs/en/plugins/overview">Plugins</a></dd></div>') 'an item''s popup is in headings (the owner, November 9, 2026): its name the h1 with its one line, then an h2 per block'
Assert-True ($dcOver -match '(?s)id="detail-item-plugin-dependencies">(?:(?!<h2>).)*<h2>Overview</h2><dl [^>]+>(?:(?!</dl>).)*<dt>Docs</dt>(?:(?!</dl>).)*<dt>Status</dt>(?:(?!</dl>).)*<dt>Issue</dt><dd><a href="[^"]+/issues/3895">#3895</a></dd>.*?<h2>The idea</h2><h3>What</h3><p>Declare plugin dependencies.*?<h3>Why</h3>.*?<h3>Checked against the docs</h3><ul><li>The dependencies key exists') 'one Overview list holds where it sits and its status and issue (the owner, November 9, 2026), then the idea, each part an h3, and each point the docs check found'
Assert-True ($dcDecl -match '(?s)id="detail-item-hook-if-async">.*?<h2>Overview</h2>.*?<h3>Why declined</h3><p>Measured: ') 'a declined item''s popup says why, under its Overview'
Assert-True ($dcAdv -match '(?s)id="detail-page-sandboxing">.*?<h2>Overview</h2>.*?<h2>Advice</h2><p>No sandbox key[^<]*Our advice: skip it\. Native Windows' -and $dcAdv -notmatch 'Potential' -and $dcAdv -notmatch '<dt>Advice</dt>') 'an Open page''s popup gives the advice and why, and no Potential even where the data still carries one'
Assert-True ($dcWithCat -match '(?s)id="detail-page-statusline"><div class="dialog__head"><div><h1 id="row-detail-title">Customize your status line</h1><p class="dialog__sub">Configure a custom status line\.</p>.*?<h3>Evidence</h3><ul><li><code>\.claude/settings\.json</code></li>') 'a docs page''s popup: its title the h1, the docs'' description under it, and its evidence'
Assert-True ($dcWithCat -notmatch '(?s)id="detail-page-agent-sdk-overview">(?:(?!</template>).)*<dt>Group</dt>' -and $dcWithCat -notmatch '(?s)id="detail-page-agent-sdk-overview">(?:(?!</template>).)*Evidence') 'a page with no group or evidence leaves those out of its popup'
Assert-True ($dcOver -notmatch 'class="dialog__title" id="row-detail-title"') 'the popup''s title is a heading, not the dialog''s plain title'
Assert-True ($dcOver -match 't\.content\.cloneNode\(true\)' -and $dcOver -match 'd\.showModal\(\)' -and $dcOver -match 'ev\.target === d \|\| ev\.target\.closest\("\.dialog__close"\)' -and $dcOver -match '"close", function \(\) \{ c\.innerHTML = ""; \}') 'a script fills the dialog from the row''s template, opens it modal, shuts it on the close button or the backdrop, and empties it when shut, so its h1 is in the page only while it is open'
$dcStyleD = Get-DocsCoverageStatusStyle
Assert-True ($dcStyleD -match '\.dc-detail \{' -and $dcStyleD -match '\.dc-detail__facts dd \{ white-space: normal;') 'the page''s own layer styles the icon and lets a fact wrap in the popup'
Assert-True ($dcStyleD -notmatch '#[0-9a-fA-F]{3,8}\b|rgb\(|hsl\(|color-mix|font-size|font-weight') 'reading only house tokens, and typing no colour, size or weight'
Assert-True ($dcWithCat -match '(?s)<label class="field dc-filter"><span>Status</span><select id="status-filter" aria-controls="items">.*?</select></label>\s*<div class="table-wrap">') 'a status filter over the table: the product layer''s .field with a select, one choice at a time (the owner, November 9, 2026)'
Assert-True ($dcWithCat -match '<select id="status-filter" aria-controls="items"><option value="all" selected>All statuses \(12\)</option><option value="covered">Covered \(2\)</option><option value="awaiting-decision">Awaiting decision \(1\)</option><option value="not-relevant">Not relevant \(1\)</option><option value="">-- \(8\)</option></select>') 'All statuses first and chosen, then each status the table shows with its row count, in the colour order and a status not read last'
Assert-True ($dcWithCat -notmatch 'type="checkbox"' -and $dcWithCat -notmatch 'filter-chip' -and $dcWithCat -notmatch 'dc-filter__panel') 'no checklist, and none of the chips or the panel it replaces'
Assert-True ($dcWithCat -match 'getElementById\("status-filter"\)' -and $dcWithCat -match 'r\.hidden = v !== "all" && slug\(r\) !== v;') 'a script shows a row when all is chosen or its status is the one chosen'
Assert-True ($dcWithCat -match 'localStorage\.setItem\(k, f\.value\)' -and $dcWithCat -match 'try \{ s = localStorage\.getItem\(k\); \} catch' -and $dcWithCat -match 'o\.value === s; \}\)\) \{ f\.value = s; apply\(\); \}') 'and remembers the last choice across a reload, restoring it only while the page still offers it (the owner, November 9, 2026)'
Assert-True ((Format-DocsCoverageStatusFilter -Statuses @()) -eq '') 'with no rows there is no filter'
Assert-True ((Get-DocsCoverageStatusStyle) -match '\.dc-filter \{ display: block; max-width: 280px; margin-bottom: var\(--spacing-3\); \}') 'the page sets the filter''s width and its space to the table'
$dcFail = Format-DocsCoveragePageHtml -Query (ConvertFrom-DocsCoverageQuery -Json '') -Meta $dcMeta -Catalog @()
Assert-True ($dcFail -match 'role="alert">GitHub could not be read') 'a failed read says so above the table'
Assert-Equal 10 ([regex]::Matches($dcFail, '<tr><td><a href="https://code\.claude\.com/docs/en/')).Count 'and still shows every row'
Assert-True (($dcOver + $dcWithCat) -notmatch [string][char]0x2014) 'no em dash anywhere (the brand book)'
Write-Host ''
Write-Host "dev-pages: $script:pass passed, $script:fail failed"
if ($script:fail -gt 0) { exit 1 }
exit 0
