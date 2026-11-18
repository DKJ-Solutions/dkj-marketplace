## feat/4290-measure-buybox-in-shopify

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

Step 3 of 3 of [#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290). The owner's
decision splits `measure-buybox` in two:
- **Moves to the plugin:** the measuring mechanism, the node harness with its viewport emulation.
- **Stays in the store:** the theme's selectors and the expectation, read through one new seam,
  `Get-ShopifyBuyBox`.

This closes #4290. A gap in the native-capture audit's scope, found here, is filed as #4307.

### CREATE

- [x] `scripts/task/measure-buybox.ps1`, `scripts/task/measure-buybox.harness.js` and
  `scripts/lib/measure-buybox-rules.ps1` in the shopify plugin, in English. The harness hard-codes no
  theme selector.
- [x] The `Get-ShopifyBuyBox` seam: `BoxSelector` and `AtcSelector` are required. `BlockSelectors`,
  `StickySelector`, `MobileMaxWidth` and the `AtcMaxTop`/`AtWidth` expectation are optional. A verdict is
  given only when the measured width equals `AtWidth`.
- [x] The `node` call is bounded, and a missing `node` is a refusal. It is audited by hand in
  `native-capture.tests.ps1`, because the counter does not see plugin-only scripts (#4307).
- [x] `skills/measure-buybox/SKILL.md`, the README row and seam table, and `scripts/tests/shopify-measure-buybox.tests.ps1` in `suite-groups.json`

### TEST

- [x] `shopify-measure-buybox` 91/0, including an end-to-end run with a stand-in `node` and `node --check` on the harness
- [x] `native-capture` 355/0, `exception-message-guard` 18/0, and the other shopify suites green
- [x] `check-plugin-integrity.ps1` 0 errors
- [x] The full gate runs in `ship-pr`

### DEPLOY: feat/4290-measure-buybox-in-shopify

Ships the `measure-buybox` skill in `dkj-subagents-shopify`. It measures where the add-to-cart button
sits in a product page's buy box on a really emulated viewport. Resizing a window or framing the page
silently measures the wrong width, so it uses headless Chrome with DevTools device emulation instead. It
always prints the width it actually measured at. The theme's selectors and the store's expectation come
from the new `Get-ShopifyBuyBox` seam. With an expectation it prints PASS or FAIL; without one it only
measures. It needs node 22.7 or newer. Closes
[#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290).

**Score:** 2

#### What makes this deploy extra special

A store can track a buy-box layout requirement, such as "the add-to-cart button within N px at 390 px
wide", as a measured number instead of a judgement by eye. To do that, it answers `Get-ShopifyBuyBox` in
`scripts/repo-config.ps1`.

**Score:** 2

#### Pull Request

Move measure-buybox's mechanism into dkj-subagents-shopify
