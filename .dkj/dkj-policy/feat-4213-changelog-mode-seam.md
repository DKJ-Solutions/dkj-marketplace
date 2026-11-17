## feat/4213-changelog-mode-seam

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

#### The shape

One `decide` seam, `Get-ChangelogMode` (`'fold'` default, `'none'`), read through a new leaf lib
`changelog-mode-lib.ps1`. It is a leaf, not part of seam-lib, because park-cycle runs after every turn.
Under `'none'` the branch document is written but never committed: it is named in the clone's
`.git/info/exclude`, so there is nothing to park and nothing for a fold to remove. That is what keeps the
other stand-downs small.

### CREATE

- [x] `scripts/lib/changelog-mode-lib.ps1`: the resolver, the stand-down sentence, and the exclude helpers; registered as a shared lib and mirrored
- [x] The contract record (`decide`, ViaLib `changelog-mode-lib`), the blueprint rebuilt, and this repo stating `'fold'`
- [x] new-branch: no park commit under `'none'`, the document excluded locally
- [x] park-cycle (the autopark hook) parks nothing
- [x] open-pr: the entry gates and the document commit stand down; the document still names and describes the PR
- [x] check-branch-entry and check-unfolded-entry stand down with an `[OK]`
- [x] fold-changelog-entry exits 0 with nothing to fold; ship-pr removes the local document and its exclude line after the merge
- [x] cut-release refuses, naming the seam
- [x] CONTRIBUTING-portable.md: the lighter route described under the Fold step

### TEST

- [x] `changelog-mode.tests.ps1` (38 asserts): the resolver, the exclude helpers, and a consumer answering `'none'` end to end -- one-file change, no `park:`/`fold:` commit on the trunk, quiet gates, cut refused
- [x] script-contract suite: the record count is 50, and this repo states the seam
- [x] The fixtures that copy libs one at a time now copy the new lib; new-branch, park-cycle, fold, worktree-lane, park-branch, prune-merged and internal-note suites green

### DEPLOY: feat/4213-changelog-mode-seam

Inside this repo, a new leaf lib (`changelog-mode-lib.ps1`) and one contract record (now fifty) carry
the seam. This repo states `'fold'`, and the fixtures that copy libs one by one now copy the new lib too.

**Score:** 1

#### What makes this deploy extra special

A repo whose changelog nobody reads can now drop the ceremony around it. Add
`function Get-ChangelogMode { 'none' }` to `scripts/repo-config.ps1`, and from then on a branch carries
its work commits and nothing else: no `park:` commit at creation or after a turn, and no `fold:` commit on
the trunk after the merge. The branch document is still written for the session and still names and
describes the PR, but it is never committed, and the PR body becomes the record. The entry gates, the CI
`Branch entry` check and the unfolded-entry session check stand down. `cut-release` refuses and names the
seam. Every other repo keeps the full route without changing anything
([#4213](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4213)).

**Score:** 3

#### Pull Request

A Get-ChangelogMode seam: a consumer with no changelog reader skips the park and fold commits

