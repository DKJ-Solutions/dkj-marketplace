# Changelog

## [Unreleased]

**11 / 14 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4228-prune-orphan-branch-documents · 20261117-145142Z

`prune-merged` (and so `tidy-machine`) gained step 4e and `changelog-mode-lib.ps1` the function behind
it; a repo answering `'fold'` has no such exclude lines, so the step stays silent there.

**Score:** 1

#### What makes this deploy extra special

In a repo that answers `Get-ChangelogMode` with `'none'`, `prune-merged` now removes a local branch
document and its `.git/info/exclude` line once the branch is gone locally and on the remote (#4228).
Before, a ship that stopped early (merge queue, a held merge, a failure after the merge) left both
behind for good. It prevents a failure that has not happened yet: an exclude file growing one line
per such branch.

**Score:** 1

#### Pull Request

prune-merged sweeps orphaned 'none' branch documents and their exclude lines

Plugins: dkj-repo-workflow

[PR #4232](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4232)

---

### DEPLOY: feat/4209-rename-dkj-repo-workflow · 20261117-142821Z

Inside this repo the workflow plugin and its two extensions carry new names, and so does every path,
id, skill and test that named them: `plugins/dkj-repo-workflow/`, `.dkj/dkj-repo-workflow/`, and the
retired-name machinery that maps the old ids.

**Score:** 4

#### What makes this deploy extra special

**Every consumer has to migrate, once, and it is a hard cut** (#4209). The workflow plugin `dkj-policy`
is now `dkj-repo-workflow`, `dkj-solutions` is `dkj-repo-workflow-dkj` and `bwj-development` is
`dkj-repo-workflow-bwj`, and the workflow folder `.dkj/dkj-policy/` is now `.dkj/dkj-repo-workflow/`.
The shared scripts read the new folder only, so a repo that has not moved finds no branch document.

To migrate a consumer, on a branch:

1. In `.claude/settings.json`, replace each `enabledPlugins` key: `dkj-policy@dkj-marketplace` with
   `dkj-repo-workflow@dkj-marketplace`, `dkj-solutions@...` with `dkj-repo-workflow-dkj@...`,
   `bwj-development@...` with `dkj-repo-workflow-bwj@...`; then `claude plugin install <id> --scope project`
   for each. `plugin-versions` and `update-plugins` name every retired id with this repair.
2. Run Part 1 of `adopt-dkj-repo-workflow` with `-Apply`. It moves `.dkj/dkj-policy/` to
   `.dkj/dkj-repo-workflow/` in one `git mv`, repoints the quoted seam paths in `scripts/repo-config.ps1`,
   the `.gitignore` lines and the PR template's first line, and rewrites the `CLAUDE.md` imports of the
   constitution and the extensions to their new paths.
3. Move the `ref:` pin in `fold-on-merge.yml` and `merge-on-green.yml` to the release that ships this
   (`adopt-ci-floor` prints the line); a pin below it reads the old folder and fails green.
4. A BWJ store repo may move `.dkj/bwj-development/` to `.dkj/dkj-repo-workflow-bwj/` and repoint
   `Get-ShopifySyncLogPath`, as `adopt-dkj-repo-workflow-bwj` describes. It is optional: the sync log
   lives wherever that seam points.

Until step 2 runs, `script-contract-sessioncheck` reports the old folder as an `[ERROR]` naming the move.

**Score:** 5

#### Pull Request

Rename the workflow plugin and its extensions to dkj-repo-workflow, -dkj, -bwj

[PR #4221](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4221)

---

### DEPLOY: feat/4230-reach-reason-after-the-fact · 20261117-132020Z

Inside this repo, `closed-message-sessioncheck` reads `reach-reason-rules.ps1` beside finding 6 and its
suite gains the cases for the new line.

**Score:** 1

#### What makes this deploy extra special

A store session now starts with an `[ERROR]` line naming every open issue that carries the reach label
with no `## Why <reach label>` section in its body. An issue that slipped past `guard-reach-reason` -- a
body built at run time, a body on stdin, `gh` unreachable, or a checkout that had not updated -- is
caught at the next session start, as #1398 and #1404 in smartwatchbanden were not.

**Score:** 3

#### Pull Request

bwj-development: catch a reach label without its reason after the fact

Plugins: bwj-development

[PR #4231](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4231)

---

### DEPLOY: feat/4213-changelog-mode-seam · 20261117-124945Z

Inside this repo, a new leaf lib (`changelog-mode-lib.ps1`) and one contract record (now fifty) carry
the seam. This repo states `'fold'`, and the fixtures that copy libs one by one now copy the new lib too.

**Score:** 1

#### What makes this deploy extra special

A repo whose changelog nobody reads can now drop the ceremony around it. Add
`function Get-ChangelogMode { 'none' }` to `scripts/repo-config.ps1`, and from then on a branch carries
its work commits and nothing else: no `park:` commit at creation or after a turn, and no `fold:` commit on
the trunk after the merge. The branch document is still written for the session and still names and
describes the PR, but it is never committed, and the PR body becomes the record. The entry gates, the CI
`Branch entry` check and the unfolded-entry session check stand down. `cut-release` refuses and names the
seam. The trade-off: work in progress reaches `origin` only when `open-pr` pushes it, so until then it is
not backed up. Every other repo keeps the full route without changing anything
([#4213](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4213)).

**Score:** 3

#### Pull Request

A Get-ChangelogMode seam: a consumer with no changelog reader skips the park and fold commits

Plugins: dkj-repo-workflow

[PR #4229](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4229)

---

### DEPLOY: feat/4226-park-move-release-external · 20261117-120836Z

`claim-issue -Candidates` now reads an `awaiting-pull-external` issue as `relabel` once everything it waits on has merged upstream but no release has followed: it waits on a release from then on, and the label said otherwise ([#4226](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4226)). The line it prints moves the issue in one step, `claim-issue.ps1 <n> -Tag -Park awaiting-release-external -Reason "<owner/repo>'s next release"`: `-Park` now lifts `awaiting-pull-external` in the same edit that adds its successor, and posts the dated parking comment the release-external stale-park reads. A hand swap with `gh issue edit` left a park that never cleared, because nothing dated it. Any other already-parked issue is refused by `-Park` as before.

**Score:** 2

#### What makes this deploy extra special

A sweep in a consumer repo sees the merged-upstream wait named, with the paste-ready move, instead of an owner spotting the stale label by hand.

**Score:** 2

#### Pull Request

claim-issue: an awaiting-pull-external issue whose upstream landed reads 'relabel', and -Park moves it to awaiting-release-external in one step

Plugins: dkj-repo-workflow

[PR #4227](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4227)

---

### DEPLOY: feat/4220-filed-with-stamp · 20261117-114823Z

Every issue a session files with `gh issue create` on a BWJ store repo now carries, at the end of its body, a hidden comment naming the plugin versions that session ran -- `<!-- filed-with: dkj-policy 6.18.0, bwj-development 6.18.0 -->` -- read from this checkout's install record. When an issue arrives malformed, the tracker itself answers whether the guard that should have caught it was installed ([#4220](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4220)). It is a PostToolUse hook rather than a step of `report-issue`, because a bare create is the case that slips past the procedure. It fails open: the issue always stands as created, and a body it cannot edit is named to the session. An inbound issue on the source repo is not stamped.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a BWJ store repo can answer *which version filed this?* with `gh search issues filed-with` instead of asking the colleague who filed it to run `plugin-versions`. Issues filed before the update carry no stamp, and cannot be given one after the fact.

**Score:** 2

#### Pull Request

bwj-development: stamp the filing session's plugin versions on every issue it creates

Plugins: dkj-repo-workflow-bwj

[PR #4225](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4225)

---

### DEPLOY: feat/4216-companion-plugin-check · 20261117-113943Z

A repo that enables the core team (`dkj-subagents-alpha`) without the developers team
(`dkj-subagents-developers`) now hears it at session start: `companion-plugin-sessioncheck` prints an
`[ERROR]` with the `enabledPlugins` line to add and the `claude plugin install ... --scope project` command
([#4216](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4216)). Before, the split in #4211 left such
a repo with eleven specialists and no word about it.

**Score:** 3

#### What makes this deploy extra special

The check that would have reported the gap shipped inside the plugin that was missing; this one lives in the
workflow plugin, which nearly every repo enables. A repo without `dkj-policy` stays uncovered.

**Score:** 2

#### Pull Request

A session check names a required companion plugin that is not enabled

Plugins: dkj-repo-workflow

[PR #4224](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4224)

---

### DEPLOY: feat/4219-kind-label-sessioncheck · 20261117-112709Z

Inside this repo, `closed-message-sessioncheck` gains a seventh finding with its own cases in the
suite, and finding 6 now shares its label read and number list with it.

**Score:** 1

#### What makes this deploy extra special

A store session (smartwatchbanden, xoxowildhearts, phone-factory) now starts with an `[ERROR]` line
naming every open issue that carries no kind label, or more than one, with the `gh issue edit` line
that repairs it. An issue that slipped past `guard-kind-label` -- a label built at run time, a
template, or a checkout that had not updated yet -- is caught at the next session start instead of
only when somebody notices, as #1390, #1391 and #1394 in smartwatchbanden were not.

**Score:** 3

#### Pull Request

bwj-development: catch a kind-less issue after the fact

Plugins: dkj-repo-workflow-bwj

[PR #4223](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4223)

---

### DEPLOY: feat/4211-split-developers-team · 20261117-110234Z

The core team is now two plugins. `dkj-subagents-alpha` keeps the specialists who work anywhere (Chris,
Bianca, Paula, Priya, Rebecca, Vera, Gwen, Uma, Edith, Marlowe, Auden) and is what the Claude App gets. The
specialists whose craft needs a repository (Derek, Rendall, Sylvester, Cody, Tycho, Victor, Sebastian, Ravi,
Nolan, Tessa), the skills `specialists-init`, `specialists-teardown` and `sync-roster`, and the roster session
check moved to a new plugin, `dkj-subagents-developers`
([#4211](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4211)).

**Every repo must enable the new plugin**, or a session there has eleven specialists instead of twenty-one and
no roster check. Add `"dkj-subagents-developers@dkj-marketplace": true` beside the core team in
`.claude/settings.json`, then run `claude plugin install dkj-subagents-developers@dkj-marketplace --scope project`
and restart. Lenses and roster rows need no change; the slash commands are now
`/dkj-subagents-developers:specialists-init`, `/dkj-subagents-developers:sync-roster` and
`/dkj-subagents-developers:specialists-teardown`.

**Score:** 5

#### What makes this deploy extra special

The Claude App now offers only specialists who can work without a repository: the PowerShell skills and the
roster hook no longer travel with the core team.

**Score:** 3

#### Pull Request

Split dkj-subagents-alpha into a portable core team and a repo-only developers team

Plugins: dkj-repo-workflow-bwj, dkj-repo-workflow, dkj-subagents-alpha, dkj-subagents-developers, dkj-subagents-shopify

[PR #4218](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4218)

---

### DEPLOY: feat/4208-park-decider · 20261117-104330Z

A `-dev` parking label no longer means "the owner alone". `claim-issue -Park <label> -Decider <login>`
names the developer an issue waits on, as `Decider: @<login>.` in the parking comment. `-Candidates`
prints it beside the label, and `issues-sweep-decisions` and `issues-sweep-reviews` put the issue only to
that account (#4208).

**Score:** 3

#### What makes this deploy extra special

A repo with more than one developer can park a decision, a look or an act on the one it belongs to,
instead of in front of the owner, who may have no context on it. Without `-Decider` nothing changes. The
three `-dev` label descriptions changed for a tracker adopting them fresh. An existing tracker keeps its
own wording, because `adopt-triage-labels` does not compare descriptions (#2942).

**Score:** 3

#### Pull Request

A named decider on a -dev park: claim-issue -Park -Decider, read by the owner sweeps

Plugins: dkj-repo-workflow

[PR #4217](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4217)

---

### DEPLOY: feat/4214-lifehub-agenda-ai-radar · 20261117-101853Z

A life hub gets two more skills: `/dkj-subagents-lifehub:agenda` walks the coming weeks of the Notion
Agenda and proposes one action per date, and `/dkj-subagents-lifehub:ai-radar` collects Claude Code
tips and updates into the hub's AI dossier without duplicates, both with the personal settings kept in
the owner's own Notion ([#4214](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4214)).

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Add the agenda and ai-radar skills to dkj-subagents-lifehub

Plugins: dkj-subagents-lifehub

[PR #4215](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4215)

---

### DEPLOY: docs/4210-claude-app-map · 20261117-100824Z

The Claude App map in [`ADOPTION.md`](../../plugins/ADOPTION.md#which-half-needs-a-repository--the-claude-app-map)
counted 15 core agent defs and listed every persona as portable. It now reads per plugin, over all four
teams, and its rule has a third test: a specialist whose craft is work on a checkout (Derek, Rendall,
Sylvester, Liam, Sandra) is repo-bound even when no script is named (#4210).

**Score:** 2

#### What makes this deploy extra special

A correction to a reference map; nothing a user of the plugins runs or installs changes.

**Score:** N/A

#### Pull Request

ADOPTION.md's Claude App map restated per plugin

[PR #4212](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4212)

---

### DEPLOY: feat/4206-lifehub-inbox-sweep · 20261116-222127Z

A life hub gets `/dkj-subagents-lifehub:inbox-sweep`: the Gmail inbox processed into the Notion hub by
the specialist each thread belongs to, and a thread archived only once its fact is verifiably there,
with the personal settings kept in the owner's own Notion
([#4206](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4206)).

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Add an inbox-sweep skill to dkj-subagents-lifehub

Plugins: dkj-subagents-lifehub

[PR #4207](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4207)

---

### DEPLOY: feat/4204-lifehub-agenda-sync · 20261116-211128Z

A life hub gets `/dkj-subagents-lifehub:agenda-sync`: Google Calendar synced into the Notion Agenda
every day, unattended, also as a cloud routine, with the personal settings kept in the owner's own
Notion ([#4204](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4204)).

**Score:** 3

#### What makes this deploy extra special

A life-hub owner can run the calendar sync in the cloud without their PC on, and the same skill works
on every machine.

**Score:** 3

#### Pull Request

Add an agenda-sync skill to dkj-subagents-lifehub

Plugins: dkj-subagents-lifehub

[PR #4205](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4205)

---

