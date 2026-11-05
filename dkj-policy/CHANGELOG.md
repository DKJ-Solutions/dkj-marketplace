# Changelog

## [Unreleased]

**4 / 4 minor entries** <!-- pending-tally -->

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

