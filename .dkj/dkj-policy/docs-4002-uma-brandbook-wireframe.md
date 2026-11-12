## docs/4002-uma-brandbook-wireframe

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

#### Scope

Issue #4002, scope **B** (decided by the owner on November 12, 2026): the as-is lo-fi analysis plus two
alternative structures, every assumption about the user labelled rather than asked first. Two parts: Tessa
fills Uma's repo lens before Uma is deployed, then Uma builds the wireframe in the owner's Figma file
(`ffJGriv6yREpvkdTysm7mR`). The wireframe is a visible result, so the branch parks for the owner's look.

### CREATE

- [x] Tessa: fill `.claude/specialists/lenses/specialist-04-32-lens.md` (who the users are here, assumptions
      over a question round, wireframes live in Figma, design rather than trace, hand-over to Gwen).
- [x] Uma: mark the first attempt superseded (renamed, faded, a banner above it).
- [x] Uma: brief board (assumptions A1-A3, tasks T1-T3, legend) and row A, as-is: desktop overview, desktop
      detail, the flow between them, phone overview, phone menu open, link-card states, the unhappy path,
      numbered annotations and findings F1-F7 ranked by severity.
- [x] Uma: row B, alternative 1 "Previewing overview" (desktop, search state, empty state, phone) and row C,
      alternative 2 "Catalogue shell" (desktop, phone, drawer open), plus a B-or-C cost note.
- [ ] Owner looks at the wireframe in Figma and picks a structure.

### TEST

- [x] Every frame screenshotted after composition; a bounds check finds no overlap between top-level
      nodes other than an arrowhead on its own line.

### DEPLOY: docs/4002-uma-brandbook-wireframe

Uma's repo lens is filled in for the first time. It says who the users of this repo's pages are (the
owners), that a statement about them is a labelled assumption unless confirmed, that her wireframes here
live in Figma rather than as a page in the repo, and that a wireframe is designed by hand rather than traced
from the HTML with `figma-generate-design`, which is the route that made the first attempt on #4002 a trace.
The wireframe itself lives in Figma and is not part of this diff.

**Score:** 2

N/A: the lens is read only inside this repo, and nothing this repo ships changes.

#### What makes this deploy extra special

The first wireframe of the team's new UX specialist that was designed rather than traced: three rows (the
page as it is, a previewing overview with search, a catalogue shell with previous / next), with seven
ranked findings and every user statement labelled as an assumption.

**Score:** 1

#### Pull Request

Uma: a real lo-fi wireframe of the brand book overview in Figma
