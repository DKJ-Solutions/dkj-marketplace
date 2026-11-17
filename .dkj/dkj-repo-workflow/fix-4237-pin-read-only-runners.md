## fix/4237-pin-read-only-runners

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

Issue #4237, the pin half (the owner chose both halves; the release cut is a separate owner act). The
#4209 rename moved script paths on main before any release, and every consumer runner on `ref: main`
went red. Pin the read-only runners to the release a consumer adopts, as the write runners already are
(#2333), which reverses #1805's choice for them.

### CREATE

- [x] `release-pin-lib.ps1` (new, mirrored): `Get-ScaffoldingPluginVersion` moved out of adopt-ci-floor,
  plus `Get-ScaffoldingReleaseTag`, so both scaffolders read the release from one place
- [x] `adopt-workflow-folder.ps1`: the branch-entry and always-on-budget callers call `@vX.Y.Z` and pass
  `scripts-ref: vX.Y.Z`; a re-run names an existing caller still on `@main`; an unreadable version falls
  back to main, loudly
- [x] `adopt-ci-floor.ps1`: repo-settings.yml fetches the shared scripts at the same pinned ref as the
  write runners; a re-run reports it on main or behind, with the read-only reason
- [x] `check-consumers.ps1` check 6d: a read-only runner or gate caller on a moving ref is an `[INFO]`
  with the #4237 reason, never the credential one
- [x] The three reusable workflows' `scripts-ref` commentary, the adopt skill page and Sylvester's lens
  updated; the default stays `main` only so callers placed before this still start
- [x] Filed #4246: the house-style caller the dkj-brandbook skill gives still calls `@main`
- [x] Review fixes: Edith's stale sentences (check 6d header, both scaffolders' headings, the lens), Victor's
  narrow `@main` re-run match (now quoted/commented, and only this repo's calls)

### TEST

- [x] adopt-workflow-folder.tests 188/0 (pinned `uses:` + `scripts-ref`, re-run advisory), adopt-ci-floor.tests
  334/0 (repo-settings pinned, read-only re-run verdict), consumers.tests 445/0 (scenario 12s, 12s2)

### DEPLOY: fix/4237-pin-read-only-runners

Both adoption scaffolders now pin every CI runner they place to the dkj-repo-workflow release they came
from (#4237). The branch-entry and always-on-budget callers from `adopt-workflow-folder` call
`@vX.Y.Z` and pass `scripts-ref: vX.Y.Z`. The repo-settings runner from `adopt-ci-floor` fetches the
shared scripts at the same release, as the write runners have since #2333. This reverses #1805's
choice to keep the read-only runners on main. The #4209 rename moved every script path on main a day
before any release carried it, and every consumer runner on `ref: main` went red at once. Internally,
the register's check 6d reports a read-only runner still on main as an `[INFO]`, and the new
`release-pin-lib.ps1` holds the version read both scaffolders share.

**Score:** 2

#### What makes this deploy extra special

For the maintainer of a repo that adopts the workflow: a newly adopted repo's CI gates no longer go red
when the source moves a script on main before a release. They move when you adopt the release. A
repo adopted earlier keeps its `@main` callers. A re-run of `adopt-workflow-folder` or `adopt-ci-floor`
names the line to change.

**Score:** 3

#### Pull Request

Pin the read-only consumer runners to the adopted release, not main
