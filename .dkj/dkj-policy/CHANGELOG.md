# Changelog

## [Unreleased]

**2 / 3 minor entries** <!-- pending-tally -->

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

