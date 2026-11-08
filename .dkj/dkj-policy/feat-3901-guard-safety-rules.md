## feat/3901-guard-safety-rules

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

#3901, as decided on its thread (November 8, 2026): a plugin cannot ship `deny` or `ask` permission rules, so
the PreToolUse guard `guard-working-copy` refuses the constitution's safety-rule commands itself, on every
thread, with no consumer setting to change. In scope: every force push (`-f`, `--force`,
`--force-with-lease`, a `+` refspec) and `git reset --hard`. Out of scope, and written down as such:
`git rebase` "on a shared branch", because whether a branch is shared is not in the command string.

### CREATE

- [x] `working-copy-guard-lib.ps1` (both copies): `Get-SafetyRuleViolation`, on the same segment and subcommand parsing as the subagent rule, with no project scope
- [x] `guard-working-copy.ps1`: a second string pre-gate, the safety rule asked before the `agent_id` gate, and a refusal that says the owner runs the command themselves
- [x] Tests: a `Get-SafetyRuleViolation` group in `working-copy-guard-lib.tests.ps1`; group 6 in `guard-working-copy.tests.ps1`; group 1's main-thread `reset --hard` case is now `reset --soft`
- [x] `plugins/dkj-policy/scripts/README.md`: the lib row names the new function
- [x] Code review (Victor) and security review (Sebastian)
- [x] Review fixes: the hook's pre-gate drops `\b` (a newline before `git` is `\n` in the JSON, so a multi-line command walked past it); `HEAD:+main` and `--mirror` count as force pushes; `& git` and `"git"` are git-led (both rules); unique abbreviations `--force-w...` and `--ha...` are read; the refusal offers a stash or branch to the main thread only; the residual limits are listed in full

### TEST

- [x] After the review fixes: `working-copy-guard-lib.tests.ps1` 125/0, `guard-working-copy.tests.ps1` 57/0, `hook-fail-closed` 43/0, `hook-stdin-guard` 56/0, `command-guard-lib` 38/0, run locally.
- [x] Measured over this repo's transcripts: 1 refusal in 4593 calls before the reviews, 8 in 4638 after, every one a heredoc of test data or a reviewer's own probe of this rule. No real force push or hard reset is in the corpus. Recorded in the lib.
- [x] The repo gates run inside `ship-pr`.

### DEPLOY: feat/3901-guard-safety-rules

`guard-working-copy` now refuses a force push (`-f`, `--force`, `--force-with-lease`, `--mirror`, a `+`
refspec) and `git reset --hard` on every thread, the main one included, abbreviations git accepts as well. It used to guard only dispatched subagents. The
constitution allows both commands only with the owner's explicit permission, and a plugin cannot ship
permission rules, so the guard enforces them itself (#3901). The refusal tells the session to give the owner
the exact command to run themselves. A commit message or grep that names the rule is not refused.

**Score:** 3

#### What makes this deploy extra special

Every repo with `dkj-policy` installed gets the refusal at its next plugin update, with no setting to change.
A session that tries to force-push or hard-reset is stopped and hands the command to its owner instead.

**Score:** 3

#### Pull Request

guard-working-copy refuses a force push and a hard reset on every thread

