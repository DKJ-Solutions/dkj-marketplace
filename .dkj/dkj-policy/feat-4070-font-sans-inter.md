## feat/4070-font-sans-inter

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

Closes #4070: the owner wants one family on every device, Inter (the Figma `font-family/sans`), self-hosted, behind a `--font-sans` token. Vendoring the font into consumer copies (pin, checksum, skill table) is #4075.

### CREATE

- [x] `InterVariable.woff2` (rsms/inter v4.1, weights 100 to 900) and `LICENSE-Inter.txt` (SIL OFL 1.1) beside `house-style.css`
- [x] `house-style.css`: an `@font-face` for Inter, `--font-sans` next to `--font-mono`, and `var(--font-sans)` at the four hard-coded `system-ui` sites
- [x] `serve-general-pages.ps1` and `serve-consumer-dashboard.ps1` serve `/InterVariable.woff2` beside the stylesheet
- [x] Brand-book README: the font-family row and how-to-use step 1

### TEST

- [x] Browser on the House style page: `body` and `h1` compute to `--font-sans`, `document.fonts` reports Inter `loaded`, `/InterVariable.woff2` 200 `font/woff2`
- [~] The owner looks at the House style page in Inter -- not done as a separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-14 without one.

### DEPLOY: feat/4070-font-sans-inter

The house stylesheet now sets all text in Inter, the same family on every device, through a new `--font-sans` token; it was the device's own system font (Roboto, Segoe UI or SF). The font ships as `InterVariable.woff2` beside `house-style.css`, and where the file is absent the system stack takes over ([#4070](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4070)).

**Score:** 3

#### What makes this deploy extra special

Every page Admin renders reads in Inter after taking this version, so a Figma design and the screen show the same letters. An app that vendors the brand book keeps the system font until it copies the font file too (#4075).

**Score:** 3

#### Pull Request

house-style: Inter as the house family, behind a --font-sans token

