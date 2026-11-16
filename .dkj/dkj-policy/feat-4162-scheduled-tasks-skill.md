## feat/4162-scheduled-tasks-skill

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

#4162, first of its two branches: version the Desktop scheduled-task prompts in a dkj-policy skill
(decision on the thread, November 16, 2026) and give each owner's machine one command to place them.
The tested local prompt is absent on this machine, so task 1 is rebuilt from the issue's own
description. Task 2 (the weekly consumer health sweep) is the second branch.

The Desktop docs (code.claude.com/docs/en/desktop-scheduled-tasks) set the shape: SKILL.md holds only
`name`, `description` and the prompt; schedule, folder and enabled state live in the app. So the
command writes the prompt and prints the schedule for a person to register once.

### CREATE

- [x] `plugins/dkj-policy/skills/scheduled-tasks/`: the skill page and `tasks/bwj-release-prep.md` +
      `tasks/bwj-release-prep-monday.md`
- [x] `scripts/task/place-scheduled-tasks.ps1` + its plugin mirror, registered in
      `Get-SharedScriptPairs` (MirrorRun, and a new `RepoRootExempt` key with a reason), and a row in
      the plugin's scripts README
- [x] `shared-scripts.tests.ps1` holds a `RepoRootExempt` entry to a reason and to resolving no root
- [x] dropped from the Monday task: the issue's `notify-live` dry run, because `notify-live.ps1`
      refuses a version that has no tag yet, and on Monday morning the cut has not happened

### TEST

- [x] `scripts/tests/place-scheduled-tasks.tests.ps1`: 47 passed (a dry run writes nothing,
      placement, refresh by marker with `.previous`, orphan and unmarked tasks untouched, refusals,
      both copies find the shipped tasks from their own depth, the shipped tasks' shape)
- [x] `shared-scripts.tests.ps1` green; `check-plugin-integrity.ps1` 0 errors; the roster, script
      contract and unfolded-entry gates green

### DEPLOY: feat/4162-scheduled-tasks-skill

Inside this repo, the shared-scripts registry gains a `RepoRootExempt` key for an entry point that
touches no repo, and the new script is its first user.

**Score:** 1

#### What makes this deploy extra special

A team's Claude Code Desktop scheduled tasks are now versioned: the new `scheduled-tasks` skill ships
their prompts, and `place-scheduled-tasks` puts them into `~/.claude/scheduled-tasks/` on each owner's
machine, refreshes every placed copy after an update, and prints the schedule and folder to register
once in the app. It ships the BWJ Friday release prep and its Monday companion, both read-only.

**Score:** 3

#### Pull Request

Scheduled tasks: versioned Desktop task prompts and a command that places them

