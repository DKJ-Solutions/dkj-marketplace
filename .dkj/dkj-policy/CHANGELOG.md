# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

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

