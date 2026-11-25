## fix/4485-windows-only-gates-skip

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

Issue #4485, option 2: on Linux, `check-roster-sync` crashed on `$env:USERPROFILE`, and
`check-plugin-integrity` reported 1218 findings caused by the platform. `ci.yml` already says the tree
is judged on Windows PowerShell 5.1 only, so both gates now say so on any other host instead of
crashing or flooding. Option 1, making them platform-neutral, would be a much larger port and is not
taken.

### CREATE

- [x] `scripts/sync/check-roster-sync.ps1` (and its `dkj-subagents-developers` mirror) and
  `scripts/lint/check-plugin-integrity.ps1`: a guard right after `param`, keyed on
  `[Environment]::OSVersion.Platform`, prints `[SKIP] ... Windows-only gate` and exits 0.
- [x] Chris's lens: where the four stand-verification gates are named, says the first two skip off
  Windows.

### TEST

- [x] `scripts/tests/roster-sync.tests.ps1`: pins, for both gates, the guard's shape and that it runs
  before any lib or StrictMode, and that the plugin mirror is identical. The suites run on Windows, so
  the skip itself is pinned on the source.

### DEPLOY: fix/4485-windows-only-gates-skip

In a Linux session, such as a Claude Code cloud session, `check-roster-sync` and `check-plugin-integrity`
now print a `[SKIP]` line naming CI's Windows leg as authoritative. Before, one crashed and the other
reported over a thousand findings caused by the platform.

**Score:** 2

#### What makes this deploy extra special

A consumer's cloud session that runs `check-roster-sync` from `dkj-subagents-developers` gets a clear
skip in place of a crash.

**Score:** 1

#### Pull Request

Two of the four stand-verification gates cannot run in a Linux cloud session

