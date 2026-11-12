## feat/done-follows-primary

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

#### Why

`--done-3` was GitHub's purple in every theme (November 9, 2026), so in a theme like Paars or Magenta it stood
beside the primary as a near copy, and in the rest as a fourth colour outside the 60-30-10 groups. The owner
(November 12, 2026): done becomes a variant of the theme's primary. No new token: done reads `--primary-muted`,
the 30 group's grey for what may recede, which is what finished work is.

### CREATE

- [x] `house-style.css`: `--done-3` removed from the light `:root` and both dark blocks
- [x] README: the Status row says done takes `--primary-muted`, the Grey row lists done among its roles, the switch table drops `--done-3`
- [x] `--done-3` retired in `Get-HouseStyleRetiredTokens`, so the gate reports a repo layer still reading it
- [x] `specimens.html`: the `--done-3` swatch removed
- [x] docs coverage: Covered reads `--primary-muted`; Waiting, which read it before, moves to `--primary-border` so no two statuses share a colour
- [x] Figma: the three `done-3` variables deleted, the Done tone, its mark and the status instance rebound to `color/primary-muted`

### TEST

- [x] `house-palette`: 199 passed; `check-house-style` suite: 169 passed
- [x] `dev-pages`: 753 passed (every coverage status keeps its own colour); `consumer-dashboard`: 255 passed

### DEPLOY: feat/done-follows-primary

Done (finished and closed work) now takes the theme's own grey, `--primary-muted`, instead of one purple in every theme, so it
no longer looks like the primary in the purple and magenta themes. `--done-3` is retired: a page that still reads it is reported by the house-style gate and should switch to `--primary-muted`.
**Score:** 2

#### What makes this deploy extra special

N/A
**Score:** 0

#### Pull Request

Done follows the theme: --done-3 becomes --primary-muted
