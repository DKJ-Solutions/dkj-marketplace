## fix/3885-repoint-skips-comments

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

Issue #3885: the folder-move repoint in `adopt-workflow-folder -Apply` rewrote quoted `dkj-policy/` paths
inside comments of `scripts/repo-config.ps1`, which turned a history comment into a false record
(dkj-lifehub PR #657). Restrict that one file's repoint to code lines, and name the comment hits it keeps.

### CREATE

- [x] `adopt-workflow-folder.ps1` (both copies, byte-identical): the `repo-config.ps1` row is `CodeOnly`;
  `#` lines and `<# ... #>` blocks are skipped and reported as `[kept]`.
- [x] The move test in `adopt-workflow-folder.tests.ps1` adds a `#` comment and a block comment with
  quoted old-folder paths: both are kept, the dry run counts 1 repoint and 2 kept.

### TEST

- [x] `adopt-workflow-folder.tests.ps1` alone: 172 of 172 asserts pass. The full gate runs in `ship-pr`.

### DEPLOY: fix/3885-repoint-skips-comments

When `adopt-workflow-folder -Apply` moves `dkj-policy/` to `.dkj/dkj-policy/`, it now repoints quoted paths
in `scripts/repo-config.ps1` only on code lines. A quoted path inside a `#` comment or a `<# ... #>` block
is left as written, and the run lists those as `[kept]`. Before this, the move rewrote history comments too,
so a comment recording an earlier seam value then claimed a value that was never set (#3885).

**Score:** 2

#### What makes this deploy extra special

A consumer still to move keeps its `repo-config.ps1` comments true, and no longer has to undo the rewrite
by hand the way dkj-lifehub did.

**Score:** 1

#### Pull Request

adopt-workflow-folder leaves comments in repo-config.ps1 alone on the move

