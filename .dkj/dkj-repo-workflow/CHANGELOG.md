# Changelog

## [Unreleased]

**3 / 3 minor entries** <!-- pending-tally -->

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

