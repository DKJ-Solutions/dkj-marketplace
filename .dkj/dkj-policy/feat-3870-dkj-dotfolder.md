## feat/3870-dkj-dotfolder

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

#### The rule

Build in `plugins/`, use in `.dkj/`: a dot-folder is a tool's and a plain folder is the product. `.claude/`
was declined as the home because it is a Claude Code protected path (every write prompts).

### CREATE

- [x] `workflow-folder-lib.ps1`: one list of folder names, `.dkj/dkj-policy` first, read by seam-lib and entry-scaffold-lib
- [x] Branch-document paths, ship-pr, the hub's release-notes route, measure-closeouts and issue-dashboard read the folder off the tree
- [x] `adopt-workflow-folder.ps1` moves an older folder with `git mv` and repoints `repo-config.ps1` and `.gitignore`
- [x] This repo's own folder moved, its seam answers, `.gitignore`, the PR templates and the relative links
- [x] Docs: present-tense paths repointed, dated history left as written; the adopt skill explains the move

### TEST

- [x] The migration step run on a throwaway repo: folder, seam answer and `.gitignore` line all moved
- [x] Lint gate and the suites that touch the folder
- [x] Code review (Victor): publish-to-business still named the old changelog path, and callers holding a repo root now pass it to Get-BranchFilePaths

### DEPLOY: feat/3870-dkj-dotfolder

The workflow's own folder moves from the repo root to [`.dkj/dkj-policy/`](./), so a repo now tells what
it **builds** (`plugins/<plugin>/`, in this repo) from what an installed plugin **uses** in it
(`.dkj/<plugin>/`): a dot-folder is a tool's, a plain folder is the product. A second plugin that leaves
data in a repo gets `.dkj/<its-name>/` beside it, so nothing ever has to merge. `.claude/` was the first
candidate and was declined: it is a Claude Code protected path, so every write there asks for
confirmation, and the branch document is written almost every turn.

One list of folder names now lives in
[`workflow-folder-lib.ps1`](../../scripts/lib/workflow-folder-lib.ps1), read for the changelog and release
roots and for the branch documents alike, so the two cannot disagree in a repo mid-move. The root
`dkj-policy/` and the two names before it are still read wherever `.dkj/dkj-policy/` does not exist, so
nothing breaks before a repo moves.

**Score:** 3

#### What makes this deploy extra special

Every consumer moves its folder once: Part 1 of `adopt-dkj-policy`, run with `-Apply`, does it in one
`git mv` and repoints the quoted paths in `scripts/repo-config.ps1` and the `.gitignore` lines that name
the old folder. Until then everything keeps working where it is, and the session check names the move.

**Score:** 4

#### Pull Request

The workflow folder moves to .dkj/dkj-policy/: build in plugins/, use in .dkj/

