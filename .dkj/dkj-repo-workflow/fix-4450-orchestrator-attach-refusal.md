## fix/4450-orchestrator-attach-refusal

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

#4450: in a no-repo claude.ai session, an unprompted `add_repo` for the source repo was refused by the
auto-mode classifier as `[Unauthorized Access]`, and went through after the owner asked for it. The
orchestrator skill's REST filing section did not say so, or what to do next. One paragraph there.

### CREATE

- [x] `plugins/dkj-subagents/dkj-subagents-alpha/skills/orchestrator/SKILL.md`: a paragraph under
  "Filing where GraphQL is refused". In a no-repo session, attaching the repo may be refused until the
  owner asks. Ask once, as one menu option (shape B), and do not retry unprompted. Keep the finding
  written out in the reply meanwhile. The standing fix is a preferences line; that it satisfies the
  classifier on its own is stated as unmeasured.

### TEST

- [x] Docs only; the paragraph cites #4450 as its measurement and adds no link outside this repo's own
  tracker. The gates run in `ship-pr`.

### DEPLOY: fix/4450-orchestrator-attach-refusal

The orchestrator skill now says that in a session with no repo, attaching the source repo can be refused
until the owner asks for it, and that the session then asks once instead of retrying or dropping the
finding.

**Score:** 2

#### What makes this deploy extra special

In a claude.ai chat running the orchestrator skill, a refused `add_repo` no longer reads as a ban on
filing upstream: the session asks you once to approve the connection. A line in your preferences such as
"report lessons upstream to DKJ-Solutions/dkj-marketplace" is named as the standing request, but nobody has
yet measured whether the classifier accepts that line on its own.

**Score:** 2

#### Pull Request

Orchestrator skill: name the add_repo refusal in a no-repo session and what to do next

