## fix/4067-reviews-noresolves-mirrored

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

Inbound #4067. Verified before the repair: `open-pr`'s resolves gate refuses `-Resolves` for an issue
whose body matches `Get-ResolvesExemptMatchers` (`open-pr.ps1`, resolves-exempt gate), and
`issues-sweep-reviews` step 4 prescribes `-Resolves` and states that the merge closes the issue, with no
word on that route. `issues-sweep` step 6 already says the mirror's message comes before the close, so
the gap is in the reviews skill alone.

### CREATE

- [x] `issues-sweep-reviews` step 4: a paragraph naming the `-NoResolves` route for an issue the repo
      closes by hand, the mirror plugin's handover step (`golive-block -Post` in `bwj-development`)
      before the hand close, where the preview link comes from, and that such a refusal is not a
      held-out ship.
- [x] Step 6's receipt names an issue closed by hand after a `-NoResolves` ship.

### TEST

- [x] No gate pre-run (`issues-sweep` step 4): `ship-pr` runs the full gate before the push, and the
      required CI check runs before the merge.

### DEPLOY: fix/4067-reviews-noresolves-mirrored

`issues-sweep-reviews` now tells a pass what to do with a parked issue the repo closes by hand: step 4
says `open-pr` refuses `-Resolves` for an issue matching `Get-ResolvesExemptMatchers`, so that issue ships
with `-NoResolves`, gets the mirror plugin's handover (`golive-block -Post` in `bwj-development`) while
still open, and is then closed as completed. Step 6's receipt names it as closed by hand. Before this,
every Asana-mirrored issue in a pass failed its first ship ([#4067](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4067)).

**Score:** 2

#### What makes this deploy extra special

An owner running `/issues-sweep-reviews` in a store repo no longer meets a refused ship on every mirrored
issue and has to work out the route from the refusal text.

**Score:** 2

#### Pull Request

issues-sweep-reviews names the -NoResolves route for an issue the repo closes by hand

