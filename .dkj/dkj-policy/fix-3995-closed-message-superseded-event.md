## fix/3995-closed-message-superseded-event

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

Inbound #3995, verified on pickup: `Invoke-Main` in the template never reads the issue's current
state, and the workflow's `concurrency` comment assumed the pending run is always the newest event,
while GitHub serialises runs in the order it created them.

### CREATE

- [x] `asana-closed-message.ps1`: `Get-IssueStateApiArgs`, `Read-IssueState`, `Test-SupersededEvent`;
  `Invoke-Main` posts nothing and moves no card for an event the current state has superseded, and posts
  as before when the read fails
- [x] `asana-closed-message.yml`: the `concurrency` comment names the creation-order gap and the guard
- [x] `bwj-development.tests.ps1`: asserts for the read's arguments and the superseded verdict

### TEST

- [x] The suites, run by `ship-pr`'s gate

### DEPLOY: fix/3995-closed-message-superseded-event

The `asana-closed-message` template no longer posts a stale message when two events on one issue
arrive out of order. Inbound
[#3995](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3995): on xoxowildhearts#512 the
reopen's run was created one second after the close's, so the task was told "back in development" and
its card moved back while the issue was closed. The script now reads the issue's current state before
it posts, and an event that state has already moved past (a reopen of a closed issue, a close of an
open one) posts nothing and moves no card, because the run of the later event carries the current
state. A failed read posts as before, logged. A consumer takes it by copying the template again
(`adopt-bwj-development`).

**Score:** 2

#### What makes this deploy extra special

A requester on Asana was told an issue was back in development while it had closed; that message no
longer goes out.

**Score:** 2

#### Pull Request

asana-closed-message: skip an event the issue's current state has superseded

