## feat/4272-check-theme-refs-in-bwj

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

#4259 step 2 for `theme/check-theme-refs.ps1` and the `theme-check-gate` test. The two store copies are
reconciled into one copy in `dkj-repo-workflow-bwj`. Removing the store copies is step 3 (#4274), not
this branch.

#### Reconciliation: which copy won, per behaviour

Store A is the copy with 449 lines and store B the copy with 236. No store facts are carried over.

| Behaviour | Taken from | Why |
|---|---|---|
| Language | B | English, as repo content must be; A was Dutch |
| Repo root | `repo-root-lib` (`Resolve-BwjRepoRoot`) | B fell back to `--show-toplevel`, which is banned here; A's script-relative root is wrong for a plugin-shipped script |
| What counts as a section | B | Only `sections/*.liquid`; A counted `.json` groups, which hid a template naming a group as a section type |
| Finding references | B | Parses `sections.<id>.type`; A's regex over group and layout files also caught block types |
| Templates recursion | A | B missed `templates/customers/` |
| Context variants of a group | A, widened | A's `[a-z]+` missed `xx-yy`-style locales |
| Reserved `_blocks` type | B | Shopify's own wrapper section has no file |
| Uncalled-section refinements | A | Presets, the Section Rendering API, the Cart Sections API and own-asset exclusion were each measured against false positives; B listed every uncalled section |
| Section Rendering API match | new | Bounded on the right, so `section_id=foo` is no evidence for `foo-bar` |
| Liquid scan | B, extended | Per line with line numbers; both quote styles and CRLF |
| Missing group | B | `{% sections 'x' %}` with no `sections/x.json` is an error; A could not report it |
| Uncalled groups | A | A warning, with context-variant inheritance |
| JSON comments | B | Banner and `//` lines are stripped; A's global `/* */` strip ate text inside string values |
| Trailing comma | A | A warning, and the file is still read |
| Unparseable file | A | An error; B printed "NOT CHECKED" and exited 0, which fails open |
| Raw control character in a string | A, extended | B had no such check; comment skipping added |
| Allowlist | A's visible `[KNOWN]` output | The built-in table moves to the optional `Get-ThemeRefsAllowedMissing` seam |
| `-Quiet` | B | Summary and verdict only, as both copies' docs said |
| Gate: `continue-on-error` | B | The annotation step must carry it and the gate step must not; A lacked the check |
| Gate: known checks | split | `ValidJSON` and `LiquidHTMLSyntaxError` are in the lib; a store's own come from the optional `Get-ThemeCheckExtraChecks` seam |

### CREATE

- [x] `scripts/lib/theme-refs-rules.ps1` + `scripts/task/check-theme-refs.ps1` in the extension
- [x] `scripts/lib/theme-check-gate-rules.ps1` + `scripts/task/check-theme-gate.ps1` in the extension
- [x] Suites `bwj-theme-refs` and `bwj-theme-check-gate`, made-up fixtures only, registered in `suite-groups.json`
- [x] The extension README's table lists both

### TEST

- [x] `bwj-theme-refs.tests.ps1`: 62 passed. `bwj-theme-check-gate.tests.ps1`: 34 passed. `check-plugin-integrity`: 0 errors.
- [x] Read-only run against both store checkouts: the reference check passes in both, with warnings only. The gate check names adoption work for step 3 (#4274): one store's annotation step lacks `continue-on-error: true`, and the other must declare its extra theme-check names through the seam.
- [x] The full gate runs in `ship-pr`.

### DEPLOY: feat/4272-check-theme-refs-in-bwj

`dkj-repo-workflow-bwj` now ships the theme-reference check and the theme-check gate shape check. The
two BWJ stores used to keep separately diverged copies of each. Every behaviour where the two copies
differed is now settled in one place and covered by this repo's suites, so a fix reaches both stores
through a release ([#4272](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4272), part of
[#4259](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4259)).

**Score:** 3

#### What makes this deploy extra special

A BWJ store maintainer gets the scripts, but nothing changes for them until the store swaps its copy
for a forwarder (#4274).

**Score:** N/A

#### Pull Request

Move check-theme-refs and its gate into dkj-repo-workflow-bwj

