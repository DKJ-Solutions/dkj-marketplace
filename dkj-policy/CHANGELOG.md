# Changelog

## [Unreleased]

**10 / 10 minor entries** <!-- pending-tally -->

### DEPLOY: feat/tools-crumb-root · 20261102-214200Z

The toolbox's first crumb, **Tools**, and the site-header name now link `/`, the toolbox's own root,
instead of `/hub`. Both addresses render the same home page, so nothing a reader lands on changes; the URL
in the address bar is simply the plain one. `/hub` still answers, so a bookmark or an old link keeps
working. The README's crumb paragraph no longer describes the product relay retired with #3540 as live.

**Score:** 2

#### What makes this deploy extra special

A toolbox user who clicks Tools sees `localhost:<port>/` in the address bar rather than `/hub`; the page
is the same.

**Score:** 1

#### Pull Request

The Tools crumb on the toolbox goes to / instead of /hub

Plugins: dkj-policy

[PR #3762](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3762)

---

### DEPLOY: feat/3758-live-push-merged-only · 20261102-213141Z

`guard-live-theme` no longer lets the live-push marker authorise a push on its own (#3758). An
authorised live push must also carry only what `origin/<trunk>` holds: every `--only` file must match
the trunk byte for byte (a line-ending difference aside), a file the push would delete must be absent
from the trunk too, and a push without `--only` needs a clean root whose commit equals the trunk. The
refusal names each file and says to merge first. A pattern or directory in `--only`, a shell-expanded
value, a `cd`, `--environment`, a `SHOPIFY_FLAG_ONLY`/`_PATH`/`_ENVIRONMENT` on the line, or a missing
`origin/<trunk>` is refused, because what it would push cannot be read. The trunk is
`Get-TrunkBranchName`, default `main`. A second live push on the same line is measured too.

**Score:** 3

#### What makes this deploy extra special

In a Shopify store repo, a live push of work that is not merged into the trunk is now refused even with
the marker, so live can no longer hold work the trunk lacks, which a later push from the trunk would
silently revert. The step-7 push `live-preflight` composes from the merged trunk passes as before.

**Score:** 3

#### Pull Request

guard-live-theme refuses a live push of content the trunk does not hold

Plugins: dkj-subagents-shopify

[PR #3763](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3763)

---

### DEPLOY: feat/site-header-brand-hit-area · 20261102-205736Z

The house site header's brand link is no longer only its text: the whole cell from the bar's left edge to the end of the name, top to bottom, goes home, and it lights up on hover in the header's hover shade -- the same shape the settings cell has at the bar's right end.

**Score:** 2

#### What makes this deploy extra special

Every page built on the brand book gets a larger, visible home target in its header, so going home no longer needs a click on the text itself.

**Score:** 2

#### Pull Request

The site header's brand link fills the bar's full height as one clickable cell

Plugins: dkj-policy

[PR #3760](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3760)

---

### DEPLOY: feat/site-header-nav · 20261102-190626Z

The house site header can carry an app's main pages between its name and the settings button. On a wide header they stand as full-height cells with the page you are under marked; narrower than 48rem they fold into a three-line toggle that opens them as the house drawer. The toolbox's menu is its home page's cards, a product's its own pages.

**Score:** 3

#### What makes this deploy extra special

Every page of the toolbox, and of an app that adds a menu to its header, can be reached from every other page in one click, on a phone too, instead of going back home first.

**Score:** 3

#### Pull Request

The site header carries a menu between the brand and the settings, folding into a drawer on a phone

Plugins: dkj-policy

[PR #3759](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3759)

---

### DEPLOY: feat/3745-one-h1-per-page · 20261102-184846Z

The brand book now states that a page carries exactly one `h1`: content a page renders (a lens, a release
note, any markdown) never adds its own, and the home page under a site header is the one page without one
(rule 9, #3745). The hub's page shell checks the rule on sight. The fit alarm in the bottom right also
warns when the live page holds more than one `h1`, or none where its trail is longer than Home. It counts
the live document, so a body rendered after load is judged too, and it is not width-gated.

**Score:** 2

#### What makes this deploy extra special

Anyone opening a page in the hub (this repo's or a consumer's toolbox) now sees a warning when that page
carries two `h1`, where before nothing said so. A page that keeps the rule sees nothing new.

**Score:** 2

#### Pull Request

Brand book: a page carries exactly one h1, stated and checked

Plugins: dkj-policy

[PR #3757](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3757)

---

### DEPLOY: feat/3752-release-note-heading-rules · 20261102-181642Z

`check-release-note-form` now holds the newest release note's `h1`-`h3` headings to the brand book's rules 7
and 8 in a repo that has `dkj-solutions` enabled (#3752). A heading may carry no code span and no more than
five words. Each offending line is named with its number under a `[HEADING]` label, apart from form drift.
The rules are the brand book's rather than the draft's, so they live in their own function,
`Get-ReleaseNoteHeadingFindings`, and a repo outside DKJ-Solutions is not held to them.

**Score:** 2

#### What makes this deploy extra special

In a DKJ-Solutions repo, the release-notes step of a cut now refuses a note whose section heading holds a
code span or runs past five words, and names the line, before the note is published. A BWJ-Development
repo sees no change.

**Score:** 2

#### Pull Request

check-release-note-form refuses a code span or more than five words in a release note's h1-h3 heading

Plugins: dkj-policy

[PR #3756](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3756)

---

### DEPLOY: feat/3751-lane8-gone-checkout-handover · 20261102-171648Z

`tidy-machine` lane 8 now hands over the removal of an install record whose checkout is gone (#3751).
`claude plugin uninstall` takes no path and picks the record from the directory it runs in, so for each
vanished folder the lane prints `mkdir` the folder, `cd` into it, one uninstall per record at that
record's own scope, `cd ..`, and `rmdir`, which removes only an empty folder. Until now it printed
"nothing here guesses" and no command, though moved or deleted the old record is dead either way.

**Score:** 2

#### What makes this deploy extra special

When `tidy-machine` reports install records for a checkout that no longer exists, it now prints the
commands that remove them, ready to paste. Run them only for a folder that is gone for good. A drive that
is not mounted, or a synced folder that is offline, looks the same.

**Score:** 2

#### Pull Request

tidy-machine lane 8 hands over the recreate-and-uninstall sequence for a gone-checkout record

Plugins: dkj-policy

[PR #3755](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3755)

---

### DEPLOY: fix/3747-checkout-v7 · 20261102-164702Z

Every `actions/checkout` pin in the tree moves from v5 to v7 (#3747): this repo's own workflows, the
reusable ones consumers call, the CI floor and the Shopify floor that `adopt-ci-floor` and
`adopt-shopify-floor` write, and the two `bwj-development` Asana templates. The SHA-pinned write-capable
runners take `3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`, still equal across the generator and this
repo's own copies, as `pin-parity` requires.

**Score:** 2

#### What makes this deploy extra special

If Dependabot has moved your workflows to `actions/checkout@v7`, re-adopting a scaffold no longer puts v5
back. If yours are still on v5, a re-adopt now writes v7. One behaviour changes with it: `merge-on-green`
now refuses to check out a pull request from a fork, which v7 blocks under `workflow_run`.

**Score:** 2

#### Pull Request

Every actions/checkout pin moves from v5 to v7, scaffolds and this repo's own runners alike

Plugins: bwj-development, dkj-policy, dkj-subagents-shopify

[PR #3754](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3754)

---

### DEPLOY: fix/release-notes-headings-no-code · 20261102-163529Z

The brand book gains rule 8 (Maikel, November 2, 2026): an `h1`, `h2` or `h3` has five words at most,
in its README and in the `dkj-brandbook` skill. The v6.3.0 release notes now follow rules 7 and 8: no
`code` element in a heading, and every heading at five words or fewer. Who a change is for moved into the
text under it. On the release-notes page each h3 and its text now stand in a house card of their own, in
the grid form the brand book's own pages use, and the note no longer wraps them in a panel. A gate in the release-note form check is #3752.

**Score:** 1

#### What makes this deploy extra special

A session building a page in a DKJ-Solutions repo now keeps every heading to five words and puts who it is for in the content under it.

**Score:** 2

#### Pull Request

Release notes: short headings, no code in them, each h3 section a card

Plugins: dkj-policy, dkj-solutions

[PR #3753](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3753)

---

### DEPLOY: docs/no-code-in-headings · 20261102-160112Z

The brand book gains a rule (Maikel, November 2, 2026): no `code` element inside an `h1`, `h2` or `h3`,
because a fixed-width run in a heading looks out of place. It is rule 7 in the brand book's README and a
bullet in the `dkj-brandbook` skill, so a session reads it before any visual work.

**Score:** 2

#### What makes this deploy extra special

A session building a page in a DKJ-Solutions repo now names things in plain words in its headings and
keeps file names, commands and identifiers for the content under them.

**Score:** 2

#### Pull Request

Brand book: no code element inside an h1, h2 or h3

Plugins: dkj-policy, dkj-solutions

[PR #3750](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3750)

---

