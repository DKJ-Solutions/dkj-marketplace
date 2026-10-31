## docs/brandbook-30-group-reads-on-paper

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

Maikel asked to add a readability rule to the 30% group and doubted `--muted-inverse` on `paper-4`.
Measured (WCAG, all twelve themes): `--primary` 4.56:1+ and `--muted` 5.30:1+ on `paper-4`;
`--muted-inverse` 2.14:1 to 2.32:1. A first pass gave `--muted-inverse` an Inverse card of its own on the
Color page; Maikel refused it (a theme has three groups, 60-30-10, and no invented fourth) and it was
reverted. Of his three routes, two were measured impossible: as paper it reads 2.1:1 to 4.0:1 on
`--primary` (floor 4.55), and no colour reaches 4.5:1 on both `paper-4` and `--fg-1` (best 3.9:1 to
4.05:1). Decision (Maikel): retire it, and the quieter line on `.fill-inverse` takes `--paper-4`.

### CREATE

- [x] The brand book README states that the 30% group reads on all four paper steps, and that a theme has the three groups and no fourth
- [x] The palette model (`house-palette-lib.ps1`) no longer computes `--muted-inverse`, and promises `paper-4 on fg-1` at 7:1 instead; `house-style.css` rebuilt with `build-house-palette.ps1 -Apply` (only that token left the theme lines)
- [x] `.fill-inverse`'s quieter lines take `--paper-4`; the stylesheet comments, README, the `dkj-brandbook` skill page and `specimens.html` (the 30 card and the twelve theme dot rows) follow
- [x] `--muted-inverse` joins `Get-HouseStyleRetiredTokens`, so a consumer still using it is told

### TEST

- [x] The figures re-measured from the theme hex values in `house-style.css`
- [x] `house-palette` (140), `check-house-style` (121) and `dev-pages` (543) suites green; `check-house-style.ps1` on this repo OK
- [x] The Color page re-read on the restarted dev server: Theme holds 60, 30 and 10 and nothing else

### DEPLOY: docs/brandbook-30-group-reads-on-paper

The brand book's 60-30-10 rule now says that everything in the 30% group (`--primary`, `--muted`) reads on
all four paper steps, and that a theme has these three groups and no fourth. That retired `--muted-inverse`:
it fitted no group and no value could make it fit. Each theme now has ten colours instead of eleven, the
quieter line on `.fill-inverse` takes `--paper-4`, and the brand book's Color page and theme swatches show
the three groups alone.

**Score:** 3

#### What makes this deploy extra special

`--muted-inverse` no longer exists. A DKJ-Solutions repo whose own domain layer uses it must switch to
`--paper-4` on an inverted surface; the house-style check now reports every use as a retired token.

**Score:** 5

#### Pull Request

The brand book retires --muted-inverse: a theme has the 60-30-10 groups and no fourth
