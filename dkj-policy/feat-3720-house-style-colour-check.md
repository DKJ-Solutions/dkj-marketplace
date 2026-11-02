## feat/3720-house-style-colour-check

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

#3720: the brand book's colour rule (a rule reads a colour only as a token, Maikel, November 1, 2026) held
only where the brand book is made, in `check-colour-literals.mjs`. Give `check-house-style` a fourth check,
`colour`, so it holds where the brand book is used. Its shape follows the README rather than the issue's
wording: a domain token's own value may hold a code (README "How to use it", step 2; "outside a token's own
value", under "A rule reads a colour only as a token"), so only a colour *property*'s value is read.

#### Measured before building

All three consumers that call the reusable gate (dkj-music-library, dkj-recipes, dkj-etf-tracker) already
fail it at v6.2.0 with 38 to 94 findings, so the new check turns no green CI red. It adds 11 findings in
dkj-music-library (`color-mix()` in rules), 2 in dkj-recipes (an icon script) and 0 in dkj-etf-tracker, whose
codes all sit in domain token values. In this repo it found 11, answered in `Get-HouseStyleAllowlist`: GitHub
label-colour fixtures, the BWJ extension's own pages, and four `color: #000` samples on the House style page,
filed as #3725. Whether a token's own value may *derive* is filed as #3727: the README allows it, the house
sheets' gate refuses it, and this check follows the README until that is decided.

### CREATE

- [x] `Find-HouseStyleColourHit` and check 4 in `house-style-rules.ps1`, wired into `Invoke-HouseStyleCheck`
- [x] The allowlist entries in `scripts/repo-config.ps1`, the specimens one citing #3725
- [x] The skill page, the plugin README, the hook, the gate's synopsis, the reusable workflow's header and the
  marketplace description name the fourth check (the last two also lose the retired `h2`-in-a-card check)

### TEST

- [x] `check-house-style.tests.ps1`: 13 unit asserts on the matcher and one fixture assert through the gate;
  135 passed, the self-run over this repo included

### DEPLOY: feat/3720-house-style-colour-check

The brand book's gate, `check-house-style`, gains a fourth check, `colour`: a rule in a repo's own layer reads
a colour only as a token ([#3720](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3720)). A colour
property (`color`, `background`, `border-color`, `fill` and the like) whose value types a code (`#hex`,
`rgb()`, `hsl()`) or derives one (`color-mix()`, `oklch()`, `rgb(from ...)`) is a finding. A custom
property's own value is not, so a domain colour stays a token of the repo's own. The session check reports
it too, and the House style page's four raw sample colours are allowlisted here until #3725 gives them a
token.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions repo running the house-style gate gets a new finding for every rule that types or mixes a
colour, and the reusable workflow tracks `main`, so it arrives at the merge rather than at the next release.
Measured on November 2, 2026: 11 `color-mix()` rules in dkj-music-library, 2 in dkj-recipes' icon script,
none in dkj-etf-tracker. All three already fail the gate on retired token names, so no green check turns
red. The fix is the one the README names: add a domain token (`--my-row-tint: ...`) holding the colour and
read it with `var()`, or answer a false positive in `Get-HouseStyleAllowlist` with its reason.

**Score:** 3

#### Pull Request

check-house-style refuses a raw or derived colour in a consumer's rules

