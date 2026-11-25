## fix/4478-session-closes-asana-issue

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

#4478: after a `-NoResolves` merge, `WORKFLOW-portable.md` and the resolves-gate refusal named the task's
assignee as the closer, while `golive-block` and the owner have the shipping session close it. The refusal's
text is the consumer's `Get-ResolvesExemptMatchers` seam, so the source fix is the template that seam is
copied from. ship-pr closing the issue itself (the issue's optional point 2) is left out.

#### Scoped out, and why

- [~] The issue's optional point 2 (ship-pr closes the issue itself after a `-NoResolves` merge) is not built:
  the issue marks it optional, and the corrected refusal already prints the exact `gh issue close` line.

### CREATE

- [x] `WORKFLOW-portable.md` (bwj), both passages: the shipping session closes the issue as completed once
  the PR has landed and the block is on it.
- [x] The `Get-ResolvesExemptMatchers` template in `adopt-dkj-repo-workflow-bwj` and the bwj README say the
  same, and its `Why` prints the `gh issue close <n> --reason completed` line.
- [x] `open-pr`'s fallback `Why` (both mirrors, kept byte-identical) no longer says "closed by a person".

### TEST

- [x] No suite asserts the changed strings (searched `scripts/tests`); the full gate runs in `ship-pr`.

### DEPLOY: fix/4478-session-closes-asana-issue

After a `-NoResolves` merge of an Asana-linked issue, the docs and the resolves-gate refusal now say that
the shipping session closes the issue, not the task's assignee.

**Score:** 2

#### What makes this deploy extra special

A store's session no longer hands the close of an Asana-linked issue to the owner after the merge. It
closes the issue itself with the `gh issue close` line the refusal now prints. A store already on the old
`Get-ResolvesExemptMatchers` answer keeps the old refusal text until it copies the new template from
`adopt-dkj-repo-workflow-bwj`.

**Score:** 2

#### Pull Request

The shipping session, not the task's assignee, closes an Asana-linked issue after a -NoResolves merge

