## fix/3881-legacy-names-empty-entry

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

- [x] `Get-BranchFileLegacyNames` drops its empty rows at the source, in both byte-identical copies of `entry-scaffold-lib.ps1`

### TEST

- [x] `branch-document-path.tests.ps1` holds an unmoved tree's legacy list to no empty entry and binds it the way `new-branch.ps1` does: 2 failed without the fix, 55 of 55 passed with it

### DEPLOY: fix/3881-legacy-names-empty-entry

`new-branch` writes the branch document again in a repo that has not moved to `.dkj/dkj-policy/` yet. There
`Get-BranchFileLegacyNames` returned an empty row (`PolicyFolderPerBranch` is `''` by design in an unmoved
repo), and `new-branch.ps1` binds that list to a Mandatory `[string[]] -Legacy`, which refuses an empty
element: the branch was created and the run died before its document (#3881). The list now drops empty rows
at its one source, and `branch-document-path.tests.ps1` pins it against an unmoved fixture.

**Score:** 3

#### What makes this deploy extra special

A consumer still on the root `dkj-policy/` folder could not start a branch through `new-branch` on v6.10.0:
the branch appeared and its document did not. After this release it works without moving the folder first.

**Score:** 4

#### Pull Request

new-branch fails in an unmoved consumer: empty string in the -Legacy list

