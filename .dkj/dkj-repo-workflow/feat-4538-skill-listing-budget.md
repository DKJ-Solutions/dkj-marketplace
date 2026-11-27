## feat/4538-skill-listing-budget

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

Issue #4538, split off #4528: check 48 holds the published skill descriptions to the listing budget
only in this source repo, while a consumer cannot see what its own enabled plugins spend there.

### CREATE

- [x] `measure-skill-lib.ps1`: one description parser (`Get-SkillDescriptionText`), `Measure-SkillListing`,
      and the 250 / 8,000 constants
- [x] check 48 of `check-plugin-integrity.ps1` reads descriptions through that parser and its 250
- [x] `measure-skill.ps1`: a listing-budget section between pass 1 and pass 2, as `[INFO]`/`[OK]`, never `[ERROR]`
- [x] the `measure-skill` skill page and the script's help describe it; the plugin mirror is rebuilt
- [x] the integrity fixture copies `measure-skill-lib.ps1`, which check 48 now dot-sources

### TEST

- [x] `measure-skill.tests.ps1` pins the parser (folded, literal, quoted, plain, absent) and `Measure-SkillListing`
- [x] `check-plugin-integrity-skill-spans.tests.ps1` and the integrity gate stay green (46 skills, 7,843 of 10,000)
- [x] run here: 4 enabled plugins, 3,178 of the 8,000-character fallback, nothing over 250

### DEPLOY: feat/4538-skill-listing-budget

Check 48's description parser moves into `measure-skill-lib.ps1`, so the gate and the new report read
one parser and one 250-character ceiling.

**Score:** 1

#### What makes this deploy extra special

`measure-skill` now reports how many characters the model-invocable skill descriptions of the plugins a
checkout enables spend on Claude Code's skill listing. It measures that total against the 8,000-character
fallback and names any description over 250 characters as likely to arrive name-only. A consumer can now
see the budget that #4528 found overrun, in its own plugin set, before a skill silently stops triggering.

**Score:** 2

#### Pull Request

measure-skill reports the summed skill-description listing cost against Claude Code's budget, in a consumer

