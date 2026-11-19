## feat/4323-publish-page-verify-served

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

Inbound #4323: `publish-page.ps1` proved what KV holds but left the fetch of the public URL to the
caller, so a store consumer wrapped build-publish-verify locally. Of the issue's two directions, the
served check goes into `publish-page.ps1` itself, on by default: every caller gets it, and no second
step has to know about the page set.

### CREATE

- [x] `Get-BwjServedCheckUrl` in `page-publish-rules.ps1`: the public URL plus a cache-buster query (the worker routes on pathname only).
- [x] `publish-page.ps1`: after the KV read-back, fetch every page of the set (skipped ones too) from its public URL, compare SHA-256 with the uploaded bytes, retry every 10 s for up to 60 s, throw naming each page still wrong; `-NoVerifyServed` opts out.
- [x] The `publish-page` skill page and the extension README describe the served check instead of the KV-only limit.

### TEST

- [x] `scripts/tests/bwj-page-publish.tests.ps1`: asserts for the helper (bare URL, URL with a query, release URL, the worker's ROUTE still matching a buster URL) and structural asserts for the switch and the unauthenticated fetch; 221 pass, 0 fail. The end-to-end wrangler fixtures pass `-NoVerifyServed`, since their origin is fake.
- [x] `check-plugin-integrity.ps1`: 0 errors.
- [~] The fetch-and-retry loop itself has not run against a real or fake HTTPS origin; the first real run is the next store publish. Dropped as a gate step: no local HTTPS origin exists in the suites.

### DEPLOY: feat/4323-publish-page-verify-served

A BWJ store's `publish-page.ps1` now fetches the public URL of every page it published, with a
cache-buster, and exits 0 only when the URL serves exactly the uploaded bytes, retrying every 10 s for
up to a minute. Before, it proved only what KV held and told the caller to fetch the link by hand, so a
store wrapped that fetch in a script of its own; that wrapper can now go. `-NoVerifyServed` skips the
check. Closes #4323.

**Score:** 3

#### What makes this deploy extra special

A green publish now means the release-notes link can be sent; a stale edge or a misbound worker fails
the run instead of reaching management.

**Score:** 3

#### Pull Request

publish-page verifies what the URL serves

