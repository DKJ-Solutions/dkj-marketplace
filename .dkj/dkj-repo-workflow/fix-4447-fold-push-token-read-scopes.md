## fix/4447-fold-push-token-read-scopes

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

#4447: merge-on-green's Ship it step runs `ship-pr` under `FOLD_PUSH_TOKEN`, and the docs scope that PAT
to `Contents` + `Pull requests` only. Verified before repairing: `ship-pr` reads the required check
(`gh pr checks`, the status-check rollup) and the closing issues (`gh issue list/view`) as `GH_TOKEN`,
which in that step is the PAT; the job's `permissions:` block (#3491, #3619) reaches only the picker's
`GITHUB_TOKEN`. The issue's first option is taken -- name the scopes -- because splitting ship-pr's reads
onto a second token is a larger change to the merge path. The probe that reads an error as "not
registered" is #4448's own subject, and is left to it.

### CREATE

- [x] `adopt-ci-floor.ps1` (and its `scripts/task/` mirror): the scaffolded merge-on-green header and the
      Part 3 console note name `Checks`, `Commit statuses`, `Actions` and `Issues`, each Read-only.
- [x] `adopt-dkj-repo-workflow` SKILL.md: the merge-on-green section names the same four, and why.
- [x] `adopt-ci-floor.tests.ps1`: two asserts pin the note and the scaffolded header.

### TEST

- [x] The suites run under `ship-pr`'s gate.

### DEPLOY: fix/4447-fold-push-token-read-scopes

The adopt skill and its Part 3 scaffold now say that `FOLD_PUSH_TOKEN` needs four read scopes on the
merge-on-green path, which the docs had left out.

**Score:** 2

#### What makes this deploy extra special

A private repo running merge-on-green whose sweep refuses a green pull request after 1800s with "never
registered" now finds the cause in the adopt skill: add `Checks`, `Commit statuses`, `Actions` and
`Issues` (Read-only) to `FOLD_PUSH_TOKEN`. An existing runner is not rewritten; the fix is on the token.

**Score:** 3

#### Pull Request

Name the read scopes FOLD_PUSH_TOKEN needs on merge-on-green's ship path

