## fix/4248-candidates-default-skiplabel

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

Issue #4248: `claim-issue.ps1 -Candidates` applied the default parking-label list only in the `Issue` parameter set (line 303, from #2518). The `issues-sweep` skill used to pass the list itself. #4233 dropped that line and said "pass none", so every parked issue read `free` and no `stale-park`/`relabel` printed. Verified on `main` at 1d0fc0a64 before claiming.

### CREATE

- [x] `scripts/task/claim-issue.ps1` (and its byte-identical plugin mirror): the default now applies in the `Candidates` set too. The comment that called the empty default deliberate, and the `.PARAMETER SkipLabel` help, now say why it changed.

### TEST

- [x] `scripts/tests/claim-issue.tests.ps1`: the wiring assert follows the new condition. New behavioural asserts run the script's own default block under each parameter set: `-Candidates` with no `-SkipLabel` gets the list, and an `awaiting-pull` issue reads `skipped` through `Get-SweepCandidates`. An explicit `-SkipLabel` still wins, and `-ReleaseAll` gets no default. Suite: 740 passed, 0 failed.

### DEPLOY: fix/4248-candidates-default-skiplabel

`claim-issue -Candidates` skips parked issues again when no `-SkipLabel` is passed, which is how the `issues-sweep` skill has run it since #4233. In v7.0.0 every parked issue read `free`, and a cleared wait never showed as `stale-park`. The claim's own parking check was the only backstop.

**Score:** 4

#### What makes this deploy extra special

A consumer running `issues-sweep` on v7.0.0 sees every parked issue offered as `free`, and the claim then refuses it. After this release, parked issues are skipped again and cleared waits print as `stale-park`.

**Score:** 3

#### Pull Request

claim-issue -Candidates applies the default parking-label list

