## fix/4426-reach-test-seo-defects

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

Inbound #4426: `report-issue`'s reach test ("in doubt, leave it off", with a tier-0 worked example)
let a session file four top brand pages serving no H1 as tier 0, while a lesser heading defect in the
same session got `minor`. Name the SEO case in the reach-label row and in the matching paragraph of
`WORKFLOW-portable.md`.

### CREATE

- [x] `skills/report-issue/SKILL.md`: the reach-label row names a measured SEO defect on indexed live
  pages (H1/headings, canonicals, structured data, indexability) as passing the test, with the SEO team
  named in `## Why <reach label>`; "in doubt, leave it off" is kept for defects nobody outside
  development meets.
- [x] `WORKFLOW-portable.md`: the same case in the reach-reason paragraph, with the measurement.

### TEST

- [x] Doc-only change; the gates `ship-pr` runs cover links and integrity.

### DEPLOY: fix/4426-reach-test-seo-defects

A store session filing a measured SEO defect on indexed live pages (a missing H1, a wrong canonical,
broken structured data, a page that cannot be indexed) now gives it the reach label and names the
store's SEO team in `## Why <reach label>`, instead of reading it as developer-only and filing it tier
0 without an Asana card. [`report-issue`](../../plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-bwj/skills/report-issue/SKILL.md)
and [`WORKFLOW-portable.md`](../../plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-bwj/WORKFLOW-portable.md)
name the case (#4426).

**Score:** 2

#### What makes this deploy extra special

A store's SEO defects on live pages now reach its Asana board and business worklist consistently,
instead of depending on whether the SEO team's question happened to be in the session's context.

**Score:** 2

#### Pull Request

report-issue's reach test names measured SEO defects on indexed live pages
