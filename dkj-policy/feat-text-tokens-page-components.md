## feat/text-tokens-page-components

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

Maikel asked for two h2s, Tokens and Components, on the brand book's Text token page
(`/marketplace/dkj-policy/dkj-brandbook/tokens/text`), and chose to show the Text section's own cards under Components,
and then had the Text section's card taken off the overview's Preview: it lives on the Text token page now. On the same
page he then retired `.eyebrow`, asked for a complete Headings card (h1, h2, h3), and merged `.sub` into `.note`, which
share colour and size (their margins differed: `.note`'s is kept), and retired `.lead`, which since it went to body size
read as a plain `<p>`.

### CREATE

- [x] `dev-pages-lib.ps1`: a token group's heading may name a `Section`, and then shows every card of that section in
  its own grid; the Text group gets Tokens (Font size, Font family, Font weight) and Components (the Text section)
- [x] The overview's Text card counts both halves (7 specimens)
- [x] The Messages and group headings card is Status alone, a positive, a warning and a negative line (`.msg--positive`
  is new): `.group-heading` is gone, so the house has one h3
- [x] `house-style.css`: four weight tokens, `--font-weight-light` 300 to `--font-weight-black` 900, and every rule (the
  body too) sets its weight through one: 300 light, 400 regular, 600 bold, 700 and 800 black; the hub's stopwatch,
  masthead and consumer-dashboard layers likewise
- [x] `h2` is bold (700); `h3` is `--primary` and light
- [x] `.card__title` gone: every card title is a plain `h3` in `.card__head` (the specimens, the patterns and the hub)
- [x] `.grid-3` has `--spacing-5` of padding (the other card groups keep `--spacing-3-5`)
- [x] `.amount` gone into `.num`: a `.num > svg` is the small icon beside a figure; the specimen shows it
- [x] `.verdict` gone: the line under a `.question-head` is a plain `<p>` (`<strong>` for a verdict), whose margin
  `.question-head + p` sets; the specimen shows it
- [x] No h1, h2 or h3 carries a class: `.menu-item__title` (the hub's card labels), and the
  dialog's class move to their place (`.menu-item__label > h2`, `.dialog__head h3`)
- [x] Every `<p>` has no margin, so `.msg` (a `<p>` with none) is gone; `.msg--warn` and `.msg--error` stand on a
  plain `<p>`, across the specimens, the patterns and the hub
- [x] `house-palette.tests.ps1` refuses a heading with a class in any page or generator, and a font weight set as a number in the stylesheet or those hub layers
- [x] A section a token group shows is left off the overview, so Preview holds Themes alone
- [x] `house-style.css`: `.eyebrow`, `.lead`, `.pos` and `.neg` gone, `.sub` gone into `.note`, the fill switches and comments with them
- [x] `specimens.html`: the Type scale card is Font size, a new Font weight card shows the four weight tokens, the Headings card shows h1, h2, h3, the Running text card drops its `.lead` row, the Numbers card its `.pos, .neg` row; the fill specimens' quieter line is a `.note`
- [x] The hub: `Format-GeneralPageHtml`'s `-Eyebrow` (drawn only without a site header, which no caller had) removed
  with its callers; the consumer dashboard's two `.sub` lines are `.note`
- [x] The brand book README and the `dkj-brandbook` skill name `.note` instead of `.sub` and `.eyebrow`, and no longer offer `.lead`

### TEST

- [x] `dev-pages.tests.ps1`: the Text page's heading and card order, the overview's count, and a 404 when the Text
  section is gone from the file
- [x] `consumer-dashboard.tests.ps1`, `check-house-style`, `check-plugin-integrity` green
- [x] Looked at the live page on the product server
- [x] The owner's look at `/marketplace/dkj-policy/dkj-brandbook/tokens/text` (Maikel: "ship it", November 1, 2026)

### DEPLOY: feat/text-tokens-page-components

The brand book's Text token page sets its three token cards, Font size, Font family and Font weight, under an h2 Tokens, and the
Text section's own specimens (headings, running text, numbers, status) under an h2 Components, so the type tokens
and the type they produce read on one page. A token group's heading can now name a whole section to show, and that section leaves the overview's Preview, which
now holds Themes alone. The Headings specimen shows h1, h2 and h3.

A `.grid-3` group has 20px of padding (`--spacing-5`) instead of 14px.
The house style gains four weight tokens, `--font-weight-light` (300), `--font-weight-regular` (500),
`--font-weight-bold` (700) and `--font-weight-black` (900), and every rule now takes its weight from them, so all
text is one step heavier: running text 500, card titles 700, h1 900. h2 is bold (700), and h3 turns light (300)
and takes the theme's colour, `--primary`, instead of `--fg-3`. Its headings carry no class any more: a card's label and a dialog's title are styled by where they
sit. A message line gains `.msg--positive`, in `--positive-5`, beside `.msg--warn` and `.msg--error`. A `<p>` has no
margin of its own any more: its place sets the space around it. It drops eleven classes: `.eyebrow`, which no page here drew any more; `.lead`, which since it went to
body size read as a plain `<p>`; and `.sub`, merged into `.note`, the one quiet-text class, which had the same colour
and size; `.pos` and `.neg`, the colours of `.delta--up` and `.delta--down` without the weight; `.card__title`: a card's
title is a plain `h3`, set like every other; `.amount`, gone into `.num`, which now sets a small icon beside its figure; `.verdict`, which read as a `<p>`
with a `<strong>`; and `.menu-item__title`, the hub card's heading, now styled as the h2 or h3 in `.menu-item__label`; and `.group-heading`, the uppercase section label, so the house has
one h3; and `.msg`, which was a `<p>` with no margin.

**Score:** 2

#### What makes this deploy extra special

`house-style.css` no longer defines `.eyebrow`, `.lead`, `.sub`, `.pos`, `.neg`, `.card__title`, `.amount`, `.verdict`, `.menu-item__title`, `.group-heading` or `.msg`, and a `<p>` has
no margin. A page that takes the new copy and still uses either loses
that styling: replace `class="sub"` with `class="note"` (the same colour and size, with a small top margin instead of a
16px bottom one), drop the eyebrow line or set it as a `.note`, and drop `class="lead"` (the paragraph keeps the body size and colour,
and loses its 46rem measure and its 8px top margin). Replace `class="pos"` with `class="delta delta--up"` and
`class="neg"` with `class="delta delta--down"`; the figure then turns bold (700). Replace `<span class="amount"><span>12,50</span><svg…></span>` with
`<span class="num">12,50<svg…></span>`. Replace `<p class="verdict">…</p>` with `<p><strong>…</strong></p>` (it keeps its margin under a
`.question-head`). No heading takes a class: drop `class="menu-item__title"` from the `h2` or `h3` in a `.menu-item__label`;
drop `class="msg"` (and the `msg` before `msg--warn` or
`msg--error`), and give a run of plain paragraphs the space between them it relied on from the browser's 1em; a
`.group-heading` becomes a plain `h3` (its count, where it had one, a `.note` or a `.badge` beside it); and a dialog's title is the plain `h3`
in `.dialog__head` (`.dialog__title` stays for a `<p>`). Drop `class="card__title"` from a card's `h3`: it
then takes the h3's light weight and the theme's colour instead of semibold `--fg-3`. Text set in the house style is one
step heavier throughout (400 to 500, 600 to 700, 700 to 900); a domain layer that sets a weight should take one of
the four `--font-weight-*` tokens rather than a number.

**Score:** 5

#### Pull Request

the Text token page splits into Tokens and Components; the house style retires eleven classes and no heading carries one

