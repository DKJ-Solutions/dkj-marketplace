## fix/3945-close-when-pr-lands

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

Inbound #3945: state that an issue closes when its PR lands, and report an Asana-linked issue left open
after its `-NoResolves` merge. The issue's symptom held: `WORKFLOW-portable.md` said only that an issue
stays open while it still changes code (#3059), and nothing read an open issue after a merge.

### CREATE

- [x] `WORKFLOW-portable.md`: the rule, stated in the extension's own words, and the `-NoResolves` paragraph says when the hand close happens
- [x] `closed-message-sessioncheck.ps1`: finding 5, from three gh reads, with a test-only data override
- [x] README hooks row names the new finding

### TEST

- [x] `closed-message-sessioncheck.tests.ps1`: the measured case, five silent cases, an unreadable read, and the reach (42 passed)

### DEPLOY: fix/3945-close-when-pr-lands

In a BWJ store, an Asana-linked issue closes when its pull request lands, always
([#3945](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3945)). "Open until live" is not a state:
`notify-live` tells the task once the release is live. The ticket chapter now says so in its own words. The
`closed-message-sessioncheck` session check reports any Asana-linked issue still open within 14 days after
the `-NoResolves` pull request named for it merged. It stays quiet where an open pull request's branch is named
after the same issue, because a further step is still changing code. Measured on smartwatchbanden#1126, whose
pull request merged while the session kept the issue open for the live push.

**Score:** 2

#### What makes this deploy extra special

A store maintainer now sees a session-start error line for an Asana-linked issue left open after its merge,
where nothing said anything before. It names the issue, the pull request, and the two steps that end it: the
go-live block and the close.

**Score:** 3

#### Pull Request

bwj-development: an Asana-linked issue closes when its -NoResolves PR lands

