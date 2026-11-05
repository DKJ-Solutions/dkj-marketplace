## feat/issues-sweep-names

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

Dave, November 5, 2026: the sweeps get names that read the way he thinks of them, all under one prefix.
`sweep-issues` becomes `issues-sweep` and `sweep-decisions` becomes `issues-sweep-decisions`, beside
`issues-sweep-reviews` (#3826). The released changelog and archived release notes keep the old names,
because they are history.

### CREATE

- [x] The two skill folders move, and every live reference in the tree follows: skills, `CONTRIBUTING-portable.md`, `ADOPTION.md`, Derek's lens, `repo-config.ps1` and the blueprint that mirrors it, and the comments in `claim-issue` and its plugin mirror (still byte-identical).
- [x] `logbook-lib.ps1`: the hub's sweep regex accepts the old and the new name, so a run recorded as `/sweep-issues` is still cut per issue.
- [x] Each renamed page says what it was called until today.

### TEST

- [x] `logbook.tests.ps1`: two new asserts. A run under the former name is still a sweep, and `/issues-sweep-reviews` is not mistaken for one. 76 passed.
- [x] `claim-issue.tests.ps1` 613 passed; `check-plugin-integrity.ps1` 0 errors.

### DEPLOY: feat/issues-sweep-names

The two sweep skills are renamed so that all three share one prefix: `sweep-issues` is now `issues-sweep`, and `sweep-decisions` is now `issues-sweep-decisions`, beside `issues-sweep-reviews`. Every page that names them follows, and each renamed page says what it used to be called. The hub's logbook still recognises a sweep recorded under the old name.

**Score:** 2

#### What makes this deploy extra special

Anyone who types `/sweep-issues` or `/sweep-decisions` must type `/issues-sweep` or `/issues-sweep-decisions` after updating. The old names no longer exist as commands.

**Score:** 4

#### Pull Request

Rename sweep-issues to issues-sweep and sweep-decisions to issues-sweep-decisions
