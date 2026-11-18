## fix/4301-sync-summary-renamed-section

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

Closes #4301. `sync-summary`'s removed-section check read only status `D` rows; a section renamed in a
sync arrives as `R<score>\told\tnew`, and `ConvertFrom-SyncSummaryNameStatus` kept only the new path, so
a template still naming the old section name was never flagged. Verified in the code before repairing.

### CREATE

- [x] `ConvertFrom-SyncSummaryNameStatus` keeps the old path of a rename or copy as `OldPath`.
- [x] `Get-SyncSummaryFindings` treats a renamed section's old name as gone, unless the rename keeps the
  name inside `sections/`; the message names the new name.
- [x] The skill page says a renamed section counts.

### TEST

- [x] `shopify-sync-summary.tests.ps1`: unit asserts for the parser and four rename cases, and a fixture
  repo with a real `git mv`-style rename whose old name a template still references. 102 passed, 0
  failed; against the unfixed lib the 8 new asserts fail.

### DEPLOY: fix/4301-sync-summary-renamed-section

`sync-summary` now flags a section that a sync **renamed** while a template still points at its old
name, the same way it flags a deleted one: such a page returns HTTP 200 and renders nothing. Until now
only deletions were checked, so a rename slipped through as if nothing had gone.

**Score:** 2

#### What makes this deploy extra special

N/A: `sync-summary` has not been released yet, so this lands in the same release that first ships it and
no store repo ever runs the version with the gap.

**Score:** N/A

#### Pull Request

sync-summary flags a renamed section a template still references

Plugins: dkj-subagents-shopify

