## fix/4154-app-deploy-allow-updates

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

One formatter prints the command for both scripts (`Format-ShopifyAppDeployCommand`), so the flag goes there,
and the pages that quote the command follow it. `--no-release` was not added: its deploy uploads a version
without releasing it, so the release day would still owe a second step.

### CREATE

- [x] `Format-ShopifyAppDeployCommand` (`live-push-rules.ps1`, all three identical copies) appends `--allow-updates`
- [x] The `prepare-release` and `live-preflight` skill pages, the shopify README and `live-preflight`'s help quote the new command

### TEST

- [x] `live-push-rules.tests.ps1` and `bwj-development.tests.ps1` assert the command with `--allow-updates`

### DEPLOY: fix/4154-app-deploy-allow-updates

The app deploy that `live-preflight` and `prepare-release` print now reads
`shopify app deploy --path <folder> --allow-updates`
([#4154](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4154)), so it runs in a non-interactive shell.
A deletion still needs `--allow-deletes`, which remains a deliberate separate act.

**Score:** 2

#### What makes this deploy extra special

On release day in a Shopify store repo that ships an app, the printed app deploy runs as printed through a
session's `!` prefix. Before, the Shopify CLI refused it there and the owner had to look up the missing flag.

**Score:** 3

#### Pull Request

The printed app deploy carries --allow-updates, so it runs in a non-interactive shell
