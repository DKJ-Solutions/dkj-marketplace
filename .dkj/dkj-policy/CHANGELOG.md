# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

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

