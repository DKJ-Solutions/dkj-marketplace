# Changelog

## [Unreleased]

**4 / 6 minor entries** <!-- pending-tally -->

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

