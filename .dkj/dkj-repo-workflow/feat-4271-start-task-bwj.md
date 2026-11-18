## feat/4271-start-task-bwj

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

Part of step 2 of #4259. Both BWJ store repos carry their own `scripts/task/start-task.ps1`, and the two
have diverged (201 and 375 lines). This branch reconciles them into one copy in `dkj-repo-workflow-bwj`.
Removing the store copies is step 3 (#4274).

### CREATE

- [x] **The base is the second store's copy.** It is a later port of the first, plus four hardenings: it
  refuses a base that is not the trunk (`-Base`/`-Stacked`), refuses a missing Shopify CLI, refuses a
  `dependabot/` name, and checks the git identity. The first store's copy has no behaviour the second lacks.
- [x] The git-identity check is dropped. The shared `new-branch.ps1` refuses through `Test-GitCanCommit`
  (lines 469-495) before it creates anything, so the store check duplicated it. One gap remains: with
  `-Base`, the checkout of the base has already happened by then.
- [x] `scripts/task/start-task.ps1`, `scripts/lib/branch-base.ps1` (whole lib, `Get-CarriedBranchVerdict`
  included, so step 3 can drop the store copy) and `scripts/lib/machine-preflight.ps1` are authored
  directly in the extension, like `notify-live`. They are bwj-only, so they are not shared-script pairs.
- [x] Store facts come through seams. The trunk is read from `Get-TrunkBranchName` in `repo-config.ps1`,
  the prefix table from the checkout's own `scripts/lib/branch-info.ps1`, and the store domain from
  `Get-ShopifyStoreDomain` (`<your-store>.myshopify.com` where it is absent). `new-branch` resolves through
  `Resolve-PluginScript`. Store-tracker issue numbers became "a store issue". `-RootOverride` was added.
- [x] Skill page `skills/start-task/SKILL.md` and a row in the extension README.

### TEST

- [x] `start-task.tests.ps1` (53 asserts: each refusal, the base refusal off-trunk, a stubbed CLI),
  `branch-base.tests.ps1` (47) and `machine-preflight.tests.ps1` (15), all registered in the `bwj` group.
- [x] `dkj-repo-workflow-bwj.tests.ps1` 0 failures. `check-plugin-integrity` and `check-script-contract`
  report 0 errors.

### DEPLOY: feat/4271-start-task-bwj

`dkj-repo-workflow-bwj` now ships `start-task`, the store layer over the shared `new-branch` (#4271). It
refuses a missing Shopify CLI, a `sync/` or `dependabot/` name, an unknown prefix, a double quote in the
title, and a base that is not the trunk unless `-Base` or `-Stacked` says so. It checks all of this before
anything is created. It reconciles the two diverged store copies into one, which reads the trunk, the
prefix table and the store domain from the store's own seams.

**Score:** 2

#### What makes this deploy extra special

A fix to how a store task starts now reaches both stores with a release, instead of being made twice by
hand.

**Score:** 2

#### Pull Request

Move start-task into dkj-repo-workflow-bwj, reconciled from both store copies

