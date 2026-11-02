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
to its new address.

**Score:** 2

#### What makes this deploy extra special

The hub is the toolbox every repo running dkj-policy gets: its user finds Claude's pages under Claude itself,
one click and one heading fewer, and a bookmark to the old address still arrives.

**Score:** 2

#### Pull Request

The hub's AI card is Claude, and its page holds Rules, Skills, Specialists and Performance directly under /claude

