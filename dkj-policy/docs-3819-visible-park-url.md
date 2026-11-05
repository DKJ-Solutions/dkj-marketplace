## docs/3819-visible-park-url

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

#3819: the visible-result report names the URL to open, on a line of its own. The rule goes where the
report's shape is owned: the constitution's "Merging work with a visible result" bullet, plus the two
places the sweep skill spells out a park's handover and its close-out. Chris's persona is not edited: it
restates no visible-result report shape, and the constitution already loads beside it in every session.

### CREATE

- [x] `plugins/dkj-policy/CLAUDE.md`: the visible-result bullet says the report names the exact URL that shows the result, on a line of its own, one line per changed page.
- [x] `plugins/dkj-policy/skills/sweep-issues/SKILL.md`: step 5's review-label comment carries the URL, and the sweep's close-out lists each parked branch's page URLs on lines of their own.
- [~] A script printing the line itself (#1884's approach): dropped, because no script prints a visible park's report. The park opens no pull request, so neither `open-pr` nor `ship-pr` runs at that moment, and there is nothing to attach the line to.

### TEST

- [x] The three edits read in place; the constitution's always-on growth is three lines, well inside the 100,000 B budget the session check reported (39,121 B of headroom).

### DEPLOY: docs/3819-visible-park-url

When a branch stops for the owner's look, its report now names the exact URL that shows the result, a Toolbox page or a preview, on a line of its own and one per changed page. The rule sits in the constitution's visible-result bullet, and the sweep skill carries it into its review-label comment and its close-out. Until now the report could say "the branch waits for your look" without saying where, and the owner had to find the page themselves.

**Score:** 2

#### What makes this deploy extra special

A session that parks a visible result in any repo running `dkj-policy` hands the owner the address to open, instead of a sentence they have to turn into one.

**Score:** 2

#### Pull Request

A visible result parked for the owner's look names the URL to open

