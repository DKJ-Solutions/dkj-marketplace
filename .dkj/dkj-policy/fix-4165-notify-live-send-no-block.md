## fix/4165-notify-live-send-no-block

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

The owner decided on #4165 (davekokbwj, 2026-11-16): **send it**. PR #4178 only named a solved issue with
no go-live block as `NO BLOCK`; this branch makes it owed the plain live message.

### CREATE

- [x] `Get-LiveMessageVerdict` (live-message-rules.ps1): a closed-as-completed issue linking one task, not
  told yet, with no go-live block, is `Owed` with `NoBlock = $true` and language `en`
- [x] notify-live.ps1: no-block issues join the owed list (row reads `no block`); the `NO BLOCK` row and
  the "tell them by hand" summary line are gone
- [x] notify-live SKILL.md step 4 and both docstrings say the same
- [x] bwj-development.tests.ps1: the NoBlock asserts pin owed, its task, `en`, the refusals that still
  hold (open, not planned, no task, -LiveSince block, already told), and the driver's row

### TEST

- [x] the gate (`ship-pr` runs it)

### DEPLOY: fix/4165-notify-live-send-no-block

`notify-live` now tells the task of a solved issue that carries no go-live block
([#4165](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4165)), instead of only naming it as
`NO BLOCK`. An issue closed as completed, linking one task and not told yet, gets the same plain "now live
as version vX.Y.Z" message as a block waiting on the release, and its dry-run row reads `no block`. That
is the set the cut's audience note counts as solved, so the two readers share one definition. The marker
comment still keeps it from being told twice.

**Score:** 3

#### What makes this deploy extra special

On release day every task the release notes call solved now hears on the task itself that its work is
live, with no by-hand messages left for the issues whose close carried no go-live block.

**Score:** 3

#### Pull Request

notify-live: send the plain live message to a solved issue with no go-live block

