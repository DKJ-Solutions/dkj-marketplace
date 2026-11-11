## docs/3978-derek-repository-engineer

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

Issue #3978: Derek was titled DevOps Engineer while his scope is the repo flow only. The owner's decision
on the issue (November 11, 2026): retitle him to what he does; his scope stays branches, pull requests,
merges, labels and `gh` up to the merge, and product infrastructure is not added.

### CREATE

- [x] Persona `specialist-05-05-persona.md`: title Repository Engineer, plus one sentence on what that title does not cover and why
- [x] This repo's lens and roster row (`specialist-05-05-lens.md`, `SPECIALISTS.md`)
- [x] Every role reference to "the DevOps engineer/specialist/colleague" in personas, manuals (alpha and shopify), README, ADOPTION, lenses, the guard hook and three script comments
- [x] `CHANGELOG.md`: #3984's folded entry gets back its `#### What makes this deploy extra special` heading, which the lint gate refused this branch over; the gap that let it through is #3986
- [~] The fixture strings in `dev-pages.tests.ps1` and `teardown.tests.ps1` keep "DevOps": they test title parsing on made-up input, not Derek's title. The archived changelog keeps its history.

### TEST

- [x] `git grep -i devops` outside the release history and those two fixtures finds nothing
- [x] Every replacement matched exactly once; the diff is line-for-line (21 in, 21 out before the persona sentence)

### DEPLOY: docs/3978-derek-repository-engineer

Derek 🐙 #05 is retitled **Repository Engineer** (was DevOps Engineer), the title of the work he already did:
branches, pull requests, merges, labels and `gh`, up to the merge (#3978). Hosting, a product's CI/CD,
monitoring and incident response stay nobody's on this team, and the persona now says so, so infrastructure
work is no longer routed to him by title. Every role reference in the personas, manuals, README and
ADOPTION follows.

**Score:** 2

A consuming repo's roster (`SPECIALISTS.md`) and Derek's lens title still read "DevOps Engineer" until that
repo edits them; the roster check does not compare titles, so nothing fails, and Derek's own persona reads
Repository Engineer from this release on.

**Score:** 2

#### Pull Request

Derek is retitled Repository Engineer, the title his scope already had

