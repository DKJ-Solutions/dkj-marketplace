# The DKJ-Solutions brand book: the product layer

**This is the product layer of the brand book, the part only DKJ-Solutions' products use**
(Maikel, issue [#3831](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3831), November 5, 2026).
Admin renders in every repo that runs `dkj-policy`, while the mobile-first product (the storefront, the
site header, the card overviews) is DKJ-Solutions' alone: a BWJ-Development repo has a Shopify storefront and
never uses it. So the brand book is split in two, and **this folder holds the half a session doing Admin
work no longer has to load**. It is documented here, and styled by [`house-product.css`](house-product.css)
beside this file. [`specimens.html`](specimens.html) beside it holds the product specimens, which the product
server joins to the core's (`Join-HouseStyleSpecimens` in `scripts/lib/product-pages-lib.ps1`).

**The layer loads after the core and never alone.** `house-product.css` uses the tokens, themes, typography,
tables and surfaces that [`house-style.css`](https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/house-style.css)
defines, and it adds to classes the core's "Shared components" block starts. A product page links both
sheets, **the core first**, and `house-theme.js` where the app lets the user pick a theme:

```html
<link rel="stylesheet" href="house-style.css">
<link rel="stylesheet" href="house-product.css">
<script src="house-theme.js"></script>
```

(or inlines them in that order where the output must make no external requests). An Admin-only repo links the
first and the last and needs nothing else. The three files are vendored the same way, copied unchanged and
held to the pin in the [`dkj-brandbook` skill](../../skills/dkj-brandbook/SKILL.md)'s table;
`check-house-style` counts the classes in `house-product.css` as house classes, so a repo's own layer may not
restyle them either. The product page renderer is `Format-ProductPageHtml` and its siblings
(`Format-ProductHomeHeadHtml`, `Format-SiteHeaderHtml`, `Format-ProductBreadcrumbBarHtml`) in
[`scripts/lib/product-pages-lib.ps1`](../../scripts/lib/product-pages-lib.ps1); `dkj-policy`'s
`Format-GeneralPageHtml` draws Admin's desktop shell only and refuses `-BrandTag 'product'`.

**The other half is the core's README**, [`assets/dkj-brandbook/README.md`][core-readme] in `dkj-policy`: how to
use the brand book, every token, the twelve themes, `house-theme.js`, typography, tables and surfaces, the
desktop shell Admin uses, the shared components both layers take, the rename tables (the `Was` columns:
`check-house-style` reads them there) and the process for changing it. **Read it first; this page holds only
what the product layer adds**, and where a rule here says "the core's", it is that README's.

## Reserved names, the product layer's part

**The core's list of reserved names** ([Components][core-components]) covers the shared classes, so a repo layer
knows what not to redefine. The product layer reserves these too:

- **The app components** ([below](#app-components-from-mesowise)): `.container--narrow`/`main.narrow`, `.field`
  (with `__error`), `.btn--touch`, `.btn--block`, `.dialog` (with `__body`, `__head` (with `--two`, `--back`),
  `__title`, `__sub`, `__close` (with `--save`, `--cancel`, `--back`), `__handle`, `--drawer`, `--screen` and
  `--sheet`), `.topbar` (with `__inner`, `__brand`, `__name`), `.breadcrumbs-bar`
  ([below](#every-page-the-breadcrumb-bar)), the site header, `.site-header` (with `__brand`, `__name`, `__tag`,
  `__nav`, `__menu`, `__menu-toggle`, `__back`, `__title`, `__more`; [below](#the-site-header-above-the-bar)),
  the full-screen menu's parts, `.menu-section`, `.menu-footer` (with `__name`, `__note`) and `.menu-item__aside`
  ([below](#the-menu-in-the-header)), and the bottom bar, `.bottom-bar` (with `__item`, `__more`, `__icon`,
  `__label`; [below](#the-bottom-bar-on-a-phone)), the topic list, `.topic-list` (`.topic` around a plain `h2`, with `__link`,
  `__badge`, `__items`, `__item`; [below](#the-topic-list-a-home-page-on-a-phone)), the status card, `.status-card` (with `__kicker`), and the error state,
  `.error-state` on an `.empty-state` ([below](#status-card-and-error-state)).
- **The brand-book components** ([below](#brandbook-app-components)): `.round-toggle`, `.badge-toggle`, `.help`,
  `.more--structured` (`.more__title`, `__meta`, `__trailing`, `__version`), `.question-head` (the answer line
  under it is a plain `<p>`; `.verdict` is gone, Maikel, November 1, 2026), `.answer` (`__label`, `__value`),
  `.flash`, `.page-header`, `.field__fixed`, `.check`, `.stepper` (`--lg`), `.combo` (`__input` (with `--under`),
  `__picked`, `__glass`, `__list`, `__option` with `--own`, `--more`, `__name`, `__meta`), `.value-box` (`__num`
  with `--lg`, `--negative`, `--positive`, `--regular`, `__was`, `__unit`, `--changed`, `--flush`), `.stat-rows`
  (`--help`)/`.stat-row` (`__name`, `__sub`, `__help`, `__op`, `--help`, `--formula`, `--head`), `.step-head`
  (`__value`), `.info-rows` (`--info`, `__head`, `__list`), `.info-row` (`__box`, `__named`, `__value` with
  `--placeholder`), `.info-dot`, `.info-stem`, `.bill` (`--qty`, `__head`, `__slot`, `__name`, `__qty`,
  `__price`, `__action`, `__subtotal`, `__total`), `.compare`, `.calc` (`--boxed`, `__row`, `__box`, `__what`,
  `__sub`, `__op`, `__num`, `__result`), `.calc-section` (`__question`), `.date-list`/`.date-row` (`--near`,
  `--today`, `--invalid`, `--link`, `__when`, `__main`, `__body`, `__title`, `__sub`, `__trailing`, `__icon`,
  `__reason`), `.figure` (`--ratio-*`, `--contain`, `__frame`, `__placeholder`, `__glyph`, `__label`,
  `__caption`), `.chart-detail`, `.chart-row`, `.chart-swatch` and `.chart-figure`. Each is commented in the
  file.

## App components (from MesoWise)

**The brand book is extended with the MesoWise app** (Maikel, October 12, 2026; ported here on
October 13, 2026 by [#18](https://github.com/DKJ-Solutions/dkj-brandbook/issues/18), after the owner's
choice on [dkj-claude-plugins#2955](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2955)):
the components that app had and the brand book lacked were lifted into the same stylesheet. They are
the generic, mobile-first parts of an app shell: a narrow column, a form field, touch buttons, a dialog
and a side drawer, a top bar and a menu list. The group sits in
[`house-product.css`](house-product.css) under "App components" (it sat in `house-style.css`, right after the
desktop shell, until #3831). The menu list, `.icon-btn`, `.action-row` and `.sr-only` are in the core's
"Shared components" ([core README][core-shared]), because Admin's own pages use them.

- **Sizes.** Touch targets are at least `--tap` (44px) high. The column is `--column-narrow` (512px), a
  phone and, on a computer, the same width.
- **Buttons.** `.btn--touch` and `.btn--block` are modifiers of `.btn`, so the `.btn` hover, focus and disabled states
  covers them too, `.btn--touch.btn--primary` included.
- **Dialog.** A native `<dialog>` opened with `showModal`. Its title is the `h3` in `.dialog__head`, with no class, or a `p.dialog__title` where it is no heading; in a
  `.dialog--drawer` it is bold. The page stands still behind a modal
  (`html:has(dialog:modal)`), and `html:has(.topbar)` adds the scroll padding for the top bar.
  `.dialog--drawer` slides in from the side. A dialog on top of a dialog sets `--dialog-scale` (default
  0.95) smaller on itself: a hook the app sets, not a house token.
- **Contrast.** Field labels and the quiet icons use `--fg-1`, which holds 4.5:1 on
  `--bg-2`.
- **Input font.** The input's 16px is a literal, not a type step: iOS zooms in on focus below 16px.

**What this changes for an app that takes the update:** nothing that exists, only additions. But an app
that defines its own `.field`, `.dialog`, `.topbar`, `.menu-row`, `.icon-btn` or `.sr-only` now collides
with a house name, and renames its class or adopts the house one.

**What stayed in the app, because it is domain:** MesoWise's tinted "advised" and "profile" dialogs, the
level-up colours, the equipment lists, the stat lines, its own chip variants and the download button. The
generic `.chip`, the stat rows and the stepper are house classes since the
[brand-book components](#brandbook-app-components) moved in.

## Brandbook-app components

**The Brandbook app was retired under [#3493](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3493)** (owner's decision, October 26, 2026), and its component CSS moved here first so consumers receive it. Only the families the brand book had no class for were ported, renamed to the house convention (unprefixed, `.block`, `.block__part`, `.block--modifier`); a family the brand book already had was dropped in favour of the house class, so there is one vocabulary. The components were lifted from MesoWise and the ETF tracker, plus Brandbook-app originals (`.prose`, retired on November 2, 2026, `.figure`, `.filter-chips`, `.date-list`). The group sits at the end of [`house-product.css`](house-product.css), under "Brand-book components". **Since #3831 part of it is in the core**: alert, banner, panel, chip, tag, filter chips and the additions to existing classes below are in `house-style.css` under "Shared components" ([core README][core-shared]), because Admin's pages use them; the rest of this section is in `house-product.css`.

**Ported:** alert, banner, panel, chip, tag, filter chips, round and badge toggles, help, a structured disclosure (`.more--structured`), group heading, question head and verdict, amount, answer box, flash, page header, read-only field value, checkbox, stepper, search combobox, value box, stat and formula rows, step header, info rows, bill, comparison and calculation tables, date list, figure, prose, and the chart's tooltip rows.

**Dropped, the house class replaces it:** button and its variants (`.btn`, `.btn--primary`, `.btn--touch`, `.btn--block`), icon button (`.icon-btn`, `.action-row`), card (`.card`), dialog and drawer (`.dialog`, `.dialog--drawer`), top bar, menu rows, breadcrumbs, field, table wrap, message, tooltip, badge, meter, tile, hero figure, delta, legend, mini card, read-more, segmented choice (`.seg`, and `.menu-item` for a list), definition list (`.facts`), inline "?" toggle (`.info-button`). Not carried over, because the house class has no such state and the look is not general: the hover (the house `.btn` gained its own under [#3648](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3648)), outline, positive, compact and disabled-primary looks of the Brandbook app's button, the `--row` and `--joined` choice layouts, the accent and info dialog tints, the `.table-wrap` column drop-out (`col-low`), the meter and badge in `--cat-1`, and the warning tone helper: `.warn` is a class MesoWise and the ETF tracker already style themselves, so `.msg--warn` and `.notice` carry a warning instead.

**Added to existing classes** (no existing rule changed; in the core's "Shared components" since #3831): `.card--open`, `.card--invalid`, `.msg--error`, `.table-wrap:focus-visible`, `.table .row-negative`, `.row-positive`, `.row-warn`, `.col-start`, `.col-end`, `.facts__detail`, `.facts__total`, `.chart .bar--active`.

- **New tokens.** The corner radii, `--radius-1` 4px to `--radius-3` 12px and `--radius-pill` 999px (named `--radius-xs` to `--radius-lg` until [October 31, 2026][core-radius]); `--control-lg` 52px; `--datecol` 10ch; `--font-mono`. Everything else the Brandbook app defined maps onto an existing token (`--tap`, `--control-h`, `--topbar-h`, `--column-narrow`, the spacing and type scales) or onto a literal as in the older classes (weights, line heights, tracking, focus ring, motion).
- **Sizes and focus.** Interactive parts are at least `--tap` (44px) high, or grow their hit area to it (`::after`). The focus ring is `--primary-muted`, 2px, offset 2px (inset where the part is clipped).
- **Contrast.** Every pairing is a token pair already used in the brand book. A date row marked `--invalid` shows its date and reason in `--negative-5` (the Brandbook app used `--negative-3`, which is a fill step, not a text step). The native checkbox takes the theme through `accent-color`.
- **Browser support.** `.calc` needs `subgrid`, `.more--structured` container queries, `.step-head__value` uses `text-box` (ignored where unsupported, the figure is only less tightly centred).
- **Markup contracts.** The combobox marks its active option with `aria-selected="true"`, not a class. A stat row's button is an `.icon-btn` made `--control-h` square.

**What this changes for an app that takes the update:** nothing that exists, only additions. But an app that defines its own `.chip`, `.help`, `.amount`, `.calc`, `.verdict`, `.question-head` (all measured in MesoWise) or `.tag`, `.panel`, `.banner`, `.alert`, `.check`, `.answer`, `.flash`, `.figure`, `.stepper`, `.combo`, `.bill`, `.compare` now collides with a house name, and renames its class or adopts the house one. MesoWise's `.value` and `.input` do not collide (the value box is `.value-box`, and the standalone input class was not ported: `.field` styles its input).

## Status card and error state

**Two components after the Figma `Product / Status card` and `Product / Error state`** (#4096, drawn under #4087).

- **The status card** says where something stands: a kicker, an `h2`, an optional progress bar and the facts as one
  row (`.facts.facts--row`), on `--bg-3` with an 8px corner. **It is the surface itself, so it never sits inside a
  `.card`**: a card in a card is the frame twice.
- **The progress bar is the core's `.meter.meter--info`, with no class of its own.** A native `<progress>` takes
  `--primary` through `accent-color` and draws the browser's own track, while the Figma bar fills in `fill-accent`,
  which is `--primary-muted`: exactly `.meter--info`. Give it `role="progressbar"` and its `aria-value*`. Inside a
  status card its track is drawn on `--bg-4`, so it shows on the card's `--bg-3`.
- **The error state is the core's `.empty-state` with `.error-state` beside it**: the same frame, title, line and
  one action, the mark in `--negative-1` holding a `!` in `--negative-5`, and the action a retry. Give it
  `role="alert"` where it replaces content the user was waiting for.

```html
<section class="status-card">
  <p class="status-card__kicker">Dossier</p>
  <h2>Moving house</h2>
  <div class="meter meter--info" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" aria-label="Progress"><span style="width: 40%"></span></div>
  <dl class="facts facts--row"><div><dt>Open</dt><dd>6</dd></div><div><dt>Done</dt><dd>4</dd></div></dl>
</section>

<div class="empty-state error-state" role="alert">
  <span class="empty-state__mark" aria-hidden="true">!</span>
  <h2>Could not load</h2>
  <p class="empty-state__text">The list did not come back. Check the connection and try again.</p>
  <button class="btn" type="button">Try again</button>
</div>
```

## Page patterns

**These are the product layer's patterns.** Which of them Admin's desktop shell takes is in the table
under [Two layers][core-two-layers] in the core README: of the ones below, it takes the page-name rules and
none of the page structure. Admin, the one page pattern Admin keeps, stays in the core README
([Admin][core-admin]).

### Which shape a page's cards take

**Read what the page holds, and take the one shape for it** (owners, November 3, 2026,
[#3777](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3777)). The parts below were each defined, but
not when to use which, and a consumer's pages came out correct by every token check and wrong by eye in
both directions: an overview set each group's `h2` above its grid instead of inside it, and a document of
six sections rendered as one card about 3700px tall, with no cards and no drill-down.

| The page holds | Its shape | Not |
|---|---|---|
| **A flat list of pages**, no groups | one `.grid-3` with **no** `.grid__head`, one card link per page: THE card ([below](#every-page-a-long-page-becomes-cards-with-a-page-each)), its label the page's name | an `h2` or `h3` link inside the card; an `h2` above the grid |
| **A grouped list** | one grid per group, its first child a `.grid__head` holding the group's `h2` (then a `p.card__sub`), and each card titled `h3` | the group's `h2` as a sibling above or beside its grid |
| **A few cards, each naming a subject of the page** rather than a part of one group | each card titled `h2` ([below](#an-h2-may-title-a-card)), no `.grid__head` | an `h2` above them as well |
| **A document of more than four sections** | an overview: the text before the first section in one card, then one card link per section, each section a page one level down ([below](#every-page-a-long-page-becomes-cards-with-a-page-each)) | the whole document in one card, however narrow |
| **A group with nothing in it** | its empty state inside its own grid: one `.card.grid__full` after the `.grid__head` | an empty-state line beside or below the grid |

A long list inside one group stays one group ([A list is not sections](#every-page-a-long-page-becomes-cards-with-a-page-each)).
No check holds this table: the structural `heading` check stays retired (below), so it is the page's
author who reads it.

**What this changes for an app that takes the update:** nothing that exists; it names the choice the parts
below already allow. A page whose shape does not match its row does not break, but it does not follow the
brand book until it does.

### An h2 may title a card

**Retired rule** (Maikel, October 24, 2026): from October 19, 2026
([#3175](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3175)) an `h2` always stood above the
card or cards it heads and never inside one, and `check-house-style` held that as its fourth check, `heading`.
Both are gone: an `h2` may now title a card, as the Stopwatch's label cards do.

- **The grouping form still stands where a page groups cards**: a `.grid-2` whose first child is a
  `.grid__head` (the `h2`, then a `p.card__sub`), then the cards; a card with `.grid__full` takes the whole
  row. In a `.page-column` such a group takes no margin of its own: the column's `gap` is the only space between
  its blocks (Maikel, October 30, 2026; from #3175 it took an extra `--spacing-5` above it).
- **A card's own title under such a group is still an `h3`**: `.card__head` > a plain `h3` (with room for a
  `.badge` before the text), then an optional `.card__sub`. It is set like every `h3`; `.card__title`, which set it
  apart in `--fg-3` and semibold, is gone (Maikel, November 1, 2026).
- **A card that stands on its own may carry an `h2`** instead, when it is one of a set of cards that each name
  a subject of the page, rather than a part of one group.

### Every page: the breadcrumb bar

**Every page a DKJ-Solutions dev server serves opens with a breadcrumb bar** (owner's request, October 17,
2026). That is every page you can open in the preview browser: the home page, the product, and any
page below either. The bar says where the page sits and is the way back, so no page needs a "back" link of
its own. **An Admin page in the desktop shell carries its trail in the `.shell__bar` instead**
([Two layers][core-two-layers]); the labels and the `h1` rule below hold there too. The base `.breadcrumbs`
trail is the core's ("Shared components", [core README][core-shared]), because the shell's bar uses it; the
`.breadcrumbs-bar` that stands above `<main>` is this layer's.

**On a phone, a bar under a site header gives way to a back cell and the page's name** (owner, November 13,
2026, [#4048](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4048)): a trail is a desktop aid, and on a
phone it does not fit, its crumbs are small tap targets and the sticky bar costs a row of screen. How the header
carries it is under [On a phone: back and title](#on-a-phone-back-and-title). A bar with **no** site header above
it stays at every width, because nothing else would carry the way back.

- **Place:** the first element in `<body>` above `<main>` and
  outside it, so it spans the full width. Its trail lines up with the page column.
- **Always visible:** the bar sticks to the top of the screen while the page scrolls. It is one `--tap`
  (44px) high and one line: a trail longer than the screen scrolls sideways inside the bar instead of
  wrapping, so the height never changes. Whatever else sticks to the top sits under it, at `top: var(--tap)`;
  the brand book already does that for the floating settings button and for in-page anchors.
- **The trail:** it always starts at **Home**, linking to `/` (it read **Repo hub** until #3270, and **Tools** on the Toolbox from October 27, 2026 until #3815 renamed it Admin; a product keeps **Home** for its own pages). Each further crumb is one level
  down: the product (under its own name), then a page inside it. The last crumb is the current page,
  unlinked, with `aria-current="page"`. The bar stands on the theme's colour, `--primary` (owner, #3235, October 21, 2026), so
  the trail is in the paper steps, which all read on it: the chevron `--bg-3`, the ancestor links `--bg-2` (with
  a `--bg-1` focus ring), the current page `--bg-1`, every crumb at the regular weight and `--text-base` (owner, October 24, 2026; it was `--text-sm`); a link shows its underline only under the pointer. On the home page itself the trail is that one crumb: the bar is
  still there, so it sits in the same place on every page.
- **The labels** are the pages' own names, short, in the app's language: **two words at most**, as rule 8
  under [How to use it][core-how] holds the page name (#3797). A crumb names a page, never a
  section on a page: an in-page anchor is not a level.
- **The page's `h1` reads exactly what its current crumb reads** (owner, October 25, 2026): the same words,
  the same case, so the bar and the page never name one page twice in two ways. Write the name once and
  render both from it. A page whose current crumb is a label or a run (a Stopwatch label, a single run)
  takes that same text as its `h1`. The one page without an `h1` is the home page under a site header
  ([below](#the-site-header-above-the-bar)), and the rule has nothing to match there.
- **The markup:** `.breadcrumbs-bar` > `.container` > `nav.breadcrumbs[aria-label="Breadcrumb"]` > `ol`,
  one `li` per crumb, and a `<span class="breadcrumbs__sep" aria-hidden="true">` holding the chevron at the start
  of every `li` but the first (the stylesheet sizes it to `1.25rem` and thickens it with a stroke):

  ```html
  <svg viewBox="0 0 24 24"><path fill="currentColor" fill-rule="evenodd" d="M9.793 16.707a1 1 0 0 1 0-1.414L13.086 12 9.793 8.707a1 1 0 0 1 1.414-1.414l4 4a1 1 0 0 1 0 1.414l-4 4a1 1 0 0 1-1.414 0" clip-rule="evenodd"/></svg>
  ```

  [`patterns/product-page.html`][pattern-page] carries it.

**What this changes for an app that takes the update:** nothing that exists, only an addition. A page
without the bar does not break, but it does not follow the brand book until it has one. An app with its
own sticky element at `top: 0` (a sidebar, a toolbar) moves it to `top: var(--tap)` when it adds the bar,
or the bar covers it.

### Every page: a long page becomes cards, with a page each

**A page never grows into one long column of sections** (owners, October 26 and 27, 2026,
[#3563](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3563)). Once a page holds **more than
four sections**, each a `.grid__head` with its own `h2`, it becomes an **overview**: one card per section,
and each card opens **a page of its own** at `<page>/<section>`. Finding one part of a page should never mean
scrolling past the rest. This was decided one page at a time (the Stopwatch, SessionStart in #3543, the
brand book's own specimens in #3563, the Specialists in #3551) and is written down here once, so a new or
growing page gets this shape without anyone having to point it out.

**Length is a second trigger, beside the section count** (owner, November 15, 2026,
[#4114](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4114)). A page holding **more than 1,500 words
of reading** (about seven minutes) becomes the same overview of its sections, even with two to four of them,
because a few very long sections read as one endless column just as many short ones do. Measured in the first
consumer to need it: a page of 7,797 words in three sections stayed one column under the section count alone.

- **The rule is recursive.** A section's page obeys the same limit: still over it, that page becomes an
  overview of its next heading level (`h3`, then `h4`), at `<page>/<section>/<part>`, each level one more
  crumb. One section measured 3,569 words on its own, so splitting at the sections alone does not settle it.
- **Every heading that becomes a page becomes a crumb**, so the rule that a page name is short now reaches
  headings that were never page titles. Shorten them as they turn into pages.
- **A word of reading** is the text of a paragraph, a list item, a quote, a definition or a code block. A table,
  the navigation, the header and the footer are not reading, nor is a comment or a link's URL, for the same
  reason a list is not sections (below): a release list or a logbook runs long by nature.
- **A page with one long section and no subheadings still breaks the rule**, and it warns. It cannot be split
  mechanically, so the remedy is to give it headings it can split at.

- **The overview card is THE card**: Admin's one card link ([The card][core-admin], a `.card.card--link`
  holding one `.menu-item` row, written by `Format-AdminCardLinkHtml`), three to a row in a `.grid-3`. Its
  label is the section's name, and its one-line description is the section's **headline**: the figure
  that tells you whether the page is worth opening, such as the number of specimens in a house-style
  section. No hand-written variant: no `h2` or `h3` link inside the card, and no extra rows. A card that
  needs more (a figure on its own line, a badge, its label as a heading) takes it from the card's slots
  ([The card][core-admin]).
- **The section's page** is that section alone, under one more crumb, so the trail reads Home >
  ... > the overview > the section. Its `h1` is the section's name and the section's line is its `<meta name="description">`, never a lead under the `h1` (#3585). Its
  own `.grid__head` goes, because the `h1` already says it.
- **A list is not sections.** A logbook, a release list or an issue list may run long inside **one**
  section. The rule counts `.grid__head` blocks, not cards or rows.
- **Where it holds itself:** the product's page shell (`Format-ProductPageHtml`, through dkj-policy's `Get-LongPageWarningHtml`) counts the sections of
  every page it renders, and above four it puts a warning at the top of that page naming the count and
  this rule; it counts the words of reading too, and above 1,500 it puts a second warning there
  (`Get-PageWordCount`, #4114). A page that breaks the rule says so on its own, instead of waiting to be
  spotted.

### The site header, above the bar

**An app may open with a site header, and the breadcrumb bar then stands right under it** (owner, October
22, 2026). **Every Admin page carried it until #3831** (the dkj-policy plugin's Admin server drew it on the home page and
every general page of every repo, with the repo's name and `admin` after it): **Admin's pages no longer do**, because the
desktop shell's bar and side navigation replace it ([Two layers][core-two-layers]), and `dkj-policy` ships no code
that draws it. A product's pages carry it, drawn by `Format-SiteHeaderHtml` in `product-pages-lib.ps1`; an app without
one keeps the bar as described above.

- **The header:** `header.site-header` > `.container`, at most `--spacing-18` (72px) high, on `--primary`
  over the full width. On the left the app's name, `a.site-header__brand` linking home (`/`); on
  the far right, **where the app offers its theme there**, the settings button, `DKJTheme.settings` mounted in a
  plain `#settings` inside the header, so nothing floats. **The button is optional.** The dev servers this
  marketplace ships mount none (Maikel, November 3, 2026): a product's theme is chosen on its own Settings page, and
  the `.site-header .theme-settings` rules stay for an app that still mounts it. The name, `.site-header__name`, is set at `--text-h2` (`--text-title` until November 14, 2026, #4078); `.site-header__tag` sets a quieter word after the name (`product`).
  **The header carries no mark** (Dave, November 2, 2026): `.site-header__mark`, the organisation's initials on
  `--bg-1` (#3301), is retired, so an app that takes this update drops that `<span>` from its header.
- **No eyebrow under it:** the header already names the site, so the intro opens with the `h1`. **A home page has no
  intro at all** (owner, October 22, 2026): its `h1` and lead only repeated the header, so `<main>` opens on its first
  block.
- **The bar under it leaves the primary to the header:** `.site-header + .breadcrumbs-bar` stands on
  `--bg-1` with a `--bg-3` line under it, and the trail is quiet (links `--primary-muted` since November 1, 2026, Maikel; `--fg-3` before; the
  chevron `--primary-muted`, the current page `--primary`, since October 24, 2026, the owner; it was `--fg-1`). The header
  scrolls away; the bar still sticks to the top.

```html
<header class="site-header"><div class="container">
  <a class="site-header__brand" href="/" aria-label="my-app, home"><span class="site-header__name">my-app</span></a>
  <div id="settings"></div>
</div></header>
<div class="breadcrumbs-bar">...</div>
```

**What this changes for an app that takes the update:** nothing, unless it adds a `.site-header`; the
bar's own colours change only right under one.

#### On a phone: back and title

**Where the header is narrower than 48rem, a page below home shows a back cell and its own name in the header,
and the breadcrumb bar under the header is hidden** (owner, November 13, 2026,
[#4048](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4048)). 48rem is the width the menu folds at, so
the two change together.

- **The back cell**, `a.site-header__back`, comes first in the header's `.container`: a cell the full height of the
  bar, as wide as the menu toggle, holding the house chevron mirrored to point left, with the same `--primary-hover`
  hover. It links **one level up**, the page the bar's last linked crumb names (home on a page one level down), and
  its `aria-label` reads `Back to <that page>`.
- **The title**, `span.site-header__title` right after the brand, is the page's own name, the same text as its
  current crumb and its `h1`, at `--text-h2`. It is `aria-hidden`, because the `h1` already says it to a screen
  reader. **The brand gives way to it**, so the row reads back, title, then the menu toggle.
- **A wide header hides both**, and the bar is back. The home page has neither, so on a phone it keeps its brand.
- **The bar's hide reads the window** (`@media (max-width: 48rem)`) and the Phone width in the settings
  (`:root[data-width="phone"]`): the header's own fold is a container query, and a container query cannot reach the
  bar beside it.
- **The title is never a button.** A phone has no path on demand: the back cell is the way up, one level at a time
  (Dave, November 15, 2026, as dkj-lifehub's header does; the path sheet #4095 added is gone).

`Format-SiteHeaderHtml -Back @{ Label; Href } -PageTitle <name>` draws both, and `Get-SiteHeaderBack` picks the page
one level up from the trail; `Format-ProductPageHtml` passes them on every page below home. `-Path` is still accepted,
so a caller that passes it does not fail, and draws nothing.

```html
<header class="site-header"><div class="container">
  <a class="site-header__back" href="/projects" aria-label="Back to Projects">(chevron, mirrored)</a>
  <a class="site-header__brand" href="/" aria-label="my-app, home"><span class="site-header__name">my-app</span></a>
  <span class="site-header__title" aria-hidden="true">Project X</span>
  <nav class="site-header__nav" aria-label="Main">...</nav>
</div></header>
<div class="breadcrumbs-bar">...</div>
```

**What this changes for an app that takes the update:** on a phone, a page whose header carries no back cell loses
its bar and has no way up but the browser's own back, so add `.site-header__back` and `.site-header__title` to every
page below home in the same update. An app that keeps its sticky elements at `top: var(--tap)` under the bar moves
them to `top: 0` below 48rem.

#### The menu in the header

**A site header may carry the app's main pages after the brand, before the settings button where there is one** (Maikel, November 2,
2026, after the three-zone nav of djcylow: brand, menu, button). The breadcrumb bar under it stays: the menu says
where you can go, the trail where you are.

- **On a wide header** the links stand in the middle of the space between the name and the button, each a cell the
  full height of the bar with the `--primary-hover` hover the settings button has; the page you are under carries a
  `--bg-1` bar along its bottom (`aria-current="page"`).
- **Narrower than 48rem** the links fold away and a three-line toggle opens them as a **full-screen menu**,
  `dialog.dialog--screen.site-menu` (#4095, Figma `Product / Menu row`, `Menu section head` and `Menu footer`; it was
  the side drawer, `dialog.dialog--drawer`, until then). The width is the **header's own**, through a container
  query, so the Phone width in the settings folds it as a phone does.
- **The full-screen menu** reads like a phone's settings screen. Its head is the site header's own bar: the primary,
  as tall, the back cell at the left closing it, and the title `Menu`. Under it three sections, each a
  `p.menu-section` (small, uppercase, `--primary-muted`): **Pages**, the menu's items as `.menu-item` rows (an optional
  `.menu-item__icon`, the label with an optional `.menu-item__sub` line, an optional `.menu-item__aside` value at the
  right, the chevron; a `--bg-3` line under each); **Display**, one row to the app's settings page, in the place the
  gear takes on a computer, drawn only where the app has one (`-SettingsHref`); and **About**, closed by a
  `.menu-footer`: the app's name and a quieter line such as the brand book version (`-MenuNote`). The content keeps
  the narrow column, so at the Phone width on a computer it lines up with the header.
- **`house-theme.js` wires it** with no call of its own: the toggle opens the dialog its `aria-controls` names as a
  modal (so Escape and the focus return are the browser's), and a click on the close button or the backdrop, or the
  header growing wide again, shuts it.
- **The menu sits inside the header, after its `.container`**, as the sheets do, so `.site-header + .breadcrumbs-bar`
  still matches.

```html
<header class="site-header"><div class="container">
  <a class="site-header__brand" href="/" aria-label="my-app, home"><span class="site-header__name">my-app</span></a>
  <nav class="site-header__nav" aria-label="Main">
    <ul class="site-header__menu"><li><a href="/a" aria-current="page">A</a></li><li><a href="/b">B</a></li></ul>
    <button class="site-header__menu-toggle" type="button" aria-controls="site-menu" aria-expanded="false" aria-label="Menu">(three lines)</button>
  </nav>
  <div id="settings"></div>
</div>
<dialog class="dialog dialog--screen site-menu" id="site-menu" aria-label="Menu"><div class="dialog__body">
  <div class="dialog__head dialog__head--back"><p class="dialog__title">Menu</p></div>
  <button class="dialog__close dialog__close--back" type="button" aria-label="Close the menu">(chevron left)</button>
  <nav class="menu-list" aria-label="Main">
    <p class="menu-section">Pages</p><a class="menu-item" href="/a" aria-current="page">..</a><a class="menu-item" href="/b">..</a>
    <p class="menu-section">Display</p><a class="menu-item" href="/settings">..</a>
    <p class="menu-section">About</p>
  </nav>
  <div class="menu-footer"><p class="menu-footer__name">my-app</p><p class="menu-footer__note">Brand book v6.16.0</p></div>
</div></dialog></header>
```

**What this changes for an app that takes the update** (#4095): its phone menu opens full screen instead of as a
drawer. An app that draws the menu by hand swaps `dialog--drawer` for `dialog--screen`, adds the sections, and turns
its close into the back cell; one that draws it with `Format-SiteHeaderHtml` gets it with the update. The drawer
itself stays a house class for an app's own use.

#### The sheet: actions

**A short list of choices on a phone rises from the bottom as a sheet** (#4095, Figma `Product / Sheet`):
`dialog.dialog--sheet`, the paper, rounded at the top only and the narrow column wide, over the page dimmed in the
primary. It holds a grab handle (`span.dialog__handle`), an optional `p.dialog__title`, and `.menu-item` rows with no
line between them, the page you are on bold in the primary. A tap on the dimmed page shuts it, as Escape does.

- **The actions sheet** opens from a **More cell**, `button.site-header__more` (three dots, as wide as the menu
  toggle, Figma `Product / Site header`, More=true), and lists the page's own actions (the lifehub's *Save as PDF*,
  say), titled with the page's name. On a phone it stands before the menu toggle; on a wide header at the far right,
  because the actions are the page's and must not vanish on a computer. `Format-SiteHeaderHtml -Actions` (each
  `@{ Label; Href }`) draws the cell and its sheet, and `Format-ProductPageHtml -Actions` passes them on.
- **`house-theme.js` wires both** as it wires the menu: the trigger opens the dialog its `aria-controls` names as a
  modal and sets `aria-expanded`; a tap on the backdrop, or the trigger vanishing as the header grows wide, shuts it.

```html
<button class="site-header__more" type="button" aria-controls="site-actions" aria-expanded="false" aria-haspopup="dialog" aria-label="More actions">(three dots)</button>
...
<dialog class="dialog dialog--sheet" id="site-actions" aria-label="Actions"><div class="dialog__body">
  <span class="dialog__handle" aria-hidden="true"></span><p class="dialog__title">Page name</p>
  <nav class="menu-list" aria-label="Actions"><a class="menu-item" href="/pdf"><span class="menu-item__label">Save as PDF</span>(chevron)</a></nav>
</div></dialog>
```

**What this changes for an app that takes the update:** nothing, unless it passes `-Path` or `-Actions` or draws the
sheet itself.

#### The bottom bar, on a phone

**A product may put its sections in the thumb zone** (#4094, after the Figma `Product / Bottom bar`, #4084): a bar
fixed to the bottom of a phone, a hairline on top and the safe area padded below. It has **four slots or five**:
three or four sections, then **More**, always last, a button that opens the site menu.

- **Each slot** is a 16px icon over a 12px label, a 44px tap target, all equally wide. The section you are in
  carries `aria-current="page"` and is bold in the text colour; the others are regular and muted. The icon is the
  app's own.
- **Phone only.** It shows below 48rem, the width the header folds its menu at, and at the Phone width, where it is
  as wide as the page column. On a wide window it is gone and the menu sits in the header.
- **More replaces the header's toggle**, so a page with a bottom bar leaves `.site-header__menu-toggle` out (Figma
  `Menu toggle=false`) and keeps the header's links and its menu. `house-theme.js` wires More as it wires the
  toggle.
- **It is a direct child of `<body>`**, so the page gets the bar's height as padding below and its last line is
  never under the bar.
- **The renderer** is `Format-BottomBarHtml` in this plugin's `scripts/lib/product-pages-lib.ps1`, and
  `Format-ProductPageHtml -BottomBar` / `Format-ProductHomeHeadHtml -BottomBar` draw it and drop the toggle. A bar
  needs a `-Menu`, because More opens the menu the header draws from it.
  [`patterns/product-bottom-bar.html`][pattern-bottom-bar] is the stylesheet-only reference.

```html
<nav class="bottom-bar" aria-label="Sections">
  <a class="bottom-bar__item" href="/"><span class="bottom-bar__icon">(svg)</span><span class="bottom-bar__label">Home</span></a>
  <a class="bottom-bar__item" href="/agenda" aria-current="page"><span class="bottom-bar__icon">(svg)</span><span class="bottom-bar__label">Agenda</span></a>
  ..
  <button class="bottom-bar__item bottom-bar__more" type="button" aria-controls="site-menu" aria-expanded="false"><span class="bottom-bar__icon">(three lines)</span><span class="bottom-bar__label">More</span></button>
</nav>
```

#### The topic list, a home page on a phone

**A product's home page on a phone is a list of topics, not a stack of cards** (Figma wireframe `H1 - Home
(mobiel)`; first built in dkj-lifehub, where its shape was settled): each topic a heading with its initial in a round
badge, the topic's sections under it, a thin rule between topics, indented to the heading's text.

- **The badge is on the primary.** A small mark beside a heading is an accent, as the current bottom-bar slot is,
  so it does not break the rule that the theme colour is never a fill for content (Dave, November 13, 2026).
- **The whole row is the tap target**, with a press state across the full width, for the heading and each section.
- **A topic without a page of its own** puts a `span.topic__link` in its heading instead of a link.
- **The list is always drawn.** A home page that keeps its cards on a wide screen hides one of the two forms
  itself, at 48rem, the width the header folds its menu at.

```html
<nav class="topic-list" aria-label="Pages">
  <section class="topic">
    <h2><a class="topic__link" href="/brain"><span class="topic__badge" aria-hidden="true">B</span>Brain</a></h2>
    <ul class="topic__items"><li><a class="topic__item" href="/brain/work">Work</a></li></ul>
  </section>
  ..
</nav>
```

**In Admin** there is no site header menu: Admin draws its side navigation instead (`Get-AdminNav`), whose Development section is its home page's cards in their order (GitHub, Release notes, Claude, Installed plugins: `Get-AdminMenu`, from the same list the cards come from). A product's menu is its own pages.

### The product page: the phone rules and the computer layout

**One shell, every app** (#4097, after the Figma `Wireframes · Product` frames and their notes, #4088, for the goal
in [#4081](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4081)). Phone first at 390 wide with a 16px
gutter, every tap target 44px or more. [`patterns/product-page.html`][pattern-page] carries all of it.

**On a phone:**

- **The title appears once**: in the site header, beside the back cell ([above](#on-a-phone-back-and-title)). The
  page's `h1` stays in the markup for a screen reader, since the header's title is `aria-hidden`, but leaves the
  screen: `house-product.css` hides it wherever the window is narrower than 48rem, or the width is Phone, and the
  page has a `.site-header__back`. Keep the `h1` a direct child of its column, so it leaves no gap.
- **No card inside a card.** A list is one card of rows; a status card and a details card stand one under the other,
  never nested. A `.status-card` is a surface itself and never sits in a `.card`.
- **Compact rows of about 52px instead of large tiles**: `.card.card--rows.menu-list`, one `a.menu-item` per item
  (the title, its meta line in `.menu-item__sub`, an optional value in `.menu-item__aside`, the chevron), a line
  between the rows.
- **An empty message is dropped rather than shown**, unless the empty list is the page itself, where the empty
  state is the content.
- **The theme colour is an accent, never a fill**: the current bottom-bar slot, the progress bar, the current menu
  item. A block on the primary (`.fill-primary`) is not for a product page's content.
- **A failure shows the [error state](#status-card-and-error-state)** beside the empty state: what failed, what you
  can do, a retry.

**On a computer, a main column and a sidebar**: `main.page-layout`, holding a `.page-layout__main` (640px) and an
`aside.page-layout__side` (320px), each also a `.page-column`, 48px apart and centred, under the site header with
its menu and the breadcrumb bar. The breadcrumb bar is for the computer only; a phone has the back cell. The
sidebar holds what stands beside the work (a status card, card links elsewhere), each part under its own `h2`.
Narrower than 48rem, and at the Phone width, the two stack: the sidebar comes after the main column. The bottom bar
and the sheets do not appear on a computer.

```html
<main class="page-layout">
  <div class="page-layout__main page-column">
    <h1>Items</h1>
    <nav class="card card--rows menu-list" aria-label="Items">
      <a class="menu-item" href="/items/1"><span class="menu-item__label">Item one<span class="menu-item__sub">Group A · 25 min</span></span><span class="menu-item__aside">4.5</span>(chevron)</a>
    </nav>
  </div>
  <aside class="page-layout__side page-column" aria-label="Beside the items">
    <h2>Status</h2><section class="status-card">..</section>
    <h2>Elsewhere</h2><section class="card card--link">..</section>
  </aside>
</main>
```

**What this changes for an app that takes the update:** on a phone, every page below home that has a back cell
loses its visible `h1`, so a page that relied on it alone to say where you are gains nothing to do: the header
already says it. A page that put anything else in a wrapper around its `h1` keeps that wrapper's space; move the
`h1` out of it. `.page-layout` and `.card--rows` are new, so nothing else changes until a page uses them.

## Changing this layer

**The process is the core's** ([Changing the brand book][core-changing]): a change here is a **visible result**, it
reaches a product only once it is released, and a consuming repo asks for it through an inbound issue, never a
local edit. The product specimens (`specimens.html` beside this file) are how a change is judged by eye, and
the `house-style-css` gate parses `house-product.css` as it does the core's.

[core-readme]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md
[core-how]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md#how-to-use-it
[core-components]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md#components
[core-shared]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md#shared-components
[core-radius]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md#the-radius-rename-of-october-31-2026
[core-two-layers]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md#two-layers
[core-admin]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md#admin
[core-changing]: https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-policy/assets/dkj-brandbook/README.md#changing-the-brand-book
[pattern-page]: patterns/product-page.html
[pattern-bottom-bar]: patterns/product-bottom-bar.html
