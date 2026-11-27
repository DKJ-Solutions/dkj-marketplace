## fix/4549-admin-probe-timeout

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

- [x] Verify #4549's reason in the code: the `/whoami` probe is uncached (`serve-consumer-dashboard.ps1` L409, L599) and `Get-LoopbackWhoami` gives connect + read one 500 ms deadline

### CREATE

- [x] `serve-consumer-dashboard.ps1`: a new `-AdminProbeTimeoutMs` (default 500) feeds both probes
- [x] `consumer-dashboard.tests.ps1`: the fixture's product server starts with `-AdminProbeTimeoutMs 5000`

### TEST

- [x] `consumer-dashboard.tests.ps1` locally: 258 passed, 0 failed

### DEPLOY: fix/4549-admin-probe-timeout

The consumer-dashboard suite's admin-card assert no longer flakes on a busy CI shard (#4549, superseding the record #3856). The product server asked the freshly started plugin admin for `/whoami` with a fixed 500 ms deadline, which a cold PowerShell admin on a four-lane shard can miss, so the home page rendered "Admin is not running" behind a healthy 200. `serve-consumer-dashboard.ps1` now takes that deadline as `-AdminProbeTimeoutMs` (default 500, unchanged for a browser visit), and the fixture raises it to 5000 ms.

**Score:** 2

#### What makes this deploy extra special

N/A -- a test fixture and a test-only server parameter; nothing a consumer runs behaves differently.

**Score:** N/A

#### Pull Request

consumer-dashboard.tests: the product server's admin probe deadline is a parameter the fixture raises

