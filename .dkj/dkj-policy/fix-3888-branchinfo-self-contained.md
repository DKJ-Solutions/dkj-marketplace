## fix/3888-branchinfo-self-contained

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

### CREATE

- [x] `Get-BranchInfo` in `scripts/lib/branch-info.ps1` derives its prefix inline instead of calling `Get-BranchPrefix`; the blueprint rebuilt from it
- [x] `check-script-contract.ps1` (both copies) drops the `Get-BranchPrefix` stub it needed to evaluate the record

### TEST

- [x] `config-blueprint.tests.ps1` evaluates every `branch-info.ps1` record from its own text: 3 failed before the change (`Get-BranchPrefix` not recognized), 237 of 237 pass after
- [x] `script-contract.tests.ps1` now holds the inline rule to `Get-BranchPrefix` over nine names and asserts the stub is gone: 463 of 463 pass

### DEPLOY: fix/3888-branchinfo-self-contained

The config blueprint's `Get-BranchInfo` record runs on its own. Its text called `Get-BranchPrefix`, which no
contract record carries, so a consumer with a hand-built `branch-info.ps1` that adopted the record (a `copy`
record since #3886) got a `Get-BranchInfo` that threw (#3888). The function now derives the prefix inline,
`check-script-contract` evaluates the records without the stub it carried for this, and
`config-blueprint.tests.ps1` evaluates the branch-info records from their own text.

**Score:** 2

#### What makes this deploy extra special

A repo whose `branch-info.ps1` was written by hand can adopt `Get-BranchInfo` from the blueprint without it
failing on first use. A repo set up by `specialists-init` already had `Get-BranchPrefix` and notices nothing.

**Score:** 2

#### Pull Request

Get-BranchInfo's blueprint text no longer calls Get-BranchPrefix, which the blueprint does not carry

