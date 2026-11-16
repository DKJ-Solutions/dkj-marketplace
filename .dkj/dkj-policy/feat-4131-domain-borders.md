## feat/4131-domain-borders

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

- [x] the nine decorative borders #4131 measured, each called the way #4127 called its own: none marks something pressable or typeable, so all nine go

### CREATE

- [x] `goals-lib.ps1`: the Now card stands out by a `--bg-3` fill instead of a 2px primary edge; the next tasks and every milestone (open or not) stand on `--bg-2`; the steps inside a milestone lose their rules
- [x] `today-page-lib.ps1` and `consumer-dashboard-lib.ps1`: the day's items and a repo's signals become rows of `--bg-3` fill a `--spacing-0-5` gap apart, as `.card--rows` does
- [x] `general-pages-lib.ps1`: the toolbar pane's notice loses its bottom rule (its tint separates it); the release page's `.sheet` stands on `--bg-2`
- [x] `repo-admin-page.ps1`: the code block stands on `--bg-3`, as a panel does

### TEST

- [x] `git grep` for a `<n>px solid|dashed` border in the five files finds none
- [x] this tree's Admin on port 4910 serves the new rules on `/dev/today` and `/dev/goals`
- [ ] the owner looks at Admin's Today, Goals and Repository pages and the consumer dashboard

### DEPLOY: feat/4131-domain-borders

Admin's own pages and this repo's consumer dashboard follow the brand book's rule from #4127, that a border marks
something you can press ([#4131](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4131)): the Goals page's
Now card, next tasks and milestones, the Today page's items, the repository page's code block, the release page's
sheet, the notice above a toolbar pane and the dashboard's signal rows stand on fills instead of lines.

**Score:** 2

#### What makes this deploy extra special

Admin, which every repo running this workflow opens, now reads like the rest of the brand book after #4127: no
lines left on its Goals and Today pages, the current task marked by a stronger fill rather than a coloured frame.

**Score:** 2

#### Pull Request

Admin and dashboard domain layers drop their decorative borders

