## docs/4256-revendor-with-the-pin

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

Inbound #4256: moving `house-style.yml` to `@v7.0.0`, as the 7.0.0 note says, turns the brand-book gate
red in a repo that vendors the brand book. The gate holds those copies to v7.0.0's checksums, and they
differ from 6.x only in two comment lines of the rename.

### CREATE

- [x] The 7.0.0 note's runner step: re-vendor `house-style.css` and `house-product.css` from the same tag,
  in the same change.
- [x] The `dkj-brandbook` skill's CI-gate paragraph says the caller and the copies move together, and why.

### TEST

- [x] Read back: both pages name the same two files and the same tag, and the skill's existing
  "moves its caller when it takes a new copy" now states the converse as well.

### DEPLOY: docs/4256-revendor-with-the-pin

The 7.0.0 note and the brand-book skill now say that a repo vendoring the brand book re-vendors
`house-style.css` and `house-product.css` from the same tag it pins the gate to, in the same change
(#4256). Moving the pin alone turns the gate red, even where the copies differ only in a comment.

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions repo with a vendored brand book takes the 7.0.0 pin in one green change, instead of
finding the second half on a red check.

**Score:** 3

#### Pull Request

Moving the house-style gate's pin re-vendors the brand book at the same tag

