## docs/git-holds-code-not-data

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

Record which content belongs in git in every DKJ-Solutions repo, so data the owner edits as a user of an
app is kept out of the branch + PR cycle from the start rather than moved out after it has slowed a repo
down. The how already exists (`move-data-to-onedrive`, #4320); this is the what.

### CREATE

- [x] Tessa: a third chapter, "what belongs in git", in the `dkj-repo-workflow-dkj` extension's `CLAUDE.md`
- [x] Tessa: `move-data-to-onedrive` names that chapter as the rule deciding which data moves
- [x] Edith: copy edit of both changes

### TEST

### DEPLOY: docs/git-holds-code-not-data

Every DKJ-Solutions repo now has a written rule for what belongs in git. Git carries what decides how an
app works: code, config, tests and their fixtures, and the docs about that code. Content the owner keeps
up as a user of the app (dossiers, notes, exports, personal data) lives in OneDrive, because each edit to
it would otherwise pay the full branch, PR and CI cycle. The rule is a chapter of the
`dkj-repo-workflow-dkj` extension's `CLAUDE.md`, with two quick tests: work a developers-team specialist
builds or tests belongs in git, and work only a core-team specialist does most likely does not. The
`move-data-to-onedrive` skill now points at it as the rule deciding which data moves.

**Score:** 3

#### What makes this deploy extra special

Sessions in every DKJ-Solutions repo now steer data that is edited as a user out of git, so updating a
dossier or a note no longer waits on a pull request.

**Score:** 3

#### Pull Request

Rule: git holds what builds the app, not the data it is used for

