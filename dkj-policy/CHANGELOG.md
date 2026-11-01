# Changelog

## [Unreleased]

**7 / 12 minor entries** <!-- pending-tally -->

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

