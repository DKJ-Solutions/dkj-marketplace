## fix/4252-refresh-stale-statusline-shim

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

Inbound #4252, measured in a consumer's v7.0.0 migration: a shim placed before the rename matches
`dkj-policy@*` install records, which no longer exist, so the progress bar goes dark, and a re-run of
`adopt-statusline.ps1 -Apply` kept it as `[keep]`.

### CREATE

- [x] Refresh an existing shim that carries this command's provenance line but differs from the current
  template (`[refresh]` / `[would refresh]`); keep an identical one, and keep a file without the
  provenance line with a note and the repair line.
- [x] Mirror into `plugins/dkj-repo-workflow/`, correct the "never rewritten" comments, one sentence in
  the adopt skill, three new cases in `adopt-statusline.tests.ps1`.

### TEST

- [x] `adopt-statusline.tests.ps1` standalone: all 90 asserts pass, the refresh, keep and foreign-file
  cases among them. The full gate runs in `ship-pr`.

### DEPLOY: fix/4252-refresh-stale-statusline-shim

`adopt-statusline.ps1 -Apply` now replaces a progress-bar shim it placed before v7.0.0 (#4252). That shim
looked for the old `dkj-policy` plugin id, so after the rename the progress bar went dark, and a re-run
left the stale shim in place. A file at that path that this command did not place is still left alone,
with the line that repairs it.

**Score:** 3

#### What makes this deploy extra special

A consumer whose progress bar went dark after 7.0.0 gets it back by re-running `adopt-statusline.ps1 -Apply`,
without deleting the file by hand first.

**Score:** 3

#### Pull Request

adopt-statusline refreshes a plugin-placed shim that differs from the current template

