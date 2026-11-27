# Changelog

## [Unreleased]

**4 / 4 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4528-skill-description-budget · 20261127-162005Z

Every skill the plugins ship that a session can invoke on its own now has a short, trigger-first
description, and eight one-time or owner-typed skills (the adopt skills, scheduled-tasks, the two
stopwatch skills, record-suite-durations, dependabot-entry) left the model's listing and are typed as a
slash command instead. The descriptions together went from about 35,800 characters to 7,843, and a new
integrity check holds each one to 250 characters and their sum to 10,000.

**Score:** 3

#### What makes this deploy extra special

Skills such as asana-intake, day-plan and tidy-machine fire on their own again: Claude Code drops
descriptions that do not fit its skill-listing budget, and they were arriving name-only. The eight
skills above are now started by typing them, for example `/adopt-dkj-repo-workflow`.

**Score:** 3

#### Pull Request

Skill descriptions fit Claude Code's listing budget, so plugin skills trigger again

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj, dkj-repo-workflow-dkj, dkj-subagents-alpha, dkj-subagents-developers, dkj-subagents-lifehub, dkj-subagents-shopify

[PR #4539](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4539)

---

### DEPLOY: feat/4532-live-pr-entry-guard · 20261127-152302Z

The plugin's own scripts and hooks gained a new PreToolUse guard, `guard-live-pr-entry`. It meets a
hand-typed `gh pr create` whose base is the live deploy branch a repo declares, and refuses it while the
head branch's changelog entry is not written, using the same check the CI gate runs.

**Score:** 2

#### What makes this deploy extra special

A hotfix PR to the live branch is now checked before it opens, even when the live branch's own CI copy
lags the trunk's. A malformed DEPLOY section can no longer land there unjudged and strand the fold later.
Repos that declare no live branch see no change.

**Score:** 2

#### Pull Request

A hotfix PR to the live branch is checked for a written changelog entry before it opens

Plugins: dkj-repo-workflow

[PR #4536](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4536)

---

### DEPLOY: fix/4527-fold-valid-entries-past-malformed · 20261127-151201Z

The changelog fold no longer refuses a whole fold-all run over one malformed entry. It sets that entry
aside on the trunk, folds the valid entries beside it, and ends red naming the set-aside entry and why,
so a release cut in the meantime no longer misses changes that were written correctly.

**Score:** 3

#### What makes this deploy extra special

A repo whose trunk holds one malformed entry no longer sees its valid entries stranded with it, or every
unrelated merge's fold go red without folding anything.

**Score:** 3

#### Pull Request

fold-all folds the valid entries and leaves only the malformed ones stranded

Plugins: dkj-repo-workflow

[PR #4533](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4533)

---

### DEPLOY: docs/4525-ian-collection-placement · 20261127-145318Z

The life hub's information architect, Ian (04-03), places one item out of a series of similar items (a
track, a film, a trip) as a row in a per-kind collection database rather than as a dossier, groups by
columns rather than by a page tree, opens a new database for a new kind of collection, and does not
log a row as an Update. What the owner has watched or done no longer goes to the taste dossier.

**Score:** 2

#### What makes this deploy extra special

A life-hub user whose hub keeps a collection page gets tracks, films and trips filed as rows there,
instead of as dossiers that bury the topics with a narrative.

**Score:** 2

#### Pull Request

Ian places collection items as rows in per-kind Collection databases

Plugins: dkj-subagents-lifehub

[PR #4531](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4531)

---

