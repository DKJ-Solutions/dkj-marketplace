## fix/4282-asana-move-own-board

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

#4282: `asana-closed-message` skipped the InReview move (and the reopen's InDevelopment move) whenever the
task sat on more than one Asana board -- measured on smartwatchbanden#1439, a task on the repo's own board
and on the SEO team's. The repo's own board is the one `Get-AsanaProjectGid` names, so on several boards
only that membership is judged; where it is not among them the move is still skipped. The open-section
sweep shares the board read (a held-equal copy) and gets the same rule.

### CREATE

- [x] `Get-RepoProjectGid`: reads the GID from `Get-AsanaProjectGid` in `scripts/repo-config.ps1` as text, never run, like the stage map.
- [x] `Read-AsanaTaskBoard -HomeProject`: on several boards, keeps only the repo's own membership when it is among them.
- [x] `Resolve-ReviewMoveSection` and `Resolve-ReopenCardWrites` pass it through; `asana-open-section.ps1` takes both copied helpers and passes it in its sweep.
- [x] Header docs of both templates name the new rule.

### TEST

- [x] `scripts/tests/dkj-repo-workflow-bwj.tests.ps1`: a two-board task moves on the home board (review and reopen), stays put without a home board or with one not among its boards, the GID reader ignores comments and the next function; the copy-equality list includes `Get-RepoProjectGid` -- 1068 asserts pass.
- [x] The full gate runs in `ship-pr`.

### DEPLOY: fix/4282-asana-move-own-board

When an issue closes with its result block, or is reopened, the BWJ Asana workflow now moves the linked
card even when the task also sits on another team's board: it moves the card on the repo's own board,
the one `Get-AsanaProjectGid` names, and leaves the other boards alone. Before, any second board made the
move a skip, so the message arrived while the card stayed in its old column. The daily open-section sweep
follows the same rule. A task on several boards none of which is the repo's own is still left where it is.

**Score:** 2

#### What makes this deploy extra special

Tickets from other teams, which normally live on a second board, now follow their message into review
like every other ticket.

**Score:** 2

#### Pull Request

Asana card moves use the repo's own board when a task is on several boards
