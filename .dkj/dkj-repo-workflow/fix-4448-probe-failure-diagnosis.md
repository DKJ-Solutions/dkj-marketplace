## fix/4448-probe-failure-diagnosis

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

Inbound #4448: in `Wait-CheckRegistration`'s narrowed arm a FAILED `gh pr checks --json` probe was read as
"not registered yet", polled for the full budget, and then refused with a sentence claiming other checks
had registered. Verified in the code before repairing: the `catch` discarded the exit code and gh's text,
and the caller's unnarrowed first wait is satisfied by any gh error text, so nothing ever proved a check
had registered.

### CREATE

- [x] Classify an unparseable narrowed probe: `no checks reported` stays "not yet", a non-zero exit otherwise is a probe failure, and a parsed payload (also on exit 8 or 1) resets the count
- [x] Refuse after `-MaxProbeFailures` (3) consecutive failures, quoting gh's text and exit code with a token diagnosis
- [x] Print "Other checks DID register" only when a poll saw one (`$everReported`), an honest variant otherwise
- [x] The progress line says gh failed instead of `0 check(s) have reported so far`
- [x] Mirror `plugins/dkj-repo-workflow/scripts/release/ship-pr.ps1` byte-identical

### TEST

- [x] `pr-issues.tests.ps1`: 1225 asserts pass, 11 of them new source-text asserts for #4448
- [x] Diff reviewed by the sweep before shipping

### DEPLOY: fix/4448-probe-failure-diagnosis

`ship-pr` no longer waits out its whole CI budget when `gh` cannot read the PR's checks: after three
failed reads in a row it stops, prints gh's own error and exit code, and says to check the token's
permissions. Its timeout refusal claims other checks registered only when one was actually seen (#4448).

**Score:** 2

#### What makes this deploy extra special

A token that cannot read checks used to cost a run its whole wait and then blame the ruleset; the real
cause is now on screen within about 45 seconds.

**Score:** 2

#### Pull Request

Wait-CheckRegistration surfaces a failing gh pr checks probe instead of blaming the ruleset

