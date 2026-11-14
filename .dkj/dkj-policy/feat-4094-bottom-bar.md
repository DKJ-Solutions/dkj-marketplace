## feat/4094-bottom-bar

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

The scope on #4094 (its two comments), after the Figma `Product / Bottom bar` and `Product / Bottom bar item` (#4084, #4091): a phone-only bar of four or five slots, More last, and the header's toggle dropped where a bar is drawn. A visible result, so the branch parks for the owner's look.

### CREATE

- [x] `.bottom-bar` in `house-product.css`: fixed bottom below 48rem and at the Phone width, hairline on top, safe-area padding, equal slots (16px icon over a 12px label, 44px target), `aria-current` bold in `--fg-1`, the rest `--primary-muted`; the body padded by the bar's height.
- [x] `house-theme.js` opens the drawer from `.bottom-bar__more` as from the toggle, and shuts it when the bar goes.
- [x] `Format-BottomBarHtml` (3 or 4 sections, then More), `Format-SiteHeaderHtml -NoMenuToggle`, and `-BottomBar`/`-MoreLabel` on `Format-ProductPageHtml` and `Format-ProductHomeHeadHtml`, refused without `-Brand` and `-Menu`.
- [x] Product README: the reserved names and "The bottom bar, on a phone"; `patterns/product-bottom-bar.html`; a Bottom bar specimen (four and five slots) under Navigation.

### TEST

- [x] `dev-pages.tests.ps1`: the bar's markup, the five-slot bar, the 2/5-section refusals, `-NoMenuToggle`, the page and home wiring, the no-menu refusal, the CSS and the `house-theme.js` wiring -- 769 passed, 0 failed.
- [x] `check-house-style` OK, `check-plugin-integrity` 0 errors.

### DEPLOY: feat/4094-bottom-bar

Inside this repo, the product layer's renderer can draw a phone's bottom bar: `Format-ProductPageHtml -BottomBar` draws it and leaves the header's toggle out, and the brand-book specimens show it in four and five slots.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product can now put its sections in the thumb zone on a phone: `.bottom-bar` in `house-product.css` is a bar fixed to the bottom with four or five slots, the last always More, which opens the site menu, so the header drops its three-line toggle. It is gone on a wide window, where the menu sits in the header. dkj-lifehub's Agenda (Home, To-do, Tijdlijn, Agenda, Meer) is the first to use it.

**Score:** 3

#### Pull Request

house-product.css: a bottom bar for a phone, with More opening the site menu

