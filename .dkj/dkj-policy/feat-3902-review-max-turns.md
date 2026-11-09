## feat/3902-review-max-turns

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

The owner's decision on #3902 (November 8, 2026): keep the OAuth subscription token, no API key; read
`num_turns` from recent green review runs and set `--max-turns` just above that ceiling. No `--model`
was asked for.

#### The measurement

`num_turns` from the logs of the last 40 green `claude-code-review` runs (November 9, 2026): 4 to 90,
median 12. The 90 is a real review of a large PR (#3896's evals branch), and the next highest is 44.

### CREATE

- [x] `claude_args` in `.github/workflows/claude-code-review.yml` gains `--max-turns 100`, with the
  measurement and how to re-take it in the comment beside it.

### TEST

- [~] Not testable on this PR: the action skips a run whose workflow file differs from `main`'s and goes
  green without reviewing (the file's own header). The first PR after the merge exercises it.

### DEPLOY: feat/3902-review-max-turns

The Claude review workflow now stops a run at 100 turns, so one review cannot drain the subscription
quota its token shares with interactive work. The bound sits just above the measured ceiling: over the
last 40 green runs `num_turns` was 4 to 90, median 12. The token stays the OAuth subscription token, as
the owner chose (#3902).

**Score:** 2

#### What makes this deploy extra special

N/A: the review workflow runs in this repo's CI only, and nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

The Claude review workflow is bounded at 100 turns

