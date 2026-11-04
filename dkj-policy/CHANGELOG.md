# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: feat/stopwatch-overview-latest-run · 20261104-191020Z

Each card on the hub's `/stopwatch` overview now shows the time of the label's latest run, with its change in
percent against the run before it (`+` faster, `-` slower), instead of the fastest run ever. A label whose
latest run is still going shows its live clock, and the cards are ordered slowest first by that latest time.

**Score:** 2

#### What makes this deploy extra special

Every dkj-policy user with a Toolbox sees the overview's times change: they now tell how the last run went,
not the best one, so a run that got slower no longer hides behind an old record.

**Score:** 2

#### Pull Request

The Stopwatch overview shows each label's latest run

Plugins: dkj-policy

[PR #3812](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3812)

---

