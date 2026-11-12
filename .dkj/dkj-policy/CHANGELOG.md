# Changelog

## [Unreleased]

**9 / 13 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4011-plugins-route · 20261112-115800Z

The product server's plugin pages moved from `/marketplace` back to `/plugins`, with the h1, the
trail and the menu label named Plugins again; every old `/marketplace` address, the brand book's
token pages included, answers with a 303 to the same page under `/plugins`
([#4011](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4011)). Only the product server in
this source repo serves these pages.

**Score:** 2

#### What makes this deploy extra special

No consumer runs the product server, and a consumer's Admin links to it only in the source repo, so
nothing a subscriber takes changes.

**Score:** N/A

#### Pull Request

Product server: rename the /marketplace route to /plugins

Plugins: dkj-policy

[PR #4016](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4016)

---

### DEPLOY: feat/4009-brandbook-previewing-overview · 20261112-112521Z

The brand book on the product server previews and searches. Its overview opens on a sticky bar: a chip naming
the branch and commit the pages were read from, one search over every specimen and class name, a chip per group
and the theme switcher. Each card shows what it holds: a token group previews its tokens, and every card names its
specimens as chips that open the specimen itself. Radius, Spacing and Size are one group, Scale. Every page below
the overview carries previous / next and its position, so walking the whole book after a change is one button per
page. Built from the structure the owner picked on #4002's wireframe (#4009).

**Score:** 2

N/A: the brand book pages are this repo's own product server; no consumer runs them.

#### What makes this deploy extra special

The first structure the new UX specialist wireframed that made it onto a real page: the owner picked it from three
rows in Figma, and every finding it answers is named in the code where it lands.

**Score:** 2

#### Pull Request

Brand book overview: search, previews, a provenance chip and previous / next

[PR #4019](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4019)

---

### DEPLOY: feat/4017-golive-hotfix-form · 20261112-111334Z

[`build-golive-block.ps1`](../../plugins/dkj-policy/extensions/bwj-development/scripts/task/build-golive-block.ps1)
gains `-Hotfix` for a change that ships through a store's hotfix lane, a pull request to the live branch
merged once the requester approves it. The block names no release day: it says the change goes live as a
separate hotfix once approved, with `-LiveBy <date>` as the aim where the requester has a deadline. The ask
treats the look as that approval and no longer says the change ships with the release either way. The block
carries no release marker, so no "now live" message follows at the next release. It refuses `-LiveSince`,
`-From`, `-ReleaseDay`, `-Version` and the other forms
([#4017](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4017)).

**Score:** 3

#### What makes this deploy extra special

A BWJ store that ships a hotfix no longer has to bend `-ReleaseDay` to a deadline and patch the block by hand:
`-Hotfix` tells the requester the truth, which is that it goes live once they approve it.

**Score:** 3

#### Pull Request

golive-block: a hotfix form for a change that goes live on approval

Plugins: bwj-development

[PR #4021](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4021)

---

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

