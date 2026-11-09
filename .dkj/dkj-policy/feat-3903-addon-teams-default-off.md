## feat/3903-addon-teams-default-off

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

#### The decision (#3903)

The owner's decision of November 8, 2026: `defaultEnabled: false` on the three add-on teams only. Chris stays an
`@`-imported persona (no main-thread `agent`), and no repo-config seam becomes `userConfig`. Per the docs the key
applies only where the user has set no `enabledPlugins` entry, and a dependency starts enabled regardless, so
`dkj-subagents-alpha` (which the teams declare since #3895) is unaffected.

### CREATE

- [x] `"defaultEnabled": false` in the `plugin.json` of `dkj-subagents-ecomm`, `-lifehub` and `-shopify`
- [x] `ADOPTION.md` says the add-on teams ship switched off

### TEST

### DEPLOY: feat/3903-addon-teams-default-off

The three add-on teams (`dkj-subagents-ecomm`, `dkj-subagents-lifehub`, `dkj-subagents-shopify`) declare
`defaultEnabled: false` ([#3903](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3903)). A repo that has not
named a team in `enabledPlugins` no longer gets it enabled just by installing it. A repo that already names one keeps
its own choice. The core team and the policy plugins are unchanged.

**Score:** 2

#### What makes this deploy extra special

A fresh install of an add-on team stays off until the repo turns it on with `"<team>@dkj-marketplace": true` in
`enabledPlugins`. A repo that already lists the team sees no change.

**Score:** 2

#### Pull Request

Add-on teams ship defaultEnabled: false

