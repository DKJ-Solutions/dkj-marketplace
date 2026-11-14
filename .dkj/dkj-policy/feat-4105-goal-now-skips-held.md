## feat/4105-goal-now-skips-held

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

- [x] Owner's decision (November 14, 2026): a Now another sweep is on advances the sweep's Now, like a parked one (#4105).

### CREATE

- [x] `Get-GoalTreeSkips` takes `-InFlightNumbers` and walks past them; the reason names each passed task as parked or held.
- [x] `claim-issue.ps1 -Candidates` reads the `held` and `branch` verdicts in one pure pass before the goal walk, never `mine`.
- [x] Both mirrors, and the `issues-sweep` skill paragraph.

### TEST

- [x] `claim-issue.tests.ps1`: a held Now advancing, parked then held, all parked or held, a held task behind a free Now, an unplanned milestone still stopping the walk, the sweep verdicts, and the script wiring -- 690 passed, 0 failed.
- [x] Live `-Candidates` on goal #4081: `Now is #4088 (#4085 parked, #4086 parked, #4087 held)`, 1 free.

### DEPLOY: feat/4105-goal-now-skips-held

Inside this repo, a second sweep beside a running one now takes a plan-goal's next task instead of reading `0 free` while the other sweep holds the goal's Now: goal #4081 read `0 free` because #4086 was claimed by another machine two minutes earlier.

**Score:** 3

#### What makes this deploy extra special

Two sweeps can now work one plan-goal at once: when the goal's Now is claimed by another sweep, or has a branch pushed for it, `issues-sweep` takes the next task in order, and its reason names what it passed (`Now is #4088 (#4085 parked, #4086 parked, #4087 held)`). Each sweep still takes one task per goal; a task that depends on the one before it can now be built early.

**Score:** 3

#### Pull Request

issues-sweep: a plan-goal Now claimed by another sweep no longer blocks the goal's next task

