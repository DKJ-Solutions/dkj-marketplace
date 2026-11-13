# Changelog

## [Unreleased]

**2 / 3 minor entries** <!-- pending-tally -->

### DEPLOY: docs/4040-wireframe-token-mapping · 20261113-015209Z

The brand book README now maps every colour of the Figma `Wireframe` collection to the house token it
becomes, and each variable carries the same mapping in its Figma description
([#4040](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4040)). The wireframes stay grey and
are not aliased. The two wireframe text greys both become `--primary-muted`, because the brand book has
one tone for what may recede.

**Score:** 2

#### What makes this deploy extra special

N/A: the mapping guides how Admin's visual design is made in this repo, and nothing a consumer runs changes.

**Score:** N/A

#### Pull Request

Wireframe colour variables: the role mapping to the house tokens, in Figma and in the brand book README

Plugins: dkj-policy

[PR #4044](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4044)

---

### DEPLOY: fix/4041-closed-message-waits-for-trunk-sync · 20261113-012644Z

`closed-message-sessioncheck` now waits for dkj-policy's trunk sync before it reads a store's tree
([#4041](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4041)). It ran as its own SessionStart
entry beside the dispatcher, so in xoxowildhearts it reported the prio-label pair and
`Get-ResolvesExemptMatchers` missing, and the same session start then fast-forwarded `main` by 34
commits that brought both in. It now waits up to 20 s for the dispatcher's prep-done mark, as the
dev-preview hook does (#3657), with `session-cache-lib` and `hash-hex-lib` mirrored into bwj-development.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a BWJ store stops getting `[ERROR]` lines at session start for files the same
session start brings in. Those lines made them re-run `adopt-bwj-development` for work already merged,
and taught them to skip the one error that was real.

**Score:** 2

#### Pull Request

closed-message-sessioncheck waits for the trunk sync before it reads the tree

Plugins: bwj-development

[PR #4043](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4043)

---

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

