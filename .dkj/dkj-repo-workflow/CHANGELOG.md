# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4314-lint-script-rooted-path · 20261118-201748Z

A repo's `Get-LintScript` may now return a rooted path. `open-pr`, `ship-pr`, `cut-release` and
`live-preflight` use it as it is instead of joining it onto the repo root, and the lint gate starts that
script in the repo root. This is what lets a store point its gate at the plugin's own `lint-brain.ps1`
(through `Resolve-PluginScript`) and drop the forwarder it kept only so the gate had a repo-relative
file to name. A repo-relative answer behaves exactly as before.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a store repo running the BWJ extension: one forwarder file fewer, and the
`dkj-repo-workflow-bwj` README now shows the three-line `Get-LintScript` that replaces it. Every other
consumer is unaffected.

**Score:** 2

#### Pull Request

Get-LintScript may name a rooted path, so a store points its lint gate at the plugin's lint-brain

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj, dkj-subagents-shopify

[PR #4318](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4318)

---

### DEPLOY: fix/4312-lint-brain-dot-record-root · 20261118-200346Z

The shared `lint-brain` (`dkj-repo-workflow-bwj`) no longer strips the leading dot of a record-root
seam, so frozen release records under `.dkj/` are exempt again, as its header promises (#4312). A suite
case with a dot-folder root pins it; every earlier fixture used `docs/workflow/`, which is why it slipped.

**Score:** 2

#### What makes this deploy extra special

A BWJ store that points its lint gate at the plugin's `lint-brain` no longer goes red on its own frozen
release history under `.dkj/dkj-repo-workflow/releases/`, so its `open-pr`/`ship-pr` lint gate passes
without `-SkipLint`.

**Score:** 3

#### Pull Request

lint-brain keeps the dot of a dot-folder record root

Plugins: dkj-repo-workflow-bwj

[PR #4317](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4317)

---

