## fix/4278-rest-filing-fallback

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

#4278, measured in a Claude Code cloud session: `gh issue create`/`list` is refused there (GraphQL
unavailable), the REST form works, `gh auth status` reads invalid until the repo is attached, and the
orchestrator skill page cited the retired repo name a no-repo session would attach first.

### CREATE

- [x] `skills/orchestrator/SKILL.md`: seven `DaveKJohn/claude-code-specialists` links now cite `DKJ-Solutions/dkj-marketplace`; new section "Filing where GraphQL is refused" with the REST file/list/search lines and how to tell a tracker is reachable.
- [x] Chris's manual: a pointer to that section beside the filing-inward passage.
- [~] The other `gh issue create` citations stay: they run in desktop sessions, where GraphQL works.

### TEST

- [x] Docs only; the full gate runs in `ship-pr`.

### DEPLOY: fix/4278-rest-filing-fallback

The orchestrator skill page now cites the live repo name, and says how to file where `gh issue create`
is refused because GraphQL is unavailable (a Claude Code cloud session): through `gh api` against the
REST endpoints, after checking reachability with a REST read rather than `gh auth status`.

**Score:** 2

#### What makes this deploy extra special

A cloud session that finds something to report can now file it inbound instead of concluding there is no
tracker.

**Score:** 2

#### Pull Request

A session where GitHub GraphQL is refused files through the REST form, and the orchestrator skill cites the live repo name

