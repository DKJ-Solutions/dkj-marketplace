# Changelog

## [Unreleased]

**1 / 1 minor entry** <!-- pending-tally -->

### DEPLOY: fix/settings-page-width · 20261103-214954Z

The toolbox's Settings page offers the page width again -- Fluid, Phone or Full -- under the theme. It
lived in the header's settings button, and when that button went the width choice went with it, so
the page could no longer be widened or narrowed from anywhere.

The house style also gains a fifth paper token, `--bg-5`: one step past `--bg-4`, a little lighter on a dark
theme and a little darker on a light one, computed for all twelve themes. No existing colour moved.

**Score:** 3

#### What makes this deploy extra special

Whoever uses the toolbox can switch its page width again, which they lost when the header's settings
button was removed. An app on the house style can now use a fifth paper step, `--bg-5`.

**Score:** 3

#### Pull Request

Settings page gets the page-width choice back, and the house style a --bg-5

Plugins: dkj-policy, dkj-solutions

[PR #3793](https://github.com/DKJ-Solutions/dkj-marketplace/pull/3793)

---

