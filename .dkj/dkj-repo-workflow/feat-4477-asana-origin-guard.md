## feat/4477-asana-origin-guard

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

Inbound #4477: `report-issue` files a colleague's request passed on in chat without looking for its
Asana task, and `asana-link-pickupcheck` only warns after the work has started. Two builds: a search
step in `report-issue` step 1, and a create-time guard beside `guard-kind-label`.

### CREATE

- [x] `scripts/lib/asana-origin-rules.ps1`: the signal (a requester named or a task quoted, EN/NL), the
      settled test (Resolve-AsanaTaskRef's link, or `<!-- no-asana-task -->`) and the verdict; the source
      repo is not judged
- [x] `hooks/guard-asana-origin.ps1` + its `hooks.json` entry on `gh issue create`, failing open with a
      warning on a body it cannot read
- [x] `report-issue` step 1: search the board before filing a request that names a requester or a task
- [x] `WORKFLOW-portable.md` section 8 and the plugin README's hook list name the guard

### TEST

- [x] `scripts/tests/guard-asana-origin.tests.ps1` (47 asserts: lib, hook as a process, registration),
      registered in `suite-groups.json`

### DEPLOY: feat/4477-asana-origin-guard

A new PreToolUse hook, `guard-asana-origin`, refuses a `gh issue create` on a store repo whose body names
a requester or quotes a task but links no Asana task, and `report-issue` step 1 now searches the board for
the colleague's task before filing. The line `<!-- no-asana-task -->` records a search that found none.

**Score:** 3

#### What makes this deploy extra special

A colleague's request passed on in chat is now filed as the issue for their own Asana task, so the card
moves to Filed, gets its created: comment, and the requester hears about it when the work ships. Before,
such an issue was filed unlinked and the colleague's card sat untouched in their inbox.

**Score:** 3

#### Pull Request

Refuse a store issue that names a colleague's request but links no Asana task
