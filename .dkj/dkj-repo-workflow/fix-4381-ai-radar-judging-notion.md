## fix/4381-ai-radar-judging-notion

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

### CREATE

- [~] A judging mode in the shipped `ai-radar` skill -- dropped: #4382 builds the judging half as
  `tip-check` in `dkj-subagents-alpha`, as its issue asks, and edits the same lines of `ai-radar/SKILL.md`.
  A second judging procedure would duplicate it (PR #4389 closed for that reason).
- [x] Retired the repo-local `.claude/skills/ai-radar/` and `scripts/dashboard/ai-radar.ps1`, which read a
  `Brains/` folder the life hub no longer has, and their fixture block in `consumer-dashboard.tests.ps1`.

### TEST

- [x] No other path references the retired skill or script (grep, release history excepted); the suites
  `ship-pr` selects are the check.

### DEPLOY: fix/4381-ai-radar-judging-notion

The repo-local `ai-radar` skill and `scripts/dashboard/ai-radar.ps1` are retired: they read the AI radar
from a `Brains/` folder in the life hub checkout that no longer exists, since the radar moved to Notion. The
judging half lands as `tip-check` in `dkj-subagents-alpha` (#4382), so this is one step of #4381.

**Score:** 1

#### What makes this deploy extra special

Only this repo carried the local skill and script, so nothing a plugin user takes changes.

**Score:** N/A

#### Pull Request

ai-radar: retire the repo-local radar that reads a Brains/ folder

