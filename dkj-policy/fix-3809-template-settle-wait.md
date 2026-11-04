## fix/3809-template-settle-wait

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

Decided on #3809 (davekokbwj, November 4, 2026): the consumer template passes the same
`-WaitForSettleSeconds 660` cap as this repo's own runner, accepting the billed wait.

### CREATE

- [x] `adopt-ci-floor.ps1` (plugin copy and root mirror): the template's pick step passes
  `-WaitForSettleSeconds 660`, with a comment naming the billed cost; section 3's cost summary names it too
- [x] `.github/workflows/merge-on-green.yml`: the comment that said the template does not pass it now says it does
- [x] `adopt-ci-floor.tests.ps1`: asserts the placed template passes the cap

### TEST

- [x] `adopt-ci-floor.tests.ps1`: 318 passed, 0 failed

### DEPLOY: fix/3809-template-settle-wait

The merge-on-green workflow that `adopt-ci-floor` places in a consumer now waits out the settle window
the way this repo's own runner has since #3807. It passes `pick-merge-on-green.ps1 -WaitForSettleSeconds 660`,
so the last armed pull request to go green is merged within about 11 minutes instead of waiting
for the 3-hourly schedule. The template comment and the run's cost summary name the price on a private
repo: at most about 11 billed minutes, and only on a sweep the settle window alone refused
([#3809](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3809)).

**Score:** 3

#### What makes this deploy extra special

A consumer's maintainer who places or re-places the CI floor with `adopt-ci-floor` gets a merge-on-green
runner that no longer leaves the last green pull request waiting for hours, at the price of up to about 11
billed Actions minutes on the sweeps where the settle window alone held it back.

**Score:** 3

#### Pull Request

merge-on-green consumer template waits out the settle window

