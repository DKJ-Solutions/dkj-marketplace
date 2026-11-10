# Changelog

## [Unreleased]

**12 / 18 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3959-plan-goal-label-probe · 20261110-220451Z

`plan-goal -Apply` creates the `goal` label again in a repo that has none, on Windows PowerShell 5.1. The
label probe ran under the script's `Stop` preference, and 5.1 turns a native command's stderr into a
terminating error even through `2>$null`, so the 404 that means "no label yet" ended the run with
`[FAILED] gh: Not Found (HTTP 404)` and nothing filed. The probe now runs under a local `Continue` and
reads the exit code. Inbound #3959, measured in `DKJ-Solutions/dkj-recipes`.

**Score:** 2

#### What makes this deploy extra special

Planning the first goal in a repo with `plan-goal` works on the first try, without creating the `goal`
label by hand first.

**Score:** 3

#### Pull Request

plan-goal -Apply creates the goal label on PowerShell 5.1

Plugins: dkj-policy

[PR #3964](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3964)

---

### DEPLOY: fix/3958-owner-look-answers-pr-box · 20261110-214811Z

`open-pr` and `ship-pr` take `-OwnerLook "<answer>"`, the owner's recorded look at a visible result. A
repo whose PR template has a box for that look names it with the optional seam `Get-PrOwnerLookPattern`
in `scripts/repo-config.ps1`, and `open-pr` ticks that box and writes the answer after it, on a fresh PR
and on one already open. `issues-sweep-reviews` (step 4) and `issues-sweep` (step 6) now pass the
approval they recorded, with the link to the approval comment. Inbound #3958, measured on
BWJ-Development/xoxowildhearts#499: the approval reached the issue and the branch document but never the
PR, so the consumer's Preview check, which requires one ticked box, went red on every approved ship.
Without the seam nothing changes except a one-line note that the box was not written.

**Score:** 2

#### What makes this deploy extra special

A consumer whose template carries a Preview box can now ship an approved visible result without editing
the PR body by hand: define `Get-PrOwnerLookPattern` (a regex for the unticked box line) once, and every
`issues-sweep-reviews` ship answers it. Repos without such a box notice nothing.

**Score:** 3

#### Pull Request

The owner's approval answers the PR template's owner-look box

Plugins: dkj-policy, dkj-subagents-alpha

[PR #3963](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3963)

---

### DEPLOY: feat/3955-note-grid-two-columns · 20261110-120559Z

The release-notes page lays a section's note cards out two per row at most instead of three, so a card's
text gets about 22rem of line width on desktop instead of about 14rem, and a phone still gets one column
([#3955](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3955)). A consumer's page takes it at
its next `release-notes-page` run after the plugin release.

**Score:** 2

#### What makes this deploy extra special

A reader of a published release-notes page gets notes that read as paragraphs rather than five-word
columns.

**Score:** 3

#### Pull Request

Release-notes page: the note grid stops at two columns

Plugins: dkj-policy

[PR #3957](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3957)

---

### DEPLOY: feat/3954-clickable-handover-link · 20261110-104810Z

A visible result's report now gives its URL as a markdown link `[<label>](<url>)` on its own line, so the
owner can click it in the terminal: the constitution says so, and `build-handover-page.ps1` prints its one
link in that form ([#3954](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3954)). A bare URL had
reached the owner as text they could not open.

**Score:** 2

#### What makes this deploy extra special

Every handover a BWJ store session reports is now one click instead of a copy and paste.

**Score:** 2

#### Pull Request

The handover link is reported as a clickable markdown link

Plugins: bwj-development, dkj-policy

[PR #3956](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3956)

---

### DEPLOY: feat/3952-theme-prefix-seam · 20261110-081653Z

A Shopify store repo can name the themes the plugin creates after itself: answer `Get-ShopifyThemePrefix`
in `scripts/repo-config.ps1` (e.g. `'smartwatchbanden-'`), and previews and backups are named
`smartwatchbanden-main`, `smartwatchbanden-fix-x`, `smartwatchbanden-backup-<stamp>` instead of `dkj-...`
([#3952](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3952)). Unanswered, nothing changes.
After the move `dkj-` themes stay the repo's own: the sweep still spares a living branch's preview and
retires a gone one's, rotation still retires an old backup, and `push-preview` finds a branch's existing
preview instead of creating a second.

**Score:** 2

#### What makes this deploy extra special

A store maintainer sees the store's own name on its preview and backup themes instead of a vendor
label, by answering one seam, with no cleanup of the themes already there.

**Score:** 3

#### Pull Request

dkj-subagents-shopify: the reserved theme prefix becomes a per-repo seam

Plugins: dkj-subagents-shopify

[PR #3953](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3953)

---

### DEPLOY: feat/3950-trunk-preview-promote-then-cut · 20261110-073511Z

In a Shopify store whose live theme deploys from a branch of its own (`Get-ShopifyLiveDeployBranch`,
promote-then-cut), `push-preview` now pushes the trunk to a preview theme instead of refusing it
([#3950](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3950)). There the trunk runs ahead of live
between promotions, so its preview is the release candidate the owner judges before promoting. The theme
takes the reserved `<prefix><trunk>` name, which the preview sweep recognises and spares as long as the
trunk exists. Under push-then-cut the trunk stays refused, and the refusal now says why.

**Score:** 2

#### What makes this deploy extra special

A promote-then-cut store maintainer previews the release candidate with one command, where they used to
cut a throwaway branch at the trunk's commit only to get past the guard.

**Score:** 3

#### Pull Request

push-preview: allow a trunk preview where live deploys from its own branch

Plugins: bwj-development, dkj-subagents-shopify

[PR #3951](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3951)

---

### DEPLOY: feat/docs-coverage-drop-tooltips · 20261109-170127Z

Admin's Docs coverage table no longer puts a "?" beside a row's name or status. Each row's info icon opens one
popup that already holds everything those tooltips said, so the table reads as plain cells plus that one icon. The popup's Potential line, 1 to 4, is gone with it:
Impact, Tier-1 to Tier-8, is now the one measure of how much a docs page matters here. An Open page's popup puts its reasoning under one
Advice heading, starting with Adopt, Consider or Skip, rather than under "Why consider", and no longer repeats it as a row in the facts above. That block also carries the page's note, which was a
separate Note block, so what the repo has, the advice and why read as one running paragraph, under an Advice h2 of its own.
The popup's "Where it sits" and "How this repo stands" are now one Overview list.

**Score:** 2

#### What makes this deploy extra special

The Docs coverage page belongs to this repo's own Admin and ships to nobody.

**Score:** N/A

#### Pull Request

Docs coverage: drop the question-mark tooltips, the Details popup carries it all

[PR #3947](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3947)

---

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

