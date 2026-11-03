## fix/3766-trunk-sync-cli-diagnostics

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

#3766: the sync-trunk.ps1 single-checkout case failed once under the parallel test gate and passed alone. The issue's cause (a shared temp path, a git lock, the fetch, a timing window) is inferred, not measured. Not reproduced on November 3, 2026: 12 parallel runs of the suite under load, and 6 more with the gate's environment (`GIT_TERMINAL_PROMPT=0`, `GCM_INTERACTIVE=never`, `DKJ_TEST_GATE_DEPTH=1`, a foreign working directory), all 53/53. So this branch repairs nothing it cannot see: it makes the next failure say why. The issue stays open, parked `awaiting-recurrences-first`.

### CREATE

- [x] `trunk-sync.tests.ps1`: when the single-checkout `sync-trunk.ps1` run exits non-zero, the suite prints that child's own output (it was captured and discarded before), so its `Write-SyncLine` names the outcome and the git detail (a fetch timeout, a refused fast-forward, an exception)

### TEST

- [x] the gates run inside `ship-pr`

### DEPLOY: fix/3766-trunk-sync-cli-diagnostics

When the `sync-trunk.ps1` single-checkout case in `trunk-sync.tests.ps1` fails, the suite now prints what that script said, not just the three red asserts. It failed once under the parallel test gate (#3766) and could not be reproduced in 18 runs, so the next failure will name its own cause.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

trunk-sync.tests: print sync-trunk.ps1's own output when the single-checkout case fails

