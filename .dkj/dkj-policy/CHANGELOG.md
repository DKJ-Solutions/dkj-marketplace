# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: feat/radius-three-steps · 20261113-011101Z

The brand book's radius scale is cut from six steps to three plus the pill, one per role: `--radius-1` (4px)
for a small element, `--radius-2` (8px) for a control, `--radius-3` (12px) for a container. `--radius-1-5`
folds into `--radius-2`, and `--radius-2-5` and `--radius-4` into `--radius-3`; the three old names are
retired tokens, so the house-style gate reports a use left behind. The migration table is in the brand book
README, and the Figma library's `Scale` collection carries the same four steps.

**Score:** 3

#### What makes this deploy extra special

An app that takes this brand book renames each use of the three retired radius tokens in its own layer, and
its controls, small cards and dialogs change their corners (6 to 8px, 10 to 12px, 16 to 12px).

**Score:** 4

#### Pull Request

Brand book radius scale cut to three steps plus pill

Plugins: dkj-policy, dkj-solutions

[PR #4042](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4042)

---

