# Changelog

## [Unreleased]

**3 / 3 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4105-goal-now-skips-held · 20261114-185123Z

Inside this repo, a second sweep beside a running one now takes a plan-goal's next task instead of reading `0 free` while the other sweep holds the goal's Now: goal #4081 read `0 free` because #4086 was claimed by another machine two minutes earlier.

**Score:** 3

#### What makes this deploy extra special

Two sweeps can now work one plan-goal at once: when the goal's Now is claimed by another sweep, or has a branch pushed for it, `issues-sweep` takes the next task in order, and its reason names what it passed (`Now is #4088 (#4085 parked, #4086 parked, #4087 held)`). Each sweep still takes one task per goal; a task that depends on the one before it can now be built early.

**Score:** 3

#### Pull Request

issues-sweep: a plan-goal Now claimed by another sweep no longer blocks the goal's next task

Plugins: dkj-policy

[PR #4106](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4106)

---

### DEPLOY: feat/4101-goal-now-skips-parked · 20261114-172814Z

Inside this repo, the sweep walks a plan-goal past a task parked for the owner's look instead of stopping the whole goal at it: goal #4081 read `0 free` for every sweep while its Now waited on a review.

**Score:** 3

#### What makes this deploy extra special

A consumer sweeping a goal tree no longer stalls on a task that waits for the owner: when a goal's Now carries a parking label, `issues-sweep` takes the next task in order instead, and its reason names what it passed (`Now is #4086 (#4085 parked)`). One task per goal is still free at a time; `plan-goal -Next` still shows the goal's own Now.

**Score:** 3

#### Pull Request

issues-sweep: a parked plan-goal Now no longer blocks the goal's next task

Plugins: dkj-policy

[PR #4104](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4104)

---

### DEPLOY: docs/4102-reviews-branchless-result · 20261114-170821Z

`issues-sweep-reviews` now clears a visible result that lives outside the repo
([#4102](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4102)). A parked issue with no branch, whose
thread says the result is in Figma, a design file or an external page, gets the approval comment and loses
its label, and is closed as completed instead of being held out. A branch-less issue whose thread names no
such place is still held out as a defect of whatever parked it. Measured November 14, 2026: a Figma task
that was a plan-goal's Now stayed parked after the owner typed the command.

**Score:** 2

#### What makes this deploy extra special

An owner who runs `/issues-sweep-reviews` after design work in Figma now sees those issues closed, instead
of left waiting under a label that the command was meant to lift.

**Score:** 2

#### Pull Request

issues-sweep-reviews: clear an approved result made outside the repo

Plugins: dkj-policy

[PR #4103](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4103)

---

