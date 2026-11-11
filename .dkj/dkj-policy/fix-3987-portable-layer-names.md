## fix/3987-portable-layer-names

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

Issue #3987 and the owner's decision on it (option A): restate the layer rule to what the layer carries --
an issue number as provenance is allowed in manuals and personas, repo names and person names are not --
and add a lint check that holds that line. Measured on this branch: the 28 GitHub links in the 31 files all
point at this source repo (under its current or retired names), and 6 lines named a person.

### CREATE

- [x] The six person names in the manuals (Chris 01-01 x4, Paula 02-09, Gwen 04-12, Liam 05-21) become "the owner", with the pronouns that followed them
- [x] Check 47 `[portable-names]` in `scripts/lint/check-plugin-integrity.ps1`, plus its `checks:list` entry
- [x] `check-plugin-integrity-docs.tests.ps1`: the allowed shapes stay silent, another repo (link and `owner/name#n`) and a person (by name and by account, any case) are reported, a skill page is not a subject
- [x] Tessa's lens table restated as the rule, with the two failed measurements as its history; `.claude/rules/this-repo.md`'s one-line summary follows

### TEST

- [x] `check-plugin-integrity.ps1` on this tree: 0 errors, `[portable-names]` checked 31, 0 findings
- [x] `check-plugin-integrity-docs.tests.ps1` alone: all 39 asserts pass

### DEPLOY: fix/3987-portable-layer-names

Manuals and personas now follow a rule instead of a measurement: they may cite an issue of this source repo
as provenance, and name no other repo and no person (#3987). Check 47 of `check-plugin-integrity.ps1`,
`[portable-names]`, holds the line, after the six person names in the manuals became "the owner". Tessa's
lens states the rule in place of a table that had been falsified twice (#701, #3987).

**Score:** 2

#### What makes this deploy extra special

Four shipped manuals in `dkj-subagents-alpha` and `dkj-subagents-shopify` attribute a decision to "the
owner" instead of a named person; the rules themselves are unchanged.

**Score:** 1

#### Pull Request

Manuals and personas may cite an issue number, never a repo or a person, and a lint check holds that line

