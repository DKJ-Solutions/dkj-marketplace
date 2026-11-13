# Changelog

## [Unreleased]

**9 / 11 minor entries** <!-- pending-tally -->

### DEPLOY: feat/4057-why-reach-label · 20261113-134758Z

`bwj-development` gives the reach label a written reason
([#4057](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4057)). An issue that carries the
reach label now says why in a `## Why <reach label>` section: who notices the defect, and what they
notice. A new PreToolUse hook, `guard-reach-reason`, refuses a `gh issue create` or `gh issue edit` that
adds the label on an admitted repo while the body the call leaves has no such section. It judges
`--body`, `--body-file`, or the issue's current body. A body it cannot read -- one built at run time,
taken from a template, the browser or an editor, or held by an unreachable tracker -- passes with a
warning. Measured in `smartwatchbanden`: 35 issues were filed with `minor` between November 1 and 13,
2026, and none said why.

**Score:** 3

#### What makes this deploy extra special

A session in a store repo that labels an issue `minor` without a written reason is now stopped and shown
the section to write, so every reach-labelled issue a colleague later reads on the board can be checked
against its stated reason.

**Score:** 4

#### Pull Request

bwj-development: the reach label needs a written Why section, and a guard refuses it without one

Plugins: bwj-development, dkj-policy

[PR #4062](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4062)

---

### DEPLOY: feat/4056-asana-open-section · 20261113-133714Z

The new `asana-open-section` template ships with its suite cases and a session-check group, and step 6 of
[`WORKFLOW-portable.md`](../../plugins/dkj-policy/extensions/bwj-development/WORKFLOW-portable.md) now names a third automated move.

**Score:** 3

#### What makes this deploy extra special

A store whose board shows every open issue as in progress can now keep it that way: copy the new
`asana-open-section` workflow (smartwatchbanden's session check asks for it) and a card dragged back into
`1. Todo` while its issue is open returns to `2. In Progress` the next morning. On a board whose `Filed`
is the inbox column it moves nothing.

**Score:** 3

#### Pull Request

bwj-development: a daily sweep keeps the Asana task of an open issue in the Filed section

Plugins: bwj-development

[PR #4060](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4060)

---

### DEPLOY: fix/4053-reach-issue-without-card · 20261113-132840Z

`bwj-development`'s session check `closed-message-sessioncheck` now names, at every session start in a
store or `phone-factory`, the open issues that carry the reach label and link no Asana task
([#4053](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4053)). Until now nothing that runs on
its own noticed a skipped `report-issue` step 2: `guard-asana-mirror` stops only a card without the
label, and only at the call. Measured in `smartwatchbanden`: 34 of 35 reach-labelled issues filed since
November 1 had no card. The finding reuses the open-issue list the check already reads, so it costs no
extra `gh` call.

**Score:** 3

#### What makes this deploy extra special

A store's maintainer sees a new `[ERROR]` line at session start, listing every open reach-labelled issue
whose card is still owed, until `report-issue`'s steps 2-3 have run for each of them.

**Score:** 3

#### Pull Request

bwj-development: report an open reach-labelled issue that has no Asana card at session start

Plugins: bwj-development

[PR #4058](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4058)

---

### DEPLOY: docs/4051-content-product-lead · 20261113-130659Z

Brand-book rule 5 (no intro paragraph under a page's `h1`) gains one opt-in exception: a **content
product**, whose pages brief a reader as a news app does, may carry one plain `<p>` of one or two
sentences under the `h1` where the page sums up content for a reader. Its tool and admin pages keep the
strict rule. A repo opts in with the line `Content product (brand-book rule 5): yes.` in its own facts
rule; without it the strict rule holds. The core README's rule 5 and the `dkj-brandbook` skill both
carry it.

**Score:** 2

#### What makes this deploy extra special

A DKJ-Solutions product built as a reader's briefing, such as dkj-lifehub, may now open a summary page
with a short lead, once its repo declares itself a content product.

**Score:** 2

#### Pull Request

Brand book rule 5: a content product may carry a short lead under its h1

Plugins: dkj-policy, dkj-solutions

[PR #4055](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4055)

---

### DEPLOY: feat/drop-sessionstart-timing-line · 20261113-120126Z

The session-start dispatcher no longer appends its `sessionstart: N s in the dispatcher -- ...` timing
line to the message the person sees. What a session start shows is now the release check's line and
the dev-preview hook's server ports; a start with nothing to say prints nothing at all. A check that
hangs past the deadline is still named in the session's context.

**Score:** 2

#### What makes this deploy extra special

A user of the plugin sees one line fewer at every session start, `/clear` and compaction.

**Score:** 2

#### Pull Request

Session start shows only the release check and the local server ports

Plugins: dkj-policy

[PR #4050](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4050)

---

### DEPLOY: feat/mobile-heading-sizes · 20261113-114737Z

On a phone (760px and narrower) the headings step down a size: `--text-h1` 36 → 28px, `--text-h2`
and `--text-title` 20 → 18px. `--text-h3` and the body sizes do not move. The Figma library carries
the same pair as the `Desktop` and `Mobile` modes of its `Scale` collection.

**Score:** 2

#### What makes this deploy extra special

Every DKJ-Solutions app that takes this brand book shows smaller headings on a phone, so more of a
page fits on the first screen.

**Score:** 3

#### Pull Request

Headings step down a size on a phone

Plugins: dkj-policy

[PR #4049](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4049)

---

### DEPLOY: feat/4046-one-text-token · 20261113-105442Z

The brand book has one text colour: `--fg-1`. `--fg-2`, `--fg-3` and `--fg-4` were steps so close to it that
they could not be told apart, and the Figma wireframes already map all text to one token. `h2`, `h3` and
`.meta` move to `--fg-1`; a quieter text stays `--primary-muted`. The three old names are retired tokens, so
the house-style gate reports a use left behind. The README's stale line that `h2` and `h3` are `--primary` is
corrected ([#4046](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4046)).

**Score:** 3

#### What makes this deploy extra special

An app that takes this brand book renames each use of `--fg-2`, `--fg-3` or `--fg-4` in its own layer to
`--fg-1` (or `--primary-muted` for a quiet text); its `h2`, `h3` and `.meta` become a shade stronger.

**Score:** 3

#### Pull Request

Brand book: one text colour, fg-2..4 retired

Plugins: dkj-policy, dkj-solutions

[PR #4047](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4047)

---

### DEPLOY: feat/4038-figma-token-sync · 20261113-090937Z

A new `figma-tokens` skill keeps the brand book's colour variables in Figma in step with `house-style.css`,
in one direction ([#4038](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4038)). A read-only drift
check runs a script through the Figma MCP's `use_figma` on the brand book's Figma file and compares what it
returns with the stylesheet, per theme: missing, extra and differing collections, modes, values and aliases.
On request, a sync script writes the stylesheet's values into the file's existing layout (`House / Palette
light`, `House / Palette dark` and the aliasing `House / Theme`), creating and overwriting but never deleting.
Colour tokens only. The first check found the file in sync: 3 collections, 75 variables.

**Score:** 3

#### What makes this deploy extra special

N/A: the skill runs in this repo against the brand book's own Figma file, and nothing a consumer runs changes.

**Score:** N/A

#### Pull Request

Skill: check and sync brand book colour tokens to Figma variables

Plugins: dkj-solutions

[PR #4045](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4045)

---

### DEPLOY: docs/4040-wireframe-token-mapping · 20261113-015209Z

The brand book README now maps every colour of the Figma `Wireframe` collection to the house token it
becomes, and each variable carries the same mapping in its Figma description
([#4040](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4040)). The wireframes stay grey and
are not aliased. The two wireframe text greys both become `--primary-muted`, because the brand book has
one tone for what may recede.

**Score:** 2

#### What makes this deploy extra special

N/A: the mapping guides how Admin's visual design is made in this repo, and nothing a consumer runs changes.

**Score:** N/A

#### Pull Request

Wireframe colour variables: the role mapping to the house tokens, in Figma and in the brand book README

Plugins: dkj-policy

[PR #4044](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4044)

---

### DEPLOY: fix/4041-closed-message-waits-for-trunk-sync · 20261113-012644Z

`closed-message-sessioncheck` now waits for dkj-policy's trunk sync before it reads a store's tree
([#4041](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4041)). It ran as its own SessionStart
entry beside the dispatcher, so in xoxowildhearts it reported the prio-label pair and
`Get-ResolvesExemptMatchers` missing, and the same session start then fast-forwarded `main` by 34
commits that brought both in. It now waits up to 20 s for the dispatcher's prep-done mark, as the
dev-preview hook does (#3657), with `session-cache-lib` and `hash-hex-lib` mirrored into bwj-development.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a BWJ store stops getting `[ERROR]` lines at session start for files the same
session start brings in. Those lines made them re-run `adopt-bwj-development` for work already merged,
and taught them to skip the one error that was real.

**Score:** 2

#### Pull Request

closed-message-sessioncheck waits for the trunk sync before it reads the tree

Plugins: bwj-development

[PR #4043](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4043)

---

### DEPLOY: feat/radius-three-steps · 20261113-011101Z

The brand book's radius scale is cut from six steps to three plus the pill, one per role: `--radius-1` (4px)
for a small element, `--radius-2` (8px) for a control, `--radius-3` (12px) for a container. `--radius-1-5`
folds into `--radius-2`, and `--radius-2-5` and `--radius-4` into `--radius-3`; the three old names are
retired tokens, so the house-style gate reports a use left behind. The migration table is in the brand book
README, and the Figma library's `Scale` collection carries the same four steps.

**Score:** 3

#### What makes this deploy extra special

An app that takes this brand book renames each use of the three retired radius tokens in its own layer, and
its controls, small cards and dialogs change their corners (6 to 8px, 10 to 12px, 16 to 12px).

**Score:** 4

#### Pull Request

Brand book radius scale cut to three steps plus pill

Plugins: dkj-policy, dkj-solutions

[PR #4042](https://github.com/DKJ-Solutions/dkj-marketplace/pull/4042)

---

