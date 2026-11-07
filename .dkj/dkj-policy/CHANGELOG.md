# Changelog

## [Unreleased]

**6 / 9 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3872-retire-issue-dashboard · 20261107-145945Z

The optional live issue dashboard is retired: the Cloudflare Worker under `plugins/dkj-policy/worker/`,
`issue-dashboard.ps1`, its suite and its skill are gone, and so is the `Get-IssueDashboardWorkerName`
seam. Nothing ran it, and Admin's GitHub page already lists the open issues locally, so every new parking
label no longer has to be taught to a worker nobody deploys. The BWJ pages worker is a different worker
and stays.

**Score:** 2

#### What makes this deploy extra special

A repo that answered `Get-IssueDashboardWorkerName` in `scripts/repo-config.ps1` can delete the function:
nothing reads it any more, and no check names it, so it stays as dead code until you do. If you ever
deployed the dashboard, remove the worker
with `npx wrangler delete <repo>-issue-dashboard` (or the name your seam gave it); the path token under
`.dkj/dkj-policy/dashboard/` can go with it.

**Score:** 2

#### Pull Request

Retire the optional Cloudflare issue dashboard

Plugins: dkj-policy

[PR #3876](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3876)

---

### DEPLOY: fix/3868-ship-pr-merged-during-lap · 20261107-144938Z

`ship-pr` no longer reports "NOT merged, NOT folded" for a pull request that something else merged while
it waited, such as its own `merge-when-green` arm. Before the stale-certificate lap forwards or refuses,
and before step 4 merges, it reads the PR's state; when it reads `MERGED` it says so and carries on with
the post-merge steps (the fold, or standing down where the fold already landed) instead of refusing (#3868).

**Score:** 3

#### What makes this deploy extra special

Whoever ships with `ship-pr` stops getting a false refusal that invites a re-ship or a blocker report for
work that had already landed.

**Score:** 2

#### Pull Request

ship-pr: recognise a PR merged by another path during the forward lap

Plugins: dkj-policy

[PR #3875](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3875)

---

### DEPLOY: feat/3870-dkj-dotfolder · 20261107-141444Z

The workflow's own folder moves from the repo root to [`.dkj/dkj-policy/`](./), so a repo now tells what
it **builds** (`plugins/<plugin>/`, in this repo) from what an installed plugin **uses** in it
(`.dkj/<plugin>/`): a dot-folder is a tool's, a plain folder is the product. A second plugin that leaves
data in a repo gets `.dkj/<its-name>/` beside it, so nothing ever has to merge. `.claude/` was the first
candidate and was declined: it is a Claude Code protected path, so every write there asks for
confirmation, and the branch document is written almost every turn.

One list of folder names now lives in
[`workflow-folder-lib.ps1`](../../scripts/lib/workflow-folder-lib.ps1), read for the changelog and release
roots and for the branch documents alike, so the two cannot disagree in a repo mid-move. The root
`dkj-policy/` and the two names before it are still read wherever `.dkj/dkj-policy/` does not exist, so
nothing breaks before a repo moves.

**Score:** 3

#### What makes this deploy extra special

Every consumer moves its folder once: Part 1 of `adopt-dkj-policy`, run with `-Apply`, does it in one
`git mv` and repoints the quoted paths in `scripts/repo-config.ps1` and the `.gitignore` lines that name
the old folder. Until then everything keeps working where it is, and the session check names the move.

**Score:** 4

#### Pull Request

The workflow folder moves to .dkj/dkj-policy/: build in plugins/, use in .dkj/

[PR #3874](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3874)

---

### DEPLOY: docs/move-avatars-to-lifehub · 20261107-120950Z

The three GitHub-account avatars leave this repo for `dkj-lifehub`: they are the owner's personal
material, also used outside this repo (Windows accounts), and nothing here read them. The root
`assets/` folder goes with them, and Sylvester's repo-layout lens says where they went.

**Score:** 1

#### What makes this deploy extra special

N/A -- no plugin ships or reads these files; no consumer notices.

**Score:** N/A

#### Pull Request

Move the GitHub-account avatars out of this repo, to dkj-lifehub

[PR #3869](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3869)

---

### DEPLOY: feat/3860-today-page · 20261107-113029Z

A new hub page and a `-Status` mode on `day-plan.ps1`; the hub's menu gains a card, first of its own, so the
Goals card moves one place along. The page reads the day file and runs the script as a child of the hub, so the
GitHub search has one source.

**Score:** 3

#### What makes this deploy extra special

Admin opens on Today: the day goal with a progress bar, the plan with each item ticked off as its PR or issue
closes, what got done outside the plan, what was deliberately left for another day, and the week so far. The day
you planned with Paula stays in view while you work, and at the end of it you can see what you did.

**Score:** 3

#### Pull Request

Admin page /dev/today: the day plan, what got done, and the week

Plugins: dkj-policy

[PR #3865](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3865)

---

### DEPLOY: docs/remove-ai-radar · 20261107-111644Z

The AI radar added in #3863 leaves this repo: the owner keeps the AI knowledge base in `dkj-lifehub`
instead. This repo keeps a line to it, the repo-local `ai-radar` skill: its script finds the
lifehub checkout through the register, lists the items still to be assessed, and the skill says how
to hold them against this tree, file a gap here and write the verdict back in the lifehub. Rebecca's
lens and the repo layout in Sylvester's lens are back to what they said before.

**Score:** 1

#### What makes this deploy extra special

N/A: the folder sat outside `plugins/`, and the new skill is repo-local, so nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

Move the AI radar to the lifehub, and read it from here with the ai-radar skill

[PR #3867](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3867)

---

### DEPLOY: feat/3862-tidy-lane8-removes-records · 20261107-104657Z

`tidy-machine` lane 8 now removes an install record whose checkout is gone, instead of printing the
sequence for the reader to run. It recreates the folder empty, uninstalls each record from inside it at
that record's own scope, and removes the folder again only while it is still empty. It acts only when the
folder's parent is still on the machine, so an unmounted drive or an offline sync root stays on report,
and it never touches a `managed` record
([#3862](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3862)).

**Score:** 2

#### What makes this deploy extra special

Running `tidy-machine` now clears the dead install records a moved or deleted checkout leaves behind, in
the same run, as long as the folder's parent is still on the machine. Before this, every run handed back the same list of uninstall lines to paste by hand.
`-DryRun` still shows the sequence without running it.

**Score:** 3

#### Pull Request

tidy-machine lane 8 removes a gone checkout's install records itself

Plugins: dkj-policy

[PR #3864](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3864)

---

### DEPLOY: docs/ai-radar · 20261107-103730Z

A new root folder, [`ai-radar/`](https://github.com/DKJ-Solutions/dkj-marketplace/blob/dea5c62f4/ai-radar/README.md), keeps a running log of AI and Claude Code
news. Each entry is held against what the plugins already ship and gets a verdict: `Covered`,
`Partly`, `Gap`, `Not for us` or `To assess`. A `Gap` is filed as an issue and the entry cites it, so
the radar turns news into work on the tracker. Rebecca's lens says why this folder does not break her
rule that research lands on issues, and Sylvester's repo layout lists it.

**Score:** 2

#### What makes this deploy extra special

N/A: the folder sits outside `plugins/`, so nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

AI radar: a knowledge base of AI and Claude Code news, held against our own setup

[PR #3863](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3863)

---

### DEPLOY: feat/3859-day-plan-skill · 20261107-102517Z

A new `day-plan` skill and script in `dkj-policy`, with a test suite and Paula's day-rhythm section; nothing
existing changes behaviour. The script keeps one day file per machine under `%LOCALAPPDATA%\dkj-hub\dayplan\`,
outside any repo, and counts the work of both accounts a checkout can act and commit as.

**Score:** 3

#### What makes this deploy extra special

The owner's working day gets a beginning and an end. In the morning Paula proposes one day goal and the items
for it, each with an hour estimate and a mode (plan first, or go), and she holds the day between 6 and 8
hours: a thin day and an overfull one are both refused, and an addition during the day that does not fit is
too. Overruling her takes a reason, which comes back at the close-out. In the evening the close-out reads
GitHub, says what got done, what moves to tomorrow and what was extra, and ends with "You can close the day";
on Friday the week does the same.

**Score:** 3

#### Pull Request

Day plan skill: Paula's morning plan and day/week close-out

Plugins: dkj-policy, dkj-subagents-alpha

[PR #3861](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3861)

---

