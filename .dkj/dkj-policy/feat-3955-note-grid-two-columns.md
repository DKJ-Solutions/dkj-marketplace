## feat/3955-note-grid-two-columns

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

Inbound #3955 (the owner, November 10, 2026, from smartwatchbanden's v3.0.0 page): three note cards per row
leave about 14rem of text per cell inside the 52rem wrap, five words a line. Measured at the source: the
template's `.note-grid` rule is `minmax(max(14rem, (100% - 2 * gap) / 3), 1fr)`, as reported. This revises
the October 27, 2026 three-column decision at the owner's own request.

### CREATE

- [x] `.note-grid` stops at two columns: `minmax(max(20rem, (100% - gap) / 2), 1fr)`, about 22rem of text
  per cell on desktop, one column on a phone; the comment above it says why. Both byte-identical copies
  of `release-notes-page-template.html` (`scripts/release/` and the plugin mirror) carry it

### TEST

- [x] page rebuilt locally (`build-release-notes-page.ps1`); Admin's `/dev/release-notes/v6.12.0` serves
  the two-column rule (200)
- [~] the owner looks at the page and approves the layout -- not done as a separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-10 without one.

### DEPLOY: feat/3955-note-grid-two-columns

The release-notes page lays a section's note cards out two per row at most instead of three, so a card's
text gets about 22rem of line width on desktop instead of about 14rem, and a phone still gets one column
([#3955](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3955)). A consumer's page takes it at
its next `release-notes-page` run after the plugin release.

**Score:** 2

#### What makes this deploy extra special

A reader of a published release-notes page gets notes that read as paragraphs rather than five-word
columns.

**Score:** 3

#### Pull Request

Release-notes page: the note grid stops at two columns

