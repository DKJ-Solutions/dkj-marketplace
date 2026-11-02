# Changelog

## [Unreleased]

**1 / 2 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3718-bare-cr-in-test · 20261102-084057Z

A consumer-dashboard test held a raw carriage-return byte inside a regex, so any edit through a tool that reads with universal newlines silently turned it into a line break and the assert went red with no visible change. It now writes the escape `\r`, as its neighbours do ([#3718](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3718)).

**Score:** 1

#### What makes this deploy extra special

N/A -- a test in this repo; nothing a plugin user takes changes.

**Score:** N/A

#### Pull Request

consumer-dashboard test writes the CR in its regex as an escape, not a raw byte

[PR #3724](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3724)

---

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

