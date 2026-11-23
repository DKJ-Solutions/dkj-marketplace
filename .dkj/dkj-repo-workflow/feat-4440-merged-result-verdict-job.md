## feat/4440-merged-result-verdict-job

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

Issue #4440, decision (a) by the owner: give the unattended merge-on-green run (`-TrustedRoot`) the #4432
docs-only lap discount by running the two cross-file checks in a separate, token-free job of
`merge-on-green.yml`, and let ship-pr read only its verdict.

#### Why a separate JOB, not a step

A step in the ship job would share the runner disk with `trusted-main`, so code it ran could rewrite the
scripts the token-bearing step runs next. A job is its own virtual machine, so the pick moves into its own
job and both later jobs read it through `needs:`.

### CREATE

- [x] `merge-on-green.yml`: three jobs before the redispatch -- `pick`, `merged-result` (no secret,
  `contents: read`, Windows like the CI lint leg; answers `skip` for any non-`.md` path before merging or
  running anything, else merges `origin/main` and runs both checks, then writes verdict + head + main
  without a BOM), and the ship job, which waits for both but is not held by a failed or skipped
  `merged-result`
- [x] `Test-MergedResultVerdict` in `pr-issues-lib.ps1` (pure, fails closed: only `pass`, only 40-hex
  SHAs, only the exact head and `main` tip)
- [x] ship-pr step 3b: under `-TrustedRoot`, keep the trusted eligibility read and accept the handed-over
  verdict instead of skipping the discount outright; `Invoke-MergedResultChecks` stays unreachable there
- [x] ship-pr SKILL.md paragraph on the unattended half

### TEST

- [x] `pr-issues.tests.ps1`: 13 asserts on `Test-MergedResultVerdict` plus the step 3b wiring
- [x] `merge-on-green-lib.tests.ps1`: the #2338 two-checkout guard rescoped to the ship job; new guards
  that the merged-result job holds no secret, checks out the picked SHA, refuses non-`.md` before merging,
  writes no BOM, and that the ship step receives the three values through `env:` (371 pass)
- [x] Proved the merged-result step's body for real, extracted verbatim from the YAML: on a docs-only
  commit three behind `main` it merged and both checks passed (`verdict=pass`, correct SHAs); on a commit
  touching `scripts/repo-config.ps1` it answered `skip` before running anything. That run caught a BOM
  from `Out-File -Encoding utf8` that would have turned every pass into no verdict.
- [x] native-capture and trusted-tree-seam suites unchanged and green

### DEPLOY: feat/4440-merged-result-verdict-job

The unattended merge-on-green run now gets the #4432 docs-only lap discount too. `merge-on-green.yml`
picks in its own job, then runs `check-plugin-integrity` and `check-always-on-budget` on `main` merged
into the picked head in a separate job that holds no token and never runs a PR's non-Markdown change. The
ship job hands that job's verdict to ship-pr, and step 3b under `-TrustedRoot` accepts it only for a PR
its own trusted code judged docs-only and disjoint, and only for the exact head and `main` tip the
verdict names. No verdict, a failed check or a moved `main` is the ordinary forward lap. A consumer's
runner has no such job, so nothing changes there. (#4440)

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** 0