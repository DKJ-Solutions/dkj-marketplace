## feat/performance-sections

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

Dave's request (November 3, 2026): on `/performance`, two `h2` headings, Clock and Context; under Clock
the Stopwatch and Logbook `h3` cards, under Context SessionStart. A visible result: it waits for the
owner's look before the merge.

### CREATE

- [x] `Get-HubGroups`: Clock becomes a Section of Performance, and a new Context Section holds SessionStart
- [x] `Format-HubGroupPageHtml`: a Section's cards include its member general pages, not only its groups
- [x] `/clock` moves to `/performance` (301), because the Clock no longer has a page
- [x] Docs: the hub README, the brand book README's group paragraph, the stopwatch-lib and server comments
- [x] Logbook in pages (Dave, same day: "it keeps getting slower"): `Select-LogbookPage` takes 20 store runs
  per page, newest first, and only those are cut, read and drawn; `/logbook/page/<n>` for the older ones,
  linked by `Format-LogbookPager`
- [x] The run page still cuts the whole store to find a slug: filed as #3779

### TEST

- [x] `dev-pages` and `stopwatch` suites updated and green (571/0, 273/0)
- [x] Served from the branch on port 4895: `/performance` reads h1 Performance, h2 Clock, h3 Stopwatch,
  h3 Logbook, h2 Context, h3 SessionStart; `/clock` answers 301 to `/performance`
- [x] `logbook` suite: paging asserts added, green (69/0)
- [x] Served on 4895: `/logbook` 20 store runs with an "Older runs" link, `/logbook/page/2` the rest,
  `/logbook/page/1` 301 to `/logbook`, a page past the last 404

### DEPLOY: feat/performance-sections

The hub's Performance page now reads as two sections instead of two cards: **Clock**, with the Stopwatch and
Logbook cards directly under it, and **Context**, with the SessionStart card. The Stopwatch and Logbook are
therefore one click closer, and their trail reads Tools > Claude > Performance. The old `/clock` address moves
to `/performance`.

The Logbook overview no longer gets slower with every session: it shows the newest 20 runs, and older ones
sit behind **Older runs** on `/logbook/page/2` and on. Only that page's runs are cut per sweep issue, read from
the transcripts and drawn, so a load costs one page whatever the store holds.

**Score:** 3

#### What makes this deploy extra special

Every repo's Toolbox shows the new Performance page, with Stopwatch and Logbook one click closer than they were,
and its Logbook stays fast however many sessions it has logged.

**Score:** 2

#### Pull Request

The Performance page groups its cards under Clock and Context

