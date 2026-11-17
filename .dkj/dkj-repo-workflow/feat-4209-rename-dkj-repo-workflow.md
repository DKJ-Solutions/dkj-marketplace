## feat/4209-rename-dkj-repo-workflow

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

dkj-policy becomes dkj-repo-workflow, dkj-solutions becomes dkj-repo-workflow-dkj, bwj-development becomes dkj-repo-workflow-bwj, and the workflow folder .dkj/dkj-policy/ becomes .dkj/dkj-repo-workflow/ as a hard cut

#### Decisions (owner, November 17, 2026, on #4209)

- Go on all three names. Extensions stay recognised by #2788's list (`Get-PolicyExtensionList`); the
  suffix is naming only.
- The workflow folder moves too, as a hard cut: the readers resolve `.dkj/dkj-repo-workflow/` alone, and
  only the adopt step's move reads the older names (`Find-LegacyWorkflowFolder`).
- Ships in the same release as #4211, so consumers migrate once.

#### The merge is the owner's to time

Consumers call the reusable CI workflows at `@main` with `scripts-ref` defaulting to `main`, so this
reaches every consumer's branch-entry and always-on-budget gate at the merge, not at the release. An
unmigrated consumer finds no branch document from that moment. So this PR waits for the owner's word,
to be merged right before the release cut that carries it.

### CREATE

- [x] `git mv` the plugin, both extensions, the two adopt skills, the bwj test suite and `.dkj/dkj-policy/` to their new names
- [x] Rewrite every live mention; keep dated history, the retired names (`dkj-policy-bwj`, `dkj-policy-dkjs`), the pre-#3871 layout, the root folder of #1437 to #3870, and the lifehub's `dkj-solutions/ai` dossier as written
- [x] Archived release notes: link targets repointed, prose untouched
- [x] `workflow-folder-lib.ps1`: readers resolve the current folder only; `Get-LegacyWorkflowFolderNames` / `Find-LegacyWorkflowFolder` for the adopt move
- [x] `adopt-workflow-folder.ps1` moves `.dkj/dkj-policy/` (and every older name) through `Find-LegacyWorkflowFolder`
- [x] `claude-md-import-lib.ps1`: `dkj-policy`, `dkj-solutions` and `bwj-development` mapped as retired ids; retired constitution and extension import lines under the old plugin directory detected and rewritten
- [x] `Get-SharedScriptLayoutFloor` raised to 6.19.0 / `.dkj/dkj-repo-workflow` (#4209)
- [x] Brand book: the reusable gate and the local tag-page fetch try the pre-#4209 paths for a tag cut before it
- [x] `check-plugin-integrity`: `*-repo-workflow` / `*-repo-workflow-*` accepted as the policy family
- [x] Shared-script mirrors rebuilt
- [ ] Test fixtures that modelled an unmoved consumer or the old names brought to the hard cut

### TEST

- [ ] The four gates green (`check-roster-sync`, `check-plugin-integrity`, `check-script-contract`, `check-unfolded-entry`)
- [ ] The full suite gate green

### DEPLOY: feat/4209-rename-dkj-repo-workflow

**Score:**

#### What makes this deploy extra special

**Score:**

#### Pull Request

Rename the workflow plugin and its extensions to dkj-repo-workflow, -dkj, -bwj

