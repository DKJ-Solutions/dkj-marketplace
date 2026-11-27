## feat/4511-rutger-sourced-mechanisms

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

### CREATE

- [x] Tessa: def working method (library first, then lookup; claim shape; alternative), web tools allowed, webcontent block
- [x] Tessa: manual's evidence rules (library first, source opened, status, private queries, competing explanation)

### TEST

- [x] build-agent-defs generated the shared block; plugin integrity 0 errors
- [x] Gates green through open-pr

### DEPLOY: feat/4511-rutger-sourced-mechanisms

Rutger, the life hub's Behavioral Analyst, now grounds the explanation half of a conclusion in the
literature rather than in model memory, and keeps what he finds. He reads the hub's mechanism library
first. That library has one page per mechanism, with its sources, its evidence status and the date it
was last checked. He searches the web only when a page is missing, more than 12 months old or marked
contested, and never with the person's data. After a search he delivers the new page for Ian to
place. Each pattern he reports has the same shape:
- the observation, with its data points;
- the mechanism, with a source he opened and its status (established, mixed or contested);
- at least one competing explanation;
- a confidence level.

**Score:** 2

#### What makes this deploy extra special

A life-hub user can check every explanation Rutger gives against its source, and sees how solid the
underlying research is. Research done once stays in the hub's library instead of being repeated.

**Score:** 3

#### Pull Request

Rutger grounds each mechanism in a source he opened

