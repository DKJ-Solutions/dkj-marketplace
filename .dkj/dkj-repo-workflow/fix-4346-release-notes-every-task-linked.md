## fix/4346-release-notes-every-task-linked

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

The cut records the release's resolved Asana tasks; the release-note-form gate refuses a note that does not link every one

The parking comment's four steps: (1) the cut records the expected tasks where the release-notes step can
read them; (2) `check-release-note-form.ps1` refuses unless every expected link is in the newest note; (3)
the cut-release and prepare-release pages brief a writer with that list; (4) tests.

### CREATE

- [x] `release-lib.ps1`: the task record -- `Get-ReleaseTaskRecordPath`, `ConvertTo-ReleaseTaskRecord`, `Read-ReleaseTaskRecord` (throws on a broken record, never reads it as empty), `Get-ReleaseNoteMissingTasks`
- [x] `cut-release.ps1`: writes `<X.Y.Z>.tasks.json` beside the task-form draft, refuses to overwrite one, and its follow-up lines say to keep every link and brief a writer with the file
- [x] `check-release-note-form.ps1`: a `[TASKS]` finding per missing link, exit 1
- [x] Docs: cut-release skill (step 2 and step 4), prepare-release skill, BWJ `WORKFLOW-portable.md`
- [x] Plugin mirrors of the three scripts updated byte-for-byte

### TEST

- [x] `release-note-form.tests.ps1`: sections 9 and 10, 56 passed, 0 failed
- [x] The gates via open-pr

### DEPLOY: fix/4346-release-notes-every-task-linked

A cut that drafts the audience note as solved tasks (`Get-ReleaseNoteTaskLink`) now writes the tasks it
drafted from beside the note as `<X.Y.Z>.tasks.json`. The release-notes gate (`open-pr -GatesOnly
-NoteTreeOnly`, through `check-release-note-form.ps1`) refuses the note under `[TASKS]` until it links
every one, and names each missing URL. Rewording the items is still fine. Dropping a link is not. The
cut-release and prepare-release pages now say to brief a writer with that file.

**Score:** 3

#### What makes this deploy extra special

A store that publishes task-form release notes can no longer ship a note that lost its task links. A
consumer's v3.1.0 went out twice that way. The gate stops it before the release-notes commit, and the
cut's follow-up lines name the file to brief a writer with.

**Score:** 3

#### Pull Request

Audience release notes: every resolved Asana task linked, counted before the commit

