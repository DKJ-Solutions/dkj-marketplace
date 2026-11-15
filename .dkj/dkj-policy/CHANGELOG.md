# Changelog

## [Unreleased]

**6 / 7 minor entries** <!-- pending-tally -->

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

