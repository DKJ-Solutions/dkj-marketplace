## feat/4123-single-header-action

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

#4123: a page with exactly one action shows it directly in the header, not behind three dots and a sheet of one
item. The three dots and the sheet appear only from two actions up.

### CREATE

- [x] `product-pages-lib.ps1`: `Format-SiteHeaderHtml` draws a single action as `a.site-header__action`, an icon
      cell labelled with the action's name; its optional `Icon` is `download` (the default) or `print`
- [x] `house-product.css`: `.site-header__action` takes the More cell's place, size and states
- [x] The product README states the rule under "The sheet: actions"; the specimens show a one-action phone header

### TEST

- [x] `dev-pages.tests.ps1`: one action draws the icon cell and no sheet, `Icon = 'print'` picks the print glyph,
      and two actions still draw the More cell and the sheet (812 passed)
- [x] The new specimen card is served at `/plugins/dkj-policy/dkj-brandbook/nav`
- [~] The owner's look at the one-action header on the specimen page. Not done as a separate look: DaveKJohn
  approved the branch through issues-sweep-reviews on 2026-11-15 without one.

### DEPLOY: feat/4123-single-header-action

A product page with a single action, such as *Save as PDF*, now shows that action as its own icon in the site
header, instead of three dots that open a sheet holding one item. The three dots and the sheet appear only when a
page has two actions or more. An app drawing its header with `Format-SiteHeaderHtml` gets this with the update.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Product header: a page with one action shows it directly

