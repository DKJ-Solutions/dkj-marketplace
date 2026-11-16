## feat/4162-consumer-health-task

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

#4162's second task, decided on the issue (November 16, 2026): the weekly consumer health sweep, as a
versioned prompt in the `scheduled-tasks` skill that #4194 shipped. Read-only on every repo; it files
only findings whose repair lives in this repo, and reports a consumer's own state instead of filing it.

### CREATE

- [x] `tasks/consumer-health-sweep.md`: Monday 07:37 from the dkj-marketplace checkout -- `check-consumers`, BWJ release cadence, unlabelled issues, red scheduled/fold/merge runs
- [x] the skill's task table names it, and its "no task posts" line now names the one tracker it may write to

### TEST

- [x] `place-scheduled-tasks.tests.ps1`: 56 passed, 0 failed, the new file held to the shipped shape
- [x] dry-run placement prints its schedule, cron and folder
- [x] steps 3-5's `gh` commands run against BWJ-Development/xoxowildhearts (tag v1.8.0, its date, its release object, the issue list, the failed-run list)

### DEPLOY: feat/4162-consumer-health-task

Inside this repo nothing changes but the `scheduled-tasks` skill's prompt folder and its task table; no
script, gate or registry moves.

**Score:** 1

#### What makes this deploy extra special

The `scheduled-tasks` skill ships a second kind of task: `consumer-health-sweep`, every Monday at 07:37
from the dkj-marketplace checkout, reads every registered consumer's plugin lag, CI pins, release cadence,
unlabelled issues and red scheduled runs, and reports them in one place, where until now each surfaced
only when a session happened to open the right repo. It files only what the marketplace itself must
repair, after searching its tracker.

**Score:** 3

#### Pull Request

Scheduled tasks: the weekly consumer health sweep

