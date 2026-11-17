## feat/4233-issues-sweep-split

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

#4233: `/usage` put 32% of a week's local usage on `issues-sweep`. Measured with `measure-skill`
(installed v6.18.0): always-on **0** (`disable-model-invocation`), on-invoke **~12,200** tokens. The
body stays in context for every turn of a sweep's loop, so the lever is the on-invoke body. Of the
issue's three options: split by step (done), move mechanics into the scripts (done where the script
already had it: `-SkipLabel`'s default is the exact list step 1 typed out), and a cheaper `model:`
(not done here -- a sweep builds and judges in the main loop, so a model downgrade is a quality
trade for the owner; filed as #4240).

### CREATE

- [x] Split `issues-sweep/SKILL.md` (35,051 B) by when each part is needed: the loop stays (13,697 B,
  -61%); the step-1 states and goal-tree reading move to `candidates.md`, parking to `parking.md`, the
  claim's refusals / `-TakeOver` / `-ReleaseAll` / tag parts to `claiming.md`, lane mode to
  `lane-mode.md`, and the measurements behind steps 4, 5 and the close-out to `why.md`. Text moved
  verbatim; the loop page carries a table naming when to read each page.
- [x] Step 1 runs `claim-issue.ps1 -Candidates` bare: its `-SkipLabel` default is the same 25-label
  list (pinned by `claim-issue.tests.ps1`), so the page no longer types it out.
- [x] `claim-issue/SKILL.md`'s sentence on how the sweep chooses names the default instead.

### TEST

- [x] No text lost: every sentence of the old page (248) is present in the new set of pages, bar 15
  deliberate rewordings, each read by hand.
- [x] Every relative link on the six pages resolves.

### DEPLOY: feat/4233-issues-sweep-split

The `issues-sweep` skill page was split into a loop page and five pages beside it, and step 1 relies
on `claim-issue`'s own `-SkipLabel` default (#4233).

**Score:** 1

#### What makes this deploy extra special

A sweep now loads a 13.7 KB loop page instead of a 35 KB one (~12,200 tokens measured before; ~4,800
estimated after, at the measured bytes-per-token of the old page), and that body is carried through
every turn of the sweep. What applies only to one case (a `stale-park`, a refused claim, a lane, a
park) sits on its own page beside it, read when that case comes up (#4233).

**Score:** 2

#### Pull Request

issues-sweep: load only the step in hand

