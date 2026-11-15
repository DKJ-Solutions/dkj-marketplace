## feat/card-grid-rows-on-phone

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

Causes 2 and 3 of the phone inventory #4113: lists drawn as large tiles inside a grey group surface, where the
mobile wireframes draw one card of compact rows, and a card inside a surface inside the page. Both come from the
groups (`.grid-2`, `.grid-3`, `.card-grid`), so the repair is one phone rule in the product layer rather than an
edit to every page.

### CREATE

- [x] `house-product.css`: below 48rem every group drops its surface and padding, a card in it stands as a plain
      card, and a group of `.card--link` tiles reads as one card of rows of about 52px with its `.grid__head` above
      as the heading; it outweighs a page's own grid layer (`.sp-grid`, `.dr-repos`). A wide screen is unchanged
- [x] The product README says it beside its "compact rows" rule

### TEST

- [x] `dev-pages.tests.ps1`: the phone rule's shape, tokens only but the hairline
- [x] `check-house-style`, `house-palette` green
- [x] Seen at 390px: `/consumers`, `/plugins/dkj-policy`, `/plugins/dkj-subagents/dkj-subagents-alpha`,
      `/consumers/dkj/dkj-lifehub`

### DEPLOY: feat/card-grid-rows-on-phone

On a phone a list of pages -- the consumer repos, the plugins, a team's specialists -- is one card of compact rows
with its heading above, instead of a stack of large tiles in a grey surface, as the mobile wireframes draw it. No
card sits inside a surface on a phone any more. A wide screen keeps its tiles.

**Score:** 3

#### What makes this deploy extra special

Every product built on the brand book gets this on a phone without a markup change: a group of card links becomes
one card of rows, and a group never wraps its cards in a second surface there.

**Score:** 3

#### Pull Request

On a phone a group of card links reads as one card of compact rows, after the mobile wireframes
