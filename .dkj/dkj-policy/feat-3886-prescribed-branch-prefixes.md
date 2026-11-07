## feat/3886-prescribed-branch-prefixes

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

Prescribe one branch-prefix table for every DKJ repo and report a consumer that differs, per #3886
(Dave, November 7, 2026): `feat/` -> `feature`, `fix/` -> `bug`, `docs/` -> no label, `chore/` refused.
Out of scope: fixing each consumer, which runs through that consumer's own issue. The one finding found on
the way is #3888 (the blueprint's `Get-BranchInfo` text calls `Get-BranchPrefix`, which it does not carry).

### CREATE

- [x] Flip the three `branch-info.ps1` records (`Get-BranchInfo`, `Test-BranchName`, `Get-BranchTypes`)
      from `decide` to `copy` in `script-contract-lib.ps1` (plugin copy and its source mirror), each
      `AdoptWhy` amended with the dated reversal; the block comment and the "ten are decide" count amended
- [x] Rewrite the self-description in `scripts/lib/branch-info.ps1` (no longer "repo-owned and does not
      travel") and regenerate `config-blueprint.json` with `build-config-blueprint.ps1`
- [x] `check-script-contract.ps1` (plugin copy and mirror) compares behaviour with the blueprint's: the
      label and type of every prefix either table knows, and whether `chore/x` is refused. A difference is
      one `[ERROR]` line naming it and the repair; silent in the source repo and wherever the blueprint is
      absent; a throwing lib degrades to one `[INFO]` line
- [x] `shared-scripts-lib.ps1` declares `MirrorRun` for the check (the blueprint path resolves differently
      in the mirror)
- [x] Docs that called the table a local choice: `CONTRIBUTING-portable.md`, `ADOPTION.md`, the
      `adopt-dkj-policy` and `adopt-bwj-development` skill pages

### TEST

- [x] `script-contract.tests.ps1`: new section 14 -- the source's table is silent and reported as matching,
      a differing table and a chore-allowing table report `[ERROR]` with the repair, a throwing table
      degrades to `[INFO]`, the source repo itself says nothing
- [x] `config-blueprint.tests.ps1` now pins all three records as `copy`
- [x] `script-contract`, `config-blueprint`, `branch-info` suites and `check-plugin-integrity.ps1` green

### DEPLOY: feat/3886-prescribed-branch-prefixes

Every DKJ repo now uses the source's branch prefixes: `feat/` earns `feature`, `fix/` earns `bug`, `docs/`
earns no label, and `chore/` is refused. The three `branch-info.ps1` records are `copy` instead of
`decide`, and the script-contract session check reports a repo whose table differs, with the repair. It
runs at every session start, so a repo with its own prefixes now sees one `[ERROR]` line until it adopts
the shared table. In this repo nothing changes: its table already is the source's.

**Score:** 3

#### What makes this deploy extra special

If your `scripts/lib/branch-info.ps1` keeps its own prefixes (`data/`, `dossier/`, `chore/` and so on) or
labels `docs/` as `documentation`, the session check now fails with a line naming the difference. Replace
the table and the `Get-BranchInfo`, `Test-BranchName` and `Get-BranchTypes` functions with the text of
those three records in the plugin's `blueprint/config-blueprint.json` (`adopt-config` will not overwrite a
function you already have). Fold any pending changelog entry under a type the shared table does not have
first, because the shared table produces only Feat, Fix, Docs and Chore. The cost is accepted: release
notes no longer group by a domain type.

**Score:** 3

#### Pull Request

Every DKJ repo uses the source's branch prefixes
