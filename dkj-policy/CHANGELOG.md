# Changelog

## [Unreleased]

**2 / 3 minor entries** <!-- pending-tally -->

### DEPLOY: feat/3862-tidy-lane8-removes-records · 20261107-104657Z

`tidy-machine` lane 8 now removes an install record whose checkout is gone, instead of printing the
sequence for the reader to run. It recreates the folder empty, uninstalls each record from inside it at
that record's own scope, and removes the folder again only while it is still empty. It acts only when the
folder's parent is still on the machine, so an unmounted drive or an offline sync root stays on report,
and it never touches a `managed` record
([#3862](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3862)).

**Score:** 2

#### What makes this deploy extra special

Running `tidy-machine` now clears the dead install records a moved or deleted checkout leaves behind, in
the same run, as long as the folder's parent is still on the machine. Before this, every run handed back the same list of uninstall lines to paste by hand.
`-DryRun` still shows the sequence without running it.

**Score:** 3

#### Pull Request

tidy-machine lane 8 removes a gone checkout's install records itself

Plugins: dkj-policy

[PR #3864](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3864)

---

### DEPLOY: docs/ai-radar · 20261107-103730Z

A new root folder, [`ai-radar/`](https://github.com/DKJ-Solutions/dkj-marketplace/blob/dea5c62f4/ai-radar/README.md), keeps a running log of AI and Claude Code
news. Each entry is held against what the plugins already ship and gets a verdict: `Covered`,
`Partly`, `Gap`, `Not for us` or `To assess`. A `Gap` is filed as an issue and the entry cites it, so
the radar turns news into work on the tracker. Rebecca's lens says why this folder does not break her
rule that research lands on issues, and Sylvester's repo layout lists it.

**Score:** 2

#### What makes this deploy extra special

N/A: the folder sits outside `plugins/`, so nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

AI radar: a knowledge base of AI and Claude Code news, held against our own setup

[PR #3863](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3863)

---

### DEPLOY: feat/3859-day-plan-skill · 20261107-102517Z

A new `day-plan` skill and script in `dkj-policy`, with a test suite and Paula's day-rhythm section; nothing
existing changes behaviour. The script keeps one day file per machine under `%LOCALAPPDATA%\dkj-hub\dayplan\`,
outside any repo, and counts the work of both accounts a checkout can act and commit as.

**Score:** 3

#### What makes this deploy extra special

The owner's working day gets a beginning and an end. In the morning Paula proposes one day goal and the items
for it, each with an hour estimate and a mode (plan first, or go), and she holds the day between 6 and 8
hours: a thin day and an overfull one are both refused, and an addition during the day that does not fit is
too. Overruling her takes a reason, which comes back at the close-out. In the evening the close-out reads
GitHub, says what got done, what moves to tomorrow and what was extra, and ends with "You can close the day";
on Friday the week does the same.

**Score:** 3

#### Pull Request

Day plan skill: Paula's morning plan and day/week close-out

Plugins: dkj-policy, dkj-subagents-alpha

[PR #3861](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3861)

---

