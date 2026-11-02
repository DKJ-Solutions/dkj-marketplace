## fix/3705-brandbook-console-text

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

Resolves #3705. The words the brand book's scripts print, and the comments around them, follow the
rename to dkj-brandbook. The file names stay `house-style` (the owner's choice), and so do the hub page
labels, which are #3704's.

### CREATE

- [x] `house-style-sessioncheck.ps1`, `check-house-style.ps1`, `house-style-rules.ps1`: console text and docstrings say "the brand book"
- [x] `check-colour-literals.mjs`, `check-css-vars.mjs`: the `[OK]` lines say "the brand book"
- [x] `reusable-house-style.yml` step name and `house-style-css.yml` comments; workflow `name:` keys left alone, so no check name changes
- [x] `check-house-style.tests.ps1`: the assert label follows

### TEST

- [x] the suites assert `holds at <tag>` and `nothing to check`, which both survive; the gate in ship-pr runs them

### DEPLOY: fix/3705-brandbook-console-text

The brand book's scripts now say "the brand book" where they printed "house style": the
`house-style-sessioncheck` line at session start, `check-house-style`'s `[OK]`/`[FAIL]` verdict and its
retired-token finding, and the two CSS gates' `[OK]` lines. The file names keep `house-style`, and no
workflow or check name changes. Resolves #3705.

**Score:** 1

#### What makes this deploy extra special

A DKJ-Solutions repo's session-start line now reads *"the brand book holds at vX.Y.Z"*, in the same word the
skill and the docs use since the rename.

**Score:** 2

#### Pull Request

Script and hook console text says 'the brand book', not 'house style'

