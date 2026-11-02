## feat/hub-settings-page

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

- [x] `Get-GeneralPages`: a Settings card on `/settings`, with a gear icon of its own
- [x] `Format-HubSettingsPageHtml`: the page, its h1 Settings, then a card headed by the h2 Theme over the brand book's theme picker and its reset
- [x] `serve-general-pages.ps1`: the `/settings` route
- [x] The picker in an h3 card, Colour, in the house group the Theme h2 heads, its rows without the Light/Dark labels
- [x] `house-style.css`: one padding for every card group, `--spacing-5`, the one `.grid-3` already took; the README's stale `--spacing-3` corrected

### TEST

- [x] `dev-pages.tests.ps1`: the page list and the hub's card count updated, the Settings page asserted (578 passed)
- [x] Served from this branch on 4898: `/settings` answers 200 with the h1, the Theme h2 and the picker, and the hub links it

### DEPLOY: feat/hub-settings-page

The toolbox hub gets a **Settings** card, after Installed plugins and in the site header's menu. Its page, `/settings`, opens on an h2 **Theme** with the brand book's own theme picker and a reset under it, in an h3 card Colour -- the same choice the header's settings button makes, so the two always agree.

**Score:** 2

#### What makes this deploy extra special

The brand book gives every card group the same padding: `.grid-2` and `.card-grid` now take `--spacing-5` (20px), as `.grid-3` already did, so a two-column group no longer sits tighter than a three-column one.

Every repo running dkj-policy gets the card on its toolbox: the theme is now one click from the hub, on a page of its own rather than only behind the header's gear.

**Score:** 2

#### Pull Request

A Settings card on the toolbox hub, its page holding the theme settings

