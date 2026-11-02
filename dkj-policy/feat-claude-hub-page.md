## feat/claude-hub-page

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

Maikel, November 2, 2026: rename the hub's AI card to Claude, make Claude the `/ai` page's h1 instead of an
h2 section on it, and move the URL and the breadcrumbs with it.

### CREATE

- [x] `Get-HubGroups`: the `/ai` group and its Claude section become one `/claude` group; Rules, Skills,
  Specialists, Performance and the Lenses section move under `/claude`
- [x] The lens page's crumbs and links follow; the unused `ai` icon goes
- [x] `serve-general-pages.ps1`: an old `/ai` or `/ai/claude/...` link answers 301 to its `/claude` address
- [x] The hub README and the comments that named AI follow
- [x] Maikel's review: an h2 card never sits in a `.grid-3`'s surface, which frames an h2 over h3 cards. The
  group pages set their h2 cards in the hub's own bare `.ph-cards`, now one definition (`Get-HubCardGridStyle`)
  both take
- [x] Maikel: the group pages' cards four to a row for a while (`.ph-cards--4`), then back to three, as the
  hub's (both November 2, 2026)
- [x] Maikel: every icon stands in the middle of an invisible square. Measured each drawing's bounding box in
  Edge: ten of the 24 were off-centre by 0.25 to 1.5 grid units, and each now moves its viewBox by that much
  (`$script:HubIconOffsets`); re-measured, all 24 centred
- [x] Maikel: the brand book's `.menu-item` gap from `--spacing-4` to `--spacing-5`, then `--spacing-6`, and `.ph-cards`' gap from
  `--spacing-3` to `--spacing-4`
- [x] Maikel: the brand book's `.page-column` gap from `--spacing-3` to `--spacing-5`, and `--text-h2` from 22px
  to 20px; the brand book's README records the three house changes in one dated section

### TEST

- [x] `dev-pages`, `dev-preview-sessionstart` and `stopwatch` suites updated and green
- [x] Checked on a preview hub from this branch (port 4899): `/claude` has Claude as h1 over four h2 cards,
  the Clock's trail reads Tools > Claude > Performance > Clock, and `/ai/...` redirects
- [ ] Maikel looks at the result before the merge (a visible result)

### DEPLOY: feat/claude-hub-page

The hub's AI card is now the Claude card, and its page is `/claude`: Claude is the page's h1, with the Rules,
Skills, Specialists and Performance cards directly under it, where they sat under a Claude heading on an AI
page before. Every page below it moves along: `/claude/rules`, `/claude/skills`, `/claude/specialists` and
each lens's page under it, and every trail through it reads Tools > Claude. An old `/ai` link is redirected
to its new address. And the cards on every group page (Claude, Performance, Clock) now stand on the page as the
hub's own do, three to a row, instead of inside a grey group surface that belongs to a heading over smaller cards. Every card icon
now stands in the middle of its square, so no icon looks shifted beside its neighbours. And there is more room
in and between the cards: every menu row and card link (a brand book class, so every DKJ page that uses one) keeps
24px between its icon, label and chevron instead of 16px, and the hub's cards stand 16px apart instead of 12px. Two more brand book changes reach every DKJ page the
same way: the blocks of a page column stand 20px apart instead of 12px, and an `h2` is 20px instead of 22px.

**Score:** 2

#### What makes this deploy extra special

The hub is the toolbox every repo running dkj-policy gets: its user finds Claude's pages under Claude itself,
one click and one heading fewer, and a bookmark to the old address still arrives.

**Score:** 2

#### Pull Request

The hub's AI card is Claude, and its page holds Rules, Skills, Specialists and Performance directly under /claude

