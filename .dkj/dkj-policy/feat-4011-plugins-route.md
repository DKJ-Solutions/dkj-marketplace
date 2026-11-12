## feat/4011-plugins-route

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

#4011, as decided on the issue (DaveKJohn, November 12, 2026): the repo and marketplace name stay
`dkj-marketplace`; only the product server's `/marketplace` route becomes `/plugins`. The url follows
the h1 (Maikel's October 30, 2026 rule), so the h1, the trail and the menu label go back to Plugins
with it, and the old `/plugins` -> `/marketplace` redirect turns around.

### CREATE

- [x] `scripts/lib/dev-pages-lib.ps1`: every product address under `/plugins`, h1 and crumbs `Plugins`;
  `Resolve-MarketplaceRedirect` now sends `/marketplace[/...]` (up to four levels, so the brand book's
  token pages too) to the same level under `/plugins`
- [x] `scripts/lib/consumer-dashboard-lib.ps1`: the menu entry is `Plugins` at `/plugins`
- [x] `scripts/dashboard/serve-consumer-dashboard.ps1`: comments follow the new address
- [x] `plugins/dkj-policy/apps/admin/lib/plugins-page-lib.ps1`: Admin in the source repo sends the
  house style to `/plugins/dkj-policy/dkj-brandbook`; a released Admin's `/marketplace` link is redirected
- [x] suites `dev-pages`, `consumer-dashboard`, `house-palette` and Uma's lens follow the address

### TEST

- [~] the owner's look at http://localhost:4871/plugins and its levels (a visible result) -- Not done as a separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-12 without one.

### DEPLOY: feat/4011-plugins-route

The product server's plugin pages moved from `/marketplace` back to `/plugins`, with the h1, the
trail and the menu label named Plugins again; every old `/marketplace` address, the brand book's
token pages included, answers with a 303 to the same page under `/plugins`
([#4011](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4011)). Only the product server in
this source repo serves these pages.

**Score:** 2

#### What makes this deploy extra special

No consumer runs the product server, and a consumer's Admin links to it only in the source repo, so
nothing a subscriber takes changes.

**Score:** N/A

#### Pull Request

Product server: rename the /marketplace route to /plugins

