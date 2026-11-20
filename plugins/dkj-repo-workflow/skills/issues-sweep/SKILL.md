---
name: issues-sweep
description: >-
  Work an open-issue backlog with SEVERAL machines at once, without two of them building the same
  thing. Each session claims by TAG -- machine:checkout/account, written as a marker comment -- so a claim names
  the checkout even where two of them share one machine and one GitHub account, and a two-session race is settled on
  the tracker's own timestamps: earliest marker wins, and only the losers let go. Use it when issues
  have piled up and you want them worked through rather than picked at one by one. It claims, builds,
  runs the gates and PARKS a result that has to be judged by eye, then goes on to the next issue -- it
  never opens a pull request on work nobody has looked at, and it never pushes anything live.
disable-model-invocation: true
---

# issues-sweep -- six machines, one backlog, no duplicated work

**This page is the loop. What applies only in a particular case is on a page beside it, read when that
case arises** -- the body of this skill stays in context for every turn of a sweep, so it carries only what
every turn needs ([#4233](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4233)):

| page | read it when |
|---|---|
| [`candidates.md`](candidates.md) | step 1 prints `branch`, `stale-park`, `relabel`, a goal tree, or a `free` issue that may mirror a ticket from somewhere else |
| [`parking.md`](parking.md) | a `free` issue turns out to WAIT, or is too large for one sweep turn |
| [`claiming.md`](claiming.md) | a claim refuses, you resume your own issue from another machine (`-TakeOver`), or you leave a machine (`-ReleaseAll`) |
| [`lane-mode.md`](lane-mode.md) | this sweep runs in a worktree beside another sweep on the same machine |
| [`why.md`](why.md) | a rule below is in question, or before changing one -- the measurements behind steps 4, 5 and the close-out |

**Run the shared script from the root of the consuming repo**, as the lines below spell it. *In the
source repo, run its own copy instead* -- `scripts/task/claim-issue.ps1`: `${CLAUDE_PLUGIN_ROOT}`
resolves into the plugin cache, which holds the last released mirror.

**One sweep per checkout, one issue at a time.** Claim, build, gates, hand over, next. The parallelism is
the CHECKOUTS, not the issues: a second issue in the same checkout means two branches in one working copy,
and nothing on the tracker can tell those apart. A second checkout -- another clone, or a
[worktree-lane](../worktree-lane/SKILL.md) -- is a second tag, on the same machine or another. A
visible park (step 5) is an issue handed over like any other: the branch waits on `origin`, and the
sweep goes on. **A second sweep on the same machine runs in a lane**: [`lane-mode.md`](lane-mode.md).

**A sweep claims with a tag, never with the assignee alone**: `machine:checkout/account`, written as a
marker comment, with the assignee beside it as the tracker's visible signal. Why the assignee cannot be
the claim is on [`claiming.md`](claiming.md).

## The loop

### 0. Once, before anything

```powershell
git status                  # must be clean
git checkout main ; git fetch origin --prune ; git pull --ff-only
```

Then read the repo's own `CLAUDE.md`. **It outranks everything on this page**, and where the two
disagree you follow it and say so.

### 1. Choose -- and it writes nothing

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" -Candidates
```

It prints every open issue as `free`, `mine`, `held`, `branch`, `stale-park`, `relabel` or `skipped` with
the reason, and names the lowest free number. `-SkipLabel` defaults to every label that parks an issue with
somebody else, former names included, so pass none; `-SkipIssue` holds numbers out by hand.
`-Author @me` judges only issues your own sessions filed, the rest read `skipped` (#4337): in a tracker two people share, each sweeps what their own sessions opened.

- **`branch` is not free** -- somebody pushed work for it without a marker. Read that branch first.
- **`stale-park` and `relabel` are waits that have cleared**: run the lines the output prints. **Never swap
  a parking label by hand.**
- **A decision wait reading `stale-park`** has its `Decision (` comment: read it before you build.
- What each state means, and how a goal tree reads: [`candidates.md`](candidates.md).

**Choosing and claiming are two steps on purpose**: between them, ask whether the issue is this repo's
work at all. Where it mirrors a ticket from somewhere else, read who that ticket is assigned to before you
take it, and **a source ticket you cannot read is no green light** -- report it as unjudged and move on.

**A `free` issue that turns out to WAIT is parked on the tracker, not held out** -- and one that is
workable but too large for one sweep turn is parked as `awaiting-session-dev`, with the steps left in its
`-Reason`. Both go through the claim, never a bare `gh issue edit` plus `gh issue comment`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag -Park <awaiting-label> -Reason "<what>"
```

Which label, what `<what>` must name (`#<n>` or a branch first, for `awaiting-pull`), `-Decider`, why
`-SkipIssue` is not a park, and why an act-only issue in a repo enabling `dkj-repo-workflow-bwj` is closed
rather than parked (#4340): [`parking.md`](parking.md). **A verdict that settles an issue is building
work**, so it starts at step 2.

### 2. Claim it

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag
```

The marker goes on, the assignee beside it, and the claim is **read back**: a lost race releases this
session's marker and stops with exit 1. The claim also refuses an issue that gained a `<prefix>/<n>-*`
branch on origin or a parking label since step 1. Take the next free number -- a lost race costs a claim,
never work.

**Run the claim on its own and read its whole verdict before step 3.** Never chain it into `new-branch`
with `;`, and never cut its output with `Select-Object -Last 1`: the last line of a refusal is the issue
URL, so a cut refusal reads like a claim.

**A refusal is final**, with one exception: your OWN issue whose branch is on origin, resumed with
`-TakeOver`. That, the marker-less branch, `DKJ_OWN_ACCOUNTS` and `-ReleaseAll`: [`claiming.md`](claiming.md).

### 3. Build it

Read the issue and its comments in full. Then the ordinary workflow, unchanged:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/new-branch.ps1" -Name <prefix>/<n>-<short-name> -Title "<title>"
```

The prefix table is this repo's own (`scripts/lib/branch-info.ps1`) -- read it rather than guessing.

**The build goes to a fresh subagent on `sonnet`; the judgement stays here**
([#4240](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4240)). A sweep's main loop runs on the
session's model, and building is the bulk of its tokens, while choosing, parking and judging the result
are the part that needs it. So once the branch is open, hand the edit to the subagent whose craft it is (a
script to the system administrator, a doc to the technical writer, application code to the app
developer), or to `general-purpose` with `model: sonnet` where none fits. Never a `fork`: it inherits
the sweep and commits on its behalf. The brief carries the issue's ask and the measurements in it, the
files to touch, the repo's rules that bind them, and **"edit the working copy; do not commit, push, open
a PR or touch the tracker"**. When it returns, read the diff yourself: it is your claim, and a delegated
mistake ships under it. Then fill the branch document's `### CREATE`, `### TEST` and `### DEPLOY:`
sections yourself. Build it inline instead where the brief would be longer than the edit.

The `### DEPLOY:` section of `.dkj/dkj-repo-workflow/<branch>.md` IS the changelog entry. The change and
its entry go in **one** commit.

### 4. The gates -- `ship-pr` runs them, not you

**You run no gate yourself, wherever step 5 sends the branch.** A shipped branch gets `ship-pr`'s full
gate, and a pre-run is almost never credited; a parked branch gets the gate when step 6 ships it, and the
required CI check before the merge. Either way the gates' outcome is a number, not a feeling, and it is
`ship-pr` that records it. The measurements: [`why.md`](why.md).

### 5. Ship it, or park it for the owner's eye

**Does the change produce something that has to be judged by eye?** A frontend, styling, rendered
output, an Admin page, anything a visitor of a storefront can see or do. If yes -- or if you have to
ARGUE that it renders, which is itself the doubt -- then:

- push whatever preview the repo has (in a Shopify consumer, `push-preview`), hand it over in the form
  that repo's own pages prescribe, and **open no pull request**;
- park the branch on `origin`, and set `awaiting-review-dev` on the issue (`awaiting-review-client` when
  the client must look) together with a one-line comment on what to look at and the URL that shows it
  (#2977, #3819), so the next
  sweep reads it as `skipped`;
- then **on to step 7, like any other issue** -- the sweep goes on with the next `free` one. The sweep is
  the constitution's one carve-out from keeping the checkout on a visible branch (#3552); why:
  [`why.md`](why.md).

**If the gates prove it** -- scripts, tests, docs, config -- the movement runs through without an
intermediate question: open, merge, fold.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/release/ship-pr.ps1" -Resolves <n> -HandOff
```

**`-HandOff` (#4355)** ends the run once the PR is armed and the checkout is on the trunk: merge-on-green merges
and fold-on-merge folds it, so go straight to step 7 in the same turn. Where it cannot hand off it says why and
watches CI as usual.

**`-Resolves <n>` is not optional here** -- a bare `ship-pr` is refused on a sweep branch (#2376). Where
the branch is only one step of a larger issue -- the issue stays open for the next step -- pass
`-NoResolves` instead, and say in a comment on the issue what the step did and what is left.

### 6. Coming back to an approved branch

An approval names a branch or an issue number. **Verify that this tag is the one that built it, before
you check anything out:**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag -Verify
```

Exit 0 means yours; anything else means another session's, and on this machine a checked-out branch is
indistinguishable from your own. **This is the sharpest place a vague claim costs** -- step 1 skips
everything that carries a marker and is therefore safe whoever wrote it, while this step deliberately
resumes on the tag's own work.

Then take the review label off (`gh issue edit <n> --remove-label awaiting-review-dev`, or `awaiting-review-client`), mark the branch document's owner-look step `- [~]` with who approved it, when and what they saw, and commit that (`open-pr`'s step gate refuses it open, #3829), ship it -- the same `ship-pr.ps1 -Resolves <n>` as step 5, plus `-OwnerLook "<who approved, when, what they saw>"` so a template box for the owner's look is answered too (#3958, [`issues-sweep-reviews`](../issues-sweep-reviews/SKILL.md) step 4) -- and close the issue the way this repo
closes issues. **Where the issue mirrors a ticket
somewhere else, the message to the person who asked comes BEFORE the close** -- the plugin that owns
that mirror carries the form; without such a plugin the ordinary `Closes #<n>` applies.

### 7. Clean up, and go again

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/prune-merged.ps1"
git checkout main
```

Back to step 1, in the same turn.

### When the sweep ends, and the one close-out it owes

**The loop stops when step 1 has nothing left for this session**: every issue `-Candidates` prints as
`free` has been shipped, given back, parked on the tracker with its `awaiting-*` label because it
waits, parked for the owner's eye at step 5, or judged and held out (with `-SkipIssue` and a reason)
for something that is not a wait. Nothing else ends it, and neither one shipped issue nor one visible
park does.

**The close-out `ship-pr` prints is one issue's receipt, not the sweep's** (#2562): read it as the cue
for step 7, not as the end of the assignment.

**What it skipped as `awaiting-decision-dev` is the owner's half**, and `issues-sweep-decisions` walks it with
them in one pass; a decided issue comes back here as `free`. What it skipped as `awaiting-decision-client` is nobody's half here: it waits on the client or requester, and neither skill walks it. **Nor does either walk `awaiting-review-dev` or `awaiting-review-client`** (#2977): those wait on a look at a result, not on a choice, and the look is the owner's or the client's to give. Where the owner gives it for the whole pile at once, `issues-sweep-reviews` runs step 6 for every `awaiting-review-dev` issue in one pass; only the owner types it.

**The sweep closes out once, after the loop**, in the ordinary receipt shape: the PR number of each issue
it shipped (each handed-off one as "armed, merges via merge-on-green"), each branch it parked for the owner's eye with the `git checkout <branch>` line and, each on
a line of its own, the URL of every page it changed as a markdown link `[<label>](<url>)` (#3819, #3954), the number and label of each it parked as waiting, and the number of each it held out, with a clause
for why.

## Giving an issue back

A session that cannot finish an issue -- blocked, out of scope, waiting on somebody -- releases it
rather than leaving a marker standing:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag -Release
```

It deletes only markers carrying THIS tag, and the assignee with them. Where the issue is going back to
whoever asked for it, set the repo's own parked label in the same movement and say what you need --
a card parked with a question nobody can read is a waiting room nobody knows the subject of.

## What it never does

- **Open a pull request on work nobody has looked at**, where the result has to be judged by eye.
  Waiting means NOT OPENED, not "opened and unmerged".
- **Push anything live, publish anything, or cut a release.** Those come from a person, always.
- **Take an issue whose marker carries another tag** (outside `-TakeOver`), or one whose source
  ticket it could not read.
- **Delete another session's marker** -- except through `-TakeOver`, on your own issue (this account or
  a declared one) with its branch on origin. `-Release` touches this tag's own and nothing else.
- **Close an issue that carries the repo's parked label.** That one is with the requester.

## Requirements

`gh`, authenticated, and `git`. An incomplete tag refuses before the tracker is even read; where the tag
comes from, and `-Marker`: [`claiming.md`](claiming.md).

## Important

The scripts behind this skill are maintained in the source repo; do not modify them locally in a
consumer. A change lands first in the source and travels here via a release.
