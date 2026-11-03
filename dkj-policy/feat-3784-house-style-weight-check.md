## feat/3784-house-style-weight-check

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

Issue #3784, decided by the owner on November 3, 2026: option 1. The weight is in scope with no new step,
so check 5 (`type`) also reads `font-weight` and the weight inside a `font` shorthand.

### CREATE

- [x] `Find-HouseStyleTypeHit` reads `font-weight` (house weights only) and a shorthand's typed weight (`Kind = 'weights'`)
- [x] Its own finding text names the four house weights and the missing semibold
- [x] Allowlist: the consumer-dashboard suite's regex pattern that reads a weight out of a rendered page
- [x] Check 5's description updated in the lib, the gate, the session hook, the reusable workflow, the plugin README, the skill and the marketplace description

### TEST

- [x] `check-house-style.tests.ps1`: a typed 600, a keyword, a domain weight token, a shorthand weight with a stepped size, a shorthand typing both (reported once, by its size), the clean forms
- [x] The gate runs clean over this repo

### DEPLOY: feat/3784-house-style-weight-check

The brand book's `type` check now holds the font weight as well as the size
([#3784](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3784)). This was the owner's choice on
November 3, 2026: the weight is in scope, with no new step. A `font-weight` in a repo's own layer reads
one of the four house weights, `var(--font-weight-light|regular|bold|black)` (300/500/700/900), or a
CSS-wide keyword. A `font` shorthand that types a weight (`700`, `bold`) is a finding too. There is no
semibold step and no domain weight, so a typed `600` becomes the bold or the regular.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions repo running the house-style gate gets a new finding for every rule that types a weight,
and the reusable workflow tracks `main`, so it arrives at the merge. The fix is a house weight read with
`var()`, or an allowlist entry with its reason for a false positive. dkj-lifehub typed `font-weight: 600` in
8 places, as its reporter measured on November 3, 2026.

**Score:** 3

#### Pull Request

check-house-style holds font-weight to the four house weight tokens

