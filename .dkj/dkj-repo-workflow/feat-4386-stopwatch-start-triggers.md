## feat/4386-stopwatch-start-triggers

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

Inbound #4386: a run starts only from a `stopwatch:` first line. Verified on pickup: the hook's cheap
path exits on any payload without the literal `stopwatch:`. Add the slash command and an imperative
phrase in the owner's own words, both decided in the pure lib.

#### Unverified

The slash route assumes the `UserPromptSubmit` payload carries the command as typed
(`/dkj-repo-workflow:stopwatch-start <label>`); no live session confirmed it.

### CREATE

- [x] `stopwatch-lib.ps1`: `Get-StopwatchPromptSlashStart`, `Get-StopwatchPromptPhraseStart` and
  `Get-StopwatchPromptStart` (marker, then slash, then phrase); `Invoke-StopwatchHookEvent` takes
  `-PreparedLabels`, so a prepared card's label wins for the phrase.
- [x] `stopwatch-hook.ps1`: cheap path widened to `(?i)stopwatch|time this`; calls the new start.
- [x] New skill `stopwatch-start` (`disable-model-invocation: true`).
- [x] Texts that said a run starts only from `stopwatch:`: the hub tile, the Stopwatch pages' prepared
  and footer lines, the logbook lib, `stopwatch-prepare` (page and script), the Admin README.

### TEST

- [x] `scripts/tests/stopwatch.tests.ps1`: 356 passed, 0 failed, with negative cases for a sentence
  about the stopwatch, a question, a phrase on a later line and a phrase inside a pasted block.
- [x] `check-plugin-integrity.ps1`: 0 errors.
- [ ] The owner looks at the changed lines on Admin's Stopwatch overview, a prepared card's page and
  the hub tile.

### DEPLOY: feat/4386-stopwatch-start-triggers

A Stopwatch run now starts in three ways: the `stopwatch:` first line, the slash command
`/dkj-repo-workflow:stopwatch-start <label>`, or an imperative phrase in the owner's own words such as
"use the stopwatch", "time this" or "gebruik de stopwatch" (#4386). Pasted text and a sentence about the
stopwatch start nothing.

**Score:** 3

#### What makes this deploy extra special

Asking for the stopwatch the way you would say it ("prepare a release, use the stopwatch") now times
that assignment. Before, it started nothing, and the only fix was another prompt that began with
`stopwatch:`.

**Score:** 3

#### Pull Request

Stopwatch: start a run from a slash command or a plain-language phrase

