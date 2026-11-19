## fix/4330-trunk-guard-quote-aware-split

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

Inbound #4330: `Split-CommandSegments` splits on a raw `;`, `&&` or `|` with no notion of quotes, so
`git -c user.name="a;b" commit -m wip` reached `Get-TrunkCommitViolation` as two halves, neither a
commit led by git, and was allowed on the trunk. The fix: judge a second, quote-aware reading beside
the plain one. A refusal in either reading refuses the commit. This is the approach the reporting
consumer used locally.

### CREATE

- [x] `Split-CommandSegmentsQuoteAware` in `command-guard-lib.ps1`, and a `-QuoteAware` switch on
  `Get-GuardSegments` that is off by default, so guard-live-theme and the other working-copy rules are
  unchanged. Both mirrors resynced.
- [x] `Get-TrunkCommitViolation` judges both readings, with the directory tracking restarted per
  reading. `Get-FirstLineAfterSegment` searches for a segment's first line only, because a quote-aware
  segment can span lines (the heredoc-subject case). The `working-copy-guard-lib.ps1` mirror resynced.

### TEST

- [x] New cases: the quoted `a;b` and `a&&b` commits are refused, a `fold:` subject with a quoted `;`
  is allowed, and the wrapper form is still refused. The splitter cases: two segments quote-aware, and
  three plain, which is unchanged.
- [x] Run standalone: `command-guard-lib` 43/0, `working-copy-guard-lib` 221/0, `guard-working-copy`
  85/0. The full gate is `ship-pr`'s.

### DEPLOY: fix/4330-trunk-guard-quote-aware-split

The trunk-commit guard no longer lets a quoted separator split a commit in two (#4330).
`git -c user.name="a;b" commit -m wip` on the trunk was allowed, because the command was split at the
`;` inside the quotes. The guard now also reads the command quote-aware and refuses when either
reading refuses.

**Score:** 2

#### What makes this deploy extra special

A consumer can drop its own quote-aware trunk guard and rely on the plugin's without reopening this
form. The `-c "user.name=a b"` and quoted-`&&` variants are closed too.

**Score:** 2

#### Pull Request

The trunk-commit guard reads a quoted separator as a split

