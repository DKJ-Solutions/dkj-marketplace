## fix/4186-decided-park-reads-stale

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

Issue #4186 offers a recording route, a safety net, or both. This branch builds the safety net, because it covers
the route the issue measured: an answer posted from a session where the plugin is not loaded at all, which no new
tool reaches. It reuses the `stale-park` reading `-Candidates` already does for `awaiting-pull`. A
`Decision (` comment after the last parking comment, from somebody with a hand on the repo, reads the park as
cleared, and the run prints the two unpark lines. The recording route (`record-decision`) is not built: the issue asked for either one, and a tool would only help where the plugin is loaded.

### CREATE

- [x] `Get-ParkDecisionAnswer` in `claim-issue-lib.ps1`: the decision comment after the last park, with the parking comment's trust rule
- [x] `claim-issue.ps1 -Candidates` reads `awaiting-decision-dev` and `awaiting-decision-client` as `stale-park` when one exists, and says the wait was decided
- [x] The issues-sweep skill page, the script help and CONTRIBUTING-portable name the reading
- [x] dkj-policy mirrors kept byte-identical

### TEST

- [x] `claim-issue.tests.ps1`: after the park counts, before a re-park does not, parked at filing counts, an outside author and prose do not, and `-Candidates` matches both labels
- [x] A live `-Candidates` run on this tracker completes

### DEPLOY: fix/4186-decided-park-reads-stale

`claim-issue -Candidates` reads an `awaiting-decision-dev` or `awaiting-decision-client` issue as `stale-park` once
a comment opening `Decision (` follows its last parking comment
([#4186](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4186)). The comment must come from somebody with a
hand on the repo. The run prints the lines that lift the label, so a decision posted without removing it no
longer leaves the issue skipped by every sweep.

**Score:** 2

#### What makes this deploy extra special

In every repo running the sweeps, a client's or owner's decision posted as a comment, from any session, now
surfaces at the next sweep as a park to lift. Until now the issue sat skipped until somebody noticed the label.

**Score:** 3

#### Pull Request

A decision park with a posted decision reads as stale-park
