# Changelog

## [Unreleased]

**6 / 6 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4400-review-park-verify · 20261123-105151Z

`claim-issue.ps1 -Tag -Verify` now answers `[OK]` for the tag that parked an issue for review
(`-Park awaiting-review-dev` or `awaiting-review-client`), so issues-sweep step 6 can resume an
approved visible park (#4400).

**Score:** 3

#### What makes this deploy extra special

A sweep coming back to a branch the owner approved no longer gets told the work is "another session's"
and to stop. Before, every approved review park failed `-Verify`, so step 6 could not be followed as
written. This applies to parks made after the update; an issue parked earlier carries no marker yet.

**Score:** 3

#### Pull Request

issues-sweep: -Verify reads the tag a review park recorded

Plugins: dkj-repo-workflow

[PR #4411](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4411)

---

### DEPLOY: fix/4404-closing-step-answer-to-pr-box · 20261123-103551Z

`open-pr` now carries the branch document's answer to the repo's closing step into the PR body: where
that step is answered "not visible" (`- [~] <reason>`, or `- [x] ... No -- <reason>`) and the repo names
its template box with the new optional `Get-PrNotVisiblePattern` seam, that box is ticked with the reason
(#4404).

**Score:** 3

#### What makes this deploy extra special

A store repo that names its "nothing a visitor can see" box once no longer gets a red Preview check on a
change the branch already judged invisible, so it is no longer ticked by hand after the merge.

**Score:** 3

#### Pull Request

open-pr: carry the branch's 'is the change visible?' answer into the PR's not-visible box

Plugins: dkj-repo-workflow, dkj-subagents-developers

[PR #4409](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4409)

---

### DEPLOY: docs/4417-deliverable-done-check · 20261123-102338Z

The UX designer, graphic designer, long-form writer, project planner and data analyst now each have a
"What finished looks like" list in their manual, per kind of job, and check their deliverable against it
before handing it back; an item they could not meet is named as open in the handback (#4417).

**Score:** 2

#### What makes this deploy extra special

A wireframe, page, draft, plan or dashboard from one of these five specialists arrives self-checked, so
the first look at it is no longer where a missing flow, an unsourced claim or an invented deadline is
found (as with the first wireframe in #4002).

**Score:** 2

#### Pull Request

Producing specialists check their deliverable against a "what finished looks like" list

Plugins: dkj-subagents-alpha

[PR #4423](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4423)

---

### DEPLOY: fix/4403-cut-release-backflow-merges · 20261123-101305Z

`cut-release -LivePushRecord` now finds the merge commit of a branch that reached `main` through a
back-flow from the deploy branch (the hotfix lane), instead of reporting it as unknown (#4403). The
first-parent line is still read first. For an entry it misses, the cut reads the range's full merge
history once, and the live-push record decides that entry's state as for any other.

**Score:** 2

#### What makes this deploy extra special

In a Git-connected store that ships hotfixes through `live`, a cut with a live-push record no longer
warns about every hotfix-lane entry and no longer drops them from the drafted audience note. A
smartwatchbanden cut measured 19 warnings and 7 dropped entries, all re-checked by hand.

**Score:** 3

#### Pull Request

cut-release finds entry merges behind a back-flow from the deploy branch

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj, dkj-subagents-shopify

[PR #4408](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4408)

---

### DEPLOY: fix/4401-reconcile-base-crlf · 20261123-095821Z

`sync-main -ReconcileBase` now restores the trunk's blobs byte for byte: its "put the trunk content back"
commit no longer re-stages the paths through the working copy, so a file stored with CRLF in a repo with
`core.autocrlf=true` and no `.gitattributes` stops coming back as LF. The run also checks that the
branch's tree equals the trunk's before it pushes, so "changes no file" is measured rather than assumed
(#4401).

**Score:** 2

#### What makes this deploy extra special

A Shopify store's maintainer running `-ReconcileBase` on Windows no longer gets a whole-file
line-ending diff on the trunk from a branch that claims to change nothing.

**Score:** 2

#### Pull Request

sync-main -ReconcileBase: restore the trunk blobs byte-for-byte

Plugins: dkj-subagents-shopify

[PR #4407](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4407)

---

### DEPLOY: docs/4399-task-card-sourced-fields · 20261123-093601Z

Ian's manual now says that a task card's Deadline and SMART answers come from the owner or a source (a
mail, a letter, an official date) and stay empty otherwise, and `inbox-sweep` points at it (#4399).

**Score:** 2

#### What makes this deploy extra special

A life hub's task cards no longer get a deadline or a generic SMART answer the writer made up, so a card
does not land in the overdue column on a date the owner never set.

**Score:** 2

#### Pull Request

lifehub: a task card's Deadline and SMART answers come from the owner or a source

Plugins: dkj-subagents-lifehub

[PR #4406](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4406)

---

