## feat/black-weight-to-bold

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

Maikel asked to move every element set at `--font-weight-black` to `--font-weight-bold`. The token
itself stays defined, and the specimen still shows it.

### CREATE

- [x] `house-style.css`: every `font-weight: var(--font-weight-black)` becomes `--font-weight-bold` (26 rules)
- [x] The hub's own page CSS: the masthead `h1` (`general-pages-lib.ps1`) and the Stopwatch start line (`stopwatch-lib.ps1`)
- [x] The brand book README: the `h1` weight and the token row say so
- [x] `stopwatch.tests.ps1` pins the new weight
- [x] The plain `h3` goes from light to bold (Maikel, asked after looking)
- [x] Under a site header, the breadcrumb links take `--primary-muted` (was `--fg-3`); the current page keeps `--primary`
- [x] The settings toggle is the icon alone in `--fg-1`: no fill, edge, shadow or hover colour
- [x] Inside a site header the toggle takes the header's own colour (`--bg-1`), as the name does
- [x] The gear is the filled Bootstrap Icons `gear-fill` (MIT) rather than the outlined one, after Maikel's reference picture
- [x] In a site header the toggle is a square cell the bar's full height at its right edge, a shade lighter than the header

### TEST

- [x] `stopwatch` and `house-palette` suites green
- [ ] The owner has looked at the result (a visible change)

### DEPLOY: feat/black-weight-to-bold

Every rule in the house stylesheet that was set at the black weight (900) is now set at bold (700): the
`h1`, the primary button, the top bar and site header names, panel labels, totals, the answer and
step-head values, the comparison table's head and foot, and the rest. The hub's masthead and the
Stopwatch start line follow. The plain `h3` turns from light (300) to bold (700), so a card's `h3` is
bold as well. Under a site header, the breadcrumb links are `--primary-muted` instead of `--fg-3`, and the
current page at the right end stays `--primary`; the bar standing on `--primary` is unchanged. The settings toggle
is just its icon in the text colour (`--fg-1`): no round card, `--primary` edge or shadow behind it, and no
colour change under the pointer or while it is open. Inside a site header it takes the header's own
colour (`--bg-1`), as the app's name does. The gear is the filled Bootstrap Icons `gear-fill` instead of an
outline, and in a site header the button is a square cell the full height of the bar at its right edge, a
shade lighter than the header (a little lighter again under the pointer and while open). `--font-weight-black` stays defined for an app that wants it, but no house
rule uses it any more.

**Score:** 3

#### What makes this deploy extra special

Every DKJ-Solutions app that takes the next brand book copy renders its headings, primary buttons and
emphasised values a step lighter.

**Score:** 3

#### Pull Request

Everything set at the black weight is set at bold

