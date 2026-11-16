## docs/4139-storage-neutral-brain

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

- [x] inbound checks: the folder-tree assumption stands, mostly in Ian's and Onyx's subagent definitions (`Brains/plutchik-brain/`, "NEURON.md files") and four lines of Ian's manual; Onyx's manual is already neutral
- [~] parts 3 and 4 of the proposed repair collapse: the hand-off chain already says "the brain", and `INPUT.md`, `HIPPOCAMPUS.md`, `CORTEX.md` and `ELEMENT.md` appear nowhere in the source
- [x] part 5 (no branch for an external update) is written as "the lens says how an entry there is written", since the branch rule governs the repo and the owner's constitution is not this plugin's to relax

### CREATE

- [x] `specialist-04-03-subagent.md`: the lock and the placement rule name where the brain lives through the lens (files or an external workspace); hierarchy is a parent/child relation; an entry carries its half and emotion tags
- [x] `specialist-04-04-subagent.md`: Onyx works in the connection layer, stored as the lens says (`NEURON.md` files or relations between entries), with the reason per link beside it
- [x] `specialist-04-03-manual.md`: place, navigation and index rule are storage-neutral

### TEST

- [x] no `Brains/` path and no folder-only placement rule left in the lifehub plugin's manuals and subagents

### DEPLOY: docs/4139-storage-neutral-brain

Ian and Onyx in `dkj-subagents-lifehub` no longer assume the knowledge base is a folder tree in the repo
([#4139](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4139)): where the brain lives, how its entries
are placed and how its links are stored are what the consumer's lens names, files in the repo or an external
workspace.

**Score:** 2

#### What makes this deploy extra special

A life-hub whose knowledge base has moved out of git, into an external workspace, can drop the temporary
section its Ian and Onyx lenses carried: the two specialists read the location and the link format from the
lens instead of looking for `Brains/` and `NEURON.md` files.

**Score:** 2

#### Pull Request

Lifehub: Ian and Onyx no longer assume the knowledge base is a folder tree

