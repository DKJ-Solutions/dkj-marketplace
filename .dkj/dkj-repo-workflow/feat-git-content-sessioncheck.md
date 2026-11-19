## feat/git-content-sessioncheck

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

Make the "what belongs in git" rule (#4331) checkable instead of remembered. A hand audit of the six
DKJ-Solutions app repos found two violations (dkj-recipes#133, dkj-thumbnail-generator#60); the same
signal as a SessionStart hook keeps finding them without anybody asking.

### CREATE

- [x] Sylvester: `git-content-rules.ps1` lib + `git-content-sessioncheck.ps1` hook in the `dkj-repo-workflow-dkj` extension, wired in its `hooks.json`
- [x] Sylvester: `Get-GitContentAllowlist` in this repo's `scripts/repo-config.ps1` (plugins, marketplace manifest, baselines)
- [x] Tycho: `git-content-sessioncheck.tests.ps1` (10 asserts), registered in `suite-groups.json`
- [x] Tessa: the extension's `CLAUDE.md` chapter and README name the hook and the allowlist
- [x] Victor: code review of the diff. One real finding repaired: a non-ASCII path came back quoted by git, so its extension read `.md"` and the folder was invisible (now unquoted, and asserted). Also the thresholds now come from the result rather than a fixed string, and the `plugins*` glob became `plugins` + `plugins/*`.

### TEST

- [x] Prototype measured on all seven DKJ checkouts: exactly the two hand-found folders, 0.1-1.6 s per repo

### DEPLOY: feat/git-content-sessioncheck

A new SessionStart check in the `dkj-repo-workflow-dkj` extension, `git-content-sessioncheck`, names
every tracked folder that holds only content files (`.md`, `.json`, `.csv` and the like) and was touched
by 10 or more commits in the last 90 days: data that keeps paying the branch + PR toll, against the "what
belongs in git" rule. Tooling folders and test material are never named. A folder kept in git on purpose
goes in `Get-GitContentAllowlist` in the repo's `scripts/repo-config.ps1`, with its reason. Measured over
the six DKJ-Solutions app repos, it names exactly the two folders a hand audit found, in 0.1 to 1.6
seconds per repo.

**Score:** 3

#### What makes this deploy extra special

Every DKJ-Solutions repo now says at session start when notes or data in it keep going through pull
requests, so the slowdown is seen before it costs weeks.

**Score:** 3

#### Pull Request

Session check reports content folders that pay the PR toll without being code

