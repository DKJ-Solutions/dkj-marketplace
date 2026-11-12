## feat/4006-working-profile

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

#### The three parts #4006 asks for

The profile lives in the person's own `~/.claude/CLAUDE.md`, so it travels with them and never enters a
repo. The orchestrator's body gets one short rule, and the template sits on a page beside the orchestrator
skill. That page loads on demand, so the only always-on cost is the persona's pointer.

### CREATE

- [x] `skills/orchestrator/working-profile.md`: where a profile lives, what it may and may not change, and the template
- [x] Chris's persona: one section, "The person's working profile — how, never what", pointing at that page

### TEST

- [x] The gates run in `ship-pr`

### DEPLOY: feat/4006-working-profile

Inside this repo, nothing changes in how the gates or the release run.

**Score:** N/A

#### What makes this deploy extra special

A person can now write a working profile once, in their own `~/.claude/CLAUDE.md`, and Chris reads it in
every repo they work in. It tunes how the team works with them (how long a question is, who tests, how a
result is shown, how readily a reversible choice is asked about) and never loosens the constitution or the
safety rules. The template, and why it lives at user level rather than in a repo lens, is on
[`working-profile.md`](../../plugins/dkj-subagents/dkj-subagents-alpha/skills/orchestrator/working-profile.md)
([#4006](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4006)).

**Score:** 3

#### Pull Request

A per-person working profile the specialists read in every repo

