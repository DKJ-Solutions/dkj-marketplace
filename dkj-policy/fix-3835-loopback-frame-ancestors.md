## fix/3835-loopback-frame-ancestors

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

#3835: the two loopback servers send no `frame-ancestors` and no `X-Frame-Options`. The issue reasons from #3834
(a cross-site top-level GET served), which is not on `main` yet. On `main` the reason is a different one, and it
holds independently: `Test-LoopbackCrossSite` serves a **same-site** request in mode `navigate`, and an `<iframe>`
from a page on another localhost port is exactly that, so today nothing but the absence of such a page stops it.

No page of either server frames another (`<iframe>` grepped across `main` and the three open branches #3817, #3830,
#3834). The issue's "merge with the dashboard's own CSP" does not arise: that CSP is the Cloudflare worker's, which
does not use `Send-LoopbackResponse`. A host that frames these pages today (an editor's built-in browser) arrives
`cross-site` and is already refused with a 403, so the header breaks nothing that works.

### CREATE

- [x] `loopback-server-lib.ps1`: `Send-LoopbackResponse` writes `Content-Security-Policy: frame-ancestors 'none'`
      and `X-Frame-Options: DENY` into the head of every response, not only HTML, so a later route cannot forget it.
- [x] `dev-preview-sessionstart.tests.ps1`: three asserts, the two headers and the same-site `navigate` pass that
      makes them needed.

### TEST

- [x] Both files parse, and a response written by the lib carries both headers in its head.
- [x] No other suite pins the old head: the only other `nosniff` asserts are the worker's.

### DEPLOY: fix/3835-loopback-frame-ancestors

Every page the hub and the product's dev server answer with now carries `Content-Security-Policy: frame-ancestors
'none'` and `X-Frame-Options: DENY`. Until now a page on another localhost port could frame them, because a
same-site frame passes the request guard as a navigation. That has not been seen to happen. The point is
that the airsquats `POST /api/airsquats/clear` can no longer be click-jacked from a frame.

**Score:** 1

#### What makes this deploy extra special

Nothing changes that the user sees. It closes a framing route before anything uses it, which is the whole point of a
second barrier.

**Score:** 1

#### Pull Request

Loopback servers: send frame-ancestors 'none' as a second barrier against framing

