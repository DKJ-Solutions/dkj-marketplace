## fix/4168-sync-required-checks

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

#4168: `Complete-SyncPullRequest` waited on every check, so a pending non-required check held the merge
until the deadline. Read the required checks from the trunk's branch rules (they name a check before it
registers, which `gh pr checks --required` cannot) and judge only those; keep the old rule where none can be read.

### CREATE

- [x] `Get-SyncRequiredCheckNames` and `Get-SyncCheckVerdict` in `sync-rules.ps1`, pure and mirrored
- [x] `Complete-SyncPullRequest` reads `rules/branches/<trunk>` once and judges each poll with the verdict
- [x] The `sync-main` skill page's `-ChecksTimeoutMinutes` row says which checks are waited for

### TEST

- [x] `sync-rules.tests.ps1`: the measured case, a required check not yet registered, red and green on both sides, no required names; 238 asserts pass
- [x] `sync-main.tests.ps1`: the stand-in gh answers JSON and the bounded-call count is sixteen; 182 asserts pass

### DEPLOY: fix/4168-sync-required-checks

`sync-main` no longer holds its PR when a check the trunk does not require stays pending
([#4168](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4168)): it reads the required checks from the
trunk's branch rules and merges once those are green, as `ship-pr` does. A required check that has not
registered yet still counts as pending, and where the rules cannot be read or require nothing every check is
waited for, as before.

**Score:** 2

#### What makes this deploy extra special

A Shopify store whose sync PR carries a slow, non-required check (a theme-check report, measured pending for
ten minutes over green required checks) gets the sync merged instead of `NOT merged` after the timeout.

**Score:** 2

#### Pull Request

sync-main waits on the required checks only, where the repo has any

