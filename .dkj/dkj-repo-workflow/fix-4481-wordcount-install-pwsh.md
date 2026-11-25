## fix/4481-wordcount-install-pwsh

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

#4481: a cloud session had a shell but no PowerShell, so `count-words.ps1` could not run and the session
rebuilt the counter in Python by hand. The owner decided (2026-11-25, on the issue) against a Python twin:
the session installs `pwsh` first, and falls back to the existing no-shell path where that fails.

### CREATE

- [x] Step 1 of `plugins/dkj-subagents/dkj-subagents-lifehub/skills/dossier-wordcount/SKILL.md`: a shell
      without PowerShell installs `pwsh` and runs the same line with it; never a re-implementation; a
      failed install falls back to the hand count.

### TEST

- [x] Text-only change to a skill page; the gates run through `ship-pr`.

### DEPLOY: fix/4481-wordcount-install-pwsh

`dossier-wordcount` now says what a session with a shell but no PowerShell does: install `pwsh` and run
the one counter, rather than rebuilding it in another language, so the word count means the same whoever
wrote last (#4481).

**Score:** 1

#### What makes this deploy extra special

A lifehub owner whose dossiers are written from a cloud session gets counts from the same counter as on
their own machine, instead of a per-session rebuild that can drift.

**Score:** 2

#### Pull Request

dossier-wordcount: install pwsh in a shell without PowerShell

