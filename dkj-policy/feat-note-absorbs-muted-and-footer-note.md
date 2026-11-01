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
- [x] `--font-serif` retired: no house class and no app on this machine reads it (measured in dkj-marketplace, dkj-lifehub, dkj-music-library); the token, its specimen and its README row go. `--font-mono` stays: `.prose` sets code in it and dkj-music-library reads it about 55 times
- [x] `--font-mono` leaves the Type scale card, where it read as a size, for a card of its own, Font family, in the same Text token group (`$script:ProductBrandbookTokenGroups`), and gets its own row in the README's token table
- [x] The Type scale and Font family cards drop their notes: each sample is its own token's name set in that token, one per line
- [x] The type scale's heading samples drop their colour and weight: the card shows sizes only, and h1 alone carried `--primary`, so h2 read as a different colour than its element has
- [x] The type scale: `--text-h1` 36px (was 32), `--text-h2` 22px (was 18), `--text-h3` 16px (was 14); `--text-lg` retired, its 13 house rules and the DKJ card title take `--text-h3`, and `.prose`'s h1 takes `--text-h2` to stay a step below the page. README: a dated section with the table, the Type row and the heading ceiling follow
- [x] Suites: stopwatch's allowed-size list drops `text-lg`; dev-pages' DKJ-card assert read `h3` inside a value (`var(--text-h3)`) as a selector, so it now reads selectors only, checked to still catch an `h3` rule
- [x] Filed #3716: the release-notes map still points `ink-faint` at the retired `--muted` token (a different subject, found here)

### TEST

- [x] The owner has looked at the brand book pages and said ship it (Maikel, November 1, 2026)

### DEPLOY: feat/note-absorbs-muted-and-footer-note

The house style has one class for quiet text, `.note`. `.muted` and `.footer-note` drew the same `--primary-muted` text at `--text-sm` under three names, told apart only by a top margin the page column already took away, so they are retired into `.note` (Maikel, November 1, 2026). The README carries the rename table, and every page the hub and the dashboards render uses `.note`, so nothing here looks different. `--font-serif`, kept after October 24 for a title that never came, is retired with them; `--font-mono` stays, and the brand book now shows it as what it is, a typeface: its own Font family card and table row instead of a line in the type scale. The headings grow a step, 36/22/16 where they were 32/18/14, and `--text-lg` is retired into `--text-h3`. Both cards set each token's name in the token itself, with no note beside it, and in its size alone: no heading colour or weight, which belong to the elements on the Text page.

**Score:** 3

#### What makes this deploy extra special

An app taking this release renames `.muted` and `.footer-note` to `.note` in its own markup, by the README's table. A use left behind loses its grey and reads as plain text, without an error, so the rename has to be done rather than noticed. An app still reading `--font-serif` falls back to the sans. Headings render larger (36/22/16), and an app moves each `--text-lg` in its own layer to `--text-h3`; one left behind renders at the inherited size.

**Score:** 4

#### Pull Request

Brand book: .note absorbs .muted and .footer-note, a larger heading scale, and --font-serif and --text-lg are retired

