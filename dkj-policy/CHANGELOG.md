# Changelog

## [Unreleased]

**13 / 17 minor entries** <!-- pending-tally -->

### DEPLOY: fix/3857-settle-verdict · 20261106-154057Z

A merge-on-green runner placed before #3810 kept the settle-window gap indefinitely, and nothing said so:
a re-run of `adopt-ci-floor` judged it fine, and moving its `ref:` pin did not help, because the wait is
a YAML flag. A re-run now names such a runner under `[settle]`, with the flag to append
([#3857](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3857)).

**Score:** 2

#### What makes this deploy extra special

A repo that adopted merge-on-green before #3810 sees a `[settle]` line the next time it re-runs
`adopt-ci-floor`. Appending `-WaitForSettleSeconds 660` to the picker line stops the last pull request
to go green from waiting hours for the schedule.

**Score:** 3

#### Pull Request

adopt-ci-floor: report an existing merge-on-green.yml whose picker lacks -WaitForSettleSeconds

Plugins: dkj-policy

[PR #3858](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3858)

---

### DEPLOY: fix/3849-product-patterns · 20261106-112402Z

The brand book's two product pattern pages draw a product, not the hub as it was before #3830:
`patterns/product-home.html` and `patterns/product-page.html` in dkj-solutions (formerly `repo-dashboard.html`
and `repo-repository.html`) show the site header with its menu, the breadcrumb bar and the cards, and the
brand book names `patterns/admin-shell.html` as Admin's reference
([#3849](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3849)). A repo that copied the old files keeps
them; a product without a build starts from the new ones.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The brand book's product patterns draw a product home, not the pre-#3830 hub

Plugins: dkj-policy, dkj-solutions

[PR #3855](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3855)

---

### DEPLOY: docs/3852-skill-breadcrumb-shell · 20261105-181439Z

The `dkj-brandbook` skill no longer tells a session that Admin's pages open with the breadcrumb bar: a product
page does, and an Admin page carries its trail in the desktop shell's bar
([#3852](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3852)). The failure it prevents: a session
building an Admin page from the skill adds a breadcrumb bar above the shell.

**Score:** 1

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The dkj-brandbook skill says Admin's shell carries its trail in its bar, not a breadcrumb bar

Plugins: dkj-solutions

[PR #3854](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3854)

---

### DEPLOY: docs/3851-site-header-settings · 20261105-180005Z

The product layer's README says the site header's settings button is optional, as the dev servers have drawn
the header without one since November 3, 2026, choosing the theme on a Settings page; an app that mounts the
button keeps its styling ([#3851](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3851)).

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The product README makes the site header's settings button optional, as the dev servers have drawn it since November 3

Plugins: dkj-solutions

[PR #3853](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3853)

---

### DEPLOY: docs/3843-hub-home-shell · 20261105-173340Z

The brand book's "The hub" and the hub README describe Admin's home and GitHub page as the desktop shell draws
them since #3830: the shell's bar and side navigation with no toolbar on the home page, then one `.table--dense`
of links, a row per page
([#3843](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3843)). The site header and card grid they
used to describe are the product layer's.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

The hub docs describe Admin's home as the desktop shell draws it

Plugins: dkj-policy

[PR #3850](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3850)

---

### DEPLOY: feat/3846-parked-review-takeover · 20261105-170739Z

`/issues-sweep-reviews` can now approve and ship a branch a co-owner parked for review: its claim step
runs `claim-issue.ps1 -Tag -TakeOver -Parked`, which moves another account's claim only when the issue
carries `awaiting-review-dev` ([#3846](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3846)).
Outside a parked review the colleague refusal is unchanged (#2207).

**Score:** 3

#### What makes this deploy extra special

A repo with two owners no longer has its review pass hold out half the parked work; whichever owner
types the command can approve the other's branch, and the approval comment names whose work it was.

**Score:** 2

#### Pull Request

issues-sweep-reviews: let an owner approve a co-owner's parked branch

Plugins: dkj-policy

[PR #3848](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3848)

---

### DEPLOY: feat/3831-brandbook-product-split · 20261105-165433Z

The DKJ-Solutions brand book is now two files. `dkj-policy` ships the core and Admin's desktop shell
(`house-style.css`, `house-theme.js`). The mobile-first product layer is `house-product.css`, shipped by the
`dkj-solutions` plugin alone, with its own README, specimens and reference pages. A product page links it after
the core, and Admin never loads it. The page builders follow the same line. dkj-policy draws Admin pages only.
The product's site header, breadcrumb bar and page column are dkj-solutions' `product-pages-lib.ps1`. The
dkj-brandbook skill pins all three files, and the gate holds a vendored `house-product.css` to that pin and
counts its classes as house classes. An Admin-only repo, such as every BWJ-Development repo, vendors and loads
the core alone.

**Score:** 3

#### What makes this deploy extra special

A DKJ-Solutions product repo that vendors the brand book must add `house-product.css` beside its copy of
`house-style.css` and link it after the core. Without it, the product's site header, breadcrumb bar, forms and
dialogs lose their styling once that repo takes the new core. A repo that renders only Admin needs nothing.

**Score:** 4

#### Pull Request

Brand book: core + Admin in dkj-policy, product layer only in dkj-solutions

Plugins: dkj-policy, dkj-solutions

[PR #3847](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3847)

---

### DEPLOY: feat/3816-goals-page · 20261105-154303Z

Admin has a **Goals** page on `/dev/goals`, the first of its own pages, with a `plan-goal` skill beside it
([#3816](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3816)). A goal is an open GitHub issue
labelled `goal`, its milestones are its sub-issues, and their tasks are theirs, so the page moves as sessions
claim and close issues, with no second administration. Per goal the page shows its progress, one prominent
**Now** card (the first open task of the first open milestone, or a milestone still to break down), a short
**Next** row and the milestones collapsed, each with a progress bar. The skill asks a few questions, proposes
4 to 6 milestones with session-sized tasks, and once the owner agrees files them as linked sub-issues
(`plan-goal.ps1 -PlanFile <plan> -Apply`). `plan-goal.ps1 -Next` answers "what now?" in the terminal.

**Score:** 3

#### What makes this deploy extra special

Every repo running `dkj-policy` gets a planning board that is never out of date, because it is the tracker
itself: on a project too big to see the first step of, Admin names that step.

**Score:** 3

#### Pull Request

Goals: an Admin page and a plan-goal skill (goal -> milestones -> tasks as GitHub sub-issues)

Plugins: dkj-policy

[PR #3845](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3845)

---

### DEPLOY: fix/3841-frame-ancestors-sentences · 20261105-153137Z

The hub's README no longer says that its pages can be framed by a page that is not refused. Since #3835 every response
forbids framing, and the paragraph on the Fetch Metadata check now says so.

**Score:** 1

#### What makes this deploy extra special

It corrects a contradiction between two merged branches. Nothing about the behaviour changes.

**Score:** 1

#### Pull Request

Hub: the docs say the loopback pages forbid framing, as they do since #3835

Plugins: dkj-policy

[PR #3844](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3844)

---

### DEPLOY: docs/3839-closeout-offers-the-fix · 20261105-151649Z

Chris closes a status question about your stuck work differently now. Where his answer finds a fix he can carry out
in the same session, the receipt ends with one plain line offering it, for example *"I can fix the assert and ship
#3816 now -- shall I?"*. Before, it ended on *"the session can be cleared"* and left you to ask. He still acts only
after your yes.

**Score:** 2

#### What makes this deploy extra special

A wording sharpening with a measured instance behind it. The always-on persona grows by three lines.

**Score:** 1

#### Pull Request

Close-out: a status question about stuck work offers the fix it found

Plugins: dkj-subagents-alpha

[PR #3842](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3842)

---

### DEPLOY: feat/3817-admin-nav-search · 20261105-150658Z

Admin's side navigation now opens on a search field. Press Ctrl K (Cmd K on a Mac) anywhere in Admin to jump to it,
type part of a page's name or description, and Enter opens the first match. It finds every page in the navigation and
the pages under its groups, such as Rules, Skills and Stopwatch, so none of them is more than a few keystrokes away.
The brand book's desktop shell gains the field as `.nav-search`.

**Score:** 3

#### What makes this deploy extra special

A Toolbox user reaches any Admin page from the keyboard, without clicking through a group page first.

**Score:** 3

#### Pull Request

Admin's navigation opens on a search field, focused with Ctrl K

Plugins: dkj-policy

[PR #3840](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3840)

---

### DEPLOY: fix/3835-loopback-frame-ancestors · 20261105-145612Z

Every page the hub and the product's dev server answer with now carries `Content-Security-Policy: frame-ancestors
'none'` and `X-Frame-Options: DENY`. Until now a page on another localhost port could frame them, because a
same-site frame passes the request guard as a navigation. That has not been seen to happen. The point is
that the airsquats `POST /api/airsquats/clear` can no longer be click-jacked from a frame.

**Score:** 1

#### What makes this deploy extra special

Nothing changes that the user sees. It closes a framing route before anything uses it, which is the whole point of a
second barrier.

**Score:** 1

#### Pull Request

Loopback servers: send frame-ancestors 'none' as a second barrier against framing

Plugins: dkj-policy

[PR #3838](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3838)

---

### DEPLOY: feat/3830-admin-fully-in-shell · 20261105-144508Z

Admin's pages now stand fully in the desktop shell. Wherever a page listed the pages under it as a grid of cards, it now shows one compact table, a row per page with its description, under the section's heading: the home page, the GitHub page, Claude, Performance, the plugins and each plugin's contents, the brand book overview, SessionStart, the Test gate, the Stopwatch and the Logbook, and the release notes. Every page's title sits in the toolbar above the pane. The warning that flags a page that does not fit now reads the shell: the pane's own height, the toolbar's title and the bar's trail. A product's own pages keep their cards.

**Score:** 2

#### What makes this deploy extra special

Anyone who opens Admin after updating sees its overviews as tables instead of cards. Nothing needs to be done.

**Score:** 2

#### Pull Request

Admin pages fully in the desktop shell

Plugins: dkj-policy

[PR #3837](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3837)

---

### DEPLOY: fix/3834-cross-site-top-level-get · 20261105-143153Z

The Admin and product servers now serve a cross-site top-level `GET` navigation into a document, so Claude
in Chrome can open their pages. Every other cross-site request, a frame included, is still refused, and the
403 names the `Sec-Fetch-*` headers it judged.

**Score:** 3

#### What makes this deploy extra special

A session driving Chrome can open the Admin page it built and look at it before handing it to the owner.

**Score:** 3

#### Pull Request

Admin serves a cross-site top-level GET navigation, so Claude in Chrome can open it

Plugins: dkj-policy

[PR #3836](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3836)

---

### DEPLOY: fix/3829-reviews-resolve-look-step · 20261105-141408Z

`issues-sweep-reviews` now resolves a parked branch's "the owner looks" step with the approval before it
ships, and `issues-sweep` step 6 does the same. Without it `open-pr`'s step gate refused every branch the
skill was meant to ship.

**Score:** 3

#### What makes this deploy extra special

An owner who approves parked visible results in one `/issues-sweep-reviews` pass sees them ship, instead of
every one being refused on its own plan.

**Score:** 3

#### Pull Request

issues-sweep-reviews: resolve the plan's owner-look step before ship-pr

Plugins: dkj-policy

[PR #3833](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3833)

---

### DEPLOY: feat/3818-admin-objects-seam · 20261105-140226Z

A repo can now put its own domain objects at the top of Admin's navigation, right under Home: state
`Get-AdminObjects` in `scripts/repo-config.ps1`, returning `@{ Label; Href; Count }` items, and each shows with its
count as a badge. The repo's own server serves the pages they link to: a path such as `/tracks` opens on the
product's address, and a full http(s) URL opens as given. A repo that states nothing sees no change.

**Score:** 3

#### What makes this deploy extra special

The maintainer of a repo with its own data (tracks, playlists, recipes) can reach its management pages from Admin's
navigation, with the counts in view, instead of keeping them outside it.

**Score:** 3

#### Pull Request

A repo's domain objects in Admin's navigation, from a Get-AdminObjects seam

Plugins: dkj-policy

[PR #3832](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3832)

---

### DEPLOY: feat/3820-dismiss-toast · 20261105-134848Z

The airsquats toast on every Admin page now has a close button at the end of its row. It puts the toast away without
ticking the squats off, and it stays away in that tab until another hour comes due or the hub goes offline again.

**Score:** 2

#### What makes this deploy extra special

A user of the Toolbox who does not want the reminder on screen right now can close it, instead of ticking off squats
they have not done.

**Score:** 2

#### Pull Request

The airsquats toast gets a close button

Plugins: dkj-policy

[PR #3828](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3828)

---

