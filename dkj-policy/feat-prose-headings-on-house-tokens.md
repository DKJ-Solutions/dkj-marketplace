## feat/prose-headings-on-house-tokens

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

Maikel, November 2, 2026: `.prose` headings showed through `--prose-h1`..`--prose-h3`, which confused him -- he wants to see only his own tokens (`--text-h1`, `--text-h2`, ...). Stacked on `feat/lens-page-rendered-markdown` so both can be looked at together; that branch ships first.

### CREATE

- [x] `house-style.css`: `.prose h1/h2/h3` at `--text-h1/h2/h3`, `.prose--sm` sizes named directly, the three variables gone
- [x] `--prose-h1`..`--prose-h3` added to `Get-HouseStyleRetiredTokens`
- [x] README: a dated section on the change, beside the type-scale one

### TEST

- [x] `check-house-style.tests.ps1` 135/0, `house-palette.tests.ps1` 161/0, `dev-pages.tests.ps1` 560/0, `check-house-style.ps1` OK
- [~] The owner's look in the browser: a visible result to every DKJ-Solutions app, so the branch waits for it instead of merging

### DEPLOY: feat/prose-headings-on-house-tokens

`.prose` now sets each heading at the house token of its own level -- `h1` at `--text-h1`, `h2` at `--text-h2`,
`h3` at `--text-h3` -- instead of one step down through `--prose-h1`..`--prose-h3`, three variables that read as
tokens without being in the table. A prose `h2` is now 22px where it was 16px. The three are retired, so
`check-house-style` reports an app that still reads one; the README's "The prose headings of November 2, 2026"
says what to move to.

**Score:** 3

#### What makes this deploy extra special

An app that renders markdown in `.prose` shows its headings one size larger, the same sizes as headings
everywhere else in the brand book; an app that read `--prose-h*` in its own layer is told to move to `--text-*`.

**Score:** 3

#### Pull Request

Prose headings use the house text tokens directly

