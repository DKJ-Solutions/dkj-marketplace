## fix/4236-runner-path-at-pin

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

Issue #4236: check 6 compared every runner path with this tree's working copy, ignoring the `ref:` the
runner fetches, so pinned runners whose paths exist at their pin were reported missing after #4209.

### CREATE

- [x] `consumer-runner-lib.ps1`: references carry their `Ref`; `Test-SharedScriptReference -AtPinnedRef`
  judges a pinned path (40-hex SHA or `vX.Y.Z`) with `git cat-file -e <ref>:<path>` and suggests moves
  from that ref's tree; an unresolvable pin comes back `Unjudged`
- [x] `check-consumers.ps1`: check 6 passes `-AtPinnedRef`, names the ref in the `[ERROR]`, and reports an
  unresolvable pin as `[INFO]`, never as a missing path

### TEST

- [x] `consumers.tests.ps1` scenario 12x: a two-commit fixture repo (SHA pin, tag pin, bare version,
  moving ref, switch off, missing at the pin, unresolvable pin) plus two end-to-end runs; suite 442/0

### DEPLOY: fix/4236-runner-path-at-pin

The register's check 6 (`check-consumers.ps1`, behind `consumer-sessioncheck`) now judges a runner
whose shared-scripts checkout is pinned at the tree of that pin instead of at this repo's working copy
(#4236). Before, five runners pinned at v6.12.0 in one consumer were reported as `[ERROR]` "does not
exist here" after #4209 renamed the plugin folder on main, while every path existed at their pin, and
the suggested new path would have broken them. A path missing at its pin is still an `[ERROR]`, now
naming the ref and suggesting a location from that ref's tree. A pin this checkout cannot resolve is
an `[INFO]`. Runners on a moving ref are judged as before.

**Score:** 2

#### What makes this deploy extra special

For the maintainer of a consumer: the session check no longer reports runners pinned to a release as
broken when only main has moved, so it no longer points them at a repair that would break working
runners. A genuinely missing path at the pin is still reported, with the ref named.

**Score:** 3

#### Pull Request

consumer-sessioncheck judges a pinned runner's script path at its pin, not at main

