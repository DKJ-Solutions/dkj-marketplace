## feat/hub-rules-page

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

Maikel found `/claude/rules` on the toolbox empty: it was a group page with no members. It now reads its
cards from the repo, the way the Specialists page reads its Lenses.

### CREATE

- [x] `Get-HubRulePages` + `Get-HubSectionCards` in `hub/lib/general-pages-lib.ps1`: a Repo rules `Source` section on `/claude/rules`, holding only what is in `.claude/rules` (Maikel dropped a Constitution section read from the root `CLAUDE.md`'s imports, the same day), and `Bare`, so no heading repeats the h1 and the cards stand on the page as h2 cards
- [x] `Format-HubRulePageHtml` on a shared `Format-HubDocPageHtml`, which the lens page now uses too
- [x] The `/claude/rules/<name>` route in `serve-general-pages.ps1`, a 404 for a name the repo has no rule document of
- [x] `hub/README.md` names the Rules page's sections

### TEST

- [x] `dev-pages.tests.ps1`: the one section, the cards from a fixture (only `.claude/rules/*.md`, an imported `CLAUDE.md` not, the path-scoped note), the rule page, the 404 names -- 601 passed
- [ ] The owner's look at `http://localhost:4890/claude/rules` on this branch

### DEPLOY: feat/hub-rules-page

The toolbox's Rules page (`/claude/rules`) is no longer empty. It holds cards read from the repo, under no
heading but the page's own: a card per `.claude/rules/*.md` and nothing else, where a path-scoped rule says it loads only when
Claude touches a matching file. Each card opens on `/claude/rules/<name>` with the file rendered as a lens
page is.

**Score:** 2

#### What makes this deploy extra special

Every DKJ repo's toolbox now shows the rule files in its `.claude/rules` folder, readable in the browser.

**Score:** 3

#### Pull Request

The toolbox's Rules page lists the rules Claude works by

