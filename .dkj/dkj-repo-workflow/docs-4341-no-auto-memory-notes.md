## docs/4341-no-auto-memory-notes

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

#### Scope: the first step of #4341

#4341 asks for three things: the rule, the harness switch placed by `adopt-dkj-repo-workflow` plus a
session check, and a migration of existing notes. This branch takes the rule and switches auto memory
off in this repo's own settings. The adopt key, the session check and the migration stay on #4341
(`-NoResolves`).

### CREATE

- [x] Constitution, "Lessons learned...": from "not just in memory" to an outright no-memory rule,
  with the reason (a note lives on one machine and one account) and the `autoMemoryEnabled` switch.
- [x] The two restatements brought in line: the technical writer's portable manual and Chris's lens
  chain line.
- [x] `.claude/settings.json`: `"autoMemoryEnabled": false`, so this repo's own sessions stop writing notes.

### TEST

- [x] `ship-pr`'s gate (integrity, script contract, roster, suites, always-on budget) runs on the PR.

### DEPLOY: docs/4341-no-auto-memory-notes

The constitution's rule on lessons learned went from "secured in the docs, not just in memory" to
**never in memory**: no auto-memory notes at all, because a note lives on one machine under one
account and no other person on the team ever reads it. That was measured the same day on a consumer,
where a filing rule the owner decided in a memory note never reached a colleague's sessions. The rule
names the switch, `"autoMemoryEnabled": false` in `.claude/settings.json`, and this repo now sets it.
The technical writer's manual and Chris's lens now say the same.

**Score:** 3

#### What makes this deploy extra special

A consumer reading the next release's constitution is told to keep no memory notes and how to switch
auto memory off. Until `adopt-dkj-repo-workflow` places the key (still open on #4341), a consumer sets
it by hand.

**Score:** 2

#### Pull Request

No auto-memory notes: lessons go upstream or into the repo lens

