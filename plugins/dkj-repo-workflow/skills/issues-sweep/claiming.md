# issues-sweep -- the claim in full: the tag, refusals, and taking over

> Read on demand from [`SKILL.md`](SKILL.md) step 2: when a claim refuses, when you resume your own
> issue from another machine, when you leave a machine on purpose, or when the tag itself is in
> question. The loop itself is on `SKILL.md`
> ([#4233](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4233)).

## Why the assignee cannot be the claim

`claim-issue` without `-Tag` writes an assignee, which is the right claim for one session picking up
one issue. A sweep breaks it on both halves:

- **The write cannot name the machine.** Two checkouts authenticated as the same account write the
  same assignee, and neither can afterwards tell its own claim from the other's.
- **The read refuses work that is free.** An assignee a colleague put on their own ticket months ago is
  not somebody mid-flight. Measured on the BWJ board, September 17, 2026: three of fourteen open issues
  carried such a name, on work that was the ordinary business of that round.

So a sweep claims with a **tag**: `machine:checkout/account`, written as a marker comment. Both halves carry
weight -- two accounts can share a machine name and two machines can share an account
([#701](https://github.com/BWJ-Development/smartwatchbanden/issues/701)) -- and the assignee is still
written beside it as the tracker's own visible signal.

**The checkout is a short hash of the checkout's root path**, never the path itself, which would put a
user name on the tracker. Without it two sweeps on one machine under one account wrote one tag, and each
read the other's claim as `mine` -- measured October 5, 2026, when two sessions built the same issue and
one shipped it while the other ran its gates
([#2836](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2836)). A claim written before the
checkout half existed reads as `held`, with a note that it is this machine's and account's: read its
branch, and `-TakeOver` resumes it when the work is yours.

**The word "lane" is not used for it.** It already means a git worktree here
([`worktree-lane`](../worktree-lane/SKILL.md)), and the two are unrelated.

## What the claim checks before and after the marker

The marker goes on first, the assignee beside it, and then the claim is **read back**: if a second
machine got there first, this session releases its own marker and stops with exit 1. Take the next free
number -- a lost race costs a claim, never work.

**And before the marker, it asks origin once more.** An issue `free` at step 1 may have gained a
`<prefix>/<n>-*` branch since, pushed by a session that wrote no marker. The claim refuses it, whoever
wrote it: same account is not same session. Measured October 24, 2026
([#3386](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3386)): a sweep claimed #3379 an hour
after step 1, and the other session's branch merged first. Read the branch, and resume your own work
with `-TakeOver` below.

**And an issue parked since step 1 is refused too** (#3907). Another sweep judged it waiting in between,
and that claim used to print the PARKED warning followed by `[OK] ... claimed`, which twice had to be
released by hand. Take the next free number. A label that has gone stale is lifted first, and then the
claim runs again. The assignee route (no `-Tag`) keeps its warning, for #2518's reason.

**Why the claim runs on its own.** Measured October 27, 2026
([#3602](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3602)): a sweep's claim on #3596
refused as `held`, the chained `new-branch` ran anyway, and the owner got two parked fixes for one
issue. `new-branch` now refuses a second `<prefix>/<n>-*` branch when origin already carries one, but
that only catches a branch already pushed, not a claim still in flight.

## Taking over your own work

**A refusal is final -- with one deliberate exception.** `held` means another machine is mid-flight
and its branch is somewhere this session cannot see. The exception is your OWN issue on another of your
machines, whose branch IS on origin -- the state a machine you cannot reach leaves behind
([#2387](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2387)):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag -TakeOver
```

It refuses a colleague's claim, an issue with no branch on origin, and one with several; otherwise it
replaces the old marker with this tag's, comments the handover, and prints the checkout. The old machine's
`-Verify` then reads `[NO]`, so step 6 stops it there.

**The same command resumes a branch that carries NO marker** -- a session that never ran `-Tag` leaves
only its branch on origin, and the claim's parked-fix scan then prints `NOT YOURS` over your own work
([#2394](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2394)). `-TakeOver` checks who wrote
the branch instead: every commit off the trunk must carry one of your names. **If you work under more
than one account**, declare the others in `DKJ_OWN_ACCOUNTS` (the `env` block of your own
`~/.claude/settings.json`) -- a branch on origin written by one of your declared accounts is then
resumable through `-TakeOver`, and an undeclared author still stops you.

## Leaving a machine on purpose

**Leaving a machine on purpose, you can tidy first** -- `claim-issue.ps1 -Tag -ReleaseAll` lists every
open issue this tag holds, and `-Apply` releases them, so the next machine's `-Candidates` does not read
your old tag as `held` ([#2395](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2395)). It
touches this tag's own markers only, never another's, and it is optional: `-TakeOver` above is what
covers the switch you did not plan.

## The tag's parts

The tag's machine half comes from `$env:COMPUTERNAME` or `hostname`; its account half from
`gh auth status`. **An incomplete tag refuses before the tracker is even read** -- half a tag reads like
a claim and settles nothing.

`-Marker` names the marker a claim is written under (`claim-tag`) and any predecessors a repo still has
comments under, so a claim in flight under an older name still holds.
