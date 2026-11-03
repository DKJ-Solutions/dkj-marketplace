## fix/3780-timing-store-orphan-adoption

> **How this file is read.** A step is `- [ ]` until it is resolved -- `- [x]` done, or
> `- [~]` dropped with the reason, which exists so nobody ticks a box for work they did not do.
> open-pr and ship-pr both refuse while one is still open, and there is no `-Force`.
>
> **FOUR `###` HEADINGS, AND NEVER A FIFTH** -- PLAN, CREATE, TEST, DEPLOY are the whole top
> level. A section needing its own heading goes in as a `####` UNDER whichever of the four owns
> it. No gate in YOUR repo reads a heading, so this half is on you -- only the repo that authors
> this workflow refuses a fifth (Dave, August 26, 2026).
>
> **AND NOTHING BRANCH-SPECIFIC ABOVE THE FIRST OF THOSE FOUR HEADINGS** -- everything between the
> title and it is this guidance, which is identical in every branch document. A status line, a note about
> THIS branch or an instruction to a session belongs under one of the four, normally as a `####`
> in PLAN. THIS half open-pr refuses, in every repo, before the push -- it reads the shape, so a
> guidance block in your own language passes and your own paragraph here does not (Dave,
> August 26, 2026; refused since #1650).
>
> **DEPLOY takes no steps of its own, and it is WRITTEN LAST** -- it is what the branch DID, once
> TEST says so. Written while steps above it are still open it states an INTENTION, and no gate
> holds it against what landed: the step gate splits this file at that heading and counts only
> above it. The PR title is the one exception -- new-branch -Title writes it at creation, because
> open-pr composes the PR title from it. It is the one part of this file that travels verbatim
> into `CHANGELOG.md` at the merge. In each tier, write the reason
> ABOVE the Score line -- anything below it is discarded.
>
> Relative links in that text resolve FROM THIS DIRECTORY -- `CHANGELOG.md` sits here too, so
> write each path exactly as it reads in this file.
>
> For tier 2 audiences: the user who relies on what this repo ships, and decides whether to take the next version -- a subscriber of a service, or the user of a tool, its own maintainer included. That reader and nobody else -- what matters only
> inside this repo belongs under the first `**Score:**`. If the change reaches that reader
> not at all, N/A is a complete answer and the common one. **One hop and no further:** where that
> reader is itself a business, ITS own customers sit one hop past this repo and are never the reader
> here -- they take nothing this repo ships. Name the party that runs the upgrade, and score
> against them.
>
> The phase arc, the marks and the whole form: `DEVELOPMENT-portable.md`, which ships
> with this workflow.

### PLAN

- [x] Implement the owner's decision on #3780 (November 3, 2026): keep the path-hash key, add an
  adopt-on-orphan fallback on the runs' `startHead` commits, retire the hard-coded `dkj-claude-plugins`
  name, and merge the Logbook stores as a union on run id.

#### Two choices the decision left open, made here

- **Orphan means the folder was demonstrably this repo's and its checkout is gone**, not just
  "another key": two clones of one repo share every commit, and a fork shares its upstream's, so the
  commit test alone would let one copy the other's runs (Victor and Sebastian, in review). A folder's
  new `checkout.txt` names its checkout and origin, and is an orphan only with that checkout gone and
  the same origin; a folder of before that file only when its own `<name>-<hash>` places it beside
  the current checkout, which is exactly the rename case. And from an orphan only the runs whose
  `startHead` is a commit here are taken.
- **Adopting copies and never deletes**, as the issue's own local repair did, so a wrong adoption
  costs duplicates and never loses a run.

### CREATE

- [x] `Move-HubTimingLegacyStore` becomes `Import-HubTimingOrphanStore` in
  `plugins/dkj-policy/hub/lib/stopwatch-lib.ps1`, with `Get-HubTimingStoreVerdict`,
  `Get-HubOriginId`, `Get-HubCommitsKnown` and a merge for the run stores, the phase caches and the
  hide file; its six callers (two hooks, two hub pages, `timing-pages.ps1`,
  `Start-StopwatchScriptRun`) renamed.
- [x] Review (Victor, Sebastian) folded in: each merge under its file's own lock; a store that does
  not read, a lock not taken or git not answering leaves the folder unmarked, so the next call
  retries; hide files merged rather than copied; an unreadable `checkout.txt` reads as live, and a
  network path in one is never tested.
- [x] The commit probe is `git rev-list --no-walk --ignore-missing` with the shas as arguments:
  `cat-file --batch-check` fed through a Windows PowerShell pipe read every sha as missing.

### TEST

- [x] `scripts/tests/stopwatch.tests.ps1`: the old move asserts replaced by the adoption block
  (rename orphan adopted, a moved folder of the same origin adopted, Logbook union with its own
  run winning, a run on a foreign commit left behind, sessions, phase caches and hide files merged,
  old folder untouched, an unrelated orphan, a live clone, an unplaced clone, a fork and a network
  path never adopted, once per folder, an unreadable store leaving the folder unmarked, the
  machine-wide store adopted by commit and not by name, no folder left by a non-repo). 309 passed,
  twice in a row.
- [x] Dry read against this machine's real stores: of twelve folders only
  `dkj-claude-plugins-b8e66305` is both an orphan and shares commits with this repo (62 of 91).

### DEPLOY: fix/3780-timing-store-orphan-adoption

Renaming a checkout's folder no longer empties its Stopwatch and Logbook
([#3780](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3780)). The store key stays the
path hash, so two unrelated repos with one folder name still never share a store (#3470), and the
first time a repo's hooks or hub run after the upgrade, `Import-HubTimingOrphanStore` adopts the
store its checkout left behind: a folder whose checkout is gone and that was this repo's, placed
beside the checkout by its own name or carrying this repo's origin. From it, only the runs that
started on a commit of this repo are taken, so a live clone, a fork or an unrelated repo never
crosses over. The run stores merge as a union on run id, the repo's own run winning, and the phase
caches and hide files the same way. Nothing is moved or deleted. The repo's folder is then marked
with its checkout and origin in a local `checkout.txt` (no sync reads it), so every later call is one
file test and the next rename finds it. The machine-wide stores of before #3470 are adopted on the
same commit test, which retires the hard-coded `dkj-claude-plugins` name the old move needed.

**Score:** 2

#### What makes this deploy extra special

A repo whose checkout folder was renamed gets its earlier Stopwatch cards and Logbook runs back on
its hub without anyone copying files by hand, and a shared Stopwatch stops publishing an empty store.

**Score:** 2

#### Pull Request

Stopwatch/Logbook: adopt a timing store orphaned by a checkout rename

