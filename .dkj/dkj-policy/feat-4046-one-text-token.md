## feat/4046-one-text-token

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

The Figma wireframes map all text to one token (#4040), and `--fg-2` … `--fg-4` sit so close to `--fg-1`
(OKLCH L 0.12 / 0.16 / 0.20 / 0.24 on light) that they cannot be told apart; `fg-4` had no role at all. The owner
agreed to collapse them into `--fg-1` (November 13, 2026). Absorbs #4046: README line 711 still said `h2`/`h3`
are `--primary`, which Dave's November 12 change (`ccced7007`) had already reversed. Visible result: parked for
the owner's look before the merge.

### CREATE

- [x] `house-palette-lib.ps1`: one text step instead of four; the contrast rows follow; thirteen tokens per theme
- [x] `build-house-palette.ps1 -Apply`: the twelve theme lines and three default blocks rewritten; every other value unchanged
- [x] `house-style.css`: `h2`, `h3` and `.meta` move to `--fg-1`; the comments follow
- [x] `house-product.css`, `general-pages-lib.ps1`, `dev-pages-lib.ps1`, both `specimens.html`: the remaining uses move to `--fg-1`
- [x] `Get-HouseStyleRetiredTokens`: `--fg-2`, `--fg-3`, `--fg-4` retired, so a consumer's leftover use is reported
- [x] Brand book README, product README, `dkj-brandbook` and `figma-tokens` skills: current-state text follows; the migration history is kept
- [ ] Figma: remove `palette/fg-2..4` and `color/fg-2..4` from the three `House` collections, after the owner's look

### TEST

- [x] `house-palette` (219), `check-house-style` (169) and `figma-tokens` (42) suites green; the house-style lint green
- [ ] Owner looks at the result in Admin before the merge

### DEPLOY: feat/4046-one-text-token

The brand book has one text colour: `--fg-1`. `--fg-2`, `--fg-3` and `--fg-4` were steps so close to it that
they could not be told apart, and the Figma wireframes already map all text to one token. `h2`, `h3` and
`.meta` move to `--fg-1`; a quieter text stays `--primary-muted`. The three old names are retired tokens, so
the house-style gate reports a use left behind. The README's stale line that `h2` and `h3` are `--primary` is
corrected ([#4046](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4046)).

**Score:** 3

#### What makes this deploy extra special

An app that takes this brand book renames each use of `--fg-2`, `--fg-3` or `--fg-4` in its own layer to
`--fg-1` (or `--primary-muted` for a quiet text); its `h2`, `h3` and `.meta` become a shade stronger.

**Score:** 3

#### Pull Request

Brand book: one text colour, fg-2..4 retired

