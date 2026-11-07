## fix/3868-ship-pr-merged-during-lap

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

- [x] Verify the reported reason: step 3b's forward lap classified update-branch's `422 head ref does
  not exist` as `failed` and refused with "NOT merged, NOT folded" without ever reading the PR's state
  (#3868, measured on PR #3867).

### CREATE

- [x] `Test-PrMergedNow` in `ship-pr.ps1`: true only on a positively read `MERGED`.
- [x] Step 3b asks it before the forward (whether or not a lap is left) and again after an update-branch
  that did not forward; a merged PR breaks out of the lap instead of refusing.
- [x] One more read before step 4 covers a merge the lap never saw; a merged PR skips step 4's two gates
  and the `gh pr merge` call, and the read-back plus step 5 (with its already-folded handling, #1792) run
  against the merge that landed.
- [x] Plugin mirror kept byte-identical.

### TEST

- [x] Five structural asserts in `forward-lane-lib.tests.ps1`; the suite passes 117/0 on its own.

### DEPLOY: fix/3868-ship-pr-merged-during-lap

`ship-pr` no longer reports "NOT merged, NOT folded" for a pull request that something else merged while
it waited, such as its own `merge-when-green` arm. Before the stale-certificate lap forwards or refuses,
and before step 4 merges, it reads the PR's state; when it reads `MERGED` it says so and carries on with
the post-merge steps (the fold, or standing down where the fold already landed) instead of refusing (#3868).

**Score:** 3

#### What makes this deploy extra special

Whoever ships with `ship-pr` stops getting a false refusal that invites a re-ship or a blocker report for
work that had already landed.

**Score:** 2

#### Pull Request

ship-pr: recognise a PR merged by another path during the forward lap

