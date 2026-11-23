## fix/4428-safe-issue-body-append

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

Inbound #4428: `report-issue` told a session to add the reach label with
`gh issue edit --body "<current body + the ## Why section>"`; on PowerShell the natural read of the
body is an array of lines, and concatenating onto it flattened a store issue's body to one line.
Replace that with a file-based recipe (`gh` writes the body, append, `--body-file`), and point step 3's
Asana-marker append at it. The optional guard on a collapsed body is left out: the recipe removes the
cause, and nothing has slipped past it yet.

### CREATE

- [x] `skills/report-issue/SKILL.md` step 1: the PowerShell recipe for appending the `## Why` section,
  with the measurement.
- [x] Step 3's Asana-marker append points at the same recipe.

### TEST

- [x] Ran the recipe read-only against #4428 into the scratchpad: 9 lines before, 12 after the
  appended section, no BOM (first bytes `35,35,32`), a non-ASCII `é` intact. The naive
  `gh ... --jq .body` read returned `Object[]` with 9 elements, confirming the reported cause.

### DEPLOY: fix/4428-safe-issue-body-append

Adding the reach label to an issue that is already filed no longer flattens its body on PowerShell.
[`report-issue`](../../plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-bwj/skills/report-issue/SKILL.md)
now has `gh` write the current body to a file, appends the `## Why` section to that file and passes it
back with `--body-file`, where it used to rebuild the body as a PowerShell string, which joined every
line with a space. Step 3's Asana link is appended the same way (#4428).

**Score:** 2

#### What makes this deploy extra special

A store session that adds the reach label afterwards keeps the issue's headings, paragraphs and
`filed-with` marker intact, so nobody has to repair the body by hand.

**Score:** 2

#### Pull Request

report-issue appends to an issue body without flattening it on PowerShell

