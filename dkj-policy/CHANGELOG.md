# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

### DEPLOY: docs/3819-visible-park-url · 20261105-101546Z

When a branch stops for the owner's look, its report now names the exact URL that shows the result, a Toolbox page or a preview, on a line of its own and one per changed page. The rule sits in the constitution's visible-result bullet, and the sweep skill carries it into its review-label comment and its close-out. Until now the report could say "the branch waits for your look" without saying where, and the owner had to find the page themselves.

**Score:** 2

#### What makes this deploy extra special

A session that parks a visible result in any repo running `dkj-policy` hands the owner the address to open, instead of a sentence they have to turn into one.

**Score:** 2

#### Pull Request

A visible result parked for the owner's look names the URL to open

Plugins: dkj-policy

[PR #3822](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3822)

---

### DEPLOY: feat/3815-toolbox-to-admin · 20261105-100350Z

The Toolbox is now **Admin**, modelled on the Shopify Admin: Admin is for managing, the product for using
([#3815](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3815)). Its side navigation is flat,
under section headings, instead of a tree: **Home** on top, a **Product** section linking the storefront
the session started, a **Development** section holding GitHub, Release notes, Claude and Installed
plugins, and **Settings** pinned to the foot. Every development page moved under `/dev/...`
(`/dev/test-gate`, `/dev/claude/rules`, `/dev/plugins/...`), and every old address answers a 301 to the
same page there, its query kept, so links and bookmarks keep working. The session-start line opens with
`Admin:`, the first crumb reads **Home**, and the brand book's desktop shell takes `.nav-list`,
`.nav-item` and `.shell__nav-foot` under a `.pane-head` heading in place of the `.tree*` classes
(`patterns/admin-shell.html`, formerly `toolbox-shell.html`). A caller passing `-BrandTag 'toolbox'` is
still served the desktop shell in this release; pass `'admin'`.

**Score:** 4

#### What makes this deploy extra special

Everyone who opens their repo's Admin notices it at once: a new name on the session-start line, a flat
navigation in place of the tree, and every development page at a new address, with the old ones still
landing. A consumer whose own code passes `-BrandTag 'toolbox'` or uses the `.tree*` classes has to move
to `admin` and the `.nav-*` classes; the alias keeps the first working for this release.

**Score:** 4

#### Pull Request

Rename the Toolbox port to Admin, with a Development section at /dev

Plugins: dkj-policy, dkj-solutions, dkj-subagents-alpha

[PR #3821](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3821)

---

