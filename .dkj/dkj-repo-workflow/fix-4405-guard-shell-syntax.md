## fix/4405-guard-shell-syntax

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

Inbound #4405: an authorised live push ending in `2>&1 | tail -15` was blocked by a crash in
`guard-live-theme`, not by a verdict. Verified cause: `Get-LivePushTrunkProblems` reads every bare word
after the push as a pushed file, so `2>&1` reached `Test-Path`, which throws on `>` (illegal path character).

### CREATE

- [x] `guard-live-theme.ps1`: unquoted control operators end the push's arguments, unquoted redirections
  (with a standalone target) are skipped, and an `--only` value holding a character no path can hold is
  refused by name before `Test-Path`.
- [x] `guard-live-theme.tests.ps1`: group 10 gains four `shell:` asserts (trailing `2>&1 | tail`,
  `> out.txt`, a quoted `<` refused by name).

### TEST

- [x] `guard-live-theme.tests.ps1` standalone: 3 of the new asserts failed on the old hook; 415 of 415 pass on the fix.

### DEPLOY: fix/4405-guard-shell-syntax

`guard-live-theme` now judges an authorised live push whose command line ends in shell syntax, such as
`2>&1 | tail -15` or `> out.txt`, instead of crashing on it. Redirections and pipes are no longer read as
pushed files, and an `--only` value holding a character no file name can hold is refused by name instead
of surfacing as "PowerShell could not run this guard" (#4405).

**Score:** 2

#### What makes this deploy extra special

A Shopify store's maintainer can pipe a live push's output (`2>&1 | tail`) without the guard blocking an
authorised release by crashing, and a bad `--only` value now gets a refusal that names the file.

**Score:** 2

#### Pull Request

guard-live-theme: judge a live push that ends in shell syntax instead of crashing

