## feat/3830-admin-fully-in-shell

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

Move the hub's remaining Admin pages off the product layer (breadcrumbs-bar, site header, page column, card-link overviews) into the desktop shell, and point the fit alarm at the shell's structure (#3830, the open step of #3811). It is the prerequisite of #3831, which moves the product layer out of `dkj-policy`. Product pages (BrandTag `product`) keep their cards.

### CREATE

- [x] `Format-AdminLinkTableHtml` (general-pages-lib): a set of links as one `.table--dense`, from the same fields a card took
- [x] the house's desktop shell gains `.shell__body` (Admin's form of `.page-column`) and `.admin-list` (an `h2` over a `.table--dense`)
- [x] Admin's pages switch: the home page, the GitHub page, every group page, the plugins pages and a plugin's contents, the brand book specimens overview, the SessionStart overview, the test gate, the Stopwatch overview and label pages, the Logbook, and the release notes overview
- [x] a -Bare page that writes its own `h1` into its body has it lifted into the shell's toolbar, centrally in `Format-GeneralPageHtml`
- [x] the fit alarm reads `.toolbar > h1` and the `.shell__bar` trail, and judges the main pane rather than the window
- [x] the product's brand book page keeps its cards (`Get-HouseStyleSpecimensParts -Cards`)
- [x] the brand book README's layer table and the "What is not moved yet" paragraph, and the docstrings that described the cards

### TEST

- [ ] the hub suites (dev-preview-sessionstart, stopwatch, logbook, dev-pages, house-palette and the rest that load hub/lib) updated to the Admin form and green
- [ ] every Admin page served from this branch checked: no `card--link`, `page-column` or `breadcrumbs-bar`, and its one `h1` in the toolbar

### DEPLOY: feat/3830-admin-fully-in-shell

Admin's pages now stand fully in the desktop shell. Wherever a page listed the pages under it as a grid of cards, it now shows one compact table, a row per page with its description, under the section's heading: the home page, the GitHub page, Claude, Performance, the plugins and each plugin's contents, the brand book overview, SessionStart, the Test gate, the Stopwatch and the Logbook, and the release notes. Every page's title sits in the toolbar above the pane. The warning that flags a page that does not fit now reads the shell: the pane's own height, the toolbar's title and the bar's trail. A product's own pages keep their cards.

**Score:** 2

#### What makes this deploy extra special

Anyone who opens Admin after updating sees its overviews as tables instead of cards. Nothing needs to be done.

**Score:** 2

#### Pull Request

Admin pages fully in the desktop shell
