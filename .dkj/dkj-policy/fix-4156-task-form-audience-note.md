## fix/4156-task-form-audience-note

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

`prepare-release` reads the seam `cut-release` reads to choose the task form, `Get-ReleaseNoteTaskLink`, through
its own `Get-Seam`, so the two cannot disagree about which form a repo is in. The entries form keeps its
sentence unchanged.

### CREATE

- [x] `prepare-release.ps1`: step 2 says the cut drafts the note from the live-push record in a task-form repo; the runbook gets `-TaskForm`
- [x] `Format-ReleaseRunbook` (`prepare-release-rules.ps1`): step 6 in the task form names `-LivePushRecord` and the review after the cut
- [x] The skill page names the task-form answer

### TEST

- [x] `bwj-development.tests.ps1`: the entries form still asks for the note ahead, the task form does not and names `-LivePushRecord`, and the driver reads the seam

### DEPLOY: fix/4156-task-form-audience-note

`prepare-release` (bwj-development) no longer asks a repo that drafts its audience note as solved tasks
(`Get-ReleaseNoteTaskLink`) to write that note before the day
([#4156](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4156)). Step 2 and the runbook's cut step say the
cut drafts it from the live-push record, name `-LivePushRecord` as required, and ask for a review after the cut.

**Score:** 2

#### What makes this deploy extra special

A BWJ store repo whose release note lists solved tasks is no longer told to write a note the cut would replace.
That note would list work before anyone knew it was live. Its runbook now names the record the cut needs.

**Score:** 2

#### Pull Request

prepare-release tells a task-form repo that the cut drafts the audience note
