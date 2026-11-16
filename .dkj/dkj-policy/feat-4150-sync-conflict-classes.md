## feat/4150-sync-conflict-classes

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

- [x] `sync-rules.ps1` (both byte-identical copies): `Get-SyncTrunkAheadHint`, `Get-SyncJsonKeyDiff` (with `ConvertTo-SyncFlatJson`), `Test-SyncJsonTemplatePath` and `Format-SyncConflictHint` -- pure, so the suite walks them without a sync
- [x] `sync-main.ps1` (both copies): `Get-SyncConflictHintLine` reads the trunk's revisions of a conflicted path and prints one `->` line under its `git diff --no-index` command; the refusal is unchanged

### TEST

- [x] `sync-rules.tests.ps1`: trunk ahead on a CRLF copy of older lines, a foreign line counted, an empty live file never trunk ahead, the editor banner stripped, live-only / trunk-only / changed keys named, reformatting alone said to be formatting, a string and a number kept apart, an unparseable side yields no key hint, and which paths take the key hint (225 asserts, green)
- [x] `sync-main.tests.ps1`: through a real dry run, a Liquid path reads `trunk ahead` and a template reads its key summary, both still refusing (179 asserts, green)
- [x] `native-capture.tests.ps1`: the audited site count moves 116 -> 118 for the two new captures, each judged by `Test-NativeExitMeasured` first (355 asserts, green)

### DEPLOY: feat/4150-sync-conflict-classes

Inside this repo, `sync-main.ps1` prints a one-line reading under each conflicted path's diff command
([#4150](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4150)). New pure functions in `sync-rules.ps1`
compute it, and both suites cover them.

**Score:** 2

#### What makes this deploy extra special

A Shopify repo whose sync refuses on conflicts gets a first reading of each conflicted path, so nobody has to diff
them all by hand. A Liquid or other text path reads `trunk ahead` when every line live holds is one the trunk's
history has held. A `templates/` or `sections/` JSON file gets its live-only, trunk-only and changed settings,
by key. Measured in a consumer, those were the two readings that settled twelve conflicts, and they took most of a
session to work out by hand. The conflict still refuses: the person decides.

**Score:** 3

#### Pull Request

sync-main gives each conflicted path a first reading

