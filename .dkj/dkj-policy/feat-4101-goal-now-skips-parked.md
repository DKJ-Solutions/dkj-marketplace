## feat/4101-goal-now-skips-parked

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

- [x] Owner's decision (November 14, 2026, in session): a parked plan-goal Now advances the sweep's Now to the next open task in order (#4101).

### CREATE

- [x] `Get-GoalTreeSkips` takes `-ParkedNumbers` and walks past parked tasks to the first unparked step; an unplanned milestone still stops the walk.
- [x] `claim-issue.ps1 -Candidates` hands it the numbers this run skips by a parking label, read with the same skip list.
- [x] Mirrors under `plugins/dkj-policy/scripts/` synced; the `issues-sweep` skill page says it.
- [~] `plan-goal -Next` left unchanged: that view is the owner's, and the owner's next step on a parked Now is still the look.

### TEST

- [x] `claim-issue.tests.ps1`: a parked Now advancing, every task parked, a parked task behind an unparked Now, no parked numbers, and the sweep path end to end -- 683 passed, 0 failed.
- [x] Live `-Candidates` on this tracker: `goal #4081's Now is #4086 (#4085 parked)`, where it read 0 free before.

### DEPLOY: feat/4101-goal-now-skips-parked

Inside this repo, the sweep walks a plan-goal past a task parked for the owner's look instead of stopping the whole goal at it: goal #4081 read `0 free` for every sweep while its Now waited on a review.

**Score:** 3

#### What makes this deploy extra special

A consumer sweeping a goal tree no longer stalls on a task that waits for the owner: when a goal's Now carries a parking label, `issues-sweep` takes the next task in order instead, and its reason names what it passed (`Now is #4086 (#4085 parked)`). One task per goal is still free at a time; `plan-goal -Next` still shows the goal's own Now.

**Score:** 3

#### Pull Request

issues-sweep: a parked plan-goal Now no longer blocks the goal's next task

