## feat/product-width-bar

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

A thin bar above the site header on the product pages (port 4870-4879), with full, fluid and phone as
small icons, as VS Code's title bar holds its layout toggles (Dave, November 4, 2026). The Toolbox stays
fixed on full and gets no bar. Visible result: stops for the owner's look before the PR.

### CREATE

- [x] Brand book: `DKJTheme.widthBar(el, opts)` in `house-theme.js` and `.width-bar` in `house-style.css`
- [x] Product pages: the bar opens `<body>` on the consumer pages and the product home; their settings call drops its width group
- [x] Brand book README: the width bar paragraph

### TEST

- [x] `consumer-dashboard` and `dev-pages` suites: the body-order asserts now expect the bar first, green
- [x] `check-house-style` gate and `house-palette` suite green
- [x] Owner's look at the product on http://localhost:4871/ (Dave: "ja nice ship it")

### DEPLOY: feat/product-width-bar

The brand book gains a width bar, `DKJTheme.widthBar(el)`: a thin strip above the site header holding
full, fluid and phone as three small icon buttons. This repo's product pages (the home and the
consumer pages) open with it, so the page width is one click away again; the Toolbox stays on full.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that takes the next brand book copy can offer its users the width as a one-click
bar instead of a setting inside the gear panel.

**Score:** 2

#### Pull Request

Product pages: a thin width bar above the site header

