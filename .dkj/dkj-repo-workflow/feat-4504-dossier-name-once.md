## feat/4504-dossier-name-once

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

Inbound #4504: replace the "two dossiers may share a name" allowance in Ian's #4380 rule with a
hub-wide uniqueness rule, and write the owner's decision on the gifts-under-a-person case
(`Gifts <person>`) into it.

### CREATE

- [x] Ian's manual (`specialist-04-03-manual.md`): dropped the allowance from "No word twice in a
  dossier's path" and changed its `Person › Gifts` example; added "A dossier name occurs only once"
  with the search test, the two clash routes, the grid-belongs-in-a-table case and the
  `Gifts <person>` convention.

### TEST

- [x] Read the rule against #4380 beside it: the `Gifts <person>` echo is named as the one place a
  word may repeat its path, so the two rules do not contradict each other.

### DEPLOY: feat/4504-dossier-name-once

Ian, the life hub's information architect, now keeps every dossier name unique across the hub,
compared case-insensitively. Before he creates or renames a dossier he searches for the exact name.
On a clash he makes the new name more specific, or asks whether the items belong in a table instead
of a tree of dossiers. The old allowance that two dossiers may share a name because their paths
differ is gone. A per-person child dossier carries the person's name, so the gifts dossier under
Anna is `Gifts Anna`.

**Score:** 2

#### What makes this deploy extra special

A life-hub user can read a dossier name in a search result, a link or a mention and know which
dossier it is, without opening its path.

**Score:** 2

#### Pull Request

Ian: a dossier name occurs only once in the hub

