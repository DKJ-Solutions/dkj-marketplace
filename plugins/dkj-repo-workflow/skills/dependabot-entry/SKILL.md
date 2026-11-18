---
name: dependabot-entry
description: >-
  Write the branch development document onto a Dependabot PR's own branch, so the PR passes the
  branch-entry CI gate -- the mechanical half of the entry, with the three questions a dependency bump
  must answer (where the package enters, why the bump is worth taking, what the gates and the package
  manager's audit said) left in its DEPLOY section for a person to answer. Use when a Dependabot PR
  sits red on the "Branch entry" check, or when asked to "fix the entry on the Dependabot PR", in
  whatever language. It relaxes no gate: the gate is deliberately not an exemption for `dependabot/*`.
argument-hint: "[pull-request-number]"
---

# dependabot-entry -- the entry a Dependabot PR does not bring

Dependabot opens its pull requests itself and knows nothing of this workflow's entry convention, so the
branch-entry gate refuses them. **The gate stays as it is, on purpose** (inbound #4287): the entry is where
the distinction a lockfile diff does not show lands -- dev or production branch of the lockfile, where the
package enters, whether there is a real attack route. This script does only the mechanical part.

## Run it

From the **root of the consuming repo**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/dependabot-entry.ps1" -PullRequest 215
```

**In the source repo, run its own copy instead -- `scripts/task/dependabot-entry.ps1`.**
`${CLAUDE_PLUGIN_ROOT}` resolves into the plugin cache, which holds the last *released* mirror.

## The parameters

- **`-PullRequest <n>`** (required) -- the Dependabot PR.
- **`-Title`** -- the entry's branch title. Default: the PR title. A double quote in it is refused.
- **`-Intent`** -- the DEPLOY body. Default: the three bump questions as a scaffold to answer by hand.
- **`-SkipMergeMain`** -- do not merge the current `origin/<trunk>` into the branch first. Only sensible
  when the trunk has not moved since the PR opened.
- **`-NoPush`** -- commit the document but do not push.

## What it does, and where it stops

In this order, stopping at the first objection: it requires a clean working tree; reads the PR with `gh`
and **refuses** one that is not open, comes from a fork, or is not from Dependabot (`app/dependabot` /
`dependabot[bot]`); checks the branch out (**a local branch ahead of origin is never touched**); merges the
current trunk in (a conflict aborts the merge and stops); has the shared `new-branch` write the document
under the PR's **own branch name** (no second branch is created for a name it does not own); inserts the
three questions into the DEPLOY section above its first `**Score:**` line, **only while that body is still
unwritten**; commits **only** the branch document and pushes.

It runs no gates, does not merge, does not fold, and does not fill the reach tiers -- which tier a bump
reaches is the judgement it knows nothing about. It prints those as the follow-up: answer the questions,
fill the tiers, update the steps, run the gates, ship.
