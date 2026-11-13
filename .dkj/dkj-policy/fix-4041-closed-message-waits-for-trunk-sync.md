## fix/4041-closed-message-waits-for-trunk-sync

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

Inbound #4041: `closed-message-sessioncheck` (bwj-development) reported files missing that the same
session start's trunk fast-forward then brought in. Cause verified: it is a separate SessionStart
entry, so the harness runs it beside dkj-policy's dispatcher, whose prep step does the fast-forward.
Repair: wait for the dispatcher's prep-done mark, the mechanism #3657 built for the dev-preview hook.

### CREATE

- [x] Mirror `session-cache-lib.ps1` and `hash-hex-lib.ps1` into bwj-development (registry + generator)
- [x] `closed-message-sessioncheck.ps1` waits (at most 20 s, store repos only) for the prep-done mark

### TEST

- [x] `closed-message-sessioncheck.tests.ps1`: the measured case (files land, then the mark) is silent;
  no mark in time checks the tree as it stands, within the cap. 48 passed, 0 failed.

### DEPLOY: fix/4041-closed-message-waits-for-trunk-sync

`closed-message-sessioncheck` now waits for dkj-policy's trunk sync before it reads a store's tree
([#4041](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4041)). It ran as its own SessionStart
entry beside the dispatcher, so in xoxowildhearts it reported the prio-label pair and
`Get-ResolvesExemptMatchers` missing, and the same session start then fast-forwarded `main` by 34
commits that brought both in. It now waits up to 20 s for the dispatcher's prep-done mark, as the
dev-preview hook does (#3657), with `session-cache-lib` and `hash-hex-lib` mirrored into bwj-development.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a BWJ store stops getting `[ERROR]` lines at session start for files the same
session start brings in. Those lines made them re-run `adopt-bwj-development` for work already merged,
and taught them to skip the one error that was real.

**Score:** 2

#### Pull Request

closed-message-sessioncheck waits for the trunk sync before it reads the tree

