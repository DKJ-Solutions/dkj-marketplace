## feat/3846-parked-review-takeover

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

Issue #3846: `/issues-sweep-reviews` held out every parked issue claimed under the co-owner's account,
because `-TakeOver` refuses a colleague's claim. Verified against #2207 first: that refusal guards a
session still mid-flight on the branch, and an issue carrying `awaiting-review-dev` was handed to the
owner's look by its builder. So the take-over may move it, on request and on the label only.

### CREATE

- [x] `Get-TakeOverVerdict` takes `-Parked`, `-Labels` and `-ReviewLabel`: a foreign holder passes only
  under `-Parked` with `awaiting-review-dev` on the issue (new code `not-parked` otherwise), and the
  branch preconditions still apply. `Colleagues` names whose claim moved.
- [x] `claim-issue.ps1` gains `-Parked` (refused without `-TakeOver`), passes the issue's labels, prints the
  `not-parked` refusal and a take-over line naming the co-owner; plugin mirrors copied byte-identical.
- [x] `issues-sweep-reviews` step 2 runs `-TakeOver -Parked`, and its approval comment names the builder.
- [x] Seven asserts in `claim-issue.tests.ps1`.

### TEST

- [x] `claim-issue.tests.ps1`: 620 passed, 0 failed, the seven new asserts included.

### DEPLOY: feat/3846-parked-review-takeover

`/issues-sweep-reviews` can now approve and ship a branch a co-owner parked for review: its claim step
runs `claim-issue.ps1 -Tag -TakeOver -Parked`, which moves another account's claim only when the issue
carries `awaiting-review-dev` ([#3846](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3846)).
Outside a parked review the colleague refusal is unchanged (#2207).

**Score:** 3

#### What makes this deploy extra special

A repo with two owners no longer has its review pass hold out half the parked work; whichever owner
types the command can approve the other's branch, and the approval comment names whose work it was.

**Score:** 2

#### Pull Request

issues-sweep-reviews: let an owner approve a co-owner's parked branch

