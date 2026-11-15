## feat/4124-icon-grammar

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

Inbound #4124: one meaning per icon across DKJ products on a phone (three lines = more pages, three dots = page
actions, gear = settings), and settings as a single gear row inside More. The header already followed the grammar;
what was left was writing it down and turning the menu's Display section into a Settings row with the gear. The
Figma half (aligning `Product / Menu`, #4085) is not in this branch: it goes on the issue for the owner's look.
The More-as-a-page half is #4125.

### CREATE

- [x] `Format-SiteHeaderHtml` draws a Settings section whose row carries the house gear (`product-pages-lib.ps1`)
- [x] the icon grammar and the Settings row in the product README; the product-page pattern and the specimens follow

### TEST

- [x] asserts in `dev-pages.tests.ps1`: the Settings section, its gear before the label, no Display section left (810 passed)
- [~] the owner looks at the full-screen menu on a phone width: the Settings section and its gear. Not done as a separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-15 without one.

### DEPLOY: feat/4124-icon-grammar

Every DKJ product now reads three icons one way on a phone: **three lines** for more pages, **three dots** for the
page's own actions, and the **gear** for settings
([#4124](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4124)). The product README writes that grammar
down, and the full-screen menu's **Display** section becomes **Settings**, its one row carrying the house gear, so
on a phone settings sit inside the menu rather than as an icon in the header.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product that draws its header with `Format-SiteHeaderHtml` and passes `-SettingsHref` shows a
**Settings** section with a gear in its phone menu where it showed **Display**, with no change of its own. One that
draws the menu by hand renames the section and adds the gear, as the README says.

**Score:** 3

#### Pull Request

Product on a phone: one icon grammar, and settings as a row in More
