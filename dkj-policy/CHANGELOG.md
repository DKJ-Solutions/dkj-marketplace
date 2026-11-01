# Changelog

## [Unreleased]

**11 / 16 minor entries** <!-- pending-tally -->

### DEPLOY: feat/text-tokens-page-components · 20261101-140734Z

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

Plugins: dkj-policy, dkj-solutions

[PR #3719](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3719)

---

### DEPLOY: feat/note-absorbs-muted-and-footer-note · 20261101-104821Z

The house style has one class for quiet text, `.note`. `.muted` and `.footer-note` drew the same `--primary-muted` text at `--text-sm` under three names, told apart only by a top margin the page column already took away, so they are retired into `.note` (Maikel, November 1, 2026). The README carries the rename table, and every page the hub and the dashboards render uses `.note`, so nothing here looks different. `--font-serif`, kept after October 24 for a title that never came, is retired with them; `--font-mono` stays, and the brand book now shows it as what it is, a typeface: its own Font family card and table row instead of a line in the type scale. The headings grow a step, 36/22/16 where they were 32/18/14, and `--text-lg` is retired into `--text-h3`. Both cards set each token's name in the token itself, with no note beside it, and in its size alone: no heading colour or weight, which belong to the elements on the Text page.

**Score:** 3

#### What makes this deploy extra special

An app taking this release renames `.muted` and `.footer-note` to `.note` in its own markup, by the README's table. A use left behind loses its grey and reads as plain text, without an error, so the rename has to be done rather than noticed. An app still reading `--font-serif` falls back to the sans. Headings render larger (36/22/16), and an app moves each `--text-lg` in its own layer to `--text-h3`; one left behind renders at the inherited size.

**Score:** 4

#### Pull Request

Brand book: .note absorbs .muted and .footer-note, a larger heading scale, and --font-serif and --text-lg are retired

Plugins: dkj-policy

[PR #3717](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3717)

---

### DEPLOY: fix/chart-specimen-third-bar-graph-3 · 20261101-100352Z

The brand book's Chart scope specimen draws its three plain category bars in `--graph-1`, `--graph-2` and `--graph-3`. The third bar was `--positive-3`, a direction colour the README reserves for gain and never for a category, so the specimen taught the very mix the token table forbids. It came in with the static specimen page (#3493), carried over from the retired app's direction charts. The legend and the swatch beside text sat in the Meters card, keying `--graph` series that card does not draw; they now sit above the chart whose bars they name, with an average line in `--fg-2` to show the line item, and the card is called Meters. The brand book's overview now has three h2s: Tokens, Preview (Themes and Text, the whole style at once) and Components (Actions, Surfaces, Tables, Forms and every other section), each section card an h3. The Text page reads as four cards of one subject each, every sample on its own row with the class that draws it beside it, where two cards used to stack fifteen unlabelled samples on uneven margins. The specimen cards carry their title alone, without the class list under it.

**Score:** 2

#### What makes this deploy extra special

A reader building a chart from the brand book now sees the categorical slots used as the token table says, instead of a status colour standing in for a third series.

**Score:** 2

#### Pull Request

The chart specimen keys its own bars, the brand book overview gets Preview and Components headings, and the Text page is labelled

Plugins: dkj-policy

[PR #3715](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3715)

---

### DEPLOY: feat/hub-assets-addons-heading-labels · 20261101-092830Z

The brand book's colour tokens are named for what they are, and its pages read more clearly.

- **Renamed tokens, same values:** `--paper-1..4` is `--bg-1..4`, `--muted` is `--primary-muted`, and the series
  slots `--cat-1..3` are `--graph-1..3`. The old names are retired tokens and the README carries a rename table.
- **Colour:** `--bg-2` stands a clearer step off the page (1.09:1 to 1.10:1 on light, 1.04:1 to 1.05:1 on dark; it
  was barely visible in some themes), with `--bg-3` moving along. On dark, `--primary-muted` now takes its
  primary's own hue with a little more colour, so Lila's grey no longer reads blue.
- **Corners and spacing:** a new `--radius-4` (16px) rounds the dialog and the drawer, every corner on the scale
  reads its token instead of a pixel value, and the card groups round at `--radius-3`, pad at `--spacing-3-5` and
  space their cards at `--spacing-3`.
- **The specimens:** every colour swatch carries its token's name inside it, centred, in a colour that reads on it in
  every theme. The Color page groups its cards under **Theme** and **Graphs & Status**, with the cards **Graphs** and
  **Status**, and the Tokens section's own page is gone: its address lands on the overview's token groups.
- **The hub's dkj-policy page** heads its sections **Assets (Always on)** and **Add-ons (Optional)**.

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions repo that takes this release's `house-style.css` must rename, in its own domain layer,
`var(--paper-N)` to `var(--bg-N)`, `var(--muted)` to `var(--primary-muted)` and `var(--cat-N)` to
`var(--graph-N)`, per the README's rename table of November 1, 2026. There is no alias, so a use left behind loses
its colour, and the house-style gate reports each one as a retired token.

**Score:** 5

#### Pull Request

The brand book renames its colour tokens (--bg-N, --primary-muted, --graph-N) and sharpens its pages

Plugins: dkj-policy, dkj-solutions

[PR #3714](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3714)

---

### DEPLOY: docs/brandbook-30-group-reads-on-paper · 20261101-092048Z

The brand book's 60-30-10 rule now says that everything in the 30% group (`--primary`, `--muted`) reads on
all four paper steps, and that a theme has these three groups and no fourth. That retired `--muted-inverse`:
it fitted no group and no value could make it fit. Each theme now has ten colours instead of eleven, the
quieter line on `.fill-inverse` takes `--paper-4`, and the brand book's Color page and theme swatches show
the three groups alone.

**Score:** 3

#### What makes this deploy extra special

`--muted-inverse` no longer exists. A DKJ-Solutions repo whose own domain layer uses it must switch to
`--paper-4` on an inverted surface; the house-style check now reports every use as a retired token.

**Score:** 5

#### Pull Request

The brand book retires --muted-inverse: a theme has the 60-30-10 groups and no fourth

Plugins: dkj-policy, dkj-solutions

[PR #3713](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3713)

---

### DEPLOY: feat/brandbook-overview-theme-stats-status · 20261031-210130Z

The brand book's Color page sets its swatches under three h2 headings: Theme, where the theme colours are split
into the 60-30-10 rule's shares (60 Paper, 30 Primary, 10 Text), Stats with the series colours, and Status with
the status and direction colours. The specimens page shows the same three cards in place of "Theme colours".

**Score:** 2

#### What makes this deploy extra special

The specimens and the Color page are this repo's own pages; nothing a consumer takes changes.

**Score:** N/A

#### Pull Request

The brand book's Color page sets its swatches under Theme, Stats and Status

Plugins: dkj-policy

[PR #3712](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3712)

---

### DEPLOY: feat/radius-scale-names · 20261031-203241Z

The brand book's corner-radius tokens are named like its spacing scale: `--radius-N` is N × 4px and a half
step adds 2px, so `--radius-xs`, `-sm`, `-md`, `-md-plus` and `-lg` are now `--radius-1`, `-1-5`, `-2`,
`-2-5` and `-3`; `--radius-pill` stays. Every value is unchanged. The old names are retired, so
`check-house-style` reports a use left behind, and the brand book's README carries the rename table.

**Score:** 3

#### What makes this deploy extra special

An app that takes the new stylesheet and uses a radius token in its own layer must rename it by the table in
the brand book's README; a use that slips past renders with square corners, and the house-style gate names it.

**Score:** 5

#### Pull Request

The radius tokens follow the spacing scale's names

Plugins: dkj-policy, dkj-solutions

[PR #3711](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3711)

---

### DEPLOY: fix/house-style-above-add-ons · 20261031-200532Z

dkj-policy's page on the product's Marketplace now opens on the house style's card, now named dkj-brandbook (it was
Specimens), under the heading Assets (it was House style), with the Add-ons below it and the plugin's facts below those (Maikel,
October 31, 2026). The page that card opens carries the same name in its url and its h1:
`/marketplace/dkj-policy/dkj-brandbook`, where `/marketplace/dkj-policy/house-style` now redirects.
That page now opens on an h2 Tokens over five cards (Color, Text, Radius, Spacing and Size), each a page
of its own holding only those specimens; the other sections follow as before.

**Score:** 2

#### What makes this deploy extra special

N/A -- the product's Marketplace pages are this repo's own dev server, which no consumer runs.

**Score:** N/A

#### Pull Request

dkj-policy's marketplace page shows its house style above its add-ons

Plugins: dkj-policy

[PR #3710](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3710)

---

### DEPLOY: fix/3703-specimens-tail-anchor · 20261031-193714Z

The hub's house-style specimens are cut into a page per section, and each page takes the file's tail: the closed modal specimens and their script. That tail began at the first `<dialog` anywhere, which since the Overlays section shows dialogs open in place was one of those, so every section page carried the rest of the Overlays section outside its `.spec-stage`, where the browser's own `dialog[open]` style centres it over the top of the page. The tail now begins at the first column-0 `<dialog`, which is the modals alone, and the suite holds the real tail to that.

**Score:** 2

#### What makes this deploy extra special

Anybody browsing the house style in the toolbox saw an open dialog floating over every section page, and a duplicate of half the Overlays section below it; both are gone.

**Score:** 2

#### Pull Request

House-style section pages no longer carry a stray open dialog over the page

Plugins: dkj-policy

[PR #3707](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3707)

---

### DEPLOY: fix/house-style-css-gate-path · 20261031-191613Z

The brand book's CSS gate reads the stylesheets from `plugins/dkj-policy/assets/dkj-brandbook/` again. #3706 renamed the folder but missed this reader, because it builds the path from separate segments, so the gate failed on every change to the stylesheet.

**Score:** 2

#### What makes this deploy extra special

N/A -- the gate runs only in this repo's CI; nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

The CSS gate reads the brand book from its renamed folder

[PR #3708](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3708)

---

### DEPLOY: feat/house-style-to-dkj-brandbook · 20261031-190353Z

The house style is renamed to **dkj-brandbook**: the skill is now `dkj-solutions:dkj-brandbook`, its canonical files sit in `plugins/dkj-policy/assets/dkj-brandbook/`, and the docs call it the brand book. The files keep their names (`house-style.css`, `house-theme.js`, the house tokens and classes, `check-house-style` and its session check), so no vendored copy has to change. The pin readers and the reusable `check-house-style` workflow read a skill page at a tag cut before the rename as well, so a consumer pinned at v6.1.0 or earlier keeps passing. Between this merge and the next cut, the skill page on `main` names v6.1.0 under the new folder path, which that tag does not serve. The cut repoints the tag, as it does after every brand book change.

**Score:** 3

#### What makes this deploy extra special

A session in a DKJ-Solutions repo loads the brand book under its new skill name, `dkj-brandbook`. Anything that calls the skill by its old name, `house-style`, now has to use the new one. The copies a repo vendors, and its CI call to the reusable workflow, stay as they are.

**Score:** 3

#### Pull Request

The house style is renamed to dkj-brandbook

Plugins: dkj-policy, dkj-solutions

[PR #3706](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3706)

---

### DEPLOY: feat/house-style-on-product · 20261031-111530Z

The house style's specimens are on this repo's product, at `/marketplace/dkj-policy/house-style` with a page per
section and a card on the product's dkj-policy page, read from this tree on every request. The toolbox here
sends its own house-style pages there once a release carries the redirect; in every other repo the toolbox
keeps serving them, since only the source repo holds the canonical `specimens.html`.

A plugin's page on the product has no Description card any more: its description is behind a "?" right of the
`h1`, shown as a tooltip while the pointer is on it or it has focus. `Format-GeneralPageHtml` takes it as `-Info`,
and the house style gains `.page-title`, the `h1` and its `.page-info-button` on one row, so a page still opens on its
`h1` alone (#3585).

**Score:** 2

#### What makes this deploy extra special

Every plugin's own description is rewritten for the person who installs it: what it gives you, when to enable it and
what it needs, without the internal terms the old ones were written in. It is the text `claude plugin details` and
the toolbox's Plugins page show, so it reaches every user with the next release. The redirect itself fires only in
the house style's source repo, so no consumer's toolbox changes.

**Score:** 2

#### Pull Request

The house style's specimens on the product port; the toolbox redirects there in the source repo

Plugins: bwj-development, dkj-policy, dkj-solutions, dkj-subagents-alpha, dkj-subagents-ecomm, dkj-subagents-lifehub, dkj-subagents-shopify

[PR #3702](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3702)

---

### DEPLOY: fix/3698-house-style-scss-interpolation · 20261030-175934Z

`check-house-style` reads an SCSS interpolation (`.a-#{$n}`) in a stylesheet as part of the selector
it sits in, so an interpolated rule of the repo's own scopes the house classes nested inside it, like any
other domain class ([#3698](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3698)).

**Score:** 1

#### What makes this deploy extra special

A DKJ-Solutions repo whose SCSS nests a house class inside an interpolated selector of its own no longer
gets a `[redefine]` finding for it.

**Score:** 2

#### Pull Request

check-house-style still flags a house class nested in an interpolated SCSS selector

Plugins: dkj-solutions

[PR #3700](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3700)

---

### DEPLOY: fix/3697-btn-edge-in-grid-card · 20261030-173410Z

A plain `.btn` on a card inside a `.grid-2`, `.grid-3` or `.card-grid` now draws its edge in `--muted`, so it
stays visible beside a `.btn--primary` in every theme
([#3697](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3697)). Before, its border was the card's own
edge colour, one paper step from the card, and on a dark theme it barely showed. A repo that worked around this
with a class of its own can drop that class once it takes this version.

**Score:** 2 -- a button edge that was hard to see, noticed when somebody points at it.

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

A plain .btn on a card inside a grid keeps a visible edge

Plugins: dkj-policy

[PR #3701](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3701)

---

### DEPLOY: fix/3694-house-style-scss-nesting · 20261030-172451Z

`check-house-style` now reads a nested rule in a `.css`, `.scss`, `.less` or `.pcss` file together with
the rules around it ([#3694](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3694)). A house
class nested inside a rule of the repo's own (a `.menu-item` rule inside `.thumb-card`) is composition,
as it already was written out flat, and no longer a `[redefine]` finding; nested only inside an element
or an at-rule it still is. The skill page says so under check 2.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions repo that writes its styles in SCSS no longer has to flatten its nested house-class
compositions, or allowlist them, to pass the house-style gate: the gate and the skill's own rule now
agree.

**Score:** 3

#### Pull Request

check-house-style reads a nested SCSS selector as an app-wide redefinition of a house class

Plugins: dkj-solutions

[PR #3699](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3699)

---

### DEPLOY: fix/3695-killed-product-not-reused · 20261030-165759Z

When a session starts after the trunk has moved, the dev-preview hook restarts the repo's product
server, and it now really restarts it
([#3695](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3695)). Before, a stopped server that
took more than 5 seconds to free its port was reported `already running`, and a moment later nothing
listened at all. The replacement now starts on the same port once it is free, or on the next free port
in the range. Where there is none, the line says so instead of naming a server that is gone. The hub's
restart after a plugin update follows the same rule.

**Score:** 2 -- the product link from the session start line pointed at nothing, which the owner
notices the first time they open it.

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

dev-preview: a killed outdated product server is never reported as reused

Plugins: dkj-policy

[PR #3696](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3696)

---

