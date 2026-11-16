## fix/4193-parking-verdict-per-label

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

Resolves #4193. The issue names `Format-ParkingLabelVerdict`, but the function is `Format-ParkingLabelNote`
in `scripts/lib/claim-issue-lib.ps1`. The cause it states still holds: one fixed "waiting on an ANSWER"
text for every parking label, plus two follow-up lines in `claim-issue.ps1` that say the same thing.

### CREATE

- [x] `Get-ParkingWaitKind` classifies the matched labels as `answer` (the decision and information labels,
      including their former names), `session` (`awaiting-session-dev` alone) or `other` (everything else);
      where several labels match, the strictest wins
- [x] `Format-ParkingLabelNote` and the two follow-up lines in `claim-issue.ps1` read per kind
- [x] Plugin mirrors of the lib and the script kept byte-identical
- [x] Asserts in `claim-issue.tests.ps1` for every kind and for precedence

### TEST

- [x] `claim-issue.tests.ps1` on its own: 708 passed, 0 failed (11 new asserts)

### DEPLOY: fix/4193-parking-verdict-per-label

`claim-issue` now gives each parking label its own verdict. Before, every label printed the same
"waiting on an ANSWER ... not yours to give" text. A session claiming an `awaiting-session-dev` issue
(#4066) was told to stop, even when it was the session that issue had been parked for. Now that label
says to lift it and carry on. A wait on a pull request, a release, an act, a look or a recurrence is
named as a wait. The decision and information labels keep the original text (#4193).

**Score:** 2

#### What makes this deploy extra special

A session the owner opens to work an issue parked under `awaiting-session-dev` is now told to go ahead
instead of stopping.

**Score:** 2

#### Pull Request

claim-issue: the parking verdict reads per label, so awaiting-session-dev is not told it waits on an answer

