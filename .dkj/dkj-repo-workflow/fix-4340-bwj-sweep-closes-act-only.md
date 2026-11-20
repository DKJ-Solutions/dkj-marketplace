## fix/4340-bwj-sweep-closes-act-only

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

#### The reason, verified

The issue says the sweep and `parking.md` never mention the extension's close. Half true:
`parking.md` named it in one sentence, filed under "What `<what>` names", with neither the #3059
question nor the close form. SKILL.md step 1 never pointed to it. And nothing in `claim-issue -Park`
stopped the park, so the repair goes into the script rather than adding more prose.

### CREATE

- [x] `Test-ParkClosedByExtension` in `claim-issue-lib.ps1`: true for `awaiting-action-dev` when an
  enabled id is `dkj-repo-workflow-bwj@*`.
- [x] `claim-issue.ps1 -Park awaiting-action-dev` refuses in a repo whose OWN settings enable that
  extension (`RepoEnabledIds`, so a user-level enable on one machine does not change the repo's parks).
  It asks the #3059 question and prints both routes. `-StillChangesCode` is the yes, and it is refused
  beside any other label. An unreadable settings chain fails open.
- [x] Mirrored with `build-shared-scripts.ps1`.
- [x] Docs: `parking.md` gets its own section (question, close form, measurement); SKILL.md step 1
  points there; the claim-issue skill names `-StillChangesCode`.

### TEST

- [x] `claim-issue.tests.ps1`: five unit asserts on `Test-ParkClosedByExtension` and three runs (a
  fixture repo enabling the extension refuses the park and names the question and both routes;
  `-StillChangesCode` refuses on another label and without a park). 751 passed, 0 failed.

### DEPLOY: fix/4340-bwj-sweep-closes-act-only

`claim-issue -Park awaiting-action-dev` now refuses in a repo whose own settings enable
`dkj-repo-workflow-bwj`. That extension closes an act-only issue as completed with a research block
instead of parking it (#3059, #3062), and its sweeps kept parking such issues anyway (four measured on
smartwatchbanden). The refusal asks the extension's question, *does any step still change a file in the
repo?*, and prints the close route for a no. For a yes, `-StillChangesCode` lets the park through.
`issues-sweep`'s `parking.md` now gives the rule its own section ([#4340](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4340)).

**Score:** 3

#### What makes this deploy extra special

A BWJ sweep closes what the extension says to close, so the open issues and the In Progress column show
only work that can still be built. Repos without the extension see no change.

**Score:** 3

#### Pull Request

issues-sweep closes act-only issues where the BWJ extension says so

