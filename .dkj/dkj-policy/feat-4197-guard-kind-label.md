## feat/4197-guard-kind-label

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

#### Scope

Inbound #4197: a PreToolUse guard holding the kind-label rule on `gh issue create`, beside
`guard-reach-reason`. The optional session-check line the issue names is left out: the guard closes the
gap at the moment of filing, and the measured case is the create.

The issue proposed the admitted-repo list as the guard's reach. That list includes the source repo, where
a store session files inbound issues under `feature-inbound`/`bug-inbound`, so the guard judges the
stores only.

### CREATE

- [x] `reach-reason-rules.ps1`: the command parser becomes `Get-GhIssueLabelCall`, returning every
  create/edit call with its labels; `Get-ReachLabelInvocation` filters it, unchanged in shape
- [x] `kind-label-rules.ps1` (the verdict and the repo list) and `hooks/guard-kind-label.ps1`,
  registered in `hooks.json`
- [x] WORKFLOW-portable, report-issue and the README name the guard

### TEST

- [x] `guard-kind-label.tests.ps1` (new, in the bwj suite group), `guard-reach-reason.tests.ps1` green
  on the shared parser, and the hooks.json count in `guard-stale-paste-block.tests.ps1` moved to four

### DEPLOY: feat/4197-guard-kind-label

Inside this repo, `guard-reach-reason`'s command parser is now the shared `Get-GhIssueLabelCall`, which
both guards read a `gh issue` call with.

**Score:** 1

#### What makes this deploy extra special

In a BWJ store, a `gh issue create` without exactly one of `bug`, `feature` or `research` is now
refused before it runs, naming the three
([#4197](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4197)). Sessions had filed 11
consecutive issues with no kind while the rule was loaded. Labels set in a template, the browser or an
editor pass with a warning, and an inbound issue on the source repo is not judged at all.

**Score:** 3

#### Pull Request

bwj-development: guard-kind-label refuses a gh issue create with no (or several) bug/feature/research labels

