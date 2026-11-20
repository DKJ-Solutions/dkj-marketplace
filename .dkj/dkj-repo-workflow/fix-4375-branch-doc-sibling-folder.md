## fix/4375-branch-doc-sibling-folder

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

Inbound #4375: a folder beside a branch document (`<doc-stem>/`, review screenshots in the measured case)
survives the fold, which removes only the document. Verified in `fold-changelog-entry.ps1`. The fold is a
bounded trunk exception (CHANGELOG.md and the document), so it is not widened; the folder is refused
before the merge instead, at the branch-entry gate.

### CREATE

- [x] `entry-scaffold-lib.ps1`: `Get-BranchSiblingFolderFindings` (paths added or modified under `<doc-stem>/`, against the merge-base with the trunk, or HEAD^1 on a PR merge commit) and `Get-SiblingFolderRefusalLines`, one wording for both gates
- [x] `check-branch-entry.ps1` (CI) and `open-pr.ps1` (local) refuse such a branch; not `-Force`-able
- [x] Both branch-entry runners fetch depth 2, so the CI half has the PR's base to diff against
- [x] The check-branch-entry skill page lists the new refusal; root mirrors kept byte-identical

### TEST

- [x] `branch-entry-gate.tests.ps1`: folder file refused, document-only passes, other workflow-folder file passes, untracked refused, deleted passes, open-pr call pinned -- 92/92
- [x] The HEAD^1 fallback checked by hand on a merge-commit fixture with no trunk ref: the folder file is found

### DEPLOY: fix/4375-branch-doc-sibling-folder

The branch-entry gate, in `open-pr` and in CI, refuses a branch that adds files under a folder named after
its own branch document, which the fold would leave on the trunk (#4375).

**Score:** 2

#### What makes this deploy extra special

A branch that commits review screenshots or other files beside its branch document is now stopped at
`open-pr` and by the Branch entry check, with the files named and where they belong instead (the PR or the
issue). Before, the folder slipped past every gate and stayed on the trunk after the merge until somebody
noticed it.

**Score:** 2

#### Pull Request

Branch-entry gate refuses files in a folder beside the branch document
