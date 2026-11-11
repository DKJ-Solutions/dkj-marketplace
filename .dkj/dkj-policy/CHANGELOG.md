# Changelog

## [Unreleased]

**10 / 12 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3993-handover-dkj-policy-root · 20261111-125848Z

`build-handover-page.ps1` runs from an installed plugin again. It looked for dkj-policy's Admin libs four
directories above itself, which only holds in the source tree, so in the plugin cache it failed before
building anything. It now also finds dkj-policy as the sibling plugin in the cache, at its own version
(#3993).

**Score:** 2

#### What makes this deploy extra special

A BWJ store repo can build the preview handover page with the script as shipped, instead of copying the
plugin's files to a temporary folder and running the copy with `-RootOverride`.

**Score:** 3

#### Pull Request

build-handover-page finds dkj-policy's root in the plugin cache

Plugins: bwj-development

[PR #3994](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3994)

---

### DEPLOY: feat/3973-priya-product-owner · 20261111-124900Z

The core team has a new specialist: **Priya 🧩, the Product Owner** (`02-31`). She owns the *what* and
the *why* of a product: its goals, user stories with acceptance criteria, the order of the backlog, and
scope held as a budget (MoSCoW: something in means something out). She proposes and the owner decides.
Paula keeps *when*; `plan-goal` stays the mechanism that files an agreed breakdown (#3973).

**Score:** 3

#### What makes this deploy extra special

A repo running the core team gets a specialist who writes stories with checkable acceptance criteria
and orders the backlog, where before nobody on any team owned scope. After updating the plugin, the
roster check reports her as missing from the roster: run `sync-roster` to adopt her, which places an
empty lens and proposes the roster line.

**Score:** 3

#### Pull Request

Priya: a Product Owner / Product Manager specialist in the core team

Plugins: dkj-subagents-alpha

[PR #3985](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3985)

---

### DEPLOY: fix/3987-portable-layer-names · 20261111-111453Z

Manuals and personas now follow a rule instead of a measurement: they may cite an issue of this source repo
as provenance, and name no other repo and no person (#3987). Check 47 of `check-plugin-integrity.ps1`,
`[portable-names]`, holds the line, after the six person names in the manuals became "the owner". Tessa's
lens states the rule in place of a table that had been falsified twice (#701, #3987).

**Score:** 2

#### What makes this deploy extra special

Four shipped manuals in `dkj-subagents-alpha` and `dkj-subagents-shopify` attribute a decision to "the
owner" instead of a named person; the rules themselves are unchanged.

**Score:** 1

#### Pull Request

Manuals and personas may cite an issue number, never a repo or a person, and a lint check holds that line

Plugins: dkj-subagents-alpha, dkj-subagents-shopify

[PR #3992](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3992)

---

### DEPLOY: feat/3974-uma-ux-designer · 20261111-110007Z

The core team has a new specialist: **Uma 🖱️, the UX Designer / UX Researcher** (`04-32`). She owns
how a product works for its users: she prepares interviews and usability tests and synthesises what
comes back into findings tied to their evidence, tears competitors down from the user's side, and
designs user flows (unhappy paths included), wireframes and a clickable prototype. Gwen stays the
visual designer and takes Uma's tested flow further (#3974).

**Score:** 3

#### What makes this deploy extra special

A repo running the core team gets a specialist for user research and interaction design, where
before nobody on any team owned either. She never invents users: she prepares the session, the
owner runs it, and she reads the result. After updating the plugin, the roster check reports her as
missing from the roster: run `sync-roster` to adopt her, which places an empty lens and proposes the
roster line.

**Score:** 3

#### Pull Request

Uma: a UX Designer / UX Researcher specialist in the core team

Plugins: dkj-subagents-alpha

[PR #3989](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3989)

---

### DEPLOY: docs/changelog-heading-3988 · 20261111-104934Z

`CHANGELOG.md`: the pending entry for #3988 gets back the section heading its tier-2 text belongs under, so
the next pull request is no longer refused by the lint gate's `[entry-heading]` check (#3986).

**Score:** 1

#### What makes this deploy extra special

N/A -- only this repo's pending changelog changes.

**Score:** N/A

#### Pull Request

Restore the tier-2 heading of #3988's folded changelog entry

[PR #3990](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3990)

---

### DEPLOY: fix/3986-deploy-missing-tier-heading · 20261111-103650Z

An entry whose audience-tier heading was deleted while both `**Score:**` lines stayed is now refused by
`open-pr` and `check-branch-entry` before the push (#3986). Until now the shared entry parser read the
second Score line as text under the first, so the entry declared tier 0 alone with every gate green. The
fold then wrote it into `CHANGELOG.md`, where `[entry-heading]` refused the next PR on somebody else's
branch. A second Score line with no heading between it and the first now names the heading to put back.
#3984's entry, which slipped through that way, gets its heading back here too.

**Score:** 3

#### What makes this deploy extra special

A DEPLOY section that lost its audience-tier heading is refused at your own `open-pr` with the heading to
restore. It no longer passes your gates and then drops its audience score silently from the release.

**Score:** 2

#### Pull Request

Refuse a DEPLOY section whose audience-tier heading is missing

Plugins: dkj-policy

[PR #3991](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3991)

---

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

