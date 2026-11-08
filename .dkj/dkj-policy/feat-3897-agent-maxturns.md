## feat/3897-agent-maxturns

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

- [x] Follow the owner's decision on #3897 (davekokbwj, 2026-11-08): a `maxTurns` ceiling per role
  only; `model: sonnet` everywhere, no `memory:`, no `skills:` preload. The docs (sub-agents,
  supported frontmatter fields) list `maxTurns` among the keys a plugin agent keeps.

### CREATE

- [x] `maxTurns` in all 26 subagent defs, read off each def's `tools` line: 60 read-and-report,
  80 web research or writing without `Bash`, 120 writing with `Bash`.
- [x] The teams README states the rule beside the frontmatter it describes.

### TEST

- [x] `git diff --stat`: 26 defs, one inserted line each and nothing else changed; the full gate
  runs in `ship-pr`.

### DEPLOY: feat/3897-agent-maxturns

Every specialist subagent now carries a `maxTurns` ceiling that matches its role: 60 turns for one
that only reads and reports, 80 for one that also searches the web or writes files, and 120 for one
that writes and runs `Bash`. A runaway dispatch now stops at that ceiling and hands back what it has.
Model, effort and memory stay as they were
([#3897](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3897)).

**Score:** 2

#### What makes this deploy extra special

A specialist that loops now stops and returns its partial work instead of running on.

**Score:** 2

#### Pull Request

Give every specialist subagent a maxTurns ceiling per role

