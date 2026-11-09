## fix/3941-audience-note-named-issues

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

- [x] Verify inbound #3941 still stands: `cut-release.ps1`'s task form read `closingIssuesReferences`
  alone, while `notify-live.ps1` also took the issues a PR names (`Get-PullIssueCandidates`, #3498).

### CREATE

- [x] Move `Get-PullIssueCandidates` into `scripts/lib/pull-issue-lib.ps1`, mirrored into dkj-policy and
  bwj-development and held byte-identical; `live-message-rules.ps1` dot-sources it.
- [x] `cut-release.ps1`'s task form reads the same set (`Get-PullRequestCarriedIssues`): a named number is
  asked about through `gh api -i`, a pull request or a 404 is dropped, and a named issue counts only once
  it closed as completed (`Test-NamedIssueSolved`).
- [x] The left-out hint tells an open named issue with a task apart from "no issue it closed or named is
  linked to a task".
- [x] Code review (Victor): a deleted issue answers 410, not 404, so a named `#<n>` pointing at one
  would have aborted every rerun of the cut; both readers now treat 410 like 404.

### TEST

- [x] Asserts in `bwj-development.tests.ps1` for the solved test and for both readers using the one rule;
  the native-capture ledger records the changed `$isCap`. Full gates by `ship-pr`.

### DEPLOY: fix/3941-audience-note-named-issues

The release cut's audience note now finds an entry's task through the issues its PR **names** as well as
the ones it closes, the same set `notify-live` reads (#3941). At BWJ-Development/smartwatchbanden's
v2.51.0 cut five storefront entries were left out as "no issue it closed is linked to a task" because
their PRs named the issue without closing it, and `notify-live` then told three of those tasks the release
was live. The rule is now one file, `pull-issue-lib.ps1`, shared by both plugins. A named issue counts
only once it has closed as completed, and one that has not is named in the hint instead of read as having
no task.

**Score:** 3

#### What makes this deploy extra special

A repo that ships its Asana-linked issues with `-NoResolves` gets a cut's audience note with those tasks
linked, instead of adding the links by hand after the draft.

**Score:** 3

#### Pull Request

cut-release's audience note reads the issues a PR names, not only the ones it closes
