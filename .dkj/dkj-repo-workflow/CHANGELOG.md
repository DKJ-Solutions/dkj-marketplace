# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

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

