## feat/4075-vendor-inter-font

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

- [x] Read #4075 and the vendoring chain it names: `Get-HouseStyleCopyNames` / `Get-HouseStylePinRequiredNames`, `Get-ReleaseVersionPins`, the `dkj-brandbook` skill page.
- [x] Decide the issue's open question: an inlined `<style>` output keeps the system-font fallback (no data URI), the behaviour `house-style.css` already documents and the cheaper one.

### CREATE

- [x] Pin `InterVariable.woff2` on the skill page (a fourth row, optional for the gate) and tell an app to vendor it, with `LICENSE-Inter.txt`, beside `house-style.css`.
- [x] Add the font to `Get-ReleaseVersionPins`' checksums, so the cut writes its URL tag and sha256.
- [x] Teach check 1 the font: a copy name, the pin-table regex, and its mixed-case canonical path.

### TEST

- [x] Asserts in `check-house-style.tests.ps1` (group 1c): the page pins the font, the cut checksums it, a page with and without the row, and the canonical path from a lowercased leaf. The suite runs under `ship-pr`'s gate.

### DEPLOY: feat/4075-vendor-inter-font

The `dkj-brandbook` skill now pins the house font, `InterVariable.woff2`, beside the three stylesheet files: the release cut writes its tag URL and sha256, and `check-house-style` holds a vendored copy to that checksum like the others. The skill tells an app to put the font and its license in the same folder as `house-style.css`; an inlined `<style>` block keeps the system-font fallback ([#4075](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4075)).

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions app that vendors the brand book can now take Inter too, from the same pinned table, so its pages show the same letters as Admin and Figma. Taking it is optional: an app without the font keeps the system font, and the gate does not ask for it.

**Score:** 2

#### Pull Request

Vendor InterVariable.woff2 with the pinned brand book files
