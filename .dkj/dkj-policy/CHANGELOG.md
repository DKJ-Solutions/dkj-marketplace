# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

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

