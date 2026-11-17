## feat/4240-sweep-delegates-build

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

Issue #4240, decided by the owner on November 17, 2026: delegate the build. The main loop keeps
choosing and judging, and step 3's build goes to a subagent on `sonnet`.

### CREATE

- [x] `skills/issues-sweep/SKILL.md` step 3: the build goes to the craft's subagent (or `general-purpose`
  on `sonnet`), never a fork, with a brief that forbids commit, push, PR and tracker writes; the main loop
  reads the diff and writes the branch document itself; inline where the brief outgrows the edit

### TEST

- [x] Doc-only change; `ship-pr`'s gate covers the skill's links and shape

### DEPLOY: feat/4240-sweep-delegates-build

`issues-sweep` step 3 now hands the build to a fresh subagent (#4240): the specialist whose craft the
change is, or `general-purpose` on `sonnet`, never a `fork`. Its brief forbids committing, pushing,
opening a PR and writing to the tracker. The sweep's main loop keeps the choosing, parking and
judging. It reads the returned diff before anything ships, and writes the branch document itself. A
change whose brief would be longer than the edit is still built inline.

**Score:** 2

#### What makes this deploy extra special

For whoever runs a sweep: the build, the bulk of a sweep's tokens, now runs on the cheaper subagent
model instead of the session's main model, while the judgement that needs the stronger model stays in
the main loop. Follow-up to #4233, whose page split cut what the skill loads per run.

**Score:** 3

#### Pull Request

issues-sweep: step 3's build goes to a fresh subagent on sonnet, the main loop keeps the judgement

