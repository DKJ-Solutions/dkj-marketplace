## feat/4442-asana-review-followers

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

A new optional seam, `Get-AsanaReviewFollowers`, so the colleague who owns SEO, UX or CRO follows a
mirrored Asana task from creation when the finding touches their area (#4442). Decided in the build:
the area is judged in step 1 (one step old by step 2), only created tasks get followers, and
`guard-asana-mirror` does not check it, because the area is a judgement.

### CREATE

- [x] `report-issue`: read the seam, judge the area in step 1, pass `followers` on the same `create task` call in step 2.
- [x] The bwj README seam list and the adopt skill's `repo-config.ps1` stub carry the new function, `$null` by default.

### TEST

- [x] Docs only; the Asana `create_tasks` tool's schema confirms `followers` is a comma-separated string per task. The gates run in `ship-pr`.

### DEPLOY: feat/4442-asana-review-followers

`report-issue` can now put the colleague who owns SEO, UX or CRO on a mirrored Asana task from the
moment it is created, when the finding touches their area. A new optional seam in
`scripts/repo-config.ps1`, `Get-AsanaReviewFollowers`, maps `seo`, `ux` and `cro` to Asana user
GIDs; step 1 judges which areas a finding touches and step 2 passes those users as `followers` on the
same `create task` call. Left at `$null`, nothing changes.

**Score:** 3

#### What makes this deploy extra special

For a store team, a change to search, navigation, templates or checkout now reaches the SEO/CRO owner
before it is built rather than after it is live, once the seam is answered.

**Score:** 3

#### Pull Request

report-issue: add the SEO/UX/CRO reviewer as a follower on the Asana task when a finding touches their area

