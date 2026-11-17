# issues-sweep -- what step 1's candidate list means

> Read on demand from [`SKILL.md`](SKILL.md) step 1: when `-Candidates` prints a state other than
> `free`, `mine` or a plain label skip, when a goal tree is in the list, or when the issue may mirror a
> ticket from somewhere else. The loop itself is on `SKILL.md`; this page is its step 1 in full
> ([#4233](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4233)).

## The states

`-Candidates` prints every open issue as `free`, `mine`, `held`, `branch`, `stale-park`, `relabel` or
`skipped` with the reason, and names the lowest free number.

**`-SkipLabel` defaults to the labels that park an issue with somebody else**, so a sweep passes none
(the list is the default in `claim-issue.ps1`, and `claim-issue.tests.ps1` pins it). `-SkipIssue` holds
numbers out by hand. The last eleven names in that default are former names -- `needs-info` then `awaiting-more-info` became `awaiting-info-client` (#2917, October 12, 2026), `needs-decision` and then `awaiting-decision` became `awaiting-decision-dev`,
`awaiting-recurrence` then `awaiting-first-recurrence` became `awaiting-recurrences-first`, `dossier` then `record` then `awaiting-more-recurrences` became
`awaiting-recurrences`, `awaiting-owner-act` became `awaiting-action-dev`, and `awaiting-event` became
`awaiting-action-external` (#2683, #2723, October 2, 2026; #2741, October 3, 2026; #2890 and #2896, October 7, 2026; #2904, October 9, 2026) -- listed because a tracker keeps an old name until
somebody renames it there.

**`branch` means somebody pushed work for it without a claim marker** -- a `<prefix>/<n>-<name>` branch
is on origin, and the reason names its author and how long ago it last moved. It is not free: a marker is
only written by a session that ran `-Tag`, so the tracker alone once read 11 of 11 open issues as free
while 9 had a live branch
([#2392](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2392)). Read that branch, or ask its
author, before you claim one. **And `free` still means only what this step can see** -- no marker and no
branch named with the number; a branch named for the subject is caught at the claim, by its
title-overlap scan.

## A goal tree

**A [`plan-goal`](../plan-goal/SKILL.md) tree is not a backlog**
([#3961](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3961)). Measured November 10, 2026: one goal
with 6 milestones and 24 tasks read as 31 `free` issues, and none was sweep work. So `-Candidates` reads the
tree once, with the query `plan-goal -Next` uses, and marks the goal and its milestones `skipped` as
containers, and every task but the goal's **Now** `skipped` as not yet Now. Now stays `free`, and a repo
whose Now is an owner-only step parks it with its label. An unread tree is said, and leaves only the `goal`
label's own skip.

**A parked Now does not hold the goal**
([#4101](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4101)). The sweep's Now is the first open
task that carries none of the `-SkipLabel` labels, so a task parked for the owner's look lets the next task in
order go free, and the reason names what it passed (`Now is #4086 (#4085 parked)`). Measured November 14,
2026: goal #4081's Now was parked as `awaiting-review-dev`, and its 18 other issues read `0 free` for every
sweep, against the visible park above that exists so a sweep goes on. One task per goal is still free per sweep,
and an unplanned milestone still stops the walk. `plan-goal -Next` keeps showing the goal's own Now,
since that view is the owner's.

**Nor does a Now another sweep is on**
([#4105](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4105)). A task `held` by another tag, or
with a `branch` pushed for it, is walked past the same way, so a second sweep beside a running one takes the
next task in order (`Now is #4088 (#4085 parked, #4086 parked, #4087 held)`); this tag's own `mine` stays its
Now. Measured November 14, 2026: the second of two sweeps on goal #4081 read `0 free` while the first held
its Now. The owner accepted that a task depending on the one before it can be built early.

## A wait that has cleared -- `stale-park` and `relabel`

**`stale-park` means an `awaiting-pull` issue whose wait has cleared**
([#3136](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3136)). Nothing lifts that label at
the merge, so `-Candidates` reads the `waiting on` clause of the parking comment and asks the tracker
about every `#<n>` and branch in it. Measured October 19, 2026: two issues stayed `skipped` after both
their blockers had merged. When all of them have landed, unpark the issue with the two lines the run
prints, and it is free for this same sweep. A parking comment that names no number or branch is read as
before, and its reason says so.

**An issue parked at filing is read from its body**
([#4028](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4028)). A label set in the same
`gh issue create` leaves no parking comment, so where no comment names the wait, `-Candidates` reads the
same clause in the body. Measured November 12, 2026: #4025 named its blocking branch only in prose, and
stayed `skipped` after that branch merged. **So whoever files an issue under `awaiting-pull` writes the
line `Parked: waiting on <#n or branch>.` in its body**, in the clause form above; prose that merely cites
the branch is never read, because a body citing numbers is not a statement of what it waits on.

**The two external waits can also read as `stale-park`**
([#3572](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3572)), each by what clears it.
`awaiting-pull-external` clears once every `owner/repo#n` its clause names has landed *and* that repo has
published a release since. `awaiting-release-external` clears once the `owner/repo` its clause names has
published a release after the parking comment was written. What is left after either is this repo's own
work, so the issue is free.

**Between the two, an `awaiting-pull-external` issue reads as `relabel`**
([#4226](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4226)): every `owner/repo#n` it names has
landed, and no release has followed yet, so it waits on a release now. Move it with the line the run prints,
`claim-issue.ps1 <n> -Tag -Park awaiting-release-external -Reason "<owner/repo>'s next release"`, which lifts
the old label in the same edit and posts the dated parking comment. **Never swap the label by hand**: measured
November 17, 2026, a hand swap left a park dated by nothing, and `awaiting-release-external` is read only
from a dated parking comment, so that park would never have cleared.

**The two decision waits can read as `stale-park` too**
([#4186](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4186)). `awaiting-decision-dev` and
`awaiting-decision-client` clear once a comment opening `Decision (` follows the last parking comment, written by
somebody with a hand on the repo. Measured November 16, 2026: two issues got their client's answer as a comment,
from a session without this plugin, and stayed skipped until the owner asked why. Read that decision before you
build. **No other parking label is read**: each waits on a person, or on something no tracker records, and
`awaiting-release` already surfaces at this repo's own cut.

## Is it this repo's work at all

**Choosing and claiming are two steps on purpose.** Between them you still have to ask whether the
issue is this repo's work at all. A tracker carrying an issue means the work is TRACKED here, not that
it is OURS: where the issue mirrors a ticket from somewhere else, read who that ticket is assigned to
and what its comments say before you take it. Measured, September 17, 2026
([#722](https://github.com/BWJ-Development/smartwatchbanden/issues/722)): four tickets were mirrored
onto a board, three belonged to a colleague's own running experiment, and they were built, merged and
reported as delivered before anybody asked. **If you cannot read the source ticket, that is not a green
light** -- report the number as unjudged and move on.
