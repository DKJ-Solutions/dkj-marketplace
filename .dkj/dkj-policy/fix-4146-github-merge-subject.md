## fix/4146-github-merge-subject

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

Issue #4146 also proposed the fold commit `fold: <branch> changelog (#NN)` as a third anchor. This branch leaves it
out. A fold commit's diff is the changelog fold and not the branch's change, so it cannot answer which paths the
entry touched. GitHub's merge commit can, the same way ship-pr's does.

### CREATE

- [x] `Find-BranchMergeCommit` (`live-record-lib.ps1`, all four byte-identical copies) also matches `Merge pull request #<n> from <owner>/<branch>`
- [x] `cut-release.ps1`'s comment and its unknown-entry warning name both shapes (mirror kept identical)

### TEST

- [x] `live-record-lib.tests.ps1`: a GitHub UI merge subject is matched, a prefix-sharing branch and a near miss are not, a trunk merge into a branch is not, and the newest match wins across the two shapes

### DEPLOY: fix/4146-github-merge-subject

Inside this repo, `Find-BranchMergeCommit` in `live-record-lib.ps1` also recognises GitHub's default merge subject,
`Merge pull request #<n> from <owner>/<branch>`, beside ship-pr's `merge: <branch> (#<n>)`
([#4146](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4146)). `cut-release.ps1`'s warning for an
unmatched entry names both.

**Score:** 2

#### What makes this deploy extra special

A Shopify repo cutting a release with `-LivePushRecord` gets entries merged through the GitHub UI checked against
the live-push record automatically. They no longer count as unknown, each to be checked by hand. Measured in a
consumer's cut, that was 58 of 82 entries. Only squash merges still need the check by hand.

**Score:** 3

#### Pull Request

The cut finds an entry's merge under GitHub's default merge subject too
