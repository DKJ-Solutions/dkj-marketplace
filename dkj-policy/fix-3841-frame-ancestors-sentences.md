## fix/3841-frame-ancestors-sentences

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

#3841: #3834 and #3835 merged one after the other. Two sentences from #3834 still say the pages send no
`frame-ancestors`, and since #3835 they do. This branch rewords both. The wording now matches what the code does.

### CREATE

- [x] `loopback-server-lib.ps1`, the `Test-LoopbackCrossSite` docstring: `Dest` is the first barrier, against a
      cross-site frame; the response header is the second, and the one that holds for a same-site frame.
- [x] `hub/README.md`, the Fetch Metadata paragraph: the same, with both header names.

### TEST

- [x] `frame-ancestors` grepped across the tree: no other sentence says the pages send none.

### DEPLOY: fix/3841-frame-ancestors-sentences

The hub's README no longer says that its pages can be framed by a page that is not refused. Since #3835 every response
forbids framing, and the paragraph on the Fetch Metadata check now says so.

**Score:** 1

#### What makes this deploy extra special

It corrects a contradiction between two merged branches. Nothing about the behaviour changes.

**Score:** 1

#### Pull Request

Hub: the docs say the loopback pages forbid framing, as they do since #3835

