## feat/4113-consumer-group-rows

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

Cause 5's first bullet of #4113: `/consumers/bwj` and `/consumers/other` were one long report -- a table of repos,
then every repo's check report with a "Back to overview" button -- which ran past a phone's screen, and no mobile
wireframe draws that form. The owner chose the DKJ group's form (November 15, 2026): the group page is a card per
repo, which the phone rule of #4121 draws as one card of compact rows, and each repo's report is a page of its own
at `/consumers/<group>/<name>`. `/docs-coverage` is #4111 and stays out of this branch.

### CREATE

- [x] `consumer-dashboard-lib.ps1`: a group page is its summary line and a `card-grid` of repo cards
  (`Format-ConsumerRepoCardLinkHtml`, shared with the Consumers overview); the table, the Issues card and its
  mini-cards are gone, with their styles
- [x] a repo's own page, `Format-ConsumerRepoPageHtml`, holding one card headed This machine
  (`Format-ConsumerRepoCardHtml`) whose paths and plugin ids wrap (`.cd-card`); `Get-ConsumerRepoSlug` names it
  `owner--name` where Other holds two repos of one name
- [x] `serve-consumer-dashboard.ps1`: the route `/consumers/(bwj|other)/<slug>`, a 404 for an unknown one, and
  `/refresh` coming back to it
- [x] a card's id is the old details anchor, so an old `#repo-...` link still lands on its card

### TEST

- [x] `consumer-dashboard.tests.ps1`: 260 passed, 0 failed -- the group page's cards, the repo page's frame and card,
  the slug and its twin rule, and the live server serving every linked repo page and a 404 for an unknown one
- [x] `dev-pages.tests.ps1`: 810 passed, 0 failed
- [x] seen at 390 px in headless Chromium: `/consumers/bwj` is one card of two rows, and
  `/consumers/bwj/smartwatchbanden` and `/consumers/other/djcylow-react` fit the screen, their long paths wrapping
  inside the card

### DEPLOY: feat/4113-consumer-group-rows

The BWJ and Other repos on the Consumers pages read like the DKJ ones: a group's page is a card per repo -- on a
phone one card of compact rows -- and each repo's report is a page of its own, where its long paths and plugin ids
wrap inside the card. The table and the one long report of every repo are gone.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Consumer group pages as rows with a page per repo

