## feat/3924-dayplan-sync

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

- [x] Reuse the Stopwatch's ref plumbing (#3349) rather than a second copy: `Receive-`/`Publish-StopwatchShared`
  take the ref namespace, file name, subject and identity as parameters, defaulting to the Stopwatch's own.
- [x] Settle the issue's four design points with its own suggestions: one private home repo
  (`DKJ_DAYPLAN_REPO`, visibility checked through `gh`), the newest plan as the base plus every later addition
  (a closed copy wins whole), a sync in every command, and `not shared` offline.

### CREATE

- [x] `lib/dayplan-sync-lib.ps1`: the home repo, the bare sync dir, the bounded payload, the merge, the sync.
- [x] `pages/day-plan.ps1`: the merged read, a sync around every write, `-Sync`, and `-Status` off the network
  with a background sync every five minutes.
- [x] The Today page's footer names whose day file the plan is; the skill and the Admin README document it.

### TEST

- [x] `dayplan-sync.tests.ps1` (new): the payload and its bounds, the merge rules, and two machines planning
  and adding to one day through a bare remote of the test's own. `dayplan.tests.ps1` holds sharing off and
  covers the footer. `stopwatch-sync.tests.ps1` passes unchanged.
- [ ] The owner looks at the Today page's footer (`/dev/today`): it now says whether the plan is this
  machine's day file or merged from every machine's.

### DEPLOY: feat/3924-dayplan-sync

The `day-plan` script syncs the day plan across machines through Stopwatch-style refs
(`refs/dayplan/<machine id>`) in one private home repo. The Stopwatch's publish and fetch now take their
namespace as parameters, so both features share one set of plumbing.

**Score:** 3

#### What makes this deploy extra special

The day plan now works on several machines at once: set `DKJ_DAYPLAN_REPO` to a private repo in your user
settings, and a plan made on one machine is the plan on every other. `-Add` is held to the 6-8 h band against
the whole day, and `-Close` sees the whole day. Sharing goes only to a repo GitHub reports as private, since
plan titles can be personal. Without the setting nothing changes.

**Score:** 3

#### Pull Request

day-plan: sync the day across machines through refs

