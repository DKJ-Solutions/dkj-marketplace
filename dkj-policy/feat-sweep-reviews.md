## feat/sweep-reviews

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

Dave, November 5, 2026: a third sweep that approves every issue parked on `awaiting-review-dev` and ships
its parked branch. It runs `sweep-issues` step 6 for the whole pile in one pass. The constitution lets a
visible result merge only on the owner's word, so the skill carries `disable-model-invocation: true`:
only a person types it, and typing it is that word for every issue it lists. It skips
`awaiting-review-client`, whose look belongs to somebody else. Named `issues-sweep-reviews` at Dave's
request; renaming the two existing sweeps to the same scheme is a separate branch.

### CREATE

- [x] `plugins/dkj-policy/skills/issues-sweep-reviews/SKILL.md`: the new skill. It finds each issue's single parked branch, verifies or takes over the claim, comments the approval before it removes the label, ships with `ship-pr -Resolves`, and holds out an issue with no branch, two branches, a colleague's claim or a refused ship.
- [x] `plugins/dkj-policy/CONTRIBUTING-portable.md`, `plugins/dkj-policy/skills/sweep-issues/SKILL.md`, `.claude/specialists/lenses/specialist-05-05-lens.md`, `plugins/ADOPTION.md`: each place that says which sweep walks the review labels now names the new one.
- [~] A script that loops over the issues: dropped. Every step is an existing script (`claim-issue`, `ship-pr`, `prune-merged`), and `ship-pr` is long-running with a last line that has to be read per issue, so a wrapper would hide exactly what the session must read.

### TEST

- [x] `check-plugin-integrity.ps1` passes with the new skill registered.

### DEPLOY: feat/sweep-reviews

A new skill, `issues-sweep-reviews`, approves and ships every issue parked on `awaiting-review-dev` in one pass. Each issue gets an approval comment and loses its label, and its parked branch goes through `ship-pr` (open, merge, fold). Only a person can run it, because typing the command is the owner's permission to merge a visible result. It never touches `awaiting-review-client`, and it holds out any issue without exactly one parked branch, any branch a colleague claims and any ship that is refused. Until now each parked branch had to be shipped by hand, one at a time.

**Score:** 3

#### What makes this deploy extra special

An owner who has a pile of visible results parked by `sweep-issues` ships them all with one command, instead of one round per branch.

**Score:** 3

#### Pull Request

issues-sweep-reviews: ship every awaiting-review-dev issue on the owner's word
