---
name: retro
description: >-
  Read this repo's last sessions for what they spent LOOKING -- searches, reads, re-reads, lookups before
  the first edit, reverted edits -- then open the costliest ones, judge where the looking went (a stale
  doc, a missing pointer, or just the work), and file each real finding as an issue. Run it by name, after
  a stretch of work or weekly, and before and after a doc change meant to make finding things cheaper.
disable-model-invocation: true
---

# retro -- what a session spent finding things, and which doc it was looking for

This workflow measures what a session pays **up front**: the always-on budget, `measure-skill`,
`measure-session-start`. It did not measure what a session spends **once the work is known**: forty greps
before the first edit, or the same lens read five times. That cost is a missing pointer or a stale doc,
and the constitution already says where such a lesson goes: into the doc that owns it. A retro names the
doc ([#3905](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3905)). It is the Performance
Engineer's instrument.

**This page costs no always-on tokens.** It carries `disable-model-invocation: true`, so you run it by name
(`/retro`). The flag removes the page from context. It does not gate the script.

## Who does what

| step | who | why |
|---|---|---|
| count the lookups, per session and per file | the script | counting is mechanical, and a count is comparable before and after a change |
| decide what a costly session was looking for | you, after opening it | whether forty greps were a missing pointer or simply the work is a judgement |
| file the finding | you, as an issue | a retro's output is issues, not a report |

## 1. Measure

Run the shared script from the **root of this repo**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/maintenance/retro.ps1"
```

**In the source repo, run its own copy instead**: `scripts/maintenance/retro.ps1`. The script carries the
source-repo guard and refuses the stale mirror there.

It reads this checkout's last ten sessions (and its worktree lanes'), and prints three things:

- **the medians**: searches, reads, re-reads, lookups before the first edit, reverted edits in total, and
  output tokens. These are the figures to compare.
- **the costliest sessions**, by lookups before the first edit, each with its session id.
- **the files read most**, by how many sessions read them and how often they were re-read.

| parameter | what it does |
|---|---|
| `-Last <n>` | How many sessions, most recent first. Default 10. |
| `-Since <date>` / `-Until <date>` | Only sessions whose transcript was last written at or after / before the date. Run once with each around a change for a before-and-after comparison. |
| `-Top <n>` | How many sessions and files the report lists. Default 10. |
| `-Project <wildcard>` | Read other project directories under the transcript root instead of this checkout's. |
| `-TranscriptRoot <path>` | Where the transcripts live. Default `~/.claude/projects`. |
| `-Json` | The figures as JSON, for a caller that wants them. |

## 2. Judge: open the costly sessions

A session is `~/.claude/projects/<project>/<session>.jsonl`, and the report names both. Read the stretch
**before the first edit** of the top few: what was it trying to find, and where did it end up finding it?

- **A missing pointer.** The answer was in a doc the session reached late. The fix is a line where the
  session looked first: a lens, a skill page, a docstring.
- **A stale doc.** The session followed a doc that was wrong and had to search past it. The fix is that
  doc.
- **The work.** Unfamiliar code is read before it is changed. Most lookups are this, and they are not a
  finding.

**Less searching alone proves nothing**, which is why reverted edits are counted beside it. A session that
searched little and then undid its own edits found the wrong thing sooner. Hold the two together. A file
read in most sessions, or re-read within them, is the other place to look: it may want a pointer, or a
summary that saves reading it whole.

## 3. File: each finding is an issue

One issue per finding, in **this repo's** tracker, under the repo's usual filing rules: search for a
duplicate first, and add the priority label. Where the doc that needs the fix belongs to an installed
plugin, the issue goes inbound on that plugin's source repo instead. The issue names the doc and the
fix, and gives the measured figures (the session's lookups before its first edit, how many sessions
read the file).

**Quote no transcript text in it**: no prompt, no message, no tool output. A session may have handled
something private, and a tracker may be public. The script's output keeps to that boundary on purpose (counts, session
ids, repo-relative paths, and `(outside the repo)` for anything else), so its lines can be pasted as
they are.

A retro with no finding is a valid result. Say so, with the medians, and file nothing.

## Running it on a schedule

The transcripts are on **this machine**, so a cloud routine (`/schedule`) cannot read them. A weekly retro
is a local one: `/loop` in a session left open, or a task in the machine's own scheduler that starts
`claude -p "/retro"` in this checkout.

## What it is not

- **Not a gate.** It always exits 0 and reaches no verdict about any session.
- **Not a reader of your content into anything.** Transcripts are read in place and never written. Only
  counts, session ids and file paths leave the script.
- **Not the close-out measurement.** That is `measure-closeouts`, which counts what a session's last
  message cost the reader. This one counts what the session cost itself on the way.
