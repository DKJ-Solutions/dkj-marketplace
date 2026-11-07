## feat/3859-day-plan-skill

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

Dave, November 7, 2026: work never feels finished because nothing adds a day up. Paula plans the day in
the morning (one goal, items with hours and a plan/go mode, strictly 6-8 h both ways) and closes it at the
end from GitHub. The Admin page that shows it is #3860, a separate branch because it is a visible result.

### CREATE

- [x] `plugins/dkj-policy/hub/lib/dayplan-lib.ps1`: reading a plan, the band, the pace, matching, the texts
- [x] `plugins/dkj-policy/hub/pages/day-plan.ps1`: -Context, -PlanFile [-Apply], -Add, -Close, -Week, -Override
- [x] `plugins/dkj-policy/skills/day-plan/SKILL.md`, Paula's manual section and her description, the hub README row
- [x] `scripts/tests/dayplan.tests.ps1`, in the pages group of `suite-groups.json`

### TEST

- [x] The suite: 47 passed
- [x] End to end against GitHub with a scratch state dir: -Context, the refusal under the band, an override, -Add refused over 8 h and accepted inside it, -Close, -Week
- [ ] Review: Victor (code), Sebastian (security), Edith (copy)

### DEPLOY: feat/3859-day-plan-skill

A new `day-plan` skill and script in `dkj-policy`, with a test suite and Paula's day-rhythm section; nothing
existing changes behaviour. The script keeps one day file per machine under `%LOCALAPPDATA%\dkj-hub\dayplan\`,
outside any repo, and counts the work of both accounts a checkout can act and commit as.

**Score:** 3

#### What makes this deploy extra special

The owner's working day gets a beginning and an end. In the morning Paula proposes one day goal and the items
for it, each with an hour estimate and a mode (plan first, or go), and she holds the day between 6 and 8
hours: a thin day and an overfull one are both refused, and an addition during the day that does not fit is
too. Overruling her takes a reason, which comes back at the close-out. In the evening the close-out reads
GitHub, says what got done, what moves to tomorrow and what was extra, and ends with "You can close the day";
on Friday the week does the same.

**Score:** 3

#### Pull Request

Day plan skill: Paula's morning plan and day/week close-out
