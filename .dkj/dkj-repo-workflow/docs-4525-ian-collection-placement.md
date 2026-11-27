## docs/4525-ian-collection-placement

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

Inbound #4525: a consumer hub added a collection page with one database per kind of collection. Ian's
manual carries the placement rule so it does not live only in that consumer's conventions page. The
owner's addition on the issue: a collection row is not an Update. The catalog rule (#4503) pointed a
list of liked films at the taste dossier; that pointer is replaced.

### CREATE

- [x] Ian's manual (04-03): new rule "a collection item is a row, never a dossier" after the catalog
  rule, with the item-in-a-series test, columns instead of a page tree, mood as a multi-select column,
  a new kind as a new database, catalog vs. collection, and rows are not Updates.
- [x] Ian's manual: the catalog rule's taste-dossier pointer now points to the collection.
- [x] Ian's def: one line with the test and the not-an-Update clause.

### TEST

- [x] `grep -n "taste" plugins/dkj-subagents/dkj-subagents-lifehub` returns no remaining pointer to the
  taste dossier for item lists; the generated blocks in the def are untouched. ship-pr runs the gates.

### DEPLOY: docs/4525-ian-collection-placement

The life hub's information architect, Ian (04-03), places one item out of a series of similar items (a
track, a film, a trip) as a row in a per-kind collection database rather than as a dossier, groups by
columns rather than by a page tree, opens a new database for a new kind of collection, and does not
log a row as an Update. What the owner has watched or done no longer goes to the taste dossier.

**Score:** 2

#### What makes this deploy extra special

A life-hub user whose hub keeps a collection page gets tracks, films and trips filed as rows there,
instead of as dossiers that bury the topics with a narrative.

**Score:** 2

#### Pull Request

Ian places collection items as rows in per-kind Collection databases

