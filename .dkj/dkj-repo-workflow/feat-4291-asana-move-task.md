## feat/4291-asana-move-task

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

Inbound #4291: one store carries a manual "move this Asana task to stage N" script, and the other store
lacks it. It ships in `dkj-repo-workflow-bwj` and resolves the section by the same rule the CI runners
use.

- **The section rule is in one lib**, `asana-section-lib.ps1`. The CI templates cannot dot-source it,
  because they are copied into a consumer's `.github/scripts/`. So the suites hold the templates' copies
  of `Get-SectionCode` and `New-AsanaMoveRequest` equal to the lib's, run over one table of section
  names. The lib takes the template's rule, not the store's: the store's copy upper-cased the code and
  returned `$null`, so the two rules differed. Case folds only in the lookup.
- **Only the repo's own board (#4282).** A task that is not on the board `Get-AsanaProjectGid` names is
  skipped, because `addTask` would otherwise add it to a board it was never on.
- **What it reuses:** the CI runners' `Resolve-AsanaTaskRef`, `Invoke-AsanaGhBounded` and
  `Resolve-BwjRepoRoot`. The task link is read from the issue body only, as the runners read it. The
  store copy also read comments.

### CREATE

- [x] `scripts/lib/asana-section-lib.ps1`, `scripts/task/move-asana-task.ps1` and the `move-asana-task` skill, plus a README row
- [x] Equality holds between the lib and both templates, in `dkj-repo-workflow-bwj.tests.ps1` and the new suite
- [x] Store task GIDs and issue numbers that the store copy carried are replaced with made-up ones (public repo)

### TEST

- [x] `bwj-asana-move-task.tests.ps1` 57 passed; `dkj-repo-workflow-bwj.tests.ps1` 1072 passed; `test-suite-gate.tests.ps1` 349 passed; `check-plugin-integrity` 0 errors.
- [x] The full gate runs in `ship-pr`.

### DEPLOY: feat/4291-asana-move-task

`dkj-repo-workflow-bwj` ships a `move-asana-task` skill. It moves an issue's Asana task to a section of
the repo's own board, named by stage code, with a dry run, and resolves the section by the same rule as
the CI runners. Before this, only one store had such a script
([#4291](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4291)).

**Score:** 3

#### What makes this deploy extra special

A session in either BWJ store can move a card on request without a raw Asana API call, which auto mode
refuses. It does so without picking a different section than the CI runners would.

**Score:** 3

#### Pull Request

Ship a manual move-Asana-task-to-stage script in dkj-repo-workflow-bwj

