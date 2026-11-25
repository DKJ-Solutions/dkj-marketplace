# Changelog

## [Unreleased]

**4 / 4 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4479-fold-standdown-retry · 20261125-104848Z

When ship-pr pushed its own `fold:` commit right after a merge, the fold-on-merge runner for that merge
stood down and left every other pending entry on the trunk unfolded, while reporting green. The runner
now catches up with the moved trunk and folds what is still there, and fails red if it cannot.

**Score:** 3

#### What makes this deploy extra special

Repos that take the CI floor get the fix the next time `adopt-ci-floor` places or refreshes their fold
runner. Until then, leftover changelog entries can still pile up after a ship and need folding by hand.

**Score:** 2

#### Pull Request

fold-on-merge retries a stood-down fold on the moved trunk instead of counting on a run a fold-only push never starts

Plugins: dkj-repo-workflow

[PR #4490](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4490)

---

### DEPLOY: fix/4478-session-closes-asana-issue · 20261125-103612Z

After a `-NoResolves` merge of an Asana-linked issue, the docs and the resolves-gate refusal now say that
the shipping session closes the issue, not the task's assignee.

**Score:** 2

#### What makes this deploy extra special

A store's session no longer hands the close of an Asana-linked issue to the owner after the merge. It
closes the issue itself with the `gh issue close` line the refusal now prints. A store already on the old
`Get-ResolvesExemptMatchers` answer keeps the old refusal text until it copies the new template from
`adopt-dkj-repo-workflow-bwj`.

**Score:** 2

#### Pull Request

The shipping session, not the task's assignee, closes an Asana-linked issue after a -NoResolves merge

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj

[PR #4489](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4489)

---

### DEPLOY: fix/4480-closed-issue-asana-link · 20261125-102352Z

When a session links an Asana task to a GitHub issue that is already closed, the task now gets its
closed message, with the go-live block and the move into review, exactly as if it had been linked before
the close. It no longer gets a "now in progress" comment, and its card no longer moves backwards. To take
the change, a store re-places its `asana-closed-message` workflow from the template;
`closed-message-sessioncheck` reports the old copy as differing.

**Score:** 2

#### What makes this deploy extra special

A colleague waiting on an Asana card for a request that is already done hears that it is done, instead of
reading that work has started on it.

**Score:** 2

#### Pull Request

report-issue links an already-closed issue as 'now in progress', so asana-closed-message never posts

Plugins: dkj-repo-workflow-bwj

[PR #4488](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4488)

---

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

