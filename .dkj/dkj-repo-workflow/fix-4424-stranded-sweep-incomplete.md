## fix/4424-stranded-sweep-incomplete

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

Verify the cause before repairing (#4424 left it open). Measured on November 23, 2026 against the 10
armed pull requests then open: every `gh pr checks --required` read took about 1 s, so the 90 s budget
was never the cause. Four of the ten exited 1 with `no required checks reported on the '<branch>'
branch` -- the state of every pull request whose required check (`lint-en-tests`, which runs after the
suite shards) CI has not created yet. The direction "judge this tag's own armed PRs first" is not
taken: with the real cause repaired, nothing is left unjudged to reorder.

### CREATE

- [x] `pr-scan-lib.ps1`: a required-check read that fails with gh's "no required checks reported" is
      judged as pending (`New-PrScanNotReportedVerdict`) instead of counted unjudged
- [x] `pr-scan-lib.ps1`: the scan records why each record went unjudged, and the `[INCOMPLETE]` line
      names the cause that hit, with the remedy that fits it
- [x] Root copy of the lib synced byte-identical to the plugin copy

### TEST

- [x] `stranded-sweep-gate.tests.ps1`: a not-reported read is judged `[OK]`; one quiet for five hours is
      `[STUCK]`; the failed-read and budget lines name their cause (60 asserts green)
- [x] `native-capture.tests.ps1`: bounded-site count 132 -> 133, with the new site audited (360 green)
- [x] `unshipped-pr-gate.tests.ps1` (49) and `shared-scripts.tests.ps1` (1352) green
- [x] Live run in this repo: `[OK] 10 armed pull request(s)`, where the session start had printed
      `[INCOMPLETE] judged 4 of 10`

### DEPLOY: fix/4424-stranded-sweep-incomplete

`check-stranded-sweep` and `check-unshipped-pr` no longer report `[INCOMPLETE]` for a pull request whose
required check CI has not created yet. `gh pr checks --required` exits 1 with `no required checks
reported` in that state, and the shared scan counted it as a failed read, so with several sweeps handing
off at once about half the armed pull requests went unjudged on every run, and a rerun never helped. That
answer is now judged as pending, so a required check that never appears turns into `[STUCK]` after the
quiet window instead of going unjudged forever. Where something does stay unjudged, the `[INCOMPLETE]`
line now says which cause hit (a failed read, the scan budget, or no number) and only suggests a rerun
when the budget was the cause.

**Score:** 3

#### What makes this deploy extra special

A consumer running `issues-sweep` gets step 1's hand-off check back: the `[STUCK]` report for a red or
silent hand-off now reaches every armed pull request, where it used to skip the ones still waiting on CI.

**Score:** 2

#### Pull Request

check-stranded-sweep judges a not-yet-reported required check as pending and names why a scan stopped
