## fix/facts-long-value

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

Cause 1 of the phone inventory #4113: a fact row's long value ran over its term or past the card. The reason was
read in the house rule before the repair: `.facts dt { min-width: 0 }` let the term shrink to nothing and
`.facts dd { white-space: nowrap }` held the value to one line.

### CREATE

- [x] `house-style.css`: the term keeps its width (`flex: none`) and the value wraps under itself
      (`min-width: 0; overflow-wrap: anywhere`), right-aligned as before
- [x] `/consumers/dkj/<repo>` keeps its one-line facts with an ellipsis (Maikel, October 28, 2026): `.dr-facts dd`
      now states the `nowrap` it had borrowed from the house rule
- [x] Docs coverage's popup drops `.dc-detail__facts dd`, a local copy of what the house rule now does

### TEST

- [x] `dev-pages.tests.ps1`: the house rule's shape, `.dr-facts` still one line, no local copy in docs coverage
- [x] `check-house-style`, `house-palette` green
- [x] Seen at 390px: the specialist page's "What it is" and "Its files", the team page's "Holds" and "Source"

### DEPLOY: fix/facts-long-value

On a phone a fact row's long value -- a source path, a plugin with its note, a sentence -- no longer runs over its
label or past the card: the label keeps its width and the value wraps under itself, right-aligned. A short value
reads as before.

**Score:** 3

#### What makes this deploy extra special

Every product built on the brand book shows its `.facts` lists readably on a phone: a long value wraps instead of
covering its term. A page that wants one-line facts now says `white-space: nowrap` in its own layer.

**Score:** 2

#### Pull Request

A fact row's long value wraps under its label instead of running over it on a phone
