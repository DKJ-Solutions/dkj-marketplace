## docs/4418-design-lessons-to-manuals

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

#4418: five design lessons that were kept as local memory notes are to be moved into the shared docs, one
home each. I checked each against the tree when I picked it up:

1. Building in Figma the professional way: already in Uma's manual (#4018). **Missing from Gwen's.**
2. One spacing and radius scale for wireframe and visual design: **in no doc.** The brand book README
   describes the Figma `Scale` collection but has no rule against a wireframe-only scale.
3. The wireframe leads the visual design: the brand book README says so for Admin's desktop shell only
   (the *Desktop shell* entry). **No general handover rule.**
4. 60-30-10: already in the brand book README (*A theme's colours are three groups*), including "every
   colour token sits in one of the three groups", and the graph slots staying clear of the primary are in
   *Status, direction and categorical colours*. The memory note is **out of date**: it maps 30 to
   primary and 10 to text, but since November 12, 2026 primary is the 10 and text the 30. Nothing to add.
5. Colours only as tokens: already in the brand book README (*A rule reads a colour only as a token*) and
   enforced by `check-colour-literals.mjs`. Nothing to add.

### CREATE

- [x] Uma's manual: the professional-wireframe rule now says its spacing and radius variables are the
  design system's one scale, shared with the visual design (lesson 2).
- [x] Gwen's manual: two hard rules. She builds in a design tool the way Uma builds a wireframe, on the same
  scale (lesson 1, pointing at Uma's rule instead of repeating it in full), and the wireframe leads the
  visual design on structure (lesson 3).

### TEST

- [x] Docs only. The gates `ship-pr` runs cover links and integrity.

### DEPLOY: docs/4418-design-lessons-to-manuals

The UX designer's and the graphic designer's manuals now carry three design lessons that had only lived in
one machine's memory notes: the visual design is built in Figma the same professional way as a wireframe,
both share the design system's one spacing and radius scale, and where the two disagree on structure the
visual design adapts to the wireframe (#4418).

**Score:** 2

#### What makes this deploy extra special

A visual design in Figma no longer starts from one-off frames or its own spacing scale, and no longer
quietly overrides the tested wireframe's layout.

**Score:** 2

#### Pull Request

Design lessons from local memory notes land in Uma's and Gwen's manuals

