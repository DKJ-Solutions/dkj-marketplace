# Changelog

## [Unreleased]

**2 / 3 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3766-trunk-sync-cli-diagnostics · 20261103-091659Z

When the `sync-trunk.ps1` single-checkout case in `trunk-sync.tests.ps1` fails, the suite now prints what that script said, not just the three red asserts. It failed once under the parallel test gate (#3766) and could not be reproduced in 18 runs, so the next failure will name its own cause.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

trunk-sync.tests: print sync-trunk.ps1's own output when the single-checkout case fails

[PR #3769](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3769)

---

### DEPLOY: feat/3761-store-execute-live-refused · 20261103-085504Z

The Shopify team's live-theme guard now refuses an Admin API theme write aimed at the live theme (`themeFilesUpsert`, `themeFilesCopy`, `themeUpdate` and the rest, through `shopify store execute`) even when the command carries `# LIVE-PUSH-AUTHORIZED`. Until now the marker let it through, and because its content is inline rather than in theme files, nothing held it to the trunk the way #3758 holds a CLI live push, so unmerged work could reach live by that route. The refusal now points at the one live route: a CLI `shopify theme push` of merged work, which `live-preflight` composes.

**Score:** 2

#### What makes this deploy extra special

A Shopify consumer that wrote to its live theme through `shopify store execute` with the marker is refused now and has to push merged work with `shopify theme push` instead. No documented flow used the API route, so for most consumers nothing changes except that the merged-only rule can no longer be bypassed.

**Score:** 2

#### Pull Request

guard-live-theme: refuse every live-aimed Admin API theme write, marker or not

Plugins: dkj-subagents-shopify

[PR #3768](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3768)

---

### DEPLOY: docs/brandbook-no-em-dash · 20261103-084431Z

The brand book gains a rule (Maikel, November 3, 2026): the em dash (U+2014) is never used in any text a
DKJ-Solutions app renders. It is rule 10 in the brand book's README and a bullet in the `dkj-brandbook`
skill, so a session reads it before any visual work.

**Score:** 2

#### What makes this deploy extra special

A page, report, dashboard or Artifact built in a DKJ-Solutions repo now writes a colon, a comma,
parentheses or a new sentence where it would have used an em dash.

**Score:** 2

#### Pull Request

the brand book bars the em dash

Plugins: dkj-policy, dkj-solutions

[PR #3767](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3767)

---

