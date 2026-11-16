## fix/4148-layout-floor-pin

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

#4148: a credential-holding runner pinned below the release that moved the workflow folder to
`.dkj/dkj-policy/` (v6.10.0, #3870) looks in the old place and reports OK. The reason was verified, not
inferred: v5.18.0's `Get-BranchFilePaths` names `Directory = 'dkj-policy'`.

#### Decided in this branch

- `check-unfolded-entry` does NOT fail loud on a missing workflow folder. The copy that failed green is the
  pinned old one, which no change here can reach, and a repo with no workflow folder yet is a legitimate state.
  The floor below is what catches the next layout move: raise it in the release that moves a path.
- Re-pinning the consumers is work in their own repos; the register now names each one as an `[ERROR]`.

### CREATE

- [x] `Get-SharedScriptLayoutFloor` in `consumer-runner-lib.ps1`: v6.10.0, `.dkj/dkj-policy`, #3870
- [x] Check 6d (`Write-RunnerPinFinding`) reports a pin below the floor as `[ERROR]` where the consumer carries the folder, `[INFO]` otherwise, never escalating on an unknown
- [x] The local read tests the checkout; the `-RemoteRunners` read asks for the folder in the same GraphQL call

### TEST

- [x] `consumers.tests.ps1`: 12u-12w (local: moved, not moved, at the floor) and 13c3 (remote: moved, not moved, field absent); 431 pass, 0 fail
- [x] Measured against the real register with `-RemoteRunners`: `[ERROR]` on mesowise (v5.13.0), music-library (v5.8.0), recipes (v5.11.0) and xoxowildhearts (v5.18.0); smartwatchbanden (v6.12.0) stays `[INFO]`

### DEPLOY: fix/4148-layout-floor-pin

The consumer register (`check-consumers.ps1`, check 6d) now reports a write runner pinned below v6.10.0 as an
`[ERROR]` when the consumer already carries `.dkj/dkj-policy/` ([#4148](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4148)).
Such a pin's fold and unfolded-entry scripts look for branch documents in the old `dkj-policy/` folder, find
none, and report OK: measured in a consumer, two merges went green over an entry that was never folded. Run
with `-RemoteRunners` it flags four consumers today; a pin that is merely behind stays `[INFO]`.

**Score:** 3

#### What makes this deploy extra special

N/A -- the register runs in this repo only; nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

The consumer register flags a write runner pinned below the .dkj/ layout floor as an error
