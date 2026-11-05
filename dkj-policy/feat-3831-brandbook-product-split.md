## feat/3831-brandbook-product-split

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

#### The decision this builds

Maikel, November 5, 2026, on #3831: Admin's remaining product-layer classes move into the core, and the product
renderer moves to dkj-solutions with the product CSS, so dkj-policy keeps only Admin.

#### What is a visible result here

Every Admin page and every product page renders from a different stylesheet set than before. No gate can prove
that it looks the same, so this branch parks for the owner's eye (no pull request).

### CREATE

- [x] Split `house-style.css`: the core and the desktop shell stay, plus a "Shared components" block at the end
  with what Admin's own pages draw (page width, icon button, the base breadcrumb trail, menu list and card link,
  sr-only, the additions to core classes, alert/banner/panel, chip/tag). Everything else is
  `dkj-solutions/assets/dkj-brandbook-product/house-product.css`, loaded after the core and never alone. The moved
  blocks keep their relative order, so the cascade between them is unchanged.
- [x] Pin the product layer: a third, optional row in the skill's checksum table, a third `Checksums` entry for the
  cut (`scripts/repo-config.ps1` and the blueprint), and `house-style-rules.ps1` treats `house-product.css` as a
  copy held to the pin with its classes counted as house classes. A page at a tag before the split is still a
  complete pin.
- [x] The CSS lint gate (`house-path.mjs`, `house-style-css.yml`) reads the product folder too.
- [x] The renderer: `Format-GeneralPageHeadHtml`, `Get-PageInfoGlyph` and `Get-LongPageWarningHtml` are shared
  in dkj-policy. `Format-GeneralPageHtml` and `Format-RepoHomeHeadHtml` draw Admin only and refuse
  `-BrandTag 'product'`. The product layout (`Format-ProductPageHtml`, `Format-ProductHomeHeadHtml`,
  `Format-SiteHeaderHtml`, `Format-ProductBreadcrumbBarHtml`) is dkj-solutions' `scripts/lib/product-pages-lib.ps1`.
  The release notes stand in the shell even unnamed.
- [x] This repo's product pages (Consumers, the home page, every `Format-DevPageHtml` page) link and serve
  `/house-product.css`.
- [x] Specimens: the 26 product cards move to dkj-solutions' own `specimens.html`, with the two live dialogs.
  Admin shows the core's 33. The product joins both (`Join-HouseStyleSpecimens`) and shows all 59. The
  specimens' tail now starts at a column-0 `<script>` too, so the theme picker still draws on a section's page.
- [x] The two product reference pages (`patterns/repo-dashboard.html`, `repo-repository.html`) move beside the
  product layer and link all three files.
- [x] Docs (Tessa): the README is split into the core and dkj-solutions' `assets/dkj-brandbook-product/README.md`,
  and the skill page, the dkj-solutions README and extension `CLAUDE.md`, the hub README and the designer's lens
  are updated. Filed #3843 for the hub's home form, which the docs still describe as it was before #3830.

### TEST

- [x] Suites run on the branch: dev-pages (628), consumer-dashboard (245), check-house-style (167, with new
  cases for the product row, the canonical product path, a pinned and an edited vendored copy, and a product
  class restyled), cut-release-drive (132, the fixture now pins three files), dev-preview-sessionstart (377),
  house-palette, config-blueprint, script-contract, logbook, stopwatch, stopwatch-sync: all green. The CSS lint
  gate passes on both sheets. `ship-pr` runs the full gate once the owner has looked.

### DEPLOY: feat/3831-brandbook-product-split

The DKJ-Solutions brand book is now two files. `dkj-policy` ships the core and Admin's desktop shell
(`house-style.css`, `house-theme.js`). The mobile-first product layer is `house-product.css`, shipped by the
`dkj-solutions` plugin alone, with its own README, specimens and reference pages. A product page links it after
the core, and Admin never loads it. The page builders follow the same line. dkj-policy draws Admin pages only.
The product's site header, breadcrumb bar and page column are dkj-solutions' `product-pages-lib.ps1`. The
dkj-brandbook skill pins all three files, and the gate holds a vendored `house-product.css` to that pin and
counts its classes as house classes. An Admin-only repo, such as every BWJ-Development repo, vendors and loads
the core alone.

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions product repo that vendors the brand book must add `house-product.css` beside its copy of
`house-style.css` and link it after the core. Without it, the product's site header, breadcrumb bar, forms and
dialogs lose their styling once that repo takes the new core. A repo that renders only Admin needs nothing.

**Score:** 4

#### Pull Request

Brand book: core + Admin in dkj-policy, product layer only in dkj-solutions

