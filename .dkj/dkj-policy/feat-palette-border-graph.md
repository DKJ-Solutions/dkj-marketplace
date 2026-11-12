## feat/palette-border-graph

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

#### Why

A UX and design review of the palette (November 12, 2026) found the gains outside text: a control's edge
(`--bg-3`) read at about 1.1:1, under WCAG 1.4.11's 3:1; `--graph-2` was ΔE 4.2 from `--warning-3` with full
colour vision, `--graph-3` sat beside `--positive-3` and under 3:1 on a light page; the dark paper steps were
1.04:1 apart. The owner asked for these two points as one small round, then a look.

### CREATE

- [x] `--primary-border`, a fourteenth computed token in the 30 group: a grey of the primary's hue at 3:1 on bg-3, in the palette model and builder (first proposed as a free-standing `--border-strong`; the owner moved it into the 30 the same day)
- [x] the 60-30-10 membership rule written into the brand book README and the `dkj-brandbook` skill, so a new colour token joins a group rather than standing beside them
- [x] the dark paper steps widened in the model (bg-1 to bg-2 1.06:1, bg-3 to bg-4 1.12:1); the builder recomputed all twelve themes
- [x] the plain `.btn`, `.seg`, `.info-button`, `.nav-search`, `.toolbar__filter`, `.stepper` and `.combo` take `--primary-border`
- [x] new graph slots, chosen with the dataviz validator away from the status hues, light and dark
- [x] the brand book README, the stylesheet's measurement comment and specimens.html name the new token
- [x] the Figma variables (dkj-brandbook file): all twelve theme modes and the graph slots synced from house-style.css, and `palette/primary-border` with its semantic `color/primary-border` alias added, renamed from `border-strong` when it moved into the 30 (after the owner allowed the write)

### TEST

- [x] `house-palette` suite: 161 passed (fourteen tokens, every pairing at its floor, every token on the specimens page)
- [x] `check-house-style`: the brand book holds
- [x] the branch's Admin (port 4897) and the product (4870) serve the new stylesheet

### DEPLOY: feat/palette-border-graph

Controls now show their edge: a plain button, a segmented control, the info button, the search and filter fields
and the product's stepper and combo field take a new `--primary-border`, a grey of the theme's colour in the 30 group at 3:1 on
the page and on a card, in all twelve themes. The three graph colours are now blue, purple-magenta and deep teal,
so a series no longer looks like a warning or a gain. The dark themes' surfaces stand a little further apart.
**Score:** 2

#### What makes this deploy extra special

The house palette now promises non-text contrast for controls, computed per theme rather than typed, and the brand book states that every theme colour belongs to the 60, the 30 or the 10.
**Score:** 2

#### Pull Request

Palette: a 3:1 control border, wider dark paper steps, colour-blind-safe graph slots
