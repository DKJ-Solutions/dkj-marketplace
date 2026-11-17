# issues-sweep -- a second sweep beside a running one (lane mode)

> Read on demand from [`SKILL.md`](SKILL.md), only by a sweep that runs in a git worktree beside the
> primary checkout. Everything on `SKILL.md` holds there except the four steps below
> ([#4233](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4233)).

**One checkout is single-occupancy for every local gate**, which is several minutes per issue, so a
second sweep on the same machine halves the wall-clock on a backlog that the gates prove
([#3557](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3557)). It needs a working copy
of its own: a git worktree beside the primary checkout. Open it once, from the primary, detached at the
trunk:

```powershell
git fetch origin --prune
git worktree add --detach "..\<repo>-lanes\sweep-2" origin/main
```

Then start Claude Code **in that directory** and run this skill there. Its path differs, so its claim tag
differs too (#2836): the two sweeps read each other's claims as `held` and never take the same issue.
`worktree-lane.ps1` is not the opener here, because it creates a branch, and a sweep's branches come one
per issue from the loop.

**Four steps read differently inside the lane. Everything else on `SKILL.md` holds as written:**

- **Step 0.** No `git checkout main` and no `git pull`. The primary holds `main`, and git will not give
  one branch to two worktrees. Run `git fetch origin --prune` and `git checkout --detach origin/main`.
- **Step 3.** Before `new-branch`, the same two lines again, so every branch is cut from a fresh
  `origin/main`. `new-branch` reads a detached HEAD as a base and not as a stack, so it cuts there
  without a warning.
- **Step 5.** `ship-pr` runs from the lane, unchanged. A lane never returns to `main` before the CI wait
  (`Get-TrunkReturnDecision`). After the merge the fold goes one of two ways. If the primary is standing
  on `main`, `ship-pr` merges and leaves the fold to the repo's CI fold runner (#2087). If `main` is
  free, it folds in the lane and then releases `main` again (`ship-pr`'s step 5b). **A repo without a CI fold runner**
  is refused at `ship-pr`'s step 0 while the primary holds `main`, before anything is pushed. That
  refusal is the cue to leave lane mode in that repo. It never leaves a half-state behind. A visible park
  works as written, because step 7 detaches the lane and that releases the branch, so the owner can check
  it out in the primary.
- **Step 7.** `prune-merged`, then the two lines from step 0 in place of `git checkout main`.

**When the loop ends, the lane stays where it is**: detached, clean, holding no branch, and ready for
the next second sweep. Removing it is a single command from the primary,
`git worktree remove "..\<repo>-lanes\sweep-2"`. `tidy-machine` does not report it, because its
stale-lane check looks for a finished *branch* and this lane has none. Removing it from inside the lane
fails on Windows, because the session's own working directory holds the tree open.
