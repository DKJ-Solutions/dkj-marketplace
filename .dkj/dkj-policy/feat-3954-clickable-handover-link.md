## feat/3954-clickable-handover-link

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

Inbound #3954 (smartwatchbanden#1149, November 10, 2026): a preview handover was reported as a bare
`http://localhost:4891/dev/handover/...` line, exactly as #3819's rule asks, and the owner could not click
it; the same address as a markdown link worked. Verified at the source: `build-handover-page.ps1` printed
`$state.Pages + $route` bare, and the constitution's visible-result rule said nothing about clickability.

### CREATE

- [x] `Format-HandoverLink` in `apps/admin/lib/handover-page-lib.ps1`: `[handover: <name>](<url>)`, the
  label a slug so it cannot break the brackets
- [x] `build-handover-page.ps1` prints its one link through it, and says to relay the line as it stands
- [x] the constitution's visible-result rule, `PREVIEW-portable.md` and `issues-sweep`'s close-out name the
  markdown-link form

### TEST

- [x] `handover-page.tests.ps1` asserts the reported line is the markdown link (40 passed, 0 failed)

### DEPLOY: feat/3954-clickable-handover-link

A visible result's report now gives its URL as a markdown link `[<label>](<url>)` on its own line, so the
owner can click it in the terminal: the constitution says so, and `build-handover-page.ps1` prints its one
link in that form ([#3954](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3954)). A bare URL had
reached the owner as text they could not open.

**Score:** 2

#### What makes this deploy extra special

Every handover a BWJ store session reports is now one click instead of a copy and paste.

**Score:** 2

#### Pull Request

The handover link is reported as a clickable markdown link

