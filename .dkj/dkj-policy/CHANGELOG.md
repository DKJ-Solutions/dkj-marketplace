# Changelog

## [Unreleased]

**0 / 2 patch entries** <!-- pending-tally -->

### DEPLOY: feat/docs-coverage-potential · 20261109-134441Z

Admin's Docs coverage page now scores every Not used docs page from 1 to 4 for how much value it could have
in this repo, in the status "?" popup beside the advice. The score is estimated apart from the advice, so a
Skip can still score 2 where its cost decided it rather than its value. The page's status filter now keeps
its last choice across a reload.

**Score:** 2

#### What makes this deploy extra special

N/A: the page is this repo's own Admin page, and no consumer takes it.

**Score:** N/A

#### Pull Request

Docs coverage: a potential score for every Not used docs page, and the status filter remembered

[PR #3934](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3934)

---

### DEPLOY: fix/3932-get-raw-says-why · 20261109-124804Z

When a group-3 page assert in the consumer-dashboard suite fails, it now also prints what the request
got: the status line and how long it took, or the exception and how long until it was thrown. The next
CI recurrence can then say whether the page was slow or wrong.

**Score:** 1

#### What makes this deploy extra special

N/A: a test suite of this repo, which no consumer runs.

**Score:** N/A

#### Pull Request

consumer-dashboard tests: a failing page assert says whether the page was slow or wrong

[PR #3933](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3933)

---

