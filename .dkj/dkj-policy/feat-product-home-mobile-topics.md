## feat/product-home-mobile-topics

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

#### Where this comes from

The product home on `http://localhost:4870/` read as a stack of five large cards on a phone. The owner asked for it
to follow the mobile wireframes in the brand book's Figma file, as dkj-lifehub's home already does: the frame
"H1 - Home (mobiel)" (a list of topics, each a heading with its initial in a badge and its sections under it) and
the navigation frames' bottom bar. The house product layer already ships the bottom bar (`Format-BottomBarHtml`,
#4094); this product had not taken it yet.

### CREATE

- [x] `Get-ProductPages`: each page's sections as `Items` -- the owner groups under Consumers, the two top-level
      entries under Plugins
- [x] `Format-ProductHomeHtml`: below 48rem the cards and their note give way to a topic list
      (`Get-ProductHomeTopicsStyle`, house tokens only, neutral as the wireframe draws it); Admin is a heading
      without a link while it is not running
- [x] `Get-ProductBottomBar`: Home, Consumers, Plugins, then More; on the home page, every `Format-DevPageHtml`
      page and the Consumers page, whose header then drops its toggle
- [x] `/consumers` and `/consumers/dkj` no longer overflow a phone: `.dr-repos`' single column is
      `minmax(0, 1fr)`, not `1fr` (442px wide at a 375px viewport); `/docs-coverage`'s table overflow is a
      design question, filed as #4111

### TEST

- [x] `dev-pages.tests.ps1`: the topic list's headings, badges, links and sections, its breakpoint, tokens only,
      escaping (a badge is the label's first letter as written, escaped on its own), and the bottom bar on the
      home page, the Settings page and a page under Plugins; two existing asserts follow the new markup
- [x] `consumer-dashboard.tests.ps1`: the Consumers page's bar with Consumers current, and the bar's three sections
- [x] `dev-pages.tests.ps1`: the `.dr-repos` phone column is `minmax(0, 1fr)`
- [x] Every product page measured at 375px for a page wider than the screen: only `/docs-coverage` (#4111)
- [x] Seen at 390px and 1280px in a headless browser: the phone shows the topic list and the bar, the desktop is
      unchanged

### DEPLOY: feat/product-home-mobile-topics

On a phone the product follows the mobile wireframes. The home page is a list of topics instead of five cards:
Admin, Consumers (with DKJ, BWJ and Other under it), Plugins (with dkj-subagents and dkj-policy), Docs coverage and
Settings, each a heading with its initial in a badge. Every product page carries the house bottom bar -- Home,
Consumers, Plugins, and More, which opens the site menu -- so the header leaves its menu toggle out. The Consumers pages no
longer scroll sideways on a phone. A wide screen is unchanged.

**Score:** 3

#### What makes this deploy extra special

N/A -- the product server is this repo's own maintenance view, under `scripts/`; nothing a plugin ships changes.

**Score:** N/A

#### Pull Request

The product on a phone, after the mobile wireframes: the home page as a list of topics and a bottom bar on every page
