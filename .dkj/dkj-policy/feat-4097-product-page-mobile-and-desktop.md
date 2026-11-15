## feat/4097-product-page-mobile-and-desktop

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

#4097, the last sub-issue of #4092 (goal #4081). The design source is the Figma frame "List (desktop)" and the
Notes frame on Wireframes · Product (section 83:558), approved on #4088: a 640 main column and a 320 sidebar on a
computer, and the mobile rules (title once, no card in a card, compact ~52px rows, empty messages dropped, theme
colour as an accent). #4094-#4096 landed first, so the bottom bar, the full-screen menu, the sheets, the status card
and the error state are already in the layer.

### CREATE

- [x] `house-product.css`: `.page-layout` (main column + sidebar, stacked below 48rem and at the Phone width),
  `.card--rows` (compact rows in one card) and the phone rule that takes the `h1` off the screen under a header
  with a back cell.
- [x] `patterns/product-page.html` rebuilt to the desktop frame: h1, search, filter chips, rows; sidebar with the
  status card and card links.
- [x] Specimens: "Rows in one card" and "Main column and sidebar" under Navigation and shell.
- [x] Product README: "The product page: the phone rules and the computer layout".

### TEST

- [x] Gates: `check-house-style` OK; `house-style-css` syntax, vars and colour literals OK.
- [x] By eye, headless Edge: the pattern at 1280 matches the Figma desktop frame; at phone width the title stands
  once in the header, the breadcrumb bar is gone, the rows are compact and the sidebar stacks under the column.
  The specimens render at `/plugins/dkj-policy/dkj-brandbook/nav` on the product server.
- [ ] The owner's look (a visible result).

### DEPLOY: feat/4097-product-page-mobile-and-desktop

Inside this repo, the product layer's page pattern follows the approved desktop wireframe, its specimens show the
row list and the page layout, and its README lays down the phone rules.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product page now has one shape on both screens: on a computer a main column with a sidebar beside
it (`.page-layout`), on a phone one column with its title once, in the header. A list is one card of compact rows
(`.card--rows`) instead of a card per item.

**Score:** 3

#### Pull Request

