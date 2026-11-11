# Changelog

## [Unreleased]

**5 / 6 minor entries** <!-- pending-tally -->

### DEPLOY: feat/3975-tycho-qa-lead · 20261111-102812Z

Tycho, the Test Engineer, now also carries the QA-lead half of the craft: a test plan for a release,
checking work against its acceptance criteria, manual and exploratory testing written down as
repeatable steps where automation does not reach, and running a beta through to an explicit go/no-go
that names every open blocking bug. He reports readiness; the release stays the owner's call. His
manual has a new section, "The QA-lead half", and his agent description says so (#3975).

**Score:** 2

#### What makes this deploy extra special

A team running the core plugin can hand Tycho a release or a beta and get back a test plan, an
acceptance check per criterion with evidence, and a go/no-go, where before he only wrote automated
tests and that half had no owner.

**Score:** 3

#### Pull Request

Tycho: widen the Test Engineer to QA lead work

Plugins: dkj-subagents-alpha

[PR #3982](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3982)

---

### DEPLOY: docs/3978-derek-repository-engineer · 20261111-100459Z

Derek 🐙 #05 is retitled **Repository Engineer** (was DevOps Engineer), the title of the work he already did:
branches, pull requests, merges, labels and `gh`, up to the merge (#3978). Hosting, a product's CI/CD,
monitoring and incident response stay nobody's on this team, and the persona now says so, so infrastructure
work is no longer routed to him by title. Every role reference in the personas, manuals, README and
ADOPTION follows.

**Score:** 2

#### What makes this deploy extra special

A consuming repo's roster (`SPECIALISTS.md`) and Derek's lens title still read "DevOps Engineer" until that
repo edits them; the roster check does not compare titles, so nothing fails, and Derek's own persona reads
Repository Engineer from this release on.

**Score:** 2

#### Pull Request

Derek is retitled Repository Engineer, the title his scope already had

Plugins: dkj-policy, dkj-subagents-alpha, dkj-subagents-shopify

[PR #3988](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3988)

---

### DEPLOY: fix/3979-update-plugins-key-order · 20261111-093636Z

`update-plugins -AllCheckouts` no longer leaves a checkout behind because `claude plugin install/update`
re-serialized its `.claude/settings.json` with another key order or a final newline (#3979). A `.json`
file under `.claude/` whose parsed value is unchanged is now treated like #3792's line-ending-only
rewrite: restored to the committed bytes after the run instead of named as "review and commit", and
restored before the run instead of skipping the checkout as dirty. A real edit still differs once
parsed, so it is still skipped or named. `-DryRun` only says the restore would come.

**Score:** 3

#### What makes this deploy extra special

`update-plugins -AllCheckouts` in a consumer stops skipping a checkout whose only change is such a
rewrite, so that repo takes plugin releases again without a hand `git restore`.

**Score:** 3

#### Pull Request

update-plugins -AllCheckouts restores a .claude/ rewrite that changes key order or a final newline only

Plugins: dkj-policy

[PR #3984](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3984)

---

### DEPLOY: feat/3977-sebastian-privacy-check · 20261111-092252Z

Sebastian, the Security Engineer, now also runs a privacy (GDPR) check before a product that collects
personal data launches, written as a technical check and never as legal advice (#3977).

**Score:** 2

#### What makes this deploy extra special

You can ask Sebastian for a privacy check on a product that stores data about people. He returns an
inventory: what personal data it keeps and why, how long, which processors see it, whether the privacy
statement matches, and whether people can see, correct, export and delete their data. Questions that need
legal judgment come back marked as open for a lawyer, not answered.

**Score:** 3

#### Pull Request

Sebastian: add a privacy / GDPR check beside the security review

Plugins: dkj-subagents-alpha

[PR #3983](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3983)

---

### DEPLOY: feat/3976-cody-tech-lead · 20261111-091251Z

Cody, the App Developer, is now also the tech lead: he records architecture decisions as ADRs, argues a
stack choice from the repo's own constraints, and estimates stories as a range with its assumptions
(#3976).

**Score:** 2

#### What makes this deploy extra special

A team with a backlog to plan had nobody who owned the technical choice before the build or the
estimate per story: Cody built and Victor reviewed code that already existed. Asking Cody for an
estimate or a decision record now has a playbook behind it, including a spike where a story is too
uncertain to estimate.

**Score:** 2

#### Pull Request

Cody: add architecture decisions and estimates to the App Developer

Plugins: dkj-subagents-alpha

[PR #3981](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3981)

---

### DEPLOY: fix/3972-repo-session-issue-list · 20261111-090208Z

`repo-session.ps1 <repo>` lists a repo's open issues one per line again, with each issue's number and title,
instead of one `#System.Object[] System.Object[]` line on Windows PowerShell 5.1 (#3972). The JSON from
`gh issue list` is parsed by `ConvertFrom-IssueListJson` in `scripts/lib/consumer-dashboard-lib.ps1`, which
enumerates after the parse, because 5.1's `ConvertFrom-Json` emits an array as one object. A suite case with
two issues now holds it.

**Score:** 3

#### What makes this deploy extra special

N/A -- `repo-session` is a tool of this hub repo and ships in no plugin.

**Score:** N/A

#### Pull Request

repo-session prints open issues as System.Object[] on Windows PowerShell 5.1

[PR #3980](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3980)

---

