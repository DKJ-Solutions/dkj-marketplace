# Changelog

## [Unreleased]

**7 / 10 minor entries** <!-- pending-tally -->

### DEPLOY: docs/4018-uma-wireframe-craft · 20261112-110137Z

Uma's portable manual gains a hard rule: a wireframe built in a design tool is built the way a working
UX designer builds it, by default: scoped tokens and text styles first, repeated elements as
components with variants and properties, screens composed from instances, structure carried by
auto-layout instead of empty spacer frames, and layers named for what they are. "Plain" in "structure
before style" now reads as the look (greyscale, no brand), never as permission for the quick route
([#4018](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4018);
[`specialist-04-32-manual.md`](../../plugins/dkj-subagents/dkj-subagents-alpha/manuals/specialist-04-32-manual.md)).

**Score:** 2

#### What makes this deploy extra special

A consumer who asks Uma for a wireframe in Figma gets a file built from tokens, components and
auto-layout without having to ask for it, instead of one-off frames held apart by spacer frames that
the next designer has to rebuild.

**Score:** 2

#### Pull Request

Uma's manual: a wireframe in a design tool is built the professional way by default

Plugins: dkj-subagents-alpha

[PR #4020](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4020)

---

### DEPLOY: fix/4013-native-capture-wrap · 20261112-095119Z

The `native-capture` suite no longer fails when it runs from a checkout with a long root path, such
as a sweep lane: the assert that looks for the file name in the rendered error now reads it unwrapped
([#4013](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4013)).

**Score:** 2

#### What makes this deploy extra special

A test of this repo only; nothing a subscriber takes changes.

**Score:** N/A

#### Pull Request

native-capture suite: match the caret on unwrapped Out-String text

[PR #4015](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4015)

---

### DEPLOY: feat/4004-progress-page · 20261112-094216Z

A new Admin page, Progress, on `/dev/progress`, beside Goals. It reads what the Goals page and the Logbook
already hold, so nothing new is recorded and no store changes; the Goals query gains one field, a
milestone's labels.

**Score:** 3

#### What makes this deploy extra special

Every repo's Admin gains a Progress card. A repo with a goal sees, on one screen, how far its milestones are,
each marked built, used or measured (a closed milestone carrying the label `used` or `measured`), and how the
team ran: its assignments, how long Claude worked, how long it waited on you, and a column per assignment.
Questions asked and steps by hand read "not recorded yet" until #4008 records them.

**Score:** 3

#### Pull Request

Admin: a Progress page -- how far the app is, and how the team ran

Plugins: dkj-policy

[PR #4014](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4014)

---

### DEPLOY: feat/4005-measure-decision-stops · 20261112-093010Z

A new skill, [`measure-decision-stops`](../../plugins/dkj-policy/skills/measure-decision-stops/SKILL.md),
counts how often sessions on this machine stopped to ask the owner a menu question (`AskUserQuestion`)
and how each question was answered: the option marked Recommended as-is, the same with a note, another
option, the owner's own words, or declined. The headline is the share of questions that offered a
Recommended option and got it unchanged. Like `measure-closeouts`, it reads transcripts in place and emits
only counts. Close-outs of shape B, a menu written in prose, are not counted, and the report says so. On
the day it was written it measured 17 of 23 (74%), against the owner's estimate of about 90% (#4005).

**Score:** 3

#### What makes this deploy extra special

A consumer's owner can run `/measure-decision-stops` to see how predictable their own answers are before
deciding how readily sessions should ask them. It costs nothing until typed (`disable-model-invocation`).

**Score:** 2

#### Pull Request

measure-decision-stops: count decision stops and how often the owner picks Recommended

Plugins: dkj-policy

[PR #4012](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4012)

---

### DEPLOY: docs/4002-uma-brandbook-wireframe · 20261112-091821Z

Uma's repo lens is filled in for the first time. It says who the users of this repo's pages are (the
owners), that a statement about them is a labelled assumption unless confirmed, that her wireframes here
live in Figma rather than as a page in the repo, and that a wireframe is designed by hand rather than traced
from the HTML with `figma-generate-design`, which is the route that made the first attempt on #4002 a trace.
The wireframe itself lives in Figma and is not part of this diff.

**Score:** 2

N/A: the lens is read only inside this repo, and nothing this repo ships changes.

#### What makes this deploy extra special

The first wireframe of the team's new UX specialist that was designed rather than traced: three rows (the
page as it is, a previewing overview with search, a catalogue shell with previous / next), with seven
ranked findings and every user statement labelled as an assumption.

**Score:** 1

#### Pull Request

Uma: a real lo-fi wireframe of the brand book overview in Figma

[PR #4010](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4010)

---

### DEPLOY: feat/4006-working-profile · 20261112-090809Z

This repo consumes the core team too, so its maintainers can write a profile the same way. The gates
and the release run as before.

**Score:** 2

#### What makes this deploy extra special

A person can now write a working profile once, in their own `~/.claude/CLAUDE.md`, and Chris reads it in
every repo they work in. It tunes how the team works with them (how long a question is, who tests, how a
result is shown, how readily a reversible choice is asked about) and never loosens the constitution or the
safety rules. The template, and why it lives at user level rather than in a repo lens, is on
[`working-profile.md`](../../plugins/dkj-subagents/dkj-subagents-alpha/skills/orchestrator/working-profile.md)
([#4006](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4006)).

**Score:** 3

#### Pull Request

A per-person working profile the specialists read in every repo

Plugins: dkj-subagents-alpha

[PR #4007](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4007)

---

### DEPLOY: fix/3998-register-three-consumers · 20261111-164400Z

`dkj-etf-tracker`, `dkj-music-library` and `dkj-recipes` now have a manifest under `consumers/`, so the
registry check, the session hook and the registry-driven sweeps reach them (#3998). Each records the
plugins and lenses measured on that repo's `origin/main`.

**Score:** 2

#### What makes this deploy extra special

N/A: the register is workshop administration in this repo and does not travel with any plugin.

**Score:** N/A

#### Pull Request

Register dkj-etf-tracker, dkj-music-library and dkj-recipes under consumers/

[PR #4003](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4003)

---

### DEPLOY: fix/3997-golive-page-count · 20261111-163222Z

`build-golive-block`'s console summary now counts the pages a comma-separated `-Path` names, and names
the market count beside them: `-Path "/products/a,/products/b"` with four markets reads
`live urls: 8 (2 page(s) x 4 market(s))` where it read `1 page(s)`. Inbound
[#3997](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3997). The block itself was already
right. Cosmetic: a console line a session reads, never the block or a URL in it.

**Score:** 1

#### What makes this deploy extra special

No subscriber reads this line: it is the shipping session's own console, and the block it summarises
was already correct.

**Score:** N/A

#### Pull Request

build-golive-block: count the pages a comma-separated -Path names

Plugins: bwj-development

[PR #4001](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4001)

---

### DEPLOY: fix/3996-closed-message-json-array · 20261111-162054Z

The bwj-development session check that reports an Asana-linked issue left open after a `-NoResolves`
merge stopped throwing on session start in the store repos. It read gh's pull and issue lists as one
element each under Windows PowerShell 5.1, so the first `[int]` cast failed and the check never ran
(#3996). The suite now runs that live path through a stand-in `gh`.

**Score:** 2

#### What makes this deploy extra special

In a BWJ store repo the session start no longer prints `closed-message-sessioncheck skipped due to an
error`, and an Asana-linked issue still open after its `-NoResolves` PR merged is reported again.

**Score:** 3

#### Pull Request

closed-message-sessioncheck: parse gh's JSON lists so PS 5.1 does not wrap them

Plugins: bwj-development

[PR #4000](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4000)

---

### DEPLOY: fix/3995-closed-message-superseded-event · 20261111-161044Z

The `asana-closed-message` template no longer posts a stale message when two events on one issue
arrive out of order. Inbound
[#3995](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3995): on xoxowildhearts#512 the
reopen's run was created one second after the close's, so the task was told "back in development" and
its card moved back while the issue was closed. The script now reads the issue's current state before
it posts, and an event that state has already moved past (a reopen of a closed issue, a close of an
open one) posts nothing and moves no card, because the run of the later event carries the current
state. A failed read posts as before, logged. A consumer takes it by copying the template again
(`adopt-bwj-development`).

**Score:** 2

#### What makes this deploy extra special

A requester on Asana was told an issue was back in development while it had closed; that message no
longer goes out.

**Score:** 2

#### Pull Request

asana-closed-message: skip an event the issue's current state has superseded

Plugins: bwj-development

[PR #3999](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3999)

---

