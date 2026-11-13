## feat/4048-mobile-back-header

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

Inbound #4048 from dkj-lifehub: the owner decided (November 13, 2026) that breadcrumbs are a desktop
aid. On a phone the product layer's breadcrumb bar under a site header gives way to a back cell and
the page's name in the header. A bar with no site header above it stays, since nothing else would
carry the way back. The fold point is the header's own 48rem, where the menu already folds; the bar's
hide reads the window and the Phone width, because a container query cannot reach a sibling.

The Figma frames (Product · mobile) are not edited on this branch: they follow once the owner has
judged the look here.

### CREATE

- [x] `house-product.css`: `.site-header__back` and `.site-header__title`, shown below 48rem; the bar under a header hidden there and at the Phone width
- [x] `product-pages-lib.ps1`: `Format-SiteHeaderHtml -Back -PageTitle`, `Get-SiteHeaderBack`, passed by `Format-ProductPageHtml`
- [x] `consumer-dashboard-lib.ps1`: the Consumers pages pass the same
- [x] Product-layer README: the bar rule scoped, and a new "On a phone: back and title" section
- [x] `patterns/product-page.html`: carries the back cell and the title

### TEST

- [x] `dev-pages.tests.ps1`: 758 asserts pass, five new ones on the back cell, the title, the one-level-up pick and the CSS hide
- [ ] The owner's look at a product page at phone width (Admin's Phone width or a narrow window)

### DEPLOY: feat/4048-mobile-back-header

The product layer of the brand book no longer shows the breadcrumb bar on a phone under a site
header. Below 48rem, the width the header menu folds at, the header shows a back cell
(`.site-header__back`, one level up) and the page's own name (`.site-header__title`) in place of the
brand, and the bar beneath it is hidden, also at the Phone width. A wide screen is unchanged, and a
bar with no site header above it stays at every width. `Format-SiteHeaderHtml` takes `-Back` and
`-PageTitle`, `Get-SiteHeaderBack` picks the parent page, and `Format-ProductPageHtml` passes both on
every page below home.

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions product that takes this release gets a phone layout with a back button and the page
title instead of a breadcrumb trail that does not fit. An app that draws its own site header must add
the back cell and title to every page below home in the same update, or its phone pages lose their
way up.

**Score:** 3

#### Pull Request

Brand book (product layer): no breadcrumb bar on mobile, back button and title instead
