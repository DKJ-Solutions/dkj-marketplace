## docs/3722-settings-toggle-readme

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

Resolves #3722: the brand book README's settings-button paragraph still described the toggle as it
looked before November 1, 2026; `house-style.css` has drawn it icon-only since then.

### CREATE

- [x] Rewrite the toggle sentence in `plugins/dkj-policy/assets/dkj-brandbook/README.md` to match the
  `.theme-settings__toggle` rule, keeping the earlier look as dated history

### TEST

- [x] Read the sentence against `house-style.css` (`.theme-settings__toggle`: `background: none;
  border: 0; color: var(--fg-1)`): they now agree. The gates run in `ship-pr`.

### DEPLOY: docs/3722-settings-toggle-readme

The brand book README describes the settings toggle as `house-style.css` draws it: the icon alone, in
`--fg-1`, with no fill, edge or shadow, and no colour change under the pointer or while open. Until now
it still described the `--primary` edge the toggle lost on November 1, 2026
([#3722](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3722)).

**Score:** 1

#### What makes this deploy extra special

A doc sentence that disagreed with what renders; nothing an app does changes.

**Score:** N/A

#### Pull Request

Brand book README describes the icon-only settings toggle

