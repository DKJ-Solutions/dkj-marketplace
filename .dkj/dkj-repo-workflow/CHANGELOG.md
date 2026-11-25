# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: fix/4476-entry-gate-live-sessioncheck · 20261125-100129Z

A new session check, `entry-gate-live-sessioncheck`, warns when the branch-entry CI caller leaves out the
live deploy branch that `scripts/repo-config.ps1` declares, and prints the `branches:` line to use instead.

**Score:** 2

#### What makes this deploy extra special

A Shopify store adopted before the live branch joined the branch-entry caller now hears about it at every
session start, with the exact line to change. Before, hotfix PRs to the live branch landed malformed
changelog entries unjudged and turned the fold red, and nothing said why until someone re-ran adoption.

**Score:** 3

#### Pull Request

Session check reports a branch-entry caller that leaves out the live deploy branch

Plugins: dkj-repo-workflow

[PR #4486](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4486)

---

