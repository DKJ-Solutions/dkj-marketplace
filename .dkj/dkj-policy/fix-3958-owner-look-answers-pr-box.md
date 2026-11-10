## fix/3958-owner-look-answers-pr-box

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

Inbound #3958: `issues-sweep-reviews` records the owner's approval on the issue and in the branch
document, but nothing writes it into the PR, so a consumer template's Preview box stays empty and the
consumer's own check, which requires one box ticked, goes red. Verified: the Preview section and its
`preview-answered` job are the consumer's own (4.17.0 declined to ship them), so the source's part is a
way to carry the approval into the PR body. `Get-PrApprovalPattern` cannot do it: it ticks on every PR.

### CREATE

- [x] `Set-PrOwnerLookAnswer` in `pr-body-lib.ps1`: tick the first line a pattern matches, append the answer, idempotent
- [x] `open-pr -OwnerLook` on both paths (fresh PR and already open), the box named by the optional seam `Get-PrOwnerLookPattern`; `ship-pr` forwards it
- [x] `issues-sweep-reviews` step 4 and `issues-sweep` step 6 pass the approval; the optional-seam lists name the new seam
- [x] Mirrors rebuilt with `build-shared-scripts.ps1`

### TEST

- [x] `pr-body.tests.ps1`: tick + answer, other boxes untouched, idempotence, multi-line folding, no match, empty input, CRLF
- [x] `script-contract.tests.ps1`: the new seam stays outside the contract like the other optional `Get-Pr*`

### DEPLOY: fix/3958-owner-look-answers-pr-box

`open-pr` and `ship-pr` take `-OwnerLook "<answer>"`, the owner's recorded look at a visible result. A
repo whose PR template has a box for that look names it with the optional seam `Get-PrOwnerLookPattern`
in `scripts/repo-config.ps1`, and `open-pr` ticks that box and writes the answer after it, on a fresh PR
and on one already open. `issues-sweep-reviews` (step 4) and `issues-sweep` (step 6) now pass the
approval they recorded, with the link to the approval comment. Inbound #3958, measured on
BWJ-Development/xoxowildhearts#499: the approval reached the issue and the branch document but never the
PR, so the consumer's Preview check, which requires one ticked box, went red on every approved ship.
Without the seam nothing changes except a one-line note that the box was not written.

**Score:** 2

#### What makes this deploy extra special

A consumer whose template carries a Preview box can now ship an approved visible result without editing
the PR body by hand: define `Get-PrOwnerLookPattern` (a regex for the unticked box line) once, and every
`issues-sweep-reviews` ship answers it. Repos without such a box notice nothing.

**Score:** 3

#### Pull Request

The owner's approval answers the PR template's owner-look box

