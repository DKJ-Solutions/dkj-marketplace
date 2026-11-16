## feat/4149-sync-main-as-drift-check

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

#### The repair, and which of the issue's two routes it takes

#4149 offered two routes: run `sync-main -DryRun` as step 5's fallback, or give `sync-main` an `-Only` list
so a repo can answer the seam with it. A plain `-DryRun` cannot serve as a drift check, because it exits 0
on a `take-live` path, which is exactly the third-party edit a push would destroy. So the branch takes both
halves on one contract. `sync-main -Only <paths>` is the drift check: it implies `-DryRun`, judges only the
listed paths, and exits 1 on any take-live or conflicted path. Then `live-preflight` (its sibling
`sync-main`) and `prepare-release` (the repo's own `scripts/task/sync-main.ps1`, never reached across
plugins) fall back to it where nothing is answered and `live-snapshot.ps1` is absent. The issue comment's
third item, no deletion command without a passed drift check, closes with it, because `-Only` judges a
deleted path too.

#### What was measured, and how

The issue's item (1) asked to measure what `sync-main -DryRun` exits and prints on conflicts against a
real store. That was read from the code, which takes one route: conflicts print a `CONFLICTS:` block and
`exit 1`, take-live paths exit 0. It was then pinned through `-MirrorPath` fixtures. No real store was
pulled from this source repo, which has none.

#### Cost, stated

Where a release both uploads and deletes, `live-preflight`'s fallback runs `sync-main` twice, so it pulls
the theme twice. The two calls stay separate because a refusal on the deletions withholds only the
deletion command.

### CREATE

- [x] `sync-main.ps1`: `-Only <paths>`, the drift-check mode, with refusals for an empty list, `-ReconcileBase` and a Git-connected store; root mirror copied
- [x] `live-preflight.ps1`: falls back to its sibling `sync-main.ps1 -Only -RootOverride <root>`; root mirror copied
- [x] `prepare-release.ps1`: falls back to the repo's own `scripts/task/sync-main.ps1`
- [x] the three skill pages name the new parameter and the fallbacks

### TEST

- [x] `sync-main.tests.ps1`: ten new `-Only` asserts (conflict, held, take, implied dry run, nothing written, comma-joined list, deletion, unlisted drift, empty list, `-ReconcileBase`, connected); 193/193
- [x] `live-push-rules.tests.ps1`: the fallback and its trigger pinned on the source; 203/203
- [x] `bwj-development.tests.ps1`: prepare-release's fallback, and that it never reaches into the shopify plugin; 1035/1035

### DEPLOY: feat/4149-sync-main-as-drift-check

`sync-main` takes `-Only <paths>` and runs as a drift check over them
([#4149](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4149)). It writes nothing and exits 1
when a listed path holds content on live this repo never had, or was changed on both sides. Where no
drift check is answered and `scripts/theme/live-snapshot.ps1` is absent, `live-preflight` and
`prepare-release` now use it. Until now they skipped the step, and with it `live-preflight`'s deletion
command.

**Score:** 3

#### What makes this deploy extra special

A store whose only drift check is `sync-main` now learns from `prepare-release`, days ahead, which paths on
its push list a third party has changed on live. Measured in a consumer: 12 conflicted paths, 9 on the push
list, while the step read as skipped. On the day, `live-preflight` checks the same paths and prints the
deletion command it used to withhold.

**Score:** 3

#### Pull Request

sync-main -Only is a drift check, and the release steps fall back to it

Plugins: bwj-development, dkj-subagents-shopify
