# Changelog

## [Unreleased]

**8 / 11 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4123-single-header-action · 20261115-194435Z

A product page with a single action, such as *Save as PDF*, now shows that action as its own icon in the site
header, instead of three dots that open a sheet holding one item. The three dots and the sheet appear only when a
page has two actions or more. An app drawing its header with `Format-SiteHeaderHtml` gets this with the update.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Product header: a page with one action shows it directly

Plugins: dkj-solutions

[PR #4134](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4134)

---

### DEPLOY: fix/4111-docs-coverage-scroll · 20261115-193008Z

A wide house table no longer widens the whole page on a phone. Its scroll container, `.table-wrap`, is now
the containing block of what is positioned inside it, so a visually hidden column head at the table's far
edge (the Docs coverage page's Details column) is clipped with the rest of the table instead of setting the
document's width. On the product's `/docs-coverage` at 375 px the page measured 1322 px wide and now measures
375, with the table scrolling inside its own box (#4111).

**Score:** 3

#### What makes this deploy extra special

Any page in a consuming repo that puts a `.sr-only` element, or anything else absolute, inside a wide
`.table-wrap` stops scrolling sideways as a whole on a phone once it takes this brand book.

**Score:** 2

#### Pull Request

A wide table's hidden column head no longer widens the page on a phone

Plugins: dkj-policy

[PR #4133](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4133)

---

### DEPLOY: feat/4126-no-group-surface · 20261115-191324Z

A card group is no longer a surface of its own
([#4126](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4126)): `.grid-2`, `.grid-3` and `.card-grid`
lose the `--bg-2` tray, its radius and its padding at every width, so a card in a group is the same plain card it is
anywhere else, on `--bg-2` against the page. That reverses the padded tray of November 2, 2026, and takes with it
the darker card fill inside a group and the button edge #3697 gave it.

**Score:** 2

#### What makes this deploy extra special

Every DKJ-Solutions app that takes the update loses the frame around its card groups: the cards stand on the page
directly, one step lighter or darker than it, and on a phone they gain the width the padding took on both sides.
No markup changes; an app whose own layer leaned on the group's padding checks its spacing.

**Score:** 3

#### Pull Request

Brand book: a card group is no surface of its own

Plugins: dkj-policy, dkj-solutions

[PR #4132](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4132)

---

### DEPLOY: feat/4113-consumer-group-rows · 20261115-182852Z

The BWJ and Other repos on the Consumers pages read like the DKJ ones: a group's page is a card per repo -- on a
phone one card of compact rows -- and each repo's report is a page of its own, where its long paths and plugin ids
wrap inside the card. The table and the one long report of every repo are gone.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Consumer group pages as rows with a page per repo

[PR #4130](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4130)

---

### DEPLOY: feat/4113-phone-page-furniture · 20261115-174831Z

On a phone a product page no longer shows a lone "?" at the top left or a long note of source paths at its foot,
and a row of figure tiles, such as a specialist's token costs, reads as one card of compact rows. That matches the
mobile wireframes. A wide screen is unchanged.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

On a phone, no lone '?', no source note, and the stat tiles as one card of rows

Plugins: dkj-solutions

[PR #4122](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4122)

---

### DEPLOY: feat/card-grid-rows-on-phone · 20261115-173629Z

On a phone a list of pages -- the consumer repos, the plugins, a team's specialists -- is one card of compact rows
with its heading above, instead of a stack of large tiles in a grey surface, as the mobile wireframes draw it. No
card sits inside a surface on a phone any more. A wide screen keeps its tiles.

**Score:** 3

#### What makes this deploy extra special

Every product built on the brand book gets this on a phone without a markup change: a group of card links becomes
one card of rows, and a group never wraps its cards in a second surface there.

**Score:** 3

#### Pull Request

On a phone a group of card links reads as one card of compact rows, after the mobile wireframes

Plugins: dkj-solutions

[PR #4121](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4121)

---

### DEPLOY: docs/4115-scope-question · 20261115-154629Z

Chris now asks whether a piece of work is shared before he routes it. An owner's requirement, an
irritation or a found defect counts as shared product behaviour (the brand book, page patterns, the
workflow scripts) unless the repo's facts rule lists it as a declared deviation with its reason, and
under doubt it is shared. So it is filed or commented on the source tracker first, and any local build
in the meantime is a declared bridge that names that inbound issue and is removed when the release
lands. The constitution now lists those declared deviations among a repo's facts (#4115).

**Score:** 3

#### What makes this deploy extra special

In every consuming repo, a requirement that holds for every DKJ repo is now reported at the source before
it is built, instead of being built locally and then again in each of the other repos. A repo that really
does differ writes the deviation and its reason into its facts rule.

**Score:** 3

#### Pull Request

Chris asks 'is this shared?' before building

Plugins: dkj-policy, dkj-subagents-alpha

[PR #4120](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4120)

---

### DEPLOY: fix/facts-long-value · 20261115-153440Z

On a phone a fact row's long value -- a source path, a plugin with its note, a sentence -- no longer runs over its
label or past the card: the label keeps its width and the value wraps under itself, right-aligned. A short value
reads as before.

**Score:** 3

#### What makes this deploy extra special

Every product built on the brand book shows its `.facts` lists readably on a phone: a long value wraps instead of
covering its term. A page that wants one-line facts now says `white-space: nowrap` in its own layer.

**Score:** 2

#### Pull Request

A fact row's long value wraps under its label instead of running over it on a phone

Plugins: dkj-policy

[PR #4118](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4118)

---

### DEPLOY: feat/4112-device-preview · 20261115-151812Z

Inside this repo, the product layer gains a device-preview pattern and specimen, and `house-theme.js` switches its
versions.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product that shows a mobile mockup, an A/B variant or a design proposal takes the brand book's phone
frame (`.device-stage`, `.device`, `.device__screen`) instead of writing its own: an iframe per version keeps the
mockup's own look, and a `.seg` above it switches versions with no script of the page's own.

**Score:** 3

#### Pull Request

Brand book: a device preview with an A/B toggle

Plugins: dkj-policy, dkj-solutions

[PR #4119](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4119)

---

### DEPLOY: feat/4114-long-page-word-limit · 20261115-150505Z

A page now splits on length as well as on section count: the brand book's long-page rule
([#3563](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3563)) only ever counted sections, so a
page of three sections and 7,797 words stayed one column. Over **1,500 words of reading** a page becomes an
overview of its sections, and a section page still over the limit splits at its next heading level
([#4114](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4114)). The page shell's guard,
`Get-LongPageWarningHtml`, warns on the word limit too, through a new `Get-PageWordCount` that counts the
text of paragraphs, list items, quotes and code blocks and leaves tables and navigation out, because a list
is not a long page: a plain count put Admin's release-notes list at 1,755 words, its prose at 15.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that renders long content (a dossier, a guide) now gets a warning at the top of any
page over 1,500 words of reading, through the shared page shell, and the `dkj-brandbook` skill names the
threshold before such a page is written. Admin's own pages are all far below it, so nothing changes there.

**Score:** 3

#### Pull Request

A long page splits on length too, not only on section count

Plugins: dkj-policy, dkj-solutions

[PR #4117](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4117)

---

### DEPLOY: feat/product-home-mobile-topics · 20261115-145440Z

On a phone the product follows the mobile wireframes. The home page is a list of topics instead of five cards:
Admin, Consumers (with DKJ, BWJ and Other under it), Plugins (with dkj-subagents and dkj-policy), Docs coverage and
Settings, each a heading with its initial in a badge -- the brand book's new topic list. Every product page carries the house bottom bar -- Home,
Consumers, Plugins, and More, which opens the site menu -- so the header leaves its menu toggle out. The Consumers pages no
longer scroll sideways on a phone, and the phone header's title is plain text, with no path menu behind it. A wide screen is unchanged.

**Score:** 3

#### What makes this deploy extra special

The brand book's product layer gains the topic list, `.topic-list` in `house-product.css`: a home page on a phone as
topics with an initial on the primary and their sections under them, the whole row pressable. A product that built
its own copy -- dkj-lifehub's `hub-rubriek` -- can drop it for this one once it takes the release. And the
phone's site header loses its path sheet: the page title is plain text again, the back cell is the way up, and
`Format-SiteHeaderHtml -Path` is still accepted but draws nothing, so a caller that passes it keeps working.

**Score:** 2

#### Pull Request

The product on a phone, after the mobile wireframes: the brand book's topic list on the home page and a bottom bar on every page

Plugins: dkj-policy, dkj-solutions

[PR #4116](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4116)

---

