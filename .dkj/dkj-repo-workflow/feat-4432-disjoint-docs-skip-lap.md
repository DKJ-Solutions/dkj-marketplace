## feat/4432-disjoint-docs-skip-lap

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

#### Decision

Option (a) on #4432, recorded on the issue by issues-sweep-decisions (2026-11-23): skip the step-3b
forward lap for a docs-only PR disjoint from the trunk's new commits, provided the cross-file checks
pass locally on the merged result.

### CREATE

- [x] `Test-DisjointDocsOnlyCertificate` + `Get-NameStatusPaths` (pure) in `scripts/lib/pr-issues-lib.ps1`, with its mirror
- [x] `Get-DisjointDocsVerdict` + `Invoke-MergedResultChecks` in `scripts/release/ship-pr.ps1`, wired into step 3b (once per gained-commit set) and step 3a (eligibility only, no early forward), with its mirror
- [x] `skills/ship-pr/SKILL.md` and the `-MaxForwardLaps` help name the second discount

### TEST

- [x] `scripts/tests/pr-issues.tests.ps1`: 12 new asserts on the pure decision (docs-only, overlap case-insensitive, rename sides, empty sets fail closed); suite green locally (1203 asserts)
- [x] the full gate runs in ship-pr and CI

### DEPLOY: feat/4432-disjoint-docs-skip-lap

Under merge-on-green every merge voided the certificate of every other armed PR, and each then paid a
full CI forward lap (~10 min), even when the PR touched only `.md` files that none of the new trunk
commits touched. Step 3b now discounts that case: when the PR's diff is docs-only (every path `.md`)
and shares no file with the counted (non-fold) commits `main` gained, ship-pr merges `main` into the PR
head in a throwaway worktree and runs `check-plugin-integrity` and `check-always-on-budget` there (~2
min). Green, the certificate holds and the merge goes ahead without a lap; anything that fails or cannot
run falls through to the lap unchanged. Step 3a no longer early-forwards such a PR. (#4432)

**Score:** 3

#### What makes this deploy extra special

A repo that ships through `ship-pr` with merge-on-green sees its docs-only pull requests merge one after
another instead of queueing a CI cycle each behind every other merge.

**Score:** 3

#### Pull Request

ship-pr step 3b: skip the forward lap for a docs-only PR disjoint from the trunk's new commits, after local cross-file checks

