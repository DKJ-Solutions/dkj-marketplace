## feat/3761-store-execute-live-refused

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

Decision on #3761 (davekokbwj, November 3, 2026): option (a). Rule 4 refuses every live-aimed theme write through `shopify store execute`, marker or not.

### CREATE

- [x] `guard-live-theme.ps1`: rule 4's theme-write branch no longer reads the live-push marker; the refusal points at the CLI live push `live-preflight` composes; header and both comment blocks restated; the duplicated `$THEME_WRITE` assignment removed
- [x] `guard-live-theme.tests.ps1` group 9: the marker-passes assert flipped to refused, a `--variable-file` case with the marker added, the refusal-text assert now checks the marker is NOT offered and `live-preflight` is
- [x] `dkj-subagents-shopify/README.md`: rule 4's row and the merged-work-only paragraph say no marker authorises the API route

### TEST

- [x] the gates run inside `ship-pr`

### DEPLOY: feat/3761-store-execute-live-refused

The Shopify team's live-theme guard now refuses an Admin API theme write aimed at the live theme (`themeFilesUpsert`, `themeFilesCopy`, `themeUpdate` and the rest, through `shopify store execute`) even when the command carries `# LIVE-PUSH-AUTHORIZED`. Until now the marker let it through, and because its content is inline rather than in theme files, nothing held it to the trunk the way #3758 holds a CLI live push, so unmerged work could reach live by that route. The refusal now points at the one live route: a CLI `shopify theme push` of merged work, which `live-preflight` composes.

**Score:** 2

#### What makes this deploy extra special

A Shopify consumer that wrote to its live theme through `shopify store execute` with the marker is refused now and has to push merged work with `shopify theme push` instead. No documented flow used the API route, so for most consumers nothing changes except that the merged-only rule can no longer be bypassed.

**Score:** 2

#### Pull Request

guard-live-theme: refuse every live-aimed Admin API theme write, marker or not

