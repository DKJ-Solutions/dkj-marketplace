## fix/4314-lint-script-rooted-path

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

#4314 (inbound): `Get-LintScript` could only name a file inside the repo, because the gate joined it onto
the repo root, so a store kept a repo-relative forwarder just to run the plugin's `lint-brain.ps1`.
Verified before repairing: `lint-brain` resolves its root from the directory it starts in, so the only
thing in the way was the `Join-Path`. Chosen repair, smaller than either of the issue's two directions: a
rooted answer is used as it is, and no new seam shape or template file is needed.

### CREATE

- [x] `gate-lib.ps1` (`Invoke-WorkflowGates`): a rooted `Get-LintScript` is used as it is, and that child starts in `$RepoRoot`; a repo-relative one behaves exactly as before
- [x] `cut-release.ps1` and `live-preflight.ps1`: the same rooted-path rule at their own lint call sites
- [x] `script-contract-lib.ps1`: the seam's `Returns` text names both shapes; the config blueprint rebuilt from it
- [x] `dkj-repo-workflow-bwj` README: how a store answers the seam with `Resolve-PluginScript` and drops its forwarder
- [x] mirrors rebuilt with `build-shared-scripts.ps1`

### TEST

- [x] `gate-lib.tests.ps1` case 15d-rooted: a lint script OUTSIDE the fixture repo, named by a rooted path, runs in the repo root, passes, and records the lint evidence
- [x] the full gate runs in `ship-pr`

### DEPLOY: fix/4314-lint-script-rooted-path

A repo's `Get-LintScript` may now return a rooted path. `open-pr`, `ship-pr`, `cut-release` and
`live-preflight` use it as it is instead of joining it onto the repo root, and the lint gate starts that
script in the repo root. This is what lets a store point its gate at the plugin's own `lint-brain.ps1`
(through `Resolve-PluginScript`) and drop the forwarder it kept only so the gate had a repo-relative
file to name. A repo-relative answer behaves exactly as before.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a store repo running the BWJ extension: one forwarder file fewer, and the
`dkj-repo-workflow-bwj` README now shows the three-line `Get-LintScript` that replaces it. Every other
consumer is unaffected.

**Score:** 2

#### Pull Request

Get-LintScript may name a rooted path, so a store points its lint gate at the plugin's lint-brain

