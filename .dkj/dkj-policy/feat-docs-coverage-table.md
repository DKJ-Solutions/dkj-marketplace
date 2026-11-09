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
      on the live page), named by that heading's text (`DocsHeading`) rather than the page's path
- [x] The What column is gone (with its `.dc-what` wrap); a "?" beside each docs heading opens a
      `.tooltip--explain` with the item's one line, the idea and why
- [x] Every column sorts: the house's sortable head (`.sort`/`.arrow` on `aria-sort`), ascending first and
      flipping per click, the Issue column as a number, ties in the page's order (`Get-DocsCoverageSortScript`)
- [x] Every docs page in the table (the owner: "really everything from the Claude Code docs"): the new
      `docs-coverage-catalog.ps1` holds the 228 pages of llms.txt (November 9, 2026), each with a fixed status
      (Covered, Not used, Not relevant), a note, and for Covered the repo paths that show it; five parallel
      research passes classified them, and every cited path and the key claims were checked against the tree.
      A page row: its title, its status with a "?" (note and evidence), section and group links, the page with a
      "?" (the docs' own description), no issue; an empty cell sorts last
- [x] No Docs column (it repeated the title on a page row): a page row's title links the docs page with its
      "?", an item's name carries the "?" with the idea, and the heading link moved to the item's own page,
      where the Docs fact now links the heading by its name
- [x] No page per item (the owner: "without landing pages, then you need no extra link"): an item's name links
      the docs heading, its "?" adds what the docs check found (the one thing only its page had shown), and the
      server serves /docs-coverage alone, so an old item URL is a 404; the home card says what the page holds now
- [x] `consumer-dashboard.tests.ps1`: its three fixtures that copy the docs-coverage lib copy the catalog it
      loads too (250/0); logbook, stopwatch and stopwatch-sync, which load the same libs, stay green
- [x] Column order Section, Group, Item, Status, Issue: from the docs' section down to the topic, then how this
      repo stands to it
- [x] Each status its own colour: a house `.dot` before the word, through a class of the page's own
      (`.dc-dot--<status>`) that reads a house token, one token per status
      (`Get-DocsCoverageStatusColors`); nothing typed or derived, `check-house-style` OK (703/0)
- [x] Done is Covered: an issue closed as completed reads Covered, the same state as a docs page the repo
      already uses; the Issue column says which arrived through an issue. Nine statuses, nine colours
- [x] Held each completed item against its page's catalog row: `plugin-evals` read Not used while #3896 had
      shipped `plugins/dkj-policy/evals`, so that row is Covered with the folder as evidence; the other eight agree
- [x] Not used reads orange (`--graph-2`, Waiting took `--primary-muted`), so the candidates stand out
- [x] A house filter chip over the table, "Hide Not relevant (148)", hides and shows those rows per press
      (`Get-DocsCoverageFilterScript`, finding a row by its status dot); `check-house-style` OK (707/0)
- [x] Every Not used page says whether to take it up and why: `Advice` (Adopt, Consider, Skip) and `AdviceWhy`
      in the catalog, judged by three parallel research passes against this repo's rules and decisions (9
      Consider, 37 Skip), shown in the status "?" after the note (710/0)
- [x] A second chip, "Only Not used (46)", shows the candidates alone; the filter script judges every row
      against both chips, so they combine (712/0)
- [x] The chips became a status dropdown: a house `.more` disclosure, "Status: all", opening a panel of the
      product layer's `.check` boxes, one per status the table shows with its dot and row count; unchecking hides
      those rows, the summary counts what shows, a click outside or Escape closes it; the panel floats on the
      tooltip's surface, every value a token; `check-house-style` OK (715/0)

### TEST

- [x] `dev-pages.tests.ps1`: the overview asserts read a table, one row per item, status, docs and issue per
      row, the docs section and group as links, the docs link to its heading, the "?" beside each docs heading, and the
      one in the status only beside a Declined status with a reason (715/0);
      `check-house-style` OK
- [x] The product server on 4870 restarted and serves the table
- [ ] The owner's look at http://localhost:4870/docs-coverage

### DEPLOY: feat/docs-coverage-table

The Docs coverage overview on the product portal is a table now, listing every page of the Claude Code docs
beside the ten items with an issue. Each row reads from the docs' section and group (each a link into the docs) to the topic, linking the docs
(an item its heading, a docs page the page itself), then its status, each status in a colour of its own, and its issue. A docs page reads
Covered (this repo already uses it well), Not used or Not relevant, and a "?" beside a name or a status explains
it on hover or focus: the idea, the docs' own description, the evidence, or why the owner declined it. Every column
sorts with a click on its head. A Not used page also says whether this repo should take it up, and why. A status dropdown over the table chooses which statuses show.

**Score:** 2

#### What makes this deploy extra special

N/A: the Docs coverage pages are this repo's own product portal, which no consumer installs.

**Score:** N/A

#### Pull Request

Docs coverage overview as a table instead of cards

