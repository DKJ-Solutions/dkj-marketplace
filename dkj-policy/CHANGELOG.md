# Changelog

## [Unreleased]

**5 / 7 minor entries** <!-- pending-tally -->

### DEPLOY: docs/gwen-simple-all-the-way-down · 20261103-130201Z

Gwen's manual gains a hard rule, **Simple, all the way down**. Her bar is Linear's website or Apple Notes:
a simple purpose, architecture, design and implementation. She cuts taglines, helper text and secondary
labels, and fixes the layout when a screen seems to need them. Every decision has to improve the user,
developer and agent experience at once, without breaking anything.

**Score:** 2

#### What makes this deploy extra special

Pages and tools designed by Gwen in any consuming repo come out leaner: one purpose, no explanatory chrome.

**Score:** 3

#### Pull Request

Gwen's manual holds the simple-all-the-way-down bar

Plugins: dkj-subagents-alpha

[PR #3774](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3774)

---

### DEPLOY: feat/3772-no-artifacts · 20261103-122943Z

The workflow no longer uses claude.ai Artifacts or Claude Docs. The constitution says so always-on and overrides
the harness's own default to publish one: a result someone must judge becomes a Toolbox page, a document a file in
the repo. The Toolbox loses its Artifacts page and card (an old `/artifacts` link lands on the home page), the
`measure-session-start` skill keeps its history in its snapshot file instead of a published page, and the
specialists' and brand book's texts no longer point at Artifacts.

**Score:** 3

#### What makes this deploy extra special

Every session in every consumer stops publishing Artifacts after taking this version, including where the harness
would offer one unprompted.

**Score:** 3

#### Pull Request

Stop using claude.ai Artifacts and Claude Docs: a visible result becomes a Toolbox page

Plugins: bwj-development, dkj-policy, dkj-solutions, dkj-subagents-alpha

[PR #3773](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3773)

---

### DEPLOY: feat/toolbox-in-product-menu · 20261103-113704Z

The product's site header menu on every page now opens on **Toolbox**, then Consumers and Marketplace -- the same order as the cards on Home. It links `/hub`, which this server already answers with a 303 to the dkj-policy hub once that hub answers as this checkout's, so the menu never has to look the hub's port up while a page is drawn. The cards on the product's Home now behave as the toolbox home's do: they stand on the page in the hub's own `.ph-cards` (no framing surface, the toolbox's gap and hover) instead of a `.grid-3`.

**Score:** 2

#### What makes this deploy extra special

N/A: the product hub is this repo's own dev server; no consumer takes it.

**Score:** N/A

#### Pull Request

The Toolbox in the product's site header menu, beside Consumers and Marketplace

[PR #3771](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3771)

---

### DEPLOY: feat/remove-header-settings-button · 20261103-110636Z

The site header on the toolbox and product pages no longer carries the settings button (the gear with theme,
width and reset). The toolbox's theme is chosen on its `/settings` page; a page without a site header still
floats the button as before. The brand book's site-header menu now stands at the right instead of in the middle,
for every app that draws one, and the header has no padding of its own. Under a site header the breadcrumb trail is inset as far as the
name, so the two start on one line, and each step of the trail is a cell the full
height of its bar, as a menu link is in the header.

**Score:** 2

#### What makes this deploy extra special

A consumer running the toolbox sees a header without the gear and its menu at the right; the theme moves to the
Settings page.

**Score:** 2

#### Pull Request

Remove the settings button from the toolbox and product headers

Plugins: dkj-policy

[PR #3770](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3770)

---

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

