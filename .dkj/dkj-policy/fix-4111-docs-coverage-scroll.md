## fix/4111-docs-coverage-scroll

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

#### The reported cause did not hold

#4111 read the overflow as a table with no scrolling container. The table already sat in a `.table-wrap`
(`overflow-x: auto`), and at 375 px it did scroll inside it (343 px wide, 1316 px of content). What widened
the page was the `.sr-only` "Details" column head: absolute, and with no positioned ancestor before `<body>`,
so the wrap's overflow never clipped it, and its static position at the table's right edge (x = 1322) set the
document width. Hiding that one span brought `scrollWidth` to 375; `overflow: hidden` on the wrap did not,
while `contain: paint` did.

### CREATE

- [x] `.table-wrap` gains `position: relative` in `house-style.css`, so it is the containing block of what is
  absolute inside it and its scroll clips that too. The Consumers group pages had no such span, which is why
  theirs never overflowed.

### TEST

- [x] Measured in headless Chrome at a 375 px mobile viewport, fresh profile: `/docs-coverage` 1322 → 375
  (`.table-wrap` 343 wide, 1316 of content, scrolling), `/consumers/bwj` and `/consumers/other` stay 375,
  `/consumers` and `/` stay 375, and the fit alarm stays hidden.
- [ ] The owner's look: `/docs-coverage` on a phone, the page at screen width and the table scrolling sideways
  inside its own box.

### DEPLOY: fix/4111-docs-coverage-scroll

A wide house table no longer widens the whole page on a phone. Its scroll container, `.table-wrap`, is now
the containing block of what is positioned inside it, so a visually hidden column head at the table's far
edge (the Docs coverage page's Details column) is clipped with the rest of the table instead of setting the
document's width. On the product's `/docs-coverage` at 375 px the page measured 1322 px wide and now measures
375, with the table scrolling inside its own box (#4111).

**Score:** 3

#### What makes this deploy extra special

Any page in a consuming repo that puts a `.sr-only` element, or anything else absolute, inside a wide
`.table-wrap` stops scrolling sideways as a whole on a phone once it takes this brand book.

**Score:** 2

#### Pull Request

A wide table's hidden column head no longer widens the page on a phone

