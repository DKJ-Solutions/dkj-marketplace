## fix/4152-reconcile-base-merges

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

#4152: `-ReconcileBase` finishes its PR the way the plain merging sync does, instead of printing three
commands that failed when run back to back. The second comment's claim that the plain sync waits on the
required checks only does not hold in the source; filed apart as #4168.

### CREATE

- [x] The plain sync's open / wait / merge / fast-forward moved into `Complete-SyncPullRequest`, unchanged but for its exits
- [x] `Write-SyncReconciliationBase` calls it after a landed push, always with a merge commit; the commands are printed only when the push failed
- [x] The `sync-main` skill page says so

### TEST

- [x] `sync-main.tests.ps1`: the recbase and squash cases run against a stand-in `gh` and assert the create, the checks poll and `pr merge --merge`; 178 asserts pass

### DEPLOY: fix/4152-reconcile-base-merges

`sync-main -ReconcileBase` now opens its PR, waits for the checks and merges it with a merge commit itself,
the same finish the plain merging sync runs ([#4152](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4152)).
It used to print `gh pr create`, `gh pr checks --watch` and `gh pr merge`, and run back to back they failed: the
watch returned before the checks had registered, and the merge was refused. The commands are still printed when
the push does not land.

**Score:** 3

#### What makes this deploy extra special

A Shopify store that reconciles a sync conflict no longer finishes the reconciliation base by hand: the run
merges it, with a merge commit even where the repo squashes by default, and leaves the checkout on the trunk.

**Score:** 3

#### Pull Request

sync-main -ReconcileBase opens, waits for and merges its own PR

