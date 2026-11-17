## feat/4228-prune-orphan-branch-documents

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

Issue #4228: under `Get-ChangelogMode 'none'`, ship-pr removes the untracked branch document and its
`.git/info/exclude` line only on its ordinary end and the "already merged" exit. Verified in
`ship-pr.ps1`: `Remove-ShipNoneBranchDocument` has exactly those two call sites. The issue's proposal is
followed: prune-merged (which tidy-machine delegates to) sweeps what no live branch owns.

### CREATE

- [x] `Remove-OrphanBranchDocumentExclude` in `changelog-mode-lib.ps1`: per exclude line naming a
  per-branch document, delete an untracked document whose declared branch is not live, then its line;
  drop a line whose document is gone; leave tracked documents, undeclared ones and the user's own lines.
- [x] `prune-merged.ps1` step 4e calls it after the reap, with local branches plus `refs/remotes/<remote>`
  as the live set (under `-DryRun` the would-be reaps count as gone), and prints each removal.
- [x] Both files mirrored into `plugins/dkj-repo-workflow/scripts/`.

### TEST

- [x] `changelog-mode.tests.ps1` section 4: after section 3's merge, `-DryRun` names the orphan and
  changes nothing; the real run removes the merged branch's document and line and a dangling line, and
  keeps a live branch's document and line and the user's own `*.tmp` line (57 pass).
- [x] `prune-merged.tests.ps1` unchanged and green (128 pass).

### DEPLOY: feat/4228-prune-orphan-branch-documents

`prune-merged` (and so `tidy-machine`) gained step 4e and `changelog-mode-lib.ps1` the function behind
it; a repo answering `'fold'` has no such exclude lines, so the step stays silent there.

**Score:** 1

#### What makes this deploy extra special

In a repo that answers `Get-ChangelogMode` with `'none'`, `prune-merged` now removes a local branch
document and its `.git/info/exclude` line once the branch is gone locally and on the remote (#4228).
Before, a ship that stopped early (merge queue, a held merge, a failure after the merge) left both
behind for good. It prevents a failure that has not happened yet: an exclude file growing one line
per such branch.

**Score:** 1

#### Pull Request

prune-merged sweeps orphaned 'none' branch documents and their exclude lines

