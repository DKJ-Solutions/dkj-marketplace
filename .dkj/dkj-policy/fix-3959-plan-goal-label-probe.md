## fix/3959-plan-goal-label-probe

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

Inbound #3959, reason verified in `plan-goal.ps1`: the label probe ran under the script's `Stop`, so on
Windows PowerShell 5.1 the 404's stderr line became a terminating error despite `2>$null`, and the create
branch was unreachable on a repo's first goal.

### CREATE

- [x] The label probe runs under a local `Continue` and reads the exit code after the preference is restored

### TEST

- [x] `goals.tests.ps1` runs `-Apply` under `powershell.exe` against a fake `gh` answering 404 on the probe: red before the fix (5 fails), green after

### DEPLOY: fix/3959-plan-goal-label-probe

`plan-goal -Apply` creates the `goal` label again in a repo that has none, on Windows PowerShell 5.1. The
label probe ran under the script's `Stop` preference, and 5.1 turns a native command's stderr into a
terminating error even through `2>$null`, so the 404 that means "no label yet" ended the run with
`[FAILED] gh: Not Found (HTTP 404)` and nothing filed. The probe now runs under a local `Continue` and
reads the exit code. Inbound #3959, measured in `DKJ-Solutions/dkj-recipes`.

**Score:** 2

#### What makes this deploy extra special

Planning the first goal in a repo with `plan-goal` works on the first try, without creating the `goal`
label by hand first.

**Score:** 3

#### Pull Request

plan-goal -Apply creates the goal label on PowerShell 5.1

