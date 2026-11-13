## feat/4057-why-reach-label

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

Inbound #4057, the owner's own request: the reach label is given only with its reason written into the
issue. Verified on pickup: report-issue step 1 asks for no written reason, and no hook reads a
`gh issue create` / `gh issue edit` at all, so the proposal's three parts all stand. Built as proposed: a
`## Why <reach label>` section in step 1, and a PreToolUse guard beside `guard-asana-mirror` that fails
open where it cannot read the body (#2482's precedent). The parser reuses `ConvertTo-ShellSegments`
from `stale-paste-block-rules.ps1`, and the label's name `Get-ProjectReachLabel`.

### CREATE

- [x] `scripts/lib/reach-reason-rules.ps1`: `Get-ReachLabelInvocation`, `Test-ReachReasonSection`
- [x] `hooks/guard-reach-reason.ps1` and its `hooks.json` entry behind a `gh issue create|edit` pre-filter
- [x] `scripts/tests/guard-reach-reason.tests.ps1`, registered in `suite-groups.json` and `suite-durations.json`
- [x] `report-issue` step 1, `WORKFLOW-portable.md`'s reach-label section, the README hook row, and the `Get-ReachLabel` consumer list in both copies of `script-contract-lib.ps1`

### TEST

- [x] Victor's review: two false refusals found and repaired -- a body built at run time (`$body`, `"$(cat b.md)"`, `(Get-Content ...)`) and a create whose body comes from `--template`, `--recover`, `--web` or `--editor` now pass with a warning instead of being refused; both are regression cases in the suite
- [x] `guard-reach-reason.tests.ps1`: 58 passed, 0 failed
- [x] The `Get-ReachLabel` consumer list also names `closed-message-sessioncheck` (reads it since #4053) and `asana-link-pickupcheck` (since #2940), which #4059 found missing
- [x] `guard-stale-paste-block.tests.ps1` counted the shell-tool PreToolUse entries at two; the gate caught it, and the count is now three (156 passed)

### DEPLOY: feat/4057-why-reach-label

`bwj-development` gives the reach label a written reason
([#4057](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4057)). An issue that carries the
reach label now says why in a `## Why <reach label>` section: who notices the defect, and what they
notice. A new PreToolUse hook, `guard-reach-reason`, refuses a `gh issue create` or `gh issue edit` that
adds the label on an admitted repo while the body the call leaves has no such section. It judges
`--body`, `--body-file`, or the issue's current body. A body it cannot read -- one built at run time,
taken from a template, the browser or an editor, or held by an unreachable tracker -- passes with a
warning. Measured in `smartwatchbanden`: 35 issues were filed with `minor` between November 1 and 13,
2026, and none said why.

**Score:** 3

#### What makes this deploy extra special

A session in a store repo that labels an issue `minor` without a written reason is now stopped and shown
the section to write, so every reach-labelled issue a colleague later reads on the board can be checked
against its stated reason.

**Score:** 4

#### Pull Request

bwj-development: the reach label needs a written Why section, and a guard refuses it without one

