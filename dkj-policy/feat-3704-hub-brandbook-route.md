## feat/3704-hub-brandbook-route

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

#3704: the brand book's rename left the toolbox page behind -- its card, title and breadcrumb said "House style"
and it lived on `/plugins/dkj-policy/house-style`, while the product already shows the same page as `dkj-brandbook`
on `/marketplace/dkj-policy/dkj-brandbook`. The owner gave the go-ahead to build it (November 2, 2026). The toolbox
follows the product: the route, the card, the title and the crumb become `dkj-brandbook`, and both older addresses
redirect. The file names (`house-style.css`, the `house-style` icon key, the `*HouseStyle*` functions) stay, as the
rename chose.

#### A visible result

This changes the hub's page, so the branch is parked for the owner's look, not merged. Open `/plugins/dkj-policy`
on a toolbox outside this repo (here the toolbox sends the page to the product): the card reads dkj-brandbook and
opens `/plugins/dkj-policy/dkj-brandbook`; `/plugins/dkj-policy/house-style` lands there too.

### CREATE

- [x] `plugins-page-lib.ps1`: `/plugins/dkj-policy/dkj-brandbook[/<section>]` is the page; `/plugins/dkj-policy/house-style` and `/plugins/dkj-solutions/house-style` (with a section) redirect to it; card, title, crumb and lead say dkj-brandbook / brand book
- [x] `serve-general-pages.ps1`: serves the page under its new key, its header names both redirects
- [x] Docs naming the old address: the hub README, the brand book README, the dkj-solutions README, Gwen's lens, a `dev-pages-lib.ps1` comment

### TEST

- [x] `dev-pages.tests.ps1` holds the new route, both redirects and the new labels: 552 passed, 0 failed

### DEPLOY: feat/3704-hub-brandbook-route

The hub's brand book page is named `dkj-brandbook` in the toolbox too, as it already was on the product: its card,
title and breadcrumb, and its address, `/plugins/dkj-policy/dkj-brandbook`
([#3704](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3704)). Both older addresses,
`/plugins/dkj-policy/house-style` and `/plugins/dkj-solutions/house-style`, redirect there, a section to the same
section.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The hub's brand book page is named and routed as dkj-brandbook
