## feat/3758-live-push-merged-only

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

Inbound #3758 from xoxowildhearts#487: the owner ruled to enforce merged-only in `guard-live-theme`
and to add no account check. Verified on pickup: line 347 authorised a live push on the marker alone.
The repair names real mechanisms (`Get-TrunkBranchName`, sync-rules' raw and CR-stripped blob ids).

### CREATE

- [x] `guard-live-theme.ps1`: rule 3's second half compares every `--only` file (or the whole clean root)
  with `origin/<trunk>`, refuses what it cannot read, and measures every live push on the line
- [x] `guard-live-theme.tests.ps1`: group 10, plus merged fixtures under the existing marker cases
- [x] README: rule 3 row and a "Merged work only" section

### TEST

- [x] `guard-live-theme.tests.ps1` standalone: 249 passed, 0 failed
- [x] Code and security review: five ways around the first cut closed, each with a case (`Push-Location`
  and `cd..`, `-o=<file>`, a non-ASCII name, a bare word after `--only`, a skip-worktree file); 255 passed

### DEPLOY: feat/3758-live-push-merged-only

`guard-live-theme` no longer lets the live-push marker authorise a push on its own (#3758). An
authorised live push must also carry only what `origin/<trunk>` holds: every `--only` file must match
the trunk byte for byte (a line-ending difference aside), a file the push would delete must be absent
from the trunk too, and a push without `--only` needs a clean root whose commit equals the trunk. The
refusal names each file and says to merge first. A pattern or directory in `--only`, a shell-expanded
value, a `cd`, `--environment`, a `SHOPIFY_FLAG_ONLY`/`_PATH`/`_ENVIRONMENT` on the line, or a missing
`origin/<trunk>` is refused, because what it would push cannot be read. The trunk is
`Get-TrunkBranchName`, default `main`. A second live push on the same line is measured too.

**Score:** 3

#### What makes this deploy extra special

In a Shopify store repo, a live push of work that is not merged into the trunk is now refused even with
the marker, so live can no longer hold work the trunk lacks, which a later push from the trunk would
silently revert. The step-7 push `live-preflight` composes from the merged trunk passes as before.

**Score:** 3

#### Pull Request

guard-live-theme refuses a live push of content the trunk does not hold

