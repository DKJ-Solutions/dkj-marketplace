## feat/4513-bronnen-library

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

Inbound #4513: a life hub keeps external evidence in a source library beside the dossiers. Carry
its four rules into the manuals of the specialists who place, link or look up sources, written
generically and conditional on the hub keeping such a library.

### CREATE

- [x] Rutger (03-33): a source he opened is delivered as one library row linked to the dossier;
  evidence status stays on the mechanism page, GRADE strength on the source row; library lookup
  before the web.
- [x] Ian (04-03): the brain/library placement test, one source one row, citing through the
  relation, kept distinct from the reference-catalog rule (#4503).
- [x] Onyx (04-04): a source is not a neuron.
- [x] Hugo (03-14), Fiona (03-08) and Rebecca (alpha 03-07): look up the source library before
  searching the web.

### TEST

- [x] Read the diff: every addition carries `(#4513)`, names no consumer or person, and is
  conditional on a hub keeping a source library; Rutger's mechanism-library rule (#4511) is kept and
  reconciled rather than replaced.

### DEPLOY: feat/4513-bronnen-library

The life-hub specialists now keep external evidence apart from the dossiers, where a hub keeps a
source library. A paper, study, guideline or textbook becomes one row in that library, never a
dossier. What it means for the person goes into the dossier as an update, citing the row through
the relation. Ian places sources by asking whether a thing is about the person or about the world.
Onyx lays no links to or between sources. Rutger delivers each source he opened as a row: the GRADE
strength of that single source sits on the row, and the evidence status of the mechanism stays on the
mechanism page. Rutger, Hugo and Fiona look a source up in the library before searching the web. So
does Rebecca, when she researches for a hub.

**Score:** 2

#### What makes this deploy extra special

A life-hub user finds a source once and every specialist reuses it, instead of each one searching
the web again for evidence another already found.

**Score:** 3

#### Pull Request

Life hub: keep external evidence in a separate library, apart from the brain

