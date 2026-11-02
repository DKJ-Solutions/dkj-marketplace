## fix/3732-fill-wait-stall

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

Issue #3732, split out of inbound #3729 (its ask 2). The fill wait in `backup-live-theme` and
`push-preview` stopped at a fixed `-TimeoutMinutes`, so a copy still growing at the deadline was refused
(measured: 661 of 909 files at 20 minutes, rising 3-4 per sample). Of the two options the issue named, the
stall rule is taken rather than a count-scaled default: it needs no estimate of a store's copy speed, and
it leaves #2350's reading intact (only `complete` ends the wait early; `short` is judged once the wait is
over). The extension is bounded by a hard cap of three times the wait.

### CREATE

- [x] `theme-lifecycle-rules.ps1`: `Get-ThemeFillWaitDecision` (pure, `-Now` passed in) and `$script:ThemeFillHardCapFactor = 3`.
- [x] `backup-live-theme.ps1` and `push-preview.ps1`: the poll loop asks it each round and says when it runs on past the deadline.
- [x] `live-preflight.ps1`: the outer bound around the backup covers the hard cap (loads the lib for the factor).
- [x] Mirror the four scripts into `plugins/dkj-subagents/dkj-subagents-shopify/scripts/`; the `theme-lifecycle` and `live-preflight` skill pages and `backup-live-theme`'s help say so.

### TEST

- [x] `theme-lifecycle-rules.tests.ps1`: seven asserts on the decision (inside the wait, the measured still-growing shape, a stall, a pause inside the window, the hard cap, one sample, the factor). Run standalone: 147 pass, 0 fail.

### DEPLOY: fix/3732-fill-wait-stall

The theme fill wait in `backup-live-theme` and `push-preview` no longer gives up at a fixed clock while
the copy is still growing. Past `-TimeoutMinutes` it waits on as long as the file count keeps rising, and
stops on a stall or at three times the wait
([#3732](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3732)).

**Score:** 3

#### What makes this deploy extra special

A Shopify store with a large live theme gets a verified backup on release day without knowing its copy
speed in advance, and without a retry that duplicates live a second time. Measured on a 909-file theme:
661 files at the old 20-minute limit, still filling.

**Score:** 3

#### Pull Request

Theme fill wait runs on while the copy is still growing, up to a hard cap

