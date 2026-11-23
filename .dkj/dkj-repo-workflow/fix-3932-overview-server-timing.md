## fix/3932-overview-server-timing

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

#3932: on CI the Consumers overview took 13 s (once past the 15 s receive timeout) where it takes about 0.1 s
locally, and the external calls timed from the test process were cheap. Only the server can say which of its
steps spent the time, so it now says so per request.

### CREATE

- [x] `Get-DkjReposModel` times the GitHub read and the checkout scan apart, in its Meta (`GhMs`, `ScanMs`)
- [x] the `/consumers` routes send a `Server-Timing` header naming each step that request ran: register, gh, scan, cards, page
- [x] `consumer-dashboard.tests.ps1` prints both pages' Server-Timing on its `[TIMING #3932]` line and asserts the header's shape

### TEST

- [x] `consumer-dashboard.tests.ps1` locally: 257 passed, 0 failed; locally `gh;dur=1083` of a 1199 ms overview
- [x] lint + all suites via `open-pr.ps1`

### DEPLOY: fix/3932-overview-server-timing

The product's Consumers pages now send a `Server-Timing` header naming each step a request ran and how long it
took: the register check, the GitHub read, the checkout scan, the cards and the page. The page itself does not
change. The group-3 test prints it on its `[TIMING #3932]` line, so the next CI run of
`consumer-dashboard.tests.ps1` says which step made the overview take 13 s on CI (#3932).

**Score:** 2

#### What makes this deploy extra special

N/A: a diagnostic header on a local developer page, read by this repo's own test.

**Score:** N/A

#### Pull Request

Consumers overview names its slow step in a Server-Timing header

