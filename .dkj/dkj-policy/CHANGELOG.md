# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

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

