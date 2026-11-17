## fix/4251-part1-move-beside-branch-docs

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

Inbound #4251, measured in a consumer's v7.0.0 migration: `new-branch` creates `.dkj/dkj-repo-workflow/`
before Part 1 runs, so `adopt-workflow-folder.ps1` skipped the move and died on the seam asserts; its dry
run died the same way, and the branch document kept a guidance line naming the old folder.

### CREATE

- [x] Move the legacy folder's children into a new folder that holds only branch documents; keep the skip,
  now announced as `[skip]`, for anything else in it.
- [x] Assert a dry run's seams against the paths the move would leave behind.
- [x] Repoint the ``FROM `<old>/` `` guidance token in the moved folder's branch documents.
- [x] Mirror the script into `plugins/dkj-repo-workflow/`, one sentence in the adopt skill, three new
  cases in `adopt-workflow-folder.tests.ps1`.

### TEST

- [x] `adopt-workflow-folder.tests.ps1` standalone: all 207 asserts pass, the new apply, dry-run and
  skip cases among them. The full gate runs in `ship-pr`.

### DEPLOY: fix/4251-part1-move-beside-branch-docs

Part 1 of adopting the workflow now moves the old `.dkj/dkj-policy/` folder when the migration branch's own
document already sits in `.dkj/dkj-repo-workflow/` (#4251). Before, it skipped the move and stopped on the
seam check, so the 7.0.0 steps failed in the order the release note gives them. Its dry run no longer
fails on the repos it exists for, and the branch document's line naming the folder links resolve from is
repointed too.

**Score:** 4

#### What makes this deploy extra special

A maintainer migrating to 7.0.0 can follow the note in order (branch first, then Part 1) without moving
their branch document aside by hand.

**Score:** 4

#### Pull Request

Part 1 moves .dkj/dkj-policy/ even when new-branch already created .dkj/dkj-repo-workflow/

