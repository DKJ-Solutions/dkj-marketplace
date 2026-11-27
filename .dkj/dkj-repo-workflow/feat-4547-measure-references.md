## feat/4547-measure-references

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

#4547's step 1, the data source: both, kept apart. The knowledge-lookup block asks each specialist to end
its deliverable with `References: <n> from the store, <n> added, <n> web searches.` (the store differs per
repo, so only the specialist can count it), and the script counts the WebSearch/WebFetch calls in that
subagent's own transcript beside it (the half nobody can talk up). Steps 3 (the Admin chart) and 4 (the
measurement after a release) are split off to #4550, parked on `awaiting-release`: no transcript carries
the line until a release ships it, so a chart now would show an empty state nobody can judge.

### CREATE

- [x] `subagent-shared/knowledge-lookup.md`: the References line, regenerated into the eight agent defs
- [x] `scripts/maintenance/measure-references.ps1` (+ plugin mirror, shared-scripts registry), its skill page `measure-references` (disable-model-invocation)
- [x] `scripts/tests/measure-references.tests.ps1`

### TEST

- [x] the new suite: 26 passed, after the Victor/Sebastian/Edith review fixes (a like-for-like measured column, a six-digit cap on the counts, PowerShell 7 timestamps, a pre-filter on non-assistant lines)
- [x] a real run (`-All`) over this machine's 75 subagent runs: Rebecca 42 measured web calls over 3 runs, nothing reported yet, exit 0

### DEPLOY: feat/4547-measure-references

Specialists carrying the knowledge-lookup block now end a deliverable whose task read or searched for sources with one line,
`References: <n> from the store, <n> added, <n> web searches.` The new `measure-references` skill reads
every subagent transcript and reports, per specialist and per ISO week, those counts beside the web calls
measured in the same runs' own transcripts, and the reuse share (from store over from store plus web).

**Score:** 2

#### What makes this deploy extra special

Whether the self-maintained references actually save web searches is now a number you can run
(`/measure-references`), week over week, instead of a guess.

**Score:** 2

#### Pull Request

measure-references: what a specialist's references save, reported beside the measured web calls
