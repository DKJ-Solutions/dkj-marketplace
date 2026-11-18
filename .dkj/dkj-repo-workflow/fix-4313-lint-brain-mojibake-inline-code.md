## fix/4313-lint-brain-mojibake-inline-code

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

Inbound #4313: `dkj-repo-workflow-bwj`'s `lint-brain.ps1` category B flagged a mojibake pair that a
store's release record QUOTES in an inline code span to describe the repair it made, while
`fix-mojibake.ps1` reports nothing to repair on the same bytes. Verified against the source:
`Test-MojibakeInFile` matched the raw line, with no inline-code handling, where category A already
skips a match inside backticks.

### CREATE

- [x] `Test-MojibakeInFile` removes inline code spans from a `*.md` line before matching, so the rest
  of the line is still checked; `.ps1` lines are left as they are, since a backtick there is
  PowerShell's escape character. The help text for B says so.
- [x] `bwj-lint-brain.tests.ps1`: a quoted pair passes, and its twin (a pair beside the quoted span)
  is still an error.

### TEST

- [x] The suite and the lint gate run under `ship-pr`.

### DEPLOY: fix/4313-lint-brain-mojibake-inline-code

`lint-brain`'s mojibake check (category B) no longer flags a mangled sequence that a Markdown file
quotes inside an inline code span, the same reading category A gives a bare reference in backticks
(#4313). A mangled sequence elsewhere on the same line is still caught.

**Score:** 2

#### What makes this deploy extra special

A BWJ store whose release records document a mojibake repair, such as a line naming the garbled
sequence it replaced, no longer has a red lint gate on correct history. Until now the only way to
turn it green was to delete the example.

**Score:** 3

#### Pull Request

lint-brain category B skips mojibake quoted inside inline code

