## feat/3817-admin-nav-search

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

#3817: Admin's navigation (#3815) was built without the search field the Shopify Admin puts at its top. A page two
levels down (Rules, Skills, Stopwatch) is reached by clicking through a group page; a search over the navigation
items, the group pages and the pages under them makes each one a few keystrokes away.

### CREATE

- [x] Brand book: `.nav-search` (with `__input`, `__key`) in `house-style.css`, beside the shell's other classes, with
      the field drawn in the desktop-shell specimen (`specimens.html`) and in `patterns/admin-shell.html`.
- [x] Hub: `Get-AdminSearchItems` (the navigation's items, the group pages that are pages, and the general pages, once
      per address) and `Format-AdminNavSearch` (the field, Ctrl K / Cmd K, Enter opens the first match, Escape
      clears), drawn first in `Format-AdminShellOpen`. The script only toggles `hidden` on what the server drew.
- [x] `dev-pages.tests.ps1`: the navigation's opening assert follows the field, and five new asserts cover the field,
      what it finds, the toggling, the ordering and dedupe, and the escaping.

### TEST

- [x] On their own: dev-pages 603/0, check-house-style 157/0, house-palette 161/0, dev-preview-sessionstart 375/0.
- [ ] The owner looks at Admin: the field on top of the navigation, Ctrl K focusing it, and typing (e.g. "rules")
      narrowing the navigation to the matches.

### DEPLOY: feat/3817-admin-nav-search

Admin's side navigation now opens on a search field. Press Ctrl K (Cmd K on a Mac) anywhere in Admin to jump to it,
type part of a page's name or description, and Enter opens the first match. It finds every page in the navigation and
the pages under its groups, such as Rules, Skills and Stopwatch, so none of them is more than a few keystrokes away.
The brand book's desktop shell gains the field as `.nav-search`.

**Score:** 3

#### What makes this deploy extra special

A Toolbox user reaches any Admin page from the keyboard, without clicking through a group page first.

**Score:** 3

#### Pull Request

Admin's navigation opens on a search field, focused with Ctrl K

