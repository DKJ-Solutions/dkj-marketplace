## fix/3998-register-three-consumers

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

#3998: three repos enable `dkj-subagents-alpha` with no manifest under `consumers/`. Verified on each
repo's `origin/main` through the GitHub API: the plugins enabled, the marketplace name they use, and the
lens inventory. Each record books what the repo HAS, so each has only the lenses that are actually
there, and `dkj-etf-tracker` keeps its retired `@dkj-claude-plugins` ids until its own migration
(dkj-etf-tracker#69) lands.

### CREATE

- [x] `consumers/dkj-recipes.json`: 21 core-team lenses, public.
- [x] `consumers/dkj-music-library.json`: 19 lenses (02-31 and 04-32 not yet placed there), public.
- [x] `consumers/dkj-etf-tracker.json`: 19 core-team lenses under the retired ids, private, metadata only.

### TEST

- [x] `check-consumers.ps1 -SkipDrift`: exit 0, 0 errors. `dkj-recipes` reads all 21 registered
  extensions present. The other two are skipped on this machine, which has no checkout of them.

### DEPLOY: fix/3998-register-three-consumers

`dkj-etf-tracker`, `dkj-music-library` and `dkj-recipes` now have a manifest under `consumers/`, so the
registry check, the session hook and the registry-driven sweeps reach them (#3998). Each records the
plugins and lenses measured on that repo's `origin/main`.

**Score:** 2

#### What makes this deploy extra special

N/A: the register is workshop administration in this repo and does not travel with any plugin.

**Score:** N/A

#### Pull Request

Register dkj-etf-tracker, dkj-music-library and dkj-recipes under consumers/

