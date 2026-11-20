## feat/4344-approved-takeover-unassigns

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

The issue's premise was checked and holds. The default route refuses an issue assigned to another
account (`Get-ClaimVerdict`'s 'taken'), and `-TakeOver` only moves this account's own tag claim. The
guard's intent ("the way past it is talking to whoever holds it, which a flag cannot do") is kept: the
new flag records that talk and does not replace it.

### CREATE

- [x] `-ApprovedBy "<who, when or where>"` on the default route: 'taken' (a foreign assignee or a
  co-assignment) becomes a takeover. One `gh issue edit` adds this account and removes the previous
  assignee(s), a comment says who approved it, and the read-back warns, with the line to run, if a
  previous assignee is still there. Refused when empty or beside a tag-mode or park parameter. Closed,
  pull-request and no-account refusals stay refused. `-DryRun` prints the takeover.
- [x] Lib: `Get-ClaimTakeoverMode`, `Format-TakeoverComment`, `Get-TakeoverRemainders`; `Get-ClaimVerdict`'s
  docstring names the valve. Mirrored with `build-shared-scripts.ps1`; the claim-issue skill names the parameter.

### TEST

- [x] `claim-issue.tests.ps1`: the verdict-to-mode mapping for every code, the comment format, the
  remainders, and the up-front refusals. 773 passed, 0 failed. The gh write path itself is not run by a
  test, since no test may reach the tracker.

### DEPLOY: feat/4344-approved-takeover-unassigns

`claim-issue <n> -ApprovedBy "<who, when>"` takes over an issue another account holds once a person
has approved it. It adds you and removes the previous assignee in the same edit, then comments who
approved it, so the issue never shows two assignees side by side. Without the flag, the refusal stands as before
([#4344](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4344)).

**Score:** 3

#### What makes this deploy extra special

Taking over a colleague's issue after they said "take it" is now one command that also unassigns them,
instead of a refusal and two hand edits.

**Score:** 3

#### Pull Request

claim-issue: an approved takeover removes the previous assignee in the same step

