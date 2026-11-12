## feat/4008-owner-load-signals

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

#### Scope

Issue #4008, on the owner's definitions recorded there (DaveKJohn's account davekokbwj, November 12, 2026).
The Progress page's three owner-load signals are read from the session transcripts, in the same single pass
that already splits a run into phases, and cached with them per run:

- **Questions asked:** each `AskUserQuestion` call, or one for a turn that asked none and whose last text
  ends in a question mark.
- **Steps by hand:** each `! <command>` the owner typed (a user record opening with `<bash-input>`), plus
  each shell call that sets `awaiting-review-dev` (a park for the owner's look).
- **Waited on you:** the gap between a turn's last write and the owner's next prompt in the same transcript,
  counted whole up to 15 minutes and not at all above (away). The prompt that starts a run brings the gap
  before it, so the reading-and-deciding time between runs, which the Logbook's in-run idle phase never saw,
  is counted. A task notification or a command's output is not a prompt.

A visible result, so the branch parks for the owner's look.

### CREATE

- [x] `stopwatch-lib.ps1`: `Read-StopwatchTranscriptEvents` also returns the owner's prompts (with their gap
      and whether they were a `!` command), the questions and the review parks; the new pure
      `Get-StopwatchOwnerLoad` counts them inside a window; the transcript cache stores them per run as
      `load`, and reads an entry cached without one once more to gain it.
- [x] `progress-lib.ps1`: the team's numbers take the Load; "Waited on you" and the chart's waiting are the
      prompt gaps (the idle time where no Load was read); the two "not recorded yet" tiles carry the counts,
      and a note says what each signal counts.
- [x] `serve-general-pages.ps1`: `/dev/progress` hands the cached Load to the page.
- [x] Tests: `stopwatch.tests.ps1` (a fixture of every signal, the window, the cap, the cache gaining Load;
      the covered-with-no-session assert now writes its entry with a load), `progress.tests.ps1` (the Load's
      waiting, the counts, the tiles and the note).
- [x] The Admin README describes what the three signals count.
- [~] Owner looks at the Progress page and says whether the three numbers read right. Not done as a
      separate look: davekokbwj approved the branch through issues-sweep-reviews on 2026-11-12 without one.

### TEST

- [x] `progress` (35) and `stopwatch` (318) green standalone.
- [x] Previewed against this repo's own Logbook (an Admin from this branch on port 4896): 22 assignments,
      6:17:47 worked, 14:02 waited on you (4%), 6 questions asked, 2 steps by hand, 20 chart columns, and the
      note under the tiles.

### DEPLOY: feat/4008-owner-load-signals

The Progress page's owner-load signals are recorded. The transcript cache gains a `load` per run, and an
entry cached before it is read from the transcripts once more; nothing else in the store changes.

**Score:** 3

#### What makes this deploy extra special

On Admin's Progress page, "Questions asked" and "Steps by hand" now show numbers instead of "not recorded
yet", and "Waited on you" counts the time you spend reading and deciding before each prompt (up to 15 minutes;
a longer gap reads as away), so it no longer shows close to 0% when you were the one the work waited on.

**Score:** 3

#### Pull Request

Progress page: record the owner-load signals -- questions asked, steps by hand, and the wait between prompts

