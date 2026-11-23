## feat/4382-tip-check-skill

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

Closes #4382. The owner's tips are saved by `ai-radar` (lifehub plugin), but the judging half is broken
(#4381) and served one repo only. The owner placed the judging skill in the core team, where both
specialists it needs live; the core team ships no script, so it is a procedure.

### CREATE

- [x] `tip-check` skill in `dkj-subagents-alpha`: claim, what we have (cited path), is the problem ours, cost, advice, Marlowe's red-team, filing
- [x] Rebecca's and Marlowe's manuals name it; the plugin description lists it
- [x] The lifehub `ai-radar` skill points its verdict pass at `tip-check`

### TEST

- [x] `check-plugin-integrity.ps1`: 0 errors (a cross-plugin link written absolute)

### DEPLOY: feat/4382-tip-check-skill

A new core-team skill, `tip-check`, owned by Rebecca with Marlowe red-teaming. Rebecca's and Marlowe's
manuals and the plugin description name it, and the lifehub `ai-radar` skill hands its verdict pass to it.

**Score:** 2

#### What makes this deploy extra special

Share a tip from your feed (a post, a link, a pasted text) and ask whether it is worth it: `tip-check`
holds it against your own setup (your `.claude/`, your enabled plugins, and Claude Code's own features),
cites what you already have, asks whether the problem actually occurs for you, counts the cost, and
advises Build, Later or Skip. Marlowe then tries to prove that advice wrong before you see it. Gaps worth
building are filed as a feature issue.

**Score:** 3

#### Pull Request

tip-check skill in the core team

