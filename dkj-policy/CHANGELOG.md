# Changelog

## [Unreleased]

**3 / 4 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3727-brandbook-derived-token-value · 20261102-090218Z

The brand book README said a colour function was allowed "outside a token's own value", which read as
permission for `--x: color-mix(…)`, while `check-colour-literals.mjs` refuses a derived colour anywhere. The
README now follows the gate: no derived colour, a token's own value included
([#3727](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3727)).

**Score:** 1

#### What makes this deploy extra special

A consumer writing its own domain layer from the README could have typed a `color-mix()` token and been
told it was allowed; the README no longer says so.

**Score:** 1

#### Pull Request

Brand book README: a token's own value may not derive a colour either

Plugins: dkj-policy

[PR #3730](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3730)

---

### DEPLOY: feat/3720-house-style-colour-check · 20261102-085146Z

The brand book's gate, `check-house-style`, gains a fourth check, `colour`: a rule in a repo's own layer reads
a colour only as a token ([#3720](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3720)). A colour
property (`color`, `background`, `border-color`, `fill` and the like) whose value types a code (`#hex`,
`rgb()`, `hsl()`) or derives one (`color-mix()`, `oklch()`, `rgb(from ...)`) is a finding. A custom
property's own value is not, so a domain colour stays a token of the repo's own. The session check reports
it too, and the House style page's four raw sample colours are allowlisted here until #3725 gives them a
token.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions repo running the house-style gate gets a new finding for every rule that types or mixes a
colour, and the reusable workflow tracks `main`, so it arrives at the merge rather than at the next release.
Measured on November 2, 2026: 11 `color-mix()` rules in dkj-music-library, 2 in dkj-recipes' icon script,
none in dkj-etf-tracker. All three already fail the gate on retired token names, so no green check turns
red. The fix is the one the README names: add a domain token (`--my-row-tint: ...`) holding the colour and
read it with `var()`, or answer a false positive in `Get-HouseStyleAllowlist` with its reason.

**Score:** 3

#### Pull Request

check-house-style refuses a raw or derived colour in a consumer's rules

Plugins: dkj-solutions

[PR #3728](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3728)

---

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

