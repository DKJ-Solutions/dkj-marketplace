# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: feat/4240-sweep-delegates-build · 20261117-170018Z

`issues-sweep` step 3 now hands the build to a fresh subagent (#4240): the specialist whose craft the
change is, or `general-purpose` on `sonnet`, never a `fork`. Its brief forbids committing, pushing,
opening a PR and writing to the tracker. The sweep's main loop keeps the choosing, parking and
judging. It reads the returned diff before anything ships, and writes the branch document itself. A
change whose brief would be longer than the edit is still built inline.

**Score:** 2

#### What makes this deploy extra special

For whoever runs a sweep: the build, the bulk of a sweep's tokens, now runs on the cheaper subagent
model instead of the session's main model, while the judgement that needs the stronger model stays in
the main loop. Follow-up to #4233, whose page split cut what the skill loads per run.

**Score:** 3

#### Pull Request

issues-sweep: step 3's build goes to a fresh subagent on sonnet, the main loop keeps the judgement

Plugins: dkj-repo-workflow

[PR #4245](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4245)

---

