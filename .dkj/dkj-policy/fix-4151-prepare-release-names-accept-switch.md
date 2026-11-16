## fix/4151-prepare-release-names-accept-switch

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

Issue #4151 offered two fixes. This branch takes the one it named as the minimum: `prepare-release` names
`-AcceptOwedReconciliation`. `-ReconcileBase -KeepTrunk <paths>` was not built. The objection that the switch
accepts every owed path at once only holds while live-wins paths are still owed. Each of those is settled by its
own content commit, after which only the trunk-wins paths are left. The step now says to pass the switch at
exactly that point.

### CREATE

- [x] `prepare-release.ps1`'s reconciliation step separates the two answers: an ordinary commit where live's content should win, `-AcceptOwedReconciliation` to `live-preflight` where the trunk's version is meant to win

### TEST

- [x] `bwj-development.tests.ps1` pins that the reconciliation step names `-AcceptOwedReconciliation`

### DEPLOY: fix/4151-prepare-release-names-accept-switch

`prepare-release`'s reconciliation step (bwj-development) now says what to do with an owed path where the trunk is
meant to win ([#4151](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4151)): pass
`-AcceptOwedReconciliation` to `live-preflight` on the day, once those are the only paths left. A path where
live's content should win still takes an ordinary commit.

**Score:** 2

#### What makes this deploy extra special

A BWJ store repo preparing a release after `sync-main -ReconcileBase` learns on the Friday how to let the trunk win
on a path. Until now that only surfaced as `live-preflight`'s refusal on the day.

**Score:** 2

#### Pull Request

prepare-release names -AcceptOwedReconciliation for paths where the trunk is meant to win
