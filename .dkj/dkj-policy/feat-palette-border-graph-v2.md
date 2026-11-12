## feat/palette-border-graph-v2

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

The second half of #4029, pushed after that PR had merged (Dave, November 12, 2026, approved both).

### CREATE

- [x] the control edge moved from `--primary-border` in the 30 to `--bg-5` in the 60: a control's edge is a line, and lines are paper; `bg-5` already bordered the Mode toggle and the theme cards. Sixteen tokens per theme; the builder recomputed all twelve
- [x] every `--primary*` and `--fg-*` token reads on `bg-1` at 4.5:1 or better: a contrast row per token in the model, the README and the skill; a token under the floor gets more contrast or moves to the paper as `--bg-*`. `--primary-raised` steps back from 15% where it fell under (teal, ochre, rust)
- [x] the Figma variables (dkj-brandbook file): `palette/bg-5` took the control edge's value in all twelve modes, the `primary-border` variables were removed (no node was bound to them), and `palette/primary-raised` synced for teal, ochre and rust

### TEST

- [x] `house-palette` suite: 199 passed; `check-house-style`: the brand book holds

### DEPLOY: feat/palette-border-graph-v2

The control edge introduced by #4029 is now `--bg-5`, a paper token, instead of `--primary-border`: a plain button,
a segmented control, the info button, the search and filter fields and the product's stepper and combo take
`--bg-5`, a grey of the theme's colour at 3:1 on the page and on a card. Every primary and text token now reads on
the page at 4.5:1 or better in every theme; the raised primary of teal, ochre and rust moved a little toward the
primary for it.

**Score:** 2

#### What makes this deploy extra special

The brand book now promises that every primary and text colour reads on the page, and says what happens to one that does not.

**Score:** 2

#### Pull Request

Palette: the control edge becomes bg-5, and every primary and text token reads on bg-1

