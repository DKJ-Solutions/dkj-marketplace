## feat/4127-borders-only-on-buttons

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

Inbound #4127: a border means "you can press this", so it stays on buttons and nowhere else; a surface is told
apart by its fill. Stacked on `feat/4126-no-group-surface` (a card is told apart by its fill alone only once the
group tray is gone), with `origin/main` merged in.

#### The three open cases, settled

- **Inputs keep their border**: a field is something you press to type in, so it is inside the principle, not an
  exception to it (`.field`, `.nav-search`, `.toolbar__filter`, `.stepper`, `.combo`).
- **Row dividers go**: rows inside one surface are set apart by their spacing; a `.table` alternates its body
  rows' fill; a list that must read as one block (`.card--rows`, a phone's card-link group and `.tiles`) puts each
  row on its own fill a `--spacing-0-5` gap apart; a total is a tinted band, not a rule.
- **Focus rings stay**, untouched.

Two lines deliberately stay: an `hr` (a rule is its whole meaning) and the opt-in `.header--accent`.

### CREATE

- [x] `house-style.css`: borders off cards, tiles, mini-cards, notices, alerts, banners, panels, chips, tooltips, the settings panel, `pre`, `blockquote`, facts, items, menu rows and items, tables, the shell's bar, nav, toolbar, detail pane and empty state; state borders become tints; `.panel--button` gains a button edge
- [x] `house-product.css`: borders off dialogs, drawer and sheet, the breadcrumb bar, the bottom bar (now `--bg-2`), topics, stat, bill, compare, calc and date rows, `.field__fixed`, the combo list, value box and figure; `.card--rows`, phone card-link groups and phone `.tiles` become rows a `--spacing-0-5` gap apart
- [x] both READMEs state the principle and drop the lines they described; #4131 filed for the Admin and dashboard domain layers

### TEST

- [x] `dev-pages.tests.ps1`: the two #4113 phone asserts follow the gap instead of the hairline (811 passed); `check-house-style` (175), `house-palette` (219) green; `check-house-style.ps1` OK
- [x] computed styles read in the browser: this branch's Admin on port 4893 draws the home table with alternating rows and no lines; the product on 4870 has borderless cards on `--bg-2` and borderless bars
- [x] the owner looked at Admin and a product at both widths and approved (November 15, 2026)

### DEPLOY: feat/4127-borders-only-on-buttons

The brand book now draws a border only where something can be pressed
([#4127](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4127)): buttons, fields, the controls a person
types in, and the focus ring keep theirs; cards, notices, alerts, panels, chips, tooltips, dialogs, bars and code
blocks stand on their own fill, rows inside a surface are set apart by spacing (a table by alternating fills), and a
state that was a coloured edge is a tint. The README states the rule.

**Score:** 2

#### What makes this deploy extra special

Every DKJ-Solutions app that takes the update loses almost every line on its pages: cards, notices and the header
and bottom bars stand on their fill alone, tables stripe instead of ruling, and lists of rows become rows of fill a
hairline of page apart. No markup changes; an app whose own layer draws borders of its own keeps them until it
follows the rule.

**Score:** 3

#### Pull Request

Borders only on buttons; separate with fills

