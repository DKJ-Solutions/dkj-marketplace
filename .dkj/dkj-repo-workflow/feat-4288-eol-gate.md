## feat/4288-eol-gate

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

Inbound #4288: a consumer carried its own `check-eol.ps1`; ship one shared copy and run it from `open-pr`
before the push, so no consumer grows its own.

### CREATE

- [x] `scripts/lint/check-eol.ps1` plus its byte-identical mirror in `dkj-repo-workflow`, registered in `shared-scripts-lib.ps1`
- [x] `open-pr.ps1` (both copies) runs it before the push, guarded on the script existing; `-Force` downgrades it to a warning
- [x] one row in the scripts README, one bullet in `CONTRIBUTING-portable.md`'s gate list

### TEST

- [x] `scripts/tests/check-eol.tests.ps1`: 16 passed, including a scratch repo with a CRLF blob under an `eol=lf` pin (exit 1) and a run outside a repo (exit 2)
- [x] the script against this repo: `[OK]`, 1261 files read; `check-plugin-integrity` 0 errors; `shared-scripts.tests.ps1` green; mirrors in sync

### DEPLOY: feat/4288-eol-gate

`open-pr` now refuses a branch whose git index carries a file with CRLF while `.gitattributes` pins it to
`eol=lf`, and prints the one-line repair (`git add --renormalize -- <paths>`). The check is
`scripts/lint/check-eol.ps1`, shared through the `dkj-repo-workflow` mirror and runnable as a CI step, so a
consumer's own copy can go (#4288).

**Score:** 3

#### What makes this deploy extra special

A consumer on Windows whose `.gitattributes` pins LF no longer meets an EOL-only modification at `ship-pr`'s
fast-forward (#4144): `open-pr` catches the CRLF blob before the push, with the repair line printed.

**Score:** 2

#### Pull Request

Ship the CRLF-under-eol=lf index check as a shared gate

