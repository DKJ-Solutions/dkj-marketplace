## feat/4125-more-page

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

- [x] Make the bottom bar's More a page with its own URL (#4125), rendered from the same menu sections as the
  full-screen dialog, and keep the dialog for products without a bottom bar.

### CREATE

- [x] `product-pages-lib.ps1`: the menu's sections and row lifted into `Format-SiteMenuSectionsHtml` and
  `Format-MenuItemHtml`, shared by the dialog and the new `Format-ProductMoreBodyHtml`; `-MoreHref` on
  `Format-BottomBarHtml`, `Format-ProductPageHtml` and `Format-ProductHomeHeadHtml`; `-NoMenuDialog` on the header.
- [x] `house-product.css`: the dialog's row rules also read `.menu-page`; the bottom bar's comment names the link form.
- [x] This repo's product: `/more` (`Format-ProductMoreHtml`), linked from the bar on every product page.
- [x] `patterns/product-more.html` added, `product-bottom-bar.html` links it; the product README's bottom bar section.
- [x] `dev-pages` and `consumer-dashboard` suites: the link form, the current marking, the shared renderer.

### TEST

- [x] `dev-pages` 825 passed, `consumer-dashboard` 260 passed, run directly while building.
- [~] The owner's look: approved by Dave on November 16, 2026, after looking at the More page
  (http://localhost:4870/more) on feat/4125-more-page.

### DEPLOY: feat/4125-more-page

Inside this repo, the product layer's renderer lifts the site menu's sections into one function,
`Format-SiteMenuSectionsHtml`, which both the full-screen dialog and a new More page body
(`Format-ProductMoreBodyHtml`) render, and this repo's product serves `/more` with the bottom bar's More linking it.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product's bottom bar can now make More a page like its other slots: pass `-MoreHref` and More becomes
a link to that page, with a URL that can be refreshed, linked and returned to. The phone's back gesture leaves it as
it leaves any page, and the bar marks More as where you are. The page holds the same sections as the menu, and the
full-screen dialog stays for products without a bottom bar.

**Score:** 3

#### Pull Request

Bottom bar: More opens a page with its own URL

