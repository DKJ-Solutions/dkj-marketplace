---
name: measure-decision-stops
description: >-
  Measure how often sessions on this machine stopped to ask the owner a menu question (AskUserQuestion),
  and how often the owner then simply picked the option marked Recommended -- so a change to how readily
  a session asks can be judged against a number rather than an impression. Run it by name, before and
  after such a change. Reads the transcripts in place, emits only counts, always exits 0.
disable-model-invocation: true
argument-hint: "[-Project <wildcard>] [-Since <yyyy-MM-dd>] [-Json]"
---

# measure-decision-stops -- how predictable the owner's answers are

A question whose answer is predictable buys little. It costs a wait and an interruption, and it turns
the owner into an approver. The constitution already says approval questions are rare, and that a
sensible default is executed and reported. Whether sessions ask through `AskUserQuestion` more often
than that rule allows could not be checked until this script existed ([#4005](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4005)).

**This page costs no always-on tokens.** It carries `disable-model-invocation: true`, so you run it by
name (`/measure-decision-stops`). The flag removes the page from context. It does not gate the script.

## Run it

From the **root of this repo**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/maintenance/measure-decision-stops.ps1"
```

**In the source repo, run its own copy instead**: `scripts/maintenance/measure-decision-stops.ps1`. The
plugin cache holds the last released mirror, and the script's source-repo guard refuses that case.

| parameter | what it does |
|---|---|
| `-Project <wildcard>` | Only project directories whose name matches. Default: all of them. |
| `-Since <yyyy-MM-dd>` | Only stops answered on or after that date, to read the effect of a change. |
| `-Json` | The figures as JSON instead of the report. |
| `-TranscriptRoot <path>` | Where the transcripts live. Defaults to `~/.claude/projects`. |

## How it classifies an answer

Every question in a call is classified separately, because one call can ask two things. A rejected or
interrupted call counts once, as declined:

| verdict | what it means |
|---|---|
| recommended, as-is | the option labelled `(Recommended)`, with no note: **the predictable answer** |
| recommended, with a note | the same option with a note typed beside it: a yes with a condition, so not predictable |
| another offered option | a different option, or a multi-select set that is not just the recommended one |
| own words | matches no option: a correction or a question back |
| declined | the call was rejected or interrupted |
| no Recommended offered | counted apart, never in the share: there was nothing predictable to pick |

**The headline is the as-is share**: of the answered questions that offered a Recommended option, how
many took it unchanged. The report also prints the share with or without a note, the same share per
project, and the number of sessions it could not read.

## What it does not count

**Close-outs of shape B**, a decision written as a menu in prose. Telling a menu from an explanation
means reading the message, and this script reads no message text. The report prints that line every
time, so the AskUserQuestion figure is never read as covering every decision stop.

## What it found on the day it was written

November 12, 2026, one machine, 225 sessions: 37 calls carrying 41 questions, in 31 sessions. Of the 23
answered questions that offered a Recommended option, **17 took it as-is (74%)**. Four chose another
option, two answered in their own words, and none added a note. Eighteen more questions offered no
Recommended at all. The owner's estimate in #4005 was about 90%. With n=23 the measured 74% is a first
reading, not a verdict.

## What this is NOT

- **Not a gate.** It always exits 0, and it reaches no verdict on any single question.
- **Not a reader of your content.** No question, label, answer or note leaves the script. A project is
  named by the part of its directory after `-GitHub-`, and any other project as `(other)`, because the
  rest of that name encodes a local path. **The repo name itself is printed**, so where a repo is private
  or named after a client, quote only the totals in a public place.
- **Per machine, not per person.** It reads this machine's transcripts. Where two people share one
  machine, or one person works on several, the figure mixes or splits them accordingly.
