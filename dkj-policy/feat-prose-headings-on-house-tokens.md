## feat/prose-headings-on-house-tokens

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

Maikel, November 2, 2026: `.prose` headings showed through `--prose-h1`..`--prose-h3`, which confused him; he wants only his own tokens, and then: remove the `.prose` class everywhere. He chose to have the plain markdown elements styled by the house itself (a menu, November 2). Stacked on `feat/lens-page-rendered-markdown` so both can be looked at together; that branch ships first.

### CREATE

- [x] `house-style.css`: every `.prose` rule gone, `--prose-h1`..`--prose-h3` with it; zero-specificity base rules for `code`, `pre`, `ul`/`ol`, `blockquote`, `hr` under "Running text"
- [x] `--prose-h1`..`--prose-h3` added to `Get-HouseStyleRetiredTokens`
- [x] `markdown-render.js`: a table is a `.table` in a `.table-wrap` (`.table-scroll` kept for the release-notes page)
- [x] Lens page: no `.prose`; the space between blocks set in its own page layer
- [x] Lens page: a lone `## Specific to this repo` wrapping `###` sections goes, and the headings shift so the highest is an h2 (`ConvertTo-HubLensBody`), so a lens's sections are h2s rather than one h2 over many h3s
- [x] Lens page: a list under an h2 whose every item opens with a bold lead becomes h3s over their text (`ConvertTo-HubLensLeadHeadings`), so the h3 level is used too
- [x] Lens page: the opening paragraphs before the first heading stand under the h1, outside the card, and a quote there goes (`Split-HubLensIntro`). That is an intro under the h1, which #3585 rules out for a page in general; the owner asked for it here by name
- [x] Rendered tables made stronger: `.table--accent` head, each column aligned by its markdown separator through `.col-start`/`.col-end` (a bare `.table` right-aligns every column but the first); the renderer keeps site-rooted `/` links, and a lens page turns links to other lens files into links to their pages
- [x] `specimens.html`: the prose cards replaced by a "Markdown elements" card
- [x] README: a dated section on the retirement; the reserved-class and collision lists no longer name `.prose`

### TEST

- [x] `check-house-style` 135/0, `house-palette` 161/0, `dev-pages` 568/0, `release-notes-page` 207/0, `shared-scripts` 1217/0; `check-house-style.ps1` OK, `check-plugin-integrity.ps1` 0 errors
- [x] The owner's look in the browser: Maikel looked on November 2, 2026 and said ship it

### DEPLOY: feat/prose-headings-on-house-tokens

`.prose` is retired. A rendered markdown body is plain elements, and the brand book now styles those itself:
headings are the ordinary `h1`-`h3` at `--text-h1`-`--text-h3`, and `code`, `pre`, lists, `blockquote` and `hr`
have zero-specificity base rules, so an app's own class still wins. A table is a `.table` in a `.table-wrap`, which
the house markdown renderer now writes. The three variables `.prose` set its headings through (`--prose-h1`..
`--prose-h3`) are retired tokens. The README's "`.prose` retired, November 2, 2026" says what an app moves to.

**Score:** 4

#### What makes this deploy extra special

An app that used `.prose` drops the class: its markdown takes the house look by itself, with headings at the same
sizes as everywhere else, and it sets the space between blocks in its own layout. Plain `code`, `pre`, lists,
quotes and rules anywhere in an app now take the house look too.

**Score:** 4

#### Pull Request

Retire .prose: rendered markdown takes the house's own elements
