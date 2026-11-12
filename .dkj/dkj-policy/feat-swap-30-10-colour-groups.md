## feat/swap-30-10-colour-groups

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

Dave, November 12, 2026: swap the 30 and the 10 of the 60-30-10 rule, so primary is the accent (10) and text the 30.
A visible result: parked for the owner's look, not merged.

### CREATE

- [x] README: the group table swapped, the reason written under it, the 30/10 references around it renamed.
- [x] specimens.html: the 30 card shows the text steps, the 10 card the primary group.
- [x] house-style.css: h2 to --fg-2, h3 to --fg-3, h1 stays --primary; the stale breadcrumb-bar-on-primary comments removed (the bar stands on --bg-1).

### TEST

- [x] Lint and test gates through open-pr.

### DEPLOY: feat/swap-30-10-colour-groups

The brand book's 60-30-10 groups are swapped: primary is the 10, the accent, and text is the 30. `h2` and `h3` move
from `--primary` to `--fg-2` and `--fg-3`; `h1`, links, the main button and the states keep the theme's colour.

**Score:** 2

#### What makes this deploy extra special

Every DKJ-Solutions app that takes this brand book sees its section headings turn from the theme colour to the text
colour, the moment it updates.

**Score:** 3

#### Pull Request

Brand book: primary becomes the 10, text the 30

