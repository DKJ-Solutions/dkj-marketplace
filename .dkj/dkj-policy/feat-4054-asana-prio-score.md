## feat/4054-asana-prio-score

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

Inbound #4054: the owner (Dave, November 13, 2026) requires a Prio-Score on every Asana task
`report-issue` creates. A new optional seam `Get-AsanaPrioFieldGid` names the board's number field (a GID,
like the two other field seams, rather than a lookup by name). Step 2 sets it from the card's `How
urgent` line, and `guard-asana-mirror` refuses a mirror that leaves it unset where the seam is answered.

### CREATE

- [x] `asana-mirror-gate.ps1`: `Read-ProjectConfigSeam` (one reader, `Get-ProjectReachLabel` now uses it), `Get-ProjectAsanaPrioFieldGid`, `Get-AsanaMirrorFieldState` (object or JSON-string `custom_fields`, per task in a batch)
- [x] `guard-asana-mirror.ps1`: the Prio-Score refusal, before the tracker is asked; warned fail-open on an unreadable config or `custom_fields`
- [x] `Get-AsanaMirrorToolInputText` drops a BOM before the opening brace: the suite's hook runs wrote one, so they never parsed
- [x] `report-issue` step 2 and "Before you start", the adopt template, the README seam list, `WORKFLOW-portable.md` step 5 and step 7

### TEST

- [x] `guard-asana-mirror.tests.ps1`: 71 pass, 20 new (field states, batch, empty and non-object values, StrictMode, the BOM, seam reads, the hook's refusal)
- [x] `asana-link-pickupcheck.tests.ps1`: 50 pass, the shared seam reader unchanged for the reach label
- [x] Victor's and Sebastian's reviews: a batch with its URL outside its tasks, empty values counted as a score, a StrictMode throw that would reach the trap, and the trap's wording, all fixed; no security finding

### DEPLOY: feat/4054-asana-prio-score

`report-issue` now scores every Asana task it creates. A new optional seam, `Get-AsanaPrioFieldGid`,
names the board's `Prio-Score` number field; where it is answered, step 2 sets the score on the same
`create task` call from the card's `How urgent` line (blocking a sale 4, visible but not blocking 3,
cosmetic 2, not customer-facing 1), and `guard-asana-mirror` refuses a mirror that leaves it unset. A
ticket that came from Asana keeps its score, or gets one where it has none. Unset, the seam requires
nothing. The guard's payload read also drops a byte-order mark before the JSON, which had made its own
test runs pass without parsing.

**Score:** 3

#### What makes this deploy extra special

A store repo that answers `Get-AsanaPrioFieldGid` gets every new card scored at filing, so its issue
carries a `prio-N` label the same day instead of waiting for somebody to score it in Asana. Add the seam
to `scripts/repo-config.ps1` to take it.

**Score:** 3

#### Pull Request

bwj-development: report-issue sets the Asana Prio-Score on every task it creates, and the mirror guard refuses one without it
