## docs/3777-card-shape-rule

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

Part 1 of #3777 only, as the owners decided on November 3, 2026: the decision rule as a table in the
brand book README's "Page patterns". No structural check (the retired `heading` check stays retired) and
no per-stack reference component.

### CREATE

- [x] A "Which shape a page's cards take" table opens "Page patterns" in `plugins/dkj-policy/assets/dkj-brandbook/README.md`; its flat-list row points at THE card, which settles the clash with the overview rule's "no `h2` or `h3` link inside the card".

### TEST

- [x] The table's anchors resolve to existing headings in the same README; the classes it names (`.grid-3`, `.grid__head`, `.grid__full`, `.card__sub`) exist in `house-style.css`.

### DEPLOY: docs/3777-card-shape-rule

The brand book README's "Page patterns" now opens with a table that says which shape a page's cards take for what the page holds: a flat list of pages is one `.grid-3` of card links with no head, a grouped list puts each group's `h2` inside its grid as the `.grid__head` with `h3` cards, a few subject cards each take an `h2`, a document of more than four sections becomes an overview with a page per section, and a group's empty state sits inside its own grid as a `.grid__full` card. The parts were each defined before, but not when to use which, and a consumer's pages were correct by every token check and wrong by eye in both directions. No check holds the table.

**Score:** 2

#### What makes this deploy extra special

A session building a page in any DKJ-Solutions repo has one rule to follow for card and heading structure, instead of the owner correcting each page by eye.

**Score:** 2

#### Pull Request

Brand book: a decision rule for when headings group cards

