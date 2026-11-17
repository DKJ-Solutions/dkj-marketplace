# Changelog

## [Unreleased]

**7 / 7 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4252-refresh-stale-statusline-shim · 20261117-233935Z

`adopt-statusline.ps1 -Apply` now replaces a progress-bar shim it placed before v7.0.0 (#4252). That shim
looked for the old `dkj-policy` plugin id, so after the rename the progress bar went dark, and a re-run
left the stale shim in place. A file at that path that this command did not place is still left alone,
with the line that repairs it.

**Score:** 3

#### What makes this deploy extra special

A consumer whose progress bar went dark after 7.0.0 gets it back by re-running `adopt-statusline.ps1 -Apply`,
without deleting the file by hand first.

**Score:** 3

#### Pull Request

adopt-statusline refreshes a plugin-placed shim that differs from the current template

Plugins: dkj-repo-workflow

[PR #4261](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4261)

---

### DEPLOY: fix/4251-part1-move-beside-branch-docs · 20261117-225213Z

Part 1 of adopting the workflow now moves the old `.dkj/dkj-policy/` folder when the migration branch's own
document already sits in `.dkj/dkj-repo-workflow/` (#4251). Before, it skipped the move and stopped on the
seam check, so the 7.0.0 steps failed in the order the release note gives them. Its dry run no longer
fails on the repos it exists for, and the branch document's line naming the folder links resolve from is
repointed too.

**Score:** 4

#### What makes this deploy extra special

A maintainer migrating to 7.0.0 can follow the note in order (branch first, then Part 1) without moving
their branch document aside by hand.

**Score:** 4

#### Pull Request

Part 1 moves .dkj/dkj-policy/ even when new-branch already created .dkj/dkj-repo-workflow/

Plugins: dkj-repo-workflow

[PR #4260](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4260)

---

### DEPLOY: fix/4248-candidates-default-skiplabel · 20261117-202420Z

`claim-issue -Candidates` skips parked issues again when no `-SkipLabel` is passed, which is how the `issues-sweep` skill has run it since #4233. In v7.0.0 every parked issue read `free`, and a cleared wait never showed as `stale-park`. The claim's own parking check was the only backstop.

**Score:** 4

#### What makes this deploy extra special

A consumer running `issues-sweep` on v7.0.0 sees every parked issue offered as `free`, and the claim then refuses it. After this release, parked issues are skipped again and cleared waits print as `stale-park`.

**Score:** 3

#### Pull Request

claim-issue -Candidates applies the default parking-label list

Plugins: dkj-repo-workflow

[PR #4250](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4250)

---

### DEPLOY: fix/4246-pin-house-style-caller · 20261117-201426Z

The house-style caller in the `dkj-brandbook` skill is now pinned to the release a repo adopted:
`reusable-house-style.yml@vX.Y.Z` plus `scripts-ref: vX.Y.Z`. #4237 had already pinned the branch-entry,
always-on and repo-settings runners this way (#4246). Before this, a script moved on `main` before a
release turned that gate red in every consumer. The release cut writes both tags beside the checksum
table's tag. To make that possible, a `Get-ReleaseVersionPins` entry takes an optional `Refs` list: the
cut repoints the bare tag after each prefix, and refuses to cut when a prefix has gone missing from the
file.

**Score:** 2

#### What makes this deploy extra special

For the maintainer of a DKJ-Solutions repo with a UI: the brand-book CI gate the skill hands you no
longer goes red when the source moves a script on `main`. It moves when you take a new brand-book
copy. A caller already on `@main` keeps working as before. Copy the new snippet to pin it.

**Score:** 2

#### Pull Request

Pin the house-style caller the dkj-brandbook skill gives to the release, as #4237 pinned the other read-only gates

Plugins: dkj-repo-workflow, dkj-repo-workflow-dkj

[PR #4249](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4249)

---

### DEPLOY: fix/4237-pin-read-only-runners · 20261117-173035Z

Both adoption scaffolders now pin every CI runner they place to the dkj-repo-workflow release they came
from (#4237). The branch-entry and always-on-budget callers from `adopt-workflow-folder` call
`@vX.Y.Z` and pass `scripts-ref: vX.Y.Z`. The repo-settings runner from `adopt-ci-floor` fetches the
shared scripts at the same release, as the write runners have since #2333. This reverses #1805's
choice to keep the read-only runners on main. The #4209 rename moved every script path on main a day
before any release carried it, and every consumer runner on `ref: main` went red at once. Internally,
the register's check 6d reports a read-only runner still on main as an `[INFO]`, and the new
`release-pin-lib.ps1` holds the version read both scaffolders share.

**Score:** 2

#### What makes this deploy extra special

For the maintainer of a repo that adopts the workflow: a newly adopted repo's CI gates no longer go red
when the source moves a script on main before a release. They move when you adopt the release. A
repo adopted earlier keeps its `@main` callers. A re-run of `adopt-workflow-folder` or `adopt-ci-floor`
names the line to change.

**Score:** 3

#### Pull Request

Pin the read-only consumer runners to the adopted release, not main

Plugins: dkj-repo-workflow

[PR #4247](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4247)

---

### DEPLOY: fix/4234-fast-session-start · 20261117-171654Z

The brand book's session check no longer re-reads every file at each session start. It keeps a per-file
cache of what it found, and reads again only the files whose size or write time changed since the last start.
On this repo that took the check from about 9 s to under 1 s on a warm start, and it was the slowest hook a
session start waited for. The CI gate still reads every file.

**Score:** 2

#### What makes this deploy extra special

A session in a repo with the brand book starts several seconds sooner after `/clear` or a new session, typically under 1 s for this check instead of 9 to 20 s.

**Score:** 2

#### Pull Request

The brand book session check caches its scan, cutting about 8 s from a session start

Plugins: dkj-repo-workflow-dkj

[PR #4244](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4244)

---

### DEPLOY: feat/4240-sweep-delegates-build · 20261117-170018Z

`issues-sweep` step 3 now hands the build to a fresh subagent (#4240): the specialist whose craft the
change is, or `general-purpose` on `sonnet`, never a `fork`. Its brief forbids committing, pushing,
opening a PR and writing to the tracker. The sweep's main loop keeps the choosing, parking and
judging. It reads the returned diff before anything ships, and writes the branch document itself. A
change whose brief would be longer than the edit is still built inline.

**Score:** 2

#### What makes this deploy extra special

For whoever runs a sweep: the build, the bulk of a sweep's tokens, now runs on the cheaper subagent
model instead of the session's main model, while the judgement that needs the stronger model stays in
the main loop. Follow-up to #4233, whose page split cut what the skill loads per run.

**Score:** 3

#### Pull Request

issues-sweep: step 3's build goes to a fresh subagent on sonnet, the main loop keeps the judgement

Plugins: dkj-repo-workflow

[PR #4245](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4245)

---

