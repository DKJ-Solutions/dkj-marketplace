---
name: go-live
description: >-
  Release day in one command for a Git-connected store: preflight, promotion PR, merge, live verify, cut, notify. Use when the owner says a release may go live ("take it live", "go live with v3.2.0").
---

# go-live -- from the owner's word to a verified, cut release

Measured on a release day ([#4402](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4402)): from
"approve" to "live and verified", a session walked six steps and handed most of them back. The promotion
PR it printed took three attempts before the guards accepted it, the merge needed the admin bypass, the
live theme was verified ad hoc, the app deploy was printed and never run, and the live-push record had to
be hand-edited when that deploy was skipped. This command runs the whole day.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/go-live.ps1" -Version 3.2.0 -AppDeploy  # <your repo's live-push marker>
```

## The word, and what it covers (the owner's decision on #4402)

- **One marker on the go-live line authorises the whole chain for one release.** It is the live-push
  marker your repo states in its own safety rules, as a shell comment on that exact command.
  `guard-live-theme` (dkj-subagents-shopify, its rule 6) refuses a line that runs `go-live.ps1` without it,
  because every act below happens inside a script the guard cannot read. go-live never prints the marker
  and never reads it: the line a person authorises is theirs to write. **And with the marker the guard
  still asks** (#4436): a comment is something a session can write itself, so the line reaches Claude
  Code's confirmation prompt and runs only once the person confirms it there.
- **The app deploy rides inside the same word**, as a required switch on the same line. Where
  `Get-ShopifyAppRoot` is answered, the line says `-AppDeploy` or `-SkipAppDeploy`, and neither is
  refused. Skipping writes `hold` for the app's files into the live-push record, so it never needs a
  hand edit.

## The steps -- it stops at the first refusal

| # | step | what it does |
|---|---|---|
| 1 | **preflight** | runs [`live-preflight`](https://github.com/DKJ-Solutions/dkj-marketplace/blob/main/plugins/dkj-subagents/dkj-subagents-shopify/skills/live-preflight/SKILL.md) unchanged, with `-ResultPath`, and carries on only from an allowed run that composed a promotion and wrote a record. |
| 2 | **promote** | opens the promotion PR, trunk into the deploy branch, or reuses the open one. |
| 3 | **checks** | polls the PR's required checks until they settle (`-CheckTimeoutMinutes`, default 30). A failure stops. **The merge bypasses the deploy ruleset, so this wait is the gate the ruleset would have been**: an answer it cannot read is waited on, never merged over. |
| 4 | **merge** | `gh pr merge --merge --admin`: a merge commit, the head branch kept. This is what goes live. |
| 5 | **verify** | pulls the record's `live` theme files from the live theme and compares each one's `git hash-object` with the promoted commit's blob (a deleted file must be absent), polling until all match (`-VerifyTimeoutMinutes`, default 15). By hash, because a text compare through the console mis-decoded non-ASCII on the measured day. |
| 6 | **app** | `shopify app deploy --path <root> --allow-updates` under `-AppDeploy`, or the record's app lines to `hold` under `-SkipAppDeploy`. |
| 7 | **cut** | `cut-release -Version <v> -LivePushRecord <record>` (dkj-repo-workflow), with `-Title` if given. |
| 8 | **notify** | `notify-live -Version v<v> -LivePushRecord <record> -Post`. |

**A stop after the merge is resumed, not re-run.** The promotion cannot be made twice, so every stop
past step 4 prints the line to run the rest with `-ResumeFrom <verify|app|cut|notify> -LivePushRecord
<path>`, without the marker. A resume first checks that the record's promoted commit is on the deploy
branch.

**`-AcceptUnverified`** turns a verify timeout into a note, after a person has read the paths it named on
live (a JSON template the theme editor rewrote, say) and judged them live. Never a default.

## What it does not cover

A store whose live theme goes live by a CLI push (`Get-ShopifyLiveDeployBranch` unanswered) is refused:
there, `live-preflight` prints the push for a person to make, under its own two boundaries.

The parameters `-SinceTag`, `-BackupTimeoutMinutes`, `-BackupVerifyExisting`, `-AcceptRejectedWriteBacks`
and `-AcceptOwedReconciliation` pass straight through to `live-preflight`.

## What is tested

`scripts/tests/bwj-go-live.tests.ps1` pins the decisions in `scripts/lib/go-live-rules.ps1`: the step
order, the app-deploy switch, the check states, the verify paths and the hash comparison, the record
rewrite, and a resume line that never carries a marker. `scripts/tests/guard-live-theme.tests.ps1` pins
the guard's rule 6. The script itself is not driven, for `live-preflight`'s reason: every step reaches gh,
git or a real store.
