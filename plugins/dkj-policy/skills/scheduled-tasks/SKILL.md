---
name: scheduled-tasks
description: >-
  Place the team's versioned Claude Code Desktop scheduled tasks on this machine -- the prompts live in
  this skill's tasks/ folder, so they are the same on every owner's machine -- and refresh the copies
  already placed after a plugin update. Use when setting up a scheduled task such as the BWJ Friday
  release prep, when asked to "put the scheduled tasks on this machine" or "update the scheduled
  tasks", in whatever language, and after a release that changed a task prompt. It writes the prompt
  file and prints the schedule and folder to set once in the Desktop app; a dry run unless -Apply.
argument-hint: "[task-name]"
---

# scheduled-tasks -- versioned prompts for Desktop scheduled tasks

**A Desktop scheduled task keeps its prompt in one file on one machine**:
`~/.claude/scheduled-tasks/<task-name>/SKILL.md` (under `CLAUDE_CONFIG_DIR` when that is set). Written by
hand there, it is unversioned and drifts between the owners' machines; #4162's first task was tested on
one machine and absent on the other. So the prompts live here, in [`tasks/`](tasks/), and a command
places them (decision on #4162, November 16, 2026).

**Why desktop tasks and not cloud routines.** A desktop task runs on the owner's machine with the local
plugins, PowerShell, `gh` and the live guard, which is the toolchain these tasks call. A cloud routine runs
on a fresh VM without the enabled plugins and without `pwsh`, and its GitHub proxy refuses `gh issue` and
`gh pr` (the cloud documentation, as cited on #4162). So a task that runs this workflow's scripts is a desktop task. Deterministic sweeps stay GitHub
Actions crons.

**What the file can hold, and what it cannot.** Per the
[Desktop scheduled-tasks documentation](https://code.claude.com/docs/en/desktop-scheduled-tasks), the
file holds YAML frontmatter for `name` and `description` and the prompt as its body, and an edit takes
effect on the next run. **The schedule, the working folder and the enabled state are not in the file.**
They live in the Desktop app, set in its Edit form or by asking Claude in a Desktop session. So the command
writes the prompt, prints the schedule and folder, and a person registers a new task once. It never
registers one itself.

## Run it

**In the source repo, run its own copy instead**: `scripts/task/place-scheduled-tasks.ps1`.
`${CLAUDE_PLUGIN_ROOT}` resolves into the plugin cache, which holds the last released copy.

```powershell
# what is placed, what is not, and what a refresh would change (writes nothing)
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/place-scheduled-tasks.ps1"

# refresh every placed copy after a plugin update
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/place-scheduled-tasks.ps1" -Apply

# place one task, under a name of its own per store repo
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/place-scheduled-tasks.ps1" -Task bwj-release-prep -Name bwj-release-prep-<repo> -Apply
```

Then, for a task placed for the first time, register it in Claude Desktop (**Scheduled -> New task**, or
ask Claude in a Desktop session) under the **same name**, with the schedule and folder the run printed,
and a permission mode that cannot push or publish, because otherwise the prompt is the run's only limit.
Registering it may write the app's own prompt over the file, so run the command with `-Apply` once more
afterwards. That run puts the versioned prompt back.

| parameter | what it is for |
|---|---|
| `-Task <name>` | the versioned task to place, by its file name in `tasks/`. Without it the run refreshes every placed copy and lists the tasks placed nowhere |
| `-Name <task-name>` | the Desktop task name, and so the folder, to place `-Task` under. Default: the task's own name. Lowercase kebab-case. A prompt meant for each store repo is placed once per repo, because a Desktop task has one folder |
| `-Apply` | write. Without it nothing is written |

## How a refresh finds its copies

Every placed file ends with a marker line naming the task it came from
(`<!-- placed by dkj-policy scheduled-tasks: <task> -->`). A run without `-Task` reads every folder under
`scheduled-tasks/`, refreshes each file whose **last line** is a marker naming a task this release ships,
and reports an **orphan** where the marker names one it no longer ships (delete that task in Desktop, and
its folder by hand). A task created in the app without this command carries no such last line and is never
touched.

**A changed copy is kept, not lost.** Where a placed file differs from what the run writes (an edit in the
app, or an older release), the old file is saved beside it as `SKILL.md.previous-<yyyyMMdd-HHmmss>`, so a
second refresh never overwrites the first backup. The versioned prompt
wins: a change worth keeping is made in `tasks/`, through a branch.

## The tasks

| task | schedule | folder | what it does |
|---|---|---|---|
| [`bwj-release-prep`](tasks/bwj-release-prep.md) | Friday 14:07 | each BWJ store repo | runs `prepare-release` read-only on the trunk (in a throwaway worktree when the checkout is busy) and reports the exit code, the flagged items and the runbook path |
| [`bwj-release-prep-monday`](tasks/bwj-release-prep-monday.md) | Monday 08:07 | each BWJ store repo | re-runs it with `-SkipDrift` and names what moved since Friday's runbook |

**No task cuts, tags, pushes or posts.** A release is cut only on a person's explicit request, so a
schedule prepares the release and never performs it. A task file states its own limits in its prompt,
because the prompt is all the run reads.

## Adding a task

A file `tasks/<name>.md`, its name in lowercase kebab-case and matching its `name:` key, with frontmatter
`name`, `description` (starting with a letter or digit, with no `: ` or ` #`, because it is written into
YAML unquoted), and
for the print `schedule` (as the app's presets word it), `cron` (5 fields, local time), `folder` and
`requires` (a plugin the folder must enable). Only `name` and `description` reach the placed file. The
prompt states what the run may not do, and reports facts in a few lines.
