# Changelog

## [Unreleased]

**1 / 3 minor entries** <!-- pending-tally -->

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

