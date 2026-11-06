## fix/3849-product-patterns

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

Issue #3849, decided by the owner on November 5, 2026: recast both dkj-solutions pattern pages as a product
home pattern and repoint the README sentence to `patterns/admin-shell.html` as Admin's reference. The form
is read from what the product server draws today (`Format-ProductHomeHeadHtml`, `Format-SiteHeaderHtml`): the
site header with its menu and drawer and no settings button, the breadcrumb bar, a `.grid-3` of card links.

### CREATE

- [x] `repo-dashboard.html` -> `patterns/product-home.html`: a product's home, the site header with a menu
  (and its drawer), the one-crumb bar, one `.grid-3` of card links, no intro.
- [x] `repo-repository.html` -> `patterns/product-page.html`: a page one level down, its menu item current,
  Home > Projects, the h1, a facts row, tiles, the warning line and one grouped data card.
- [x] Every reference repointed: the core README's page-column paragraph (Admin -> `admin-shell.html`, a
  product -> the two new files), the product README's separator example, the `dkj-brandbook` skill's hub
  passage, and `admin-shell.html`'s header comment. The comment in `general-pages-lib.ps1` cites the old file
  at v0.3.0 and stays, being history.
- [x] Two inconsistencies met on the way filed rather than fixed here: #3851 (the README's settings button
  in the header against the renderer) and #3852 (the skill's breadcrumb-bar sentence against Admin's shell).

### TEST

- [x] Every class in the two pages is one the served product home or the product README already uses; the
  lint and house-style gates run in `ship-pr` once the owner has looked.

### DEPLOY: fix/3849-product-patterns

The brand book's two product pattern pages draw a product, not the hub as it was before #3830:
`patterns/product-home.html` and `patterns/product-page.html` in dkj-solutions (formerly `repo-dashboard.html`
and `repo-repository.html`) show the site header with its menu, the breadcrumb bar and the cards, and the
brand book names `patterns/admin-shell.html` as Admin's reference
([#3849](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3849)). A repo that copied the old files keeps
them; a product without a build starts from the new ones.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The brand book's product patterns draw a product home, not the pre-#3830 hub

