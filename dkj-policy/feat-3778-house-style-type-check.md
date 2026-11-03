## feat/3778-house-style-type-check

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

#3778 (inbound from dkj-lifehub): `check-house-style` holds colour to a token (#3720), and type to nothing,
so 14 typed font sizes passed a gate that reported the brand book clean. Give it a fifth check, `type`, the
same shape as `colour`: a `font-size` reads `var(--text-*)` or a CSS-wide keyword, and a `font` shorthand
types no size; a custom property's own value stays free, so a domain step (`--text-hero: 48px`) is allowed.

The issue's two side questions: a relative size on `code` falls out of the rule (the house sets it once in
`:where(code)`). `font-weight` is left out, because covering it means deciding whether the house gains a
600 step, and that decision belongs to the owner: filed as #3784 (`awaiting-decision-dev`).

#### Measured before building

The check in this repo: 4 findings, all regex patterns in `stopwatch.tests.ps1` that read `font-size`
out of rendered pages, answered in the allowlist. The hub's own CSS is clean. In the local consumer
checkouts: 16 in dkj-lifehub's `main` as checked out here, 94 in dkj-music-library, which already fails the
gate (measured on #3720), so no green check turns red there.

### CREATE

- [x] `Find-HouseStyleTypeHit` and check 5 in `house-style-rules.ps1`, wired into `Invoke-HouseStyleCheck`
- [x] The allowlist entry for `stopwatch.tests.ps1` in `scripts/repo-config.ps1`
- [x] The skill page, the plugin README, the hook (synopsis and clean line), the gate's synopsis, the
  reusable workflow's header and the marketplace description name the fifth check

### TEST

- [x] `check-house-style.tests.ps1`: 14 unit asserts on the matcher and one fixture assert through the gate;
  150 passed, the self-run over this repo included

### DEPLOY: feat/3778-house-style-type-check

The brand book's gate, `check-house-style`, gains a fifth check, `type`: a rule in a repo's own layer reads a
font size only from the type scale ([#3778](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3778)).
A `font-size` whose value is anything but `var(--text-*)` or `inherit` and its kin, or a `font` shorthand
that types a size (`15px`, `0.88em`, `larger`, `clamp(...)`), is a finding. A custom property's own value
is not, so a domain step such as `--text-hero: 48px` stays a token of the repo's own. `font-weight` is not
read, pending [#3784](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3784).

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions repo running the house-style gate gets a new finding for every rule that types a font size,
and the reusable workflow tracks `main`, so it arrives at the merge rather than at the next release. The fix
is a `--text-*` step read with `var()`, a domain step of the repo's own, or an allowlist entry with its reason
for a false positive. Measured on November 3, 2026: 94 typed sizes in dkj-music-library, which already fails
the gate, so no green check turns red there.

**Score:** 3

#### Pull Request

check-house-style: a type rule, font-size only as a --text-* token

