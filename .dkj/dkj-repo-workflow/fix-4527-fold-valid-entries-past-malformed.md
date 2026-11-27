## fix/4527-fold-valid-entries-past-malformed

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

Inbound #4527: the fold pre-pass (`fold-changelog-entry.ps1`) exited 1 on the first entry whose impact
could not be honoured, so every valid entry stranded beside it stayed on the trunk and every later
unrelated merge turned `fold-on-merge` red. Verified in the script: the `$tierProblems` block refused the
whole run. The guardrail's intent (no half-folded state) is kept by judging in the pre-pass and only
narrowing the list the loop walks.

### CREATE

- [x] `fold-changelog-entry.ps1` (and its byte-identical plugin mirror): malformed entries are set aside
  in the pre-pass, the valid ones fold, and the run ends with exit 1 naming each set-aside entry and its
  reason. All-malformed refuses up front as before; exit 2 is untouched.
- [x] `fold-changelog.tests.ps1`: the pre-pass section now pins the new behaviour (good entry folded and
  removed, bad entry left untouched and named, exit 1).
- [x] Rendall's lens (05-06): the fold-all sentence describes the new behaviour.

### TEST

- [x] `fold-changelog.tests.ps1` 309 pass / 0 fail; `entry-scaffold.tests.ps1` passes (the all-malformed
  refusal still sits before the first changelog write). `fold-on-merge.yml` reads exit codes only, so it
  needs no change. ship-pr runs the full gate.

### DEPLOY: fix/4527-fold-valid-entries-past-malformed

The changelog fold no longer refuses a whole fold-all run over one malformed entry. It sets that entry
aside on the trunk, folds the valid entries beside it, and ends red naming the set-aside entry and why,
so a release cut in the meantime no longer misses changes that were written correctly.

**Score:** 3

#### What makes this deploy extra special

A repo whose trunk holds one malformed entry no longer sees its valid entries stranded with it, or every
unrelated merge's fold go red without folding anything.

**Score:** 3

#### Pull Request

fold-all folds the valid entries and leaves only the malformed ones stranded

