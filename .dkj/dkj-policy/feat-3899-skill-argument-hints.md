## feat/3899-skill-argument-hints

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

The owner's decision on #3899 (November 8, 2026): `argument-hint`, and `shell` where it fits; no
`allowed-tools` grants. Verified against code.claude.com/docs/en/skills: `shell` governs only the
`` !`command` `` and ` ```! ` injection blocks, and no skill in the tree has one, so it fits none. A hint
goes only on a skill that takes a typed argument, its wording taken from the parameter the skill's own
script reads.

### CREATE

- [x] `argument-hint` on fifteen skills: `claim-issue`, `new-branch`, `ship-pr`, `open-pr`,
  `worktree-lane`, `check-branch-entry`, `fix-mojibake`, `stopwatch-prepare`, `stopwatch-hide`,
  `plan-goal`, `retro`, `record-suite-durations` (dkj-policy), and `start-task`, `archive-theme`,
  `push-preview` (dkj-subagents-shopify). One frontmatter line each, nothing else changed.
- [~] `shell`: dropped, as no skill carries an injection block for it to govern.

### TEST

- [x] `claude plugin validate` on both plugins passes; its one warning (the plugin-root `CLAUDE.md`) predates
  this branch.

### DEPLOY: feat/3899-skill-argument-hints

Fifteen skills now show the argument they expect in the slash-command autocomplete: `/claim-issue
[issue-number]`, `/new-branch [<prefix>/<n>-<short-name>] [title]`, `/ship-pr [issue-number(s) it
resolves]`, `/push-preview [storefront path]` and so on. No skill gained a tool grant: the owner chose
`argument-hint` only, and `shell` governs injection blocks no skill has (#3899).

**Score:** 2

#### What makes this deploy extra special

Typing `/` and a skill name now says what to type after it, for the fifteen skills that take an argument.

**Score:** 2

#### Pull Request

Skills show their expected argument in the slash menu

