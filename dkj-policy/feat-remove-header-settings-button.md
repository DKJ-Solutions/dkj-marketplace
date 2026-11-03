## feat/remove-header-settings-button

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

Maikel, November 3, 2026: remove the settings button from the header, on both servers (toolbox on 4890 and
product on 4870). The toolbox's theme is chosen on its own `/settings` page since November 2, 2026.

### CREATE

- [x] `Format-SiteHeaderHtml` (`plugins/dkj-policy/hub/lib/general-pages-lib.ps1`) no longer mounts `#settings`; every site header on both servers is built by it
- [x] The pages' `DKJTheme.settings(...)` call stays: with no mount it returns null and draws nothing, and a page without a site header still floats its button
- [~] The `.site-header .theme-settings` rules stay in the brand book, for any app that still mounts the button
- [x] Maikel, same day: the whole `.site-header__menu` right-aligned -- `house-style.css` sets `.site-header__nav` to `justify-content: flex-end` (centred until then)
- [x] Maikel, same day: the site header pads its sides only, with the `.container`'s own side padding (the breadcrumb bar's, so the two line up; 20px for one round first), and no cell reaches past that padding any more -- the brand, the menu and the settings cell lost their negative margins; the bar keeps its 68px height through a `min-height` and stretched cells
- [x] Maikel, same day: under a site header the breadcrumb trail takes a menu cell's own padding, `--spacing-4`, so its first word stands under the app's name
- [x] Maikel, same day: under a site header each breadcrumb step is a cell the full height of the bar, as a menu link is
- [x] Maikel, same day: the site header's `.container` has no padding at all; the breadcrumb bar under it drops its side padding too, so the trail's first word still stands under the name

### TEST

- [x] `check-plugin-integrity`, `check-house-style.tests.ps1` (135) and `house-palette.tests.ps1` (161) green on the stylesheet change
- [x] `dev-pages.tests.ps1` (594) and `consumer-dashboard.tests.ps1` (241) green, their asserts flipped to "no settings button in the header"
- [ ] The owner looks at the headers on 4890 and 4870 (visible result -- no merge before that)

### DEPLOY: feat/remove-header-settings-button

The site header on the toolbox and product pages no longer carries the settings button (the gear with theme,
width and reset). The toolbox's theme is chosen on its `/settings` page; a page without a site header still
floats the button as before. The brand book's site-header menu now stands at the right instead of in the middle,
for every app that draws one, and the header has no padding of its own. Under a site header the breadcrumb trail is inset as far as the
name, so the two start on one line, and each step of the trail is a cell the full
height of its bar, as a menu link is in the header.

**Score:** 2

#### What makes this deploy extra special

A consumer running the toolbox sees a header without the gear and its menu at the right; the theme moves to the
Settings page.

**Score:** 2

#### Pull Request

Remove the settings button from the toolbox and product headers

