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
`--muted-inverse` 2.14:1 to 2.32:1. Decision (Maikel): the rule covers the 30%, and `--muted-inverse` is
named as deliberately outside it.

### CREATE

- [x] The brand book README states that the 30% group reads on all four paper steps, and why `--muted-inverse` is not in it
- [x] The Color page (`/marketplace/dkj-policy/dkj-brandbook/tokens/color`): `--muted-inverse` leaves the 30 card for an Inverse card of its own under Theme (`specimens.html`, `dev-pages-lib.ps1`)

### TEST

- [x] The figures re-measured from the theme hex values in `house-style.css`
- [x] `dev-pages.tests.ps1` green (543), its Color-page order assert extended with Inverse
### DEPLOY: docs/brandbook-30-group-reads-on-paper

The brand book's 60-30-10 rule now says that everything in the 30% group (`--primary`, `--muted`) reads on
all four paper steps, with the measured floor on `paper-4`, and that `--muted-inverse` stays out of that
group because it reads only on an inverted surface (about 2.2:1 on `paper-4`). The brand book's Color page
follows: the 30 card shows `--primary` and `--muted` alone, and `--muted-inverse` has an Inverse card of its own
under Theme.

**Score:** 2

#### What makes this deploy extra special

A consuming repo's designer now knows not to put `--muted-inverse` on a paper surface; no token changes.

**Score:** 2

#### Pull Request

The brand book says the 30% group reads on all four paper steps

