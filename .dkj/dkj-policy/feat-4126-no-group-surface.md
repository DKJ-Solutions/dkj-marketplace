## feat/4126-no-group-surface

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

Inbound #4126: a card group (`.grid-2`, `.grid-3`, `.card-grid`) drew a tray of its own (`--bg-2`, a radius,
`--spacing-5` of padding), and the cards in it took `--bg-3` with their lines moved to `--bg-4`. The owner reverses
the November 2, 2026 padding decision: the cards are the group, at every width. With the tray gone a card in a group
is the plain `.card` on `--bg-2` against the page, so the descendant fill rules and the #3697 button edge, which
existed only because of that remap, go with it, and the phone block (#4113) no longer has a surface to remove.

### CREATE

- [x] `house-style.css`: the group's padding, background and radius gone, with the `> .card` fill, line remap, hover and #3697 button-edge rules
- [x] `house-product.css`: the phone block keeps only its one column; the two READMEs say a group has no surface

### TEST

- [x] `dev-pages.tests.ps1`: the phone assert follows, and a new one holds every group rule free of padding, background, radius and a card fill (811 passed)
- [~] the owner looks at a page of card groups on a wide screen and on a phone. Not done as a separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-15 without one.

### DEPLOY: feat/4126-no-group-surface

A card group is no longer a surface of its own
([#4126](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4126)): `.grid-2`, `.grid-3` and `.card-grid`
lose the `--bg-2` tray, its radius and its padding at every width, so a card in a group is the same plain card it is
anywhere else, on `--bg-2` against the page. That reverses the padded tray of November 2, 2026, and takes with it
the darker card fill inside a group and the button edge #3697 gave it.

**Score:** 2

#### What makes this deploy extra special

Every DKJ-Solutions app that takes the update loses the frame around its card groups: the cards stand on the page
directly, one step lighter or darker than it, and on a phone they gain the width the padding took on both sides.
No markup changes; an app whose own layer leaned on the group's padding checks its spacing.

**Score:** 3

#### Pull Request

Brand book: a card group is no surface of its own
