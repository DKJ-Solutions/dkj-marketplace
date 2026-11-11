# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: fix/3995-closed-message-superseded-event · 20261111-161044Z

The `asana-closed-message` template no longer posts a stale message when two events on one issue
arrive out of order. Inbound
[#3995](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3995): on xoxowildhearts#512 the
reopen's run was created one second after the close's, so the task was told "back in development" and
its card moved back while the issue was closed. The script now reads the issue's current state before
it posts, and an event that state has already moved past (a reopen of a closed issue, a close of an
open one) posts nothing and moves no card, because the run of the later event carries the current
state. A failed read posts as before, logged. A consumer takes it by copying the template again
(`adopt-bwj-development`).

**Score:** 2

#### What makes this deploy extra special

A requester on Asana was told an issue was back in development while it had closed; that message no
longer goes out.

**Score:** 2

#### Pull Request

asana-closed-message: skip an event the issue's current state has superseded

Plugins: bwj-development

[PR #3999](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3999)

---

