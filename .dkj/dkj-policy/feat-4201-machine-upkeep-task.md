## feat/4201-machine-upkeep-task

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

#4162's third proposal, decided on #4201 (November 16, 2026): build the morning machine upkeep only, and
let an unattended run change local state through commands that guard themselves. Proposals 4 and 5 are
not taken up.

### CREATE

- [x] `tasks/machine-upkeep.md`: weekdays 07:17 from the dkj-marketplace checkout -- `update-plugins -AllCheckouts`, `sync-trunk -AllCheckouts`, `tidy-machine -DryRun`, reported in at most fifteen lines
- [x] the skill's task table names it, and a paragraph says it is the one task that changes state, and how far

### TEST

- [x] `place-scheduled-tasks.tests.ps1`: 61 passed, 0 failed, the new file held to the shipped shape
- [x] dry-run placement prints its schedule (`17 7 * * 1-5`), folder and permission hint
- [x] the three commands run from this checkout with `-DryRun`: update-plugins 5 run, 1 skipped (this branch), exit 0; sync-trunk 2 would move, 3 current, 1 skipped, exit 0; tidy-machine exit 0 with 502 items handed over, which is why step 4 reports counts per lane rather than items

### DEPLOY: feat/4201-machine-upkeep-task

Inside this repo nothing changes but the `scheduled-tasks` skill's prompt folder and its page; no script,
gate or registry moves.

**Score:** 1

#### What makes this deploy extra special

The `scheduled-tasks` skill ships `machine-upkeep`: every weekday at 07:17, from the dkj-marketplace
checkout, it updates the plugins in every checkout on the machine, fast-forwards every clean trunk and
reports what `tidy-machine` finds, so the "behind on plugins" and "trunk behind origin" findings are
closed before a working session starts instead of reported in it. It is the first task that changes
state, only locally and only through commands that skip a checkout not clean on its trunk; nothing is
deleted, pushed or published.

**Score:** 3

#### Pull Request

Scheduled tasks: the weekday morning machine upkeep

