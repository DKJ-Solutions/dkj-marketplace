## feat/4516-specialist-knowledge-canon

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

#### Scope of this first slice

Layer 1 of #4516 (the shipped canon) for the eight specialists who argue from evidence, plus the
lookup order. The repo store (layer 2) needs no code: the shared block reads it from the repo lens
where one names a store, so a hub names its `Bronnen` database in its own lens. Specialists outside
these eight get a canon page when they first need one.

### CREATE

- [x] Tessa: shared block `knowledge-lookup` (canon, then the store a lens names, then the web; a web find goes back as a store row, a canon-worthy one inbound)
- [x] Tessa: canon pages under `knowledge/` for Rebecca, Marlowe, Uma (alpha), Sebastian, Nolan (developers), Rutger, Hugo, Fiona (lifehub)
- [x] build-agent-defs: block placed in those eight agent defs
- [x] Tessa: Rutger's manual puts the canon before the hub library; the teams README describes `knowledge/` and lists the nineteenth block

### TEST

- [x] build-agent-defs generated the block in all eight defs
- [x] Gates green through open-pr

### DEPLOY: feat/4516-specialist-knowledge-canon

Eight specialists now ship with a canon of their craft: Rebecca, Marlowe and Uma in the core team,
Sebastian and Nolan in the developers team, and Rutger, Hugo and Fiona in the life-hub team. Each canon
is a short page beside the manual listing the sources that define the field, each with a one-line key
finding and a grade (A, B or C). The specialist reads it on demand at the start of a task, so it costs
nothing on turns that do not need it. Before searching the web, these specialists now look in three
places, in order:
- their own canon;
- the source store the repo's lens names, if it names one (a life hub's `Bronnen` database, for example);
- the web, citing only sources they opened.

A web find worth keeping comes back with the deliverable as a row for that store. A source that belongs
in the canon itself arrives through an inbound issue.

**Score:** 2

#### What makes this deploy extra special

The first answer of a research, security, UX, performance, behavioural, lifestyle or financial
specialist now starts from the strongest sources of its field instead of a fresh web search, and a
search done once can be reused by the next session.

**Score:** 3

#### Pull Request

Eight specialists ship a canon of their craft and look it up before the web
