## fix/4404-closing-step-answer-to-pr-box

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

Inbound #4404, the issue's option 1, built the way #3958 built the owner's look: the branch document's
closing step (`Get-BranchClosingSteps`) answered "not visible" never reached the PR body, so a consumer's
Preview check went red and `ship-pr` merged anyway, eleven times. The other half of option 1 (tick "no
theme file" when the diff touches no theme directory) needs the consumer's theme directories, which the
shared script does not know; the consumer's own CI keeps judging that case.

### CREATE

- [x] `Get-ClosingStepNotVisibleAnswer` in `pr-body-lib.ps1`: reads the closing step under CREATE and
  returns the reason for `- [~] <step> <reason>` or `- [x] <step> No -- <reason>`, '' otherwise.
- [x] `open-pr`: an optional `Get-PrNotVisiblePattern` seam names the template box; the reason ticks it on
  a new PR, an open PR and a supplied `-Body`, reusing `Set-PrOwnerLookAnswer`.
- [x] The seam is listed with the other optional Pr seams (`check-script-contract.ps1`, `bootstrap.ps1`)
  and documented in the `open-pr` skill.

### TEST

- [x] `pr-body.tests.ps1`: 11 new asserts on the parser (each answer shape, every separator, ticked
  without No, reasonless No, open, missing, under another section). The suite passes; the full gate runs in
  `ship-pr`.

### DEPLOY: fix/4404-closing-step-answer-to-pr-box

`open-pr` now carries the branch document's answer to the repo's closing step into the PR body: where
that step is answered "not visible" (`- [~] <reason>`, or `- [x] ... No -- <reason>`) and the repo names
its template box with the new optional `Get-PrNotVisiblePattern` seam, that box is ticked with the reason
(#4404).

**Score:** 3

#### What makes this deploy extra special

A store repo that names its "nothing a visitor can see" box once no longer gets a red Preview check on a
change the branch already judged invisible, so it is no longer ticked by hand after the merge.

**Score:** 3

#### Pull Request

open-pr: carry the branch's 'is the change visible?' answer into the PR's not-visible box

