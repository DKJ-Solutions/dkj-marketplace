## feat/4096-progress-status-error-states

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

The scope on #4096 (its sweep comment), after the Figma `Product / Status card` (297:1444) and `Product / Error state` (297:1462) approved under #4087: a status card, the progress bar question, an error state beside `.empty-state`, then README, specimen and tests. A visible result, so the branch parks for the owner's look.

#### Two calls made here, for the owner's look

- **The progress bar gets no class.** A native `<progress>` with `accent-color` fills in `--primary` and keeps the browser's track, while the Figma bar fills in `fill-accent` (`--primary-muted`), which is exactly the core `.meter.meter--info`. So the card uses that, with its track on `--bg-4` inside the card's `--bg-3`.
- **The facts are `.facts--row`, as the issue asks**, where the Figma stacks them as stat rows: one row is the density rule, and `.facts` dividers would vanish on `--bg-3`.

### CREATE

- [x] `.status-card` (with `__kicker`) in `house-product.css`: `--bg-3`, `--radius-2`, padding `--spacing-4`, gap `--spacing-2`; the kicker in the pane-head type; `.status-card .meter` on `--bg-4`.
- [x] `.error-state` on an `.empty-state`: the mark in `--negative-1` with a `!` in `--negative-5`, a retry `.btn`.
- [x] Product README: the reserved names and "Status card and error state"; both specimens under "Status and charts".

### TEST

- [x] `dev-pages.tests.ps1`: the card's surface and meter, the kicker type, the error mark, the specimens -- 773 passed, 0 failed.
- [x] `check-house-style` OK.

### DEPLOY: feat/4096-progress-status-error-states

Inside this repo, the product layer's specimens show a status card and an error state, and its README documents both.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product can now show where something stands and say that something failed in the house look: `.status-card` is a block with a kicker, a heading, the core meter as its progress bar and the facts in one row, and `.error-state` turns the empty state into a failure with a red mark and a retry button.

**Score:** 3

#### Pull Request

house-product.css: a status card and an error state

