## fix/4310-stale-park-awaiting-release

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

Issue #4310: a sweep run right after the v7.1.0 cut printed #4274 as `skipped` under `awaiting-release`, though everything its parking clause named had shipped in that release.

### CREATE

- [x] `claim-issue.ps1 -Candidates` reads this repo's own `awaiting-release` as `stale-park` once every local `#<n>` its parking clause names has landed and this repo's newest release was published after the latest landing (or after the dated parking comment when none is named). Unread stays `skipped`.
- [x] `Get-ParkingWaitReferences`: the comment loop's `$body` overwrote the `-Body` parameter (PowerShell names are case-insensitive), so an issue parked at filing that later got any comment read that comment instead of its body. Renamed to `$commentText`.
- [x] Both plugin mirrors (`plugins/dkj-repo-workflow/scripts/task/claim-issue.ps1`, `.../lib/claim-issue-lib.ps1`) held byte-identical.

### TEST

- [x] `claim-issue.tests.ps1`: a non-parking comment beside a body clause still yields the body's `#4269`; source asserts that `-Candidates` reads `awaiting-release` against this repo's own release, anchored on the latest landing. Suite: 743 passed, 0 failed.
- [x] Live against the tracker: `-Candidates` now prints `#4274 stale-park -- label 'awaiting-release', but v7.1.0 has been published after #4269 landed`, with the unpark lines.

### DEPLOY: fix/4310-stale-park-awaiting-release

An issue parked as `awaiting-release` now comes back by itself on the first sweep after the release that carries what it waited on: `-Candidates` reads it as `stale-park` and prints the unpark line, the way the other waits already did. An issue parked at filing that later picked up an ordinary comment had its own parking clause silently ignored by every wait reading; that is fixed too.

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

claim-issue -Candidates reads a cleared awaiting-release as stale-park

