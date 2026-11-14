## feat/4095-menu-and-sheet

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

- [x] Scope from #4095 and its two comments: the full-screen phone menu, `.dialog--sheet`, its two header triggers (the path title and a More cell), renderer support, README, specimens and tests; then park for the owner's look.
- [x] Built after the Figma file's `Product / Menu row`, `Menu section head`, `Menu footer`, `Product / Sheet` and the `Product / Site header` variants (Path sheet, More), and the `Menu open`, `Path sheet` and `More menu` phone frames.

### CREATE

- [x] `house-product.css`: `.dialog--screen` (the full-screen menu, with `.menu-section`, `.menu-footer` and `.menu-item__aside`), `.dialog--sheet` with `.dialog__handle`, and the header's `button.site-header__title` and `.site-header__more`.
- [x] `house-theme.js`: the path title and the More cell open their sheets as the menu toggle opens the menu; a backdrop tap shuts a sheet.
- [x] `Format-SiteHeaderHtml`: `-Path`, `-Actions`, `-SettingsHref`, `-MenuNote`; the menu is `dialog--screen` with Pages, Display and About. `Format-ProductPageHtml` passes the trail as the path and the new parameters on; the Consumers page passes its path.
- [x] Product README (reserved names, the phone section, the menu, a new "The sheet: path and actions") and the product specimens (a phone header, a static sheet and menu, two live modals).

### TEST

- [x] `dev-pages.tests.ps1`: the full-screen menu and its sections, the path sheet, the More cell and its sheet, their absence without input, the product page wiring, the `house-theme.js` triggers -- 768 passed, 0 failed.
- [x] `consumer-dashboard.tests.ps1` (the Consumers page's path title) 255 passed; `check-house-style` 175, `house-palette` 219, `check-house-style.ps1` and `check-plugin-integrity.ps1` clean.
- [x] Rendered headless in Edge at phone width (dark and light) and at 1280: the header, the open menu, the path sheet and the actions sheet match the Figma frames.

### DEPLOY: feat/4095-menu-and-sheet

Inside this repo, the product server's own pages (Consumers, Plugins, Docs coverage) open their phone menu full screen and offer their path behind the title, so the brand book's new parts are exercised on a live page before any consumer takes them.

**Score:** 2

#### What makes this deploy extra special

On a phone the product header gains the two things the Figma file already showed: a tap on the page title opens the whole path as a bottom sheet, and a More cell opens the page's own actions as one. The menu behind the hamburger now opens full screen, like a phone's settings screen, with Pages, Display and About sections, in place of the side drawer. A product that renders its pages with `Format-ProductPageHtml` gets the path sheet with the update, and passes `-Actions` and `-SettingsHref` to fill the rest.

**Score:** 3

#### Pull Request

house-product.css: full-screen menu, the sheet, and the header's path and More triggers
