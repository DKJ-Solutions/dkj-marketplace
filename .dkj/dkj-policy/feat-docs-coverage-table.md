## feat/docs-coverage-table

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

The owner (Dave, November 9, 2026) asked for the Docs coverage overview (#3906, PR #3922) as a table instead of
cards: ten items read better compared row by row. The item pages stay as they are.

### CREATE

- [x] `Format-DocsCoveragePageHtml` draws a house `.table` in a `.table-wrap`: Item (links its page), What,
      Status, Docs (links the docs page, shown as its path under /docs/en/), Issue (links GitHub); the card
      grid style is gone
- [x] The lib's docstrings say row instead of card
- [x] A Declined status carries the house `.info-button` "?", opening a `.tooltip--explain` with why it was
      declined: `WhyDeclined` on #3898 and #3900, taken from the decision that closed each issue;
      `Get-DocsCoverageTipScript` opens it on hover or focus, Escape closes it
- [x] Section and Group columns: where each docs page sits in the docs navigation, read from
      code.claude.com/docs/llms.txt (its `##` section and `####` group); the What column wraps through the
      page's own `.dc-what`, so seven columns fit the width
- [x] Section and Group link the page each opens on in the docs navigation (its first link in llms.txt, each
      answering 200); Docs links the heading on its page the item is about (`DocsAnchor`, each checked as an id
      on the live page)

### TEST

- [x] `dev-pages.tests.ps1`: the overview asserts read a table, one row per item, status, docs and issue per
      row, the docs section and group as links, the docs link to its heading, and the "?" only beside a
      Declined status with a reason (685/0);
      `check-house-style` OK
- [x] The product server on 4870 restarted and serves the table
- [ ] The owner's look at http://localhost:4870/docs-coverage

### DEPLOY: feat/docs-coverage-table

The Docs coverage overview on the product portal is a table now: one row per item with its one line, its
status, the section and group its Claude Code docs page sits in (each a link into the docs), a link to the
heading on that page the item is about, and a link to its issue, so the ten compare at a glance. A
Declined status carries a "?" that shows, on hover or focus, why the owner declined it. Each item still opens its own page.

**Score:** 2

#### What makes this deploy extra special

N/A: the Docs coverage pages are this repo's own product portal, which no consumer installs.

**Score:** N/A

#### Pull Request

Docs coverage overview as a table instead of cards

