## feat/4226-park-move-release-external

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

- [x] Verify #4226 still stands: a merged-but-unreleased `awaiting-pull-external` issue reads plain `skipped`, a body-parked `awaiting-release-external` has no `Since`, and `-Park` refuses an issue that is already parked

### CREATE

- [x] `Get-ParkMoveFrom` in `claim-issue-lib.ps1`: the one known progression, `awaiting-pull-external` -> `awaiting-release-external`, and only as the issue's sole parking label
- [x] `claim-issue.ps1`: `-Candidates` reads `relabel` and prints the move; `-Park` lifts the old label in the same edit; the parked-issue refusal lets a move through
- [x] The plugin mirrors of both files, and the `issues-sweep` skill page

### TEST

- [x] `claim-issue.tests.ps1`: 12 new asserts, 735 passed

### DEPLOY: feat/4226-park-move-release-external

`claim-issue -Candidates` now reads an `awaiting-pull-external` issue as `relabel` once everything it waits on has merged upstream but no release has followed: it waits on a release from then on, and the label said otherwise ([#4226](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4226)). The line it prints moves the issue in one step, `claim-issue.ps1 <n> -Tag -Park awaiting-release-external -Reason "<owner/repo>'s next release"`: `-Park` now lifts `awaiting-pull-external` in the same edit that adds its successor, and posts the dated parking comment the release-external stale-park reads. A hand swap with `gh issue edit` left a park that never cleared, because nothing dated it. Any other already-parked issue is refused by `-Park` as before.

**Score:** 2

#### What makes this deploy extra special

A sweep in a consumer repo sees the merged-upstream wait named, with the paste-ready move, instead of an owner spotting the stale label by hand.

**Score:** 2

#### Pull Request

claim-issue: an awaiting-pull-external issue whose upstream landed reads 'relabel', and -Park moves it to awaiting-release-external in one step

