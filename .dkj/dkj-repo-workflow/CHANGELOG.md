# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4366-asana-ci-scripts-load-libs · 20261120-141838Z

The three Asana CI scripts of `dkj-repo-workflow-bwj` (`asana-closed-message`, `asana-open-section`,
`asana-prio-label`) now load `asana-task-lib.ps1` and `asana-section-lib.ps1` from the pinned checkout
instead of carrying copies of their helpers, so a fix to a matcher, a block marker or the section rule
reaches the CI runs and the task scripts as one change. The workflows' `sparse-checkout` fetches
`scripts/lib` beside `scripts/ci` for that.

**Score:** 2

#### What makes this deploy extra special

A BWJ store that moves its Asana workflows' `ref:` to this release must copy the three workflow files from
the plugin's `templates/` again (keeping its `ref:` line), because the job now fetches `scripts/lib` too.
`closed-message-sessioncheck` reports each placed workflow as differing from its template until that is
done, and a workflow moved to the new `ref:` alone stops its run with a message naming exactly this.

**Score:** 4

#### Pull Request

The Asana CI scripts load the shared libs instead of carrying copies

Plugins: dkj-repo-workflow-bwj

[PR #4372](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4372)

---

### DEPLOY: feat/4369-agenda-sync-signals · 20261120-132919Z

The `agenda-sync` skill (lifehub) gets a signals step. A run now looks for two events at most 7 days apart whose titles share a distinctive word (a possible duplicate) and for same-day clashes: a single-day all-day event next to a timed one, or two timed events that overlap. Birthdays, free events and multi-day spans are left out. Each pair is put to the owner as a question at the top of the run's report, never only in a row's Notitie. It is reported once, recorded in a new `Gesignaleerd` text column. Google stays the source, so the sync never moves or removes anything because of a signal.

**Score:** 2

#### What makes this deploy extra special

A lifehub user's daily agenda run now asks about a wrong or double entry, so a mistake shows up in the run's summary instead of weeks later. The first run adds a `Gesignaleerd` column to the Agenda database.

**Score:** 3

#### Pull Request

agenda-sync reports likely duplicates and same-day clashes to the owner

Plugins: dkj-subagents-lifehub

[PR #4370](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4370)

---

