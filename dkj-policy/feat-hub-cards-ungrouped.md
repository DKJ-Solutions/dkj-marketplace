## feat/hub-cards-ungrouped

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

- [x] Drop the heading-less `.grid-3` surface around the hub home page's card links, keeping three to a row (the owner, November 2, 2026)

### CREATE

- [x] `repo-hub-page.ps1`: the cards in a `.ph-cards` of the page's own layer -- the `.grid-3` layout and its step-downs, without the framed surface

### TEST

- [x] `dev-preview-sessionstart.tests.ps1` pins the new form; 427 passed, 0 failed
- [x] Looked at by the owner on a preview served from the branch

### DEPLOY: feat/hub-cards-ungrouped

The hub's home page no longer wraps its card links in a framed `.grid-3` with no heading above it. The cards
stand three to a row straight on the page, in a `.ph-cards` of the page's own layer that takes `.grid-3`'s
columns and step-downs without its background and padding: a framed group with no heading groups nothing.

**Score:** 2

#### What makes this deploy extra special

Every repo's toolbox home page looks different the moment it is opened: the cards stand on the page instead of
inside a grey panel.

**Score:** 2

#### Pull Request

Hub home page: the cards three to a row without a grid surface

