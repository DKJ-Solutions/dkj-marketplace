## feat/4497-task-card-short-note

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

Issue #4497 (inbound): `inbox-sweep` step 3.3 says to write facts and a `Bron:` line but not where on a
task card, so the sweep fills the card's one short text property. Verified against the tree: neither the
skill nor Ian's manual names the card's page body. Repair: the rule in Ian's manual (every card writer)
and a pointer to it in the skill's step 3.3.

### CREATE

- [x] Ian's manual (`specialist-04-03-manual.md`): a task card's short text property holds one line; facts and source lines go in the page body or the linked dossier.
- [x] `inbox-sweep` step 3.3: on a task card, facts and source lines go in the page body; a follow-up mail goes at the top of that body.

### TEST

- [x] Doc-only change; the plugin-integrity and suite gates run through `ship-pr`.

### DEPLOY: feat/4497-task-card-short-note

A task card's short text property now holds one line, what the owner has to do, and its facts, source
lines and URLs go in the card's page body. The rule is in Ian's manual for every card writer, and
`inbox-sweep` step 3.3 applies it to a card the sweep fills (#4497).

**Score:** 2

#### What makes this deploy extra special

A lifehub owner whose inbox sweep files action cards gets a board that reads as one line per card,
instead of a short note that grows a paragraph with raw mail URLs on every follow-up mail.

**Score:** 3

#### Pull Request

inbox-sweep and Ian: a task card's short note holds one line, the facts go in its page body

