## feat/4289-live-direct-writes-in-shopify

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

Step 3 of 3 of [#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289): `live-direct-writes`
and its scheduled workflow move into `dkj-subagents-shopify`. The workflow is placed by
`adopt-shopify-floor`, only where `Get-ShopifyLiveDeployBranch` is answered. It follows the write-runner
mechanism of `adopt-ci-floor`: it checks out this marketplace pinned to a release SHA and runs the plugin
script from there. This closes #4289.

### CREATE

- [x] `scripts/task/live-direct-writes.ps1` and `scripts/lib/live-direct-writes-rules.ps1`, in English, with no store facts
- [x] `adopt-shopify-floor` places `.github/workflows/live-direct-writes.yml` when it is absent and the
  deploy-branch seam is answered. The branch and the `-Since` floor are baked in at placement.
- [x] `skills/live-direct-writes/SKILL.md`, the README rows, and pointers from `adopt-shopify-floor` and `live-preflight`
- [x] `scripts/tests/shopify-live-direct-writes.tests.ps1`, plus 24 new asserts in `adopt-shopify-floor.tests.ps1`

### TEST

- [x] `shopify-live-direct-writes` 50/0, `adopt-shopify-floor` 61/0, `exception-message-guard` 18/0
- [x] `check-plugin-integrity.ps1` 0 errors, and `build-shared-scripts.ps1 -Check` in sync
- [x] The full gate runs in `ship-pr`

### DEPLOY: feat/4289-live-direct-writes-in-shopify

Ships the `live-direct-writes` skill in `dkj-subagents-shopify`. On a schedule, it reads the branch a
Git-connected live theme deploys from. A `shopify[bot]` commit whose body carries `Changed by:` is a CLI
push or a code-editor save that bypassed the branch flow. The check opens one issue labelled
`live-direct-write` for every set of new ones it finds. `adopt-shopify-floor` now places the workflow
that runs it, but only in a store that answers `Get-ShopifyLiveDeployBranch`. The workflow is pinned to
the plugin's release, so it runs once a release that contains this script exists. Closes
[#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289).

**Score:** 3

#### What makes this deploy extra special

A Git-connected store gets a signal for the one route to its live theme that no guard can stop: a push
from a shell that never loaded the harness. Re-run `adopt-shopify-floor` to place the check. A store that
already runs its own copy keeps it: the label and the dedupe marker are unchanged, so passing its current
floor as `-LiveDirectWritesSince` means nothing gets reported twice.

**Score:** 3

#### Pull Request

Move live-direct-writes and its workflow into dkj-subagents-shopify
