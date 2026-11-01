## feat/note-absorbs-muted-and-footer-note

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

### CREATE

- [x] `house-style.css`: the `.muted` and `.footer-note` rules go; `.note` is the one quiet-text class, and the page column, the fill switches and the comments name it alone
- [x] README: a rename section with its table (`.muted`, `.footer-note` -> `.note`); every current-state mention follows, the dated history tables are left as written
- [x] The house's own markup follows: `specimens.html` (the Text page's two rows go, the hero label and the shell note), both patterns, the hub's page shell, `repo-hub-page.ps1`, the consumer dashboard and the dev pages
- [x] The suites that read `class="footer-note"` read `class="note"`: dev-pages, consumer-dashboard and dev-preview-sessionstart, all green
- [x] Filed #3716: the release-notes map still points `ink-faint` at the retired `--muted` token (a different subject, found here)

### TEST

- [ ] The owner has looked at the brand book's Text page and a hub page's footer note

### DEPLOY: feat/note-absorbs-muted-and-footer-note

The house style has one class for quiet text, `.note`. `.muted` and `.footer-note` drew the same `--primary-muted` text at `--text-sm` under three names, told apart only by a top margin the page column already took away, so they are retired into `.note` (Maikel, November 1, 2026). The README carries the rename table, and every page the hub and the dashboards render uses `.note`, so nothing here looks different.

**Score:** 3

#### What makes this deploy extra special

An app taking this release renames `.muted` and `.footer-note` to `.note` in its own markup, by the README's table. A use left behind loses its grey and reads as plain text, without an error, so the rename has to be done rather than noticed.

**Score:** 4

#### Pull Request

One quiet-text class: .note absorbs .muted and .footer-note

