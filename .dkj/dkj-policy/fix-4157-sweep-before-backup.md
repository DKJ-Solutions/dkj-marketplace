## fix/4157-sweep-before-backup

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

Part 2 of #4157 (parts 1 and 3 shipped in #4180): at or near Shopify's theme limit, `prepare-release`
and `live-preflight` put the preview sweep before the backup.

### CREATE

- [x] `Get-ThemeSweepOrder` in `live-push-rules.ps1` (and its two mirrors): sweep first when 2 or fewer slots are free
- [x] `live-preflight`: a `theme slots` step off step 5's list -- refuses a full store, warns near it; step 9 says the candidates are not aftercare then
- [x] `prepare-release`: reads the theme count (a read, skipped with `-SkipDrift`), and the runbook gains a step 0 sweep
- [x] Docs: THEME-LIFECYCLE-portable.md, the bwj-development CLAUDE.md line, the live-preflight step table

### TEST

- [x] `live-push-rules.tests.ps1` (211 pass) and `bwj-development.tests.ps1` (1040 pass)

### DEPLOY: fix/4157-sweep-before-backup

`live-preflight` counts the store's themes off the list it already reads
([#4157](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4157)). It refuses a full store (20/20)
before the backup and warns within two free slots. `prepare-release` reads the same count, and when the
store is at or near the limit its runbook puts the preview sweep first, as step 0, ahead of the preflight
whose backup needs the slot.

**Score:** 2

#### What makes this deploy extra special

A store at the theme limit no longer deadlocks on release day. The runbook prepared days ahead already
says to sweep spent previews before the preflight, so the backup has a slot to duplicate live into.

**Score:** 3

#### Pull Request

prepare-release and live-preflight sweep spent previews before the backup when the store is at or near the theme limit

Plugins: dkj-subagents-shopify, dkj-policy

