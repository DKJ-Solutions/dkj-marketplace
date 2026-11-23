## fix/4393-bounded-theme-list-reads

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

The five `shopify theme list --json` reads #4384 left unbounded (archive-theme, backup-live-theme,
push-preview twice, sweep-preview-themes) take `-TimeoutSeconds 60`, and one pure lib function words
the timeout/login verdict so every read names the same remedy.

### CREATE

- [x] `Get-ShopifyLoginNote` in `shopify-cli-lib.ps1` (all three copies held identical)
- [x] the five reads bounded and wired to it; the four mirrors under `dkj-subagents-shopify` re-copied
- [x] four asserts in `shopify-cli.tests.ps1` on the note (clean, null, login, timeout)

### TEST

- [x] `shopify-cli.tests.ps1`: 32 of 32 asserts pass locally; the rest runs in the gate

### DEPLOY: fix/4393-bounded-theme-list-reads

`archive-theme`, `backup-live-theme`, `push-preview` and `sweep-preview-themes` bound their
`shopify theme list` read at 60 s, as `prepare-release` and `live-preflight` already do, and a timeout or
the CLI's login prompt is named with the one command that logs back in (#4393).

**Score:** 2

#### What makes this deploy extra special

A preview push, backup, archive or sweep on a machine whose Shopify login has expired now stops within a
minute and says so, instead of hanging silently.

**Score:** 3

#### Pull Request

Bound the remaining theme-list reads and name an expired Shopify login

