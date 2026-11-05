# Changelog

## [Unreleased]

**7 / 7 minor entries** <!-- pending-tally -->

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

