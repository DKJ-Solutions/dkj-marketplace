## fix/3932-stub-gh-in-fixture

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

#4444's Server-Timing header named the cause on its own CI run (45214738882): `gh;dur=16517` of a 16649 ms
overview, every other step about 120 ms together, and the same gh call from the test process 69 ms a moment
later. The fixture server ran the real gh -- and locally, logged in, the real GitHub API.

### CREATE

- [x] group 3 starts its server with a stub `gh.cmd` first on PATH that exits 4 at once, as an unauthenticated gh does
- [x] the 90 s wait, the `[TIMING #3932]` lines and the CI-only timing block are removed, as the issue asked once the cause was named
- [x] a new assert: the overview says GitHub could not be read, which proves the stub was the gh the server ran

### TEST

- [x] `consumer-dashboard.tests.ps1` locally: 258 passed, 0 failed, with a logged-in gh on this machine
- [x] lint + all suites via `open-pr.ps1`

### DEPLOY: fix/3932-stub-gh-in-fixture

`consumer-dashboard.tests.ps1` no longer fails on CI on the Consumers overview (#3932). The fixture server ran the
real `gh`, whose first call took 16.5 s on a busy runner and pushed the page past the 15 s receive timeout; it now
runs a stub that fails at once, so the group never reaches outside its fixture -- locally it no longer reads the
real GitHub organisation either. The diagnostic wait and timing lines are gone; the Server-Timing header stays.

**Score:** 3

#### What makes this deploy extra special

N/A: a test fixture of this repo; nothing a plugin user installs changes.

**Score:** N/A

#### Pull Request

The Consumers fixture server runs a stub gh, so the overview no longer waits on a cold gh

