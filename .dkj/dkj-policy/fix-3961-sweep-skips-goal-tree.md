## fix/3961-sweep-skips-goal-tree

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

Inbound #3961: `claim-issue -Candidates` read every issue of a plan-goal tree as free. Default chosen,
following plan-goal's own page: the goal and its milestones are containers, only each goal's Now is a step,
and an unplanned milestone is the owner's step. Now stays free; a repo whose Now is owner-only parks it.

### CREATE

- [x] `Get-GoalTreeSkips` in `claim-issue-lib.ps1`, and `Get-SweepCandidates -GoalSkips/-GoalLabel` (a `goal`
  label alone reads as a container without a tree read)
- [x] `claim-issue.ps1 -Candidates` reads the tree once through goals-lib's query, only when an open issue is a
  goal; an unread tree is said and degrades to the label skip
- [x] `issues-sweep` and `plan-goal` pages name each other and say Now is sweep work by default
- [x] plugin mirrors copied

### TEST

- [x] 13 new asserts in `claim-issue.tests.ps1`, run in isolation during the build
- [x] read-only check against DKJ-Solutions/dkj-recipes's real tree: 31 tree issues, 30 skipped, Now #45 free

### DEPLOY: fix/3961-sweep-skips-goal-tree

`claim-issue -Candidates` now reads a plan-goal tree once and skips its goal, its milestones and every task
but the goal's Now, each with the reason, so a sweep no longer has to park or hold out a whole tree by hand
(#3961).

**Score:** 2

#### What makes this deploy extra special

A sweep in a repo that plans with `plan-goal` gets one candidate per goal (its Now) instead of the whole
tree. Measured on a consumer: 31 `free` issues became 1. Where Now is a step only the owner can take, park
it with its `awaiting-*` label, as the plan-goal page now says.

**Score:** 3

#### Pull Request

issues-sweep skips a plan-goal tree except each goal's Now

