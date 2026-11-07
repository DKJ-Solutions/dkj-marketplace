## fix/3884-pr-template-folder-repoint

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

Issue #3884: on the folder move, `adopt-workflow-folder -Apply` repoints `repo-config.ps1` and
`.gitignore` but never an existing `.github/pull_request_template.md`, whose first-line comment keeps
naming `dkj-policy/<branch>.md`. Add it to the same repoint list, bounded to that first `<!--` line.

### CREATE

- [x] Third repoint row in `adopt-workflow-folder.ps1` (both copies, byte-identical): the template's
  opening comment line only.
- [x] Fixture template in the move test of `adopt-workflow-folder.tests.ps1`: the dry run names the
  repoint, `-Apply` repoints the comment, and the body below it stays as written.

### TEST

- [x] `adopt-workflow-folder.tests.ps1` alone: 168 of 168 asserts pass. The full gate runs in `ship-pr`.

### DEPLOY: fix/3884-pr-template-folder-repoint

`adopt-workflow-folder -Apply` now also repoints the folder in the first-line comment of an existing
`.github/pull_request_template.md` when it moves `dkj-policy/` to `.dkj/dkj-policy/`. Before this, the
comment kept naming `dkj-policy/<branch>.md` after the move, because the scaffold never overwrites a
template that is already there (#3884). The rest of a hand-edited template is left alone, and the dry
run names the repoint like the other two.

**Score:** 2

#### What makes this deploy extra special

A consumer that runs the move on this release gets a PR template naming the folder its branch documents
actually live in. Six consumers that moved on v6.10.0 fixed the comment by hand or still carry the old one.

**Score:** 2

#### Pull Request

adopt-workflow-folder repoints the PR template's folder comment on the move

