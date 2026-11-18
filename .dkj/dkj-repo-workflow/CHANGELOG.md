# Changelog

## [Unreleased]

**5 / 6 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4315-ship-pr-cancelled-required-check · 20261118-212955Z

`ship-pr`'s CI wait no longer reads a cancelled required check as green (#4315). When the watch
ends on a required run that the concurrency group cancelled, it now waits for the run that replaced
it, the way the forward lap already did (#3331). Without that, it attempted a merge the ruleset
refused.

**Score:** 2

#### What makes this deploy extra special

A ship whose PR got a second `pull_request` run on the same head no longer ends red, with
"NOT merged, NOT folded", on a branch that was fine. It now waits for the run that counts and
merges on its answer.

**Score:** 2

#### Pull Request

ship-pr waits for the superseding run when a green watch leaves a required check cancelled

Plugins: dkj-repo-workflow

[PR #4319](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4319)

---

### DEPLOY: fix/4310-stale-park-awaiting-release · 20261118-211126Z

An issue parked as `awaiting-release` now comes back by itself on the first sweep after the release that carries what it waited on: `-Candidates` reads it as `stale-park` and prints the unpark line, the way the other waits already did. An issue parked at filing that later picked up an ordinary comment had its own parking clause silently ignored by every wait reading; that is fixed too.

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

claim-issue -Candidates reads a cleared awaiting-release as stale-park

Plugins: dkj-repo-workflow

[PR #4311](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4311)

---

### DEPLOY: feat/4320-move-data-to-onedrive · 20261118-204716Z

A new skill in the developers team, `move-data-to-onedrive`, carried by Cody: it moves app data a repo
keeps in git (every edit a branch and a PR, and public in a public repo) into
`%OneDrive%\<org>\<repo>\<data-name>\`. Its six steps were measured on one repo's move: keep a binary
store local, resolve the folder in code with an override and an in-repo fallback, point the tests at a
temp folder, remove the data from git, migrate one machine at a time, and name the trade-offs.

**Score:** 3

#### What makes this deploy extra special

A maintainer whose repo keeps editable data in git gets the procedure as a skill instead of working it out
by hand, including the two traps that cost the first move: `.env.local` splitting the dev server from
the scripts, and a test overwriting the real OneDrive data.

**Score:** 3

#### Pull Request

A move-data-to-onedrive skill in dkj-subagents-developers: app data out of git into a OneDrive folder

Plugins: dkj-subagents-developers

[PR #4321](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4321)

---

### DEPLOY: fix/4313-lint-brain-mojibake-inline-code · 20261118-203202Z

`lint-brain`'s mojibake check (category B) no longer flags a mangled sequence that a Markdown file
quotes inside an inline code span, the same reading category A gives a bare reference in backticks
(#4313). A mangled sequence elsewhere on the same line is still caught.

**Score:** 2

#### What makes this deploy extra special

A BWJ store whose release records document a mojibake repair, such as a line naming the garbled
sequence it replaced, no longer has a red lint gate on correct history. Until now the only way to
turn it green was to delete the example.

**Score:** 3

#### Pull Request

lint-brain category B skips mojibake quoted inside inline code

Plugins: dkj-repo-workflow-bwj

[PR #4316](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4316)

---

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

