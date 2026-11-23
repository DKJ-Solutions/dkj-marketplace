## fix/4403-cut-release-backflow-merges

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

#4403, verified before the repair: `cut-release.ps1` read each entry's merge commit only from
`git log --first-parent <baseTag>..HEAD`, so a branch merged into the deploy branch `live` and brought to
`main` by one back-flow merge left no match on the trunk's first-parent line. Keep the first-parent
lookup first, and read the full merge history once, only for the entries it missed. The record still
decides each entry's state: the issue's suggestion to default these entries to `live` is not taken,
because the record is the authority on what the push carried.

### CREATE

- [x] `cut-release.ps1` (source and plugin mirror): a lazy second `git log --merges` read for entries
  the first-parent line missed, its warning on failure, the comment block and the `-LivePushRecord` help
- [x] `live-record-lib.ps1` (source and three mirrors): the `Find-BranchMergeCommit` synopsis no longer
  claims it is only handed first-parent lines
- [x] `cut-release-drive.tests.ps1`: case 10b, a branch merged through a side branch `live`, run with a
  `live` record and a `hold` record
- [x] Is the change visible in the frontend / storefront? No -- a release script and its test, nothing rendered

### TEST

- [x] `cut-release-drive.tests.ps1`: all 150 asserts pass, the 10 new ones included (run during the build)
- [x] `build-shared-scripts.ps1`: every mirror in sync
- [x] The full gate runs in `ship-pr`

### DEPLOY: fix/4403-cut-release-backflow-merges

`cut-release -LivePushRecord` now finds the merge commit of a branch that reached `main` through a
back-flow from the deploy branch (the hotfix lane), instead of reporting it as unknown (#4403). The
first-parent line is still read first. For an entry it misses, the cut reads the range's full merge
history once, and the live-push record decides that entry's state as for any other.

**Score:** 2

#### What makes this deploy extra special

In a Git-connected store that ships hotfixes through `live`, a cut with a live-push record no longer
warns about every hotfix-lane entry and no longer drops them from the drafted audience note. A
smartwatchbanden cut measured 19 warnings and 7 dropped entries, all re-checked by hand.

**Score:** 3

#### Pull Request

cut-release finds entry merges behind a back-flow from the deploy branch

