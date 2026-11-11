# Changelog

## [Unreleased]

**0 / 1 patch entry** <!-- pending-tally -->

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

