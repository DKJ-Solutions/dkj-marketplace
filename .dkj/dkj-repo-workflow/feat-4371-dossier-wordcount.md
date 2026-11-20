## feat/4371-dossier-wordcount

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

Closes #4371. Points 1-3 of the issue's proposed shape are built. Point 4 (a scheduled daily sweep) was
optional, and is covered by the skill's manual recount mode instead of a schedule.

### CREATE

- [x] `count-words.ps1` in a new lifehub skill `dossier-wordcount`: the one counting rule
- [x] The skill page: settings from the owner's Notion (`Instellingen dossier-wordcount`), mode 1 after a write, mode 2 recount
- [x] Ian's manual and agent def: a dossier write ends with its recount
- [x] `inbox-sweep`, `ai-radar` and `agenda` call it after a dossier write

### TEST

- [x] `scripts/tests/dossier-wordcount.tests.ps1`: 24 asserts green, after Victor's review (prose comparisons were eaten as tags) and Edith's copy edit
- [x] `check-plugin-integrity.ps1`: 0 errors

### DEPLOY: feat/4371-dossier-wordcount

A new lifehub skill, `dossier-wordcount`, with one shared counter script and its test suite. Ian's
manual and agent def, and the three skills that write into a dossier, now end a dossier write with it.

**Score:** 2

#### What makes this deploy extra special

A dossier's word-count property in a life hub now follows the page: Ian, `inbox-sweep`, `ai-radar` and
`agenda` recount it after every write into a dossier, and name a page that crosses the owner's split
threshold. The property name and the threshold come from a settings page in the owner's Notion
(`Instellingen dossier-wordcount`), which the owner creates once. A recount mode catches edits made by
hand in Notion.

**Score:** 3

#### Pull Request

lifehub: keep a dossier's word count in sync after every write

