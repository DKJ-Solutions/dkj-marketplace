## fix/4053-reach-issue-without-card

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

Inbound #4053: a reach-labelled issue that never got its Asana card goes undetected. Verified on
pickup: `guard-asana-mirror` holds only issue -> card at the create-task call (#2482), and
`asana-link-pickupcheck` only card -> issue (#2940). `build-backlog-page` does list an open reach issue
with no mirrored task, but only when somebody runs it, so the report's "nothing detects it" is true of
everything that runs on its own. The report's second ask, a loud report when step 2 cannot reach Asana,
is already prescribed by report-issue ("still do step 1, then stop with a clear note"), so this branch
does not touch it. Repair: a sixth finding in `closed-message-sessioncheck`, read from the open-issue
list finding 5 already fetches.

### CREATE

- [x] `closed-message-sessioncheck.ps1`: finding 6 (`Get-ReachWithoutCardFindings`), issues read with `labels`, reach label read through `Get-ProjectReachLabel`
- [x] `closed-message-sessioncheck.tests.ps1`: the measured case, the seam's label, an unreadable config, the fifteen-number cap, and the live gh path's labels list
- [x] README hook row, `WORKFLOW-portable.md` and `report-issue` name the label -> card check

### TEST

- [x] `closed-message-sessioncheck.tests.ps1`: 56 passed, 0 failed

### DEPLOY: fix/4053-reach-issue-without-card

`bwj-development`'s session check `closed-message-sessioncheck` now names, at every session start in a
store or `phone-factory`, the open issues that carry the reach label and link no Asana task
([#4053](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4053)). Until now nothing that runs on
its own noticed a skipped `report-issue` step 2: `guard-asana-mirror` stops only a card without the
label, and only at the call. Measured in `smartwatchbanden`: 34 of 35 reach-labelled issues filed since
November 1 had no card. The finding reuses the open-issue list the check already reads, so it costs no
extra `gh` call.

**Score:** 3

#### What makes this deploy extra special

A store's maintainer sees a new `[ERROR]` line at session start, listing every open reach-labelled issue
whose card is still owed, until `report-issue`'s steps 2-3 have run for each of them.

**Score:** 3

#### Pull Request

bwj-development: report an open reach-labelled issue that has no Asana card at session start

