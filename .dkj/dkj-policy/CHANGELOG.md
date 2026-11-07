# Changelog

## [Unreleased]

**4 / 4 minor entries** <!-- pending-tally -->

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

