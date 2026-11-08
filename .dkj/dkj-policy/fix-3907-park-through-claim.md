## fix/3907-park-through-claim

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

#### The direction (#3907 left three open)

The first and the third: park through `claim-issue` (`-Park <label> -Reason <text>`), and refuse a plain `-Tag`
claim on an already-parked issue. The second (re-read before commenting) narrows the window and does not close it,
and the first makes it unneeded. The refusal is scoped to the sweep route on purpose. The assignee route keeps
#2518's warning, because #1485's reason (a stale label must not block) holds there, while the sweep route never
claims a parked issue except through this race. It sits below the verdict switch, outside the advisory scan block
that #1485's own asserts keep free of exits.

### CREATE

- [x] `Test-ParkLabel` and `Format-ParkComment` in `claim-issue-lib.ps1` (both mirrors byte-identical)
- [x] `claim-issue.ps1`: `-Park`/`-Reason`, validated before any read; the label and the comment only after the
  read-back names the winner; the claim released on every path; the parked-issue refusal under `-Tag` (both mirrors)
- [x] `issues-sweep` step 1 parks through `-Park`, step 2 names the new refusal, and a verdict that closes an issue
  is building work that starts with a claim
- [x] Tests in `claim-issue.tests.ps1`, including four runs of the script's own refusals
- [x] Review fixes. Victor: a park of an issue this tag already holds parks it (it said "nothing to write" and left
  the claim standing); the release's exit code is read; the read-back reads the labels, so a park that landed
  meanwhile writes nothing a second time; the label must be one the sweeps skip. Sebastian: the reason is posted as
  one line, and the paste-ready fallback is single-quoted and stripped.

#### Two things a reviewer should know

- **The refusal also covers `record`, `dossier`, `awaiting-owner-act` and `awaiting-event`** (Victor): they are in
  the default skip list, so a plain `-Tag` claim on such an issue now refuses where it warned. That is intended, since
  `-Candidates` skips them too and the sweep route never claims them.
- **The write paths are pinned by shape, not run**: the suite has no `gh` stub seam, so `Invoke-ClaimPark` is held
  by asserts on its text (every refusal releases before it exits, the release's exit code is read), and only the
  validation refusals are executed.

### TEST

### DEPLOY: fix/3907-park-through-claim

`claim-issue.ps1 <n> -Tag -Park <awaiting-label> -Reason "<what>"` parks an issue under a claim
([#3907](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3907)). Only the winner of the claim's read-back
sets the label and posts `Parked by a sweep: waiting on <what>.`, and the claim is released on every path. A plain
`-Tag` claim on an issue that another sweep parked after step 1 now refuses instead of warning and printing
`[OK] claimed`. The assignee route keeps its warning (#2518). `issues-sweep` step 1 parks this way now, and says
that evaluating and closing an issue starts with a claim.

**Score:** 3

#### What makes this deploy extra special

A repo that runs several sweeps at once no longer gets one issue parked two or three times with comments that
disagree. `issues-sweep` users park with one command where they used two, and a late claim on a parked issue
stops rather than taking it.

**Score:** 3

#### Pull Request

issues-sweep parks through claim-issue -Park, so concurrent sweeps cannot park one issue twice

