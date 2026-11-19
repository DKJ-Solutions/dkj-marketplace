## feat/4326-forwarder-drift-sessioncheck

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

Inbound #4326 asked for two things. The first, the forwarder's behavioural test in the source, already
stands: `scripts/tests/plugin-payload-lib.tests.ps1` cases F1-F10 (#4259) cover the install record, the
cache fallback, the clone, the English no-plugin error and the repo-root default. The second is still
missing: nothing reports a consumer's `scripts/lib/plugin-scripts.ps1` that has drifted from the
template, so each store keeps an equality assert of its own. That is this branch.

### CREATE

- [x] `hooks/forwarder-drift-sessioncheck.ps1`: picked up by the session-check dispatcher by name; compares the repo's `scripts/lib/plugin-scripts.ps1` with the plugin's `templates/plugin-scripts-forwarder.ps1` (BOM and CRLF/LF ignored), prints `[WARN]` with the copy-over fix when they differ, one quiet line otherwise. Read-only, always exit 0.
- [x] `scripts/tests/suite-groups.json`: the new suite in the `hooks` group.

### TEST

- [x] `scripts/tests/forwarder-drift-sessioncheck.tests.ps1`: 8 pass -- no forwarder, identical, CRLF copy, BOM copy, differing copy, missing template, nonexistent root, the shipped template path.
- [x] `sessioncheck-dispatch` 59/0, `hook-stdin-guard` 65/0, `hook-fail-closed` 51/0, `dev-pages` 829/0; `check-plugin-integrity.ps1` 0 errors.

### DEPLOY: feat/4326-forwarder-drift-sessioncheck

A new session check reports, at every session start, when a repo's `scripts/lib/plugin-scripts.ps1`
differs from the forwarder template the installed `dkj-repo-workflow` ships, and names the one-line fix.
Line endings and a BOM do not count as a difference. A consumer that kept its own test asserting the
copy equals the template can drop it; the forwarder's behaviour was already tested in the source
(#4259). Closes #4326.

**Score:** 2

#### What makes this deploy extra special

Prevents a store's forwarder silently drifting from the template once its local equality test is gone --
a failure that has not happened, but whose only guard so far lived in each store separately.

**Score:** 1

#### Pull Request

Session check reports a plugin-scripts forwarder that differs from the template

