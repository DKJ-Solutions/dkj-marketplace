## fix/4479-fold-standdown-retry

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

On the fold's exit 2 (the trunk moved under the checkout), `fold-on-merge` stood down green on the claim
that the push that moved the trunk has its own run. A lone `fold:` push is skipped by the job's `if:`, so
that run never comes and the leftovers stay on the trunk (#4479, measured in a consumer: 12 found, 11
stranded). Retry on the moved trunk instead, bounded, and go red if leftovers are still in hand.

### CREATE

- [x] `.github/workflows/fold-on-merge.yml`: on exit 2, up to 3 times: `git fetch origin main`,
  `git merge --ff-only origin/main`, re-run the check; stand down green only when the re-read finds no
  leftover, otherwise fold again. Code 2 still left after the loop exits 1. Header and step comments
  rewritten to the new ground.
- [x] The same change in the consumer template (`scripts/task/adopt-ci-floor.ps1`, trunk and plugin
  path parameterised) and its byte-identical plugin mirror.
- [x] `adopt-ci-floor`, `workflow-concurrency` and `fold-changelog` suites updated to the new contract:
  the bounded retry, no `reset --hard`, exit 1 on a trunk that keeps moving, code 3 still the one
  stand-down on a fold exit code.

### TEST

- [x] The three changed suites pass standalone (344, 40 and 306 asserts); the full gate runs in `ship-pr`.

### DEPLOY: fix/4479-fold-standdown-retry

When ship-pr pushed its own `fold:` commit right after a merge, the fold-on-merge runner for that merge
stood down and left every other pending entry on the trunk unfolded, while reporting green. The runner
now catches up with the moved trunk and folds what is still there, and fails red if it cannot.

**Score:** 3

#### What makes this deploy extra special

Repos that take the CI floor get the fix the next time `adopt-ci-floor` places or refreshes their fold
runner. Until then, leftover changelog entries can still pile up after a ship and need folding by hand.

**Score:** 2

#### Pull Request

fold-on-merge retries a stood-down fold on the moved trunk instead of counting on a run a fold-only push never starts

