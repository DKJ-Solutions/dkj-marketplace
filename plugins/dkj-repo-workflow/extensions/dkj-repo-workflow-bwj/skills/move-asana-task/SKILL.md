---
name: move-asana-task
description: >-
  Move an issue's Asana task to a section of this repo's board by stage code ("move the Asana card of #123 to section 2"). Use instead of a raw Asana API call.
---

# move-asana-task -- the narrow route to move a card

Run from the **root of the store repo**, with `ASANA_PAT` in the environment:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/move-asana-task.ps1" -Section 2 -Issue 123,124
```

| parameter | what it is for |
|---|---|
| `-Section <code>` | the stage code: `2` for `2. In Progress`, `1C` for `1C. Waiting` (required) |
| `-Issue <n,n>` | issue numbers; the task is the one the issue body links, found the way the CI runners find it |
| `-TaskGid <gid,gid>` | Asana task GIDs, when there is no issue |
| `-DryRun` | print what would move and write nothing |
| `-RootOverride <path>` | the repo root, when the run does not start inside the checkout |

- **The board** is the project `Get-AsanaProjectGid` names in `scripts/repo-config.ps1`.
- **One board only (#4282).** A task can sit on several boards; one that is not on this repo's board is
  skipped (`[SKIP]`), never added to it.
- **A code that matches no section, or several, stops the run** before anything moves.
- An issue with no single Asana link is skipped and said so.

The section rule lives in `scripts/lib/asana-section-lib.ps1`, and the CI scripts load that same file
(#4366), so a manual move and an automated move pick the same section. This script is maintained in the source repo; do not modify it locally.
