## feat/4286-trunk-commit-guard

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

Inbound #4286: nothing in the plugin enforced the constitution's "never directly on the trunk". One
store had built its own 955-line hook for it.

- **Rule 2 ships** (refuse a commit while HEAD is on the trunk). It goes into `guard-working-copy`'s
  every-thread safety block next to #3901's force-push and hard-reset rule, so no new hook entry is
  needed. The allowed subjects are `fold:`, `release:`, `release-prep:` and `release-notes:`, the only
  direct trunk subjects this repo's first-parent history shows.
- **Rule 3 (a notice on every prompt while on the trunk) is declined.** In this workflow the trunk is
  where a checkout rests between assignments, because `ship-pr` returns there, so the notice would fire
  on almost every prompt.
- **Rule 4 (the store's `live` branch) stays in the store**, as the issue proposes: the branch and its
  marker are store facts.
- **The rule fails open on every doubt**: detached HEAD, not a repo, git unreadable, `--git-dir` or
  `--work-tree`, or a trunk it cannot name. It reads the trunk as origin/HEAD, else `main`, the same
  fallback `trunk-sync-lib` uses. It does not load `Get-BranchTrunkName`, which would pull an 8,000-line
  lib and a consumer seam into every commit's refusal path.
- **A subject the guard cannot read is refused on the trunk**: an editor, `$var`, `-F -`, `--amend
  --no-edit`, or `-C`/`--fixup`. A commit made inside a script, such as the fold or the cut, is not
  visible to a hook and is not its concern.

### CREATE

- [x] `Get-TrunkCommitViolation` and its helpers in `working-copy-guard-lib.ps1`, with the mirror byte-identical
- [x] `guard-working-copy.ps1` asks it before the `agent_id` gate. The pre-gate now also admits `commit`
- [x] `Get-SegmentCdTarget` extracted and shared with the project-scope rule. It is now case-insensitive, so a capitalised `Set-Location` is seen
- [x] The scripts README row names the new rule

### TEST

- [x] `working-copy-guard-lib.tests.ps1` 217 passed; `guard-working-copy.tests.ps1` 85 passed, with temp-repo fixtures; `hook-fail-closed` and `shared-scripts` green; `check-plugin-integrity` 0 errors.
- [x] The full gate runs in `ship-pr`.

### DEPLOY: feat/4286-trunk-commit-guard

`guard-working-copy` now refuses a `git commit` made while HEAD is on the trunk, in every thread, unless
the subject is one of the constitution's bounded direct commits (`fold:`, `release:`, `release-prep:`,
`release-notes:`). Before this, "never directly on the trunk" was prose only, outside one store that
built its own guard. The rule fails open whenever it cannot tell the branch or the trunk
([#4286](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4286)).

**Score:** 4

#### What makes this deploy extra special

A consumer's session that tries to commit straight on the trunk is now stopped and pointed at
`new-branch`, where it used to land the commit and fail only at push time, or not at all.

**Score:** 3

#### Pull Request

Refuse a commit on the trunk in guard-working-copy, outside the fold and release subjects

