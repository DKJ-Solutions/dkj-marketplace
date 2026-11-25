# Changelog

## [Unreleased]

**13 / 13 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4466-ian-dossier-name-subject · 20261125-010733Z

Ian's manual gains a naming rule: a dossier is named for its subject, never for the task that opened
it.

**Score:** 2

#### What makes this deploy extra special

In a life hub, Ian now names a new or renamed dossier for what it is about (`Tool X`, not
`Replace tool X`), so the tree stops advertising work that is already done. The test is whether the
name still reads right once the dossier's status is *Done*.

**Score:** 2

#### Pull Request

Ian: a dossier name is a subject, never a task

Plugins: dkj-subagents-lifehub

[PR #4474](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4474)

---

### DEPLOY: feat/4461-correction-already-in-source · 20261125-010235Z

Fiona's and Marlowe's manuals gain a rule against double-counting a correction factor: checked against
its source before it is applied, and tied to the input it was raised for.

**Score:** 2

#### What makes this deploy extra special

In a life hub, Fiona now states per input whether a figure already contains a correction (a realised
average usually does) before she applies it, and Marlowe names which figure his "not corrected for"
applies to. A saving no longer disappears because a correction was subtracted twice.

**Score:** 2

#### Pull Request

Fiona and Marlowe: a correction factor is checked against its source before it is applied

Plugins: dkj-subagents-alpha, dkj-subagents-lifehub

[PR #4473](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4473)

---

### DEPLOY: fix/4460-preference-line-add-repo · 20261125-004840Z

The orchestrator skill's chat guidance now says a standing preference line does not make the classifier
allow attaching the marketplace repo, as measured, where `working-profile.md` said it did.

**Score:** 2

#### What makes this deploy extra special

In a claude.ai chat without a repo, Chris now tries attaching the marketplace repo once before saying
there is no connection, and asks you once after a refusal. Your preferences page no longer promises that
a "report lessons upstream" line spares you that question.

**Score:** 2

#### Pull Request

Orchestrator skill: a preference line does not make the classifier allow add_repo

Plugins: dkj-subagents-alpha

[PR #4472](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4472)

---

### DEPLOY: feat/4465-ian-app-dossier-home · 20261124-235616Z

Ian's and Onyx's manuals gain a placement rule for app dossiers: under the company overview, linked
both ways with the subject they serve.

**Score:** 2

#### What makes this deploy extra special

In a life hub, Ian now files every app or repository the owner builds under the company overview, even
one that serves a subject such as music or cooking. Onyx links the subject and the app both ways, so
the list of the owner's apps sits in one place.

**Score:** 2

#### Pull Request

Ian files an app's dossier under the company repos overview

Plugins: dkj-subagents-lifehub

[PR #4471](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4471)

---

### DEPLOY: feat/4464-ian-siblings-one-kind · 20261124-234146Z

Ian's manual gains a rule that dossiers under one parent are of one kind and mutually exclusive.

**Score:** 2

#### What makes this deploy extra special

In a life hub, Ian now checks that a new dossier matches its siblings' kind before placing it. Where
it does not, he finds the right group or adds a layer that names the kind, so a catch-all page such as
"Ecosystem" or "Other" no longer has to be spotted by eye.

**Score:** 3

#### Pull Request

Ian: siblings under one parent are of one kind

Plugins: dkj-subagents-lifehub

[PR #4470](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4470)

---

### DEPLOY: feat/4463-ai-radar-topic-pages · 20261124-232732Z

The `ai-radar` skill now describes the AI dossier's child pages by topic, at any depth, instead of one
page per model family.

**Score:** 2

#### What makes this deploy extra special

An `ai-radar` run now places each item on the page of the topic it is about, as the hub's settings page
lists those pages, including a page nested under a Products layer. An agent-building article from the
vendor's blog lands on the agent-patterns page instead of a catch-all ecosystem page.

**Score:** 2

#### Pull Request

ai-radar: place an item on the AI dossier's page for its topic

Plugins: dkj-subagents-lifehub

[PR #4469](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4469)

---

### DEPLOY: feat/4462-ian-one-home-per-topic · 20261124-231438Z

Ian's and Onyx's manuals gain the one-home-per-topic rule for dossier trees.

**Score:** 2

#### What makes this deploy extra special

In a life hub, Ian now files a dossier under the topic it is about, not under the life area it
touches. An employer's salary goes under that employer, and the income overview links to it. Where the
hub keeps a category, it follows from the path, so the tree and the category can no longer disagree.

**Score:** 3

#### Pull Request

Ian files a dossier under its topic, not under a life area

Plugins: dkj-subagents-lifehub

[PR #4467](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4467)

---

### DEPLOY: docs/4458-ian-consult-first-procedure · 20261124-151113Z

Ian's manual now states how to consult a hub before writing a fact: walk the dossier tree, query the
updates store by relation, then write. It also notes that the Notion API search matches titles only.

**Score:** 2

#### What makes this deploy extra special

In a life hub on Notion, Ian and the skills that place facts (`inbox-sweep`, `agenda`, `ai-radar`) now
check the target dossier, its parent and its children, and the updates linked to them, before writing a
fact. An empty title search no longer counts as proof that the fact is new, so the same fact stops
landing twice on two dossiers with different dates.

**Score:** 3

#### Pull Request

Ian's consult-first rule gets a procedure

Plugins: dkj-subagents-lifehub

[PR #4459](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4459)

---

### DEPLOY: fix/4451-profile-chat-home · 20261124-131249Z

The working-profile page and the orchestrator skill now name where a profile lives in a claude.ai or
desktop chat: the account's personal preferences.

**Score:** 2

#### What makes this deploy extra special

If you run Chris in a claude.ai or desktop chat, the page now says what your personal preferences should
hold: the line that loads the orchestrator skill, standing instructions, and a short working profile.
They should never hold a pasted copy of the persona or manual. Such a copy drifts from every release and
loads roughly 10,000 words into every chat.

**Score:** 2

#### Pull Request

Working profile: name its home for claude.ai and desktop chat sessions

Plugins: dkj-subagents-alpha

[PR #4456](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4456)

---

### DEPLOY: fix/4450-orchestrator-attach-refusal · 20261124-124932Z

The orchestrator skill now says that in a session with no repo, attaching the source repo can be refused
until the owner asks for it, and that the session then asks once instead of retrying or dropping the
finding.

**Score:** 2

#### What makes this deploy extra special

In a claude.ai chat running the orchestrator skill, a refused `add_repo` no longer reads as a ban on
filing upstream: the session asks you once to approve the connection. A line in your preferences such as
"report lessons upstream to DKJ-Solutions/dkj-marketplace" is named as the standing request, but nobody has
yet measured whether the classifier accepts that line on its own.

**Score:** 2

#### Pull Request

Orchestrator skill: name the add_repo refusal in a no-repo session and what to do next

Plugins: dkj-subagents-alpha

[PR #4454](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4454)

---

### DEPLOY: fix/4449-refused-head-skips-picker · 20261124-124420Z

The merge-on-green sweep no longer re-picks a pull request `ship-pr` refused: the runner marks the
refused head, the picker skips it, and the next armed pull request gets its turn. The session check
names the pull request that holds the queue when a refusal could not be recorded.

**Score:** 3

#### What makes this deploy extra special

A repo running merge-on-green no longer has one refused pull request silently hold back every newer armed
one. An existing `merge-on-green.yml` is not rewritten: `adopt-ci-floor` now prints a `[refusal]` line
for a runner without the new step, and re-running it with `-Apply` after deleting the file places it.
The step labels and comments with `FOLD_PUSH_TOKEN`, which already holds `Pull requests: write`. To
re-arm a refused pull request by hand, remove its `merge-on-green-refused` label.

**Score:** 3

#### Pull Request

Skip a refused head in the merge-on-green picker so it cannot starve the queue

Plugins: dkj-repo-workflow

[PR #4455](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4455)

---

### DEPLOY: fix/4448-probe-failure-diagnosis · 20261124-122446Z

`ship-pr` no longer waits out its whole CI budget when `gh` cannot read the PR's checks: after three
failed reads in a row it stops, prints gh's own error and exit code, and says to check the token's
permissions. Its timeout refusal claims other checks registered only when one was actually seen (#4448).

**Score:** 2

#### What makes this deploy extra special

A token that cannot read checks used to cost a run its whole wait and then blame the ruleset; the real
cause is now on screen within about 45 seconds.

**Score:** 2

#### Pull Request

Wait-CheckRegistration surfaces a failing gh pr checks probe instead of blaming the ruleset

Plugins: dkj-repo-workflow

[PR #4453](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4453)

---

### DEPLOY: fix/4447-fold-push-token-read-scopes · 20261124-120704Z

The adopt skill and its Part 3 scaffold now say that `FOLD_PUSH_TOKEN` needs four read scopes on the
merge-on-green path, which the docs had left out.

**Score:** 2

#### What makes this deploy extra special

A private repo running merge-on-green whose sweep refuses a green pull request after 1800s with "never
registered" now finds the cause in the adopt skill: add `Checks`, `Commit statuses`, `Actions` and
`Issues` (Read-only) to `FOLD_PUSH_TOKEN`. An existing runner is not rewritten; the fix is on the token.

**Score:** 3

#### Pull Request

Name the read scopes FOLD_PUSH_TOKEN needs on merge-on-green's ship path

Plugins: dkj-repo-workflow

[PR #4452](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4452)

---

