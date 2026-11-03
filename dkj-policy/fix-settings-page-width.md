## fix/settings-page-width

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

### CREATE

- [x] `Format-HubSettingsPageHtml` (`hub/lib/general-pages-lib.ps1`): a Width group under Theme, the house `.seg` with Fluid / Phone / Full through `DKJTheme.setWidth`; the lead and the hub card's sub name the width too; both toggles `--spacing-11` tall with every option `--spacing-28` wide, on a `--bg-5` border
- [x] The house palette (`house-palette-lib.ps1`) gains `--bg-5`, one paper step past `--bg-4`; `build-house-palette.ps1 -Apply` wrote it into every theme line of `house-style.css`, and the specimens page and the brand book README show it

### TEST

- [x] `dev-pages.tests.ps1`: three asserts pin the Width group, its wiring and its place after Theme (574 passed)
- [x] Served from the branch on port 4892: `/settings` renders the Width group
- [x] `house-palette.tests.ps1` (161 passed) holds thirteen tokens and five ordered paper steps; the stylesheet diff adds `--bg-5` and changes no other value

### DEPLOY: fix/settings-page-width

The toolbox's Settings page offers the page width again -- Fluid, Phone or Full -- under the theme. It
lived in the header's settings button, and when that button went the width choice went with it, so
the page could no longer be widened or narrowed from anywhere.

The house style also gains a fifth paper token, `--bg-5`: one step past `--bg-4`, a little lighter on a dark
theme and a little darker on a light one, computed for all twelve themes. No existing colour moved.

**Score:** 3

#### What makes this deploy extra special

Whoever uses the toolbox can switch its page width again, which they lost when the header's settings
button was removed. An app on the house style can now use a fifth paper step, `--bg-5`.

**Score:** 3

#### Pull Request

Settings page gets the page-width choice back, and the house style a --bg-5

