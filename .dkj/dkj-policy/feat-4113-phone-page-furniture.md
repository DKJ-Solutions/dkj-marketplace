## feat/4113-phone-page-furniture

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

Cause 4 of #4113: page furniture the mobile wireframes do not have

### CREATE

- [x] `house-product.css`: below 48rem the h1's "?" leaves with the h1 (both of the h1's conditions, the Phone
      width included), `main > .page-source` is hidden, and a `.tiles` row is one card of rows of about 52px, label
      left and figure right with a hairline between. A wide screen is unchanged
- [x] `product-pages-lib.ps1`: the footer note carries `.page-source` beside `.note`
- [x] The product README names the three under "On a phone"

#### Not in this branch

Causes 1 to 3 of #4113 are #4118 (merged) and `feat/card-grid-rows-on-phone` (parked for the owner's look). Cause 5
is the report pages `/consumers/bwj` and `/consumers/other`, which no wireframe covers yet, and `/docs-coverage`,
which is #4111.

### TEST

- [x] `dev-pages.tests.ps1`: the `.page-source` class on the footer note, and the phone rule's shape, tokens only
      but the hairline; the shell's footer assert follows the new class
- [x] `consumer-dashboard`, `dev-preview-sessionstart`, `stopwatch` suites green
- [x] Seen at phone width (headless Chrome, 500px, its narrowest): `/plugins/dkj-policy` (no lone "?", no source
      note) and `/plugins/dkj-subagents/dkj-subagents-alpha/rebecca` (the five figures as one card of rows)

### DEPLOY: feat/4113-phone-page-furniture

On a phone a product page no longer shows a lone "?" at the top left or a long note of source paths at its foot,
and a row of figure tiles, such as a specialist's token costs, reads as one card of compact rows. That matches the
mobile wireframes. A wide screen is unchanged.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

On a phone, no lone '?', no source note, and the stat tiles as one card of rows

