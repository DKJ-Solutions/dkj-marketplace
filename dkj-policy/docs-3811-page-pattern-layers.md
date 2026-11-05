## docs/3811-page-pattern-layers

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

Step 2 of #3811, built on `feat/3815-toolbox-to-admin` (merged in, so it lands after #3815 and uses its names: Admin, `.nav-list`, `admin-shell.html`): assign the seven rules the desktop-shell review listed to a layer, by Dave's criterion
of November 5 (managing goes to Admin, using to the product). The hub's own move (its card overviews
and fit alarm) is step 3 and is not on this branch.

### CREATE

- [x] README "Two layers": the criterion, and a table assigning each rule (h1 size, breadcrumb bar, site header, card shapes, touch target, page width) to a layer
- [x] README "Page patterns" and "Every page: the breadcrumb bar": say they are the product's, and where the shell's trail sits
- [x] README "Components": reserve the shell's classes; scope the 44px target to the product and the core
- [x] README "App components": correct where the part sits in `house-style.css`
- [x] `house-style.css`: a `.sort` header in a `.table--dense` takes the row height as its hit area, not 44px
- [x] `patterns/admin-shell.html` (`toolbox-shell.html` until #3815): mount the settings with `widths: false`, as the hub already does

### TEST

- [x] Integrity lint green locally (0 errors)
- [~] Lint and test gate green: dropped as a step, because open-pr runs it itself before the push
- [x] Owner's look: Dave said "open de pr" after the desktop-shell preview (November 5, 2026)

### DEPLOY: docs/3811-page-pattern-layers

The brand book's README now says which of its rules belong to Admin's desktop shell and which to the
mobile-first product, by the task a feature serves rather than the device: the breadcrumb bar, the site
header, the card overviews, the 44px target and the page width are the product's, while the page-name and
one-`h1` rules hold in both. The shell's classes are reserved by name, and a sortable header in a dense table
no longer reaches its hit area over the rows under it.

**Score:** 3

#### What makes this deploy extra special

An app building a management screen in the desktop shell now knows which brand-book rules it can drop (the
bar, the cards, the 44px target) without breaking the house style, and which still hold.

**Score:** 2

#### Pull Request

Assign the brand book's page-pattern rules to the Admin or the product layer

