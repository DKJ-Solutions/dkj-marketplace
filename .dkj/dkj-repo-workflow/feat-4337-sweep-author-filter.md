## feat/4337-sweep-author-filter

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

Issue #4337: in a tracker two people share, each person sweeps only what their own sessions filed. An
`-Author <login|@me>` filter on `claim-issue.ps1 -Candidates`; every issue another account opened reads
`skipped` with the reason `not authored by <login>`.

### CREATE

- [x] `Get-SweepCandidates` (`scripts/lib/claim-issue-lib.ps1` and its plugin mirror) takes `-Author`:
  case-insensitive, an issue without an author field is skipped too, `-SkipIssue` keeps precedence.
- [x] `claim-issue.ps1 -Candidates -Author` (and mirror): `@me` resolved once via `gh api user`, an
  unresolvable `@me` is an `[ERROR]` and exit 1; the list reads `author`. The goal tree's in-flight pass
  deliberately takes no `-Author`, so another session's work still holds its goal's Now.
- [x] One line each in `issues-sweep`, `issues-sweep-decisions` (`--author @me` on its `gh issue list`)
  and the `claim-issue` skill's parameter list.

### TEST

- [x] `claim-issue.tests.ps1`: five new asserts (other author skipped with the reason, own author free
  case-insensitively, missing author skipped, no `-Author` filters nothing); 748 passed, 0 failed.
- [x] `native-capture.tests.ps1` caught the new bounded `gh api user` site; audited (measured before
  its exit code, every failure an `[ERROR]` and exit 1) and the count moved 129 -> 130 with the reason.
- [x] Live: `-Candidates -Author @me` lists the backlog as before; `-Author nobody-here` skips all 12
  open issues with `not authored by nobody-here`.

### DEPLOY: feat/4337-sweep-author-filter

`claim-issue.ps1 -Candidates` and `Get-SweepCandidates` gain `-Author`; the sweep pages name it.

**Score:** 2

#### What makes this deploy extra special

In a repo two people share, `issues-sweep` can now sweep only the issues your own sessions filed:
`claim-issue.ps1 -Candidates -Author @me` reads every other issue as `skipped`, and
`issues-sweep-decisions` walks only your own decisions with `--author @me`. Without the flag nothing changes.

**Score:** 3

#### Pull Request

issues-sweep: an -Author filter on claim-issue -Candidates

