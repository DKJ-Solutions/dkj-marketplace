## feat/admin-figma-wireframes

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

Dave, November 12, 2026: from now on the Figma wireframes rank highest for Admin's layout -- the
*Wireframes* page of the `dkj-brandbook` Figma file (key `w44J5aQPeST96RJ71vU3ev`, node `5-3`). This
branch carries round 1 (the shell every Admin page shares, and the Home page) and round 2 (Goals and Today,
filled and empty), both judged together before the merge.

### CREATE

- [x] Desktop shell in `house-style.css` rebuilt on the wireframe's structure: full-height sidebar with a brand row, search, sections and Settings at the foot; a bar over the main pane only; a page header (`.page-head`); room around the content; the link table in a rounded, bordered frame
- [x] `Format-AdminShellOpen` draws the brand row and wraps each nav section in `.nav-section`
- [x] Home draws the page header (the repo's name and the lead line) and the shorter source note
- [x] The airsquats toast stands beside the sidebar, as the wireframe places it
- [x] The fit alarm accepts the page header's `h1`
- [x] Brand book README states the new hierarchy and the changed layer rules
- [x] Round 2: every Admin page's title is the page header (.page-head) at the top of the pane body; only a -NoColumn page keeps the toolbar
- [x] Round 2: .empty-state and Format-AdminEmptyStateHtml with a copy-prompt button; Goals and Today draw it when empty
- [x] Round 2: Goals rebuilt on the wireframe (goal card, Now box, Next cards, milestone rows, '+ Plan a goal')
- [x] Round 2: Today rebuilt on the wireframe (date beside the h1, hours planned at the right, day goal card, two columns with The plan, What got done, Not today, The week)

### TEST

- [x] Every suite touching the Admin renderers green: dayplan 74, dev-pages 752, dev-preview-sessionstart 390, goals 62, stopwatch 318, 0 failed; check-plugin-integrity 0 errors. The goals suite caught the goal line counting items under a "milestones" label; it now counts milestones done, as the wireframe does
- [x] Goals and Today, filled (sample model) and empty (this machine), screenshotted headless at 1440 wide and compared against wireframe frames 8:174, 8:328, 9:395 and 9:514
- [x] Home served from the working tree and compared by eye against the wireframe frame `8:2`: structure matches; the wireframe's grey icon placeholders and two empty bar actions are not drawn, since there is nothing to put in them yet

### DEPLOY: feat/admin-figma-wireframes

Admin now follows the Figma wireframes, which rank above the brand book for Admin's layout from this release on:
a full-height sidebar with a brand row and Settings at its foot, a bar over the main pane only, and every page
opening on a page header. Home shows the repo's name over a framed table of pages; Goals shows each goal as a card
with one Now step, the next three and its milestones; Today shows the day goal, the plan beside the week, and what
got done. An empty Goals or Today page says what will appear and offers one button that copies the prompt to fill it.
**Score:** 3

#### What makes this deploy extra special

The source of truth for Admin's layout moved out of the stylesheet and into Figma, so the next change
to Admin starts from the wireframe, not from the shell's old "compact, no cards" rule.
**Score:** 3

#### Pull Request

Admin follows the Figma wireframes: shell, Home, Goals and Today

