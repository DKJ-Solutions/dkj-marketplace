## fix/3926-fill-wait-sampling

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

#3926 (split off #3923): each fill-wait sample is a full `theme pull`, so at the 30 s default against a
910-file theme a wait pulls back to back, and parallel previews broke each other's counts; a resume also
pulled live again, which is the pull measured to fail. Of the issue's directions, the GraphQL count needs
credentials the CLI route does not, so it is left out; the two that need nothing are built. Branch
`fix/3923-preview-fill-wait` (another account) changes only push-preview's default and its doc line, not
the wait loop.

### CREATE

- [x] `Get-ThemeFillSleepSeconds` (theme-lifecycle-rules): the pause is never shorter than the last pull took; used by push-preview and backup-live-theme
- [x] `Format-PreviewLiveCountRecord` / `Get-PreviewLiveCountFromRecord`: push-preview keeps live's count in `branch.<name>.previewLiveCount` (live id, count, UTC time) and a resume reuses it; a new copy drops it
- [x] push-preview tries live's count three times before giving up
- [x] Mirrors rebuilt (`build-shared-scripts.ps1`); push-preview's skill page describes the spacing and the reuse

### TEST

- [x] `theme-lifecycle-rules.tests.ps1`: the pause (pull quicker/slower than the interval, a fractional pull not truncated), the record and every case it is refused in -- 169 pass

### DEPLOY: fix/3926-fill-wait-sampling

`push-preview` and `backup-live-theme` no longer pull a filling theme back to back
([#3926](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3926)). Every count of a copy is a full
`theme pull`, and the pause before the next one is now never shorter than that pull took, so a wait spends
at most half its time pulling. Several previews filling at once space themselves out. `push-preview` also
keeps live's file count for the copy in `branch.<name>.previewLiveCount` and reuses it on a resume,
instead of pulling live again, and tries live's count three times before giving up. That pull is the one
measured to fail while three previews filled side by side (smartwatchbanden#1066).

**Score:** 3

#### What makes this deploy extra special

A store that pushes several previews from live at once no longer has one of them fail its resume on
live's count. Each wait also pulls about half as often against a large theme. Nothing to do but take the
version.

**Score:** 3

#### Pull Request

Theme fill wait: space samples by their cost, reuse live's count on a resume (#3926)

