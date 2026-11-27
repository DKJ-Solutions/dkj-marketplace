## fix/4529-ci-floor-runner-drift

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

Issue #4529: a consumer's `fold-on-merge.yml` from v7.0.0 kept the pre-#4479 stand-down and stranded five
entries, and no session check said the runner was behind its template. `adopt-ci-floor.ps1` composed its
runners inline and never rewrites one it finds, so nothing could ask what the current template is.

#### Scope

The five CI-floor runners. Part 1's two gate callers (`branch-entry.yml`, `always-on-budget.yml`) are left
for #4537. #4476, the `branches:` gap the parked comment tied to them, is already closed.

### CREATE

- [x] Move the runner composition, `Get-WorkflowFacts` and `Test-QuotedScalarSafe` into
      `scripts/lib/ci-floor-runners-lib.ps1` (`Get-CiFloorConstants`, `Get-CiFloorWakeNames`,
      `Get-CiFloorRunnerTargets`); `adopt-ci-floor.ps1` calls it. The generated runners were compared byte
      for byte against the old script on one fixture: identical.
- [x] `ConvertTo-PinNeutralRunnerText` + `Get-CiFloorRunnerDrift`: each placed runner against the template
      composed for this tree (its trunk, its wake list), the shared-scripts `ref:` line aside.
- [x] `check-script-contract.ps1` prints `[BEHIND]` (non-counting, silenced by declining adopt-ci-floor);
      the session hook forwards it in a block of its own; a re-run of adopt-ci-floor prints `[behind]`.
- [x] Registered the lib in `shared-scripts-lib.ps1` and built the mirrors.
- [x] Docs: the adopt skill's Part 3, the check's and the hook's docstrings, the contract fixture's note.

### TEST

- [x] `ci-floor-runners-lib.tests.ps1` (new, 28 asserts): current at four pin shapes, CRLF, a non-main trunk;
      the pre-#4479 fold and an empty file behind; an absent runner not reported; the check's `[BEHIND]`
      line and exit 0; the hook forwarding it; a declined floor silent.
- [x] `adopt-ci-floor`, `pin-parity`, `workflow-timeouts`, `script-contract`, `script-contract-tables`,
      `shared-scripts`: green (the first three now read the lib).

### DEPLOY: fix/4529-ci-floor-runner-drift

A consumer now hears at session start when a CI-floor runner it placed earlier is behind the template the
installed plugin ships. The script-contract check holds `fold-on-merge.yml`, `verify-resolved.yml`,
`merge-on-green.yml`, `repo-settings.yml` and `close-parked-recurrences.yml` to what `adopt-ci-floor`
composes today, the shared-scripts pin aside, and prints a `[BEHIND]` line with the first differing line
and how to take the change. A re-run of `adopt-ci-floor` reports the same.

**Score:** 3

#### What makes this deploy extra special

A consumer whose `fold-on-merge.yml` predates the #4479 retry is told so at the next session start,
instead of finding stranded changelog entries on its trunk after a merge.

**Score:** 3

#### Pull Request

A placed CI-floor runner behind its template is reported at session start

