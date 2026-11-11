# Changelog

## [Unreleased]

**1 / 2 minor entries** <!-- pending-tally -->

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

