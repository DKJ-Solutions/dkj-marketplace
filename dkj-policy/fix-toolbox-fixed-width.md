## fix/toolbox-fixed-width

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

Rule (Maikel, November 4, 2026): the Toolbox is viewed in VS Code's Simple Browser, a ~16:9 screen, so a width choice does not apply there; the product port is responsive. Drop the Width group from Settings and pin the Toolbox to full.

### CREATE

- [x] `Get-ToolboxWidthScript` pins `full` right after `house-theme.js` on every Toolbox page (general pages, the hub, the release notes)
- [x] The Settings page drops its Width group; every Toolbox settings panel draws with `widths: false`
- [x] The rule written into `hub/README.md`, "The hub and the product"
- [x] The pin skips a product page (`-BrandTag 'product'`), which shares the general page shell
- [x] The product gets its own `/settings`, theme and width (`Get-SettingsPageParts -Widths`, `Format-ProductSettingsHtml`), as a card and a menu item

### TEST

- [x] `dev-pages.tests.ps1` (584 passed), `consumer-dashboard.tests.ps1` (239 passed) and `dev-preview-sessionstart.tests.ps1` (365 passed)
- [x] The owner looked at both Settings pages before the merge (a visible result): "ship it", Maikel, November 4, 2026

### DEPLOY: fix/toolbox-fixed-width

The Toolbox has one page width again, the full one, because it is read in VS Code's Simple Browser at
about 16:9 and never on a phone. Its Settings page no longer offers Fluid, Phone or Full, and a width
stored while it did is overwritten. A repo's product port keeps the choice: that is where an app is built
for the Simple Browser and a phone alike. This repo's own product gets a Settings page for it, theme and
width, linked from its home page and its menu. It had none since the header's settings button went. The
rule is in the hub's README.

**Score:** 2

#### What makes this deploy extra special

Whoever uses the Toolbox gets one fixed full-width page, with no width setting that does nothing useful
on the screen it is read on.

**Score:** 2

#### Pull Request

The Toolbox keeps one width, so its Settings page no longer offers one

