# Changelog

## [Unreleased]

**16 / 16 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4341-auto-memory-off-in-consumers · 20261120-112130Z

`adopt-dkj-repo-workflow` gained a Part 6, `adopt-auto-memory.ps1`, which adds `"autoMemoryEnabled": false`
to `.claude/settings.json` the way Part 5 adds its key: as text, every other byte kept, and an existing
value never replaced. A new `auto-memory-sessioncheck` reports at every session start where the key is
missing, and lists this checkout's memory notes by name until each is filed inbound or moved into the
repo's lens. The settings insert both parts use now lives in one shared lib.

**Score:** 3

#### What makes this deploy extra special

After taking this release, a consumer's session start says whether its repo still lets Claude Code write
memory notes and names the notes already there, so the rule from #4349 is something the setup enforces
and points at, rather than something a person has to remember. One command switches it off.

**Score:** 3

#### Pull Request

Adopt switches auto memory off, and a session check reports leftover memory notes

Plugins: dkj-repo-workflow

[PR #4365](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4365)

---

### DEPLOY: fix/4346-release-notes-every-task-linked · 20261120-110808Z

A cut that drafts the audience note as solved tasks (`Get-ReleaseNoteTaskLink`) now writes the tasks it
drafted from beside the note as `<X.Y.Z>.tasks.json`. The release-notes gate (`open-pr -GatesOnly
-NoteTreeOnly`, through `check-release-note-form.ps1`) refuses the note under `[TASKS]` until it links
every one, and names each missing URL. Rewording the items is still fine. Dropping a link is not. The
cut-release and prepare-release pages now say to brief a writer with that file.

**Score:** 3

#### What makes this deploy extra special

A store that publishes task-form release notes can no longer ship a note that lost its task links. A
consumer's v3.1.0 went out twice that way. The gate stops it before the release-notes commit, and the
cut's follow-up lines name the file to brief a writer with.

**Score:** 3

#### Pull Request

Audience release notes: every resolved Asana task linked, counted before the commit

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj

[PR #4364](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4364)

---

### DEPLOY: feat/4355-ship-pr-handoff · 20261120-105817Z

`ship-pr.ps1` gains `-HandOff`; `issues-sweep` step 5 uses it.

**Score:** 2

#### What makes this deploy extra special

An `issues-sweep` no longer waits out CI after each shipped issue: `ship-pr -HandOff` leaves an armed PR
to merge-on-green and the sweep goes on to the next issue in the same turn. Where the PR cannot be handed
off safely, ship-pr says why and waits as before.

**Score:** 4

#### Pull Request

ship-pr -HandOff: a sweep hands an armed PR to merge-on-green and goes on

Plugins: dkj-repo-workflow

[PR #4358](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4358)

---

### DEPLOY: docs/4348-bwj-out-of-repo-fix-closes · 20261120-104622Z

In a BWJ store repo, an issue whose fix lives in a colleague's project now closes as not planned, with a
note on where the fix lives and whose it is, instead of being parked `awaiting-pull-external`. A blocker in a repo the team
runs, such as a `dkj-marketplace` release, still parks as before. The core's label section points to the
exception ([#4348](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4348)).

**Score:** 2

#### What makes this deploy extra special

A store's open issues no longer collect waits on code the team cannot change.

**Score:** 2

#### Pull Request

bwj: a fix in code the team does not own closes as not planned; a blocker in a repo the team runs still parks

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj

[PR #4362](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4362)

---

### DEPLOY: docs/4345-release-blockers-filed-inbound · 20261120-103209Z

The release skills now say that every blocker or surprise during a release is filed the moment it
happens, with its measured cost (round trips, manual steps, minutes). It is not saved for the end of the
cut. A cause in the shared scripts goes inbound to the plugin's source, even when it surfaced in a
consumer. The rule sits in `cut-release`, and `prepare-release`, `live-preflight` and `ship-pr` point to
it. It was moved out of a per-machine memory note under #4341.

**Score:** 2

#### What makes this deploy extra special

A consumer running a release is told to file a shared-script blocker inbound right away. Before this,
such a blocker reached the source days later, as #4143 and #4144 did after a v3.1.0 cut.

**Score:** 2

#### Pull Request

Release skills: file each release blocker the moment it happens, with its measured cost

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj, dkj-subagents-shopify

[PR #4359](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4359)

---

### DEPLOY: feat/4344-approved-takeover-unassigns · 20261120-101846Z

`claim-issue <n> -ApprovedBy "<who, when>"` takes over an issue another account holds once a person
has approved it. It adds you and removes the previous assignee in the same edit, then comments who
approved it, so the issue never shows two assignees side by side. Without the flag, the refusal stands as before
([#4344](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4344)).

**Score:** 3

#### What makes this deploy extra special

Taking over a colleague's issue after they said "take it" is now one command that also unassigns them,
instead of a refusal and two hand edits.

**Score:** 3

#### Pull Request

claim-issue: an approved takeover removes the previous assignee in the same step

Plugins: dkj-repo-workflow

[PR #4360](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4360)

---

### DEPLOY: docs/4343-drafted-message-not-posted · 20261120-100318Z

The constitution now says it outright: when the owner asks for a reply or a message to a person, the
session delivers the text in the chat and does not post it, on Asana, on an issue or anywhere else. The
owner sends it. Only a procedure's own fixed writes, such as `report-issue`'s comment, are posted by the
session ([#4343](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4343)).

**Score:** 3

#### What makes this deploy extra special

A session asked to write a message to a colleague hands over the text instead of sending it under your
name.

**Score:** 3

#### Pull Request

A requested message to a person is drafted in chat, never posted by the session

Plugins: dkj-repo-workflow

[PR #4357](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4357)

---

### DEPLOY: feat/4337-sweep-author-filter · 20261120-094923Z

`claim-issue.ps1 -Candidates` and `Get-SweepCandidates` gain `-Author`; the sweep pages name it.

**Score:** 2

#### What makes this deploy extra special

In a repo two people share, `issues-sweep` can now sweep only the issues your own sessions filed:
`claim-issue.ps1 -Candidates -Author @me` reads every other issue as `skipped`, and
`issues-sweep-decisions` walks only your own decisions with `--author @me`. Without the flag nothing changes.

**Score:** 3

#### Pull Request

issues-sweep: an -Author filter on claim-issue -Candidates

Plugins: dkj-repo-workflow

[PR #4353](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4353)

---

### DEPLOY: docs/4341-no-auto-memory-notes · 20261120-094036Z

The constitution's rule on lessons learned went from "secured in the docs, not just in memory" to
**never in memory**: no auto-memory notes at all, because a note lives on one machine under one
account and no other person on the team ever reads it. That was measured the same day on a consumer,
where a filing rule the owner decided in a memory note never reached a colleague's sessions. The rule
names the switch, `"autoMemoryEnabled": false` in `.claude/settings.json`, and this repo now sets it.
The technical writer's manual and Chris's lens now say the same.

**Score:** 3

#### What makes this deploy extra special

A consumer reading the next release's constitution is told to keep no memory notes and how to switch
auto memory off. Until `adopt-dkj-repo-workflow` places the key (still open on #4341), a consumer sets
it by hand.

**Score:** 2

#### Pull Request

No auto-memory notes: lessons go upstream or into the repo lens

Plugins: dkj-repo-workflow, dkj-subagents-developers

[PR #4349](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4349)

---

### DEPLOY: fix/4340-bwj-sweep-closes-act-only · 20261120-092809Z

`claim-issue -Park awaiting-action-dev` now refuses in a repo whose own settings enable
`dkj-repo-workflow-bwj`. That extension closes an act-only issue as completed with a research block
instead of parking it (#3059, #3062), and its sweeps kept parking such issues anyway (four measured on
smartwatchbanden). The refusal asks the extension's question, *does any step still change a file in the
repo?*, and prints the close route for a no. For a yes, `-StillChangesCode` lets the park through.
`issues-sweep`'s `parking.md` now gives the rule its own section ([#4340](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4340)).

**Score:** 3

#### What makes this deploy extra special

A BWJ sweep closes what the extension says to close, so the open issues and the In Progress column show
only work that can still be built. Repos without the extension see no change.

**Score:** 3

#### Pull Request

issues-sweep closes act-only issues where the BWJ extension says so

Plugins: dkj-repo-workflow

[PR #4352](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4352)

---

### DEPLOY: fix/4339-bwj-file-only-repo-changing-work · 20261120-091520Z

In a BWJ store repo a finding is filed on GitHub only when a file in the repo will change because of
it, now or after an act outside the repo; one that waits from the start is filed already parked with
its `awaiting-*` label, and an act-only finding or someone else's decision goes to Asana instead. This
is the #3059 close rule asked at filing, so sweeps stop spending turns on issues with nothing to build
([#4339](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4339)).

**Score:** 2

#### What makes this deploy extra special

A BWJ session running `report-issue` no longer files an outside act or a decision that is not its own
as a GitHub issue, and files a waiting one with its parking label at creation. Measured in
smartwatchbanden: 21 of one filer's 26 sweep-parked issues waited on an outside act or an open choice,
and every label came from a later sweep.

**Score:** 3

#### Pull Request

bwj: file on GitHub only what will change a repo file, already parked where it waits

Plugins: dkj-repo-workflow-bwj

[PR #4350](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4350)

---

### DEPLOY: feat/4329-deploy-branch-promotion-guard · 20261119-150542Z

`guard-live-theme` rule 5 now gates every route onto the branch a Git-connected live theme deploys from
(`Get-ShopifyLiveDeployBranch`), not only a `git push`: a `gh pr create` or `gh pr edit` with that branch
as base, a writing `gh api` call on it (ref create, move, rename, protection, merges), and a local commit,
merge, cherry-pick, revert, am, rebase or pull while it is checked out. Each needs the existing live-push
marker (`Get-ShopifyLivePushMarker`); no new seam. `gh pr merge` stays ungated, because the PR's base was
gated when it was opened. This reverses the #3014 ruling that left the promotion PR ungated. Where HEAD
cannot be told (`cd` earlier in the command, `--git-dir`, two `-C`), a local write is refused rather than
guessed.

**Score:** 3

#### What makes this deploy extra special

A Shopify repo whose live theme deploys from a Git branch now has every route onto that branch guarded by
the plugin, with one marker. Opening the promotion PR from a session needs the marker, and smartwatchbanden
can delete its own local hook and suite once it takes this version.

**Score:** 3

#### Pull Request

guard-live-theme gates every route onto a Git-connected deploy branch

Plugins: dkj-subagents-shopify

[PR #4336](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4336)

---

### DEPLOY: docs/4332-ci-read-content-stays-in-git · 20261119-144449Z

The "what belongs in git" chapter of the `dkj-repo-workflow-dkj` extension now names its one
exception (#4332). Content a deployed build reads in CI, such as an Astro content collection, stays in
git or moves to a store the build can reach, because CI has no OneDrive.

**Score:** 2

#### What makes this deploy extra special

A session applying the rule in a repo with a CI-built site no longer moves the content that site
deploys from out of git, which would have published a site without it.

**Score:** 2

#### Pull Request

The what-belongs-in-git rule keeps content a deployed build reads in CI

Plugins: dkj-repo-workflow-dkj

[PR #4335](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4335)

---

### DEPLOY: feat/git-content-sessioncheck · 20261119-142738Z

A new SessionStart check in the `dkj-repo-workflow-dkj` extension, `git-content-sessioncheck`, names
every tracked folder that holds only content files (`.md`, `.json`, `.csv` and the like) and was touched
by 10 or more commits in the last 90 days: data that keeps paying the branch + PR toll, against the "what
belongs in git" rule. Tooling folders and test material are never named. A folder kept in git on purpose
goes in `Get-GitContentAllowlist` in the repo's `scripts/repo-config.ps1`, with its reason. Measured over
the six DKJ-Solutions app repos, it names exactly the two folders a hand audit found, in 0.1 to 1.6
seconds per repo.

**Score:** 3

#### What makes this deploy extra special

Every DKJ-Solutions repo now says at session start when notes or data in it keep going through pull
requests, so the slowdown is seen before it costs weeks.

**Score:** 3

#### Pull Request

Session check reports content folders that pay the PR toll without being code

Plugins: dkj-repo-workflow-dkj

[PR #4334](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4334)

---

### DEPLOY: fix/4330-trunk-guard-quote-aware-split · 20261119-141245Z

The trunk-commit guard no longer lets a quoted separator split a commit in two (#4330).
`git -c user.name="a;b" commit -m wip` on the trunk was allowed, because the command was split at the
`;` inside the quotes. The guard now also reads the command quote-aware and refuses when either
reading refuses.

**Score:** 2

#### What makes this deploy extra special

A consumer can drop its own quote-aware trunk guard and rely on the plugin's without reopening this
form. The `-c "user.name=a b"` and quoted-`&&` variants are closed too.

**Score:** 2

#### Pull Request

The trunk-commit guard reads a quoted separator as a split

Plugins: dkj-repo-workflow, dkj-subagents-shopify

[PR #4333](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4333)

---

### DEPLOY: docs/git-holds-code-not-data · 20261119-125308Z

Every DKJ-Solutions repo now has a written rule for what belongs in git. Git carries what decides how an
app works: code, config, tests and their fixtures, and the docs about that code. Content the owner keeps
up as a user of the app (dossiers, notes, exports, personal data) lives in OneDrive, because each edit to
it would otherwise pay the full branch, PR and CI cycle. The rule is a chapter of the
`dkj-repo-workflow-dkj` extension's `CLAUDE.md`, with two quick tests: work a developers-team specialist
builds or tests belongs in git, and work only a core-team specialist does most likely does not. The
`move-data-to-onedrive` skill now points at it as the rule deciding which data moves.

**Score:** 3

#### What makes this deploy extra special

Sessions in every DKJ-Solutions repo now steer data that is edited as a user out of git, so updating a
dossier or a note no longer waits on a pull request.

**Score:** 3

#### Pull Request

Rule: git holds what builds the app, not the data it is used for

Plugins: dkj-repo-workflow-dkj, dkj-subagents-developers

[PR #4331](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4331)

---

