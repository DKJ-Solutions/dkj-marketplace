## feat/4287-dependabot-entry

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

- [x] Read the consumer copy (453 lines, Dutch, stale on the folder move) and the plugin seams it should stand on (#4287).

### CREATE

- [x] `scripts/task/dependabot-entry.ps1` and its byte-identical mirror in `dkj-repo-workflow`, rewritten in English on the plugin's own libs (`Resolve-RepoRootOrFail`, `Invoke-NativeCapture`, `Resolve-BranchFilePath`, `Split-Development`, `Get-DevelopmentEntryPattern`).
- [x] Registered in `Get-SharedScriptPairs` with skill `dependabot-entry` and the test seam `-PrJson` exempt.
- [x] Skill page, a row in the plugin's `scripts/README.md`, the Chat-available list in `ADOPTION.md`.

### TEST

- [x] `dependabot-entry.tests.ps1`: every refusal, a full run against a moved trunk, a rerun, a local branch ahead of origin, `-NoPush`, and both copies -- 35 asserts green; `shared-scripts.tests.ps1` and the lint gate green.

### DEPLOY: feat/4287-dependabot-entry

`dkj-repo-workflow` now ships `dependabot-entry` (#4287): it writes the branch development document
onto a Dependabot PR's own branch, so the PR passes the branch-entry gate. It refuses a PR that is not
open, comes from a fork or is not Dependabot's, never touches a local branch ahead of origin, merges the
current trunk in, and leaves the three questions a bump owes (where the package enters, why it is worth
taking, what the audit said) in the DEPLOY section for a person to answer. The gate itself stays as it is.

**Score:** 2

#### What makes this deploy extra special

A repo with Dependabot no longer needs its own copy of this script to get a bump past the entry gate.

**Score:** 2

#### Pull Request

Ship dependabot-entry in dkj-repo-workflow, so a Dependabot PR meets the branch-entry gate

