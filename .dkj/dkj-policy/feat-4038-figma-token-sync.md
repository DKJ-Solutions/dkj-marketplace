## feat/4038-figma-token-sync

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

#### Decided on #4038 (the owner, November 13, 2026)

Colour tokens only; the target file is `w44J5aQPeST96RJ71vU3ev`; light and dark as separate collections.
Building it, a read of the file found that it already held exactly that layout (`House / Palette light`,
`House / Palette dark`, six modes each, and a semantic `House / Theme` aliasing them), so the sync keeps that
layout instead of adding a parallel one, and six modes per collection is measured on the owner's plan.

### CREATE

- [x] `figma-tokens-lib.ps1`: resolve every theme's colour tokens from `house-style.css` as the browser does, the model of the three collections, the drift comparison, and the read and sync Plugin API scripts
- [x] `figma-tokens.ps1`: `-Emit model|read-js|sync-js` and `-Compare <file>` (exit 1 on drift)
- [x] the `figma-tokens` skill page, a row in the extension README, and a pointer from the `dkj-brandbook` skill
- [x] the `figma-tokens` test suite

### TEST

- [x] `figma-tokens.tests.ps1`: 42 passed, 0 failed
- [x] the read script run through `use_figma` on the real file, and `-Compare` on its result: `[OK]`, 3 collections, 75 variables, in sync today
- [~] the sync script not run against the file: it writes, and #4038 says on request only; the file was already in sync, so it had nothing to write

### DEPLOY: feat/4038-figma-token-sync

A new `figma-tokens` skill keeps the brand book's colour variables in Figma in step with `house-style.css`,
in one direction ([#4038](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4038)). A read-only drift
check runs a script through the Figma MCP's `use_figma` on the brand book's Figma file and compares what it
returns with the stylesheet, per theme: missing, extra and differing collections, modes, values and aliases.
On request, a sync script writes the stylesheet's values into the file's existing layout (`House / Palette
light`, `House / Palette dark` and the aliasing `House / Theme`), creating and overwriting but never deleting.
Colour tokens only. The first check found the file in sync: 3 collections, 75 variables.

**Score:** 3

#### What makes this deploy extra special

N/A: the skill runs in this repo against the brand book's own Figma file, and nothing a consumer runs changes.

**Score:** N/A

#### Pull Request

Skill: check and sync brand book colour tokens to Figma variables

