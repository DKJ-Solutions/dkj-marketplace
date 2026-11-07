## docs/remove-ai-radar

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

The owner decided the AI knowledge base belongs in `dkj-lifehub` rather than here, so the folder
added in #3863 goes again. On one condition (Maikel, November 7, 2026): this repo keeps a clear line
to that knowledge base, because the items are still to be used here and held against the current
setup. So the folder is replaced by a repo-local skill that reads the radar from the lifehub checkout.

### CREATE

- [x] Remove `ai-radar/`
- [x] Rebecca's lens: drop the radar exception, so "no research folder" stands unqualified again
- [x] Sylvester's lens, repo layout: drop the `ai-radar/` bullet
- [x] `scripts/dashboard/ai-radar.ps1`: find the lifehub through the register, find the AI dossier by its shape, list the inbox (`-All`: every item with its verdict)
- [x] `.claude/skills/ai-radar/SKILL.md`: how to go through the radar here, where a gap is filed, and that verdicts are written back in the lifehub
- [x] Fixture tests in `consumer-dashboard.tests.ps1`, beside repo-session's

### TEST

- [x] `consumer-dashboard.tests.ps1`: 250 passed, 0 failed
- [x] Run against the real lifehub checkout: it finds the dossier and reports 0 items (the dossier is still empty)
- [x] Lint and suites run by open-pr

### DEPLOY: docs/remove-ai-radar

The AI radar added in #3863 leaves this repo: the owner keeps the AI knowledge base in `dkj-lifehub`
instead. This repo keeps a line to it, the repo-local `ai-radar` skill: its script finds the
lifehub checkout through the register, lists the items still to be assessed, and the skill says how
to hold them against this tree, file a gap here and write the verdict back in the lifehub. Rebecca's
lens and the repo layout in Sylvester's lens are back to what they said before.

**Score:** 1

#### What makes this deploy extra special

N/A: the folder sat outside `plugins/`, and the new skill is repo-local, so nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

Move the AI radar to the lifehub, and read it from here with the ai-radar skill

