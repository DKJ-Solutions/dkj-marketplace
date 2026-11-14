## feat/figma-color-collections

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

The owner renamed the three colour collections in the brand book's Figma file from `House / ...` to
`Color Modus ...`: a collection name says what it holds, and `House` said only whose it was. The
`figma-tokens` sync finds its collections by name and creates any it does not find, so its names
follow the file, or the next sync would write three new `House / ...` collections beside the renamed
ones.

### CREATE

- [x] The Figma file: `House / Theme`, `House / Palette light` and `House / Palette dark` renamed to
  `Color Modus`, `Color Modus Light` and `Color Modus Dark` (ids unchanged, so every binding holds).
- [x] `figma-tokens-lib.ps1` names the three collections `Color Modus ...`, and its header comment with it.
- [x] The `figma-tokens` skill's collection table, and `figma-tokens.tests.ps1`'s asserts.

### TEST

- [x] `figma-tokens.tests.ps1`: 42 passed, 0 failed.

### DEPLOY: feat/figma-color-collections

The `figma-tokens` sync writes the brand book's colour tokens into the Figma collections
`Color Modus Light`, `Color Modus Dark` and `Color Modus`, the names the file now carries,
instead of `House / ...`. A collection name now says what it holds.

**Score:** 1

#### What makes this deploy extra special

N/A: the Figma file and the sync are this repo's own design tooling, and nothing a consumer takes
changes.

**Score:** N/A

#### Pull Request

Figma colour collections are named Color, not House

