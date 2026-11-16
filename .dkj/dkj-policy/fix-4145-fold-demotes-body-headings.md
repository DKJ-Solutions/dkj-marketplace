## fix/4145-fold-demotes-body-headings

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

Issue #4145 offered two fixes. This branch takes the first one, in the fold, because the fold is the one place
every repo's entries pass through, whatever gate that repo runs. A refusal at `open-pr` would also have to reach
repos that open PRs outside it.

### CREATE

- [x] `Limit-EntryBodyHeadings` in `entry-scaffold-lib.ps1`: a pure, fence-aware function that demotes every body heading at or above the entry's level to one level below it
- [x] `fold-changelog-entry.ps1` calls it after the re-level and names how many headings it demoted
- [x] Mirrors under `plugins/dkj-policy/scripts/` kept byte-identical

### TEST

- [x] `entry-scaffold.tests.ps1`: the H2 and the H3 inside the body are demoted; the entry's own heading, a section already below it and a fenced example stay where they are
- [x] `fold-changelog.tests.ps1`: a real fold of a body carrying an H2 and an H3 lands as one entry with both headings as sections, and the fold says what it demoted

### DEPLOY: fix/4145-fold-demotes-body-headings

Inside this repo, `fold-changelog-entry.ps1` runs every folded entry through a new `Limit-EntryBodyHeadings`
([#4145](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4145)). Any heading in the entry's body at or
above the entry's own level becomes a section one level below it, and the fold prints how many it moved.

**Score:** 2

#### What makes this deploy extra special

In a repo that has taken this update, a `##` heading written inside a DEPLOY section can no longer close
`## [Unreleased]` at the fold and hide the entries below it from the next cut. Measured in a consumer, the cut saw
2 of 31 pending entries. A `###` there no longer splits one change into two entries either. The fold demotes such
headings and names the document to repair.

**Score:** 3

#### Pull Request

The fold demotes headings in a DEPLOY body that would close [Unreleased] or split the entry

