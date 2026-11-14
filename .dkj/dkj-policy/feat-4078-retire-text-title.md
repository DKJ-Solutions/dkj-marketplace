## feat/4078-retire-text-title

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

The Figma brand book dropped its `text/title` step: the site header has its own element pair there, and every
element has its own text style. `--text-title` never left the `h2` size (20px desktop, 18px under the 760px query,
both declared beside `--text-h2`), so every use moves to `--text-h2` with no change on screen, and the name joins
the retired tokens ([#4078](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4078)). The issue listed five
places; the tree had more (two Admin page libs, a second `house-product.css` rule, two README passages), and all
move. Not a visible result: the computed size is identical in both modes, so it ships.

### CREATE

- [x] `house-style.css`: the declaration and its mobile override removed, `.empty-state > h2` on `--text-h2`
- [x] `house-product.css` (`.site-header__name`, `.site-header__title`), `goals-lib.ps1`, `today-page-lib.ps1`: on `--text-h2`
- [x] `specimens.html`: the `--text-title` specimen removed; the stale `--text-h2 (22px)` label corrected to 20px
- [x] `Get-HouseStyleRetiredTokens`: `--text-title` retired, so a consumer's leftover use is reported
- [x] Brand book README: the token row, the phone sizes and the `Element` collection follow; a dated section with the rename table. Product README follows

### TEST

- [~] No pre-run: `ship-pr` runs the gate and the suites before the push (issues-sweep step 4)

### DEPLOY: feat/4078-retire-text-title

`--text-title` is retired: the site header's name, the empty state's title and the two Admin titles that used it
take `--text-h2`, the size it always had (20px, 18px on a phone), so nothing changes on screen. The Figma brand
book had already dropped the step. The name joins the retired tokens, so the house-style gate reports a use left
behind ([#4078](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4078)).

**Score:** 2

#### What makes this deploy extra special

An app that takes this brand book renames each use of `--text-title` in its own layer to `--text-h2`; the gate
names any it missed, and the size is the same.

**Score:** 2

#### Pull Request

Brand book: retire --text-title

