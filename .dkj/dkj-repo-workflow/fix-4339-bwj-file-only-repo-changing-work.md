## fix/4339-bwj-file-only-repo-changing-work

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

Inbound #4339: the BWJ filing side (WORKFLOW-portable ch. 1, `report-issue`) files act-only findings
that the #3059 close rule then removes. Verified on the tree: ch. 1 listed "a decision that is not yours
to make" as a filed finding, and `research` covered "decision" tickets. Bring filing in line with one
test used at both ends: will a file in this repo change?

### CREATE

- [x] `WORKFLOW-portable.md` ch. 1: the filing test (yes now / yes after an outside act, filed already parked / no, no issue), with Maikel's November 4 statement and the measurement; `research` narrowed to research a session carries out
- [x] `report-issue/SKILL.md`: description and step 1 carry the filing test; the create takes the `awaiting-*` label where it waits from the start
- [x] `guard-kind-label.ps1`: the refusal's `research` line matches, and names the filing test

### TEST

- [x] Gates run by `ship-pr` (docs and one console string; no behaviour change)

### DEPLOY: fix/4339-bwj-file-only-repo-changing-work

In a BWJ store repo a finding is filed on GitHub only when a file in the repo will change because of
it, now or after an act outside the repo; one that waits from the start is filed already parked with
its `awaiting-*` label, and an act-only finding or someone else's decision goes to Asana instead. This
is the #3059 close rule asked at filing, so sweeps stop spending turns on issues with nothing to build
([#4339](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4339)).

**Score:** 2

#### What makes this deploy extra special

A BWJ session running `report-issue` no longer files an outside act or a decision that is not its own
as a GitHub issue, and files a waiting one with its parking label at creation. Measured in
smartwatchbanden: 21 of one filer's 26 sweep-parked issues waited on an outside act or an open choice,
and every label came from a later sweep.

**Score:** 3

#### Pull Request

bwj: file on GitHub only what will change a repo file, already parked where it waits

