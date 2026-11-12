## feat/graph-apca-floor

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

The owner's rule (November 12, 2026): a graph token must ALWAYS read well on `bg-1`. Measured first: every theme
already passed the 3:1 ratio (lowest 4.42 in the dark themes, 4.60 in the light ones), but APCA put the dark themes'
`--graph-1` and `--graph-3` at Lc ~30 against Lc ~71 in the light ones. The owner chose Lc 45 as the floor.

### CREATE

- [x] `Get-ApcaContrast` (SAPC 0.0.98G) in `house-palette-lib.ps1`, and `OnPaperLc = 45` in `Get-HouseGraphRules`
- [x] `Get-HouseGraphLifted`: a candidate below Lc 45 on `bg-1` or `bg-3` moves away from the paper, hue and chroma held, by the least that reaches it
- [x] `Get-HouseGraphSlots` takes the first trio in pool order that stands apart, instead of a first-come walk that cannot go back
- [x] the dark pool searched again for Lc 45; the light pool and every light theme are unchanged
- [x] the contrast table carries the Lc rows, the build script prints them in Lc, and `house-style.css` is rebuilt with `-Apply`
- [x] the brand book README and the stylesheet's header state the rule

### TEST

- [x] `house-palette.tests.ps1`: APCA on known values, the lift (reaches the floor, by no more, hue held, no-op where it already reads), and every slot at Lc 45 on `bg-1` and `bg-3` in all twelve themes -- 219 passed
- [~] the owner looks at the dark themes' charts in Admin's brand book -- not a pre-PR step: the PR waits for that look before it merges (visible result)

### DEPLOY: feat/graph-apca-floor

Every graph token now reads at APCA Lc 45 or more on `bg-1` and `bg-3` in every theme, on top of WCAG's 3:1.
The ratio could not hold the owner's rule in a dark theme. It scores a mid tone on a near-black page too kindly, so
the dark blue and violet series passed at 4.4:1 while reading only Lc 30. `build-house-palette.ps1` now lifts each
candidate to that floor and picks the first trio in pool order that still stands apart. The dark pool is new. Pink,
lilac, sky and orange get a blue, a teal and an aqua, because their pastel primary rules out the magenta and the
violet. The light themes are unchanged.

**Score:** 3

#### What makes this deploy extra special

Every DKJ-Solutions app that takes this brand book draws its charts in dark mode with new, lighter series colours
that read clearly on the page.

**Score:** 3

#### Pull Request

Graph series read at APCA Lc 45 on bg-1 and bg-3 in every theme

