## feat/4230-reach-reason-after-the-fact

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

Inbound #4230: `guard-reach-reason` (#4057) fails open by design, and nothing caught a reach-labelled
issue with no `## Why <reach label>` section afterwards. Extend finding 6 of
`closed-message-sessioncheck` with the reason half, judged by the guard's own `Test-ReachReasonSection`.

### CREATE

- [x] `Get-ReachWithoutReasonFindings` in `closed-message-sessioncheck.ps1`, printed as its own line beside finding 6
- [x] docstring, README hooks row, `report-issue` skill and `WORKFLOW-portable.md` name the new line
- [x] suite cases: the measured case (#1329, #1398, #1404), an empty section, `###` in any case, the configured label

### TEST

- [x] `closed-message-sessioncheck.tests.ps1`: 73 passed, 0 failed

### DEPLOY: feat/4230-reach-reason-after-the-fact

Inside this repo, `closed-message-sessioncheck` reads `reach-reason-rules.ps1` beside finding 6 and its
suite gains the cases for the new line.

**Score:** 1

#### What makes this deploy extra special

A store session now starts with an `[ERROR]` line naming every open issue that carries the reach label
with no `## Why <reach label>` section in its body. An issue that slipped past `guard-reach-reason` -- a
body built at run time, a body on stdin, `gh` unreachable, or a checkout that had not updated -- is
caught at the next session start, as #1398 and #1404 in smartwatchbanden were not.

**Score:** 3

#### Pull Request

bwj-development: catch a reach label without its reason after the fact

