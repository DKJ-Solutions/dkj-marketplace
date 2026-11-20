## feat/4351-asana-scripts-from-pinned-checkout

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

A store keeps only the thin .github/workflows/asana-*.yml; the scripts run from a SHA-pinned checkout of the plugin source, so a fix reaches a store by a one-line pin bump instead of a re-copied 2,725-line script.

#### Decisions

- **Thin callers, not a `reusable-asana-*.yml`.** The seven other CI-floor runners a store holds
  (`live-direct-writes`, `fold-on-merge`, ...) already check `dkj-marketplace` out at a SHA pin and run a
  script from it, so the trio now reads the same. A reusable workflow would add files under this repo's
  own `.github/workflows/` and a `secrets:` hand-off for `ASANA_PAT`, for no gain over that pattern.
- **`template-selfcontained.tests.ps1` intent kept.** It exists because a CI-run script loads no plugin
  lib (#1556). The moved scripts still run as one file, so the suite now walks `scripts/ci/asana-*.ps1`
  too, and the scripts stay self-contained: a store not yet migrated runs its old copy beside them.
- **The scripts move to `dkj-repo-workflow-bwj/scripts/ci/`**, the folder name `dkj-repo-workflow` already
  uses for a CI-run script, so `templates/` holds only what a store copies.

### CREATE

- [x] Moved `templates/asana-{closed-message,open-section,prio-label}.ps1` to `scripts/ci/`; their config
      fallback is now the working directory's `scripts/repo-config.ps1` (the workflow passes it explicitly).
- [x] The three `templates/asana-*.yml` fetch the plugin source with a SHA-pinned `actions/checkout` at
      `ref: @@SCRIPTS_REF@@` (sparse, the `scripts/ci` folder) and run the script from there; prio-label no
      longer checks out the store at all, since it reads nothing from it.
- [x] `closed-message-sessioncheck` compares only the workflow, ignoring the `ref:` pin, and reports a
      `.github/scripts/asana-*.ps1` copy left behind.
- [x] `adopt-dkj-repo-workflow-bwj` step 1 places the workflow with its pin (how to resolve the SHA) and
      carries the one reported migration: replace the workflow and `git rm` the copy, in one commit.
- [x] Comments in `asana-task-lib`, `asana-section-lib`, `live-message-rules`, `stale-paste-block-rules`,
      `guard-stale-paste-block` and the plugin README point at the new path.

### TEST

- [x] `closed-message-sessioncheck.tests.ps1` -- 87 passed: pins (SHA + tag, bare tag, `main`) are not
      stale, a non-release ref is, and a left-behind copy is reported per workflow and per repo reach.
- [x] `dkj-repo-workflow-bwj.tests.ps1` -- 1106 passed, including the new asserts that each workflow
      runs nothing from `.github/scripts/`, fetches at the placeholder, and pins every action by SHA.
- [x] `bwj-asana-move-task.tests.ps1` -- 57 passed; `template-selfcontained.tests.ps1` -- 15 passed,
      now covering the three CI scripts.
- [x] `check-plugin-integrity.ps1` -- 0 errors.

### DEPLOY: feat/4351-asana-scripts-from-pinned-checkout

The three Asana workflows of `dkj-repo-workflow-bwj` (`asana-closed-message`, `asana-prio-label`,
`asana-open-section`) no longer ship their script for a store to copy. A store keeps only the workflow
file, which checks out `DKJ-Solutions/dkj-marketplace` at a pinned commit and runs the script from
`dkj-repo-workflow-bwj/scripts/ci/`, the way the rest of the CI floor already does. The adopt skill
places the workflow with that pin and migrates a store off its `.github/scripts/asana-*.ps1` copies, and
the session check now ignores the pin and reports a copy left behind.

**Score:** 3

#### What makes this deploy extra special

For a BWJ store, a fix to the closed message, the prio-label sync or the open-section sweep now reaches
the store by moving one `ref:` line, instead of re-copying up to 1,800 lines of script per workflow. Each
store needs one migration after taking this release: the session check names the copies until
`adopt-dkj-repo-workflow-bwj` step 1 has replaced the workflows and removed them.

**Score:** 4

#### Pull Request

The three Asana workflows fetch their script from a pinned dkj-marketplace checkout
