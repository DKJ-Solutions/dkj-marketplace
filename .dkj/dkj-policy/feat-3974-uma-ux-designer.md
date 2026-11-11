## feat/3974-uma-ux-designer

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

#3974: the owner approved the field (November 11, 2026) and then the person: **Uma** 🖱️, id `04-32`,
group 04 beside Gwen #12, who stays the visual designer. Boundaries settled in her manual against Gwen,
Rebecca, Bianca, the product owner, Marlowe and Cody. Built in the shape of #3973's branch (Priya), the
other new specialist of the same day.

### CREATE

- [x] Agent def `specialist-04-32-subagent.md` (Read/Write/Edit for wireframes and prototypes,
  WebSearch/WebFetch for competitor teardowns, with the web-content, browser-compatibility and
  no-Artifact shared blocks), filled by `build-agent-defs.ps1`, registered in the core team's
  `plugin.json`.
- [x] Manual `specialist-04-32-manual.md`: research prepared and synthesised, teardowns from the
  user's side, flows with unhappy paths, wireframes and a clickable prototype, severity-ranked
  findings, the boundaries, hard rules (she never invents users), tone. No issue numbers, per the
  manual layer's convention.
- [x] This repo adopts her: empty `VUL-IN` lens, roster line in `SPECIALISTS.md`, the
  `consumers/dkj-marketplace.json` extensions array, the README's team list.
- [x] Gwen's manual names the *looks* / *works* boundary from her side.
- [x] `SPECIALISTS.md` no longer lists Gwen among the specialists with an empty lens: hers has held
  the brand-book page since #3130.

### TEST

- [x] `build-agent-defs.ps1`: the new def's shared blocks filled, every other def already in sync.
- [x] Full gates run by ship-pr.

### DEPLOY: feat/3974-uma-ux-designer

The core team has a new specialist: **Uma 🖱️, the UX Designer / UX Researcher** (`04-32`). She owns
how a product works for its users: she prepares interviews and usability tests and synthesises what
comes back into findings tied to their evidence, tears competitors down from the user's side, and
designs user flows (unhappy paths included), wireframes and a clickable prototype. Gwen stays the
visual designer and takes Uma's tested flow further (#3974).

**Score:** 3

#### What makes this deploy extra special

A repo running the core team gets a specialist for user research and interaction design, where
before nobody on any team owned either. She never invents users: she prepares the session, the
owner runs it, and she reads the result. After updating the plugin, the roster check reports her as
missing from the roster: run `sync-roster` to adopt her, which places an empty lens and proposes the
roster line.

**Score:** 3

#### Pull Request

Uma: a UX Designer / UX Researcher specialist in the core team

