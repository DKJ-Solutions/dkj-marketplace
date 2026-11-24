# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: fix/4447-fold-push-token-read-scopes · 20261124-120704Z

The adopt skill and its Part 3 scaffold now say that `FOLD_PUSH_TOKEN` needs four read scopes on the
merge-on-green path, which the docs had left out.

**Score:** 2

#### What makes this deploy extra special

A private repo running merge-on-green whose sweep refuses a green pull request after 1800s with "never
registered" now finds the cause in the adopt skill: add `Checks`, `Commit statuses`, `Actions` and
`Issues` (Read-only) to `FOLD_PUSH_TOKEN`. An existing runner is not rewritten; the fix is on the token.

**Score:** 3

#### Pull Request

Name the read scopes FOLD_PUSH_TOKEN needs on merge-on-green's ship path

Plugins: dkj-repo-workflow

[PR #4452](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4452)

---

