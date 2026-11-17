# issues-sweep -- parking an issue that waits

> Read on demand from [`SKILL.md`](SKILL.md) step 1, when a `free` issue turns out to be waiting, or to
> be too large for one sweep turn. The loop itself is on `SKILL.md`
> ([#4233](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4233)).

## A waiting issue is parked on the tracker, not held out

**A `free` issue that turns out to be WAITING is parked on the tracker, not held out**
([#2843](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2843)). The wait might be a live
push, a release, a deletion or a credential (`awaiting-action-dev`), work that may only run inside the
next release (`awaiting-release`, which the cut lists), a release of another repo (`awaiting-release-external`), another issue's pull request (`awaiting-pull`), a pull request in another repo whose work is not yet available here (`awaiting-pull-external`), an external event or date (`awaiting-action-external`), the owner's choice
(`awaiting-decision-dev`), or a choice that belongs to the client or requester outside the dev team (`awaiting-decision-client`, #2890), or somebody's look at a result (`awaiting-review-dev` for the owner's, `awaiting-review-client` for the client's or requester's, #2977). Park it through the claim, with the matching label and what it waits on:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/task/claim-issue.ps1" <n> -Tag -Park <awaiting-label> -Reason "<what>"
```

It claims the issue as step 2 does, and only the winner of the claim's read-back sets the label, posts
`Parked by a sweep: waiting on <what>.` and releases its claim. A park is a tracker write like a claim,
and before `-Park` it took no claim at all
([#3907](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3907)). Measured November 8, 2026: four
sweeps on one repo within three minutes parked the same issues, up to three comments each, and the
verdicts differed in substance. A lost race now refuses with exit 1 and writes nothing. **Never park with
a bare `gh issue edit` and `gh issue comment`**, because that pair is the race this closes.

**A `-dev` wait on a developer who is not the owner names them with `-Decider <login>`** (#4208). The
parking comment then ends `Decider: @<login>.`, `-Candidates` prints it beside the label, and
`issues-sweep-decisions` and `issues-sweep-reviews` put the issue only to that account. It is accepted on
`awaiting-decision-dev`, `awaiting-review-dev`, `awaiting-action-dev` and `awaiting-session-dev`. The
assignee is not the carrier, because the claim writes it and the release removes it. Without `-Decider`
the owner decides, as before.

**And a verdict that settles an issue is building work, so it starts at step 2.** Evaluating an issue and
closing it on that evaluation is not triage: claim it first. The same measurement had a sweep post an
evaluation and close an issue while another tag held its claim and was writing the same verdict on a
branch.

## What `<what>` names

For `awaiting-pull`, `<what>` names the blocker as `#<n>` or a branch, before any explanation (`waiting
on #123's pull request -- ...`): that clause is what `stale-park` reads. For `awaiting-pull-external` it
names `owner/repo#n` in full, and for `awaiting-release-external` it names `owner/repo` (`waiting on
owner/repo's next release -- ...`). The clause ends at the first sentence end, `;`, `:`, ` -- `,
opening parenthesis or line break, so a list inside parentheses is not read.

Where an installed extension closes an act-only issue instead of parking it (`dkj-repo-workflow-bwj` does,
#3062), that extension's close applies in place of `awaiting-action-dev`, under that extension's own
conditions and with the act, and who performs it, recorded on the issue.

## Too large for one sweep turn

**A `free` issue that is workable but too large for one sweep turn is parked as `awaiting-session-dev`**
([#4066](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4066)). It waits on nothing outside,
only on a session of its own. The test: the remaining work cannot finish within one sweep turn, because
it needs several independent measurements or more than one branch. **Work that only needs a capability
the session lacks does not qualify**; verify first that the capability really is missing (a missing
capability is usually a default). Park it the same way, with a `-Reason` that names the remaining steps
(`-Park awaiting-session-dev -Reason "a dedicated session -- <the steps left>"`), so the next session reads
that comment and not the whole thread. A sweep never lifts this label: a person, or a session told to work
that issue, removes it and claims it. Measured November 13, 2026 (BWJ-Development/smartwatchbanden#1306):
a site-speed issue with three measurements left was released and held out with `-SkipIssue`, and the owner
read it as skipped, when it was waiting on a session.

## `-SkipIssue` is not a park

`-SkipIssue` lasts one run and writes nothing, so a wait held out that way is judged again by every
sweep after it. Measured October 6, 2026
([xoxowildhearts](https://github.com/BWJ-Development/xoxowildhearts)): five of six `free` issues
were held out for the same reasons the previous day's sweep had held them out for. With the label, the
next sweep's step 1 reads them as `skipped`. **`-SkipIssue` stays for a hold-out that is not a wait**,
such as a source ticket you could not read; an issue too large for the turn is not one, and takes
`awaiting-session-dev` above. Where the tracker does not carry the label yet,
`adopt-triage-labels` prints the line that creates it.
