## feat/4289-which-theme-in-shopify

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

First step of [#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289) (owner decision
2026-11-18: all three scripts move to `dkj-subagents-shopify`, each its own build). This branch moves
`which-theme` and the `fetch-failure` helper it needs; `sync-summary` and `live-direct-writes` follow
on their own branches, so it ships with `-NoResolves`. `fetch-failure` lands in the plugin lib so the
#4290 checks reuse it. Markets come from the store's own `Get-StorefrontMarkets` seam, read directly,
so the shopify plugin takes no dependency on the BWJ extension.

### CREATE

- [x] `scripts/lib/fetch-failure.ps1` in the shopify plugin, translated to English, behaviour unchanged
- [x] `scripts/lib/which-theme-rules.ps1` with the pure, testable logic (URL building, served-theme
  extraction, bot-protection detection, fingerprints, market rows)
- [x] `scripts/task/which-theme.ps1` and `skills/which-theme/SKILL.md`
- [x] README: the skill row and the `Get-StorefrontMarkets` seam
- [x] `scripts/tests/shopify-which-theme.tests.ps1`, registered in `suite-groups.json`

### TEST

- [x] The new suite: 58 passed, 0 failed, no network
- [x] `check-plugin-integrity.ps1`: 0 errors
- [x] The full gate runs in `ship-pr`

### DEPLOY: feat/4289-which-theme-in-shopify

Ships the `which-theme` skill in `dkj-subagents-shopify` and puts `fetch-failure` in its script lib. The
skill reports which theme id and name a storefront URL actually serves. You can add `-MustContain` or
`-MustNotContain` fingerprints to tell a cached copy from a fresh one. When a fetch fails, it prints
the status, `x-request-id`, UTC time and URL. Before this, only one store repo had the script. First
step of [#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289).

**Score:** 2

#### What makes this deploy extra special

A Shopify store on the plugin can now check which theme a page really serves without keeping its own
copy of the script. `-Url` works straight away. `-Path` needs the store to answer
`Get-StorefrontMarkets` in `scripts/repo-config.ps1`, the seam the BWJ extension already reads, so a
store that has answered it once is covered for both.

**Score:** 2

#### Pull Request

Move which-theme and fetch-failure into dkj-subagents-shopify
