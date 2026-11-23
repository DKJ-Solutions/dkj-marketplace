# Changelog

## [Unreleased]

**6 / 6 minor entries** <!-- pending-tally -->

### DEPLOY: docs/4378-one-detail-one-place · 20261123-003436Z

Ian's manual in `dkj-subagents-lifehub` gains the hard rule "one detail, one place": every detail lives
in exactly one dossier, the deepest one it is about, and a parent dossier only introduces and links to its
children (#4378).

**Score:** 2

#### What makes this deploy extra special

In a life hub, a parent dossier no longer repeats its children's amounts, dates, balances or open points.
Ian puts the detail in the child and a link in the parent, so the hub stops contradicting itself when
a child is updated and a reader no longer has to guess which copy is true.

**Score:** 3

#### Pull Request

dkj-subagents-lifehub: one detail, one place

Plugins: dkj-subagents-lifehub

[PR #4383](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4383)

---

### DEPLOY: fix/4375-branch-doc-sibling-folder · 20261120-174529Z

The branch-entry gate, in `open-pr` and in CI, refuses a branch that adds files under a folder named after
its own branch document, which the fold would leave on the trunk (#4375).

**Score:** 2

#### What makes this deploy extra special

A branch that commits review screenshots or other files beside its branch document is now stopped at
`open-pr` and by the Branch entry check, with the files named and where they belong instead (the PR or the
issue). Before, the folder slipped past every gate and stayed on the trunk after the merge until somebody
noticed it.

**Score:** 2

#### Pull Request

Branch-entry gate refuses files in a folder beside the branch document

Plugins: dkj-repo-workflow

[PR #4377](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4377)

---

### DEPLOY: fix/4374-branch-entry-live-lane · 20261120-172256Z

`adopt-workflow-folder` now reads `Get-ShopifyLiveDeployBranch` and, where it answers a plain branch name,
writes it into the branch-entry caller's trigger beside `main`; an existing caller missing it is reported
with the line to add (#4374).

**Score:** 2

#### What makes this deploy extra special

A Shopify consumer that ships hotfix PRs straight to its live branch now gets the branch-entry gate on
those PRs too. Before, a malformed DEPLOY section could land on live unjudged, flow back to the trunk and
turn fold-on-merge red on every later merge. An already-adopted repo is told the one line to change when it
re-runs Part 1 of `adopt-dkj-repo-workflow`.

**Score:** 3

#### Pull Request

Branch-entry gate also runs on PRs to the live deploy branch

Plugins: dkj-repo-workflow

[PR #4376](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4376)

---

### DEPLOY: feat/4371-dossier-wordcount · 20261120-145046Z

A new lifehub skill, `dossier-wordcount`, with one shared counter script and its test suite. Ian's
manual and agent def, and the three skills that write into a dossier, now end a dossier write with it.

**Score:** 2

#### What makes this deploy extra special

A dossier's word-count property in a life hub now follows the page: Ian, `inbox-sweep`, `ai-radar` and
`agenda` recount it after every write into a dossier, and name a page that crosses the owner's split
threshold. The property name and the threshold come from a settings page in the owner's Notion
(`Instellingen dossier-wordcount`), which the owner creates once. A recount mode catches edits made by
hand in Notion.

**Score:** 3

#### Pull Request

lifehub: keep a dossier's word count in sync after every write

Plugins: dkj-subagents-lifehub

[PR #4373](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4373)

---

### DEPLOY: feat/4366-asana-ci-scripts-load-libs · 20261120-141838Z

The three Asana CI scripts of `dkj-repo-workflow-bwj` (`asana-closed-message`, `asana-open-section`,
`asana-prio-label`) now load `asana-task-lib.ps1` and `asana-section-lib.ps1` from the pinned checkout
instead of carrying copies of their helpers, so a fix to a matcher, a block marker or the section rule
reaches the CI runs and the task scripts as one change. The workflows' `sparse-checkout` fetches
`scripts/lib` beside `scripts/ci` for that.

**Score:** 2

#### What makes this deploy extra special

A BWJ store that moves its Asana workflows' `ref:` to this release must copy the three workflow files from
the plugin's `templates/` again (keeping its `ref:` line), because the job now fetches `scripts/lib` too.
`closed-message-sessioncheck` reports each placed workflow as differing from its template until that is
done, and a workflow moved to the new `ref:` alone stops its run with a message naming exactly this.

**Score:** 4

#### Pull Request

The Asana CI scripts load the shared libs instead of carrying copies

Plugins: dkj-repo-workflow-bwj

[PR #4372](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4372)

---

### DEPLOY: feat/4369-agenda-sync-signals · 20261120-132919Z

The `agenda-sync` skill (lifehub) gets a signals step. A run now looks for two events at most 7 days apart whose titles share a distinctive word (a possible duplicate) and for same-day clashes: a single-day all-day event next to a timed one, or two timed events that overlap. Birthdays, free events and multi-day spans are left out. Each pair is put to the owner as a question at the top of the run's report, never only in a row's Notitie. It is reported once, recorded in a new `Gesignaleerd` text column. Google stays the source, so the sync never moves or removes anything because of a signal.

**Score:** 2

#### What makes this deploy extra special

A lifehub user's daily agenda run now asks about a wrong or double entry, so a mistake shows up in the run's summary instead of weeks later. The first run adds a `Gesignaleerd` column to the Agenda database.

**Score:** 3

#### Pull Request

agenda-sync reports likely duplicates and same-day clashes to the owner

Plugins: dkj-subagents-lifehub

[PR #4370](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4370)

---

