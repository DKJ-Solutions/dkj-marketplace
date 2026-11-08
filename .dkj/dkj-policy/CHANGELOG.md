# Changelog

## [Unreleased]

**2 / 3 minor entries** <!-- pending-tally -->

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

