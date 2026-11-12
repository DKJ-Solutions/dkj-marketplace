## fix/4025-shell-pattern-wireframes

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

#4025: `feat/admin-figma-wireframes` (#4026) rebuilt Admin's desktop shell on the Figma wireframes, but the
brand book's stylesheet-only reference (`patterns/admin-shell.html`) and its "Desktop shell" specimens still drew
the old markup. Bring both to the markup `Format-AdminShellOpen` serves now. A visible result: parked for the
owner's look, no PR until then.

### CREATE

- [x] `patterns/admin-shell.html`: brand row, every nav group a `.nav-section` (the foot one with `.shell__nav-foot`), the page header (`.page-head`, the `h1` with the filter and button at its right end) inside a `.shell__body` in place of the toolbar; the header comment names the toolbar's one remaining use
- [x] `specimens.html`: both Desktop shell specimens in the same structure; the page header's title is a `.spec-page-title` paragraph at the h1's size, since the fragment already sits under a page `h1`
- [x] `house-style.css`: `.shell__list` takes the pane's flexible row (`grid-row: 2`) itself, so a list with no toolbar over it scrolls from the stylesheet alone, as Admin's own `.tb-scroll` already made it do on served pages

### TEST

- [x] Pattern screenshotted headless at 1300 x 900 and the specimens page on the product (`/plugins/dkj-policy/dkj-brandbook/desktop-shell`): both show the wireframe structure, and the short specimen's list scrolls
- [ ] The owner's look at the pattern and the specimens

### DEPLOY: fix/4025-shell-pattern-wireframes

The brand book's Admin shell reference page and its Desktop shell specimens now show the shell as Admin draws it
since the Figma wireframes: a brand row at the top of the sidebar, grouped navigation sections, and a page header
in place of the toolbar. A repo building its own Admin page from the reference gets the current structure, and a
list in the shell scrolls from the stylesheet alone.
**Score:** 2

#### What makes this deploy extra special

Closes a gap the wireframes branch itself left: the reference the README points to showed a shell Admin no
longer draws.
**Score:** 1

#### Pull Request

Brand book: admin-shell pattern and Desktop shell specimens follow the Figma wireframe structure

