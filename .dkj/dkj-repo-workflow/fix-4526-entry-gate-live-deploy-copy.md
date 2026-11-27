## fix/4526-entry-gate-live-deploy-copy

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

Inbound #4526 proposes three repairs. Items 2 (the session check reads the deploy branch's copy) and 3
(the adoption docs say it out loud) land here. Item 1, a local gate at whatever opens a hotfix PR, needs a
new mechanism because no plugin script opens one (`open-pr`/`ship-pr` hard-code `--base main`). It is
filed as #4532.

### CREATE

- [x] `entry-gate-live-sessioncheck.ps1` also reads `origin/<live>:.github/workflows/branch-entry.yml`
      (a local git read of the remote-tracking ref) and warns, with the remedy, when that copy is missing or
      leaves the live branch out
- [x] `adopt-dkj-repo-workflow/SKILL.md`: a caller change on the trunk reaches hotfix PRs only once it
      reaches the live branch
- [x] item 1 filed as #4532

### TEST

- [x] `entry-gate-live-sessioncheck.tests.ps1`: five new asserts on git fixtures with a local
      `refs/remotes/origin/live`, including the measured shape (trunk `[main, live]`, origin/live `[main]`)
      -- 17/17 locally; the full gate is `ship-pr`'s

### DEPLOY: fix/4526-entry-gate-live-deploy-copy

`entry-gate-live-sessioncheck` now reads the live deploy branch's own copy of the branch-entry caller
(`origin/<live>`), not only the working copy. GitHub runs a hotfix PR's `pull_request` workflow from the
live branch's refs, so a trunk fix that had not reached `live` left hotfix PRs ungated while the check
said OK ([#4526](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4526)). The adoption page now
says when a caller change takes effect for hotfix PRs. A local gate at the hotfix opener is
[#4532](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4532).

**Score:** 3

#### What makes this deploy extra special

A Shopify consumer with a hotfix lane now sees a `[WARN]` at session start, with the remedy, whenever its
live branch still carries a caller that leaves `live` out. Before this, that state sat behind an OK line
and surfaced only as stranded changelog entries, three times in three days.

**Score:** 3

#### Pull Request

entry-gate-live-sessioncheck reads the deploy branch's own copy of the branch-entry caller

