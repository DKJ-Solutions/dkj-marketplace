## fix/3986-deploy-missing-tier-heading

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

- [x] Verify #3986's reason: the branch-document half of `[entry-heading]` never checks which section an
  entry opens with, and `Read-EntryTierSections` reads a second Score line in one section as text below
  the first score, so the entry silently declares tier 0 alone

### CREATE

- [x] Refuse a second Score line with no heading between it and the first, in the shared entry parser
  (both lib copies), so `open-pr` and `check-branch-entry` refuse it before the push
- [x] Restore #3984's missing heading in `CHANGELOG.md`, identical to the repair on #3974's and #3978's branches

### TEST

- [x] `entry-scaffold.tests.ps1`: the headless entry is refused and names the heading, and a deeper heading
  between the two Score lines is not; probed against every entry in `CHANGELOG.md` (only #3984's is refused)
  and every archived release note (none is)

### DEPLOY: fix/3986-deploy-missing-tier-heading

An entry whose audience-tier heading was deleted while both `**Score:**` lines stayed is now refused by
`open-pr` and `check-branch-entry` before the push (#3986). Until now the shared entry parser read the
second Score line as text under the first, so the entry declared tier 0 alone with every gate green. The
fold then wrote it into `CHANGELOG.md`, where `[entry-heading]` refused the next PR on somebody else's
branch. A second Score line with no heading between it and the first now names the heading to put back.
#3984's entry, which slipped through that way, gets its heading back here too.

**Score:** 3

#### What makes this deploy extra special

A DEPLOY section that lost its audience-tier heading is refused at your own `open-pr` with the heading to
restore. It no longer passes your gates and then drops its audience score silently from the release.

**Score:** 2

#### Pull Request

Refuse a DEPLOY section whose audience-tier heading is missing

