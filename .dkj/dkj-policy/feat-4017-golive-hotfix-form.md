## feat/4017-golive-hotfix-form

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

Inbound #4017 (measured in smartwatchbanden#1273, PR #1278 to `live`): the go-live block has no form for
a hotfix-lane change, so it planned one for the Monday release and said it went with that release either
way. Verified against `golive-block-rules.ps1`: `ReleaseDay` and `AskLook` are fixed text and no form
avoids them. Add `-Hotfix` with an optional `-LiveBy`, as the issue proposes.

### CREATE

- [x] `golive-block-rules.ps1`: the hotfix sentences (nl/en), `Format-GoLiveBlock -Hotfix -LiveBy`, the hotfix ask, no release marker
- [x] `build-golive-block.ps1`: `-Hotfix` and `-LiveBy`, their refusals, no release day or version projection
- [x] the `golive-block` skill page: step 2 and the parameter table
- [x] `bwj-development.tests.ps1`: asserts for the form, both languages, the marker and the refusals

### TEST

- [x] `bwj-development.tests.ps1` green locally (955 asserts); the full gate runs in `ship-pr`

### DEPLOY: feat/4017-golive-hotfix-form

[`build-golive-block.ps1`](../../plugins/dkj-policy/extensions/bwj-development/scripts/task/build-golive-block.ps1)
gains `-Hotfix` for a change that ships through a store's hotfix lane, a pull request to the live branch
merged once the requester approves it. The block names no release day: it says the change goes live as a
separate hotfix once approved, with `-LiveBy <date>` as the aim where the requester has a deadline. The ask
treats the look as that approval and no longer says the change ships with the release either way. The block
carries no release marker, so no "now live" message follows at the next release. It refuses `-LiveSince`,
`-From`, `-ReleaseDay`, `-Version` and the other forms
([#4017](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4017)).

**Score:** 3

#### What makes this deploy extra special

A BWJ store that ships a hotfix no longer has to bend `-ReleaseDay` to a deadline and patch the block by hand:
`-Hotfix` tells the requester the truth, which is that it goes live once they approve it.

**Score:** 3

#### Pull Request

golive-block: a hotfix form for a change that goes live on approval
