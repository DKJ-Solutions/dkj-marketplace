## fix/3729-preflight-backup-timeout

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

Inbound #3729, ask 1: `live-preflight` exposes no way to give the backup a longer fill wait, so a large
store's preflight refuses a copy that is still filling. Verified on the tree: `backup-live-theme.ps1`
defaults `-TimeoutMinutes` to 20 and `live-preflight.ps1` called it with `-Store` only, inside a flat
2700 s outer bound. Asks 2 and 3 are their own subjects, filed as #3732 and #3733.

### CREATE

- [x] `live-preflight.ps1`: a `-BackupTimeoutMinutes` (default 20, 1-600) passed to the backup as `-TimeoutMinutes`, with the outer capture bound growing with it (the wait plus the same 25 minutes the flat 2700 s allowed).
- [x] Mirror both scripts into `plugins/dkj-subagents/dkj-subagents-shopify/scripts/task/`; document the parameter on the `live-preflight` skill page and in `backup-live-theme`'s help.

### TEST

- [x] Both scripts parse; the script itself is not driven by a suite (it reaches a real store), as its NOTES state. The gates run in `ship-pr`.

### DEPLOY: fix/3729-preflight-backup-timeout

`live-preflight` takes a `-BackupTimeoutMinutes` and passes it to `backup-live-theme` as its
`-TimeoutMinutes`, so a store whose live theme takes longer than 20 minutes to copy no longer has to run
the backup by hand and then the preflight with `-SkipBackup`
([#3729](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3729)).

**Score:** 3

#### What makes this deploy extra special

A Shopify store with a large live theme can now finish a release-day preflight in one run:
`live-preflight -BackupTimeoutMinutes 45`. Measured on a 909-file theme, the copy was still filling at the
20-minute default.

**Score:** 3

#### Pull Request

live-preflight passes a longer backup timeout through to backup-live-theme

