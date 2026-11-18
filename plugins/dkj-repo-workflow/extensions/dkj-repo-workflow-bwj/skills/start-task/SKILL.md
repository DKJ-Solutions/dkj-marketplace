---
name: start-task
description: >-
  Start a branch in a BWJ Shopify store repo -- the store layer over the shared new-branch: it refuses a
  missing Shopify CLI, a sync/ or dependabot/ name, an unknown prefix, a double quote in the title, and a
  base that is not the trunk (unless -Base or -Stacked says so), all before anything is created, then
  hands the branch and its branch document to new-branch. Use it whenever a store task starts, instead of
  the plain new-branch skill. It creates no preview theme; push-preview does that.
---

# start-task -- the store's way to begin a branch

Run the shared script from the **root of the store repo**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/start-task.ps1" -Name feat/size-chart-popup -Title "Size chart popup"
```

It is the store layer on top of [`new-branch`](https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-repo-workflow/skills/new-branch/SKILL.md): the branch and its
document are new-branch's work, and what is checked here is only what is **stricter** than new-branch.
Everything is checked before anything is created.

| refusal | why |
|---|---|
| no Shopify CLI on PATH | the store's gates need it, and the theme lint skips with exit 0 without it, which reports green having read nothing |
| `sync/` or `dependabot/` | those branches arise by themselves; you never type them |
| an unknown prefix | new-branch only warns; the store's prefix table is its own `scripts/lib/branch-info.ps1` |
| a double quote in `-Title` or `-Intent` | it breaks the argument handover to new-branch |
| HEAD is not on the trunk | a branch cut from another in-flight branch makes its PR's Preview section a false claim |

## The parameters

| parameter | what it is for |
|---|---|
| `-Name <prefix/name>` | the branch name (required) |
| `-Title <text>` / `-Intent <text>` | the DEPLOY title and the PLAN direction, passed to new-branch |
| `-Base <branch>` | cut from that local branch instead of HEAD (checks it out first; needs a clean tree; does not fetch) |
| `-Stacked` | deliberately cut from the current branch; prints the `Stacked on:` line for the PR body |
| `-RootOverride <path>` | the repo root, when the run does not start inside the checkout |

The exit code is `0` on success and `1` on a refusal; a refusal creates nothing.

## What it reads from the store

- **The trunk** from `Get-TrunkBranchName` in `scripts/repo-config.ps1`, `main` where it is absent.
- **The prefix table** from the checkout's `scripts/lib/branch-info.ps1`, which new-branch reads too.
- **The store domain** in the CLI repair, from `Get-ShopifyStoreDomain` where the repo defines it.

## What it deliberately does not do

- **No git-identity check.** new-branch refuses a checkout that cannot commit, before it creates anything.
- **No preview theme.** push-preview makes one when there is something to show.
- **No skip switch** on the CLI check: it is worth having only while it cannot be forgotten.

## Important

This script is maintained in the source repo; do not modify it locally in a consumer. A change lands
first in the source and then travels via a release to the plugin.
