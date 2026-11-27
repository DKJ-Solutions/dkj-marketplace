---
name: measure-references
description: >-
  Measure whether a specialist's self-maintained references pay off: per specialist and per week, the
  sources taken from the references, the sources added and the web searches, reported beside the web calls
  measured in each run's own transcript. Run it by name, after specialists carrying the knowledge-lookup
  block have worked for a while, and again later to see the store grow and the web searches fall, or not.
disable-model-invocation: true
argument-hint: "[-Project <wildcard>] [-Since <yyyy-MM-dd>] [-All] [-TranscriptRoot <path>] [-Json]"
---

# measure-references -- what the references save

[#4544](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4544) made each specialist keep its own
**references**, the source store its repo lens names, and read them before the web. Without a number
nobody can tell whether that lookup order saves searches and context or only adds a read. This skill is that
number ([#4547](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4547)). It is the instrument of
Nolan #25, the Performance Engineer.

**This page costs no always-on tokens.** It carries `disable-model-invocation: true`, so you run it by name
(`/measure-references`). The flag removes the page from context. It does not gate the script.

## Where the numbers come from

Two sources, kept apart on purpose:

| column | source | why |
|---|---|---|
| **from store, added, web (rep.)** | the line the knowledge-lookup block asks every specialist to end its deliverable with: `References: <n> from the store, <n> added, <n> web searches.` | the store differs per repo (a Notion database, a folder), so no transcript read can count it in general; the specialist's own count is the only store-agnostic source |
| **web (meas.)** | the `WebSearch` and `WebFetch` calls in the transcripts of the same runs, the ones that reported | the half nobody can talk up or down; it also counts `WebFetch`, so it runs somewhat higher, and a large gap means the reported line may not be reliable |
| **web (all runs)** | the same calls over every run, including those that ended without a line | the baseline before the line arrives, and what the runs without a line spent |

**reuse** is *from store / (from store + web searches)* over the runs that reported. A rising reuse with
falling web searches, week over week, is the store paying off. A run with no line counts as a run without a
line, never as zero reuse.

## Run it

From the root of this repo:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/maintenance/measure-references.ps1"
```

**In the source repo, run its own copy instead**: `scripts/maintenance/measure-references.ps1`. The script
carries the source-repo guard and refuses the stale mirror there.

| parameter | what it does |
|---|---|
| `-Project <wildcard>` | Only the project folders under the transcript root matching this. Default `*`, every repo on this machine. |
| `-Since <yyyy-MM-dd>` | Only runs that started on or after that date. Run it with a date before and after a change to compare. |
| `-All` | Also list specialists that never reported a line, with their measured web calls: the baseline before the line arrives. |
| `-TranscriptRoot <path>` | Where the transcripts live. Default `~/.claude/projects`. |
| `-Json` | Per specialist with a per-week series, for a caller such as an Admin chart. |

It reads every subagent transcript (`<project>/<session>/subagents/agent-*.jsonl` and its `.meta.json`),
skips built-in agents, and lets only counts, specialist (agent) names and ISO weeks out: never a line of
transcript content and never a path. The agent names are printed, so a private custom agent's name shows
in the output and in `-Json`. It is a measurement, not a gate, and exits 0; only the source-repo guard refuses, on the stale mirror in the source repo.
