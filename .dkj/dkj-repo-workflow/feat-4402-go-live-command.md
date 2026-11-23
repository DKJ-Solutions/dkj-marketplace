## feat/4402-go-live-command

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

Built on the owner's decision recorded on #4402 (November 23, 2026): one marker on the go-live line,
which guard-live-theme learns to read; the app deploy inside that word as a required -AppDeploy /
-SkipAppDeploy switch. Home: dkj-repo-workflow-bwj, beside prepare-release and notify-live, because the
chain crosses the Shopify team (preflight), the workflow (cut) and this extension (notify).
Scope: a Git-connected store only; a CLI-push store is refused and keeps live-preflight's printed push.

### CREATE

- [x] guard-live-theme rule 6: a line running go-live.ps1 needs the live-push marker
- [x] live-preflight -ResultPath: the outcome as JSON, so go-live carries on from the same facts (source + mirror)
- [x] go-live-rules.ps1: step order, app-deploy switch, check states, verify paths, hash compare, record hold rewrite, resume line
- [x] go-live.ps1: preflight -> promote -> checks -> merge -> verify -> app -> cut -> notify, stop at the first refusal, -ResumeFrom past the merge
- [x] docs: the go-live skill page, the extension README row, live-preflight's page

### TEST

- [x] bwj-go-live.tests.ps1: 41 pass
- [x] guard-live-theme.tests.ps1: 425 pass, rule 6 included
- [x] check-plugin-integrity: 0 errors

### DEPLOY: feat/4402-go-live-command

New `go-live` skill in dkj-repo-workflow-bwj, with a rules lib and a suite; `guard-live-theme` gains a
rule 6; `live-preflight` gains `-ResultPath` (#4402).

**Score:** 3

#### What makes this deploy extra special

In a store whose live theme deploys from a Git-connected branch, release day is one command once the
owner has given the word: `go-live -Version X.Y.Z -AppDeploy` (or `-SkipAppDeploy`) with the store's
live-push marker on that line. It runs the preflight, opens and merges the promotion PR after its
required checks pass, polls the live theme until every promoted file matches the trunk by content hash,
deploys the app or writes `hold` for it into the live-push record, cuts the release and tells the tasks,
and stops at the first refusal with a line to resume from. Before, each of those steps was printed and
handed back to a person; the promotion alone took three attempts to get past the guards. The live guard
now refuses a go-live line without the marker.

**Score:** 4

#### Pull Request

One go-live command from the owner's word to a verified, cut release

