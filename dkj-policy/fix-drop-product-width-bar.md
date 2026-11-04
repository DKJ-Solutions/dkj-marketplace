## fix/drop-product-width-bar

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

Dave, November 4, 2026: VS Code's Simple Browser already has a device emulator, so the three width toggles
added today (#3796) are not needed. Option 1 of three: the product gets one width, full, like the Toolbox.

### CREATE

- [x] The brand book's `house-theme.js`, `house-style.css` and README back to their state before #3796: no
      `DKJTheme.widthBar`, no `.width-bar` classes
- [x] The product home and consumer pages draw no width bar and pin `full` through `Get-ToolboxWidthScript`;
      `Format-GeneralPageHtml` pins it on a `product`-tagged page too
- [x] The product's Settings page drops its Width group; `Get-SettingsPageParts` loses its `-Widths` switch
- [x] The owner's look at the product (http://localhost:4871/): no bar above the header, no Width on Settings

### TEST

- [x] `dev-pages`, `consumer-dashboard` and `dev-preview-sessionstart` suites green

### DEPLOY: fix/drop-product-width-bar

The width bar above the product's site header is gone again, with `DKJTheme.widthBar` and its
`.width-bar` classes in the brand book, both unreleased. The product's own pages now hold one width,
`full`, as the Toolbox does, and the product's Settings page offers only the theme. Another screen size
is judged in VS Code's Simple Browser's own device emulation instead of a toggle on the page.

**Score:** 2

#### What makes this deploy extra special

N/A: the width bar and the product's width choice never reached a release, so no user of a release loses anything.

**Score:** N/A

#### Pull Request

The width bar is gone; the product stays full, like the Toolbox

