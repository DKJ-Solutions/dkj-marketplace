## fix/4460-preference-line-add-repo

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

Inbound #4460: `working-profile.md` said a standing preference line stands as the owner's request to
attach the marketplace repo; the measurement on #4460 says the classifier still refuses. Verified on
pickup: `working-profile.md` made the claim, `SKILL.md` called it unmeasured, so the two disagreed.

### CREATE

- [x] `skills/orchestrator/working-profile.md`: the preference line no longer claims to stand as the
  attach request; it cites the measurement and points at the skill.
- [x] `skills/orchestrator/SKILL.md`: try the attach once before saying there is no connection; the
  preference line is measured as not enough; the action-naming line is named as the unmeasured next
  candidate, to be recorded on #4460.

### TEST

- [x] Doc-only change in `dkj-subagents-alpha`; the gates run in `ship-pr`.

### DEPLOY: fix/4460-preference-line-add-repo

The orchestrator skill's chat guidance now says a standing preference line does not make the classifier
allow attaching the marketplace repo, as measured, where `working-profile.md` said it did.

**Score:** 2

#### What makes this deploy extra special

In a claude.ai chat without a repo, Chris now tries attaching the marketplace repo once before saying
there is no connection, and asks you once after a refusal. Your preferences page no longer promises that
a "report lessons upstream" line spares you that question.

**Score:** 2

#### Pull Request

Orchestrator skill: a preference line does not make the classifier allow add_repo
