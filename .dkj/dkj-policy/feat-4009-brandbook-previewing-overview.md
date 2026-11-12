## feat/4009-brandbook-previewing-overview

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

#### Scope

Issue #4009: the owner picked **B plus C's previous / next bar** from #4002's wireframe (Figma
`ffJGriv6yREpvkdTysm7mR`, rows B and C1.4) on November 12, 2026. Built on the product server's brand book
pages (`/marketplace/dkj-policy/dkj-brandbook`), not in Figma: the look comes from house tokens and classes
(`nav-search`, `chip`, `btn`, `card`), with a small page layer of `bb-*` classes on house tokens only.

Deliberately not built from the wireframe: thumbnails of *components* on their cards (B1.7 says three per
card). Rendering live specimens small on the overview would pull every section's style block and sprite onto
one page; the components' cards name every specimen as a chip instead, which answers F2's "is it here?". The
token groups do get a real preview.

### CREATE

- [x] Cody: Radius, Spacing and Size merged into one token group, Scale, each under its own h2; the three old
      addresses redirect to their card on it (F6).
- [x] Cody: an anchor on every specimen card (`s-<title>`), written by one function the overview's links use too.
- [x] Cody: the overview as previewing cards: a token group previews its tokens (var()s, redrawn by a theme
      switch), every card names its specimens as chips that open them on their page (F2, B1.7).
- [x] Cody: a sticky bar on every brand book page: a provenance chip (branch @ commit, read per request), and on
      the overview the search over every specimen and class name with a live count, Escape and `/`, an empty state
      that clears, browses and suggests the closest name, jump chips, and the theme switcher (F1, F4, F5, F7;
      B1-B4). The themes are no longer a single-card group.
- [x] Cody: previous / next with a position ("3 of 13") above and below every page's cards, arrow keys too (F3, C1.4).
- [x] Cody: the breadcrumb cut to Marketplace, the brand book a destination of its own (B1.1).
- [~] Owner looks at the overview and a group page on the product server and approves the structure and look. Not done as a separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-12 without one.

### TEST

- [x] `dev-pages.tests.ps1`: the overview's assertions rewritten for the new shape, and new ones for the chip,
      the search, the index and its anchors, the previews, the Scale merge and its redirects, and the walk.
      751 passed, 0 failed.

### DEPLOY: feat/4009-brandbook-previewing-overview

The brand book on the product server previews and searches. Its overview opens on a sticky bar: a chip naming
the branch and commit the pages were read from, one search over every specimen and class name, a chip per group
and the theme switcher. Each card shows what it holds: a token group previews its tokens, and every card names its
specimens as chips that open the specimen itself. Radius, Spacing and Size are one group, Scale. Every page below
the overview carries previous / next and its position, so walking the whole book after a change is one button per
page. Built from the structure the owner picked on #4002's wireframe (#4009).

**Score:** 2

N/A: the brand book pages are this repo's own product server; no consumer runs them.

#### What makes this deploy extra special

The first structure the new UX specialist wireframed that made it onto a real page: the owner picked it from three
rows in Figma, and every finding it answers is named in the code where it lands.

**Score:** 2

#### Pull Request

Brand book overview: search, previews, a provenance chip and previous / next

