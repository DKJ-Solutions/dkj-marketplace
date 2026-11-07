## feat/3882-triage-labels-sessioncheck

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

### CREATE

- [x] `hooks/triage-labels-sessioncheck.ps1`: runs `adopt-triage-labels.ps1` in-process and prints one line on a missing or off-colour label, silent otherwise
- [x] `adopt-triage-labels.ps1` (both copies): `-TimeoutSeconds` on its two `gh` reads, and out of the source-repo guard as a hook-invoked script, argued in `source-repo-guard.tests.ps1`
- [~] `issues-sweep` step 1 printing the same line: dropped, the session-start line already reaches every sweep before step 1

### TEST

- [x] `adopt-triage-labels.tests.ps1` section 10 covers the hook: 205 of 205 pass. `source-repo-guard.tests.ps1` 70 of 70 and `sessioncheck-dispatch.tests.ps1` 61 of 61 pass, and a live run here is silent in 1.6s
- [x] `native-capture.tests.ps1` audited count of bounded captures moved 108 -> 110 for the two `gh` reads, both judged by a positive `-eq 0`: caught by the first ship's test gate, 355 of 355 pass

### DEPLOY: feat/3882-triage-labels-sessioncheck

A new session check, `triage-labels-sessioncheck`, says in one line when this repo's tracker lacks any of the
canonical triage labels or carries one in a non-canonical colour, and names `adopt-triage-labels` as the
command that prints the fix. Until now nothing said so before a sweep's `gh issue edit --add-label` failed
(#3882). It runs `adopt-triage-labels.ps1` in-process with its `gh` reads bounded to 15 seconds, stays silent
when the labels are complete or the tracker cannot be read, and creates nothing, so #1895's print-only answer
stands. `adopt-triage-labels.ps1` leaves the source-repo guard as a hook-invoked script.

**Score:** 3

#### What makes this deploy extra special

A consumer whose tracker is missing triage labels is told at session start, with the one command that prints
every `gh label create`, instead of discovering it when a sweep fails to park an issue.

**Score:** 3

#### Pull Request

A session-start line when the tracker lacks the canonical triage labels

