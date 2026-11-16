## fix/4198-merge-on-green-redispatch

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

Option B, as decided on #4198 by the owner (November 16, 2026): on ship-pr's held-merge refusal the
merge-on-green runner re-dispatches itself, with a bound.

### CREATE

- [x] `merge-on-green-lib.ps1`: `Get-MergeHeldExitCode` (75, EX_TEMPFAIL) and the pure
  `Get-MergeOnGreenRedispatchVerdict` (retry counter, 5/10/15-minute waits, at most three retries,
  workflow and branch read off `GITHUB_WORKFLOW_REF`)
- [x] `ship-pr.ps1`: the #3802 held-merge refusal exits 75 instead of 1; every other refusal keeps 1
- [x] `.github/workflows/merge-on-green.yml`: a `retry` dispatch input, a `held` output from the ship
  step, a plan step in the trusted tree, and a checkout-free `redispatch` job with `actions: write` alone
- [x] `adopt-ci-floor.ps1`: the same in the consumer template, plus a `[redispatch]` advisory for a
  runner placed before it
- [x] plugin mirrors of the three shared scripts

### TEST

- [x] `merge-on-green-lib.tests.ps1` and `adopt-ci-floor.tests.ps1` green locally; the full gate runs
  in ship-pr. The runner itself is proved only by its first held merge after the merge, like every
  workflow_run runner here.

### DEPLOY: fix/4198-merge-on-green-redispatch

When GitHub answers a merge with a 5xx and does not confirm it within a minute, `ship-pr` now exits 75
instead of 1 ([#4198](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4198)). The merge-on-green
runner reads that code and wakes its own next sweep: it waits 5, 10 and then 15 minutes, and dispatches
itself again with a retry counter, at most three times. It used to wait for a CI completion or a schedule
that, after a 5xx, does not come. The dispatch runs in a job of its own, which holds `actions: write` and
checks nothing out. `adopt-ci-floor` places the same job in a consumer's runner and flags an existing
runner that lacks it with `[redispatch]`.

**Score:** 2

#### What makes this deploy extra special

An armed pull request whose merge hit a server error now lands within about half an hour on its own.
Before this, it sat green until someone shipped it by hand: on November 16 that took over an hour, for
two pull requests. A consumer gets this by re-placing its merge-on-green runner. Moving the `ref:` pin
alone does not add the new job.

**Score:** 3

#### Pull Request

merge-on-green: re-dispatch the sweep after a held merge

