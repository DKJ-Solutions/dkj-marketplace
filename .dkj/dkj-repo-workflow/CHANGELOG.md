# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

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

