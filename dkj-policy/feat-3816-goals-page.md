## feat/3816-goals-page

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

#### The issue

[#3816](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3816): a goal is clear on a large project but
the steps toward it are not. Two halves: a skill that breaks a goal into milestones and tasks, and an Admin
page that shows where to start. Data source decided by Dave: GitHub issues, the goal labelled `goal`, its
milestones its sub-issues, their tasks theirs.

#### Placement

#3815 landed before this branch, so the page sits in Admin's Development section as `/dev/goals`, the first
of the hub's own items: where to start is what the page is for. A repo's domain objects at the top level
(#3818) is a seam that does not exist yet, so Goals does not wait for it.

#### A visible result

The page is judged by eye, so the branch is parked for the owner's look with no pull request (the sweep's
step 5).

### CREATE

- [x] `hub/lib/goals-lib.ps1`: one GraphQL query (label, owner and name as variables, so no quote reaches a
  command line), the model with Now and Next, the "what now?" text, the plan a breakdown is filed from, and
  the page
- [x] `serve-general-pages.ps1`: `/dev/goals`, cached as the issues are, with `/refresh?page=goals`
- [x] `general-pages-lib.ps1`: Goals in `Get-GeneralPages`, first of the hub's own cards, with a flag icon
- [x] `hub/pages/plan-goal.ps1` and the `plan-goal` skill: check a plan, file it through `gh api --input`
  (goal, milestones and tasks linked as sub-issues), and `-Next`
- [x] `scripts/tests/goals.tests.ps1` in the `pages` group, and the dev-pages asserts that pin the page list
- [x] The hub README names the page, the script and the suite

### TEST

- [x] `goals.tests.ps1` 56 of 56 and `dev-pages.tests.ps1` green after the menu assert moved
- [x] The query read live against this repo's tracker (with `prio-2` standing in for the label), the model
  and the page built from the answer
- [x] `plan-goal.ps1 -PlanFile` on a plan with quotes in a title and an existing milestone, and `-Next` on a
  tracker with no goal
- [~] `-Apply` against a live tracker: not run, because it files real issues. The request bodies go through
  `gh api` exactly as the documented REST endpoints take them, and the owner's first plan is its first run.

### DEPLOY: feat/3816-goals-page

Admin has a **Goals** page on `/dev/goals`, the first of its own pages, with a `plan-goal` skill beside it
([#3816](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3816)). A goal is an open GitHub issue
labelled `goal`, its milestones are its sub-issues, and their tasks are theirs, so the page moves as sessions
claim and close issues, with no second administration. Per goal the page shows its progress, one prominent
**Now** card (the first open task of the first open milestone, or a milestone still to break down), a short
**Next** row and the milestones collapsed, each with a progress bar. The skill asks a few questions, proposes
4 to 6 milestones with session-sized tasks, and once the owner agrees files them as linked sub-issues
(`plan-goal.ps1 -PlanFile <plan> -Apply`). `plan-goal.ps1 -Next` answers "what now?" in the terminal.

**Score:** 3

#### What makes this deploy extra special

Every repo running `dkj-policy` gets a planning board that is never out of date, because it is the tracker
itself: on a project too big to see the first step of, Admin names that step.

**Score:** 3

#### Pull Request

Goals: an Admin page and a plan-goal skill (goal -> milestones -> tasks as GitHub sub-issues)
