## docs/3968-labels-read-and-prescribed

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

#3968: two sentences in `CONTRIBUTING-portable.md` said the plugin reads none of a consumer's labels and
prescribes only the reach label, while `claim-issue` reads and writes the `awaiting-*` set and `open-pr`
applies the prefix table's PR labels. Verified against `Select-ParkingLabels`, `-Park` and `branch-info.ps1`.

### CREATE

- [x] step 1 says "your own labels" and names the workflow's three sets: PR labels, triage labels, reach label
- [x] the reach-label paragraph calls it the third set, not "exactly one exception"
- [x] `reach-label.tests.ps1` pin repointed to the new wording, plus an assert on the three sets

### TEST

- [x] `reach-label.tests.ps1` alone: 41 asserts pass
- [x] no other copy of the old wording in the tree (archived release notes aside)

### DEPLOY: docs/3968-labels-read-and-prescribed

`CONTRIBUTING-portable.md` stopped saying the plugin reads none of your labels but the reach label, and now
names the three sets it does read or prescribe (#3968).

**Score:** 1

#### What makes this deploy extra special

The page that tells a consumer which labels are theirs now lists the ones the workflow owns: the PR label
per branch prefix, the triage labels (whose `awaiting-*` half the sweep reads to skip parked issues), and
the reach label. It prevents a consumer from renaming or dropping an `awaiting-*` label on the old page's
word and then having a sweep claim a parked issue.

**Score:** 1

#### Pull Request

CONTRIBUTING-portable names the labels the plugin reads and prescribes

