## feat/4290-check-sitemap-in-shopify

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

Step 2 of 3 of [#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290): `check-sitemap` moves
into `dkj-subagents-shopify` on the pattern of #4305. It shares that step's market reader, comma splitting
and fetch-failure evidence. `measure-buybox` follows, so this branch ships with `-NoResolves`.

### CREATE

- [x] `scripts/task/check-sitemap.ps1` and `scripts/lib/check-sitemap-rules.ps1` in the shopify plugin, in English.
  The fetch is `Invoke-WebRequest` on one shared session and keeps the 429 backoff.
- [x] `Select-MarketRows` moves to `storefront-markets-lib.ps1`, which holds the single definition for both checks
- [x] Markets that share a domain (locale prefixes) share one `sitemap.xml`. Each sub-sitemap's locale is
  attributed to the market whose `PathPrefix` names it.
- [x] `skills/check-sitemap/SKILL.md`, the README row, and `scripts/tests/shopify-check-sitemap.tests.ps1` in `suite-groups.json`

### TEST

- [x] `shopify-check-sitemap` 99/0, `shopify-check-jsonld` 68/0, `shopify-which-theme` 58/0, `exception-message-guard` green
- [x] `check-plugin-integrity.ps1` 0 errors
- [x] The full gate runs in `ship-pr`

### DEPLOY: feat/4290-check-sitemap-in-shopify

Ships the `check-sitemap` skill in `dkj-subagents-shopify`. It reports a storefront's sitemap layout for
each market:
- which sub-sitemap holds a URL
- the URLs listed twice
- with `-Catalog`, the products, collections and pages the store serves that its sitemap leaves out

The markets come from the `Get-StorefrontMarkets` seam. A store that runs its markets as locale prefixes
on one domain is read from that domain's single sitemap. Step 2 of
[#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290).

**Score:** 2

#### What makes this deploy extra special

A store adopting this in place of its own copy gets two repairs:
- An accented handle is no longer reported as missing from the sitemap, because sitemap paths are now
  percent-decoded before the comparison.
- A catalogue list cut off at the 25,000 ceiling is skipped with a notice instead of counted as a finding.

`-Market` now defaults to every market.

**Score:** 2

#### Pull Request

Move check-sitemap into dkj-subagents-shopify
