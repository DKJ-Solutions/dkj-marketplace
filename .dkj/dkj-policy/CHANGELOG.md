# Changelog

## [Unreleased]

**3 / 6 minor entries** <!-- pending-tally -->

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

Plugins: bwj-development, dkj-policy, dkj-subagents-alpha, dkj-subagents-developers, dkj-subagents-shopify

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

Plugins: dkj-policy

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

