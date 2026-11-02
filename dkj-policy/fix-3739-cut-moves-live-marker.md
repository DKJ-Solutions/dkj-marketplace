## fix/3739-cut-moves-live-marker

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

Direction 1 of #3739, as the owner decided on November 2, 2026: the cut moves the marker.

### CREATE

- [x] `Move-ReleaseHistoryLiveMarker` in `release-lib.ps1`: takes the one marked row's marker off and puts it, as written, in the same cell of the new row; reports `none` or `ambiguous` and changes nothing then
- [x] `cut-release.ps1` calls it before inserting the row, only in a repo with a live stage and not under `-NoLivePushRecord`
- [x] the fallback's docstring in `build-release-notes-page.ps1` no longer says a live-stage repo moves the marker by hand
- [x] mirrors regenerated with `build-shared-scripts.ps1`

### TEST

- [x] `release-lib.tests.ps1`: moved (version cell with arrow, title cell without), none, two marked rows, a mention in prose, and a title containing the word "live" -- 637 asserts pass standalone

### DEPLOY: fix/3739-cut-moves-live-marker

In a repo with a live stage, `cut-release.ps1` now moves a `**LIVE**` marker in the release history onto the row it writes, into the same cell and with its arrow, because the cut runs after the push and the new version is the live one. Until now the marker stayed on the previous row, so the release-notes page labelled the replaced version live after every promote-then-cut. `-NoLivePushRecord` leaves the marker where it is, a repo without a live stage is not touched, and a table marking more than one row gets a warning instead of a guess ([#3739](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3739)).

**Score:** 3

#### What makes this deploy extra special

A consumer store that promotes to live and then cuts no longer has to move the `**LIVE**` marker by hand after every release: its release-notes page names the version that is actually live from the moment the cut lands.

**Score:** 3

#### Pull Request

cut-release moves the LIVE marker to the new row after a push-then-cut

