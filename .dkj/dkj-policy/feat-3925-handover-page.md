## feat/3925-handover-page

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

Inbound #3925 (from smartwatchbanden#1079): PREVIEW-portable.md prescribes the handover as one link to a
published page with a QR code per market, #3772 retired Artifacts, and nothing built the page. Verified
on pickup: no route, no builder, only the pair builders. Built as an Admin page because Admin runs in every
repo and is the constitution's carrier for a result someone must judge.

### CREATE

- [x] `plugins/dkj-policy/scripts/lib/qr-lib.ps1`: a QR encoder (byte mode, level M, versions 1-15) drawing inline SVG, so the preview URL never leaves the machine
- [x] `apps/admin/lib/handover-page-lib.ps1` + the `/dev/handover[/<name>]` route in `serve-general-pages.ps1`: the model (outside the checkout, beside the Stopwatch store), the four-block page and the index
- [x] bwj-development `scripts/task/build-handover-page.ps1`: the cards from `Get-MarketHandoverPairs`, the go-live block from `build-golive-block -OutFile`, one link printed
- [x] Docs: PREVIEW-portable.md names the carrier, both READMEs list it, `Write-MarketPreviewUrls` points at it
- [ ] The owner has looked at a handover page in Admin and scanned its QR codes with a phone (visible result: the encoder is held to published vectors, the whole code only to a scan)

### TEST

- [x] `scripts/tests/handover-page.tests.ps1` (new, in the `pages` group): the QR vectors (Reed-Solomon, format and version bits, the version chosen), the model's refusals (a non-https URL, a non-slug name), the page's escaping and blocks, the route, and the builder end to end against a fixture store -- 39 passed

### DEPLOY: feat/3925-handover-page

A preview handover in a BWJ store is an Admin page again
([#3925](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3925)). bwj-development's
`build-handover-page.ps1` takes the preview theme, the changed page(s) and the three text blocks, and
writes the page to `/dev/handover/<name>` on the checkout's Admin. It has one card per market, each with a
QR code to the preview and the live-pinned control beside it, and the go-live block as `build-golive-block`
wrote it. The script prints that one link. dkj-policy's Admin draws the codes on the machine with a new
local encoder, so a preview URL never reaches an outside service, and the page lives outside the checkout,
so the parked branch stays clean.

**Score:** 3

#### What makes this deploy extra special

A store session hands a preview over as one Admin link whose cards a phone can scan, where since #3772 it
had only an issue comment without QR codes. The session runs `build-handover-page.ps1` after
`push-preview` and reports the link it prints.

**Score:** 3

#### Pull Request

An Admin page carries the preview handover (#3925)

