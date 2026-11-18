## fix/4312-lint-brain-dot-record-root

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

Inbound #4312: `Read-LintBrainSeams` normalised every record-root seam with `TrimStart('.', '/')`, which
strips the dot of `.dkj/`, so no record under the v7 workflow folder ever matched `Test-UnderRoots`.
Strip a leading `./` only, and pin it with a dot-folder case.

### CREATE

- [x] `lint-brain.ps1` (`dkj-repo-workflow-bwj`): the normaliser strips a leading `./` run and then `/`, never a bare dot
- [x] `bwj-lint-brain.tests.ps1`: a case whose seams name `.dkj/...` and `./.dkj/...` frozen roots

### TEST

- [x] The new case is red with the fix stashed and green with it; the suite passes all 151 asserts

### DEPLOY: fix/4312-lint-brain-dot-record-root

The shared `lint-brain` (`dkj-repo-workflow-bwj`) no longer strips the leading dot of a record-root
seam, so frozen release records under `.dkj/` are exempt again, as its header promises (#4312). A suite
case with a dot-folder root pins it; every earlier fixture used `docs/workflow/`, which is why it slipped.

**Score:** 2

#### What makes this deploy extra special

A BWJ store that points its lint gate at the plugin's `lint-brain` no longer goes red on its own frozen
release history under `.dkj/dkj-repo-workflow/releases/`, so its `open-pr`/`ship-pr` lint gate passes
without `-SkipLint`.

**Score:** 3

#### Pull Request

lint-brain keeps the dot of a dot-folder record root

