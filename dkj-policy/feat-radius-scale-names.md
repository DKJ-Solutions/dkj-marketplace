## feat/radius-scale-names

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

The owner found the radius names random (`xs`, `sm`, `md`, `md-plus`, `lg`). Name them like the spacing
scale, which already has a predictable rule: `--radius-N` is N x 4px, a half step adds 2px. Values stay.

### CREATE

- [x] Rename the five size tokens in `house-style.css` and every use in it and in `specimens.html`
- [x] Specimen labels and the stylesheet comment state the rule
- [x] README: a Radius row in the token table, a rename table, the old "New tokens" line updated
- [x] Retire the five old names in `Get-HouseStyleRetiredTokens`, so the gate reports a use left behind

### TEST

- [x] `check-house-style.tests.ps1` green (121 passed), and `check-house-style.ps1` OK on this repo

### DEPLOY: feat/radius-scale-names

The brand book's corner-radius tokens are named like its spacing scale: `--radius-N` is N × 4px and a half
step adds 2px, so `--radius-xs`, `-sm`, `-md`, `-md-plus` and `-lg` are now `--radius-1`, `-1-5`, `-2`,
`-2-5` and `-3`; `--radius-pill` stays. Every value is unchanged. The old names are retired, so
`check-house-style` reports a use left behind, and the brand book's README carries the rename table.

**Score:** 3

#### What makes this deploy extra special

An app that takes the new stylesheet and uses a radius token in its own layer must rename it by the table in
the brand book's README; a use that slips past renders with square corners, and the house-style gate names it.

**Score:** 5

#### Pull Request

The radius tokens follow the spacing scale's names

