## feat/4329-deploy-branch-promotion-guard

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

Carry out the owner's decision on #4329 (November 19, 2026), which reverses the #3014 ruling: rule 5 of
`guard-live-theme.ps1` gates every route onto a Git-connected deploy branch with the one live-push
marker, so smartwatchbanden can delete its 720-line local hook.

### CREATE

- [x] Sylvester: rule 5 widened in `guard-live-theme.ps1` -- `gh pr create/edit --base <deploy>`, writing `gh api` calls on the branch, and local commit/merge/cherry-pick/revert/am/rebase/pull while HEAD is on it; degraded-path refusals for the two gh routes; header, seam and rule-block comments rewritten; README row and live-preflight SKILL row updated
- [x] Review (main loop): one plain `git -C <dir>` is now read in `<dir>` instead of refused outright, matching the consumer hook, since sessions use `-C` routinely

### TEST

- [x] `guard-live-theme.tests.ps1`: 411 passed, 0 failed (new section for #4329, plus four `-C` asserts)
- [x] `check-plugin-integrity.ps1`: 0 errors (run by the subagent before the `-C` edit; ship-pr reruns the full gate)

### DEPLOY: feat/4329-deploy-branch-promotion-guard

`guard-live-theme` rule 5 now gates every route onto the branch a Git-connected live theme deploys from
(`Get-ShopifyLiveDeployBranch`), not only a `git push`: a `gh pr create` or `gh pr edit` with that branch
as base, a writing `gh api` call on it (ref create, move, rename, protection, merges), and a local commit,
merge, cherry-pick, revert, am, rebase or pull while it is checked out. Each needs the existing live-push
marker (`Get-ShopifyLivePushMarker`); no new seam. `gh pr merge` stays ungated, because the PR's base was
gated when it was opened. This reverses the #3014 ruling that left the promotion PR ungated. Where HEAD
cannot be told (`cd` earlier in the command, `--git-dir`, two `-C`), a local write is refused rather than
guessed.

**Score:** 3

#### What makes this deploy extra special

A Shopify repo whose live theme deploys from a Git branch now has every route onto that branch guarded by
the plugin, with one marker. Opening the promotion PR from a session needs the marker, and smartwatchbanden
can delete its own local hook and suite once it takes this version.

**Score:** 3

#### Pull Request

guard-live-theme gates every route onto a Git-connected deploy branch

