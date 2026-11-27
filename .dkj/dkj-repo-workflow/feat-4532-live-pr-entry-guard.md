## feat/4532-live-pr-entry-guard

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

#### Shape

Option 2 from #4532, as the parking comment chose it: a PreToolUse guard on `gh pr create` whose base is
the declared live branch, because the leak is the hand-typed PR. A `-Base` route in open-pr/ship-pr would
only help a session that chose to use it.

### CREATE

- [x] Sylvester: `hooks/guard-live-pr-entry.ps1` -- reads the live branch as entry-gate-live-sessioncheck does, finds a running `gh pr create` through command-guard-lib's segments, runs `check-branch-entry.ps1` (the repo's own copy first) on the head and refuses on its exit 1; fails open with additionalContext
- [x] Sylvester: registered in `hooks/hooks.json` behind a shell pre-gate, fail-open like the bwj guards
- [x] Tessa: the adopt skill's branch-entry section names the guard

### TEST

- [x] Tycho: `scripts/tests/guard-live-pr-entry.tests.ps1` -- live malformed and valid, `--base main` untouched, a variable base, the flag spellings, a mention in a grep (15 asserts green)
- [x] The hooks.json shell wrapper run end to end through bash: refuses a malformed live PR (exit 2), passes `git status` (exit 0)
- [x] A UTF-8 BOM on stdin silenced the first version; the payload is now trimmed to its first `{`, as guard-stale-paste-block does

### DEPLOY: feat/4532-live-pr-entry-guard

The plugin's own scripts and hooks gained a new PreToolUse guard, `guard-live-pr-entry`. It meets a
hand-typed `gh pr create` whose base is the live deploy branch a repo declares, and refuses it while the
head branch's changelog entry is not written, using the same check the CI gate runs.

**Score:** 2

#### What makes this deploy extra special

A hotfix PR to the live branch is now checked before it opens, even when the live branch's own CI copy
lags the trunk's. A malformed DEPLOY section can no longer land there unjudged and strand the fold later.
Repos that declare no live branch see no change.

**Score:** 2

#### Pull Request

A hotfix PR to the live branch is checked for a written changelog entry before it opens

