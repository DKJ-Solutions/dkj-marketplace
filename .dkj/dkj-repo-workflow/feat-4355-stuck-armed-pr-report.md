## feat/4355-stuck-armed-pr-report

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

Part 3 of #4355 (parts 1 and 2 shipped in #4358): `ship-pr -HandOff` leaves nobody watching CI, so the
next sweep has to see an armed pull request that merge-on-green is not going to merge. Built into the
existing `check-stranded-sweep.ps1` rather than a new script: it already reads every armed pull request
and its required checks within a bounded budget, and its session hook already forwards its findings.

### CREATE

- [x] `Get-MergeOnGreenStuckVerdict` + `Get-MergeOnGreenStuckHours` (2) in `merge-on-green-lib.ps1`: a failed required check or a conflict is stuck at once; anything else after two quiet hours (`updatedAt`); a stranded pull request is not also stuck
- [x] `check-stranded-sweep.ps1` reads `updatedAt`, takes `-StuckHours`, prints `[STUCK]` with the reason and the resume lines
- [x] `stranded-sweep-sessioncheck` forwards `[STUCK]` like `[STRANDED]`
- [x] `issues-sweep` step 1 runs the check before `-Candidates`; step 5 says a red hand-off comes back there
- [x] plugin mirrors of the lib and the check synced

### TEST

- [x] `merge-on-green-lib.tests.ps1`: 13 new asserts on the verdict (red, conflict, pending under/over the window, eligible-but-open, `-StuckHours`, no `updatedAt`, unarmed, stranded), 339 pass
- [x] `stranded-sweep-gate.tests.ps1`: `[STUCK]` end to end for red and five-quiet-hours, `-StuckHours 6` holds it back, the hook forwards it; 55 pass
- [x] live run against this repo's three armed pull requests: none stuck (CI and merge-on-green were both running), which is the right answer

### DEPLOY: feat/4355-stuck-armed-pr-report

`check-stranded-sweep.ps1` now reports `[STUCK]` beside `[STRANDED]`: an armed pull request whose required
check failed or that conflicts with the trunk is named at once, and any other armed one after two hours
without activity (`-StuckHours` moves that), each with the reason and the `git checkout` and `ship-pr`
lines. The session-start hook forwards it, and `issues-sweep` step 1 runs the check before choosing, so a
pull request a sweep handed off with `ship-pr -HandOff` that then went red is seen by the same sweep or
the next one.

**Score:** 3

#### What makes this deploy extra special

A sweep that hands its pull requests off no longer hides a red one: after taking this release, a red or
stuck hand-off shows up at the next session start and at the next sweep's first step, with the commands
to resume it, instead of sitting armed and open until somebody happens to look.

**Score:** 2

#### Pull Request

Report an armed pull request that merge-on-green will not merge, at session start and at sweep step 1
