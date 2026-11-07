# Changelog

## [Unreleased]

**7 / 7 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3888-branchinfo-self-contained · 20261107-203949Z

The config blueprint's `Get-BranchInfo` record runs on its own. Its text called `Get-BranchPrefix`, which no
contract record carries, so a consumer with a hand-built `branch-info.ps1` that adopted the record (a `copy`
record since #3886) got a `Get-BranchInfo` that threw (#3888). The function now derives the prefix inline,
`check-script-contract` evaluates the records without the stub it carried for this, and
`config-blueprint.tests.ps1` evaluates the branch-info records from their own text.

**Score:** 2

#### What makes this deploy extra special

A repo whose `branch-info.ps1` was written by hand can adopt `Get-BranchInfo` from the blueprint without it
failing on first use. A repo set up by `specialists-init` already had `Get-BranchPrefix` and notices nothing.

**Score:** 2

#### Pull Request

Get-BranchInfo's blueprint text no longer calls Get-BranchPrefix, which the blueprint does not carry

Plugins: dkj-policy

[PR #3894](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3894)

---

### DEPLOY: feat/3882-triage-labels-sessioncheck · 20261107-194141Z

A new session check, `triage-labels-sessioncheck`, says in one line when this repo's tracker lacks any of the
canonical triage labels or carries one in a non-canonical colour, and names `adopt-triage-labels` as the
command that prints the fix. Until now nothing said so before a sweep's `gh issue edit --add-label` failed
(#3882). It runs `adopt-triage-labels.ps1` in-process with its `gh` reads bounded to 15 seconds, stays silent
when the labels are complete or the tracker cannot be read, and creates nothing, so #1895's print-only answer
stands. `adopt-triage-labels.ps1` leaves the source-repo guard as a hook-invoked script.

**Score:** 3

#### What makes this deploy extra special

A consumer whose tracker is missing triage labels is told at session start, with the one command that prints
every `gh label create`, instead of discovering it when a sweep fails to park an issue.

**Score:** 3

#### Pull Request

A session-start line when the tracker lacks the canonical triage labels

Plugins: dkj-policy

[PR #3893](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3893)

---

### DEPLOY: feat/3886-prescribed-branch-prefixes · 20261107-193225Z

Every DKJ repo now uses the source's branch prefixes: `feat/` earns `feature`, `fix/` earns `bug`, `docs/`
earns no label, and `chore/` is refused. The three `branch-info.ps1` records are `copy` instead of
`decide`, and the script-contract session check reports a repo whose table differs, with the repair. It
runs at every session start, so a repo with its own prefixes now sees one `[ERROR]` line until it adopts
the shared table. In this repo nothing changes: its table already is the source's.

**Score:** 3

#### What makes this deploy extra special

If your `scripts/lib/branch-info.ps1` keeps its own prefixes (`data/`, `dossier/`, `chore/` and so on) or
labels `docs/` as `documentation`, the session check now fails with a line naming the difference. Replace
the table and the `Get-BranchInfo`, `Test-BranchName` and `Get-BranchTypes` functions with the text of
those three records in the plugin's `blueprint/config-blueprint.json` (`adopt-config` will not overwrite a
function you already have, and the blueprint's `Get-BranchInfo` calls `Get-BranchPrefix`, which it does not
carry, so keep yours: [#3888](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3888)). Fold any pending changelog entry under a type the shared table does not have
first, because the shared table produces only Feat, Fix, Docs and Chore. The cost is accepted: release
notes no longer group by a domain type.

**Score:** 3

#### Pull Request

Every DKJ repo uses the source's branch prefixes

Plugins: bwj-development, dkj-policy, dkj-subagents-shopify

[PR #3892](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3892)

---

### DEPLOY: fix/3885-repoint-skips-comments · 20261107-192235Z

When `adopt-workflow-folder -Apply` moves `dkj-policy/` to `.dkj/dkj-policy/`, it now repoints quoted paths
in `scripts/repo-config.ps1` only on code lines. A quoted path inside a `#` comment or a `<# ... #>` block
is left as written, and the run lists those as `[kept]`. Before this, the move rewrote history comments too,
so a comment recording an earlier seam value then claimed a value that was never set (#3885).

**Score:** 2

#### What makes this deploy extra special

A consumer still to move keeps its `repo-config.ps1` comments true, and no longer has to undo the rewrite
by hand the way dkj-lifehub did.

**Score:** 1

#### Pull Request

adopt-workflow-folder leaves comments in repo-config.ps1 alone on the move

Plugins: dkj-policy

[PR #3891](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3891)

---

### DEPLOY: fix/3883-retired-constitution-import · 20261107-191022Z

`adopt-workflow-folder` now rewrites a constitution import that still names the retired
`dkj-claude-plugins` marketplace, the same way it already rewrote a retired extension import beside it.
Before, the dry run said `[keep]` and the repo silently loaded no constitution (#3883).

**Score:** 2

#### What makes this deploy extra special

A consumer that adopted before the `dkj-marketplace` rename gets its constitution back on the next
`adopt-workflow-folder -Apply`, and the session check now warns about the dead line until then.

**Score:** 2

#### Pull Request

adopt-workflow-folder rewrites a constitution import on the retired marketplace path

Plugins: bwj-development, dkj-policy

[PR #3890](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3890)

---

### DEPLOY: fix/3884-pr-template-folder-repoint · 20261107-190003Z

`adopt-workflow-folder -Apply` now also repoints the folder in the first-line comment of an existing
`.github/pull_request_template.md` when it moves `dkj-policy/` to `.dkj/dkj-policy/`. Before this, the
comment kept naming `dkj-policy/<branch>.md` after the move, because the scaffold never overwrites a
template that is already there (#3884). The rest of a hand-edited template is left alone, and the dry
run names the repoint like the other two.

**Score:** 2

#### What makes this deploy extra special

A consumer that runs the move on this release gets a PR template naming the folder its branch documents
actually live in. Six consumers that moved on v6.10.0 fixed the comment by hand or still carry the old one.

**Score:** 2

#### Pull Request

adopt-workflow-folder repoints the PR template's folder comment on the move

Plugins: dkj-policy

[PR #3889](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3889)

---

### DEPLOY: fix/3881-legacy-names-empty-entry · 20261107-184258Z

`new-branch` writes the branch document again in a repo that has not moved to `.dkj/dkj-policy/` yet. There
`Get-BranchFileLegacyNames` returned an empty row (`PolicyFolderPerBranch` is `''` by design in an unmoved
repo), and `new-branch.ps1` binds that list to a Mandatory `[string[]] -Legacy`, which refuses an empty
element: the branch was created and the run died before its document (#3881). The list now drops empty rows
at its one source, and `branch-document-path.tests.ps1` pins it against an unmoved fixture.

**Score:** 3

#### What makes this deploy extra special

A consumer still on the root `dkj-policy/` folder could not start a branch through `new-branch` on v6.10.0:
the branch appeared and its document did not. After this release it works without moving the folder first.

**Score:** 4

#### Pull Request

new-branch fails in an unmoved consumer: empty string in the -Legacy list

Plugins: dkj-policy

[PR #3887](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3887)

---

