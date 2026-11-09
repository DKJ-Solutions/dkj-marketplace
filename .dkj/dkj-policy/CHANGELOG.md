# Changelog

## [Unreleased]

**9 / 13 minor entries** <!-- pending-tally -->

### DEPLOY: feat/3906-docs-coverage-page · 20261109-090356Z

The product's home page has a **Docs coverage** card
([#3906](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3906)). It opens an overview of the ten Claude
Code features a comparison of the official docs against v6.11.0 found unused here (#3895 to #3904), one card each
with its live status (Open, In progress, Awaiting decision, In review, Waiting, Done or Declined). Each card opens
the item's own page: its idea, and what the docs turned out to say when a sweep checked it, including the
corrections to what the issue assumed. The status is read from the issues with one GraphQL call. The ideas are
fixed text, so a later change to an issue's content is copied in by hand.

**Score:** 3

#### What makes this deploy extra special

N/A: the product portal is this repo's own local server, and no plugin ships it.

**Score:** N/A

#### Pull Request

Product portal page: the ten Claude Code docs-coverage opportunities

[PR #3922](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3922)

---

### DEPLOY: feat/3920-prefilter-background-run · 20261109-085221Z

The PostToolUse hook `publish-background-run` no longer starts PowerShell on a shell call that is not
backgrounded: a bash `case` in its `hooks.json` command lets only a payload carrying
`"run_in_background"` through ([#3920](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3920),
decided in [#3898](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3898)). That was about
150 ms of the hook's measured cost on every shell call. The filter is coarse on purpose, and the
script's own precise test still decides.

**Score:** 2

#### What makes this deploy extra special

Every shell call in a session running `dkj-policy` gets about 0.15 s faster, roughly 7 s over 50
calls. Nothing to do but take the version.

**Score:** 2

#### Pull Request

Pre-filter publish-background-run in the shell so not every shell call starts PowerShell

Plugins: dkj-policy

[PR #3921](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3921)

---

### DEPLOY: fix/3907-park-through-claim · 20261109-010011Z

`claim-issue.ps1 <n> -Tag -Park <awaiting-label> -Reason "<what>"` parks an issue under a claim
([#3907](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3907)). Only the winner of the claim's read-back
sets the label and posts `Parked by a sweep: waiting on <what>.`, and the claim is released on every path. A plain
`-Tag` claim on an issue that another sweep parked after step 1 now refuses instead of warning and printing
`[OK] claimed`. The assignee route keeps its warning (#2518). `issues-sweep` step 1 parks this way now, and says
that evaluating and closing an issue starts with a claim.

**Score:** 3

#### What makes this deploy extra special

A repo that runs several sweeps at once no longer gets one issue parked two or three times with comments that
disagree. `issues-sweep` users park with one command where they used two, and a late claim on a parked issue
stops rather than taking it.

**Score:** 3

#### Pull Request

issues-sweep parks through claim-issue -Park, so concurrent sweeps cannot park one issue twice

Plugins: dkj-policy

[PR #3915](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3915)

---

### DEPLOY: feat/3902-review-max-turns · 20261109-004215Z

The Claude review workflow now stops a run at 100 turns, so one review cannot drain the subscription
quota its token shares with interactive work. The bound sits just above the measured ceiling: over the
last 40 green runs `num_turns` was 4 to 90, median 12. The token stays the OAuth subscription token, as
the owner chose (#3902).

**Score:** 2

#### What makes this deploy extra special

N/A: the review workflow runs in this repo's CI only, and nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

The Claude review workflow is bounded at 100 turns

[PR #3917](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3917)

---

### DEPLOY: feat/3903-addon-teams-default-off · 20261109-002839Z

The three add-on teams (`dkj-subagents-ecomm`, `dkj-subagents-lifehub`, `dkj-subagents-shopify`) declare
`defaultEnabled: false` ([#3903](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3903)). A repo that has not
named a team in `enabledPlugins` no longer gets it enabled just by installing it. A repo that already names one keeps
its own choice. The core team and the policy plugins are unchanged.

**Score:** 2

#### What makes this deploy extra special

A fresh install of an add-on team stays off until the repo turns it on with `"<team>@dkj-marketplace": true` in
`enabledPlugins`. A repo that already lists the team sees no change.

**Score:** 2

#### Pull Request

Add-on teams ship defaultEnabled: false

Plugins: dkj-subagents-ecomm, dkj-subagents-lifehub, dkj-subagents-shopify

[PR #3919](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3919)

---

### DEPLOY: fix/3911-admin-outside-worktree · 20261109-001641Z

`dkj-policy`'s SessionStart hook no longer starts Admin in a folder that is not a git work tree. Every
`claude plugin eval` run used to leave an Admin server behind in its temporary workspace, which kept
the eval CLI from removing that folder (`EBUSY`). An eval run now leaves nothing running, and every
repo still gets its Admin as before
([#3911](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3911)).

**Score:** 3

#### What makes this deploy extra special

Plugin eval runs no longer leave Admin servers and locked temp folders behind.

**Score:** 2

#### Pull Request

dev-preview starts no Admin outside a git work tree

Plugins: dkj-policy

[PR #3918](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3918)

---

### DEPLOY: feat/3901-guard-safety-rules · 20261109-000628Z

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

Plugins: dkj-policy

[PR #3916](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3916)

---

### DEPLOY: feat/3897-agent-maxturns · 20261108-235613Z

Every specialist subagent now carries a `maxTurns` ceiling that matches its role: 60 turns for one
that only reads and reports, 80 for one that also searches the web or writes files, and 120 for one
that writes and runs `Bash`. A runaway dispatch now stops at that ceiling and hands back what it has.
Model, effort and memory stay as they were
([#3897](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3897)).

**Score:** 2

#### What makes this deploy extra special

A specialist that loops now stops and returns its partial work instead of running on.

**Score:** 2

#### Pull Request

Give every specialist subagent a maxTurns ceiling per role

Plugins: dkj-subagents-alpha, dkj-subagents-ecomm, dkj-subagents-lifehub, dkj-subagents-shopify

[PR #3913](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3913)

---

### DEPLOY: feat/3899-skill-argument-hints · 20261108-234152Z

Fifteen skills now show the argument they expect in the slash-command autocomplete: `/claim-issue
[issue-number]`, `/new-branch [<prefix>/<n>-<short-name>] [title]`, `/ship-pr [issue-number(s) it
resolves]`, `/push-preview [storefront path]` and so on. No skill gained a tool grant: the owner chose
`argument-hint` only, and `shell` governs injection blocks no skill has (#3899).

**Score:** 2

#### What makes this deploy extra special

Typing `/` and a skill name now says what to type after it, for the fifteen skills that take an argument.

**Score:** 2

#### Pull Request

Skills show their expected argument in the slash menu

Plugins: dkj-policy, dkj-subagents-shopify

[PR #3914](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3914)

---

### DEPLOY: feat/3896-skill-trigger-evals · 20261108-233206Z

`dkj-policy` carries an eval suite (`plugins/dkj-policy/evals/`) that checks four key skills (`claim-issue`,
`new-branch`, `sync-trunk`, `day-plan`) still fire on everyday phrasing, plus one case that checks a plain
question fires none. It runs by hand with `claude plugin eval`, never in CI, and its README gives the
command, including `--no-publish`, which keeps the report off claude.ai.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Local plugin evals that prove dkj-policy's key skills still fire on natural phrasing

Plugins: dkj-policy

[PR #3912](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3912)

---

### DEPLOY: feat/3905-retro-skill · 20261108-232207Z

A new skill, [`retro`](../../plugins/dkj-policy/skills/retro/SKILL.md), measures what this repo's recent
sessions spent looking once the work was known: searches, reads and re-reads, the lookups made before the
first edit, reverted edits and tokens, per session, plus the files read most across them. The page then
has the model open the costliest sessions, judge whether the looking was a missing pointer, a stale doc or
just the work, and file each real finding as an issue. It is the other half of the cost the always-on
budget, `measure-skill` and `measure-session-start` measure up front. Like `measure-closeouts`, it reads
transcripts in place and emits only counts, session ids and repo or plugin paths; a home path and the
project directory name never leave it. `-Since` and `-Until` give a before-and-after
comparison around a doc change (#3905).

**Score:** 3

#### What makes this deploy extra special

A consumer can now run `/retro` to find which of its own docs its sessions keep searching past, and get
issues rather than a report. It costs nothing until typed (`disable-model-invocation`).

**Score:** 2

#### Pull Request

Add a retro skill that reads session transcripts for search cost

Plugins: dkj-policy

[PR #3909](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3909)

---

### DEPLOY: feat/3895-plugin-dependencies · 20261108-231102Z

The add-on teams now declare `dkj-subagents-alpha` as a dependency in their `plugin.json`, and the
`dkj-solutions` and `bwj-development` extensions declare `dkj-policy`. Installing one of them now
installs the plugin it needs, where until now only the prose description asked for it
([#3895](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3895)). The edges carry no version, so
the release keeps its one lockstep `vX.Y.Z` tag.

**Score:** 3

#### What makes this deploy extra special

Installing an add-on team or an extension now brings the plugin it needs along with it.

**Score:** 2

#### Pull Request

Declare plugin dependencies in plugin.json instead of prose

Plugins: bwj-development, dkj-solutions, dkj-subagents-ecomm, dkj-subagents-lifehub, dkj-subagents-shopify

[PR #3910](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3910)

---

### DEPLOY: docs/3904-native-worktree-evaluation · 20261108-225933Z

The `worktree-lane` skill page and the orchestrator manual record the November 8 re-check of native
worktrees (#3904): `worktree.baseRef` and `.worktreeinclude` still carry no uncommitted work into a
worktree, and a `WorktreeCreate` hook would only rebuild `worktree-lane.ps1` inside a hook. The manual's
placement bullet no longer says nothing ignores `.claude/worktrees/`, which `.gitignore` has done since #1673.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Record the re-evaluation of native worktrees against worktree-lane

Plugins: dkj-policy, dkj-subagents-alpha

[PR #3908](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3908)

---

