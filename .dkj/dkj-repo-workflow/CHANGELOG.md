# Changelog

## [Unreleased]

**11 / 11 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4497-task-card-short-note · 20261125-125025Z

A task card's short text property now holds one line, what the owner has to do, and its facts, source
lines and URLs go in the card's page body. The rule is in Ian's manual for every card writer, and
`inbox-sweep` step 3.3 applies it to a card the sweep fills (#4497).

**Score:** 2

#### What makes this deploy extra special

A lifehub owner whose inbox sweep files action cards gets a board that reads as one line per card,
instead of a short note that grows a paragraph with raw mail URLs on every follow-up mail.

**Score:** 3

#### Pull Request

inbox-sweep and Ian: a task card's short note holds one line, the facts go in its page body

Plugins: dkj-subagents-lifehub

[PR #4498](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4498)

---

### DEPLOY: fix/4481-wordcount-install-pwsh · 20261125-115004Z

`dossier-wordcount` now says what a session with a shell but no PowerShell does: install `pwsh` and run
the one counter, rather than rebuilding it in another language, so the word count means the same whoever
wrote last (#4481).

**Score:** 1

#### What makes this deploy extra special

A lifehub owner whose dossiers are written from a cloud session gets counts from the same counter as on
their own machine, instead of a per-session rebuild that can drift.

**Score:** 2

#### Pull Request

dossier-wordcount: install pwsh in a shell without PowerShell

Plugins: dkj-subagents-lifehub

[PR #4495](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4495)

---

### DEPLOY: feat/4477-asana-origin-guard · 20261125-113930Z

A new PreToolUse hook, `guard-asana-origin`, refuses a `gh issue create` on a store repo whose body names
a requester or quotes a task but links no Asana task, and `report-issue` step 1 now searches the board for
the colleague's task before filing. The line `<!-- no-asana-task -->` records a search that found none.

**Score:** 3

#### What makes this deploy extra special

A colleague's request passed on in chat is now filed as the issue for their own Asana task, so the card
moves to Filed, gets its created: comment, and the requester hears about it when the work ships. Before,
such an issue was filed unlinked and the colleague's card sat untouched in their inbox.

**Score:** 3

#### Pull Request

Refuse a store issue that names a colleague's request but links no Asana task

Plugins: dkj-repo-workflow-bwj

[PR #4496](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4496)

---

### DEPLOY: fix/4483-inbox-sweep-order-default · 20261125-112954Z

`inbox-sweep` no longer contradicts its own step 0: the processing order is a default the owner's
settings can override, instead of a fixed rule the session has to weigh against the hub's conventions
(#4483).

**Score:** 1

#### What makes this deploy extra special

A lifehub owner whose conventions order work newest first now gets that order from the inbox sweep
without the session having to decide which rule wins. Add an **order** row to the settings page to set it.

**Score:** 2

#### Pull Request

inbox-sweep: oldest first is a default, the owner's settings decide the order

Plugins: dkj-subagents-lifehub

[PR #4494](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4494)

---

### DEPLOY: fix/4485-windows-only-gates-skip · 20261125-111106Z

In a Linux session, such as a Claude Code cloud session, `check-roster-sync` and `check-plugin-integrity`
now print a `[SKIP]` line naming CI's Windows leg as authoritative. Before, one crashed and the other
reported over a thousand findings caused by the platform.

**Score:** 2

#### What makes this deploy extra special

A consumer's cloud session that runs `check-roster-sync` from `dkj-subagents-developers` gets a clear
skip in place of a crash.

**Score:** 1

#### Pull Request

Two of the four stand-verification gates cannot run in a Linux cloud session

Plugins: dkj-subagents-developers

[PR #4493](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4493)

---

### DEPLOY: fix/4484-rest-search-is-issue · 20261125-105734Z

The REST search a session uses to look for a duplicate before filing, where GraphQL is refused, now
includes `is:issue`. It no longer fails with a 422 in a cloud session, and it no longer counts pull
requests as duplicates.

**Score:** 1

#### What makes this deploy extra special

A session in a Claude Code cloud environment can search the tracker before filing, where the old form
failed on every query.

**Score:** 2

#### Pull Request

orchestrator skill's REST search form fails with 422 -- search/issues needs is:issue

Plugins: dkj-subagents-alpha

[PR #4492](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4492)

---

### DEPLOY: fix/4482-inbox-sweep-gmail-address · 20261125-105308Z

An inbox sweep now recognises the owner's private Gmail account whichever way the address is spelled
(with or without dots, with a `+tag`, or under `googlemail.com`), so the settings page needs only one
spelling and the sweep no longer stops wrongly or skips the owner's own mail.

**Score:** 1

#### What makes this deploy extra special

The owner running `/inbox-sweep` notices it the first time mail arrives at a second spelling of their
address: the sweep processes it instead of stopping.

**Score:** 3

#### Pull Request

inbox-sweep compares the recipient address literally, but Gmail ignores dots in the local part

Plugins: dkj-subagents-lifehub

[PR #4491](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4491)

---

### DEPLOY: fix/4479-fold-standdown-retry · 20261125-104848Z

When ship-pr pushed its own `fold:` commit right after a merge, the fold-on-merge runner for that merge
stood down and left every other pending entry on the trunk unfolded, while reporting green. The runner
now catches up with the moved trunk and folds what is still there, and fails red if it cannot.

**Score:** 3

#### What makes this deploy extra special

Repos that take the CI floor get the fix the next time `adopt-ci-floor` places or refreshes their fold
runner. Until then, leftover changelog entries can still pile up after a ship and need folding by hand.

**Score:** 2

#### Pull Request

fold-on-merge retries a stood-down fold on the moved trunk instead of counting on a run a fold-only push never starts

Plugins: dkj-repo-workflow

[PR #4490](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4490)

---

### DEPLOY: fix/4478-session-closes-asana-issue · 20261125-103612Z

After a `-NoResolves` merge of an Asana-linked issue, the docs and the resolves-gate refusal now say that
the shipping session closes the issue, not the task's assignee.

**Score:** 2

#### What makes this deploy extra special

A store's session no longer hands the close of an Asana-linked issue to the owner after the merge. It
closes the issue itself with the `gh issue close` line the refusal now prints. A store already on the old
`Get-ResolvesExemptMatchers` answer keeps the old refusal text until it copies the new template from
`adopt-dkj-repo-workflow-bwj`.

**Score:** 2

#### Pull Request

The shipping session, not the task's assignee, closes an Asana-linked issue after a -NoResolves merge

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj

[PR #4489](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4489)

---

### DEPLOY: fix/4480-closed-issue-asana-link · 20261125-102352Z

When a session links an Asana task to a GitHub issue that is already closed, the task now gets its
closed message, with the go-live block and the move into review, exactly as if it had been linked before
the close. It no longer gets a "now in progress" comment, and its card no longer moves backwards. To take
the change, a store re-places its `asana-closed-message` workflow from the template;
`closed-message-sessioncheck` reports the old copy as differing.

**Score:** 2

#### What makes this deploy extra special

A colleague waiting on an Asana card for a request that is already done hears that it is done, instead of
reading that work has started on it.

**Score:** 2

#### Pull Request

report-issue links an already-closed issue as 'now in progress', so asana-closed-message never posts

Plugins: dkj-repo-workflow-bwj

[PR #4488](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4488)

---

### DEPLOY: fix/4476-entry-gate-live-sessioncheck · 20261125-100129Z

A new session check, `entry-gate-live-sessioncheck`, warns when the branch-entry CI caller leaves out the
live deploy branch that `scripts/repo-config.ps1` declares, and prints the `branches:` line to use instead.

**Score:** 2

#### What makes this deploy extra special

A Shopify store adopted before the live branch joined the branch-entry caller now hears about it at every
session start, with the exact line to change. Before, hotfix PRs to the live branch landed malformed
changelog entries unjudged and turned the fold red, and nothing said why until someone re-ran adoption.

**Score:** 3

#### Pull Request

Session check reports a branch-entry caller that leaves out the live deploy branch

Plugins: dkj-repo-workflow

[PR #4486](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4486)

---

