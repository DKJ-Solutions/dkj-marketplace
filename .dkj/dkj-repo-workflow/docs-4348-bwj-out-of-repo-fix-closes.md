## docs/4348-bwj-out-of-repo-fix-closes

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

The decision was recorded on #4348 (split by owner), so this branch writes it down where both
statements are read.

### CREATE

- [x] `dkj-repo-workflow-bwj`'s `WORKFLOW-portable.md`, beside the #3059 act-only close: a fix in code
  the team does not own closes as not planned, with a note on where it lives and whose it is, and nobody
  chases the colleague. A blocker in a repo the team runs still parks.
- [x] The core's `CONTRIBUTING-portable.md`, at `awaiting-pull-external`: an extension may close instead,
  and the pointer names the BWJ rule.

### TEST

- [x] Documentation only; ship-pr's lint gate checks links and the always-on budget.

### DEPLOY: docs/4348-bwj-out-of-repo-fix-closes

In a BWJ store repo, an issue whose fix lives in a colleague's project now closes as not planned, with a
note on where the fix lives and whose it is, instead of being parked `awaiting-pull-external`. A blocker in a repo the team
runs, such as a `dkj-marketplace` release, still parks as before. The core's label section points to the
exception ([#4348](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4348)).

**Score:** 2

#### What makes this deploy extra special

A store's open issues no longer collect waits on code the team cannot change.

**Score:** 2

#### Pull Request

bwj: a fix in code the team does not own closes as not planned; a blocker in a repo the team runs still parks

