# Changelog

## [Unreleased]

**2 / 2 minor entries** <!-- pending-tally -->

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

