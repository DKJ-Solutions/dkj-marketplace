## fix/4163-comment-named-issues

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

The report left its cause open. Measured on the consumer's tracker: its PR template carries, inside an HTML comment,
the sentence "#383's handover asked the reviewer to tick a collection metafield ...". Every PR body inherits it, so
`Get-PullIssueCandidates` read #383 as named by every PR in the range, and #383 closed as completed, so it counted as
solved. The issue's suggested `git tag --contains` filter is left out: it would hide this instance while the
template kept naming #383 to notify-live, which reads the same rule. Its other suggestion, tracing each drafted item
to its PR, is moot once the cause is gone and can be filed on its own if a stray item recurs.

### CREATE

- [x] `pull-issue-lib.ps1` (all three byte-identical copies): an HTML comment, an unclosed one included, is removed before the body is read for `#<n>`

### TEST

- [x] `bwj-development.tests.ps1`: the measured template shape names only the prose outside its comment, an unclosed comment hides the rest, text between two comments is still read (1027 asserts, green)

### DEPLOY: fix/4163-comment-named-issues

Inside this repo, `Get-PullIssueCandidates` in `pull-issue-lib.ps1` skips HTML comments when it reads a PR body for
named issues ([#4163](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4163)).

**Score:** 2

#### What makes this deploy extra special

A store whose PR template mentions an issue number inside its guidance comment no longer gets that issue in every
release. Before, the cut's task-form audience note drafted it as solved, and notify-live could tell its task again
that it was live. Measured in a consumer's v1.8.0 cut: a task that had shipped three releases earlier.

**Score:** 3

#### Pull Request

A PR template's HTML comment no longer names an issue to the task form and notify-live

