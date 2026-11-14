## docs/figma-font-size-scale

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

The owner wants the Figma `Scale` collection to be a plain scale, with no element names in it. Its font
sizes are now `font-size/1` to `font-size/8` (11px to 36px, numbered so a name never states its value)
in one `Default` mode, and the code-named `text/h1` to
`text/xs` and `text/title` moved to the `Element` collection, which carries the `Desktop` and `Mobile`
modes and aliases a step per mode. The README still described the old layout.

### CREATE

- [x] The Figma file (done outside the tree): fixed `font-size/` steps in `Scale`, its `Mobile` mode
  removed; `Element` holds the seven text tokens with `Desktop`/`Mobile`, and its `element/*` group is
  gone, with its uses bound to `text/h2` or `text/sm`; text styles and 15 mobile frames follow.
- [x] The brand book README's typography paragraph describes that split.

### TEST

- [x] Docs only; every node and text style was checked for a binding left on a removed variable (0).

### DEPLOY: docs/figma-font-size-scale

The brand book README describes the Figma library's type layers as they are now: `Scale` holds the
sizes `font-size/1` to `font-size/8` in one mode, and `Element` maps each code token (`text/h1` to
`text/xs`, `text/title`) to a size per `Desktop` and `Mobile` mode.

**Score:** 1

#### What makes this deploy extra special

N/A: the CSS tokens a consumer reads are unchanged; only the description of the Figma file moved.

**Score:** N/A

#### Pull Request

The brand book README describes Figma's font-size scale and the Element text tokens

