# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

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

