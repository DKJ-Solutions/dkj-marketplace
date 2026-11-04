## fix/3802-merge-in-progress

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

Issue #3802, measured on PR #3800: a 502 on ship-pr's merge call, a read-back of OPEN, a refusal that
blamed a merge queue this repo does not have, and a re-run whose merge call GitHub then refused with
`Merge already in progress` -- reported as a plain failed merge. Repair both halves: treat the lock as
a merge still landing, and stop naming a queue where the trunk's rules were read and carry none.

### CREATE

- [x] `Test-GhMergeInProgress` in `pr-issues-lib.ps1` (both copies): GitHub's own wording, kept apart from the 5xx classifier that also serves open-pr's create.
- [x] ship-pr classifies a failed merge as a held lock before the hard-failure path, and joins the #1916 read-back.
- [x] The read-back polls about a minute (13 reads, 5s apart) after a failed merge call; an ordinary exit 0 keeps three reads.
- [x] A merge that does not read MERGED in that minute is handed back as "NOT a failed merge", the PR left armed for the merge-on-green sweep.
- [x] The #1325 refusal names a merge queue only when the trunk's rules could not be read.

### TEST

- [x] `pr-issues.tests.ps1`: unit asserts for the classifier (the measured wording, a real not-mergeable refusal, null/empty, and that the 5xx classifier does not match it) and call-site asserts on ship-pr. 1177 asserts pass standalone.

### DEPLOY: fix/3802-merge-in-progress

ship-pr no longer reports GitHub's `Merge already in progress` as a failed merge (#3802). After a 5xx
or that answer, it polls the PR for about a minute and folds once it reads MERGED. If it does not, it
says the merge is held by GitHub and leaves the PR armed for the merge-on-green sweep. The refusal for
an unmerged PR no longer names a merge queue when the trunk's rules were read and carry none.

**Score:** 2

#### What makes this deploy extra special

Whoever runs ship-pr in a consumer and hits a GitHub server error on the merge now gets a run that
waits the lock out or hands it back with the right advice, instead of a hard failure followed by a
misleading hint about a merge queue. Small, and noticed only when GitHub has a bad minute.

**Score:** 2

#### Pull Request

ship-pr: 'Merge already in progress' is a merge still landing, not a failed merge

