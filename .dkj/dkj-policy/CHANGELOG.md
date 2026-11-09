# Changelog

## [Unreleased]

**6 / 11 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3945-close-when-pr-lands · 20261109-164811Z

In a BWJ store, an Asana-linked issue closes when its pull request lands, always
([#3945](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3945)). "Open until live" is not a state:
`notify-live` tells the task once the release is live. The ticket chapter now says so in its own words. The
`closed-message-sessioncheck` session check reports any Asana-linked issue still open within 14 days after
the `-NoResolves` pull request named for it merged. It stays quiet where an open pull request's branch is named
after the same issue, because a further step is still changing code. Measured on smartwatchbanden#1126, whose
pull request merged while the session kept the issue open for the live push.

**Score:** 2

#### What makes this deploy extra special

A store maintainer now sees a session-start error line for an Asana-linked issue left open after its merge,
where nothing said anything before. It names the issue, the pull request, and the two steps that end it: the
go-live block and the close.

**Score:** 3

#### Pull Request

bwj-development: an Asana-linked issue closes when its -NoResolves PR lands

Plugins: bwj-development

[PR #3949](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3949)

---

### DEPLOY: fix/3944-noresolves-cites-branch-issue · 20261109-163848Z

`open-pr -NoResolves` now cites the issue the branch name carries as a visible `Part of #<n>` line in the
PR body, unless the body already mentions it. Before, it wrote only the `closes nothing` marker, so a branch
whose document never named its own issue merged without any link to it (#3944).

**Score:** 2

#### What makes this deploy extra special

In a BWJ store repo, an Asana-linked issue ships with `-NoResolves`, and `build-golive-block.ps1 -Post`
refused afterwards because no pull request closed or referenced the issue. The way past was a hand edit of
the merged PR's body or `-Force`. The PR now references the issue on its own, so `-Post` finds it.

**Score:** 3

#### Pull Request

open-pr -NoResolves cites the branch's issue as 'Part of #<n>'

Plugins: dkj-policy

[PR #3948](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3948)

---

### DEPLOY: fix/3941-audience-note-named-issues · 20261109-162740Z

The release cut's audience note now finds an entry's task through the issues its PR **names** as well as
the ones it closes, the same set `notify-live` reads (#3941). At BWJ-Development/smartwatchbanden's
v2.51.0 cut five storefront entries were left out as "no issue it closed is linked to a task" because
their PRs named the issue without closing it, and `notify-live` then told three of those tasks the release
was live. The rule is now one file, `pull-issue-lib.ps1`, shared by both plugins. A named issue counts
only once it has closed as completed, and one that has not is named in the hint instead of read as having
no task.

**Score:** 3

#### What makes this deploy extra special

A repo that ships its Asana-linked issues with `-NoResolves` gets a cut's audience note with those tasks
linked, instead of adding the links by hand after the draft.

**Score:** 3

#### Pull Request

cut-release's audience note reads the issues a PR names, not only the ones it closes

Plugins: bwj-development, dkj-policy

[PR #3946](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3946)

---

### DEPLOY: feat/3935-bwj-development-under-dkj · 20261109-154705Z

bwj-development's sync log now lives at `.dkj/bwj-development/SYNC-LOG.md`, beside `.dkj/dkj-policy/`,
instead of in the consumer's root: the pages, the `Get-ShopifySyncLogPath` example answer and the
adopt step all name the new place, and the adopt step moves an older root `bwj-development/` there
(#3935). No script reads a fixed path, so a repo whose seam still answers the old path keeps working
until it moves.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a BWJ store repo that still keeps a root `bwj-development/` sees the adopt step
propose the move; nothing breaks if they leave it.

**Score:** 2

#### Pull Request

bwj-development's sync-log folder moves under .dkj/bwj-development/

Plugins: bwj-development, dkj-subagents-shopify

[PR #3943](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3943)

---

### DEPLOY: feat/docs-coverage-github-colours · 20261109-153435Z

The Docs coverage page colours its statuses the way GitHub colours an issue. Open is green, because there is
still something to gain there, and a catalogue page this repo does not use yet is now Open too, under the same
word and dot as an open issue. Covered is purple, done and needing no more attention. Declined and Not relevant
are grey, a paper step apart. The brand book gains the status token `--done-3` for that purple, in light and dark.

**Score:** 2

#### What makes this deploy extra special

N/A: an Admin page of this repo and one new token nothing outside it reads yet.

**Score:** N/A

#### Pull Request

Docs coverage status colours the GitHub way

Plugins: dkj-policy

[PR #3942](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3942)

---

### DEPLOY: feat/docs-coverage-impact · 20261109-151956Z

Admin's Docs coverage page has a new Impact column after Status: how important each feature is to this repo,
from Tier-1 to Tier-8, the higher the more important. A Not relevant docs page reads N/A. The column sorts by
tier, with N/A last, and each row's Details popup names its impact too.

**Score:** 2

#### What makes this deploy extra special

N/A: the page is this repo's own Admin page, and no consumer takes it.

**Score:** N/A

#### Pull Request

Docs coverage: an Impact column, Tier-1 to Tier-8

[PR #3939](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3939)

---

### DEPLOY: feat/3937-fit-alarm-modal-h1 · 20261109-150742Z

A popup opened as a modal dialog may now open on its own h1: the page shell's fit alarm no longer counts an h1
inside an open modal as the page's second, so the Docs coverage row popup stops raising "2 h1 on this page".
The brand book's one-h1 rule says so too.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that renders its pages with the shared page shell can give a modal popup its own h1
without the fit alarm firing, once it takes the next release.

**Score:** 1

#### Pull Request

The fit alarm leaves a modal popup's own h1 out of the page count

Plugins: dkj-policy

[PR #3940](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3940)

---

### DEPLOY: feat/docs-coverage-row-detail · 20261109-143855Z

/docs-coverage has a Details column: an info icon on every row opens a popup that gathers everything known about
that row in one place, in headings: the row's name as the h1, then where it sits in the docs, how this repo stands
to it (status, issue, potential, advice, note, evidence) and, for an item, the idea and the docs check, so it
reads without hovering the "?" marks.

**Score:** 2

#### What makes this deploy extra special

N/A: the Docs coverage page is this repo's own product page and ships to no consumer.

**Score:** N/A

#### Pull Request

Docs coverage: a details column whose icon opens a popup per row

[PR #3938](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3938)

---

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

