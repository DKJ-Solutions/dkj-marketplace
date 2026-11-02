# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

### DEPLOY: fix/release-notes-headings-no-code · 20261102-163529Z

The brand book gains rule 8 (Maikel, November 2, 2026): an `h1`, `h2` or `h3` has five words at most,
in its README and in the `dkj-brandbook` skill. The v6.3.0 release notes now follow rules 7 and 8: no
`code` element in a heading, and every heading at five words or fewer. Who a change is for moved into the
text under it. On the release-notes page each h3 and its text now stand in a house card of their own, in
the grid form the brand book's own pages use, and the note no longer wraps them in a panel. A gate in the release-note form check is #3752.

**Score:** 1

#### What makes this deploy extra special

A session building a page in a DKJ-Solutions repo now keeps every heading to five words and puts who it is for in the content under it.

**Score:** 2

#### Pull Request

Release notes: short headings, no code in them, each h3 section a card

Plugins: dkj-policy, dkj-solutions

[PR #3753](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3753)

---

### DEPLOY: docs/no-code-in-headings · 20261102-160112Z

The brand book gains a rule (Maikel, November 2, 2026): no `code` element inside an `h1`, `h2` or `h3`,
because a fixed-width run in a heading looks out of place. It is rule 7 in the brand book's README and a
bullet in the `dkj-brandbook` skill, so a session reads it before any visual work.

**Score:** 2

#### What makes this deploy extra special

A session building a page in a DKJ-Solutions repo now names things in plain words in its headings and
keeps file names, commands and identifiers for the content under them.

**Score:** 2

#### Pull Request

Brand book: no code element inside an h1, h2 or h3

Plugins: dkj-policy, dkj-solutions

[PR #3750](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3750)

---

