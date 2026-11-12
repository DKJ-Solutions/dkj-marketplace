## feat/4005-measure-decision-stops

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

Picked up by a sweep (#4005). This branch is the issue's step 1, the measurement. Step 2, a per-person
dial on how readily a session stops, is conditional on this number and needs a home for a per-person
setting, which is #4006; the issue stays open for it (`-NoResolves`).

#### What the transcripts hold, verified before building

- The call is a `tool_use` named `AskUserQuestion`; its answer is the `user` record whose `tool_result`
  carries that id, with a structured `toolUseResult` holding `questions` (with their options), `answers`
  (keyed by question text) and `annotations` (notes).
- A rejected call carries a string in `toolUseResult`, and no answers.
- An `attachment` record listing deferred tools also names `AskUserQuestion`. Most of the 211 files that
  mention the name contain no call at all; 31 do (37 calls, cross-checked by regex).
- Shape B (a menu in prose) leaves no structured trace, so it is not counted and the report says so.

### CREATE

- [x] `scripts/maintenance/measure-decision-stops.ps1`: per question, recommended as-is, recommended with
  a note, another option, own words, declined, and no-Recommended-offered counted apart; the as-is share,
  per project; `-Project`, `-Since`, `-Json`. Only lines that can carry a stop are parsed (3s over 225
  sessions). Counts only; a project outside a `-GitHub-` path is `(other)`.
- [x] Registered in `shared-scripts-lib.ps1` and mirrored into `dkj-policy`.
- [x] The `measure-decision-stops` skill page, `disable-model-invocation: true`, with the day's figures.
- [x] Listed in the scripts README and the ADOPTION skill list.

### TEST

- [x] `scripts/tests/measure-decision-stops.tests.ps1` (in the `tools` suite group): every verdict, the
  share's denominator, the single-answer regression, no transcript text or local path in either output,
  the filters, exit 0. 33 asserts.
- [x] Run against this machine's 225 real sessions. The first run read 0 stops because a one-element
  answer unrolled into a string and every session holding a stop threw inside a swallowed catch; fixed,
  and the unreadable count is now printed rather than swallowed.
- [x] Review chain (Victor, Sebastian, Edith) on the first commit; applied in the second: a whole answer
  is matched as one label before a multi-select is split (a label holding a comma read as own words),
  labels are trimmed like answers, `-Since` is a UTC midnight and leaves out an unreadable timestamp, a
  question record without its text no longer throws the session away, and the page says the repo name is
  printed, how a declined call counts, and what else the report shows. The suite covers the comma label.
  The real corpus measured the same after the fixes.
- [x] The first `ship-pr` stopped at `shared-scripts.tests.ps1`: every shared entry point must resolve the
  repo root dual-context. The script now does, and uses it to mark the row of the checkout it runs from in
  the per-project report (`ThisCheckout` in the JSON); the suite asserts the mark (35 asserts).

### DEPLOY: feat/4005-measure-decision-stops

A new skill, [`measure-decision-stops`](../../plugins/dkj-policy/skills/measure-decision-stops/SKILL.md),
counts how often sessions on this machine stopped to ask the owner a menu question (`AskUserQuestion`)
and how each question was answered: the option marked Recommended as-is, the same with a note, another
option, the owner's own words, or declined. The headline is the share of questions that offered a
Recommended option and got it unchanged. Like `measure-closeouts`, it reads transcripts in place and emits
only counts. Close-outs of shape B, a menu written in prose, are not counted, and the report says so. On
the day it was written it measured 17 of 23 (74%), against the owner's estimate of about 90% (#4005).

**Score:** 3

#### What makes this deploy extra special

A consumer's owner can run `/measure-decision-stops` to see how predictable their own answers are before
deciding how readily sessions should ask them. It costs nothing until typed (`disable-model-invocation`).

**Score:** 2

#### Pull Request

measure-decision-stops: count decision stops and how often the owner picks Recommended

