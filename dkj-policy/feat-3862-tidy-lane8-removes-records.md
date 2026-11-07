## feat/3862-tidy-lane8-removes-records

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

- [x] Lane 8 runs the recreate/uninstall/remove sequence itself, guarded by the parent folder (#3862).

### CREATE

- [x] `Get-OrphanRemovalPlan` in `tidy-lib.ps1`: per vanished folder, act only on a proven-present parent; per record, refuse `managed`, an unknown scope, or an id that does not split.
- [x] Lane 8 in `tidy-machine.ps1` runs the uninstalls with `CLAUDE_PROJECT_DIR` and the working directory on the folder, then removes it through the one-argument `Directory.Delete` (empty only); `-DryRun` and `-UserHomeOverride` keep the handover.
- [x] Skill page and script header: lane 8 now removes, and why.
- [x] Review fixes: names held to `[A-Za-z0-9._-]` with no leading dash and the path must be rooted (Sebastian); `Push-Location` inside the `try`, a failed uninstall handed over again, every left-standing folder counted in the lane tally (Victor).

### TEST

- [x] `tidy-lib.tests.ps1`: the plan's cases (acting folder, gone parent, unprobed parent, managed, unknown scope, unsplittable id, drive root) and the structural asserts on the one directory delete, hostile names and a relative path; 140 passed.
- [x] `tidy-machine -MachineOnly -DryRun` on this machine: lane 8 renders, nothing found.

### DEPLOY: feat/3862-tidy-lane8-removes-records

`tidy-machine` lane 8 now removes an install record whose checkout is gone, instead of printing the
sequence for the reader to run. It recreates the folder empty, uninstalls each record from inside it at
that record's own scope, and removes the folder again only while it is still empty. It acts only when the
folder's parent is still on the machine, so an unmounted drive or an offline sync root stays on report,
and it never touches a `managed` record
([#3862](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3862)).

**Score:** 2

#### What makes this deploy extra special

Running `tidy-machine` now clears the dead install records a moved or deleted checkout leaves behind, in
the same run. Before this, every run handed back the same list of uninstall lines to paste by hand.
`-DryRun` still shows the sequence without running it.

**Score:** 3

#### Pull Request

tidy-machine lane 8 removes a gone checkout's install records itself

