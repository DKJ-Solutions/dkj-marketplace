## docs/4458-ian-consult-first-procedure

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

Give Ian's consult-first rule a concrete walk (tree, Updates by relation) and state that Notion's API search is title-only, so it never proves absence.

### CREATE

- [x] Ian's manual (`specialist-04-03-manual.md`) gets the hard rule *Consulting is a walk, not a
  search*, beside *Makes the whole usable* and above *One detail, one place*: walk the dossier tree,
  query the updates store by relation, then write.
- [x] The same rule states that the Notion API search (`post-search`) matches titles only, so a title
  search is a hint and never proof of absence.
- [~] A script or shared helper for the walk: dropped. The placing skills reach Notion through the
  session's connector, not through a script, so the walk is a procedure each of them follows; the
  rule names them.

### TEST

- [x] The four gates run in `open-pr`.

### DEPLOY: docs/4458-ian-consult-first-procedure

Ian's manual now states how to consult a hub before writing a fact: walk the dossier tree, query the
updates store by relation, then write. It also notes that the Notion API search matches titles only.

**Score:** 2

#### What makes this deploy extra special

In a life hub on Notion, Ian and the skills that place facts (`inbox-sweep`, `agenda`, `ai-radar`) now
check the target dossier, its parent and its children, and the updates linked to them, before writing a
fact. An empty title search no longer counts as proof that the fact is new, so the same fact stops
landing twice on two dossiers with different dates.

**Score:** 3

#### Pull Request

Ian's consult-first rule gets a procedure

