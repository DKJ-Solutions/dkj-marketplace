# Changelog

## [Unreleased]

**29 / 33 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4290-check-sitemap-in-shopify · 20261118-174948Z

Ships the `check-sitemap` skill in `dkj-subagents-shopify`. It reports a storefront's sitemap layout for
each market:
- which sub-sitemap holds a URL
- the URLs listed twice
- with `-Catalog`, the products, collections and pages the store serves that its sitemap leaves out

The markets come from the `Get-StorefrontMarkets` seam. A store that runs its markets as locale prefixes
on one domain is read from that domain's single sitemap. Step 2 of
[#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290).

**Score:** 2

#### What makes this deploy extra special

A store adopting this in place of its own copy gets two repairs:
- An accented handle is no longer reported as missing from the sitemap, because sitemap paths are now
  percent-decoded before the comparison.
- A catalogue list cut off at the 25,000 ceiling is skipped with a notice instead of counted as a finding.

`-Market` now defaults to every market.

**Score:** 2

#### Pull Request

Move check-sitemap into dkj-subagents-shopify

Plugins: dkj-subagents-shopify

[PR #4306](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4306)

---

### DEPLOY: feat/4290-check-jsonld-in-shopify · 20261118-172427Z

Ships the `check-jsonld` skill in `dkj-subagents-shopify`. It validates the JSON-LD structured data a
storefront serves per market, and can do so on a preview theme. The markets come from the store's
`Get-StorefrontMarkets` seam. `which-theme` now reads that seam through the same lib. It also accepts
`-Path '/a,/b'` from `powershell -File`, which used to arrive as a single path. Step 1 of
[#4290](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4290).

**Score:** 2

#### What makes this deploy extra special

A Shopify store on the plugin can check its structured data before and after a theme change without
keeping its own copy of the script. A preview check now carries the full preview parameters, so it no
longer drops back to live after the first redirect.

**Score:** 2

#### Pull Request

Move check-jsonld into dkj-subagents-shopify

Plugins: dkj-subagents-shopify

[PR #4305](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4305)

---

### DEPLOY: feat/4289-live-direct-writes-in-shopify · 20261118-165945Z

Ships the `live-direct-writes` skill in `dkj-subagents-shopify`. On a schedule, it reads the branch a
Git-connected live theme deploys from. A `shopify[bot]` commit whose body carries `Changed by:` is a CLI
push or a code-editor save that bypassed the branch flow. The check opens one issue labelled
`live-direct-write` for every set of new ones it finds. `adopt-shopify-floor` now places the workflow
that runs it, but only in a store that answers `Get-ShopifyLiveDeployBranch`. The workflow is pinned to
the plugin's release, so it runs once a release that contains this script exists. Closes
[#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289).

**Score:** 3

#### What makes this deploy extra special

A Git-connected store gets a signal for the one route to its live theme that no guard can stop: a push
from a shell that never loaded the harness. Re-run `adopt-shopify-floor` to place the check. A store that
already runs its own copy keeps it: the label and the dedupe marker are unchanged, so passing its current
floor as `-LiveDirectWritesSince` means nothing gets reported twice.

**Score:** 3

#### Pull Request

Move live-direct-writes and its workflow into dkj-subagents-shopify

Plugins: dkj-subagents-shopify

[PR #4304](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4304)

---

### DEPLOY: fix/4301-sync-summary-renamed-section · 20261118-160931Z

`sync-summary` now flags a section that a sync **renamed** while a template still points at its old
name, the same way it flags a deleted one: such a page returns HTTP 200 and renders nothing. Until now
only deletions were checked, so a rename slipped through as if nothing had gone.

**Score:** 2

#### What makes this deploy extra special

N/A: `sync-summary` has not been released yet, so this lands in the same release that first ships it and
no store repo ever runs the version with the gap.

**Score:** N/A

#### Pull Request

sync-summary flags a renamed section a template still references

Plugins: dkj-subagents-shopify

[PR #4303](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4303)

---

### DEPLOY: feat/4289-sync-summary-in-shopify · 20261118-152601Z

Ships the `sync-summary` skill in `dkj-subagents-shopify`. It turns a live-drift sync commit, or a range
such as the live branch against the trunk, into a short report. The report lists what changed per theme
area, and flags removed sections a template still references, new sections nobody asked for, and
theme-editor setting changes. `-SinceTrunk` builds the range from `Get-ShopifyLiveDeployBranch`. Sync
commits are recognised by `Get-ShopifySyncReferencePattern`, the same pattern `sync-main` uses. Step 2 of
[#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289).

**Score:** 2

#### What makes this deploy extra special

A store that kept its own copy can drop it. One thing changes: a sync commit is now recognised by the
`sync-main` pattern (`^[Ss]ync` by default), which is narrower than the store copy's pattern. Some
subjects only mention third-party edits, without starting with "sync". To keep matching those, answer
`Get-ShopifySyncReferencePattern`.

**Score:** 2

#### Pull Request

Move sync-summary into dkj-subagents-shopify

Plugins: dkj-subagents-shopify

[PR #4302](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4302)

---

### DEPLOY: feat/4289-which-theme-in-shopify · 20261118-150111Z

Ships the `which-theme` skill in `dkj-subagents-shopify` and puts `fetch-failure` in its script lib. The
skill reports which theme id and name a storefront URL actually serves. You can add `-MustContain` or
`-MustNotContain` fingerprints to tell a cached copy from a fresh one. When a fetch fails, it prints
the status, `x-request-id`, UTC time and URL. Before this, only one store repo had the script. First
step of [#4289](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4289).

**Score:** 2

#### What makes this deploy extra special

A Shopify store on the plugin can now check which theme a page really serves without keeping its own
copy of the script. `-Url` works straight away. `-Path` needs the store to answer
`Get-StorefrontMarkets` in `scripts/repo-config.ps1`, the seam the BWJ extension already reads, so a
store that has answered it once is covered for both.

**Score:** 2

#### Pull Request

Move which-theme and fetch-failure into dkj-subagents-shopify

Plugins: dkj-subagents-shopify

[PR #4300](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4300)

---

### DEPLOY: fix/4292-invoke-native-lib · 20261118-124207Z

The BWJ go-live block builder (`build-golive-block`) no longer stops with an error when `gh` or `git` is
missing from the machine. It now reports that call as failed, as `notify-live` and `prepare-release`
already did. The three scripts now share one copy of the helper that runs `gh` and `git`, so a later fix
to that helper reaches all three at once.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

One Invoke-Native lib for the dkj-repo-workflow-bwj task scripts

Plugins: dkj-repo-workflow-bwj

[PR #4298](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4298)

---

### DEPLOY: fix/4293-kind-label-repo-heredoc · 20261118-122917Z

The BWJ issue guards no longer judge an issue create against the checkout's own repo when the target repo is
passed through a shell variable (`-R $R`): the target counts as unknown, and the create passes with the
not-judged warning. A `gh issue create` quoted inside a heredoc body is no longer read as a second call
(#4293).

**Score:** 3

#### What makes this deploy extra special

In a store checkout, filing an inbound issue on the plugin's source repo with `-R $R`, or with a body written
through a heredoc that quotes a command, is no longer refused as "carries none of the kind labels".

**Score:** 3

#### Pull Request

guard-kind-label: a non-literal --repo is unknown, and heredoc bodies are not commands

Plugins: dkj-repo-workflow-bwj

[PR #4299](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4299)

---

### DEPLOY: feat/4291-asana-move-task · 20261118-121804Z

`dkj-repo-workflow-bwj` ships a `move-asana-task` skill. It moves an issue's Asana task to a section of
the repo's own board, named by stage code, with a dry run, and resolves the section by the same rule as
the CI runners. Before this, only one store had such a script
([#4291](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4291)).

**Score:** 3

#### What makes this deploy extra special

A session in either BWJ store can move a card on request without a raw Asana API call, which auto mode
refuses. It does so without picking a different section than the CI runners would.

**Score:** 3

#### Pull Request

Ship a manual move-Asana-task-to-stage script in dkj-repo-workflow-bwj

Plugins: dkj-repo-workflow-bwj

[PR #4297](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4297)

---

### DEPLOY: feat/4287-dependabot-entry · 20261118-120436Z

`dkj-repo-workflow` now ships `dependabot-entry` (#4287): it writes the branch development document
onto a Dependabot PR's own branch, so the PR passes the branch-entry gate. It refuses a PR that is not
open, comes from a fork or is not Dependabot's, never touches a local branch ahead of origin, merges the
current trunk in, and leaves the three questions a bump owes (where the package enters, why it is worth
taking, what the audit said) in the DEPLOY section for a person to answer. The gate itself stays as it is.

**Score:** 2

#### What makes this deploy extra special

A repo with Dependabot no longer needs its own copy of this script to get a bump past the entry gate.

**Score:** 2

#### Pull Request

Ship dependabot-entry in dkj-repo-workflow, so a Dependabot PR meets the branch-entry gate

Plugins: dkj-repo-workflow

[PR #4295](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4295)

---

### DEPLOY: feat/4288-eol-gate · 20261118-115621Z

`open-pr` now refuses a branch whose git index carries a file with CRLF while `.gitattributes` pins it to
`eol=lf`, and prints the one-line repair (`git add --renormalize -- <paths>`). The check is
`scripts/lint/check-eol.ps1`, shared through the `dkj-repo-workflow` mirror and runnable as a CI step, so a
consumer's own copy can go (#4288).

**Score:** 3

#### What makes this deploy extra special

A consumer on Windows whose `.gitattributes` pins LF no longer meets an EOL-only modification at `ship-pr`'s
fast-forward (#4144): `open-pr` catches the CRLF blob before the push, with the repair line printed.

**Score:** 2

#### Pull Request

Ship the CRLF-under-eol=lf index check as a shared gate

Plugins: dkj-repo-workflow

[PR #4296](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4296)

---

### DEPLOY: feat/4286-trunk-commit-guard · 20261118-114449Z

`guard-working-copy` now refuses a `git commit` made while HEAD is on the trunk, in every thread, unless
the subject is one of the constitution's bounded direct commits (`fold:`, `release:`, `release-prep:`,
`release-notes:`). Before this, "never directly on the trunk" was prose only, outside one store that
built its own guard. The rule fails open whenever it cannot tell the branch or the trunk
([#4286](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4286)).

**Score:** 4

#### What makes this deploy extra special

A consumer's session that tries to commit straight on the trunk is now stopped and pointed at
`new-branch`, where it used to land the commit and fail only at push time, or not at all.

**Score:** 3

#### Pull Request

Refuse a commit on the trunk in guard-working-copy, outside the fold and release subjects

Plugins: dkj-repo-workflow

[PR #4294](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4294)

---

### DEPLOY: fix/4282-asana-move-own-board · 20261118-112815Z

When an issue closes with its result block, or is reopened, the BWJ Asana workflow now moves the linked
card even when the task also sits on another team's board: it moves the card on the repo's own board,
the one `Get-AsanaProjectGid` names, and leaves the other boards alone. Before, any second board made the
move a skip, so the message arrived while the card stayed in its old column. The daily open-section sweep
follows the same rule. A task on several boards none of which is the repo's own is still left where it is.

**Score:** 2

#### What makes this deploy extra special

Tickets from other teams, which normally live on a second board, now follow their message into review
like every other ticket.

**Score:** 2

#### Pull Request

Asana card moves use the repo's own board when a task is on several boards

Plugins: dkj-repo-workflow-bwj

[PR #4285](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4285)

---

### DEPLOY: feat/4273-lint-brain-bwj · 20261118-111441Z

The BWJ store maintainers get one documentation linter in `dkj-repo-workflow-bwj`, in place of two diverged
copies, and with it each store gains the other store's checks. Nothing changes for them yet: they keep running
their own copy until step 3 (#4274) switches them over. That step needs `Get-LintBrainOptions` in each store to
switch on the check that store already ran.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Move lint-brain and lint-changed-hook into dkj-repo-workflow-bwj, reconciled from both store copies

Plugins: dkj-repo-workflow-bwj

[PR #4283](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4283)

---

### DEPLOY: feat/4279-agenda-tasks-card · 20261118-110236Z

`/agenda` now turns an action the owner accepts into a card in their Tasks database, with a deadline and
a relation to the Agenda row. A second run finds that card and creates no duplicate
([#4279](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4279)).

**Score:** 3

#### What makes this deploy extra special

A life-hub owner gets a trackable card per recurring date once their settings page names the Tasks
database and its relation. Without those settings nothing changes.

**Score:** 3

#### Pull Request

agenda skill: turn an accepted action into a Tasks card linked to its Agenda row

Plugins: dkj-subagents-lifehub

[PR #4284](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4284)

---

### DEPLOY: fix/4278-rest-filing-fallback · 20261118-103225Z

The orchestrator skill page now cites the live repo name, and says how to file where `gh issue create`
is refused because GraphQL is unavailable (a Claude Code cloud session): through `gh api` against the
REST endpoints, after checking reachability with a REST read rather than `gh auth status`.

**Score:** 2

#### What makes this deploy extra special

A cloud session that finds something to report can now file it inbound instead of concluding there is no
tracker.

**Score:** 2

#### Pull Request

A session where GitHub GraphQL is refused files through the REST form, and the orchestrator skill cites the live repo name

Plugins: dkj-subagents-alpha

[PR #4281](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4281)

---

### DEPLOY: fix/4277-lifehub-inherit-mcp-tools · 20261118-101902Z

The lifehub subagents (Ian, Onyx, Astrid, Fiona, Hugo) now inherit the session's connector tools through
a `disallowedTools:` denylist instead of a file-only `tools:` allowlist, so they can read and file in a
knowledge base that lives behind a connector such as Notion. Shell access stays denied to all five, and
writing stays denied to the three that only deliver material. The integrity gate's tool-block check now
counts an inherited tool as held, so a tools-less subagent def cannot pick up Bash without the
working-copy boundary.

**Score:** 2

#### What makes this deploy extra special

A lifehub user whose brain lives in Notion can hand filing to Ian or Onyx as subagents again, instead of
the work falling back to the main loop.

**Score:** 3

#### Pull Request

Lifehub subagents inherit connector tools through a denylist instead of a file-only allowlist

Plugins: dkj-subagents-lifehub

[PR #4280](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4280)

---

### DEPLOY: feat/4271-start-task-bwj · 20261118-100659Z

`dkj-repo-workflow-bwj` now ships `start-task`, the store layer over the shared `new-branch` (#4271). It
refuses a missing Shopify CLI, a `sync/` or `dependabot/` name, an unknown prefix, a double quote in the
title, and a base that is not the trunk unless `-Base` or `-Stacked` says so. It checks all of this before
anything is created. It reconciles the two diverged store copies into one, which reads the trunk, the
prefix table and the store domain from the store's own seams.

**Score:** 2

#### What makes this deploy extra special

A fix to how a store task starts now reaches both stores with a release, instead of being made twice by
hand.

**Score:** 2

#### Pull Request

Move start-task into dkj-repo-workflow-bwj, reconciled from both store copies

Plugins: dkj-repo-workflow-bwj

[PR #4275](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4275)

---

### DEPLOY: feat/4272-check-theme-refs-in-bwj · 20261118-095347Z

`dkj-repo-workflow-bwj` now ships the theme-reference check and the theme-check gate shape check. The
two BWJ stores used to keep separately diverged copies of each. Every behaviour where the two copies
differed is now settled in one place and covered by this repo's suites, so a fix reaches both stores
through a release ([#4272](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4272), part of
[#4259](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4259)).

**Score:** 3

#### What makes this deploy extra special

A BWJ store maintainer gets the scripts, but nothing changes for them until the store swaps its copy
for a forwarder (#4274).

**Score:** N/A

#### Pull Request

Move check-theme-refs and its gate into dkj-repo-workflow-bwj

Plugins: dkj-repo-workflow-bwj

[PR #4276](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4276)

---

### DEPLOY: feat/4259-plugin-payload-locator · 20261118-091702Z

`dkj-repo-workflow` now ships the plugin-payload locator (`scripts/lib/plugin-payload-lib.ps1`) and a
forwarder template (`templates/plugin-scripts-forwarder.ps1`) for consumers that run plugin scripts from
their own scripts (#4259). A consumer that replaces its own `scripts/lib/plugin-scripts.ps1` with the
template keeps every `Resolve-PluginScript` call site. A later plugin rename then reaches it with the
release, instead of as a code change in the repo. The retired-name map the import checks use now derives
from the same table.

**Score:** 2

#### What makes this deploy extra special

A store repo can drop its own diverged locator for a few-line forwarder, so the next plugin rename is a
version bump there rather than a migration.

**Score:** 2

#### Pull Request

Ship the plugin-payload locator in dkj-repo-workflow, so a store's plugin-scripts.ps1 becomes a forwarder

Plugins: dkj-repo-workflow, dkj-repo-workflow-bwj

[PR #4269](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4269)

---

### DEPLOY: fix/4267-closed-message-result-owed · 20261118-085932Z

An Asana task whose GitHub issue closes without a go-live block no longer reads "this Asana task is now
in review" while its card stays in progress (#4267). The closed line now says the result message for
this round follows. The issue is labelled `result-owed`, the store's session check lists such closed
issues, and `build-golive-block -ByHand -Post` takes the label off once the result message is on the
task. Before, the run log was the only record of that debt, and smartwatchbanden#1212's went unpaid
until the requester asked. A store takes it by re-copying the `asana-closed-message` template; the
workflow now needs `issues: write`.

**Score:** 2

#### What makes this deploy extra special

A promised result message can no longer be forgotten in silence: every session in the store names it
until it is written.

**Score:** 2

#### Pull Request

asana-closed-message without a block: track the owed result message, and stop claiming review

Plugins: dkj-repo-workflow-bwj

[PR #4268](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4268)

---

### DEPLOY: fix/4258-show-merge-on-green-wake-list · 20261118-020506Z

`adopt-ci-floor` now prints which workflows wake the merge-on-green sweep when it places that runner
(#4258). It also warns when Part 1's `branch-entry.yml` or `always-on-budget.yml` is missing, because
the sweep then does not wake on them. The 7.0.0 note's repair says to run Part 1 first. Before, a run in
the wrong order shortened the trigger list without a word, and merges only came later on the schedule.

**Score:** 2

#### What makes this deploy extra special

A maintainer re-placing CI runners sees the trigger list it chose and is told when it is short.

**Score:** 2

#### Pull Request

adopt-ci-floor shows the workflows merge-on-green wakes on, and warns when Part 1's gates are missing

Plugins: dkj-repo-workflow

[PR #4266](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4266)

---

### DEPLOY: docs/4256-revendor-with-the-pin · 20261118-013229Z

The 7.0.0 note and the brand-book skill now say that a repo vendoring the brand book re-vendors
`house-style.css` and `house-product.css` from the same tag it pins the gate to, in the same change
(#4256). Moving the pin alone turns the gate red, even where the copies differ only in a comment.

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions repo with a vendored brand book takes the 7.0.0 pin in one green change, instead of
finding the second half on a red check.

**Score:** 3

#### Pull Request

Moving the house-style gate's pin re-vendors the brand book at the same tag

Plugins: dkj-repo-workflow-dkj

[PR #4265](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4265)

---

### DEPLOY: fix/4255-repoint-every-folder-path · 20261118-005435Z

Part 1 of adopting the workflow now repoints every old folder path that addresses the workflow folder
(#4255, #4257). That means a `.gitignore` exception line beside its ignore line, and every path in the PR
template, whichever older folder name it carries, even in a repo that moved earlier. Before, a negation
line kept excepting a folder that was gone, and a template could keep naming a folder two moves old.

**Score:** 3

#### What makes this deploy extra special

A consumer migrating to 7.x no longer has to delete its PR template and re-run Part 1, or fix a
`.gitignore` exception by hand.

**Score:** 3

#### Pull Request

Part 1 repoints every old folder path in the PR template and .gitignore

Plugins: dkj-repo-workflow

[PR #4264](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4264)

---

### DEPLOY: fix/4254-gate-reports-text-lg · 20261118-001918Z

The house-style gate now reports `--text-lg` as a retired token (#4254). It was retired on November 1, 2026
for `--text-h3`, but the gate never listed it, so a page reading it passed while its text fell back to
the inherited size. A test now holds the gate's list to the brand book's rename tables.

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions app that still reads `--text-lg` gets a `[retired]` finding naming the line, instead of
quietly losing its size.

**Score:** 3

#### Pull Request

The house-style gate reports --text-lg as a retired token

Plugins: dkj-repo-workflow-dkj

[PR #4263](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4263)

---

### DEPLOY: docs/4253-complete-7-0-0-must-do-list · 20261117-235125Z

The v7.0.0 release note now lists every step a migration needs (#4253): refreshing the marketplace clone,
rewriting `permissions.allow` patterns, repointing all seven CI runners, re-adopting `Get-MojibakePaths`,
updating the core team past 6.x, the statusline shim, the Part 1 ordering workaround, and who updates the
consumer register. It no longer says lenses need no change: two lens headers point at a moved persona body
and have to be corrected by hand.

**Score:** 4

#### What makes this deploy extra special

A maintainer migrating a repo can follow the note alone and finish, rather than finding eight more
steps through failures.

**Score:** 4

#### Pull Request

The 7.0.0 release note's must-do list names every step a migration needs

[PR #4262](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4262)

---

### DEPLOY: fix/4252-refresh-stale-statusline-shim · 20261117-233935Z

`adopt-statusline.ps1 -Apply` now replaces a progress-bar shim it placed before v7.0.0 (#4252). That shim
looked for the old `dkj-policy` plugin id, so after the rename the progress bar went dark, and a re-run
left the stale shim in place. A file at that path that this command did not place is still left alone,
with the line that repairs it.

**Score:** 3

#### What makes this deploy extra special

A consumer whose progress bar went dark after 7.0.0 gets it back by re-running `adopt-statusline.ps1 -Apply`,
without deleting the file by hand first.

**Score:** 3

#### Pull Request

adopt-statusline refreshes a plugin-placed shim that differs from the current template

Plugins: dkj-repo-workflow

[PR #4261](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4261)

---

### DEPLOY: fix/4251-part1-move-beside-branch-docs · 20261117-225213Z

Part 1 of adopting the workflow now moves the old `.dkj/dkj-policy/` folder when the migration branch's own
document already sits in `.dkj/dkj-repo-workflow/` (#4251). Before, it skipped the move and stopped on the
seam check, so the 7.0.0 steps failed in the order the release note gives them. Its dry run no longer
fails on the repos it exists for, and the branch document's line naming the folder links resolve from is
repointed too.

**Score:** 4

#### What makes this deploy extra special

A maintainer migrating to 7.0.0 can follow the note in order (branch first, then Part 1) without moving
their branch document aside by hand.

**Score:** 4

#### Pull Request

Part 1 moves .dkj/dkj-policy/ even when new-branch already created .dkj/dkj-repo-workflow/

Plugins: dkj-repo-workflow

[PR #4260](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4260)

---

### DEPLOY: fix/4248-candidates-default-skiplabel · 20261117-202420Z

`claim-issue -Candidates` skips parked issues again when no `-SkipLabel` is passed, which is how the `issues-sweep` skill has run it since #4233. In v7.0.0 every parked issue read `free`, and a cleared wait never showed as `stale-park`. The claim's own parking check was the only backstop.

**Score:** 4

#### What makes this deploy extra special

A consumer running `issues-sweep` on v7.0.0 sees every parked issue offered as `free`, and the claim then refuses it. After this release, parked issues are skipped again and cleared waits print as `stale-park`.

**Score:** 3

#### Pull Request

claim-issue -Candidates applies the default parking-label list

Plugins: dkj-repo-workflow

[PR #4250](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4250)

---

### DEPLOY: fix/4246-pin-house-style-caller · 20261117-201426Z

The house-style caller in the `dkj-brandbook` skill is now pinned to the release a repo adopted:
`reusable-house-style.yml@vX.Y.Z` plus `scripts-ref: vX.Y.Z`. #4237 had already pinned the branch-entry,
always-on and repo-settings runners this way (#4246). Before this, a script moved on `main` before a
release turned that gate red in every consumer. The release cut writes both tags beside the checksum
table's tag. To make that possible, a `Get-ReleaseVersionPins` entry takes an optional `Refs` list: the
cut repoints the bare tag after each prefix, and refuses to cut when a prefix has gone missing from the
file.

**Score:** 2

#### What makes this deploy extra special

For the maintainer of a DKJ-Solutions repo with a UI: the brand-book CI gate the skill hands you no
longer goes red when the source moves a script on `main`. It moves when you take a new brand-book
copy. A caller already on `@main` keeps working as before. Copy the new snippet to pin it.

**Score:** 2

#### Pull Request

Pin the house-style caller the dkj-brandbook skill gives to the release, as #4237 pinned the other read-only gates

Plugins: dkj-repo-workflow, dkj-repo-workflow-dkj

[PR #4249](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4249)

---

### DEPLOY: fix/4237-pin-read-only-runners · 20261117-173035Z

Both adoption scaffolders now pin every CI runner they place to the dkj-repo-workflow release they came
from (#4237). The branch-entry and always-on-budget callers from `adopt-workflow-folder` call
`@vX.Y.Z` and pass `scripts-ref: vX.Y.Z`. The repo-settings runner from `adopt-ci-floor` fetches the
shared scripts at the same release, as the write runners have since #2333. This reverses #1805's
choice to keep the read-only runners on main. The #4209 rename moved every script path on main a day
before any release carried it, and every consumer runner on `ref: main` went red at once. Internally,
the register's check 6d reports a read-only runner still on main as an `[INFO]`, and the new
`release-pin-lib.ps1` holds the version read both scaffolders share.

**Score:** 2

#### What makes this deploy extra special

For the maintainer of a repo that adopts the workflow: a newly adopted repo's CI gates no longer go red
when the source moves a script on main before a release. They move when you adopt the release. A
repo adopted earlier keeps its `@main` callers. A re-run of `adopt-workflow-folder` or `adopt-ci-floor`
names the line to change.

**Score:** 3

#### Pull Request

Pin the read-only consumer runners to the adopted release, not main

Plugins: dkj-repo-workflow

[PR #4247](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4247)

---

### DEPLOY: fix/4234-fast-session-start · 20261117-171654Z

The brand book's session check no longer re-reads every file at each session start. It keeps a per-file
cache of what it found, and reads again only the files whose size or write time changed since the last start.
On this repo that took the check from about 9 s to under 1 s on a warm start, and it was the slowest hook a
session start waited for. The CI gate still reads every file.

**Score:** 2

#### What makes this deploy extra special

A session in a repo with the brand book starts several seconds sooner after `/clear` or a new session, typically under 1 s for this check instead of 9 to 20 s.

**Score:** 2

#### Pull Request

The brand book session check caches its scan, cutting about 8 s from a session start

Plugins: dkj-repo-workflow-dkj

[PR #4244](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4244)

---

### DEPLOY: feat/4240-sweep-delegates-build · 20261117-170018Z

`issues-sweep` step 3 now hands the build to a fresh subagent (#4240): the specialist whose craft the
change is, or `general-purpose` on `sonnet`, never a `fork`. Its brief forbids committing, pushing,
opening a PR and writing to the tracker. The sweep's main loop keeps the choosing, parking and
judging. It reads the returned diff before anything ships, and writes the branch document itself. A
change whose brief would be longer than the edit is still built inline.

**Score:** 2

#### What makes this deploy extra special

For whoever runs a sweep: the build, the bulk of a sweep's tokens, now runs on the cheaper subagent
model instead of the session's main model, while the judgement that needs the stronger model stays in
the main loop. Follow-up to #4233, whose page split cut what the skill loads per run.

**Score:** 3

#### Pull Request

issues-sweep: step 3's build goes to a fresh subagent on sonnet, the main loop keeps the judgement

Plugins: dkj-repo-workflow

[PR #4245](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4245)

---

