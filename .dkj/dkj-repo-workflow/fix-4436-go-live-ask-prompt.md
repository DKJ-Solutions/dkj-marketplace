## fix/4436-go-live-ask-prompt

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

Decision on #4436 (davekokbwj, November 23, 2026, recorded on the issue): the live-push marker is a
shell comment the session can compose itself, and since #4402 one marker on the `go-live.ps1` line
authorises the promotion PR, the app deploy and the release cut together. So rule 6 of
`guard-live-theme` keeps requiring the marker, and with it returns PreToolUse `permissionDecision: ask`
instead of allowing, so Claude Code puts the line to the person. Rules 3 and 5 stay marker-only.

### CREATE

- [x] `guard-live-theme.ps1`: rule 6 sets the ask reason; every allow exit goes through a new
  `Exit-Allow`, so a later rule still refuses with exit 2 and only a command that passes everything
  becomes the prompt. Header rule 6 updated.
- [x] `guard-live-theme.tests.ps1` rule 6: with the marker the guard asks and names what it takes
  live; reading the script and a marked non-go-live command ask nothing.
- [x] `go-live` skill page: the marker is required, and with it the guard still asks.

### TEST

- [x] Smoke run of the guard against an empty project dir: no marker exit 2; marker exit 0 with
  `{"hookSpecificOutput":{"permissionDecision":"ask",...}}` on stdout; `Get-Content` of the script and
  `git status` exit 0 with empty stdout. The full suite runs in `ship-pr`'s gate.

### DEPLOY: fix/4436-go-live-ask-prompt

A `go-live.ps1` line carrying the live-push marker is no longer let through by `guard-live-theme` on the
marker alone: the guard returns a confirmation request, so Claude Code asks the person before the
promotion, the app deploy and the release cut run. The marker is a comment a session can write itself,
and on this one line it authorised three outward acts at once. Without the marker the line is still
refused; an ordinary live push or promotion keeps its marker-only rule
([`go-live`](../../plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-bwj/skills/go-live/SKILL.md),
#4436).

**Score:** 2

#### What makes this deploy extra special

Release day now ends in one question the store owner answers themselves, which the session cannot
answer for them.

**Score:** 2

#### Pull Request

guard-live-theme asks the person before a go-live, instead of allowing on the marker alone

