## feat/lens-page-rendered-markdown

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

Maikel asked for the lens page on the hub to be made pretty. It showed the lens file raw in a `<pre>`.

### CREATE

- [x] Lift the release notes' markdown renderer out of its template into `scripts/release/markdown-render.js`, inlined back at `@@MARKDOWN_RENDERER@@` by the builder, registered as a mirrored pair
- [x] Render the lens page with that same renderer: the file's name as h1 and crumb, as its card reads; frontmatter and the lens's own # title out of the body and any other # demoted to ##, so the page has one h1 (#3745 for the house rule), raw text kept in a `<noscript>`, the card capped at 800px
- [x] Plugin scripts README row for the new shared file

### TEST

- [x] `dev-pages.tests.ps1` 560/0, `shared-scripts.tests.ps1` 1217/0, `check-plugin-integrity.ps1` 0 errors
- [x] The served page rendered headlessly through the inlined renderer: headings, lists, a table, blockquotes and code all come out
- [~] The owner's look in the browser: a visible result, so the branch waits for it instead of merging

### DEPLOY: feat/lens-page-rendered-markdown

A specialist lens's page in the toolbox (`/ai/claude/specialists/lenses/<name>`) now shows the lens as formatted
text instead of raw markdown: its title, headings, lists, tables, quotes and code in the
house `.prose` style. It is drawn by the same small renderer the release-notes pages use, which moved out of their
template into `scripts/release/markdown-render.js` so both pages inline one file rather than each carrying a
renderer of its own. A reader without JavaScript still gets the raw text.

**Score:** 3

#### What makes this deploy extra special

Anyone who opens a lens in their toolbox reads it as a formatted document rather than as source.

**Score:** 2

#### Pull Request

Render a specialist lens's page as formatted markdown

