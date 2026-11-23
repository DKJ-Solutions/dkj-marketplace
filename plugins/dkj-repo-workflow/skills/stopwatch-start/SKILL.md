---
name: stopwatch-start
description: Start a Stopwatch run for the prompt the owner is typing now, by the slash command `/dkj-repo-workflow:stopwatch-start <label>`. The owner types it; Claude never starts a run itself. The UserPromptSubmit hook has already started the run by the time this page is read, so there is nothing to run.
argument-hint: "[label]"
disable-model-invocation: true
---

# stopwatch-start -- start a Stopwatch run from a slash command

**It exists because a run started only from a prompt whose first line is `stopwatch: <label>`**
([#4386](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4386)): an owner who wrote "use the stopwatch for
this prompt" in their own words got no run. The command is a second, plainer way, and the phrase in the owner's own
words is a third; the three are decided together by `Get-StopwatchPromptStart` in this plugin's
`apps/admin/lib/stopwatch-lib.ps1`.

**The hook has already started the run.** The `UserPromptSubmit` hook (`hooks/stopwatch-hook.ps1`) reads the
prompt before this page loads: a prompt that begins with `/dkj-repo-workflow:stopwatch-start <label>` (or
`/stopwatch-start <label>`) starts an Auto run labelled `<label>`, at the checkout's HEAD, exactly as a
`stopwatch:` prompt does (a run still going is discarded, a prepared card of that label is removed). With no label on
that line, the label is the prompt's next non-empty line, and `Assignment` when there is none.

**So there is nothing to run and nothing to start.** Do not start a second run and do not write the store. Carry on
with the assignment the rest of the prompt gives. The Stop hook ends the run once the checkout is back on the trunk,
clean, with HEAD moved, as it ends every Auto run.

## What to know

- **Claude never starts one itself.** The page has `disable-model-invocation`: the owner types the command, so a
  run is only ever the owner's own request.
- **The slash command is read from the start of the prompt only.** A prompt that merely mentions the command further
  down starts nothing.
- **To prepare a card first and start it later**, use `stopwatch-prepare`; this command then lands the run on that
  card when its label matches.
