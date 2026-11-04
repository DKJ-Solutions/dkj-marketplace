# Changelog

## [Unreleased]

**9 / 12 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3809-template-settle-wait · 20261104-145309Z

The merge-on-green workflow that `adopt-ci-floor` places in a consumer now waits out the settle window
the way this repo's own runner has since #3807. It passes `pick-merge-on-green.ps1 -WaitForSettleSeconds 660`,
so the last armed pull request to go green is merged within about 11 minutes instead of waiting
for the 3-hourly schedule. The template comment and the run's cost summary name the price on a private
repo: at most about 11 billed minutes, and only on a sweep the settle window alone refused
([#3809](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3809)).

**Score:** 3

#### What makes this deploy extra special

A consumer's maintainer who places or re-places the CI floor with `adopt-ci-floor` gets a merge-on-green
runner that no longer leaves the last green pull request waiting for hours, at the price of up to about 11
billed Actions minutes on the sweeps where the settle window alone held it back.

**Score:** 3

#### Pull Request

merge-on-green consumer template waits out the settle window

Plugins: dkj-policy

[PR #3810](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3810)

---

### DEPLOY: fix/3807-settle-window-rewake · 20261104-141227Z

The merge-on-green sweep no longer leaves the last armed pull request to go green waiting for hours.
Its only wake was its own CI completion, which is exactly when the 10-minute settle window refuses it,
and the `*/30` schedule meant to catch it was delivered every 4 to 8 hours. With the new
`-WaitForSettleSeconds` cap, `pick-merge-on-green.ps1` waits out what is left of the window when that
is the only reason nothing was picked, then judges the tracker once more. This repo's runner passes 660
seconds; the default is 0, and the consumer template does not pass it, so nothing changes there
([#3807](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3807)).

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

merge-on-green: wait out the settle window instead of dropping the last PR's only wake

Plugins: dkj-policy

[PR #3808](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3808)

---

### DEPLOY: fix/3804-create-json-eof · 20261104-134340Z

open-pr no longer reports a created PR as a failed create when gh's follow-up update is cut off with
`unexpected end of JSON input` (#3804). It finds the PR through the existing recheck and sets the label,
assignee and milestone again, because the failed update was the call that sets them.

**Score:** 2

#### What makes this deploy extra special

Whoever ships with open-pr or ship-pr in a consumer no longer has a run stop with "nothing merged" over
a PR that was in fact created, and no longer gets that PR without its label. Small, and noticed only
when GitHub cuts a response short.

**Score:** 2

#### Pull Request

open-pr: a create that landed before gh's follow-up update failed is no longer reported as failed

Plugins: dkj-policy

[PR #3806](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3806)

---

### DEPLOY: fix/drop-product-width-bar · 20261104-123428Z

The width bar above the product's site header is gone again, with `DKJTheme.widthBar` and its
`.width-bar` classes in the brand book, both unreleased. The product's own pages now hold one width,
`full`, as the Toolbox does, and the product's Settings page offers only the theme. Another screen size
is judged in VS Code's Simple Browser's own device emulation instead of a toggle on the page.

**Score:** 2

#### What makes this deploy extra special

N/A: the width bar and the product's width choice never reached a release, so no user of a release loses anything.

**Score:** N/A

#### Pull Request

The width bar is gone; the product stays full, like the Toolbox

Plugins: dkj-policy

[PR #3801](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3801)

---

### DEPLOY: feat/3797-page-name-two-words · 20261104-121848Z

The brand book now holds a page's name, its `h1` and the breadcrumb crumb that reads the same, to two words at most (rule 8 and the breadcrumb bar's labels; #3797). The five-word cap stays for `h2` and `h3`. The hub's fit alarm checks it on sight and warns when the live page's `h1` or its current crumb runs longer. A hyphenated word counts as one.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that takes this brand book now has a two-word page name to follow, so a page title such as "Subject - a subtitle" moves its subtitle into the page. Every hub page warns about a name that does not.

**Score:** 2

#### Pull Request

Brand book: a page name is at most two words, checked by the page shell

Plugins: dkj-policy

[PR #3800](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3800)

---

### DEPLOY: fix/3798-watcher-claude-holds-session · 20261104-104856Z

The dev-preview watcher no longer stops a server while Claude Code still runs in the logon session that
started it ([#3798](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3798)). Switched away from with
fast user switching, a session reads disconnected while Claude Code keeps working in it, and its hub was
stopped one grace later; the product it started after the switch survived, so the outcome depended only on
when each server started. The watcher now reads its own session's process table at a disconnect, and a
`claude.exe` (or `@anthropic-ai/claude-code` under node) there resets the clock as an uncertain read does.
Once none is left, the session counts as abandoned, as #3569 meant.
**Score:** 3

#### What makes this deploy extra special

A Toolbox hub that went dark mid-session, on a machine with two accounts, now stays up for as long as the
Claude Code that started it is running.
**Score:** 2

#### Pull Request

dev-preview watcher: a running Claude Code holds a disconnected session

Plugins: dkj-policy

[PR #3805](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3805)

---

### DEPLOY: fix/3802-merge-in-progress · 20261104-103914Z

ship-pr no longer reports GitHub's `Merge already in progress` as a failed merge (#3802). After a 5xx
or that answer, it polls the PR for about a minute and folds once it reads MERGED. If it does not, it
says the merge is held by GitHub and leaves the PR armed for the merge-on-green sweep. The refusal for
an unmerged PR no longer names a merge queue when the trunk's rules were read and carry none.

**Score:** 2

#### What makes this deploy extra special

Whoever runs ship-pr in a consumer and hits a GitHub server error on the merge now gets a run that
waits the lock out or hands it back with the right advice, instead of a hard failure followed by a
misleading hint about a merge queue. Small, and noticed only when GitHub has a bad minute.

**Score:** 2

#### Pull Request

ship-pr: 'Merge already in progress' is a merge still landing, not a failed merge

Plugins: dkj-policy

[PR #3803](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3803)

---

### DEPLOY: feat/toolbox-only-banner · 20261104-100346Z

The airsquats banner is the Toolbox's alone: a page built as a product's (`-BrandTag 'product'`) no longer
carries it, and this repo's product pages (home, settings, Consumers, marketplace) open on the site header.

**Score:** 1

#### What makes this deploy extra special

A repo whose own product pages are built with the plugin's page builder loses the banner there; it stays
on every Toolbox page.

**Score:** 1

#### Pull Request

The airsquats banner on the Toolbox only, not on the product pages

Plugins: dkj-policy

[PR #3799](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3799)

---

### DEPLOY: feat/product-width-bar · 20261104-092205Z

The brand book gains a width bar, `DKJTheme.widthBar(el)`: a thin strip above the site header holding
full, fluid and phone as three small icon buttons. This repo's product pages (the home and the
consumer pages) open with it, so the page width is one click away again; the Toolbox stays on full.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that takes the next brand book copy can offer its users the width as a one-click
bar instead of a setting inside the gear panel.

**Score:** 2

#### Pull Request

Product pages: a thin width bar above the site header

Plugins: dkj-policy

[PR #3796](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3796)

---

### DEPLOY: fix/3792-eol-only-claude-change · 20261104-084522Z

`update-plugins -AllCheckouts` no longer asks you to review and commit a `.claude/settings.json` that
`claude plugin install/update` merely rewrote with different line endings (#3792). When every change the
run left under `.claude/` is line endings only, the sweep restores the committed bytes and says so; a real
change is still named in the summary as before.

**Score:** 2

#### What makes this deploy extra special

Nothing beyond the summary line it corrects: a sweep that already worked now stops asking for a commit
that does not exist, and changes nothing for a checkout whose `.claude/` really changed.

**Score:** N/A

#### Pull Request

update-plugins -AllCheckouts restores an EOL-only .claude/ rewrite instead of asking for a commit

Plugins: dkj-policy

[PR #3795](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3795)

---

### DEPLOY: fix/toolbox-fixed-width · 20261104-083416Z

The Toolbox has one page width again, the full one, because it is read in VS Code's Simple Browser at
about 16:9 and never on a phone. Its Settings page no longer offers Fluid, Phone or Full, and a width
stored while it did is overwritten. A repo's product port keeps the choice: that is where an app is built
for the Simple Browser and a phone alike. This repo's own product gets a Settings page for it, theme and
width, linked from its home page and its menu. It had none since the header's settings button went. The
rule is in the hub's README.

**Score:** 2

#### What makes this deploy extra special

Whoever uses the Toolbox gets one fixed full-width page, with no width setting that does nothing useful
on the screen it is read on.

**Score:** 2

#### Pull Request

The Toolbox keeps one width, so its Settings page no longer offers one

Plugins: dkj-policy

[PR #3794](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3794)

---

### DEPLOY: fix/settings-page-width · 20261103-214954Z

The toolbox's Settings page offers the page width again -- Fluid, Phone or Full -- under the theme. It
lived in the header's settings button, and when that button went the width choice went with it, so
the page could no longer be widened or narrowed from anywhere.

The house style also gains a fifth paper token, `--bg-5`: one step past `--bg-4`, a little lighter on a dark
theme and a little darker on a light one, computed for all twelve themes. No existing colour moved.

**Score:** 3

#### What makes this deploy extra special

Whoever uses the toolbox can switch its page width again, which they lost when the header's settings
button was removed. An app on the house style can now use a fifth paper step, `--bg-5`.

**Score:** 3

#### Pull Request

Settings page gets the page-width choice back, and the house style a --bg-5

Plugins: dkj-policy, dkj-solutions

[PR #3793](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3793)

---

