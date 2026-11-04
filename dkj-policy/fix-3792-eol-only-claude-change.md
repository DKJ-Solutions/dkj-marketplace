## fix/3792-eol-only-claude-change

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

Issue #3792. Its reason verified in a scratch repo before the repair: with a CRLF file committed and
rewritten as LF, `git status --porcelain` says ` M` while `git diff --ignore-cr-at-eol --quiet` exits 0
(and 1 on a real content change), with `core.autocrlf` both false and true.

### CREATE

- [x] `Restore-EolOnlyClaudeChange` in `update-plugins.ps1` (and its plugin mirror): after a run, a
  `.claude/` whose every change is ` M` and EOL-only is restored with `git checkout -- .claude` and read
  back clean; anything else falls through to the existing "review and commit" line
- [x] The help text and the skill page say so

### TEST

- [x] `update-plugins.tests.ps1` scenarios 25 (an LF rewrite of a CRLF settings.json is restored, the
  bytes are CRLF again and no commit is asked for) and 26 (a real content change is still named and left
  in place) -- 155 pass, 0 fail standalone

### DEPLOY: fix/3792-eol-only-claude-change

`update-plugins -AllCheckouts` no longer asks you to review and commit a `.claude/settings.json` that
`claude plugin install/update` merely rewrote with different line endings (#3792). When every change the
run left under `.claude/` is line endings only, the sweep restores the committed bytes and says so; a real
change is still named in the summary as before.

**Score:** 2

#### What makes this deploy extra special

**Score:** N/A

#### Pull Request

update-plugins -AllCheckouts restores an EOL-only .claude/ rewrite instead of asking for a commit

