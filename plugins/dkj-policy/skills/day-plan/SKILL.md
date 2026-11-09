---
name: day-plan
description: Plan the owner's working day in the morning and close it at the end -- one day goal, items with an hour estimate and a mode (plan first or go), held strictly between 6 and 8 hours, and a close-out that matches the plan against the PRs merged and issues closed on GitHub. Use when the owner starts the day ("plan my day", "what are we doing today?", "good morning"), wants to add something during the day ("can I also do X today?"), ends the day or the week ("close the day", "what did I do this week?", "weekend"), in whatever language it is asked. Paula, the Project Planner, carries it.
---

# day-plan -- a day with a goal, and an end

**It exists because nothing added the day up** (Dave, November 7, 2026,
[#3859](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3859)). Every session ended cleanly, yet the
work never felt finished, because there was no moment that said what the day was for or what it got done.
This skill gives the day both: a plan in the morning, and a close-out that says *you can close the day*.

**Admin's Today page (`/dev/today`) shows it all day**: the goal with its progress, the plan with each item
marked done once its PR or issue is, what got done outside the plan, and the week.

**Paula carries it** -- the Project Planner. Load her manual's *The day rhythm* section before the first
step: she proposes, the owner decides, and she holds the band in both directions.

**In the source repo, run its own copy instead**: `plugins/dkj-policy/apps/admin/pages/day-plan.ps1`.
`${CLAUDE_PLUGIN_ROOT}` resolves into the plugin cache, which holds the last released copy.

## Morning: plan the day

1. **Read the morning's input.** It writes nothing:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/apps/admin/pages/day-plan.ps1" -Context
   ```

   It prints the carry-over from the last planned day (within the past week, so Friday's on a Monday), the
   measured pace (the median merged PRs per working day over the last four weeks), the open issues assigned to
   the owner across all repos (up to 50 per account), and this repo's goals with their
   **Now** and **Next**.
2. **Propose the day in one message**: one day goal (a result, not an activity), and the items that serve it,
   each with an **hour estimate** and a **mode**:
   - **plan** -- the approach is still open, so that session starts in plan mode;
   - **go** -- the task fits in one sentence, so it runs in auto mode.

   Everything that does not fit goes under **not today**, by name, so it is a decision and not a loose end.
3. **Hold the band, both ways.** Under 6 hours is not a full day, and over 8 is too much. Say so plainly and
   say what to add or what to move. A short or long day is allowed, but only with its reason.
4. **Write the agreed plan** to a JSON file in your scratchpad, check it, and write it once the owner agrees:

   ```json
   {
     "goal": "The day-plan skill is merged",
     "items": [
       { "title": "Day-plan script and tests", "hours": 3, "mode": "go", "ref": "#3859" },
       { "title": "Today page design", "hours": 2.5, "mode": "plan", "ref": "DKJ-Solutions/dkj-marketplace#3860" },
       { "title": "Inbox and review", "hours": 1, "mode": "go" }
     ],
     "notToday": ["Spotify credentials (#123)"]
   }
   ```

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/apps/admin/pages/day-plan.ps1" -PlanFile "<scratchpad>/day.json"
   powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/apps/admin/pages/day-plan.ps1" -PlanFile "<scratchpad>/day.json" -Apply
   ```

   A `ref` is `#n` (this repo), `owner/repo#n` or an issue or PR URL. An item with a ref is marked done at the
   close-out by itself. Outside the band, `-Apply` refuses unless `-Override "<reason>"` is given. The reason
   is kept and comes back at the close-out.

## During the day: one more thing?

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/apps/admin/pages/day-plan.ps1" -Add -Title "<what>" -Hours <h> -Mode plan|go [-Ref <ref>]
```

It refuses when the day would go over 8 hours. Then ask what moves to tomorrow instead. `-Override` only
with a reason the owner gives.

## Evening: close the day, and on Friday the week

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/apps/admin/pages/day-plan.ps1" -Close [-Done 3,4]
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/apps/admin/pages/day-plan.ps1" -Week
```

`-Close` reads what got done from GitHub (PRs merged and issues closed today), matches it against the plan,
and prints the receipt: done, carried to tomorrow, extra, and *You can close the day.* Ask the owner about the
items with no ref, and pass the ones that are done as `-Done` (1-based). What is carried over is the next
morning's carry-over. `-Week` adds up the week. Relay the receipt as it is printed and don't add a list of
loose ends to it, because what is not done has already been named as tomorrow's.

## What to know

- **Whose work counts**: `-Author`, else `DKJ_DAYPLAN_AUTHORS` (comma-separated), else the login `gh` acts
  as plus git's `user.name`. Both, because a checkout can act as one account and commit as another. Measured
  November 7, 2026: the PRs were authored by one account and the issues assigned to the other.
- **The day file lives on the machine**: `%LOCALAPPDATA%\dkj-admin\dayplan\<yyyy-MM-dd>.json`
  (`DKJ_ADMIN_STATE_DIR` moves it for tests). It is not in any repo's tree, because the day belongs to the
  person and not to a repo.
- **One day across several machines** ([#3924](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3924)):
  set `DKJ_DAYPLAN_REPO` to a **private** repo (`owner/name`) in the `env` block of your user-level
  `~/.claude/settings.json`, on every machine. Each machine then publishes its recent day files to its own ref,
  `refs/dayplan/<machine id>`, in that repo, the way the Stopwatch shares its runs. No commit lands on a branch.
  Every reader merges the copies. The newest plan is the base, items added on any machine after it join once,
  and a closed day wins whole. The band is held against the merged day. `-Context`, `-Apply`, `-Add`, `-Close`
  and `-Week` sync themselves. The Today page syncs in the background every five minutes, and its footer says
  whether the day is shared. A repo GitHub does not report as private is refused, because plan titles can be
  personal. Offline, or without push rights, the day stays on this machine and every command says
  `not shared`. `DKJ_DAYPLAN_REPO=off` in the environment turns it off on one machine.
- **The pace is a context, not a quota.** It counts merged PRs, which vary in size. The hour band is the
  bound.
- **A closed day is not planned again**: plan another `-Date`.
