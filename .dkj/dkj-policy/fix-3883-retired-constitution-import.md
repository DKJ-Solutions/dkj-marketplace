## fix/3883-retired-constitution-import

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

- [x] Verify #3883's reason in the source: the constitution step passes no `-ReplacePattern`, its
  `-ImportedPattern` accepts any marketplace name, and `Test-ConstitutionImported` counts the dead row
  too, so a plain replace pattern alone would have REMOVED the line instead of rewriting it.
- [x] Keep `claude-code-specialists` valid: the business publication still ships under that
  marketplace name, and `adopt-workflow-folder.tests.ps1` pins it as kept.

### CREATE

- [x] `claude-md-import-lib.ps1`: `Get-RetiredMarketplaceNames` (`dkj-claude-plugins`, never the
  segment the running lib sits under) and `Get-RetiredConstitutionImportPattern`; `Test-ConstitutionImported`
  no longer counts a row under a retired name; `Add-ClaudeMdImportLine` tests `-ReplacePattern` before
  `-ImportedPattern`. Mirrored into dkj-policy and bwj-development.
- [x] `adopt-workflow-folder.ps1`: the constitution step passes the retired pattern and reports
  `[renamed]` / `[removed]`.

### TEST

- [x] `adopt-workflow-folder.tests.ps1`: a retired line is rewritten in place, a re-run keeps it, and
  beside the current line it is only removed. `consumer-prose-gate.tests.ps1`: the detector skips a
  retired name, except where the lib itself runs from under it, and still counts `claude-code-specialists`.

### DEPLOY: fix/3883-retired-constitution-import

`adopt-workflow-folder` now rewrites a constitution import that still names the retired
`dkj-claude-plugins` marketplace, the same way it already rewrote a retired extension import beside it.
Before, the dry run said `[keep]` and the repo silently loaded no constitution (#3883).

**Score:** 2

#### What makes this deploy extra special

A consumer that adopted before the `dkj-marketplace` rename gets its constitution back on the next
`adopt-workflow-folder -Apply`, and the session check now warns about the dead line until then.

**Score:** 2

#### Pull Request

adopt-workflow-folder rewrites a constitution import on the retired marketplace path
