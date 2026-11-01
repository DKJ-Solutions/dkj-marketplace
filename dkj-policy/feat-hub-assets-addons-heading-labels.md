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

### TEST

- [x] `dev-pages.tests.ps1` green (543 passed, 0 failed)
- [ ] The owner has looked at /marketplace/dkj-policy and its brand book's Color page on the hub

### DEPLOY: feat/hub-assets-addons-heading-labels

The hub's dkj-policy page now says what each section is to a repo that installs it: its house-style assets are headed **Assets (Always on)**, and its add-ons **Add-ons (Optional)**, so a reader no longer has to guess which part comes with the plugin and which is a choice. The brand book's Color page sets its series and status colours under one heading, **Stats & Status**, where it had two.

**Score:** 2

#### What makes this deploy extra special

The hub is this repo's own developer page; a user of the plugins never sees it.

**Score:** N/A

#### Pull Request

The hub's dkj-policy pages relabel their sections: Assets (Always on), Add-ons (Optional), and Stats & Status on the Color page

