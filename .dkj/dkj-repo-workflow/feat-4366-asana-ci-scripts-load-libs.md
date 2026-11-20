## feat/4366-asana-ci-scripts-load-libs

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

Since every BWJ store runs the pinned Asana workflows, the three scripts/ci/asana-*.ps1 dot-source asana-task-lib.ps1 / asana-section-lib.ps1 and the workflows sparse-checkout scripts/lib too.

#### Verified before building

The issue's own unblock condition: the comment of 2026-11-20 13:33 on #4366 records all three stores
(smartwatchbanden #1501, xoxowildhearts #576, phone-factory) migrated, with no `.github/scripts/asana-*.ps1`
left on any store's main.

### CREATE

- [x] The three `scripts/ci/asana-*.ps1` drop every helper equal to a lib's (16 in closed-message, 5 in
      open-section, 3 in prio-label -- measured by AST, all byte-equal) and dot-source
      `../lib/asana-section-lib.ps1` (closed-message, open-section) or `../lib/asana-task-lib.ps1`
      (prio-label), stopping with a message naming the fix when the lib is missing.
- [x] prio-label's own task read, which shared a name with the lib's `Get-AsanaTaskState` but answers a
      different shape, is renamed `Read-AsanaTaskScore` so loading the lib cannot shadow either.
- [x] The three workflow templates' `sparse-checkout` fetch `scripts/lib` beside `scripts/ci`.
- [x] Suites: the copy-equality pins against the libs become "dot-sources its lib and defines none of the
      functions its libs define"; the sparse-checkout is pinned; the card-move suite holds the CI scripts to
      no `Get-SectionCode` of their own. The self-contained suite KEEPS `scripts/ci` (stronger than the
      issue's proposal to drop it): it now counts what the libs a script loads define, so a renamed helper
      the sweep alone calls (#1556) is still caught.
- [x] Docs: the three script headers, `asana-section-lib.ps1`, `asana-task-lib.ps1`,
      `live-message-rules.ps1`, the `move-asana-task` skill, and the adopt skill's "updating the plugin"
      paragraph (copy the template again where the session check reports a difference).

### TEST

- [x] `dkj-repo-workflow-bwj.tests.ps1` 1086/1086, `bwj-asana-move-task.tests.ps1` 37/37,
      `template-selfcontained.tests.ps1` 21/21, `closed-message-sessioncheck.tests.ps1` 87/87,
      `guard-stale-paste-block.tests.ps1` 156/156.
- [x] Smoke test in a simulated sparse checkout (only `scripts/ci` + `scripts/lib`) under Windows
      PowerShell: all three scripts load and run their no-PAT / no-link paths; with `scripts/lib` removed
      the run exits 1 with the re-copy message.

### DEPLOY: feat/4366-asana-ci-scripts-load-libs

The three Asana CI scripts of `dkj-repo-workflow-bwj` (`asana-closed-message`, `asana-open-section`,
`asana-prio-label`) now load `asana-task-lib.ps1` and `asana-section-lib.ps1` from the pinned checkout
instead of carrying copies of their helpers, so a fix to a matcher, a block marker or the section rule
reaches the CI runs and the task scripts as one change. The workflows' `sparse-checkout` fetches
`scripts/lib` beside `scripts/ci` for that.

**Score:** 2

#### What makes this deploy extra special

A BWJ store that moves its Asana workflows' `ref:` to this release must copy the three workflow files from
the plugin's `templates/` again (keeping its `ref:` line), because the job now fetches `scripts/lib` too.
`closed-message-sessioncheck` reports each placed workflow as differing from its template until that is
done, and a workflow moved to the new `ref:` alone stops its run with a message naming exactly this.

**Score:** 4

#### Pull Request

The Asana CI scripts load the shared libs instead of carrying copies

