## docs/ai-radar

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

Maikel asked for a place to keep AI and Claude Code news from social feeds and team chats, and to
hold each item against our own setup to find the gaps. Chosen: a folder in this repo (over issues
only), since the plugins are the setup being compared against.

### CREATE

- [x] `ai-radar/README.md`: purpose, entry format, the five verdicts, how a gap becomes an issue
- [x] `ai-radar/claude-code.md`, `models-and-api.md`, `ecosystem.md`: the three topic files, empty
- [x] Rebecca's lens: why the radar is a folder while research still lands on issues
- [x] Sylvester's lens, repo layout: the new root folder and why it sits at the root

### TEST

- [x] Lint and suites run by open-pr

### DEPLOY: docs/ai-radar

A new root folder, [`ai-radar/`](../ai-radar/README.md), keeps a running log of AI and Claude Code
news. Each entry is held against what the plugins already ship and gets a verdict: `Covered`,
`Partly`, `Gap`, `Not for us` or `To assess`. A `Gap` is filed as an issue and the entry cites it, so
the radar turns news into work on the tracker. Rebecca's lens says why this folder does not break her
rule that research lands on issues, and Sylvester's repo layout lists it.

**Score:** 2

#### What makes this deploy extra special

N/A: the folder sits outside `plugins/`, so nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

AI radar: a knowledge base of AI and Claude Code news, held against our own setup

