## feat/4216-companion-plugin-check

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

#4216: after #4211 a consumer that enables `dkj-subagents-alpha` without `dkj-subagents-developers` loses
ten specialists, and the roster check that would say so moved with them. A read-only session check in
`dkj-policy` reports it.

### CREATE

- [x] `plugins/dkj-policy/hooks/companion-plugin-sessioncheck.ps1`: reads the settings chain through
  `Get-EnabledPlugins` and reports `[ERROR]` per enabled plugin whose companion (same marketplace) is not
  enabled, with the `enabledPlugins` line and the install command. The dispatcher discovers it by name.
- [x] `scripts/tests/companion-plugin-sessioncheck.tests.ps1`: silent when both are on, one finding when the
  core team is alone, `false` counts as off, the fork's marketplace, the user layer, an unparseable file.

### TEST

- [x] The new suite passes standalone (14/14); the hook is silent in this repo, which enables both.
- [x] The full gate runs in `ship-pr`.

### DEPLOY: feat/4216-companion-plugin-check

A repo that enables the core team (`dkj-subagents-alpha`) without the developers team
(`dkj-subagents-developers`) now hears it at session start: `companion-plugin-sessioncheck` prints an
`[ERROR]` with the `enabledPlugins` line to add and the `claude plugin install ... --scope project` command
([#4216](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4216)). Before, the split in #4211 left such
a repo with eleven specialists and no word about it.

**Score:** 3

#### What makes this deploy extra special

The check that would have reported the gap shipped inside the plugin that was missing; this one lives in the
workflow plugin, which nearly every repo enables. A repo without `dkj-policy` stays uncovered.

**Score:** 2

#### Pull Request

A session check names a required companion plugin that is not enabled

