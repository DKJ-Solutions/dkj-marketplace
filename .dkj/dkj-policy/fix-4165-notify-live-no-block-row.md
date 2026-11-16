## fix/4165-notify-live-no-block-row

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

#4165: the cut's audience note listed an issue as solved while `notify-live` skipped it as `carries no
go-live block`, so its task was never told. This branch is the half that needs no decision: name such an
issue instead of skipping it silently. Whether `notify-live` should also SEND those tasks a plain live
message changes who is messaged, and stays on the issue as the owner's decision.

### CREATE

- [x] `Get-LiveMessageVerdict` marks `NoBlock` (with the task) on a solved issue linking one task, not
  told yet, with no go-live block
- [x] `notify-live.ps1` prints it as `NO BLOCK` with its task and a summary line, not exit 1; the skill
  page says so

### TEST

- [x] `bwj-development.tests.ps1`: `NoBlock` only for that case (not open, not task-less, not a
  -LiveSince block), and the driver's row (1029 asserts green standalone)

### DEPLOY: fix/4165-notify-live-no-block-row

`notify-live` names a solved issue that carries no go-live block instead of skipping it silently
([#4165](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4165)). An issue closed as completed and
linking one task, with no block, prints as `NO BLOCK` with its task, and the run ends with a line listing
them: the cut's audience note can call such an issue solved while nothing here tells its task, so a person
tells it by hand. Nothing more is sent than before.

**Score:** 2

#### What makes this deploy extra special

On release day the dry run shows which requesters the release notes call solved but whose task this run
will not tell, so nobody reads in the notes that their task shipped without hearing it on the task itself.

**Score:** 2

#### Pull Request

notify-live: name an issue that is solved but has no go-live block, instead of skipping it silently

