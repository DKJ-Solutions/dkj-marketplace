## fix/3911-admin-outside-worktree

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

- [x] The issue's first direction: skip the start where the root is not a git work tree. Admin
  describes a repository, so a folder that is none has nothing for it to show. The other direction (an
  `EVAL_*` opt-out) would need every eval case to set it, and #3643 removed opt-outs on purpose.

### CREATE

- [x] `dev-preview-sessionstart.ps1` exits silently when `git rev-parse --is-inside-work-tree` says
  the root is not a work tree. Where git is missing it carries on as before, and `-RepoRootOverride`
  skips the guard, because the suite's fixtures are plain folders.

### TEST

- [x] `dev-preview-sessionstart.tests.ps1`: a plain temp folder reached through `CLAUDE_PROJECT_DIR`
  gets exit 0, no output, nothing listening on the general port, and no state file. The full gate runs
  in `ship-pr`.

### DEPLOY: fix/3911-admin-outside-worktree

`dkj-policy`'s SessionStart hook no longer starts Admin in a folder that is not a git work tree. Every
`claude plugin eval` run used to leave an Admin server behind in its temporary workspace, which kept
the eval CLI from removing that folder (`EBUSY`). An eval run now leaves nothing running, and every
repo still gets its Admin as before
([#3911](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3911)).

**Score:** 3

#### What makes this deploy extra special

Plugin eval runs no longer leave Admin servers and locked temp folders behind.

**Score:** 2

#### Pull Request

dev-preview starts no Admin outside a git work tree

