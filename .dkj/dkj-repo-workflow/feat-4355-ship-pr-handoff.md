## feat/4355-ship-pr-handoff

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

Issue #4355, parts 1 and 2: a sweep stops sitting through CI once its PR is armed. Part 3 (the next
sweep reports an armed PR that stays unmerged, e.g. on a red check) stays open on the issue.

### CREATE

- [x] `ship-pr.ps1 -HandOff` (and its plugin mirror): at the clearance line, a Clearable verdict closes
  the CI progress bar, prints the receipt and exits 0; merge-on-green merges and fold-on-merge folds. Not
  Clearable, it says so and watches CI as before, so a hand-off never strands a PR.
- [x] `issues-sweep` step 5 ships with `-HandOff` and goes straight to step 7; its close-out lists a
  handed-off PR as "armed, merges via merge-on-green". `ship-pr` skill page documents the switch.

### TEST

- [x] `merge-on-green-lib.tests.ps1`: four source-text asserts (switch declared; the Clearable block
  exits 0 before the CI watch; the not-clearable block does not exit). Green, as are
  `native-capture.tests.ps1` and `check-plugin-integrity.ps1`.
- [x] `closeout-lib.tests.ps1` caught the new receipt ending; ship-pr's ending count moved 2 -> 3 with
  the reason.
- [x] This branch is shipped with `-HandOff` itself, the first live run.

### DEPLOY: feat/4355-ship-pr-handoff

`ship-pr.ps1` gains `-HandOff`; `issues-sweep` step 5 uses it.

**Score:** 2

#### What makes this deploy extra special

An `issues-sweep` no longer waits out CI after each shipped issue: `ship-pr -HandOff` leaves an armed PR
to merge-on-green and the sweep goes on to the next issue in the same turn. Where the PR cannot be handed
off safely, ship-pr says why and waits as before.

**Score:** 4

#### Pull Request

ship-pr -HandOff: a sweep hands an armed PR to merge-on-green and goes on

