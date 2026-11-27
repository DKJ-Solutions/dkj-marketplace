## fix/4537-workflow-folder-caller-drift

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

Issue #4537, the half #4529 left out: the two callers `adopt-workflow-folder.ps1` places were composed
inline, so nothing compared a placed copy with the current template.

### CREATE

- [x] `workflow-folder-callers-lib.ps1`: the live-branch resolution, the composition of both callers, a
      pin-neutral reading (`uses: ...@<ref>` and `scripts-ref:`), and `Get-WorkflowFolderCallerDrift`
- [x] `adopt-workflow-folder.ps1` composes through the lib, and writes byte-identical callers
- [x] `check-script-contract.ps1` prints a non-counting `[BEHIND]` / `[OK]` per placed caller, silenced by
      declining `adopt-workflow-folder`; the session hook forwards it by marker as it does #4529's
- [x] `Get-FirstDifferingLine` shared with `Get-CiFloorRunnerDrift`; the lib is registered and mirrored
- [x] the adopt skill page and the scripts README name it

### TEST

- [x] `workflow-folder-callers-lib.tests.ps1` (new, 46): current, other pin, `@main`, CRLF, changed body,
      live branch present and declared after placement, absent caller, the contract line and its hook forwarding
- [x] adopt-workflow-folder, adopt-ci-floor, ci-floor-runners-lib, script-contract, pin-parity,
      workflow-timeouts and shared-scripts suites green; integrity gate 0 errors

### DEPLOY: fix/4537-workflow-folder-caller-drift

The composition of the two gate callers moves out of `adopt-workflow-folder.ps1` into a lib, with its
output unchanged, and `Get-CiFloorRunnerDrift` shares its line diff with the new drift read.

**Score:** 1

#### What makes this deploy extra special

A session start now reports `[BEHIND]` when a consumer's `branch-entry.yml` or `always-on-budget.yml`
differs from the caller this plugin version would place, its release pin aside, as it already does for
the CI-floor runners. A changed trigger or `permissions:` line, or a live branch declared after the caller
was placed, no longer sits unnoticed until a hotfix entry lands unjudged.

**Score:** 2

#### Pull Request

The branch-entry and always-on-budget callers are held to their templates, reported [BEHIND] like the CI-floor runners

