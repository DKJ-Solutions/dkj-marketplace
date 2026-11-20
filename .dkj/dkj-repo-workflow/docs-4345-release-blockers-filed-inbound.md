## docs/4345-release-blockers-filed-inbound

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

#### One source, three pointers

The rule is written once, as a section of `cut-release` (the release checklist every repo has).
`prepare-release`, `live-preflight` and `ship-pr` each carry a short pointer to it, because those are
the pages a release loads at the moment a blocker happens. The promotion has no skill of its own, so
`cut-release`'s section names it.

### CREATE

- [x] `cut-release` SKILL.md: new section *A blocker during a release is filed the moment it happens*,
  covering when, where (local vs inbound, decided by where the cause sits), and why (#4143, #4144).
- [x] Pointers in `prepare-release` (bwj), `live-preflight` (shopify) and `ship-pr`.

### TEST

- [x] `ship-pr`'s gate (integrity, links, suites) runs on the PR.

### DEPLOY: docs/4345-release-blockers-filed-inbound

The release skills now say that every blocker or surprise during a release is filed the moment it
happens, with its measured cost (round trips, manual steps, minutes). It is not saved for the end of the
cut. A cause in the shared scripts goes inbound to the plugin's source, even when it surfaced in a
consumer. The rule sits in `cut-release`, and `prepare-release`, `live-preflight` and `ship-pr` point to
it. It was moved out of a per-machine memory note under #4341.

**Score:** 2

#### What makes this deploy extra special

A consumer running a release is told to file a shared-script blocker inbound right away. Before this,
such a blocker reached the source days later, as #4143 and #4144 did after a v3.1.0 cut.

**Score:** 2

#### Pull Request

Release skills: file each release blocker the moment it happens, with its measured cost

