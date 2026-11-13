## docs/4051-content-product-lead

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

Inbound #4051 from dkj-lifehub: the owner set a news app as that product's model and decided an intro
paragraph is allowed there (November 13, 2026). Rule 5 (#3585) forbade one in every DKJ-Solutions
product. No lint reads rule 5, so the exception is text: the rule in the core README and its restatement
in the `dkj-brandbook` skill. A repo opts in with one line in its own facts rule.

### CREATE

- [x] Core brand-book README, rule 5: the content-product exception, its terms, and how a repo declares it
- [x] `dkj-brandbook` skill: the same exception, pointing at rule 5

### TEST

- [x] The gates `ship-pr` runs (docs only; no lint reads rule 5)

### DEPLOY: docs/4051-content-product-lead

Brand-book rule 5 (no intro paragraph under a page's `h1`) gains one opt-in exception: a **content
product**, whose pages brief a reader as a news app does, may carry one plain `<p>` of one or two
sentences under the `h1` where the page sums up content for a reader. Its tool and admin pages keep the
strict rule. A repo opts in with the line `Content product (brand-book rule 5): yes.` in its own facts
rule; without it the strict rule holds. The core README's rule 5 and the `dkj-brandbook` skill both
carry it.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product built as a reader's briefing, such as dkj-lifehub, may now open a summary page
with a short lead, once its repo declares itself a content product.

**Score:** 2

#### Pull Request

Brand book rule 5: a content product may carry a short lead under its h1
