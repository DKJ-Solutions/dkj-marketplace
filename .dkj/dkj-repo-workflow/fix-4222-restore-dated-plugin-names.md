## fix/4222-restore-dated-plugin-names

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

Fixes #4222. #4209's bulk rename put the new plugin names into sentences that describe a past
state or event. The 393 candidate lines (git diff -U0 df007c969^1 df007c969, a new name beside an
issue below #4209 or a 2026 date) were judged one by one. The rule applied:

- **A past event or a dated measurement gets the name it had then** (#2788's precedent): "moved into
  `dkj-policy` with #3531", "`dkj-policy` 4.31.0 on September 7", "until #3475 `dkj-solutions`".
- **A present-tense statement with a provenance citation keeps the current name**: "in
  `dkj-repo-workflow` since #3470", "every repo that runs `dkj-repo-workflow` (#3643)". The plugin is
  the same entity under a new name, so "its files sit in X since #3531" is true as written.
- **Paths that are links, code values and test-assert strings stay as they are**, so nothing resolves
  or matches differently.
- **The consumer register's notes go back wholesale**: they state "the sentences above keep the
  names they were WRITTEN with, per #952", which the rename broke.

Out of scope and filed: #4235, the older house-style redirect patterns were renamed too, so the
comments that describe them are left matching that code until it is repaired.

### CREATE

- [x] Restore the old name on 64 dated lines (54 files) and in 8 targeted phrases.

### TEST

- [x] The gates and suites through ship-pr.

### DEPLOY: fix/4222-restore-dated-plugin-names

Inside this repo, dated history sentences in docs, comments and the consumer register name the
plugin as it was called on that date again, instead of the names #4209 introduced.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Restore the old plugin names in dated history sentences

