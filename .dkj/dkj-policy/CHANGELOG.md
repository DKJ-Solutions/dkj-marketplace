# Changelog

## [Unreleased]

**34 / 44 minor entries** <!-- pending-tally -->

### DEPLOY: fix/4193-parking-verdict-per-label · 20261116-144724Z

`claim-issue` now gives each parking label its own verdict. Before, every label printed the same
"waiting on an ANSWER ... not yours to give" text. A session claiming an `awaiting-session-dev` issue
(#4066) was told to stop, even when it was the session that issue had been parked for. Now that label
says to lift it and carry on. A wait on a pull request, a release, an act, a look or a recurrence is
named as a wait. The decision and information labels keep the original text (#4193).

**Score:** 2

#### What makes this deploy extra special

A session the owner opens to work an issue parked under `awaiting-session-dev` is now told to go ahead
instead of stopping.

**Score:** 2

#### Pull Request

claim-issue: the parking verdict reads per label, so awaiting-session-dev is not told it waits on an answer

Plugins: dkj-policy

[PR #4196](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4196)

---

### DEPLOY: fix/4165-notify-live-send-no-block · 20261116-143606Z

`notify-live` now tells the task of a solved issue that carries no go-live block
([#4165](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4165)), instead of only naming it as
`NO BLOCK`. An issue closed as completed, linking one task and not told yet, gets the same plain "now live
as version vX.Y.Z" message as a block waiting on the release, and its dry-run row reads `no block`. That
is the set the cut's audience note counts as solved, so the two readers share one definition. The marker
comment still keeps it from being told twice.

**Score:** 3

#### What makes this deploy extra special

On release day every task the release notes call solved now hears on the task itself that its work is
live, with no by-hand messages left for the issues whose close carried no go-live block.

**Score:** 3

#### Pull Request

notify-live: send the plain live message to a solved issue with no go-live block

Plugins: bwj-development

[PR #4190](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4190)

---

### DEPLOY: fix/4163-comment-named-issues · 20261116-142518Z

Inside this repo, `Get-PullIssueCandidates` in `pull-issue-lib.ps1` skips HTML comments when it reads a PR body for
named issues ([#4163](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4163)).

**Score:** 2

#### What makes this deploy extra special

A store whose PR template mentions an issue number inside its guidance comment no longer gets that issue in every
release. Before, the cut's task-form audience note drafted it as solved, and notify-live could tell its task again
that it was live. Measured in a consumer's v1.8.0 cut: a task that had shipped three releases earlier.

**Score:** 3

#### Pull Request

A PR template's HTML comment no longer names an issue to the task form and notify-live

Plugins: bwj-development, dkj-policy

[PR #4177](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4177)

---

### DEPLOY: feat/4173-admin-mcp-connections-page · 20261116-140843Z

Admin has an **MCP connections** page on `/dev/claude/mcp`, listed on the Claude page
([#4173](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4173)). One row per MCP server a session in
the checkout can reach: where it comes from (claude.ai connector, plugin, the project's `.mcp.json`, user
config), its host, whether it is connected, needs authentication or failed, and whether this project has
switched it off. The page reads a cache that its own **Read the connections** button fills by running
`claude mcp list` (about 15 s); it keeps only each server's host, never a full URL.

**Score:** 2

#### What makes this deploy extra special

Until now the only answer to "which connectors can Claude use here, and which still need a login" was
`/mcp` inside a session or a 15-second `claude mcp list` in a terminal. Admin now shows it on one page,
next to the rules, skills and specialists.

**Score:** 2

#### Pull Request

Admin: an MCP connections page under Claude

Plugins: dkj-policy

[PR #4192](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4192)

---

### DEPLOY: fix/4157-backup-full-store · 20261116-135148Z

`backup-live-theme` counts the store's themes before it duplicates live
([#4157](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4157)). At Shopify's limit of 20 it refuses, and
names `sweep-preview-themes` as the step that frees a slot. When the duplicate leaves no copy in the theme list,
it now says so, instead of claiming the copy was created.

**Score:** 2

#### What makes this deploy extra special

On release day in a Shopify store repo holding 20 themes, the backup step stops with "the store is full (20/20)
... sweep spent previews first", instead of a misleading message and a push the preflight then refuses. Sweeping
and re-running clears it.

**Score:** 3

#### Pull Request

backup-live-theme refuses a full store before duplicating, and stops claiming a failed duplicate was created

Plugins: dkj-subagents-shopify

[PR #4180](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4180)

---

### DEPLOY: fix/4160-publish-page-skip-unchanged · 20261116-133301Z

`publish-page` uploads only the pages whose bytes changed since this machine last verified them
([#4160](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4160)). After each SHA-256 read-back it
records the page's hash under a digest of its key, in the user's LocalApplicationData rather than the repo,
because a key carries the path token. A release day then uploads the new release page and the index instead
of every page again. `-All` uploads everything, for a key changed or deleted in KV from elsewhere.

**Score:** 2

#### What makes this deploy extra special

Publishing the release notes on release day takes seconds instead of more than five minutes. The first
publish on each machine still uploads every page once.

**Score:** 2

#### Pull Request

publish-page: upload only the pages whose verified bytes changed since the last publish

Plugins: bwj-development

[PR #4175](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4175)

---

### DEPLOY: fix/4168-sync-required-checks · 20261116-132206Z

`sync-main` no longer holds its PR when a check the trunk does not require stays pending
([#4168](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4168)): it reads the required checks from the
trunk's branch rules and merges once those are green, as `ship-pr` does. A required check that has not
registered yet still counts as pending, and where the rules cannot be read or require nothing every check is
waited for, as before.

**Score:** 2

#### What makes this deploy extra special

A Shopify store whose sync PR carries a slow, non-required check (a theme-check report, measured pending for
ten minutes over green required checks) gets the sync merged instead of `NOT merged` after the timeout.

**Score:** 2

#### Pull Request

sync-main waits on the required checks only, where the repo has any

Plugins: dkj-subagents-shopify

[PR #4191](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4191)

---

### DEPLOY: feat/4149-sync-main-as-drift-check · 20261116-123740Z

`sync-main` takes `-Only <paths>` and runs as a drift check over them
([#4149](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4149)). It writes nothing and exits 1
when a listed path holds content on live this repo never had, or was changed on both sides. Where no
drift check is answered and `scripts/theme/live-snapshot.ps1` is absent, `live-preflight` and
`prepare-release` now use it. Until now they skipped the step, and with it `live-preflight`'s deletion
command.

**Score:** 3

#### What makes this deploy extra special

A store whose only drift check is `sync-main` now learns from `prepare-release`, days ahead, which paths on
its push list a third party has changed on live. Measured in a consumer: 12 conflicted paths, 9 on the push
list, while the step read as skipped. On the day, `live-preflight` checks the same paths and prints the
deletion command it used to withhold.

**Score:** 3

#### Pull Request

sync-main -Only is a drift check, and the release steps fall back to it

Plugins: bwj-development, dkj-subagents-shopify

[PR #4189](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4189)

---

### DEPLOY: fix/4148-layout-floor-pin · 20261116-122616Z

The consumer register (`check-consumers.ps1`, check 6d) now reports a write runner pinned below v6.10.0 as an
`[ERROR]` when the consumer already carries `.dkj/dkj-policy/` ([#4148](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4148)).
Such a pin's fold and unfolded-entry scripts look for branch documents in the old `dkj-policy/` folder, find
none, and report OK: measured in a consumer, two merges went green over an entry that was never folded. Run
with `-RemoteRunners` it flags four consumers today; a pin that is merely behind stays `[INFO]`.

**Score:** 3

#### What makes this deploy extra special

N/A -- the register runs in this repo only; nothing a consumer installs changes.

**Score:** N/A

#### Pull Request

The consumer register flags a write runner pinned below the .dkj/ layout floor as an error

[PR #4188](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4188)

---

### DEPLOY: fix/4186-decided-park-reads-stale · 20261116-121444Z

`claim-issue -Candidates` reads an `awaiting-decision-dev` or `awaiting-decision-client` issue as `stale-park` once
a comment opening `Decision (` follows its last parking comment
([#4186](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4186)). The comment must come from somebody with a
hand on the repo. The run prints the lines that lift the label, so a decision posted without removing it no
longer leaves the issue skipped by every sweep.

**Score:** 2

#### What makes this deploy extra special

In every repo running the sweeps, a client's or owner's decision posted as a comment, from any session, now
surfaces at the next sweep as a park to lift. Until now the issue sat skipped until somebody noticed the label.

**Score:** 3

#### Pull Request

A decision park with a posted decision reads as stale-park

Plugins: dkj-policy

[PR #4187](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4187)

---

### DEPLOY: fix/4184-one-racy-git-fix · 20261116-115516Z

Inside this repo, the EOL fixture in `git-porcelain-lib.tests.ps1` keeps one racy-git fix, the measured one from
#4176 ([#4184](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4184)). The parallel second fix and its
contradicting comment are gone.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The EOL fixture keeps one racy-git fix, the measured one

[PR #4185](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4185)

---

### DEPLOY: fix/4152-reconcile-base-merges · 20261116-114450Z

`sync-main -ReconcileBase` now opens its PR, waits for the checks and merges it with a merge commit itself,
the same finish the plain merging sync runs ([#4152](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4152)).
It used to print `gh pr create`, `gh pr checks --watch` and `gh pr merge`, and run back to back they failed: the
watch returned before the checks had registered, and the merge was refused. The commands are still printed when
the push does not land.

**Score:** 3

#### What makes this deploy extra special

A Shopify store that reconciles a sync conflict no longer finishes the reconciliation base by hand: the run
merges it, with a merge commit even where the repo squashes by default, and leaves the checkout on the trunk.

**Score:** 3

#### Pull Request

sync-main -ReconcileBase opens, waits for and merges its own PR

Plugins: dkj-subagents-shopify

[PR #4174](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4174)

---

### DEPLOY: fix/4171-case-sensitive-mirror-compare · 20261116-112727Z

Inside this repo, the shared-script mirror build, the integrity gate's `[shared-script]` check and the
consumer-drift check compare case-sensitively
([#4171](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4171)). An edit that changes only letter case
is now copied into the mirror and reported as drift, where before it read as in sync.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Mirror comparisons are case-sensitive, so a case-only edit is mirrored and flagged

[PR #4183](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4183)

---

### DEPLOY: fix/4176-eol-fixture-racy-git · 20261116-111147Z

The CRLF-index assert in `git-porcelain-lib.tests.ps1` no longer depends on how fast the runner is
([#4176](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4176)). Git trusts an index entry's stat
data unless the file was written in the same second as the index, so a slow runner read the fixture's
CRLF file as clean. The fixture now moves the file's mtime back before the first add and forward before the
checkout, so every run takes the same path.

**Score:** 2

#### What makes this deploy extra special

N/A -- a test fixture in this repo; nothing a consumer runs changes.

**Score:** N/A

#### Pull Request

git-porcelain-lib tests: make the CRLF-index fixture independent of how fast the runner is

[PR #4181](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4181)

---

### DEPLOY: fix/4143-eol-fixture-race · 20261116-110015Z

The `git-porcelain-lib` suite's line-ending fixture from [#4143](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4143)
no longer depends on timing: after `git checkout --` the file's stat matched its index entry and git could
trust it unread, so the test went red on CI while passing locally. It now sets the file's mtime apart from
the index, as a consumer's checkout is.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

git-porcelain-lib's EOL fixture no longer depends on racy-git timing

[PR #4179](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4179)

---

### DEPLOY: fix/4165-notify-live-no-block-row · 20261116-104334Z

`notify-live` names a solved issue that carries no go-live block instead of skipping it silently
([#4165](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4165)). An issue closed as completed and
linking one task, with no block, prints as `NO BLOCK` with its task, and the run ends with a line listing
them: the cut's audience note can call such an issue solved while nothing here tells its task, so a person
tells it by hand. Nothing more is sent than before.

**Score:** 2

#### What makes this deploy extra special

On release day the dry run shows which requesters the release notes call solved but whose task this run
will not tell, so nobody reads in the notes that their task shipped without hearing it on the task itself.

**Score:** 2

#### Pull Request

notify-live: name an issue that is solved but has no go-live block, instead of skipping it silently

Plugins: bwj-development

[PR #4178](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4178)

---

### DEPLOY: fix/4156-task-form-audience-note · 20261116-103028Z

`prepare-release` (bwj-development) no longer asks a repo that drafts its audience note as solved tasks
(`Get-ReleaseNoteTaskLink`) to write that note before the day
([#4156](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4156)). Step 2 and the runbook's cut step say the
cut drafts it from the live-push record, name `-LivePushRecord` as required, and ask for a review after the cut.

**Score:** 2

#### What makes this deploy extra special

A BWJ store repo whose release note lists solved tasks is no longer told to write a note the cut would replace.
That note would list work before anyone knew it was live. Its runbook now names the record the cut needs.

**Score:** 2

#### Pull Request

prepare-release tells a task-form repo that the cut drafts the audience note

Plugins: bwj-development

[PR #4172](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4172)

---

### DEPLOY: fix/4154-app-deploy-allow-updates · 20261116-101810Z

The app deploy that `live-preflight` and `prepare-release` print now reads
`shopify app deploy --path <folder> --allow-updates`
([#4154](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4154)), so it runs in a non-interactive shell.
A deletion still needs `--allow-deletes`, which remains a deliberate separate act.

**Score:** 2

#### What makes this deploy extra special

On release day in a Shopify store repo that ships an app, the printed app deploy runs as printed through a
session's `!` prefix. Before, the Shopify CLI refused it there and the owner had to look up the missing flag.

**Score:** 3

#### Pull Request

The printed app deploy carries --allow-updates, so it runs in a non-interactive shell

Plugins: bwj-development, dkj-subagents-shopify

[PR #4169](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4169)

---

### DEPLOY: feat/4155-notes-share-link · 20261116-100413Z

Inside this repo, `publish-page.ps1` gains `-CheckAuth` and `prepare-release` calls it
([#4155](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4155)). Both suites cover the new lines.

**Score:** 2

#### What makes this deploy extra special

A BWJ store's release runbook now names the release-notes publish it actually runs, `publish-page -Kind notes`.
It also prints the page's shareable link and says the close-out leads with it, so the owner gets the note they
read instead of the GitHub Release. `prepare-release` checks the Cloudflare login days ahead, where it used to
fail only on the release day.

**Score:** 3

#### Pull Request

The release runbook names the shareable release-notes link and checks the page login ahead

Plugins: bwj-development

[PR #4170](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4170)

---

### DEPLOY: fix/4147-notify-live-no-access · 20261116-095135Z

`notify-live` now tells a task the Asana token cannot see apart from a failure a rerun can fix
([#4147](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4147)). With `ASANA_PAT` set, the dry
run reads every owed task once, so an inaccessible one shows as `NO ACCESS` before `-Post`. A failed
call is reported as `NO ACCESS`, `TOKEN`, `REJECTED` or `FAILED`, and only `FAILED` (network, rate
limit, 5xx) ends in "run it again".

**Score:** 2

#### What makes this deploy extra special

On release day the person running `notify-live` learns from the dry run which requesters the token
cannot reach and must be told by hand, instead of retrying a post that fails the same way every time.

**Score:** 2

#### Pull Request

notify-live: name an inaccessible Asana task as no access, and check access in the dry run

Plugins: bwj-development

[PR #4164](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4164)

---

### DEPLOY: feat/4150-sync-conflict-classes · 20261116-093148Z

Inside this repo, `sync-main.ps1` prints a one-line reading under each conflicted path's diff command
([#4150](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4150)). New pure functions in `sync-rules.ps1`
compute it, and both suites cover them.

**Score:** 2

#### What makes this deploy extra special

A Shopify repo whose sync refuses on conflicts gets a first reading of each conflicted path, so nobody has to diff
them all by hand. A Liquid or other text path reads `trunk ahead` when every line live holds is one the trunk's
history has held. A `templates/` or `sections/` JSON file gets its live-only, trunk-only and changed settings,
by key. Measured in a consumer, those were the two readings that settled twelve conflicts, and they took most of a
session to work out by hand. The conflict still refuses: the person decides.

**Score:** 3

#### Pull Request

sync-main gives each conflicted path a first reading

Plugins: dkj-subagents-shopify

[PR #4167](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4167)

---

### DEPLOY: fix/4151-prepare-release-names-accept-switch · 20261116-092108Z

`prepare-release`'s reconciliation step (bwj-development) now says what to do with an owed path where the trunk is
meant to win ([#4151](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4151)): pass
`-AcceptOwedReconciliation` to `live-preflight` on the day, once those are the only paths left. A path where
live's content should win still takes an ordinary commit.

**Score:** 2

#### What makes this deploy extra special

A BWJ store repo preparing a release after `sync-main -ReconcileBase` learns on the Friday how to let the trunk win
on a path. Until now that only surfaced as `live-preflight`'s refusal on the day.

**Score:** 2

#### Pull Request

prepare-release names -AcceptOwedReconciliation for paths where the trunk is meant to win

Plugins: bwj-development

[PR #4166](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4166)

---

### DEPLOY: fix/4143-eol-only-dirty · 20261116-090900Z

`prepare-release` and `live-preflight` no longer count a file committed with CRLF despite `eol=lf` as an
uncommitted change ([#4143](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4143)): step 1 names such
files as `EOL-ONLY`, says a checkout cannot clean them, and prints the `git add --renormalize` line that does.
The shared `git-porcelain-lib` gains `Get-GitEolOnlySplit` for it.

**Score:** 2

#### What makes this deploy extra special

A store repo whose theme files were committed with the wrong line endings gets the remedy on release day
instead of a refusal that `git checkout --` cannot clear. The verdict is the same, ATTENTION or a refusal,
and only the message is new.

**Score:** 2

#### Pull Request

prepare-release and live-preflight name EOL-only changes instead of counting them as uncommitted

Plugins: bwj-development, dkj-policy, dkj-subagents-shopify

[PR #4161](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4161)

---

### DEPLOY: fix/4146-github-merge-subject · 20261116-085837Z

Inside this repo, `Find-BranchMergeCommit` in `live-record-lib.ps1` also recognises GitHub's default merge subject,
`Merge pull request #<n> from <owner>/<branch>`, beside ship-pr's `merge: <branch> (#<n>)`
([#4146](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4146)). `cut-release.ps1`'s warning for an
unmatched entry names both.

**Score:** 2

#### What makes this deploy extra special

A Shopify repo cutting a release with `-LivePushRecord` gets entries merged through the GitHub UI checked against
the live-push record automatically. They no longer count as unknown, each to be checked by hand. Measured in a
consumer's cut, that was 58 of 82 entries. Only squash merges still need the check by hand.

**Score:** 3

#### Pull Request

The cut finds an entry's merge under GitHub's default merge subject too

Plugins: bwj-development, dkj-policy, dkj-subagents-shopify

[PR #4159](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4159)

---

### DEPLOY: fix/4145-fold-demotes-body-headings · 20261116-083903Z

Inside this repo, `fold-changelog-entry.ps1` runs every folded entry through a new `Limit-EntryBodyHeadings`
([#4145](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4145)). Any heading in the entry's body at or
above the entry's own level becomes a section one level below it, and the fold prints how many it moved.

**Score:** 2

#### What makes this deploy extra special

In a repo that has taken this update, a `##` heading written inside a DEPLOY section can no longer close
`## [Unreleased]` at the fold and hide the entries below it from the next cut. Measured in a consumer, the cut saw
2 of 31 pending entries. A `###` there no longer splits one change into two entries either. The fold demotes such
headings and names the document to repair.

**Score:** 3

#### Pull Request

The fold demotes headings in a DEPLOY body that would close [Unreleased] or split the entry

Plugins: dkj-policy

[PR #4158](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4158)

---

### DEPLOY: fix/4144-eol-only-trunk-return · 20261116-082801Z

`ship-pr` no longer traps the fold when the trunk's fast-forward is blocked only by line endings
([#4144](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4144)): where every modified path equals
`origin/main` once CR is ignored (a file committed with CRLF despite `eol=lf`, which the merged PR itself
renormalized), it takes those paths from `origin/main`, fast-forwards again and folds. Any other change in
the tree leaves the refusal exactly as it was.

**Score:** 2

#### What makes this deploy extra special

The PR that renormalizes CRLF-committed files ships and folds in one run, instead of stopping with "the
FOLD IS STILL OWED" and a manual `git checkout origin/main -- <paths>` plus a hand fold.

**Score:** 2

#### Pull Request

ship-pr: retry the trunk fast-forward past EOL-only blockers

Plugins: dkj-policy

[PR #4153](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4153)

---

### DEPLOY: feat/4131-domain-borders · 20261116-072904Z

Admin's own pages and this repo's consumer dashboard follow the brand book's rule from #4127, that a border marks
something you can press ([#4131](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4131)): the Goals page's
Now card, next tasks and milestones, the Today page's items, the repository page's code block, the release page's
sheet, the notice above a toolbar pane and the dashboard's signal rows stand on fills instead of lines.

**Score:** 2

#### What makes this deploy extra special

Admin, which every repo running this workflow opens, now reads like the rest of the brand book after #4127: no
lines left on its Goals and Today pages, the current task marked by a stronger fill rather than a coloured frame.

**Score:** 2

#### Pull Request

Admin and dashboard domain layers drop their decorative borders

Plugins: dkj-policy

[PR #4142](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4142)

---

### DEPLOY: docs/4139-storage-neutral-brain · 20261116-014548Z

Ian and Onyx in `dkj-subagents-lifehub` no longer assume the knowledge base is a folder tree in the repo
([#4139](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4139)): where the brain lives, how its entries
are placed and how its links are stored are what the consumer's lens names, files in the repo or an external
workspace.

**Score:** 2

#### What makes this deploy extra special

A life-hub whose knowledge base has moved out of git, into an external workspace, can drop the temporary
section its Ian and Onyx lenses carried: the two specialists read the location and the link format from the
lens instead of looking for `Brains/` and `NEURON.md` files.

**Score:** 2

#### Pull Request

Lifehub: Ian and Onyx no longer assume the knowledge base is a folder tree

Plugins: dkj-subagents-lifehub

[PR #4141](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4141)

---

### DEPLOY: feat/4127-borders-only-on-buttons · 20261116-011737Z

The brand book now draws a border only where something can be pressed
([#4127](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4127)): buttons, fields, the controls a person
types in, and the focus ring keep theirs; cards, notices, alerts, panels, chips, tooltips, dialogs, bars and code
blocks stand on their own fill, rows inside a surface are set apart by spacing (a table by alternating fills), and a
state that was a coloured edge is a tint. The README states the rule.

**Score:** 2

#### What makes this deploy extra special

Every DKJ-Solutions app that takes the update loses almost every line on its pages: cards, notices and the header
and bottom bars stand on their fill alone, tables stripe instead of ruling, and lists of rows become rows of fill a
hairline of page apart. No markup changes; an app whose own layer draws borders of its own keeps them until it
follows the rule.

**Score:** 3

#### Pull Request

Borders only on buttons; separate with fills

Plugins: dkj-policy, dkj-solutions

[PR #4140](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4140)

---

### DEPLOY: feat/4125-more-page · 20261116-000103Z

Inside this repo, the product layer's renderer lifts the site menu's sections into one function,
`Format-SiteMenuSectionsHtml`, which both the full-screen dialog and a new More page body
(`Format-ProductMoreBodyHtml`) render, and this repo's product serves `/more` with the bottom bar's More linking it.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product's bottom bar can now make More a page like its other slots: pass `-MoreHref` and More becomes
a link to that page, with a URL that can be refreshed, linked and returned to. The phone's back gesture leaves it as
it leaves any page, and the bar marks More as where you are. The page holds the same sections as the menu, and the
full-screen dialog stays for products without a bottom bar.

**Score:** 3

#### Pull Request

Bottom bar: More opens a page with its own URL

Plugins: dkj-solutions

[PR #4138](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4138)

---

### DEPLOY: feat/4128-phone-header-height · 20261115-221833Z

On a phone a product's site header is 56px tall instead of 68px, with its back, actions and menu cells still square,
and the full-screen menu's head matches it. The bottom bar is 61px instead of 73px on a phone without a home
indicator, and keeps the safe area on one that has it. Together they give about 24px of the screen back to the page.
A wide screen is unchanged.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

On a phone, the site header is 56px and the bottom bar 61px

Plugins: dkj-solutions

[PR #4137](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4137)

---

### DEPLOY: feat/4124-icon-grammar · 20261115-214107Z

Every DKJ product now reads three icons one way on a phone: **three lines** for more pages, **three dots** for the
page's own actions, and the **gear** for settings
([#4124](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4124)). The product README writes that grammar
down, and the full-screen menu's **Display** section becomes **Settings**, its one row carrying the house gear, so
on a phone settings sit inside the menu rather than as an icon in the header.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product that draws its header with `Format-SiteHeaderHtml` and passes `-SettingsHref` shows a
**Settings** section with a gear in its phone menu where it showed **Display**, with no change of its own. One that
draws the menu by hand renames the section and adds the gear, as the README says.

**Score:** 3

#### Pull Request

Product on a phone: one icon grammar, and settings as a row in More

Plugins: dkj-solutions

[PR #4136](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4136)

---

### DEPLOY: feat/4129-phone-table-rows · 20261115-195943Z

A table of sentences can now stack on a phone: wrap it in `.table-wrap--stack` and each row becomes a block, its
first cell the heading and every other cell its column's name over its value, with no markup per table, so a rendered
markdown table takes it too. Wider than 48rem it stays the ordinary table, and a table without the class is unchanged.

**Score:** 3

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Brand book: a phone pattern for tables (rows as stacked blocks)

Plugins: dkj-policy

[PR #4135](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4135)

---

### DEPLOY: feat/4123-single-header-action · 20261115-194435Z

A product page with a single action, such as *Save as PDF*, now shows that action as its own icon in the site
header, instead of three dots that open a sheet holding one item. The three dots and the sheet appear only when a
page has two actions or more. An app drawing its header with `Format-SiteHeaderHtml` gets this with the update.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Product header: a page with one action shows it directly

Plugins: dkj-solutions

[PR #4134](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4134)

---

### DEPLOY: fix/4111-docs-coverage-scroll · 20261115-193008Z

A wide house table no longer widens the whole page on a phone. Its scroll container, `.table-wrap`, is now
the containing block of what is positioned inside it, so a visually hidden column head at the table's far
edge (the Docs coverage page's Details column) is clipped with the rest of the table instead of setting the
document's width. On the product's `/docs-coverage` at 375 px the page measured 1322 px wide and now measures
375, with the table scrolling inside its own box (#4111).

**Score:** 3

#### What makes this deploy extra special

Any page in a consuming repo that puts a `.sr-only` element, or anything else absolute, inside a wide
`.table-wrap` stops scrolling sideways as a whole on a phone once it takes this brand book.

**Score:** 2

#### Pull Request

A wide table's hidden column head no longer widens the page on a phone

Plugins: dkj-policy

[PR #4133](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4133)

---

### DEPLOY: feat/4126-no-group-surface · 20261115-191324Z

A card group is no longer a surface of its own
([#4126](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4126)): `.grid-2`, `.grid-3` and `.card-grid`
lose the `--bg-2` tray, its radius and its padding at every width, so a card in a group is the same plain card it is
anywhere else, on `--bg-2` against the page. That reverses the padded tray of November 2, 2026, and takes with it
the darker card fill inside a group and the button edge #3697 gave it.

**Score:** 2

#### What makes this deploy extra special

Every DKJ-Solutions app that takes the update loses the frame around its card groups: the cards stand on the page
directly, one step lighter or darker than it, and on a phone they gain the width the padding took on both sides.
No markup changes; an app whose own layer leaned on the group's padding checks its spacing.

**Score:** 3

#### Pull Request

Brand book: a card group is no surface of its own

Plugins: dkj-policy, dkj-solutions

[PR #4132](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4132)

---

### DEPLOY: feat/4113-consumer-group-rows · 20261115-182852Z

The BWJ and Other repos on the Consumers pages read like the DKJ ones: a group's page is a card per repo -- on a
phone one card of compact rows -- and each repo's report is a page of its own, where its long paths and plugin ids
wrap inside the card. The table and the one long report of every repo are gone.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Consumer group pages as rows with a page per repo

[PR #4130](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4130)

---

### DEPLOY: feat/4113-phone-page-furniture · 20261115-174831Z

On a phone a product page no longer shows a lone "?" at the top left or a long note of source paths at its foot,
and a row of figure tiles, such as a specialist's token costs, reads as one card of compact rows. That matches the
mobile wireframes. A wide screen is unchanged.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

On a phone, no lone '?', no source note, and the stat tiles as one card of rows

Plugins: dkj-solutions

[PR #4122](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4122)

---

### DEPLOY: feat/card-grid-rows-on-phone · 20261115-173629Z

On a phone a list of pages -- the consumer repos, the plugins, a team's specialists -- is one card of compact rows
with its heading above, instead of a stack of large tiles in a grey surface, as the mobile wireframes draw it. No
card sits inside a surface on a phone any more. A wide screen keeps its tiles.

**Score:** 3

#### What makes this deploy extra special

Every product built on the brand book gets this on a phone without a markup change: a group of card links becomes
one card of rows, and a group never wraps its cards in a second surface there.

**Score:** 3

#### Pull Request

On a phone a group of card links reads as one card of compact rows, after the mobile wireframes

Plugins: dkj-solutions

[PR #4121](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4121)

---

### DEPLOY: docs/4115-scope-question · 20261115-154629Z

Chris now asks whether a piece of work is shared before he routes it. An owner's requirement, an
irritation or a found defect counts as shared product behaviour (the brand book, page patterns, the
workflow scripts) unless the repo's facts rule lists it as a declared deviation with its reason, and
under doubt it is shared. So it is filed or commented on the source tracker first, and any local build
in the meantime is a declared bridge that names that inbound issue and is removed when the release
lands. The constitution now lists those declared deviations among a repo's facts (#4115).

**Score:** 3

#### What makes this deploy extra special

In every consuming repo, a requirement that holds for every DKJ repo is now reported at the source before
it is built, instead of being built locally and then again in each of the other repos. A repo that really
does differ writes the deviation and its reason into its facts rule.

**Score:** 3

#### Pull Request

Chris asks 'is this shared?' before building

Plugins: dkj-policy, dkj-subagents-alpha

[PR #4120](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4120)

---

### DEPLOY: fix/facts-long-value · 20261115-153440Z

On a phone a fact row's long value -- a source path, a plugin with its note, a sentence -- no longer runs over its
label or past the card: the label keeps its width and the value wraps under itself, right-aligned. A short value
reads as before.

**Score:** 3

#### What makes this deploy extra special

Every product built on the brand book shows its `.facts` lists readably on a phone: a long value wraps instead of
covering its term. A page that wants one-line facts now says `white-space: nowrap` in its own layer.

**Score:** 2

#### Pull Request

A fact row's long value wraps under its label instead of running over it on a phone

Plugins: dkj-policy

[PR #4118](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4118)

---

### DEPLOY: feat/4112-device-preview · 20261115-151812Z

Inside this repo, the product layer gains a device-preview pattern and specimen, and `house-theme.js` switches its
versions.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product that shows a mobile mockup, an A/B variant or a design proposal takes the brand book's phone
frame (`.device-stage`, `.device`, `.device__screen`) instead of writing its own: an iframe per version keeps the
mockup's own look, and a `.seg` above it switches versions with no script of the page's own.

**Score:** 3

#### Pull Request

Brand book: a device preview with an A/B toggle

Plugins: dkj-policy, dkj-solutions

[PR #4119](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4119)

---

### DEPLOY: feat/4114-long-page-word-limit · 20261115-150505Z

A page now splits on length as well as on section count: the brand book's long-page rule
([#3563](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3563)) only ever counted sections, so a
page of three sections and 7,797 words stayed one column. Over **1,500 words of reading** a page becomes an
overview of its sections, and a section page still over the limit splits at its next heading level
([#4114](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4114)). The page shell's guard,
`Get-LongPageWarningHtml`, warns on the word limit too, through a new `Get-PageWordCount` that counts the
text of paragraphs, list items, quotes and code blocks and leaves tables and navigation out, because a list
is not a long page: a plain count put Admin's release-notes list at 1,755 words, its prose at 15.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions app that renders long content (a dossier, a guide) now gets a warning at the top of any
page over 1,500 words of reading, through the shared page shell, and the `dkj-brandbook` skill names the
threshold before such a page is written. Admin's own pages are all far below it, so nothing changes there.

**Score:** 3

#### Pull Request

A long page splits on length too, not only on section count

Plugins: dkj-policy, dkj-solutions

[PR #4117](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4117)

---

### DEPLOY: feat/product-home-mobile-topics · 20261115-145440Z

On a phone the product follows the mobile wireframes. The home page is a list of topics instead of five cards:
Admin, Consumers (with DKJ, BWJ and Other under it), Plugins (with dkj-subagents and dkj-policy), Docs coverage and
Settings, each a heading with its initial in a badge -- the brand book's new topic list. Every product page carries the house bottom bar -- Home,
Consumers, Plugins, and More, which opens the site menu -- so the header leaves its menu toggle out. The Consumers pages no
longer scroll sideways on a phone, and the phone header's title is plain text, with no path menu behind it. A wide screen is unchanged.

**Score:** 3

#### What makes this deploy extra special

The brand book's product layer gains the topic list, `.topic-list` in `house-product.css`: a home page on a phone as
topics with an initial on the primary and their sections under them, the whole row pressable. A product that built
its own copy -- dkj-lifehub's `hub-rubriek` -- can drop it for this one once it takes the release. And the
phone's site header loses its path sheet: the page title is plain text again, the back cell is the way up, and
`Format-SiteHeaderHtml -Path` is still accepted but draws nothing, so a caller that passes it keeps working.

**Score:** 2

#### Pull Request

The product on a phone, after the mobile wireframes: the brand book's topic list on the home page and a bottom bar on every page

Plugins: dkj-policy, dkj-solutions

[PR #4116](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4116)

---

