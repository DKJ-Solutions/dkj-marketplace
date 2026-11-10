---
name: issues-sweep-reviews
description: >-
  Approve and ship every open issue parked on awaiting-review-dev in ONE pass -- the visible results
  issues-sweep parked for the owner's eye. Typing the command IS the owner's word for every issue it
  lists: each one gets an approval comment, loses the label, and its parked branch ships through
  ship-pr (open, merge, fold). It never touches awaiting-review-client, and never runs unasked.
disable-model-invocation: true
---

# issues-sweep-reviews -- shipping the visible results that wait on the owner

**`issues-sweep` parks a visible result instead of shipping it**: it pushes the branch to `origin`, sets
`awaiting-review-dev` on the issue and moves on (step 5, #3552). Shipping it afterwards is that skill's
step 6, run by hand for one branch at a time. When the owner has looked at a batch, or decides to trust
one, that is one manual round per issue. This skill runs step 6 for every one of them in a single pass.

**Running it is the owner's explicit permission, and that is the whole reason it is safe.** The
constitution lets a branch with a visible result merge only on the owner's word
([`CLAUDE.md`](../../CLAUDE.md#never-without-the-owners-explicit-permission)). `disable-model-invocation`
keeps this page out of every session's context and leaves the command to a person: only a person types `/issues-sweep-reviews`, and the repo's
own facts say which people count as the owner. **That command approves every issue it lists**, whether the
owner has opened each preview or not: the owner chose to approve without looking, and the comment this
skill leaves on each issue says so. A session never invokes it, never proposes it as the next step of a
sweep, and never reads *"ship it"* about one issue as *"run it for all of them"*.

**It walks `awaiting-review-dev` only, and never `awaiting-review-client`** (#2977). `client` waits on the
look of the client or requester outside the dev team. Approving it here would record a look that never
happened, given by somebody with no standing to give it. It comes off when that person answers.

## The loop

### 0. Once, before anything

Read the repo's own `CLAUDE.md`; it outranks this page. Then run the branch check: `git status` must
be clean, because every ship below checks out another branch. A dirty checkout stops the skill before it
writes anything.

List the parked issues:

```sh
gh issue list --state open --label awaiting-review-dev --json number,title --limit 500
```

An empty result is a complete answer: say so and stop.

**Arguments narrow the pass and never widen it.** Issue numbers after the command
(`/issues-sweep-reviews 3816 3820`) ship only those. `except <n> ...` ships all but those. A number that does
not carry `awaiting-review-dev` is not approved by being named: report it and leave it alone.

### 1. Find each issue's branch

A parked branch is named after its issue (`<prefix>/<n>-<slug>`):

```sh
git ls-remote --heads origin "refs/heads/*/<n>-*"
```

**Exactly one branch is the only case that ships.** No branch means there is nothing to merge, so hold
the issue out. A label without a branch is a defect in whatever parked it: say so in the close-out and
leave the label on. Two or more branches is a question this skill cannot answer: hold it out and name
both. A branch whose pull request is already open still ships the same way, because `ship-pr` picks up
the existing PR.

### 2. Verify that the claim is this machine's

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag -Verify
```

Exit 0 means this tag holds it. On anything else, take it over:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag -TakeOver -Parked
```

`-TakeOver` moves a claim from the owner's other machine to this one. **`-Parked` also moves a
co-owner's claim, and only on an issue that carries `awaiting-review-dev`** (#3846). Where the repo's own
facts name more than one owner, each of them can approve a visible result, whoever built it. The
colleague refusal exists to keep a session off a branch somebody is still working on (#2207), and a branch
parked for review has no such session: its builder stopped and handed it to the owner's look. Without the
label the claim refuses as `not parked`, and the branch preconditions (exactly one branch on `origin`)
hold as before. A refusal holds the issue out. When the work was a co-owner's, the approval comment in
step 3 says so: *"Approved (<owner>, <date>) ... Shipping <branch>, built by <co-owner>."*

In the source repo, run its own copies of these scripts (`scripts/task/...`, `scripts/release/...`)
rather than `${CLAUDE_PLUGIN_ROOT}`, for the reason [`ship-pr`](../ship-pr/SKILL.md) gives.

### 3. Record the approval, then take the label off

```sh
gh issue comment <n> --body-file <file>   # "Approved (<owner>, <date>) through issues-sweep-reviews, without a separate look at the result. Shipping <branch>."
gh issue edit <n> --remove-label awaiting-review-dev
```

`<owner>` is the account that typed the command as the tracker shows it, and `<date>` is today's date.
**The comment comes first and the label second**, so the thread always says why the label is gone. Where
the owner did look and said what they saw, that goes in the comment instead of *"without a separate
look"*, because what was seen goes on the issue (#2977).

### 4. Ship it

```powershell
git checkout <branch>
git pull --ff-only
# resolve the plan's owner-look step (below), commit it, then:
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/release/ship-pr.ps1" -Resolves <n> -OwnerLook "approved by <owner> on <date> through issues-sweep-reviews: <comment URL>"
```

**`-OwnerLook` carries the approval into the PR body too** (#3958). `gh issue comment` in step 3 prints
the comment's URL, and that goes in the answer. Where the repo's PR template has a box for the owner's
look (a Preview section, say) and names it with `Get-PrOwnerLookPattern` in `scripts/repo-config.ps1`,
`open-pr` ticks that box and writes the answer after it. Measured November 10, 2026: without it every
ship left the box empty, and a consumer check requiring one ticked box went red on
BWJ-Development/xoxowildhearts#499. A repo with no such seam is told so and ships as before. Keep the
answer on one line and free of double quotes.

**First resolve the step in the branch document that waits on the owner's look** (#3829). A parked
visible result's plan ends on one, `- [ ] The owner looks at ...`, and `open-pr`'s step gate refuses
every open step, with no `-Force`. So the approval of step 3 goes on that line too: mark it `- [~]` and
append the same words as the comment, e.g. *"Not done as a separate look: <owner> approved the branch
through issues-sweep-reviews on <date> without one."* (or what the owner saw). Commit it on the branch;
`ship-pr` pushes it. Measured November 5, 2026: all four branches of one pass carried that step, and every
ship was refused until it was resolved by hand. It records the owner's word, so it is not a build.

This is the same command as `issues-sweep` step 5, with the same reason: a branch named after its
issue fails `open-pr`'s resolves gate without `-Resolves`. That flag also closes the issue: the merge
resolves it, and `ship-pr` verifies the close. Read the run's **last line**, never its
exit code through a pipe ([`ship-pr`](../ship-pr/SKILL.md)). `ship-pr`'s own close-out is this issue's
receipt, not the sweep's (#2562), so go on to step 5.

**A refused ship holds the issue out, and does not put the label back.** A red gate or a conflict is not
waiting on a look any more: it is work. Say on the issue in one comment what refused and where, leave
the branch on `origin`, and let the next `issues-sweep` pick the issue up as `free`.

### 5. Clean up, and go again

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/prune-merged.ps1"
git checkout main
```

Then the next issue from step 0's list, in the same turn, until the list is empty.

### 6. Close out once, after the list

In the ordinary receipt shape: the PR number of each issue shipped, and the number of each one held out
with a clause for why (no branch, two branches, a claim that would not move, a refused ship).

## What it never does

- **Run without being typed.** No session invokes it, chains into it or offers it as a sweep's next step.
- **Touch `awaiting-review-client`**, or any other parking label. Only a look the owner can give is given here.
- **Force anything.** A refused gate, a red CI run or a conflict stops that issue and nothing else, and
  `ship-pr` never merges past one.
- **Build.** A branch that needs a fix commit goes back to `issues-sweep`.

## Requirements

`gh`, authenticated as an account the repo's own facts name as an owner, in a clean checkout of the repo
whose tracker it reads.
