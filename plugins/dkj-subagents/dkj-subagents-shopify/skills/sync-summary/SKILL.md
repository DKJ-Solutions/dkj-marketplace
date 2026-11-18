---
name: sync-summary
description: Make a live-drift sync readable -- what colleagues changed directly in the Shopify admin, per theme area, plus what to look at: removed sections a template still points at, new sections nobody requested, theme editor settings changed, removed templates. Use it after a sync-main run, when reviewing a sync or back-flow PR, or when asking "what happened in the admin?". Takes the latest sync commit, a named commit, a range such as origin/main...origin/live, or -SinceTrunk where the store names its live deploy branch; -List shows recent sync commits. Read-only: git only, no network.
argument-hint: "[-Commit <hash> | -Range <base>...<head> | -SinceTrunk | -List]"
---

# sync-summary -- read a live-drift sync

Third parties edit the live theme in the theme editor, and their edits reach git as sync commits (see
[`sync-main`](../sync-main/SKILL.md)) or, where the live theme is connected to a branch of its own, as bot
commits on that branch that flow back into the trunk. Such a commit is often thousands of lines and nobody
reads it, so it feels as if there is no view of what happens in the admin. It is all in git. Inbound
[#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289).

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/sync-summary.ps1"
```

`${CLAUDE_PLUGIN_ROOT}` resolves **only inside a plugin-owned component**. From an ordinary shell, spell the
plugin cache path out.

| Parameter | What it is for |
|---|---|
| *(none)* | the most recent sync commit on the current branch. |
| `-Commit` | a specific commit. |
| `-Range` | `<base>...<head>`, three dots, e.g. `origin/main...origin/live`: what the head has and the base does not since they split. The checks read the state at the head. |
| `-SinceTrunk` | shorthand for `-Range origin/<trunk>...origin/<deploy branch>` from the store's seams. Refuses, naming `Get-ShopifyLiveDeployBranch`, when that is unanswered. It does not fetch: refresh the refs first. |
| `-List` / `-Count` | the recent sync commits instead of a summary. |
| `-MaxFiles` | file names listed per area (default 12). |

## What it reports

Per theme area (sections, templates, snippets, layout, blocks, assets, locales, config) what was added,
changed, removed and renamed, then **what to look at**:

- **A removed section a template still points at.** The failure: a section removed live while a template
  keeps naming it. The page returns HTTP 200 and renders nothing, and nothing errors. A **renamed**
  section counts too: its old name is gone just as a deleted one's is (#4301). A removal nothing points
  at is reported as a clean removal.
- **New sections** -- work nobody requested through this repo.
- **`config/settings_data.json` changed** -- switches somebody turned in the editor, not code.
- **Removed templates** -- a page layout is gone.

Exit code: 0 whenever it could read (including "nothing found"), 1 on a refusal.

## The seams

All optional, read from `scripts/repo-config.ps1` the way this plugin's other scripts read it, so a fault in
that file degrades to the defaults:

| seam | default | used for |
|---|---|---|
| `Get-ShopifySyncReferencePattern` | `^[Ss]ync` (sync-main's default) | which commit subjects count as sync commits. |
| `Get-TrunkBranchName` | `main` | `-SinceTrunk` only. |
| `Get-ShopifyLiveDeployBranch` | *(none)* | `-SinceTrunk` only; unanswered, `-SinceTrunk` refuses. |

## What is tested

`scripts/tests/shopify-sync-summary.tests.ps1` pins the pure rules in `scripts/lib/sync-summary-rules.ps1`
(area classification, subject matching, git output parsing, the four checks, the range builder) and drives
the script against a throw-away local repo built with `git init`. No network.
