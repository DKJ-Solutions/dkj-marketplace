## feat/3871-extensions-folder

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

- [x] Dave chose (November 7, 2026, on #3871) to build this on its own now rather than wait for a bundled
  import-line change. Both stay separate plugins; only the folder grouping changes, and plugin ids do not.

### CREATE

- [x] `git mv` both extension folders under `plugins/dkj-policy/extensions/`; `marketplace.json` sources follow.
- [x] Every path citation outside the release history repointed (scripts, tests, workflows, lenses, READMEs,
  the root `CLAUDE.md` import); release-history files keep their text and only get their relative links
  repointed so the link gate holds. Measured-history comments keep the path they measured.
- [x] Admin URLs (`/marketplace/dkj-policy/<extension>`) are unchanged: they are addresses, not paths.
- [x] `build-house-palette.ps1` climbs one level more to the core brand book.
- [x] The house-style pin reads both depths: `Get-HouseStylePin` accepts the product URL at either depth,
  `Get-HouseStyleTagPin` fetches a pinned tag's page at either depth, and the reusable workflow sparse-checks
  out and picks from both, because a pinned tag cut before this move carries the old path.
- [x] `claude-md-import-lib.ps1` (three byte-identical copies): the current import line names
  `.../dkj-policy/extensions/<name>/CLAUDE.md`; a line at the old depth counts as retired, so adopt rewrites
  it in place and `consumer-prose-sessioncheck` warns about it. Its warning and adopt's messages now say
  "a retired name or path".
- [x] The `[plugin-kind]` lint holds an extension to `plugins/dkj-policy/extensions/<name>`.
- [x] The `adopt-dkj-policy` skill page names the new line and the old-depth rewrite.

### TEST

- [x] Lint `check-plugin-integrity.ps1`: 0 errors.
- [x] The first gate run found two suites building the path from segments (`reach-label`, `dev-preview-sessionstart`); both repointed, and `check-house-style` gained a product row at the new depth.
- [x] `bwj-extension-import.tests.ps1` gains old-depth asserts (pattern, not-imported, retired row) and an
  end-to-end adopt rewrite; it and `dev-pages`, `consumer-dashboard`, `consumer-prose-gate`,
  `adopt-workflow-folder`, `check-house-style`, `house-palette`, `cut-release-drive`, `shared-scripts` and
  the other touched suites pass on their own.

### DEPLOY: feat/3871-extensions-folder

The two `dkj-policy` extension plugins, `bwj-development` and `dkj-solutions`, now sit together under
`plugins/dkj-policy/extensions/` (#3871). They stay two separate plugins with the same ids, so
`.claude/settings.json` needs nothing. In this repo, every path, test and workflow follows the move, and the
house-style gate still reads a brand-book pin from a tag cut before it.

**Score:** 2

#### What makes this deploy extra special

**Action needed in every repo that enables `bwj-development` or `dkj-solutions`.** Your `CLAUDE.md` imports
the extension by its path in the marketplace clone, and that path moved: the old line
`@~/.claude/plugins/marketplaces/dkj-marketplace/plugins/dkj-policy/<extension>/CLAUDE.md` loads nothing
after this release, so the extension's rules quietly drop out of context. After updating the plugins
(`update-plugins`, which refreshes the marketplace clone too), run the `adopt-dkj-policy` skill's
`adopt-workflow-folder.ps1 -Apply`, or in a BWJ store repo the `adopt-bwj-development` skill: it rewrites the
line in place to `.../plugins/dkj-policy/extensions/<extension>/CLAUDE.md`. Until you do, the session-start
check warns about the old line and prints the new one.

**Score:** 5

#### Pull Request

Group the dkj-policy extensions under plugins/dkj-policy/extensions/

