# Changelog

## [Unreleased]

**5 / 6 minor entries** <!-- pending-tally -->

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

