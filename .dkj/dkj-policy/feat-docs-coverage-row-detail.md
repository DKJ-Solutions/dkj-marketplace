## feat/docs-coverage-row-detail

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

The owner asked (November 9, 2026) for a column on /docs-coverage with an icon per row that opens a popup with
more about that row. A visible result, so the branch stops for the owner's look before it merges.

### CREATE

- [x] `docs-coverage-lib.ps1`: a last, unsorted Details column; each row's icon opens one house `.dialog`, filled
      from a `<template>` per row (facts list, idea/why/docs points or note/advice/evidence)
- [x] The page's own layer styles the icon and the popup with house tokens only

### TEST

- [x] `dev-pages.tests.ps1`: the two pinned row shapes take the new cell, and new asserts cover the column, the
      popup content for an item, a declined item, a Not used page and a Covered page, the script and the style
      (727 passed)
- [x] Checked in the browser on http://localhost:4870/docs-coverage: an item and a docs page popup open, Escape closes

### DEPLOY: feat/docs-coverage-row-detail

/docs-coverage has a Details column: an info icon on every row opens a popup that gathers everything known about
that row in one place (its section, group, status, issue and docs link, then the idea, why and the docs check for
an item, or the note, potential, advice and evidence for a docs page), so it reads without hovering the "?" marks.

**Score:** 2

#### What makes this deploy extra special

N/A: the Docs coverage page is this repo's own product page and ships to no consumer.

**Score:** N/A

#### Pull Request

Docs coverage: a details column whose icon opens a popup per row

