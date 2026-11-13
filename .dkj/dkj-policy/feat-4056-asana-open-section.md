## feat/4056-asana-open-section

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

Inbound #4056: the owner's rule is that an open issue's Asana task sits in `2. In Progress`. The
consumer's half (`Filed = '2'` in smartwatchbanden's stage map) is local; the plugin's half is a daily
sweep that holds the rule when a person drags a card back. Checked before building: smartwatchbanden's
map ranks `Requests` and `NeedsInfo` on code `1` before `Filed`, so the sweep acts there once the local
answer lands; xoxowildhearts answers `Filed = '1'`, where the sweep finds no earlier section and moves
nothing. The reopen case stays with `asana-closed-message` (#3562).

### CREATE

- [x] `templates/asana-open-section.ps1` + `.yml`: the sweep, its helpers copied verbatim from the two sibling templates
- [x] `closed-message-sessioncheck.ps1`: the pair is asked of smartwatchbanden alone
- [x] `WORKFLOW-portable.md` step 6, the adopt skill and the README describe it

### TEST

- [x] `bwj-development.tests.ps1`: copy-equality pins, the earlier-code rule, every skip, the script's and workflow's shape
- [x] `closed-message-sessioncheck.tests.ps1`: missing pair reported in smartwatchbanden, never asked of xoxowildhearts

### DEPLOY: feat/4056-asana-open-section

The new `asana-open-section` template ships with its suite cases and a session-check group, and step 6 of
[`WORKFLOW-portable.md`](../../plugins/dkj-policy/extensions/bwj-development/WORKFLOW-portable.md) now names a third automated move.

**Score:** 3

#### What makes this deploy extra special

A store whose board shows every open issue as in progress can now keep it that way: copy the new
`asana-open-section` workflow (smartwatchbanden's session check asks for it) and a card dragged back into
`1. Todo` while its issue is open returns to `2. In Progress` the next morning. On a board whose `Filed`
is the inbox column it moves nothing.

**Score:** 3

#### Pull Request

bwj-development: a daily sweep keeps the Asana task of an open issue in the Filed section

