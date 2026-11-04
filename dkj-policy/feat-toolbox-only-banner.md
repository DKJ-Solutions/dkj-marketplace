## feat/toolbox-only-banner

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

The airsquats banner shows on the Toolbox port only, never on the product port (Dave, November 4, 2026).
Both shared builders (`Format-GeneralPageHtml`, `Format-RepoHomeHeadHtml`) leave it out under
`-BrandTag 'product'`, and the Consumers page stops drawing it. Visible result: stops for the owner's look
before the PR.

### CREATE

- [x] `general-pages-lib.ps1`: the banner only where `-BrandTag` is not `product`, docstring updated
- [x] `consumer-dashboard-lib.ps1`: the Consumers pages draw no banner

### TEST

- [x] `dev-pages`, `consumer-dashboard`, `dev-preview-sessionstart`, `stopwatch` suites green, the product asserts now expecting no banner and the Toolbox home still opening on it
- [x] Owner's look at the product (http://localhost:4870/) and the Toolbox (http://localhost:4890/) (Dave: "gezien en akkoord")

### DEPLOY: feat/toolbox-only-banner

The airsquats banner is the Toolbox's alone: a page built as a product's (`-BrandTag 'product'`) no longer
carries it, and this repo's product pages (home, settings, Consumers, marketplace) open on the site header.

**Score:** 1

#### What makes this deploy extra special

A repo whose own product pages are built with the plugin's page builder loses the banner there; it stays
on every Toolbox page.

**Score:** 1

#### Pull Request

The airsquats banner on the Toolbox only, not on the product pages
