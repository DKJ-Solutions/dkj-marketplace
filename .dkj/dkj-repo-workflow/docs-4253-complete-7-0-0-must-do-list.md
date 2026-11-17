## docs/4253-complete-7-0-0-must-do-list

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

Inbound #4253: the first consumer to run the v7.0.0 note end to end found its "You must" sections short
by eight steps and wrong in one statement ("Lenses ... need no change").

### CREATE

- [x] Correct the lens statement: two lenses name a body under `dkj-subagents-alpha/personas/`, and
  `sync-roster` never rewrites an existing lens (verified in its script header).
- [x] Add the missing steps: the marketplace refresh, `permissions.allow` patterns, every CI runner
  (verified against the runner names `adopt-ci-floor` places), `Get-MojibakePaths`, repo-local helpers,
  the statusline shim (#4252), the Part 1 ordering workaround (#4251), the `dkj-subagents-alpha` update,
  the consumer register and the old install record.
- [~] The GitHub release body (`releases/github/7.x/7.0.0.md`) is left as it is: republishing a release
  is outward-facing, and it only lists what landed.

### TEST

- [x] Read back against the issue: all ten items are answered, and none of the old steps were lost.

### DEPLOY: docs/4253-complete-7-0-0-must-do-list

The v7.0.0 release note now lists every step a migration needs (#4253): refreshing the marketplace clone,
rewriting `permissions.allow` patterns, repointing all seven CI runners, re-adopting `Get-MojibakePaths`,
updating the core team past 6.x, the statusline shim, the Part 1 ordering workaround, and who updates the
consumer register. It no longer says lenses need no change: two lens headers point at a moved persona body
and have to be corrected by hand.

**Score:** 4

#### What makes this deploy extra special

A maintainer migrating a repo can follow the note alone and finish, rather than finding eight more
steps through failures.

**Score:** 4

#### Pull Request

The 7.0.0 release note's must-do list names every step a migration needs

