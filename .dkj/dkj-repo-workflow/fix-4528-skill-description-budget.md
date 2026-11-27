## fix/4528-skill-description-budget

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

Trim every model-invocable SKILL.md description to a trigger-first line, take one-time skills out of the listing, and add an integrity check that holds each description and the summed total under the budget.

Measured before the change: 54 model-invocable skills whose descriptions summed to ~35,800 characters
(longest 2,868), against a listing budget of 1% of context with an 8,000-character fallback. The
overflow arrives name-only, so those skills never trigger on their own (#4528).

### CREATE

- [x] `disable-model-invocation: true` on the eight one-time or owner-typed skills: adopt-dkj-repo-workflow,
  adopt-dkj-repo-workflow-bwj, adopt-shopify-floor, scheduled-tasks, stopwatch-hide, stopwatch-prepare,
  record-suite-durations, dependabot-entry.
- [x] Every remaining model-invocable description rewritten to one trigger-first line of at most 200
  characters (46 skills, 7,843 characters in all, longest 198). The detail stays in each page's body.
- [x] Check 48 (`[skill-description]`) in `check-plugin-integrity.ps1`: each model-invocable description
  at most 250 characters, their sum over every published plugin at most 10,000.
- [x] The six printed instructions that told a session to run the now-barred adopt skill (check 33)
  name the slash command the operator types instead, in the source scripts and their plugin mirrors.
- [~] measure-skill reporting the sum against the budget: check 48's coverage line prints it on every
  gate run here; the consumer-side report is a separate change, filed as #4538.

### TEST

- [x] `check-plugin-integrity.ps1`: 0 errors, `[skill-description] checked 46`, sum 7,843 of 10,000.
- [x] `check-plugin-integrity-skill-spans.tests.ps1`: scenarios 17 and 18 cover check 48 (a short
  description passes, a 252-character folded description fails, a long barred one does not). 36/36 pass.

### DEPLOY: fix/4528-skill-description-budget

Every skill the plugins ship that a session can invoke on its own now has a short, trigger-first
description, and eight one-time or owner-typed skills (the adopt skills, scheduled-tasks, the two
stopwatch skills, record-suite-durations, dependabot-entry) left the model's listing and are typed as a
slash command instead. The descriptions together went from about 35,800 characters to 7,843, and a new
integrity check holds each one to 250 characters and their sum to 10,000.

**Score:** 3

#### What makes this deploy extra special

Skills such as asana-intake, day-plan and tidy-machine fire on their own again: Claude Code drops
descriptions that do not fit its skill-listing budget, and they were arriving name-only. The eight
skills above are now started by typing them, for example `/adopt-dkj-repo-workflow`.

**Score:** 3

#### Pull Request

Skill descriptions fit Claude Code's listing budget, so plugin skills trigger again

