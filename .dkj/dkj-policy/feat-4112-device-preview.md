## feat/4112-device-preview

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

#4112 (inbound from dkj-lifehub#715): a brand-book device preview, a phone frame with an A/B toggle, so a repo
presenting a mobile mockup stops writing its own phone. The issue asks for the content inside the screen to be
isolated from the house element rules; CSS cannot fence a subtree off from element selectors, so each version is an
`<iframe>`, a document of its own. The toggle is wired in `house-theme.js` (document-level, like the header's
dialogs), so a page needs no script of its own and the pattern stays stylesheet-only.

### CREATE

- [x] `house-product.css`: "Device preview" -- `.device-stage`, `.device`, `.device__screen` (390 wide, at most 844
  high and never taller than the window, its own scroll; full-bleed narrower than 30rem).
- [x] `house-theme.js`: a press on a `.device-stage .seg button[data-variant]` marks that button and shows the
  stage's parts of the same version, hiding the rest.
- [x] `patterns/device-preview.html` beside `product-page.html`, and a "Device preview" specimen under Navigation and
  shell.
- [x] Product README: the reserved names and a "Device preview" section.
- [x] `dev-pages.tests.ps1`: the frame, the full-bleed rule, the switch and the pattern.

### TEST

- [x] `dev-pages` suite alone: 787 passed, 0 failed.
- [x] By eye, headless Edge on a vendored copy: at 1280x900 the phone fits the window under the toggle and note; at a
  true 390 (inside a 390px iframe) the bezel goes and the screen meets the edges; the Variant state shows its note
  and frame; the mockup keeps the browser's own type, so no house rule reaches it. The specimen renders at
  `/plugins/dkj-policy/dkj-brandbook/nav` on the product server.
- [ ] The owner's look (a visible result).

### DEPLOY: feat/4112-device-preview

Inside this repo, the product layer gains a device-preview pattern and specimen, and `house-theme.js` switches its
versions.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product that shows a mobile mockup, an A/B variant or a design proposal takes the brand book's phone
frame (`.device-stage`, `.device`, `.device__screen`) instead of writing its own: an iframe per version keeps the
mockup's own look, and a `.seg` above it switches versions with no script of the page's own.

**Score:** 3

#### Pull Request

Brand book: a device preview with an A/B toggle

