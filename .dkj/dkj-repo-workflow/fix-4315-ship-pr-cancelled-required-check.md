## fix/4315-ship-pr-cancelled-required-check

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

#4315: on PR #4311 a resumed ship printed "every REQUIRED check is green" about a `lint-en-tests` run
that the concurrency group had cancelled, then met a merge the ruleset refused.

#### The reason, verified against the code

The issue points at the cancelled-record guard at `ship-pr.ps1:1852`. That guard sits in
`Wait-ForwardedCertificate`, which only step 3b's forward lap enters, so it never ran here. The
ordinary step-3 loop is where the run went through. gh counts a `cancel` bucket as skipped, so
`gh pr checks --watch --required` exits 0. `Get-MergeBlockVerdict` reads the cancelled record as
concluded, so `UnfinishedRequired` is empty, and the loop broke out on the green line.

### CREATE

- [x] In step 3's watch loop, a green watch with no unfinished required check now asks
  `Get-CancelledCheckRunIds` too. On a cancelled required record it waits for the superseding run
  through `Wait-ForwardedCertificate`, with the cancelled ids as the run set to look past. It then
  re-enters the watch, so the new run's answer, green or red, reaches the ordinary verdict. A
  timeout, or a cancelled record on the last watch attempt, refuses without merging.
- [x] The plugin mirror `plugins/dkj-repo-workflow/scripts/release/ship-pr.ps1` is kept
  byte-identical.
- [x] `pr-issues.tests.ps1` pins both halves structurally.

### TEST

- [x] The suites and the lint gate run under `ship-pr`.

### DEPLOY: fix/4315-ship-pr-cancelled-required-check

`ship-pr`'s CI wait no longer reads a cancelled required check as green (#4315). When the watch
ends on a required run that the concurrency group cancelled, it now waits for the run that replaced
it, the way the forward lap already did (#3331). Without that, it attempted a merge the ruleset
refused.

**Score:** 2

#### What makes this deploy extra special

A ship whose PR got a second `pull_request` run on the same head no longer ends red, with
"NOT merged, NOT folded", on a branch that was fine. It now waits for the run that counts and
merges on its answer.

**Score:** 2

#### Pull Request

ship-pr waits for the superseding run when a green watch leaves a required check cancelled

