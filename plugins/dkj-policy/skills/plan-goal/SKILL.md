---
name: plan-goal
description: Break a large goal into milestones and tasks, filed as GitHub issues and sub-issues, and say where to start. Use when the owner names a big goal and the steps toward it are unclear ("I want a replacement for HelloFresh", "help me plan X"), when they ask "what now?" or "where do I start?" on a goal, and when a milestone on Admin's Goals page still says to break it down. It asks a few questions, proposes the breakdown, and files it only once the owner agrees.
---

# plan-goal -- from a goal to the next step

**It exists because a board alone does not fix "I cannot think of the steps"** (Dave, November 5, 2026,
[#3816](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3816)): an empty board stalls as much as
none. So this skill does the breaking down, and Admin's **Goals** page (`/dev/goals`) keeps the focus:
one **Now** card per goal, a short **Next** row, and the milestones collapsed with a progress bar each.

**The data is GitHub's own.** A goal is an open issue labelled `goal`, its milestones are its
**sub-issues**, and their tasks are theirs, each list in GitHub's own order. Sessions that claim and close
those issues move the page without any second administration. A non-code task is an issue too.

**In the source repo, run its own copy instead**: `plugins/dkj-policy/hub/pages/plan-goal.ps1`. `${CLAUDE_PLUGIN_ROOT}`
resolves into the plugin cache, which holds the last released copy.

## Break a goal down

1. **Ask before you propose: two to four targeted questions, in one message.** What "done" looks like, what
   already exists, what is out of scope, and any hard date. Don't ask anything the repo or the issue already
   answers.
2. **Propose 4 to 6 milestones**, each a result you can point at ("a shopping list sums the week's
   ingredients"), not an activity ("work on the shopping list"). Under each, the tasks, **each small enough
   for one session**. Show it as a short numbered tree and let the owner change it. The script refuses more than
   8 milestones or 12 tasks under one, because a list that long is a milestone that still needs splitting.
3. **Write the agreed plan to a JSON file in your scratchpad** and check it. The check files nothing:

   ```json
   {
     "goal": { "title": "A replacement for HelloFresh", "body": "Why, and what done looks like." },
     "labels": ["prio-2"],
     "milestones": [
       { "title": "Recipe base: 20 favourites entered, with photos",
         "tasks": [ { "title": "Recipe data model" }, { "title": "Enter 20 favourites" } ] },
       { "number": 1234, "tasks": [ { "title": "Sum the week's ingredients" } ] }
     ]
   }
   ```

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/hub/pages/plan-goal.ps1" -PlanFile "<scratchpad>/plan.json"
   ```

   `"goal": { "number": n }` breaks down an existing goal, and `"number"` on a milestone adds tasks to one that
   is already filed. A task is always new. `labels` go on every milestone and task: in a repo whose own rules
   give every issue a priority label, put it here.
4. **File it once the owner has agreed to the tree**, by adding `-Apply`. That one agreement covers the whole
   filing. The script creates the `goal` label where the repo has none, files the goal, then each milestone as
   a sub-issue of the goal, then each task as a sub-issue of its milestone, in plan order. If it fails
   part-way, it prints what it already filed. Put those numbers in the plan before you rerun it, so nothing is
   filed twice.

## What now?

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/hub/pages/plan-goal.ps1" -Next [-Goal <n>]
```

It prints each open goal with its progress, **Now** and up to three **Next**, and writes nothing. Now is the
first open task of the first open milestone. An open milestone with no task yet is itself the step ("break
down milestone #n"), so plan its tasks with the same skill. Name Now to the owner. If they want to start on it,
it is an ordinary issue, so claim it and build it the way this repo builds any issue.

## What to know

- **A closed milestone is done whole.** Its leftover open tasks no longer count as steps, and its bar
  reads full.
- **The page and the script read the same query** (`Get-GoalsGraphQuery` in `hub/lib/goals-lib.ps1`): the
  first 20 open goals, 25 milestones each and 50 tasks per milestone.
- **Nothing is filed without the owner's agreement to the tree**, because filing issues is visible on the
  tracker to everyone who reads it.
