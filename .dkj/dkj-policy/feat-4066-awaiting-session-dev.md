## feat/4066-awaiting-session-dev

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

Issue #4066, name decided by the owner on the issue (davekokbwj, 2026-11-13): `awaiting-session-dev`.
Land it where #3515 landed `awaiting-release-external`: the canonical set, both pickup routes' skip
lists (so `-Park` accepts it), the docs that enumerate the family, and the issues-sweep skill's test for
when to use it.

### CREATE

- [x] `awaiting-session-dev` added to `Get-TriageLabels` (`scripts/repo-config.ps1`) and to `adopt-triage-labels.ps1`'s built-in fallback, both mirrors
- [x] Added to the `-Candidates` skip list and the single-issue route's default `$SkipLabel` in `claim-issue.ps1`, so a sweep skips it, a claim warns on it, and `-Park` accepts it
- [x] `issues-sweep` SKILL: the label, the test for using it (too large for one turn, not a missing capability), the park line, and who lifts it
- [x] Docs that list the family: `claim-issue` SKILL, `CONTRIBUTING-portable.md`, `scripts/README.md`, the script-contract text, the blueprint (rebuilt), Chris's and Derek's lenses
- [x] `repo-config.tests.ps1` now holds every canonical description to GitHub's 100-character limit: the first draft of this label's description was 109 characters, and `gh label create` refused it with HTTP 422
- [x] Tests: label counts and the expected set in `adopt-triage-labels.tests.ps1` and `repo-config.tests.ps1`; the `$SkipLabel` literal in `claim-issue.tests.ps1`

### TEST

The gates run inside `ship-pr`.

### DEPLOY: feat/4066-awaiting-session-dev

A new parking label, `awaiting-session-dev`, for an issue that can be worked on but is too large for
one sweep turn: several independent measurements, or more than one branch. `issues-sweep` parks such an
issue with `claim-issue -Tag -Park awaiting-session-dev -Reason "<the steps left>"` instead of holding it
out with `-SkipIssue`, which wrote nothing, read to the owner as skipped, and made every later sweep judge it
again. Both pickup routes skip it, a claim warns on it, and a person or a session told to work it lifts it.
`adopt-triage-labels` now prints it among the canonical labels ([#4066](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4066)).

**Score:** 3

#### What makes this deploy extra special

An owner reading a sweep's close-out sees an oversized issue parked under a label that says what it
needs, with the steps still to do in its parking comment, rather than an issue that looks skipped. Each consumer's
session-start check reports the new label as missing until `adopt-triage-labels` has created it.

**Score:** 2

#### Pull Request

issues-sweep: the awaiting-session-dev parking label

