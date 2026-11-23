## fix/4388-theme-limit-seam

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

Inbound #4388: `Get-ThemeSlotVerdict` and `Get-ThemeSweepOrder` default `-Limit 20` and no caller
passes one, so a Shopify Plus store at 43 themes is called full and its live backup is refused.
Verified on pickup: every caller relies on that default. Shopify's help center gives 20 themes for
Basic/Grow/Advanced and 100 for Plus. Whether development themes count toward the library limit is
not settled by any source found, so role counting is left as it is (counting all roles errs strict).

### CREATE

- [x] Optional seam `Get-ShopifyThemeLimit` (default 20), read through one helper
  `Resolve-ShopifyThemeLimit` in `live-push-rules.ps1`; passed by `backup-live-theme`,
  `live-preflight` and `prepare-release`.
- [x] A count above the limit proves the limit wrong: `LimitExceeded`, not `Full`, no refusal and no
  sweep order, a message naming the seam. `Count -eq Limit` stays Full.
- [x] Mirrors kept byte-identical (`Get-SharedScriptPairs`), seam rows in the Shopify README and the
  `live-preflight` skill.

### TEST

- [x] `theme-lifecycle-rules`: 218 pass; `live-push-rules`: 227 pass; `dkj-repo-workflow-bwj`: 1088
  asserts pass; `check-plugin-integrity` and `check-script-contract`: 0 errors. The full gate runs in
  `ship-pr`.

### DEPLOY: fix/4388-theme-limit-seam

The theme slot checks read the store's theme limit from a new optional seam, `Get-ShopifyThemeLimit`
in `scripts/repo-config.ps1` (20 unless answered; 100 on Shopify Plus), and a store already holding
more themes than the limit is reported as a wrong limit instead of refused as full (#4388).

**Score:** 3

#### What makes this deploy extra special

A Shopify Plus store with more than 20 themes no longer has its live backup refused, and is no longer
told to delete themes before a push. Answer `Get-ShopifyThemeLimit` with 100 in such a store to get
the right free-slot count back.

**Score:** 4

#### Pull Request

Theme slot checks read the store's theme limit from a consumer seam instead of hardcoding 20

