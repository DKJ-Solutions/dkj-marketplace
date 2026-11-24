# Changelog

## [Unreleased]

**3 / 3 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4449-refused-head-skips-picker · 20261124-124420Z

The merge-on-green sweep no longer re-picks a pull request `ship-pr` refused: the runner marks the
refused head, the picker skips it, and the next armed pull request gets its turn. The session check
names the pull request that holds the queue when a refusal could not be recorded.

**Score:** 3

#### What makes this deploy extra special

A repo running merge-on-green no longer has one refused pull request silently hold back every newer armed
one. An existing `merge-on-green.yml` is not rewritten: `adopt-ci-floor` now prints a `[refusal]` line
for a runner without the new step, and re-running it with `-Apply` after deleting the file places it.
The step labels and comments with `FOLD_PUSH_TOKEN`, which already holds `Pull requests: write`. To
re-arm a refused pull request by hand, remove its `merge-on-green-refused` label.

**Score:** 3

#### Pull Request

Skip a refused head in the merge-on-green picker so it cannot starve the queue

Plugins: dkj-repo-workflow

[PR #4455](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4455)

---

### DEPLOY: fix/4448-probe-failure-diagnosis · 20261124-122446Z

`ship-pr` no longer waits out its whole CI budget when `gh` cannot read the PR's checks: after three
failed reads in a row it stops, prints gh's own error and exit code, and says to check the token's
permissions. Its timeout refusal claims other checks registered only when one was actually seen (#4448).

**Score:** 2

#### What makes this deploy extra special

A token that cannot read checks used to cost a run its whole wait and then blame the ruleset; the real
cause is now on screen within about 45 seconds.

**Score:** 2

#### Pull Request

Wait-CheckRegistration surfaces a failing gh pr checks probe instead of blaming the ruleset

Plugins: dkj-repo-workflow

[PR #4453](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4453)

---

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

