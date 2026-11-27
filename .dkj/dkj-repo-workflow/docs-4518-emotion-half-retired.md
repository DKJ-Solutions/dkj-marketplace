## docs/4518-emotion-half-retired

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

Inbound #4518: a consumer hub retired the emotion half of its brain and moved the colour model to its
library as one framework page. Verified against the tree: the portable layer carries only traces of
the half (the routing itself lives in each consumer's lens): `halves (facts or emotion)` in Ian's
def, `dossier/note/emotion` nodes in Onyx's def, and `corpus callosum` in Onyx's manual. No manual or
skill copied the old Orange neighbour list (`magenta`: 0 hits). The `Plutchik` lock name stays, since
the issue does not rename the brain.

### CREATE

- [x] Ian's manual (04-03): a placement test for frameworks (library page, even when the owner
  invented it), feelings routed as updates, and archived-not-deleted when a framework moves out.
- [x] Ian's def: drop "which of its halves (facts or emotion)"; add the one-line framework test.
- [x] Onyx's def: a node is a dossier or a note, no longer an emotion.
- [x] Onyx's manual (04-04): an emotion colour is a tag, not a neuron; no links to archived colour
  dossiers; no cross-hemisphere link; "corpus callosum" dropped from the lens pointer.

### TEST

- [x] `grep -rnE "facts or emotion|corpus callosum|note/emotion"` over the plugins returns nothing
  outside the new rules; the generated blocks in both defs are untouched. ship-pr runs the gates.

### DEPLOY: docs/4518-emotion-half-retired

The life hub's information architect and ontologist no longer treat the emotion half as live
structure. Ian (04-03) places a framework, such as a colour model for emotions, as one reference page
in the hub's library, even when the owner invented it, and routes a feeling as an update in the
dossier of its topic, or in the identity dossier when it has none. Onyx (04-04) treats an emotion
colour as a tag on a dossier, not as a neuron, and lays no links to colour dossiers a hub has archived.

**Score:** 2

#### What makes this deploy extra special

A life-hub user whose hub keeps its emotion model in the library no longer gets new feelings filed as
nodes of their own, or links laid to archived colour dossiers.

**Score:** 2

#### Pull Request

Lifehub: the emotion half is retired; the colour model is a library framework

Plugins: dkj-subagents-lifehub

