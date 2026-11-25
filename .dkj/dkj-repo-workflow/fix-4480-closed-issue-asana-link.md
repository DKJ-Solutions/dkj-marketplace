## fix/4480-closed-issue-asana-link

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

Issue #4480: a task linked to an issue that was already closed got the open-issue writes (a move into
progress, the `created:` comment), and the closed message never came, because the close's run had found
no marker and nothing ran again. The issue proposes two fixes, and both are taken. A hand-posted closed
message would lose the block, the `InReview` move and `result-owed`, so the workflow has to post it.

### CREATE

- [x] `templates/asana-closed-message.yml`: also triggers on `edited`. A job `if:` passes an edit only
  when it adds the `asana-task` marker to a closed issue, and that run reaches the script as `closed`.
  The concurrency group moves from the workflow to the job, so a skipped edit never drops a pending close.
- [x] `skills/report-issue/SKILL.md`: the existing-task path reads the issue's state first. On a closed
  issue it makes no move and posts no `created:` comment, but still writes the link and the marker.
- [x] `WORKFLOW-portable.md`: the closed-message paragraph names the after-the-close link.

### TEST

- [x] `scripts/tests/dkj-repo-workflow-bwj.tests.ps1`: the trigger assert now names `edited`, and six new
  asserts pin the `if:` clauses, the event mapping and the job-level group. `ship-pr`'s gate runs them.

### DEPLOY: fix/4480-closed-issue-asana-link

When a session links an Asana task to a GitHub issue that is already closed, the task now gets its
closed message, with the go-live block and the move into review, exactly as if it had been linked before
the close. It no longer gets a "now in progress" comment, and its card no longer moves backwards. To take
the change, a store re-places its `asana-closed-message` workflow from the template;
`closed-message-sessioncheck` reports the old copy as differing.

**Score:** 2

#### What makes this deploy extra special

A colleague waiting on an Asana card for a request that is already done hears that it is done, instead of
reading that work has started on it.

**Score:** 2

#### Pull Request

report-issue links an already-closed issue as 'now in progress', so asana-closed-message never posts

