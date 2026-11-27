## feat/4520-asana-intake

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

Inbound #4520: there is no front door for a colleague's Asana task. Verified on pickup: no skill in
`dkj-repo-workflow-bwj` reads a task or judges readiness (`start-task` only cuts a branch,
`report-issue` only files), and the path this one hands off to, report-issue's *"On a ticket that came
the other way"*, exists. A procedure page, no script, as the issue proposes.

### CREATE

- [x] `skills/asana-intake/SKILL.md`: read, already-handled check (tracker open and closed, trunk, live
  branch, merged PRs), cause verification, one outcome, readiness verdict, receipt (drafted by Tessa #16,
  reviewed here).
- [x] The skills table in the extension README names it, beside `report-issue`.

### TEST

- [x] Every file, seam and marker the page names exists in the tree (`report-issue` and its paragraph,
  `Get-ShopifyLiveDeployBranch` as a consumer seam, the `Asana:` / `asana-task` markers). ship-pr runs
  the gates.

### DEPLOY: feat/4520-asana-intake

`dkj-repo-workflow-bwj` gains `asana-intake`, the front door for a colleague's Asana task that reaches
development. It reads the task, checks whether it is already filed or resolved (tracker open and closed,
the trunk and the live branch, merged PRs), verifies the cause the ticket states, and settles one
outcome: already resolved, an issue filed through `report-issue`, or no repo change. It ends with a
readiness verdict, and any question for the requester is drafted in the chat, never posted.

**Score:** 3

#### What makes this deploy extra special

A developer in a BWJ store repo no longer retypes the same three-step prompt for every Asana ticket, and
a ticket an earlier PR already resolved is caught before a duplicate issue is filed.

**Score:** 3

#### Pull Request

dkj-repo-workflow-bwj: an asana-intake skill -- read a task, check whether it is handled, file if needed, judge dev-readiness

