## feat/radius-three-steps

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

Six radius steps had three within 4px of each other; the owner chose one step per role (Dave, November 13,
2026): small element 4px, control 8px, container 12px, plus the pill. Visible result: parked for the owner's
look before the merge.

### CREATE

- [x] `house-style.css`: drop `--radius-1-5`, `--radius-2-5`, `--radius-4`; every use moves to `--radius-2` / `--radius-3`
- [x] `house-product.css`, `goals-lib.ps1`, `specimens.html`, `dev-pages-lib.ps1`: the same moves
- [x] `Get-HouseStyleRetiredTokens`: the three names retired, so a consumer's leftover use is reported
- [x] Brand book README: the token row and a migration section with the table
- [x] Figma `Scale`: the three variables rebound to `radius/2` / `radius/3` on every page and removed

### TEST

- [x] `dev-pages` (753) and `check-house-style` (169) suites green; the house-style lint green
- [x] Owner looks at the result in Admin before the merge (Dave: "merge", November 13, 2026)

### DEPLOY: feat/radius-three-steps

The brand book's radius scale is cut from six steps to three plus the pill, one per role: `--radius-1` (4px)
for a small element, `--radius-2` (8px) for a control, `--radius-3` (12px) for a container. `--radius-1-5`
folds into `--radius-2`, and `--radius-2-5` and `--radius-4` into `--radius-3`; the three old names are
retired tokens, so the house-style gate reports a use left behind. The migration table is in the brand book
README, and the Figma library's `Scale` collection carries the same four steps.

**Score:** 3

#### What makes this deploy extra special

An app that takes this brand book renames each use of the three retired radius tokens in its own layer, and
its controls, small cards and dialogs change their corners (6 to 8px, 10 to 12px, 16 to 12px).

**Score:** 4

#### Pull Request

Brand book radius scale cut to three steps plus pill

