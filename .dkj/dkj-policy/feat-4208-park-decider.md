## feat/4208-park-decider

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

#4208, as decided by the owner on the issue (November 17, 2026): the decider goes in a
`Decider: @login` clause in the parking comment, not in the assignee, which the sweep claim writes and
removes. The writer is `claim-issue -Park -Decider`, a reader is `-Candidates`, and the two owner sweeps
skip an issue whose decider is another account.

### CREATE

- [x] `claim-issue-lib.ps1`: `Format-ParkComment -Decider`, `Test-DeciderLogin`, `Get-ParkDecider`; `Get-SweepCandidates` prints `decider @<login>` beside a `-dev` label.
- [x] `claim-issue.ps1`: `-Decider`, refused off an `awaiting-*-dev` park or when it is not a login, before anything is read.
- [x] The three `-dev` label descriptions (seam, fallback, blueprint rebuilt) and their docstrings now read "a developer's ... the named decider, else the owner".
- [x] `issues-sweep`, `issues-sweep-decisions`, `issues-sweep-reviews` and `CONTRIBUTING-portable.md` say how it is written and read.
- [x] Mirrors copied byte-identical.

### TEST

- [x] `claim-issue.tests.ps1` gained 17 asserts (comment form, login validation, newest decider, body fallback, `-Candidates` reason, two refusing runs); the suite ran 723 passed, 0 failed. The full gate runs in `ship-pr`.

### DEPLOY: feat/4208-park-decider

A `-dev` parking label no longer means "the owner alone". `claim-issue -Park <label> -Decider <login>`
names the developer an issue waits on, as `Decider: @<login>.` in the parking comment. `-Candidates`
prints it beside the label, and `issues-sweep-decisions` and `issues-sweep-reviews` put the issue only to
that account (#4208).

**Score:** 3

#### What makes this deploy extra special

A repo with more than one developer can park a decision, a look or an act on the one it belongs to,
instead of in front of the owner, who may have no context on it. Without `-Decider` nothing changes. The
three `-dev` label descriptions changed for a tracker adopting them fresh. An existing tracker keeps its
own wording, because `adopt-triage-labels` does not compare descriptions (#2942).

**Score:** 3

#### Pull Request

A named decider on a -dev park: claim-issue -Park -Decider, read by the owner sweeps

