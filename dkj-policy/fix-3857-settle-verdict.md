## fix/3857-settle-verdict

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

Inbound #3857, verified against the tree: the template's picker line carries `-WaitForSettleSeconds 660`
since #3810, `pick-merge-on-green.ps1` defaults it to 0, `adopt-ci-floor` never rewrites an existing
runner, and none of its four existing-runner verdicts reads the flag. The issue's first direction, a
fifth verdict, is the repair. The wider "compare against the template's line set" direction is not
taken: the consumer's own deliberate bridges (smartwatchbanden's missing `schedule:`) would read as drift.

### CREATE

- [x] `Write-MergeOnGreenSettleVerdict` in `adopt-ci-floor.ps1` (both copies): silent when the picker line
  carries the flag, `[settle]` with the line to add when it does not, unread when no picker line exists.
- [x] The `adopt-dkj-policy` skill names the `[settle]` line beside `[shape]`.

### TEST

- [x] `adopt-ci-floor.tests.ps1`: a current runner draws no `[settle]`, a pre-#3810 picker line draws it,
  the same line with the flag draws none, and a hand-written file is reported unread.

### DEPLOY: fix/3857-settle-verdict

A merge-on-green runner placed before #3810 kept the settle-window gap indefinitely, and nothing said so:
a re-run of `adopt-ci-floor` judged it fine, and moving its `ref:` pin did not help, because the wait is
a YAML flag. A re-run now names such a runner under `[settle]`, with the flag to append
([#3857](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3857)).

**Score:** 2

#### What makes this deploy extra special

A repo that adopted merge-on-green before #3810 sees a `[settle]` line the next time it re-runs
`adopt-ci-floor`. Appending `-WaitForSettleSeconds 660` to the picker line stops the last pull request
to go green from waiting hours for the schedule.

**Score:** 3

#### Pull Request

adopt-ci-floor: report an existing merge-on-green.yml whose picker lacks -WaitForSettleSeconds

