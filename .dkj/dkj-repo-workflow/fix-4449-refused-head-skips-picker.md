## fix/4449-refused-head-skips-picker

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

#4449: `Select-MergeOnGreenCandidate` hands over the lowest-numbered eligible pull request, so one that
`ship-pr` refuses for a reason that does not change between sweeps is picked on every sweep, and every
armed pull request above it waits (measured in a consumer: #583 refused five sweeps running, #587 green
and armed for 22h, never tried). Verified before repairing: `ship-pr` already disarms on the refusals it
knows are judgements (#2393: step-list gate, DEPLOY lock, stale CI, a merge refusal from GitHub), but
every other exit 1 leaves the label on, and the picker has no memory of a refusal. The parking comment
asked to design against #4448 first; that issue repairs one refusal's diagnosis, not the starvation, so
this lands on its own and covers any refusal that repeats.

Design: the runner records a non-held refusal against the picked head (a `merge-on-green-refused` label
plus a marker comment carrying the SHA); the picker skips a pull request while both hold for its current
head. A push, a person removing the label, or a session's `ship-pr` re-arming it clears the skip. The
label carries the authority, so a marker comment planted by anybody else skips nothing.

### CREATE

- [x] `merge-on-green-lib.ps1`: `Get-MergeOnGreenRefusedLabel`, `Get-MergeOnGreenRefusalMarker`,
      `Get-MergeOnGreenRefusalComment`, `Get-MergeOnGreenRefusedHead`; `Get-MergeOnGreenPrVerdict` refuses a
      refused head; `Get-MergeOnGreenStuckVerdict` returns `Eligible`; `Get-MergeOnGreenQueueAheadNote`.
- [x] `pick-merge-on-green.ps1`: reads `comments` in its one list call.
- [x] `.github/workflows/merge-on-green.yml`: the ship step writes `ran` and `exit`; a new step records
      the refusal from the trusted trunk, only on an open, still-armed pull request on the refused head.
- [x] `adopt-ci-floor.ps1`: the same step in the consumer scaffold, and a `[refusal]` verdict for an
      existing runner that lacks it.
- [x] `ship-pr.ps1`: lifts `merge-on-green-refused` when it arms again, off the payload it already reads.
- [x] `check-stranded-sweep.ps1`: reads `comments`, and a stuck pull request the sweep would take names the
      lower-numbered one each sweep takes first.
- [x] Plugin mirrors rebuilt (`build-shared-scripts.ps1`).
- [x] `merge-on-green-lib.tests.ps1`: the refused-head verdict, the measured #583/#587 pick, the comment's
      input guards, the queue-ahead note, and the runner step's shape.

### TEST

- [x] `merge-on-green-lib`, `stranded-sweep-gate`, `adopt-ci-floor`, `shared-scripts`, `trusted-tree-seam`,
      `ship-pr-trusted-root`, `unshipped-pr-gate`, `source-repo-guard` and `native-capture` suites green
      locally; the full gate runs under `ship-pr`.

### DEPLOY: fix/4449-refused-head-skips-picker

The merge-on-green sweep no longer re-picks a pull request `ship-pr` refused: the runner marks the
refused head, the picker skips it, and the next armed pull request gets its turn. The session check
names the pull request that holds the queue when a refusal could not be recorded.

**Score:** 3

#### What makes this deploy extra special

A repo running merge-on-green no longer has one refused pull request silently hold back every newer armed
one. An existing `merge-on-green.yml` is not rewritten: `adopt-ci-floor` now prints a `[refusal]` line
for a runner without the new step, and re-running it with `-Apply` after deleting the file places it.
The step labels and comments with `FOLD_PUSH_TOKEN`, which already holds `Pull requests: write`. To
re-arm a refused pull request by hand, remove its `merge-on-green-refused` label.

**Score:** 3

#### Pull Request

Skip a refused head in the merge-on-green picker so it cannot starve the queue

