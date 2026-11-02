## feat/hub-performance-under-ai

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

The owner, November 2, 2026: Performance mostly measures what the AI agents' work costs, so it moves to the AI
page; the Test gate measures CI, not an agent, so it goes to GitHub, beside Actions.

### CREATE

- [x] `Get-HubGroups`: Performance into the Claude section of `/ai`, after Specialists; Clock's sub drops the Test gate
- [x] `Get-GeneralPages`: a `GitHub` key on Issues and the Test gate, which leaves the Clock group
- [x] The hub home filters on `GitHub` instead of a hard-coded `/issues`; the GitHub page gains a Test gate card
- [x] Test gate trails read Tools > GitHub > Test gate on every level
- [x] `hub/README.md` and the code comments describe the new layout

### TEST

- [x] dev-pages, dev-preview-sessionstart, stopwatch and consumer-dashboard suites green, asserts moved to the new layout
- [x] A preview server from this tree serves every moved page with the right trail and cards
- [ ] The owner has looked at the preview (visible result)

### DEPLOY: feat/hub-performance-under-ai

The hub's Performance card moved into the AI page's Claude section, beside Rules, Skills and Specialists, and the
Test gate moved from the Clock to the GitHub page, beside Issues and Actions. The hub home carries the AI card in
Performance's old place. Every route is unchanged; only the cards and the breadcrumb trails moved
(Tools > AI > Performance > Clock, Tools > GitHub > Test gate).

**Score:** 2

#### What makes this deploy extra special

Every repo's toolbox reads differently: Performance is under AI and the Test gate under GitHub. No link breaks,
because no route changed.

**Score:** 2

#### Pull Request

Move Performance under AI > Claude and the Test gate under GitHub

