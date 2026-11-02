# Changelog

## [Unreleased]

**10 / 16 minor entries** <!-- pending-tally -->

### DEPLOY: feat/site-header-name-token · 20261102-131936Z

The site header loses its mark and its name grows. The name -- the repo name and `toolbox` on every hub
page -- has a type token of its own, `--text-title`, at 20px, just under `h2`, where it was `--text-h3`
(16px), so the header can be tuned without moving every `h2`. The organisation's initials in front of it,
`.site-header__mark`, are retired: the header carries the name alone (Dave, November 2, 2026).

**Score:** 2

#### What makes this deploy extra special

Every hub page shows a header with the name alone, larger. An app with its own site header that takes the
new stylesheet drops the `.site-header__mark` span, which no longer has a rule, and can size its own header
name with `--text-title`.

**Score:** 3

#### Pull Request

The site header without its mark, and a --text-title token for its name

Plugins: dkj-policy

[PR #3746](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3746)

---

### DEPLOY: feat/hub-cards-ungrouped · 20261102-122251Z

The hub's home page no longer wraps its card links in a framed `.grid-3` with no heading above it. The cards
stand three to a row straight on the page, in a `.ph-cards` of the page's own layer that takes `.grid-3`'s
columns and step-downs without its background and padding: a framed group with no heading groups nothing.

**Score:** 2

#### What makes this deploy extra special

Every repo's toolbox home page looks different the moment it is opened: the cards stand on the page instead of
inside a grey panel.

**Score:** 2

#### Pull Request

Hub home page: the cards three to a row without a grid surface

Plugins: dkj-policy

[PR #3744](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3744)

---

### DEPLOY: fix/3739-cut-moves-live-marker · 20261102-120246Z

In a repo with a live stage, `cut-release.ps1` now moves a `**LIVE**` marker in the release history onto the row it writes, into the same cell and with its arrow, because the cut runs after the push and the new version is the live one. Until now the marker stayed on the previous row, so the release-notes page labelled the replaced version live after every promote-then-cut. `-NoLivePushRecord` leaves the marker where it is, a repo without a live stage is not touched, and a table marking more than one row gets a warning instead of a guess ([#3739](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3739)).

**Score:** 3

#### What makes this deploy extra special

A consumer store that promotes to live and then cuts no longer has to move the `**LIVE**` marker by hand after every release: its release-notes page names the version that is actually live from the moment the cut lands.

**Score:** 3

#### Pull Request

cut-release moves the LIVE marker to the new row after a push-then-cut

Plugins: dkj-policy

[PR #3743](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3743)

---

### DEPLOY: fix/3716-release-notes-ink-faint · 20261102-112904Z

The hub's release-notes page shows its faint text (dates, sub lines) in the quiet house grey again. Since the colour rename of November 1, 2026 it had pointed at `--muted`, a token the house stylesheet no longer declares, so that text fell back to the ordinary text colour. A test now holds every token that page's colour rewrite uses to the ones the stylesheet declares, so a future rename cannot leave the page behind ([#3716](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3716)).

**Score:** 2

#### What makes this deploy extra special

N/A -- the release-notes page is the hub's, a dev-side page; a consumer of the plugins sees it only on their own hub.

**Score:** N/A

#### Pull Request

Release-notes page maps ink-faint to the retired --muted token

Plugins: dkj-policy

[PR #3737](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3737)

---

### DEPLOY: feat/hub-performance-under-ai · 20261102-111836Z

The hub's Performance card moved into the AI page's Claude section, beside Rules, Skills and Specialists, and the
Test gate moved from the Clock to the GitHub page, beside Issues and Actions. The hub home carries the AI card in
Performance's old place. Every route is unchanged; only the cards and the breadcrumb trails moved
(Tools > AI > Performance > Clock, Tools > GitHub > Test gate).

**Score:** 2

#### What makes this deploy extra special

Every repo's toolbox reads differently: Performance is under AI and the Test gate under GitHub. No link breaks,
because no route changed.

**Score:** 2

#### Pull Request

Move Performance under AI > Claude and the Test gate under GitHub

Plugins: dkj-policy

[PR #3742](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3742)

---

### DEPLOY: feat/3704-hub-brandbook-route · 20261102-110036Z

The hub's brand book page is named `dkj-brandbook` in the toolbox too, as it already was on the product: its card,
title and breadcrumb, and its address, `/plugins/dkj-policy/dkj-brandbook`
([#3704](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3704)). Both older addresses,
`/plugins/dkj-policy/house-style` and `/plugins/dkj-solutions/house-style`, redirect there, a section to the same
section.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The hub's brand book page is named and routed as dkj-brandbook

Plugins: dkj-policy, dkj-solutions

[PR #3741](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3741)

---

### DEPLOY: fix/3725-specimen-sample-text · 20261102-102200Z

The House style page's Graphs and Status samples show their token name under the swatch instead of inside it,
so four of them no longer type `color: #000` for text on a light fill
([#3725](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3725)). The page now passes the brand book's
colour check without an allowlist entry.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The House style page's light specimen samples read a token for their text

Plugins: dkj-policy

[PR #3738](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3738)

---

### DEPLOY: feat/3691-remove-check-connectors-forwarder · 20261102-100241Z

The `scripts/sync/check-connectors.ps1` forwarder is gone, now that every machine runs v6.1.0 or later and its hook calls `check-consumers.ps1` directly ([#3691](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3691)).

**Score:** 1

#### What makes this deploy extra special

N/A -- a source-repo-only script; no plugin user runs it.

**Score:** N/A

#### Pull Request

Remove the check-connectors.ps1 forwarder

[PR #3731](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3731)

---

### DEPLOY: feat/3733-backup-verify-existing · 20261102-095115Z

`backup-live-theme` takes `-VerifyExisting <id>`, and `live-preflight` passes it through as
`-BackupVerifyExisting <id>`. After a backup that timed out, the retry verifies and rotates the copy that
run left standing instead of duplicating live again. It refuses an id that is live, missing from the
theme list, or outside this repo's backup namespace
([#3733](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3733)).

**Score:** 2

#### What makes this deploy extra special

A Shopify store whose live theme copies slowly no longer spends an extra theme slot on every retry of
the backup: measured in a consumer, one release day cost two extra slots on an 80-theme estate while the
first copy was still filling. Pass the id the timed-out run printed: `live-preflight -BackupVerifyExisting <id>`.

**Score:** 3

#### Pull Request

backup-live-theme verifies an existing copy with -VerifyExisting instead of duplicating live again

Plugins: dkj-subagents-shopify

[PR #3736](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3736)

---

### DEPLOY: fix/3732-fill-wait-stall · 20261102-093728Z

The theme fill wait in `backup-live-theme` and `push-preview` no longer gives up at a fixed clock while
the copy is still growing. Past `-TimeoutMinutes` it waits on as long as the file count keeps rising, and
stops on a stall or at three times the wait
([#3732](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3732)).

**Score:** 3

#### What makes this deploy extra special

A Shopify store with a large live theme gets a verified backup on release day without knowing its copy
speed in advance, and without a retry that duplicates live a second time. Measured on a 909-file theme:
661 files at the old 20-minute limit, still filling.

**Score:** 3

#### Pull Request

Theme fill wait runs on while the copy is still growing, up to a hard cap

Plugins: dkj-subagents-shopify

[PR #3735](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3735)

---

### DEPLOY: docs/3722-settings-toggle-readme · 20261102-092752Z

The brand book README describes the settings toggle as `house-style.css` draws it: the icon alone, in
`--fg-1`, with no fill, edge or shadow, and no colour change under the pointer or while open. Until now
it still described the `--primary` edge the toggle lost on November 1, 2026
([#3722](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3722)).

**Score:** 1

#### What makes this deploy extra special

A doc sentence that disagreed with what renders; nothing an app does changes.

**Score:** N/A

#### Pull Request

Brand book README describes the icon-only settings toggle

Plugins: dkj-policy

[PR #3726](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3726)

---

### DEPLOY: fix/3729-preflight-backup-timeout · 20261102-091721Z

`live-preflight` takes a `-BackupTimeoutMinutes` and passes it to `backup-live-theme` as its
`-TimeoutMinutes`, so a store whose live theme takes longer than 20 minutes to copy no longer has to run
the backup by hand and then the preflight with `-SkipBackup`
([#3729](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3729)).

**Score:** 3

#### What makes this deploy extra special

A Shopify store with a large live theme can now finish a release-day preflight in one run:
`live-preflight -BackupTimeoutMinutes 45`. Measured on a 909-file theme, the copy was still filling at the
20-minute default.

**Score:** 3

#### Pull Request

live-preflight passes a longer backup timeout through to backup-live-theme

Plugins: dkj-subagents-shopify

[PR #3734](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3734)

---

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

