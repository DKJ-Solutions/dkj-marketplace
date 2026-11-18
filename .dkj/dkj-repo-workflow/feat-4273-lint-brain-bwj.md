## feat/4273-lint-brain-bwj

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

Step 2 of #4259 for the documentation linter. Both BWJ stores carry a diverged `lint-brain.ps1`, its Stop
hook `lint-changed-hook.ps1` and a suite. Reconcile them into one copy in `dkj-repo-workflow-bwj`. Removing
the store copies is step 3 (#4274).

#### Reconciliation, per behaviour (A = the store with the blockquote check, B = the store with the mojibake check)

- **Link and anchor matching**: from B. It matches the whole file, so a link whose text wraps over two lines is caught. A's per-line regex sees neither half.
- **Bare `<file>.md#<anchor>` references**: from B (A lacks it).
- **Frozen release records exempt from the link checks**: B's rule, with the roots now read from the scanned repo's `Get-ReleaseChangelogNotesRoot` / `Get-ReleaseGithubNotesRoot` seams instead of a hard-coded folder path. With no seam there is no exemption, which is the loud direction.
- **Mojibake, the `-ExecutionPolicy` flag (markdown and `.ps1` help), stale version claims**: from B (A lacks them). The record documents come from the five workflow seams, each probed on its own, because B's single try lost all five when one function was missing.
- **Blockquote lazy continuation** (an ERROR): from A (B lacks it).
- **README index gaps, with the gitignore filter**: from A, but opt-in (`Get-LintBrainOptions` returning `IndexGaps = $true`). B had rejected it as red on arrival.
- **The `tests/` table check**: from B, but opt-in (`TestTable`). It holds a repo to a promise that repo never made.
- **Category letters**: the two stores' letters collided, so they are merged. B's are kept (A links, B mojibake, C exec-policy, D version, E tests table), and A's checks move to F (blockquote) and G (index gaps).
- **`-Quiet` and the hook**: `-Quiet` follows A (findings plus a summary line, `PASS|FAIL: n error(s) (A: 1, F: 1), m warning(s).`). The hook reads every error category from that line in one run. A counted only A+E, while B re-ran the lint and named only dead links. The hook stays fail-soft and never blocks.
- **Repo root and config**: read from the scanned repo through `Resolve-BwjRepoRoot`, not from `$PSScriptRoot`, because the script now lives in the plugin. The hook finds the lint as its sibling.
- **`plugin-floor.ps1`'s loader probe**: it does not move. It belongs to the B store's `plugin-scripts.ps1`, not to the lint, which only names `Get-PluginResolution` in one message. That message now points at `plugin-payload-lib.ps1`.
- **Hook registration**: not added to `hooks/hooks.json`. Both stores still register their own copy, so a second registration would run it twice. Step 3 moves it (noted on #4274).

### CREATE

- [x] `dkj-repo-workflow-bwj/scripts/maintenance/lint-brain.ps1` and `lint-changed-hook.ps1`, the union of both store copies, in English and ASCII, with no store literals
- [x] `scripts/tests/bwj-lint-brain.tests.ps1`, the union of both store suites plus the cases the merge created, registered in `suite-groups.json`
- [x] a row in the extension README's "What ships under it today"

### TEST

- [x] `bwj-lint-brain.tests.ps1`: 149 passed, 0 failed
- [x] `check-plugin-integrity.ps1`: 0 errors, after the suite moved to the fixture-git helpers

### DEPLOY: feat/4273-lint-brain-bwj

The BWJ store maintainers get one documentation linter in `dkj-repo-workflow-bwj`, in place of two diverged
copies, and with it each store gains the other store's checks. Nothing changes for them yet: they keep running
their own copy until step 3 (#4274) switches them over. That step needs `Get-LintBrainOptions` in each store to
switch on the check that store already ran.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Move lint-brain and lint-changed-hook into dkj-repo-workflow-bwj, reconciled from both store copies

