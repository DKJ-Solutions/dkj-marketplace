## fix/3932-get-raw-says-why

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

Closes #3932. The issue asks for a diagnostic, not a repair: make `Get-Raw` say why it returned what it
did, put that in the failing assert's message, and decide on the cause from the next recurrence. No
timeout is raised here.

### CREATE

- [x] `Get-Raw` records `$script:RawWhy`: the status line, elapsed ms and length on an answer; the
      exception type, its inner type and elapsed ms on a throw.
- [x] `Assert-True` takes an optional `-Why`, printed under a `[FAIL]` only.
- [x] The three group-3 asserts that read `/consumers`, `/consumers/other` and the home page with the
      admin up pass their fetch's `RawWhy`.

### TEST

- [x] `consumer-dashboard: 251 passed, 0 failed` locally, with a new assert on `RawWhy`'s shape.
- [x] The throw path checked in a scratch copy with a 1 s timeout against a listener that never answers:
      `threw IOException (SocketException) after 1036 ms`.

### DEPLOY: fix/3932-get-raw-says-why

When a group-3 page assert in the consumer-dashboard suite fails, it now also prints what the request
got: the status line and how long it took, or the exception and how long until it was thrown. The next
CI recurrence can then say whether the page was slow or wrong.

**Score:** 1

#### What makes this deploy extra special

N/A: a test suite of this repo, which no consumer runs.

**Score:** N/A

#### Pull Request

consumer-dashboard tests: a failing page assert says whether the page was slow or wrong

