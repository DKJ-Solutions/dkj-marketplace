# Changelog

## [Unreleased]

**1 / 2 minor entries** <!-- pending-tally -->

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

