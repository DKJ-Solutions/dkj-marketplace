## docs/4115-scope-question

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

#4115's two open questions were settled on the issue (November 15, 2026): under doubt a requirement or
defect is shared, so it is filed first, and the declared-deviation list lives in the repo's facts rule.
Proposal items 1 to 3 are built. Item 4, an optional close-out check, is not: the scope step at Classify
already asks the question before anything is built, and a gate for it would be new machinery the issue
did not settle.

### CREATE

- [x] Chris's persona, ritual step 2 (Classify): first which repo owns the work, shared or this one.
- [x] Chris's persona, the inbound route: the scope question before building, with "shared product
  behaviour" (brand book, page patterns, workflow scripts) inside the shared core, "shared" as the
  default under doubt, file or comment at the source first, and a local build only as a declared bridge
  naming that issue.
- [x] The constitution names a repo's declared deviations, with their reasons, among the facts its facts
  rule holds.

### TEST

- [x] Text only. The gates `ship-pr` runs cover the persona and the always-on budget.

### DEPLOY: docs/4115-scope-question

Chris now asks whether a piece of work is shared before he routes it. An owner's requirement, an
irritation or a found defect counts as shared product behaviour (the brand book, page patterns, the
workflow scripts) unless the repo's facts rule lists it as a declared deviation with its reason, and
under doubt it is shared. So it is filed or commented on the source tracker first, and any local build
in the meantime is a declared bridge that names that inbound issue and is removed when the release
lands. The constitution now lists those declared deviations among a repo's facts (#4115).

**Score:** 3

#### What makes this deploy extra special

In every consuming repo, a requirement that holds for every DKJ repo is now reported at the source before
it is built, instead of being built locally and then again in each of the other repos. A repo that really
does differ writes the deviation and its reason into its facts rule.

**Score:** 3

#### Pull Request

Chris asks 'is this shared?' before building

