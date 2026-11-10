## fix/3960-triage-labels-drift

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

- [x] `check-script-contract` evaluates the blueprint's `Get-TriageLabels` record, calls the consumer's own
  answer in its probe, and reports every canonical name missing from it as `[ERROR]` (option A, decided on #3960)
- [x] the source's `$script:TriageLabels` is scrubbed around the probe, as the branch table's is (#3886)
- [x] `CONTRIBUTING-portable.md` step 1 says what a consumer's own answer must carry
- [x] filed #3966: step 1 of the same page still calls branch prefixes the consumer's own, against #3886

### TEST

- [x] `script-contract.tests.ps1` case 15: the source's set, a stale pre-rename copy (the measured instance),
  a recoloured superset, an absent function, a throwing one, a consumer reading a set it never assigns, a
  missing blueprint and the source repo itself -- 484 pass, 0 fail

### DEPLOY: fix/3960-triage-labels-drift

`check-script-contract` now holds a consumer's own `Get-TriageLabels` to the canonical set. Every canonical
label missing from that answer is an `[ERROR]` naming the missing labels and the repair. Extra labels and the
consumer's own colours and descriptions stay silent, and a repo that does not define the function is not
compared, because the built-in fallback is the set. Inbound #3960, measured in a consumer whose copy, taken at
adoption, still named `needs-decision` and lacked `awaiting-decision-dev`: `adopt-triage-labels` and its
session check prescribed the retired names, and a sweep there would have failed on its first park.

**Score:** 2

#### What makes this deploy extra special

A consumer whose `scripts/repo-config.ps1` carries an older copy of `Get-TriageLabels` now gets an `[ERROR]`
from `check-script-contract`, at session start and in its gate, until the copy is replaced with the
blueprint's text or deleted. Repos that never copied it, or kept it current, notice nothing.

**Score:** 3

#### Pull Request

check-script-contract reports canonical triage labels missing from a consumer's Get-TriageLabels

