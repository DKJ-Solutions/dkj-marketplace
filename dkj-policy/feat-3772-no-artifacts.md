## feat/3772-no-artifacts

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

Dave, November 3, 2026 ([#3772](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3772)): no claude.ai
Artifacts and no Claude Docs any more. A visible result someone must judge becomes a Toolbox page, a document a
file in the repo. All 53 existing Artifacts were deleted in the same session; none converted, because the
Toolbox's Test gate, SessionStart, Skills and Performance pages already cover the analysis pages.

### CREATE

- [x] The constitution (`plugins/dkj-policy/CLAUDE.md`) carries the rule always-on, overriding the harness default to publish; the visible-result safety rule says "a Toolbox page"
- [x] `CONTRIBUTING-portable.md`: the section "A committed Artifact source carries its published URL" retired
- [x] Gwen #12, Cody #13 (manuals, subagent defs), the shared `artifact-publishing-boundary` block, Derek's persona and lens, `ship-pr`, `sweep-issues`: no Artifact publishing
- [x] Brand book: the `dkj-brandbook` skill, its README, `house-style.css`'s header comment, the `repo-dashboard` pattern, the `dkj-solutions` CLAUDE.md and descriptions name no Artifact
- [x] The hub's `/artifacts` page and card removed; `/artifacts` answers 303 to `/`, as the retired `/about` does
- [x] This repo's register and harvesting removed: `scripts/dashboard/artifacts.json`, the `harvest-artifacts` skill, its script and lib
- [x] `measure-session-start` no longer publishes or downloads a "Sessiestart-context" Artifact; its previous measurement is the snapshot JSON, read as `-Previous`

### TEST

- [x] `check-plugin-integrity` and `check-script-contract` green; `build-agent-defs` reports the subagent defs in sync
- [x] `dev-pages` (545), `measure-session-start` (231), `consumer-dashboard` (239), `dev-preview-sessionstart` (364), `shared-scripts`, `claim-issue`, `house-palette`, `script-contract` green
- [ ] The owner looks at the Toolbox on 4890 without its Artifacts card (visible result -- no merge before that)

### DEPLOY: feat/3772-no-artifacts

The workflow no longer uses claude.ai Artifacts or Claude Docs. The constitution says so always-on and overrides
the harness's own default to publish one: a result someone must judge becomes a Toolbox page, a document a file in
the repo. The Toolbox loses its Artifacts page and card (an old `/artifacts` link lands on the home page), the
`measure-session-start` skill keeps its history in its snapshot file instead of a published page, and the
specialists' and brand book's texts no longer point at Artifacts.

**Score:** 3

#### What makes this deploy extra special

Every session in every consumer stops publishing Artifacts after taking this version, including where the harness
would offer one unprompted.

**Score:** 3

#### Pull Request

Stop using claude.ai Artifacts and Claude Docs: a visible result becomes a Toolbox page

