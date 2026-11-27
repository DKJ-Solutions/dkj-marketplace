---
name: live-direct-writes
description: >-
  Find writes that reached a Git-connected live theme outside the promotion or hotfix lane, and open one issue. Use for "did anyone write to live directly?".
argument-hint: "[-Ref <ref>] [-Since <UTC date>] [-DryRun]"
---

# live-direct-writes -- read the trace a direct write leaves

Every control on the live theme is session-side (the CLI live guard, a guard hook on the trunk) or git-side
(a deploy-branch ruleset). A `shopify theme push --allow-live` from a shell that never loaded this repo's
harness -- an agent session started in the home directory, a plain terminal -- passes all of them, and the
only trace is the commit Shopify's GitHub integration writes onto the deploy branch afterwards. This check
reads that trace and turns it into an issue. Inbound
[#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289), moved here from a store repo; it
belongs beside [`live-preflight`](../live-preflight/SKILL.md), which guards the push you make on purpose.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/live-direct-writes.ps1" -Ref origin/live -Repo owner/store -DryRun
```

`${CLAUDE_PLUGIN_ROOT}` resolves **only inside a plugin-owned component**. From an ordinary shell, spell the
plugin cache path out. It needs `git` and an authenticated `gh`.

| Parameter | What it is for |
|---|---|
| `-Ref` | the ref whose history is read (default `HEAD`; name the deploy branch, e.g. `origin/live`). |
| `-Since` | the floor: a UTC date (`2026-11-18`) or date and time. Commits before it are never reported. Default: **no floor**, so on a long history the first issue is large. |
| `-Repo` | `owner/name` where issues are read and opened (default `GITHUB_REPOSITORY`, which Actions sets). |
| `-RepoPath` | the clone to read (default: the current directory). |
| `-DryRun` | read everything, open nothing, print the issue it would open. |

## The signal

Measured on the deploy branch of a Git-connected store (25 bot commits over twelve days), Shopify's integration
writes two body shapes:

| body | what it is | reported? |
|---|---|---|
| `Theme last edited by: <person>` | a theme-**editor** save: settings and template JSON, no file list. The sanctioned route; it flows back to the trunk through a PR. | never |
| `Changed by: <person>` plus a `Files:` list | a **file** write: a CLI push or an admin code-editor save. The body does not say which, and both bypass the branch flow. | yes |

The rule is: a `shopify[bot]` commit whose body has a `Changed by:` line is a direct write. A check that reported
every editor save would be ignored within a week, so the editor shape is asserted as **never** reported.

## One issue per run, deduped

Each reported commit leaves `<!-- live-direct-write:<sha> -->` in the issue it went into. A run reads the markers
of every issue carrying the `live-direct-write` label (open **and** closed) that the CI account wrote, and reports
only commits no marker names, so a re-run is quiet and closing an issue does not re-open it. A marker a person
typed does not count. The label is created once, when it is missing. Both the label name and the marker format are
fixed: a store that already ran this check keeps its dedupe history.

The run **reads** git and GitHub, and its only writes are `gh label create` (once) and one `gh issue create`, the
body in a file. It never writes to git, to Shopify or to an existing issue. A failed `gh` read stops the run:
guessing "nothing reported" would re-report every commit since the floor.

## How the schedule runs it

`adopt-shopify-floor` places `.github/workflows/live-direct-writes.yml` -- every six hours and on dispatch -- and
**only where `Get-ShopifyLiveDeployBranch` is answered**: a store whose live theme is pushed with the CLI has no
deploy branch for the bot to write to, so there is nothing to read. See
[`adopt-shopify-floor`](../adopt-shopify-floor/SKILL.md).

A consumer's runner has no plugin cache, so the workflow does what the `dkj-repo-workflow` CI floor does
(`adopt-ci-floor`): a second `actions/checkout` of `DKJ-Solutions/dkj-marketplace` beside the store's tree, and it
runs this script from there. Because the job holds `issues: write` and runs fetched code beside it, the scripts are
pinned to **the commit of the release `adopt-shopify-floor` came from** (`ref: <sha> # vX.Y.Z`) and the action by
SHA, not to `main`; move that `ref:` line when you update the plugin. The deploy branch and the floor are written
into the file when it is placed (the branch from the seam, the floor as the moment of placement, or
`-LiveDirectWritesSince`). It has no push trigger on the deploy branch on purpose -- a push-triggered workflow runs
the file in the *pushed* branch, which is the trunk's copy until the next promotion -- and it is not a required
check: it judges no PR, and the signal is a new labelled issue.

## What is tested

`scripts/tests/shopify-live-direct-writes.tests.ps1` pins the rules in `scripts/lib/live-direct-writes-rules.ps1`
(the two body shapes, log parsing, selection, dedupe, the issue text, the input checks) and drives the script
against a throw-away git repo with a stand-in `gh` (Windows only). The placement of the workflow is tested in
`adopt-shopify-floor.tests.ps1`. No network.
