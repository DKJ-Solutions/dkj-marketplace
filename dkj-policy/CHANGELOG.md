# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: fix/3705-brandbook-console-text · 20261102-083221Z

The brand book's scripts now say "the brand book" where they printed "house style": the
`house-style-sessioncheck` line at session start, `check-house-style`'s `[OK]`/`[FAIL]` verdict and its
retired-token finding, and the two CSS gates' `[OK]` lines. The file names keep `house-style`, and no
workflow or check name changes. Resolves #3705.

**Score:** 1

#### What makes this deploy extra special

A DKJ-Solutions repo's session-start line now reads *"the brand book holds at vX.Y.Z"*, in the same word the
skill and the docs use since the rename.

**Score:** 2

#### Pull Request

Script and hook console text says 'the brand book', not 'house style'

Plugins: dkj-solutions

[PR #3723](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3723)

---

