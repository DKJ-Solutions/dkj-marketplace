# Changelog

## [Unreleased]

**1 / 3 minor entries** <!-- pending-tally -->

### DEPLOY: feat/explain-tooltip-readability · 20261109-135046Z

Every explaining "?" tooltip in the brand book reads easier: body-size text at about eight words a line,
a looser line height, and more air around the title and between paragraphs.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that vendors the brand book gets the more readable explaining tooltip once it takes the
next release's copy; nothing in its markup changes.

**Score:** 2

#### Pull Request

Explaining tooltips: about eight words a line, body-size text and more spacing

Plugins: dkj-policy

[PR #3936](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3936)

---

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

