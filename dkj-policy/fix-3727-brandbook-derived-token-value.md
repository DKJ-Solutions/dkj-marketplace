## fix/3727-brandbook-derived-token-value

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

Issue #3727, decided by Maikel on November 2, 2026: the brand book README's qualifier "outside a token's
own value" goes, so the README follows `check-colour-literals.mjs`, which refuses a derived colour anywhere,
a custom-property declaration included. Verified against the gate: its `derived` pattern is matched over the
whole source, with no declaration-span exemption.

### CREATE

- [x] Drop the qualifier in `plugins/dkj-policy/assets/dkj-brandbook/README.md` and say outright that a token's own value may not derive either.

### TEST

- [x] Doc-only change; the gates run in `ship-pr`.

### DEPLOY: fix/3727-brandbook-derived-token-value

The brand book README said a colour function was allowed "outside a token's own value", which read as
permission for `--x: color-mix(…)`, while `check-colour-literals.mjs` refuses a derived colour anywhere. The
README now follows the gate: no derived colour, a token's own value included
([#3727](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3727)).

**Score:** 1

#### What makes this deploy extra special

A consumer writing its own domain layer from the README could have typed a `color-mix()` token and been
told it was allowed; the README no longer says so.

**Score:** 1

#### Pull Request

Brand book README: a token's own value may not derive a colour either
