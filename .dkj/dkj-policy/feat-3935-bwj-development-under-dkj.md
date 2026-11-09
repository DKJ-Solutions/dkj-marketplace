## feat/3935-bwj-development-under-dkj

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

- [x] Verify inbound #3935 still stands: every page named in it still placed the folder in the root,
  and the adopt step that scaffolds it is prose (step 7 of `adopt-bwj-development`), not a script.

### CREATE

- [x] Repoint the documented default and the `Get-ShopifySyncLogPath` example answer to
  `.dkj/bwj-development/SYNC-LOG.md` in `SYNC-LOG-portable.md`, the extension README, the adopt skill,
  the marketplace description, the teams README and the example comment in both `sync-main.ps1` copies.
- [x] Adopt step 7 moves an existing root `bwj-development/` the way `adopt-dkj-policy` Part 1 moves a
  root `dkj-policy/`, and leaves both folders alone when the new one already exists.

### TEST

- [x] Docs and one comment line; `ship-pr`'s gates prove the tree.

### DEPLOY: feat/3935-bwj-development-under-dkj

bwj-development's sync log now lives at `.dkj/bwj-development/SYNC-LOG.md`, beside `.dkj/dkj-policy/`,
instead of in the consumer's root: the pages, the `Get-ShopifySyncLogPath` example answer and the
adopt step all name the new place, and the adopt step moves an older root `bwj-development/` there
(#3935). No script reads a fixed path, so a repo whose seam still answers the old path keeps working
until it moves.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a BWJ store repo that still keeps a root `bwj-development/` sees the adopt step
propose the move; nothing breaks if they leave it.

**Score:** 2

#### Pull Request

bwj-development's sync-log folder moves under .dkj/bwj-development/

