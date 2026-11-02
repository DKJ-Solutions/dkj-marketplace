## fix/3725-specimen-sample-text

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

#3725: four samples on the House style page (`--graph-2`, `--graph-3`, `--positive-3`, `--warning-3`) typed
`color: #000`, since those mid fills are light in every theme and no house token is dark in every theme.
Rather than add a house token for one specimen page, the Graphs and Status grids put each label under its
swatch (the page's own `.spec-item > .note` rule), so a label reads the page's text colour and the swatch
carries only its fill. All twelve samples of the two grids move, so each grid keeps one look.

#### A visible result

This changes the House style page, so the branch is parked for the owner's look, not merged. Look at
`/plugins/dkj-policy/house-style` (the Colours section, its Graphs and Status cards) in a light and a dark theme.

### CREATE

- [x] `specimens.html`: the twelve Graphs and Status samples carry their label beneath the swatch, no text colour
- [x] `scripts/repo-config.ps1`: the `specimens.html` `#000` allowlist entry is gone; `check-house-style` holds without it

### TEST

- [x] `check-house-style` over this repo: `[OK] the brand book holds`, with the entry removed

### DEPLOY: fix/3725-specimen-sample-text

The House style page's Graphs and Status samples show their token name under the swatch instead of inside it,
so four of them no longer type `color: #000` for text on a light fill
([#3725](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3725)). The page now passes the brand book's
colour check without an allowlist entry.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The House style page's light specimen samples read a token for their text

