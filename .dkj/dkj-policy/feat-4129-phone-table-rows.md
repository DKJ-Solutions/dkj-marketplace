## feat/4129-phone-table-rows

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

#4129: a brand book pattern that stacks a table's rows on a phone instead of scrolling sideways, with no markup per table.

### CREATE

- [x] `house-style.css`: `.table-wrap--stack`, a container query on the wrap; below 48rem each row is a block, the
      first cell its heading, every other cell its `data-label` over its value, the head row kept for a screen reader
- [x] `house-theme.js`: copies each column head's text onto the body cells as `data-label` (colspan-aware; a cell
      that has one keeps it)
- [x] The core README's "A table on a phone: rows as blocks", and a specimen card under Tables
- [~] The owner's look at the specimen at phone and wide width. Not done as a separate look: DaveKJohn
  approved the branch through issues-sweep-reviews on 2026-11-15 without one.

### TEST

- [x] Seen in headless Chrome: the Tables specimens at 390px (the new card stacks, labels filled by the script) and at
      1300px (the ordinary table)

### DEPLOY: feat/4129-phone-table-rows

A table of sentences can now stack on a phone: wrap it in `.table-wrap--stack` and each row becomes a block, its
first cell the heading and every other cell its column's name over its value, with no markup per table, so a rendered
markdown table takes it too. Wider than 48rem it stays the ordinary table, and a table without the class is unchanged.

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Brand book: a phone pattern for tables (rows as stacked blocks)

