# Changelog

## [Unreleased]

**12 / 15 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3780-timing-store-orphan-adoption · 20261103-154822Z

Renaming a checkout's folder no longer empties its Stopwatch and Logbook
([#3780](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3780)). The store key stays the
path hash, so two unrelated repos with one folder name still never share a store (#3470), and the
first time a repo's hooks or hub run after the upgrade, `Import-HubTimingOrphanStore` adopts the
store its checkout left behind: a folder whose checkout is gone and that was this repo's, placed
beside the checkout by its own name or carrying this repo's origin. From it, only the runs that
started on a commit of this repo are taken, so a live clone, a fork or an unrelated repo never
crosses over. The run stores merge as a union on run id, the repo's own run winning, and the phase
caches and hide files the same way. Nothing is moved or deleted. The repo's folder is then marked
with its checkout and origin in a local `checkout.txt` (no sync reads it), so every later call is one
file test and the next rename finds it. The machine-wide stores of before #3470 are adopted on the
same commit test, which retires the hard-coded `dkj-claude-plugins` name the old move needed.

**Score:** 2

#### What makes this deploy extra special

A repo whose checkout folder was renamed gets its earlier Stopwatch cards and Logbook runs back on
its hub without anyone copying files by hand, and a shared Stopwatch stops publishing an empty store.

**Score:** 2

#### Pull Request

Stopwatch/Logbook: adopt a timing store orphaned by a checkout rename

Plugins: dkj-policy

[PR #3789](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3789)

---

### DEPLOY: docs/3777-card-shape-rule · 20261103-153718Z

The brand book README's "Page patterns" now opens with a table that says which shape a page's cards take for what the page holds: a flat list of pages is one `.grid-3` of card links with no head, a grouped list puts each group's `h2` inside its grid as the `.grid__head` with `h3` cards, a few subject cards each take an `h2`, a document of more than four sections becomes an overview with a page per section, and a group's empty state sits inside its own grid as a `.grid__full` card. The parts were each defined before, but not when to use which, and a consumer's pages were correct by every token check and wrong by eye in both directions. No check holds the table.

**Score:** 2

#### What makes this deploy extra special

A session building a page in any DKJ-Solutions repo has one rule to follow for card and heading structure, instead of the owner correcting each page by eye.

**Score:** 2

#### Pull Request

Brand book: a decision rule for when headings group cards

Plugins: dkj-policy

[PR #3788](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3788)

---

### DEPLOY: fix/3779-logbook-run-page-slug · 20261103-151817Z

A Logbook run page (`/logbook/<slug>`) no longer cuts and models every run in the store to find one
([#3779](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3779)). `Select-LogbookSlugRuns`
picks out the runs that can carry the slug: those that start in the slug's minute, which together
decide whether it carries an id suffix, and every sweep whose window holds that minute, because a
sweep's lap starts at a fold inside it. Only those reach `Get-LogbookRuns`, so the step log and the
`git log` are read only for that window, not from the oldest sweep in the store. The page reads the
same as before. On this machine, with 21 store runs, the whole-store cut took 470 ms.

**Score:** 2

#### What makes this deploy extra special

On a hub with a long Logbook, a run page opens without the delay that grew with every session.

**Score:** 2

#### Pull Request

A Logbook run page cuts only the runs that can carry its slug

Plugins: dkj-policy

[PR #3786](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3786)

---

### DEPLOY: feat/stopwatch-auto-release-run · 20261103-150649Z

Every release cut is now timed on the hub's `/stopwatch` page, whether or not the prompt started with `stopwatch:`. `cut-release.ps1` starts a `release cut` run as it begins, unless a run is already going (the owner's own `stopwatch:` run, or this cut's on a catch-up round), and the run ends on the cut's `release: vX.Y.Z release notes` commit as before. A cut refused after that start leaves its run going, and the next cut discards it once it is over 12 hours old. A missing Stopwatch lib or a store that does not read leaves the cut exactly as it was. Until now only one cut had ever been timed, so no two cuts could be compared.

**Score:** 3

#### What makes this deploy extra special

The owner of any repo running this workflow gets a timed `release cut` card on the Stopwatch for every cut from the next release on, without remembering to ask, so successive cuts can be compared.

**Score:** 2

#### Pull Request

A release cut is timed on the Stopwatch without a stopwatch: prompt

Plugins: dkj-policy

[PR #3785](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3785)

---

### DEPLOY: feat/3778-house-style-type-check · 20261103-145617Z

The brand book's gate, `check-house-style`, gains a fifth check, `type`: a rule in a repo's own layer reads a
font size only from the type scale ([#3778](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3778)).
A `font-size` whose value is anything but `var(--text-*)` or `inherit` and its kin, or a `font` shorthand
that types a size (`15px`, `0.88em`, `larger`, `clamp(...)`), is a finding. A custom property's own value
is not, so a domain step such as `--text-hero: 48px` stays a token of the repo's own. `font-weight` is not
read, pending [#3784](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3784).

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions repo running the house-style gate gets a new finding for every rule that types a font size,
and the reusable workflow tracks `main`, so it arrives at the merge rather than at the next release. The fix
is a `--text-*` step read with `var()`, a domain step of the repo's own, or an allowlist entry with its reason
for a false positive. Measured on November 3, 2026: 94 typed sizes in dkj-music-library, which already fails
the gate, so no green check turns red there.

**Score:** 3

#### Pull Request

check-house-style: a type rule, font-size only as a --text-* token

Plugins: dkj-solutions

[PR #3787](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3787)

---

### DEPLOY: feat/performance-sections · 20261103-144515Z

The hub's Performance page now reads as two sections instead of two cards: **Clock**, with the Stopwatch and
Logbook cards directly under it, and **Context**, with the SessionStart card. The Stopwatch and Logbook are
therefore one click closer, and their trail reads Tools > Claude > Performance. The old `/clock` address moves
to `/performance`.

The Logbook overview no longer gets slower with every session: it shows the newest 20 runs, and older ones
sit behind **Older runs** on `/logbook/page/2` and on. Only that page's runs are cut per sweep issue, read from
the transcripts and drawn, so a load costs one page whatever the store holds.

**Score:** 3

#### What makes this deploy extra special

Every repo's Toolbox shows the new Performance page, with Stopwatch and Logbook one click closer than they were,
and its Logbook stays fast however many sessions it has logged.

**Score:** 2

#### Pull Request

The Performance page groups its cards under Clock and Context

Plugins: dkj-policy

[PR #3783](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3783)

---

### DEPLOY: feat/plugin-page-contents · 20261103-133005Z

Each plugin's page in the Toolbox now shows what the plugin ships, under three headings: **Specialists**,
**Hooks** and **Skills**, a card per item. Each card opens a landing page of its own: a specialist's title,
description, model, tools and repo lens beside their manual in full; a hook's synopsis, the events that run
it and how it works; a skill's description, how it is invoked and its `SKILL.md`.

**Score:** 3

#### What makes this deploy extra special

Nothing beyond the page itself: it reaches only a reader who opens a plugin's page in the Toolbox, and
changes no workflow, gate or command.

**Score:** N/A

#### Pull Request

Plugin page: Specialists, Hooks and Skills sections

Plugins: dkj-policy

[PR #3776](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3776)

---

### DEPLOY: feat/hub-rules-page · 20261103-131931Z

The toolbox's Rules page (`/claude/rules`) is no longer empty. It holds cards read from the repo, under no
heading but the page's own: a card per `.claude/rules/*.md` and nothing else, described by the file's own `description:` frontmatter key (or
its title where it has none), and marked `(path-scoped)` where it loads only when Claude touches a matching
file. Each card opens on `/claude/rules/<name>` with the file rendered as a lens
page is.

**Score:** 2

#### What makes this deploy extra special

Every DKJ repo's toolbox now shows the rule files in its `.claude/rules` folder, readable in the browser.

**Score:** 3

#### Pull Request

The toolbox's Rules page lists the rules Claude works by

Plugins: dkj-policy

[PR #3775](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3775)

---

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

