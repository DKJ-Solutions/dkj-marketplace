## docs/4399-task-card-sourced-fields

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

Inbound #4399: a bulk move of dossier next steps into task cards gave cards a deadline and generic SMART
answers the owner never set. Verified on pickup: no manual or skill in `dkj-subagents-lifehub` carries
the rule; `inbox-sweep` says "a deadline if there is one", `agenda` already uses the action's moment.

### CREATE

- [x] Ian's manual: a hard rule that a task card's Deadline and SMART answers come from the owner or a
  source, and stay empty otherwise.
- [x] `inbox-sweep`: one paragraph after the sort table pointing at that rule.

### TEST

- [x] Docs only; the gates `ship-pr` runs cover links and integrity.

### DEPLOY: docs/4399-task-card-sourced-fields

Ian's manual now says that a task card's Deadline and SMART answers come from the owner or a source (a
mail, a letter, an official date) and stay empty otherwise, and `inbox-sweep` points at it (#4399).

**Score:** 2

#### What makes this deploy extra special

A life hub's task cards no longer get a deadline or a generic SMART answer the writer made up, so a card
does not land in the overdue column on a date the owner never set.

**Score:** 2

#### Pull Request

lifehub: a task card's Deadline and SMART answers come from the owner or a source

