## feat/3815-toolbox-to-admin

> **How this file is read.** A step is `- [ ]` until it is resolved -- `- [x]` done, or
> `- [~]` dropped with the reason, which exists so nobody ticks a box for work they did not do.
> open-pr and ship-pr both refuse while one is still open, and there is no `-Force`.
>
> **FOUR `###` HEADINGS, AND NEVER A FIFTH** -- PLAN, CREATE, TEST, DEPLOY are the whole top
> level. A section needing its own heading goes in as a `####` UNDER whichever of the four owns
> it. No gate in YOUR repo reads a heading, so this half is on you -- only the repo that authors
> this workflow refuses a fifth (Dave, August 26, 2026).
>
> **AND NOTHING BRANCH-SPECIFIC ABOVE THE FIRST OF THOSE FOUR HEADINGS** -- everything between the
> title and it is this guidance, which is identical in every branch document. A status line, a note about
> THIS branch or an instruction to a session belongs under one of the four, normally as a `####`
> in PLAN. THIS half open-pr refuses, in every repo, before the push -- it reads the shape, so a
> guidance block in your own language passes and your own paragraph here does not (Dave,
> August 26, 2026; refused since #1650).
>
> **DEPLOY takes no steps of its own, and it is WRITTEN LAST** -- it is what the branch DID, once
> TEST says so. Written while steps above it are still open it states an INTENTION, and no gate
> holds it against what landed: the step gate splits this file at that heading and counts only
> above it. The PR title is the one exception -- new-branch -Title writes it at creation, because
> open-pr composes the PR title from it. It is the one part of this file that travels verbatim
> into `CHANGELOG.md` at the merge. In each tier, write the reason
> ABOVE the Score line -- anything below it is discarded.
>
> Relative links in that text resolve FROM THIS DIRECTORY -- `CHANGELOG.md` sits here too, so
> write each path exactly as it reads in this file.
>
> For tier 2 audiences: the user who relies on what this repo ships, and decides whether to take the next version -- a subscriber of a service, or the user of a tool, its own maintainer included. That reader and nobody else -- what matters only
> inside this repo belongs under the first `**Score:**`. If the change reaches that reader
> not at all, N/A is a complete answer and the common one. **One hop and no further:** where that
> reader is itself a business, ITS own customers sit one hop past this repo and are never the reader
> here -- they take nothing this repo ships. Name the party that runs the upgrade, and score
> against them.
>
> The phase arc, the marks and the whole form: `DEVELOPMENT-portable.md`, which ships
> with this workflow.

### PLAN

Rename the Toolbox port to Admin, modelled on the Shopify Admin: flat navigation with section headings, the existing pages under Development at /dev with redirects from the old paths.

#### Decisions taken on the way

- **Every general page but Home and Settings moves under `/dev`**, the matchers and the links the hub
  generates together, so the two cannot disagree; one 301 (`Resolve-AdminLegacyPath`) carries every old
  address there with its path and query.
- **The release-notes template keeps linking `/release-notes`**, because the Worker shares it; the dev
  server rewrites those links to `/dev/release-notes` on the way out (`Format-ReleaseNotesDevPage`).
- **`-BrandTag 'toolbox'` stays accepted as `admin` for this release** (`ConvertTo-AdminBrandTag`); the
  release notes name the alias's end.
- **The `.tree*` classes are replaced, not kept beside**: `.nav-list`, `.nav-item` (with `__label`,
  `__count`) and `.shell__nav-foot`, with the existing `.pane-head` as the section heading. They shipped in
  v6.7.0 the same day, so no consumer is known to use them.
- **Search (Ctrl K) and a seam for a repo's domain objects are not built here**: the issue's scope list
  names neither, and each is a feature of its own: [#3817](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3817)
  and [#3818](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3818).

### CREATE

- [x] `/dev` prefix on every hub route and every link the hub generates; the old paths redirect (301).
- [x] Toolbox shell functions renamed to Admin (`Get-AdminNav`, `Format-AdminShellOpen`, ...); the side tree becomes a flat navigation: Home, Product (the storefront, where one is stated), Development, Settings in the foot.
- [x] `-BrandTag 'admin'`, with `'toolbox'` read as `admin`; the first crumb reads Home; the SessionStart line opens with `Admin:`; the product's card reads Admin.
- [x] Brand book: `house-style.css` "Desktop shell: Admin's layer" with the flat navigation classes, `patterns/admin-shell.html` (renamed from `toolbox-shell.html`), the specimens, and the README's "Two layers".
- [x] Docs: the hub README, the brand book README and skill, the constitution's and the skills' "Admin page" wording. Historical release documents are not rewritten.

### TEST

- [x] Tests under `scripts/tests` updated for the paths, the navigation, the label and the alias, with new asserts for the Product section, the foot, the legacy redirect (as a pure function and as a routed 301) and the alias.
- [x] `check-plugin-integrity.ps1`: 0 errors.
- [x] The full suite gate: all 171 suites passed (276 s, 25 lanes); `check-plugin-integrity.ps1` 0 errors after the last wording pass.

### DEPLOY: feat/3815-toolbox-to-admin

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
