## fix/4267-closed-message-result-owed

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

#### Scope (#4267)

Both halves of the inbound report hold on the tree: the no-block branch of `asana-closed-message`
said "now in review" while #3248 deliberately moves the card only on a close with a block, and the
owed result message was recorded in the run log alone. Chosen repair: the no-block closed line says
the result message follows instead of claiming review (keeps #3248's narrow move), and the issue is
labelled `result-owed`, listed by `closed-message-sessioncheck` (finding 8) and taken off by
`build-golive-block -ByHand -Post`.

### CREATE

- [x] Template: the no-block closed line says the result message follows, no review claim, no reopen line
- [x] Template + yml: label `result-owed` on a completed close without a block (`issues: write`)
- [x] Lib: `Get-ResultOwedLabel`, held equal to the template's copy
- [x] Session check finding 8: closed issues carrying `result-owed`
- [x] `build-golive-block -ByHand -Post` takes the label off
- [x] Docs: WORKFLOW-portable, golive-block skill, the template and hook headers

### TEST

- [x] `dkj-repo-workflow-bwj.tests.ps1`: 1055 asserts green (pending form, label call, refused label, parity)
- [x] `closed-message-sessioncheck.tests.ps1`: 78 green (finding 8 on the fixture and on the live gh path)

### DEPLOY: fix/4267-closed-message-result-owed

An Asana task whose GitHub issue closes without a go-live block no longer reads "this Asana task is now
in review" while its card stays in progress (#4267). The closed line now says the result message for
this round follows. The issue is labelled `result-owed`, the store's session check lists such closed
issues, and `build-golive-block -ByHand -Post` takes the label off once the result message is on the
task. Before, the run log was the only record of that debt, and smartwatchbanden#1212's went unpaid
until the requester asked. A store takes it by re-copying the `asana-closed-message` template; the
workflow now needs `issues: write`.

**Score:** 2

#### What makes this deploy extra special

A promised result message can no longer be forgotten in silence: every session in the store names it
until it is written.

**Score:** 2

#### Pull Request

asana-closed-message without a block: track the owed result message, and stop claiming review
