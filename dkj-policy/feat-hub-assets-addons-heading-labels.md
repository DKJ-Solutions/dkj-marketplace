## feat/hub-assets-addons-heading-labels

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

The owner judges the headings on the hub's dkj-policy page by eye before this merges (visible result).

### CREATE

- [x] `Format-MarketplacePluginsPageHtml`: the Assets heading reads Assets (Always on), the add-ons heading Add-ons (Optional)
- [x] `dev-pages.tests.ps1`: the two asserts that pin those headings follow
- [x] The brand book's Color page: the Stats and Status headings become one, Stats & Status, over both cards (Maikel, November 1, 2026)
- [x] The brand book: the series slots `--cat-1` to `--cat-3` are renamed `--graph-1` to `--graph-3` in `house-style.css`, `specimens.html` and the README's current-state lines, and their specimen card Categories is renamed Graphs (Maikel, November 1, 2026); the README's history lines keep the old name
- [x] The specimen card Status and direction is renamed Status (Maikel, November 1, 2026)
- [x] The paper-2 step is wider: `Get-HousePaletteSteps` takes paper-2/paper-3 to L 0.965/0.94 on light and 0.165/0.195 on dark, rebuilt into `house-style.css` by `build-house-palette.ps1 -Apply`, with the measured figures in its comment and the README taken again (Maikel, November 1, 2026)
- [x] The Color page's Stats & Status heading is renamed Graphs & Status (Maikel, November 1, 2026)
- [x] `--muted` is renamed `--primary-muted` in the brand book, the palette model and its build, the brandbook skill and every hub page that reads it; `--muted`, `--cat-1..3` join `Get-HouseStyleRetiredTokens`, and the README gains the rename table of November 1, 2026 (Maikel). The class `.muted`, the release history, and the two pages that define a `--muted` of their own (`session-start-template.html`, `issue-dashboard-worker.js`) are left alone
- [x] `--paper-1..4` is renamed `--bg-1..4` the same way (the token, and its name in the brand book's prose), retired in `Get-HouseStyleRetiredTokens` and added to the rename table; `build-house-palette` still recognises the old names on an -Apply (Maikel, November 1, 2026)
- [x] `specimens.html`: every colour swatch (and the shadow one) carries its token's name inside it, centred, as a `<div class="spec-sample">` (a `<p>` may not sit in a `<span>`), in a text colour that reads on it in every theme: `--fg-1` on the backgrounds and the -1 tints, `--bg-1` on the primary, the greys, the text steps, `--graph-1`, `--negative-3` and the -5 steps, and black on `--graph-2`, `--graph-3`, `--positive-3` and `--warning-3`, where no house token reaches 4.5:1 in every theme (black: 5.4:1 or better) (Maikel, November 1, 2026)
- [x] `--primary-muted` takes the primary's own OKLCH hue, and chroma 0.06 on dark (0.03 on light, unchanged): a dark primary is lightened in HSL, which drifts its hue, so the grey sat at the base hue and read blue beside a violet primary (Lila `#9a97ab` H 292 is now `#a492b8` H 306; Maikel, November 1, 2026). Rebuilt, every floor still met, and `house-palette.tests.ps1` holds the grey to the primary's hue within 3 degrees
- [x] A new radius step, `--radius-4` (16px), and every hard-coded radius on the scale (4, 6, 8, 10, 12, 16px) in `house-style.css` and the hub's own layer takes its token; circles (50%), 0 and the 1-3px marks are off the scale and stay. The Radius card and the README carry the new step (Maikel, November 1, 2026)
- [x] `dev-preview-sessionstart` suite green
- [x] `check-plugin-integrity` 0 errors; `check-house-style` gate OK; `stopwatch` suite green
- [x] `dev-pages`, `check-house-style`, `house-palette`, `consumer-dashboard` suites green

### TEST

- [x] `dev-pages.tests.ps1` green (543 passed, 0 failed)
- [ ] The owner has looked at /marketplace/dkj-policy and its brand book's Color page on the hub

### DEPLOY: feat/hub-assets-addons-heading-labels

The hub's dkj-policy page now says what each section is to a repo that installs it: its house-style assets are headed **Assets (Always on)**, and its add-ons **Add-ons (Optional)**, so a reader no longer has to guess which part comes with the plugin and which is a choice. The brand book's Color page sets its series and status colours under one heading, **Graphs & Status**, where it had two. The card colour `--bg-2` stands a clearer step off the page `--bg-1` in every theme (1.09:1 to 1.10:1 on light, 1.04:1 to 1.05:1 on dark), because it was barely visible in some; `--bg-3` moves along so a card inside a group keeps its own step. And the brand book's series slots are renamed: `--cat-1`, `--cat-2` and `--cat-3` are now `--graph-1`, `--graph-2` and `--graph-3`, with the same values, the grey `--muted` is now `--primary-muted`, the four backgrounds `--paper-1` to `--paper-4` are `--bg-1` to `--bg-4`, and their specimen card is called **Graphs** instead of Categories, every colour swatch now carries its token's name inside it, the dark themes' grey `--primary-muted` sits in its primary's own hue with a little more colour (Lila's read blue), a new corner step `--radius-4` (16px) rounds the card groups, the dialog and the drawer, and every corner on the scale now reads its token instead of a hard-coded pixel value; the status colours' card is called **Status** instead of Status and direction.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions repo that takes this release's `house-style.css` and uses a series slot in its own domain layer must rename `var(--cat-N)` to `var(--graph-N)` `var(--muted)` to `var(--primary-muted)` and `var(--paper-N)` to `var(--bg-N)`, per the README's rename table of November 1, 2026: the old names are gone, with no alias, so an unrenamed use loses its colour, and the house-style gate now reports each one as a retired token. The hub's relabelled headings reach no plugin user.

**Score:** 5

#### Pull Request

The brand book renames --muted, the series slots and the paper steps, widens the paper-2 step, and the hub relabels its sections

