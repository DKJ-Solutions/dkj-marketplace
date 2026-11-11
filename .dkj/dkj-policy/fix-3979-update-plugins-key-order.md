## fix/3979-update-plugins-key-order

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

Issue #3979, and the second measurement in its comment: `claude plugin install/update` re-serializes
`.claude/settings.json` with another key order or a final newline. #3792's restore holds a file to
`git diff --ignore-cr-at-eol` alone, which such a rewrite does not pass, so the run asked for a commit
that would only churn the file, and every later `-AllCheckouts` skipped the checkout as dirty. Cause
verified in `Restore-EolOnlyClaudeChange` and the pre-run guard in `scripts/task/update-plugins.ps1`.

### CREATE

- [x] `Restore-NoMeaningClaudeChange` replaces `Restore-EolOnlyClaudeChange`: per ` M` file, line endings only as before, or a `.json` whose working copy and index copy parse to the same value (`ConvertTo-CanonicalJson`, `Test-JsonMeaningEqual`)
- [x] The pre-run guard restores such a change instead of skipping the checkout; `-DryRun` only announces it (`-TestOnly`)
- [x] The plugin mirror `plugins/dkj-policy/scripts/task/update-plugins.ps1` is byte-identical
- [x] `update-plugins.tests.ps1` scenarios 27-29: a run's key-order rewrite restored, an earlier one announced under `-DryRun` and restored before a real run; 25's message assert follows the new wording

### TEST

- [x] `update-plugins.tests.ps1` alone: 173 pass, 0 fail
- [x] Negative control: with the JSON comparison forced to "different", 11 asserts in 27-29 go red

### DEPLOY: fix/3979-update-plugins-key-order

`update-plugins -AllCheckouts` no longer leaves a checkout behind because `claude plugin install/update`
re-serialized its `.claude/settings.json` with another key order or a final newline (#3979). A `.json`
file under `.claude/` whose parsed value is unchanged is now treated like #3792's line-ending-only
rewrite: restored to the committed bytes after the run instead of named as "review and commit", and
restored before the run instead of skipping the checkout as dirty. A real edit still differs once
parsed, so it is still skipped or named. `-DryRun` only says the restore would come.

**Score:** 3

`update-plugins -AllCheckouts` in a consumer stops skipping a checkout whose only change is such a
rewrite, so that repo takes plugin releases again without a hand `git restore`.

**Score:** 3

#### Pull Request

update-plugins -AllCheckouts restores a .claude/ rewrite that changes key order or a final newline only

