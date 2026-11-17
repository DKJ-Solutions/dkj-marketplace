## docs/4210-claude-app-map

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

Re-run the Claude App map's rule in `plugins/ADOPTION.md` over every item the marketplace ships and
restate the table per plugin (#4210). The issue's claim that `dkj-subagents-ecomm` is left out of
`Get-BusinessMarketplacePlugins` does not stand: `scripts/repo-config.ps1:157` names it, so the
publication paragraph's "the four teams" was already true and is not changed.

### CREATE

- [x] Add test 3 to the rule (the craft itself is work on a checkout), with its provenance.
- [x] Restate the verdict table per plugin: alpha (17 agent defs, 4 personas, skills, hook), lifehub,
      ecomm, shopify; measured by listing each plugin's `subagents/`, `personas/`, `skills/` and
      `hooks/hooks.json` and grepping for `.ps1`.
- [x] Correct "two hooks" to the one hook `dkj-subagents-alpha` ships.

### TEST

- [x] Docs only; the lint and test gates run in `ship-pr`.

### DEPLOY: docs/4210-claude-app-map

The Claude App map in [`ADOPTION.md`](../../plugins/ADOPTION.md#which-half-needs-a-repository--the-claude-app-map)
counted 15 core agent defs and listed every persona as portable. It now reads per plugin, over all four
teams, and its rule has a third test: a specialist whose craft is work on a checkout (Derek, Rendall,
Sylvester, Liam, Sandra) is repo-bound even when no script is named (#4210).

**Score:** 2

#### What makes this deploy extra special

**Score:** N/A

#### Pull Request

ADOPTION.md's Claude App map restated per plugin

