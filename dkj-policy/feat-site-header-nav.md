## feat/site-header-nav

> **How this file is read.** A step is `- [ ]` until it is resolved -- `- [x]` done, or
> `- [~]` dropped with the reason, which exists so nobody ticks a box for work they did not do.
> open-pr and ship-pr both refuse while one is still open, and there is no `-Force`.
>
> **FOUR `###` HEADINGS, AND NEVER A FIFTH** -- PLAN, CREATE, TEST, DEPLOY are the whole top
> level. A section needing its own heading goes in as a `####` UNDER whichever of the four owns
> it. No gate in YOUR repo reads a heading, so this half is on you -- only the repo that authors
> this workflow refuses a fifth (Dave, August 26, 2026).
>
> **AND NOTHING BRANCH-SPECIFIC ABOVE THE FIRST OF THOSE FOUR HEADINGS** -- everything between the
> title and it is this guidance, which is identical in every branch document. A status line, a note about
> THIS branch or an instruction to a session belongs under one of the four, normally as a `####`
> in PLAN. THIS half open-pr refuses, in every repo, before the push -- it reads the shape, so a
> guidance block in your own language passes and your own paragraph here does not (Dave,
> August 26, 2026; refused since #1650).
>
> **DEPLOY takes no steps of its own, and it is WRITTEN LAST** -- it is what the branch DID, once
> TEST says so. Written while steps above it are still open it states an INTENTION, and no gate
> holds it against what landed: the step gate splits this file at that heading and counts only
> above it. The PR title is the one exception -- new-branch -Title writes it at creation, because
> open-pr composes the PR title from it. It is the one part of this file that travels verbatim
> into `CHANGELOG.md` at the merge. In each tier, write the reason
> ABOVE the Score line -- anything below it is discarded.
>
> Relative links in that text resolve FROM THIS DIRECTORY -- `CHANGELOG.md` sits here too, so
> write each path exactly as it reads in this file.
>
> For tier 2 audiences: the user who relies on what this repo ships, and decides whether to take the next version -- a subscriber of a service, or the user of a tool, its own maintainer included. That reader and nobody else -- what matters only
> inside this repo belongs under the first `**Score:**`. If the change reaches that reader
> not at all, N/A is a complete answer and the common one. **One hop and no further:** where that
> reader is itself a business, ITS own customers sit one hop past this repo and are never the reader
> here -- they take nothing this repo ships. Name the party that runs the upgrade, and score
> against them.
>
> The phase arc, the marks and the whole form: `DEVELOPMENT-portable.md`, which ships
> with this workflow.

### PLAN

Maikel, November 2, 2026: take over the three-zone nav of `DaveKJohn/djcylow-react` (logo, menu, CTA; a hamburger
and a right-hand drawer on a phone) into the site header. Chosen: the menu in the header, the breadcrumb bar kept.

### CREATE

- [x] `house-style.css`: "Site header menu" -- `.site-header__nav` / `__menu` / `__menu-toggle`, full-height link cells with the settings cell's hover, a `--bg-1` bar under the current page, and a container query that folds the links into the toggle under 48rem (so the Phone width folds it too)
- [x] `house-theme.js`: the toggle opens the `dialog.dialog--drawer.site-menu` it controls as a modal; the close button, the backdrop and the header widening again shut it -- document-level, so no call is needed
- [x] `README.md` (brand book): "The menu in the header", with the markup
- [x] `general-pages-lib.ps1`: `Format-SiteHeaderHtml -Menu -Current` draws the menu and the drawer; `Get-HubMenu` is the toolbox's (GitHub + the home page's cards, from the new `Get-HubPageCards` the cards are drawn from); `Get-SiteHeaderMenuCurrent` marks the item a page sits under; every toolbox page, its home and the release notes carry it
- [x] `dev-pages-lib.ps1` / `consumer-dashboard-lib.ps1`: the product's menu is its own pages (`Get-ProductMenu`)

### TEST

- [x] `dev-pages.tests.ps1`: the menu, its escaping, the current item, the drawer's place, the toolbox and product menus; four asserts that counted the whole page now read past the site header
- [x] dev-pages, consumer-dashboard, dev-preview-sessionstart, house-palette, check-house-style, logbook, stopwatch, stopwatch-sync, cut-release-drive, cut-release-guardrail: green
- [x] Rendered in Chrome: at 475px the toggle opens the drawer and the backdrop shuts it; zoomed out to ~1350px the links stand between the name and the gear, the current one underlined
- [x] Maikel looked at it on the preview page (November 2, 2026): "it works quite well"; he had not planned the hub cards in the bar, and chose to ship them as they are

### DEPLOY: feat/site-header-nav

The house site header can carry an app's main pages between its name and the settings button. On a wide header they stand as full-height cells with the page you are under marked; narrower than 48rem they fold into a three-line toggle that opens them as the house drawer. The toolbox's menu is its home page's cards, a product's its own pages.

**Score:** 3

#### What makes this deploy extra special

Every page of the toolbox, and of an app that adds a menu to its header, can be reached from every other page in one click, on a phone too, instead of going back home first.

**Score:** 3

#### Pull Request

The site header carries a menu between the brand and the settings, folding into a drawer on a phone

