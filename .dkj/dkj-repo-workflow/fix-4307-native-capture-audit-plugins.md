## fix/4307-native-capture-audit-plugins

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

[#4307](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4307): the bounded-site audit in
`native-capture.tests.ps1` scanned only `scripts/`, so a bounded `Invoke-NativeCapture` in a plugin-only
script was never counted or judged. This branch widens the scan to every plugin `.ps1`, drops
byte-identical mirrors by hash, and audits each site that newly appears.

### CREATE

- [x] The audit scans `scripts/` plus every `plugins/**/*.ps1` outside `/tests/`. A plugin file
  byte-identical to a `scripts/` file is a mirror and is counted once. Plugin exemption keys are
  relative to the repo root.
- [x] Six newly counted sites, each audited. The count moves from 123 to 129, with one audit line:
  - The two `day-plan.ps1` search reads and `live-direct-writes.ps1`'s `Invoke-GhChecked` judged a
    non-zero exit without asking whether it was measured. They are repaired with
    `Test-NativeExitMeasured` and `Get-NativeExitLabel`.
  - `release-freshness-sessioncheck.ps1` is exempt as a deliberate fail-safe.
  - `consumer-sessioncheck.ps1` and `measure-buybox.ps1` were already judged.
- [x] Asserts that the scan includes plugin files and skips mirrors, so it cannot silently fall back
  to `scripts/` alone
- [x] A red-case test for each repaired guard. One of them caught a doubled "exit exit 1" in the repair's
  own wording, which is fixed.

### TEST

- [x] `native-capture` 360/0, `dayplan` 83/0, `shopify-live-direct-writes` 56/0, `exception-message-guard` 18/0
- [x] `check-plugin-integrity.ps1` 0 errors
- [x] The full gate runs in `ship-pr`

### DEPLOY: fix/4307-native-capture-audit-plugins

The bounded-native-call audit now covers plugin-only scripts, not just the repo's `scripts/` folder.
Widening it found two real gaps, now repaired:
- Admin's day-plan search could fail with a blank exit code.
- `live-direct-writes` could report an unmeasured `gh` exit as a number.

Both now say plainly when the exit code could not be measured. Fixes
[#4307](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4307).

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Widen native-capture's bounded-site audit to plugin-only scripts
