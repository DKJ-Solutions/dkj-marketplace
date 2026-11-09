## feat/3906-docs-coverage-page

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

#### The shape (#3906)

An overview on the product (`/docs-coverage`) with one house card link per opportunity, its status as the card's
value, and a page of its own per item one level down (`/docs-coverage/<slug>`), the breadcrumbs the way back. An
item's idea and what the docs said about it are fixed text in `scripts/lib/docs-coverage-lib.ps1`, as a sweep
verified them on November 8, 2026 (the comments on #3895 to #3904). The status is live: one `gh api graphql` call,
cached like the DKJ repos page.

### CREATE

- [x] `scripts/lib/docs-coverage-lib.ps1`: the ten items, the status query and its parse, the status word, both pages
- [x] The product's menu and home card (`Get-ProductPages`), and the server's routes, cache and `/refresh` target
- [x] Tests in `scripts/tests/dev-pages.tests.ps1`, and the three asserts that pin the product's page list
- [~] The owner looks at the pages: not done as a separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-09 without one.

### TEST

### DEPLOY: feat/3906-docs-coverage-page

The product's home page has a **Docs coverage** card
([#3906](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3906)). It opens an overview of the ten Claude
Code features a comparison of the official docs against v6.11.0 found unused here (#3895 to #3904), one card each
with its live status (Open, In progress, Awaiting decision, In review, Waiting, Done or Declined). Each card opens
the item's own page: its idea, and what the docs turned out to say when a sweep checked it, including the
corrections to what the issue assumed. The status is read from the issues with one GraphQL call. The ideas are
fixed text, so a later change to an issue's content is copied in by hand.

**Score:** 3

#### What makes this deploy extra special

N/A: the product portal is this repo's own local server, and no plugin ships it.

**Score:** N/A

#### Pull Request

Product portal page: the ten Claude Code docs-coverage opportunities

