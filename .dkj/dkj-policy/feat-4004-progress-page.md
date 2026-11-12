## feat/4004-progress-page

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

#### Scope

Issue #4004, a first working slice rather than the whole idea: one Admin page that answers both of the
issue's questions from what is already recorded. How far: the goals of the Goals page (#3816), each as a bar
of its milestones, a closed one filled by its kind (built, or `used` / `measured` by label). How the team
ran: the Logbook's newest page of assignments, work against waiting on the owner. The owner-load signals
nothing records yet (questions asked, steps by hand, the wait between prompts) are filed as #4008 rather
than guessed at. A visible result, so the branch parks for the owner's look.

### CREATE

- [x] `apps/admin/lib/progress-lib.ps1`: the milestone kind, the team's numbers, the two cards and the page.
- [x] `goals-lib.ps1`: the query reads a milestone's labels (ten at most, not a task's), and the model carries them.
- [x] `serve-general-pages.ps1`: the `/dev/progress` route, sharing the Goals page's cache and reading the
      Logbook as `/dev/logbook` does; `general-pages-lib.ps1`: the Progress card beside Goals, and its icon.
- [x] `scripts/tests/progress.tests.ps1` (30 asserts), registered in the `pages` group; the dev-pages
      asserts that pin the list of general pages and Admin's cards follow the new card.
- [x] The Admin README names the page, its lib and its suite.
- [ ] Owner looks at the page and says whether this slice is the right shape.

### TEST

- [x] `progress`, `goals`, `dev-pages` and `logbook` suites green standalone.
- [x] Previewed against dkj-recipes (an Admin on port 4895 with `-RepoRootOverride`): goal #121 at 1 of 3
      milestones, 20 assignments, 18 chart columns. At 1300 x 900 it fits one screen, one h1, the fit alarm
      silent.

### DEPLOY: feat/4004-progress-page

A new Admin page, Progress, on `/dev/progress`, beside Goals. It reads what the Goals page and the Logbook
already hold, so nothing new is recorded and no store changes; the Goals query gains one field, a
milestone's labels.

**Score:** 3

Every repo's Admin gains a Progress card. A repo with a goal sees, on one screen, how far its milestones are,
each marked built, used or measured (a closed milestone carrying the label `used` or `measured`), and how the
team ran: its assignments, how long Claude worked, how long it waited on you, and a column per assignment.
Questions asked and steps by hand read "not recorded yet" until #4008 records them.

#### What makes this deploy extra special

**Score:** 3

#### Pull Request

Admin: a Progress page -- how far the app is, and how the team ran
