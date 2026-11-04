## fix/3807-settle-window-rewake

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

- [x] Verify #3807's reason: the settle window refuses the sweep's `workflow_run` wake for the last
  pull request to go green, and the `*/30` schedule arrived every 4 to 8 hours (eight scheduled runs,
  November 2-4, 2026, read back with `gh run list`).
- [x] Direction: the picker waits the remainder of the window out itself and judges the tracker once
  more, rather than re-anchoring the window (which would undo #2393's guard against a live ship).

### CREATE

- [x] `merge-on-green-lib.ps1`: the settle-window refusal carries `SettleRemainingMinutes`; new pure
  `Get-MergeOnGreenSettleWaitSeconds` (longest remainder + 30 s, capped, 0 when anything is eligible
  or nothing is in the window). Mirrored to `plugins/dkj-policy`.
- [x] `pick-merge-on-green.ps1`: `-WaitForSettleSeconds` (default 0, never waits); one pass is a
  function, so the second look re-reads the tracker. Mirrored.
- [x] `merge-on-green.yml`: passes `-WaitForSettleSeconds 660`; the schedule comment's cadence claim
  corrected to what GitHub delivered. The consumer template is unchanged: there a waiting minute is billed.

### TEST

- [x] `merge-on-green-lib.tests.ps1`: 13 new asserts (remaining minutes carried only by the window
  refusal, the wait arithmetic, the cap, the zero cases, the wiring) -- 282 pass, 0 fail.
- [x] The picker runs cleanly with the new parameter (`picked=false`, nothing armed).

### DEPLOY: fix/3807-settle-window-rewake

The merge-on-green sweep no longer leaves the last armed pull request to go green waiting for hours.
Its only wake was its own CI completion, which is exactly when the 10-minute settle window refuses it,
and the `*/30` schedule meant to catch it was delivered every 4 to 8 hours. With the new
`-WaitForSettleSeconds` cap, `pick-merge-on-green.ps1` waits out what is left of the window when that
is the only reason nothing was picked, then judges the tracker once more. This repo's runner passes 660
seconds; the default is 0, and the consumer template does not pass it, so nothing changes there
([#3807](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3807)).

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

merge-on-green: wait out the settle window instead of dropping the last PR's only wake

