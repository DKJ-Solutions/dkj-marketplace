## feat/docs-coverage-drop-tooltips

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

The owner (November 9, 2026): the "?" icons in the Docs coverage table go, now that each row's info icon opens
a popup carrying everything they explained. Then: the Potential line goes too, and Impact takes over as the one
measure of a page's value. And the popup's "Why consider" heading becomes "Advice", with the advice and its reason under it, so the Advice row in the facts above it goes. Last, an Open page's Note joins that Advice block, as one running paragraph. And the popup's two fact lists become one Overview, with Advice an h2 of its own.

### CREATE

- [x] `docs-coverage-lib.ps1`: drop the "?" beside an item's name, beside a Declined status, beside a docs page's title and beside its status, with their tooltips and the hover script that opened them; the sort no longer strips a "?" from a cell
- [x] `docs-coverage-catalog.ps1`: drop Potential from all 46 Open pages; `docs-coverage-lib.ps1`: drop its line from the Details popup
- [x] `docs-coverage-lib.ps1`: the popup's "Why <advice>" heading reads "Advice", and the paragraph under it starts with the advice itself, then why; the Advice row leaves the "How this repo stands" facts
- [x] `docs-coverage-lib.ps1`: on a page with advice, the Note and the advice are one Advice paragraph (the note, "Our advice: <advice> it.", then why); a page without advice keeps its Note
- [x] `docs-coverage-lib.ps1`: "Where it sits" and "How this repo stands" are one Overview h2 with one facts list, for items and docs pages alike; Advice is an h2 after the Note and Evidence
- [x] Checked that every tooltip's text is already in the row's Details popup: the one line, the idea and the docs check; why declined; the note, evidence, potential and advice; the docs' own description

### TEST

- [x] `dev-pages.tests.ps1`: the asserts on the "?" and the tooltips now read the Details popup instead, and hold that no cell carries a "?" or a tooltip; the Potential asserts now hold that no page carries one and the popup shows none (738 passed)
- [x] The product server's /docs-coverage shows 0 "?" buttons and a Details icon on every row

### DEPLOY: feat/docs-coverage-drop-tooltips

Admin's Docs coverage table no longer puts a "?" beside a row's name or status. Each row's info icon opens one
popup that already holds everything those tooltips said, so the table reads as plain cells plus that one icon. The popup's Potential line, 1 to 4, is gone with it:
Impact, Tier-1 to Tier-8, is now the one measure of how much a docs page matters here. An Open page's popup puts its reasoning under one
Advice heading, starting with Adopt, Consider or Skip, rather than under "Why consider", and no longer repeats it as a row in the facts above. That block also carries the page's note, which was a
separate Note block, so what the repo has, the advice and why read as one running paragraph, under an Advice h2 of its own.
The popup's "Where it sits" and "How this repo stands" are now one Overview list.

**Score:** 2

#### What makes this deploy extra special

The Docs coverage page belongs to this repo's own Admin and ships to nobody.

**Score:** N/A

#### Pull Request

Docs coverage: drop the question-mark tooltips, the Details popup carries it all

