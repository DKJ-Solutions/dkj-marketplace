## fix/3829-reviews-resolve-look-step

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

#3829: `issues-sweep-reviews` step 4 runs `ship-pr` on a parked branch whose plan still ends on an open
"the owner looks" step, so `open-pr`'s step gate refused every ship of the November 5 pass. The skill must
tell the session to resolve that step with the approval before it ships.

### CREATE

- [x] `issues-sweep-reviews` step 4: mark the owner-look step `- [~]` with the approval's words, commit it,
      then `ship-pr` (`plugins/dkj-policy/skills/issues-sweep-reviews/SKILL.md`).
- [x] `issues-sweep` step 6, which ships an approved branch the same way, says the same in one clause
      (`plugins/dkj-policy/skills/issues-sweep/SKILL.md`).

### TEST

- [~] No suite reads the skills' prose; the gates `ship-pr` runs cover the tree.

### DEPLOY: fix/3829-reviews-resolve-look-step

`issues-sweep-reviews` now resolves a parked branch's "the owner looks" step with the approval before it
ships, and `issues-sweep` step 6 does the same. Without it `open-pr`'s step gate refused every branch the
skill was meant to ship.

**Score:** 3

#### What makes this deploy extra special

An owner who approves parked visible results in one `/issues-sweep-reviews` pass sees them ship, instead of
every one being refused on its own plan.

**Score:** 3

#### Pull Request

issues-sweep-reviews: resolve the plan's owner-look step before ship-pr

