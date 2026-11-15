## feat/4128-phone-header-height

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

#4128: on a phone the site header took 68px and the bottom bar 73px, 141px of a 844px screen. Give the header its
own phone height, independent of the desktop line, and trim the bottom bar in the same move.

### CREATE

- [x] `house-product.css`: below 48rem and at the Phone width the header's `.container` is `--topbar-h` (56px) tall,
      and the back, actions (`__more`, `__action`) and menu-toggle cells are `--topbar-h` wide, so they stay square
- [x] The full-screen menu's head and its back cell follow the same `--topbar-h`
- [x] The bottom bar pads `--spacing-2` below its slots, or the safe area where there is one (was a 20px floor), and
      the body's bottom padding follows: 61px instead of 73px
- [x] The product README states the phone height under "On a phone: back and title"

#### Not in this branch

The `.site-header__action` selector names the one-action cell of `feat/4123-single-header-action` (#4123, parked for
the owner's look), so the two agree once both land; until then it matches nothing.

### TEST

- [x] `dev-pages.tests.ps1`: the phone height, the square cells, the menu head and the bottom bar's padding (811
      passed)
- [ ] The owner's look at a product page and the home page at the Phone width

### DEPLOY: feat/4128-phone-header-height

On a phone a product's site header is 56px tall instead of 68px, with its back, actions and menu cells still square,
and the full-screen menu's head matches it. The bottom bar is 61px instead of 73px on a phone without a home
indicator, and keeps the safe area on one that has it. Together they give about 24px of the screen back to the page.
A wide screen is unchanged.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

On a phone, the site header is 56px and the bottom bar 61px

