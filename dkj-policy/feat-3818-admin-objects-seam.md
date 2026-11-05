## feat/3818-admin-objects-seam

> **How this file is read.** A step is `- [ ]` until it is resolved -- `- [x]` done, or
> `- [~]` dropped with the reason, which exists so nobody ticks a box for work they did not do.
> open-pr and ship-pr both refuse while one is still open, and there is no `-Force`.
>
> **FOUR `###` HEADINGS, AND NEVER A FIFTH** -- PLAN, CREATE, TEST, DEPLOY are the whole top
> level. A section needing its own heading goes in as a `####` UNDER whichever of the four owns
> it. No gate in YOUR repo reads a heading, so this half is on you -- only the repo that authors
> this workflow refuses a fifth (Dave, August 26, 2026).
>
> **AND NOTHING BRANCH-SPECIFIC ABOVE THE FIRST OF THOSE FOUR HEADINGS** -- everything between the
> title and it is this guidance, which is identical in every branch document. A status line, a note about
> THIS branch or an instruction to a session belongs under one of the four, normally as a `####`
> in PLAN. THIS half open-pr refuses, in every repo, before the push -- it reads the shape, so a
> guidance block in your own language passes and your own paragraph here does not (Dave,
> August 26, 2026; refused since #1650).
>
> **DEPLOY takes no steps of its own, and it is WRITTEN LAST** -- it is what the branch DID, once
> TEST says so. Written while steps above it are still open it states an INTENTION, and no gate
> holds it against what landed: the step gate splits this file at that heading and counts only
> above it. The PR title is the one exception -- new-branch -Title writes it at creation, because
> open-pr composes the PR title from it. It is the one part of this file that travels verbatim
> into `CHANGELOG.md` at the merge. In each tier, write the reason
> ABOVE the Score line -- anything below it is discarded.
>
> Relative links in that text resolve FROM THIS DIRECTORY -- `CHANGELOG.md` sits here too, so
> write each path exactly as it reads in this file.
>
> For tier 2 audiences: the user who relies on what this repo ships, and decides whether to take the next version -- a subscriber of a service, or the user of a tool, its own maintainer included. That reader and nobody else -- what matters only
> inside this repo belongs under the first `**Score:**`. If the change reaches that reader
> not at all, N/A is a complete answer and the common one. **One hop and no further:** where that
> reader is itself a business, ITS own customers sit one hop past this repo and are never the reader
> here -- they take nothing this repo ships. Name the party that runs the upgrade, and score
> against them.
>
> The phase arc, the marks and the whole form: `DEVELOPMENT-portable.md`, which ships
> with this workflow.

### PLAN

#3818: Admin's navigation (#3815) reserves the top level, right under Home, for a repo's domain objects, but
`Get-AdminNav` had no seam for them. The issue left open who serves the routes those items point at.

#### The decision on the routes

**The repo's own server, not a hub extension.** The hub never loads a repo's code into its own process (every read of
`repo-config.ps1` runs in a child), so it cannot serve a repo's pages without giving that up. The repo's server already
runs the repo's code and can draw its management pages in the brand book's desktop shell. So a path (`/tracks`) is
resolved against the product's address, and an http(s) URL is kept. A hub extension stays possible later, and nothing
here blocks it.

### CREATE

- [x] `general-pages-lib.ps1`: `Set-AdminObjects` (reads the items defensively: label, a root path or an http(s) URL, a
      whole-number count, at most 12) and `Resolve-AdminObjectHref`; `Get-AdminNav` puts them right under Home, and
      `Format-AdminShellOpen` draws the count as `.nav-item__count`.
- [x] `serve-general-pages.ps1`: `Get-AdminObjectsModel` reads `Get-AdminObjects` in a bounded child process, only
      where `repo-config.ps1` names it, cached for a minute.
- [x] `hub/README.md`: the navigation table's top row names the seam and the route decision.
- [x] `dev-pages.tests.ps1`: six asserts on the placement, badges, resolution, rejects, the cap and the server read.

### TEST

- [x] `dev-pages.tests.ps1` on its own: 604 passed, 0 failed.
- [x] The child read run for real against a temporary `repo-config.ps1` stating two objects: both came back, the path
      resolved on the product's address, and an item without a count drew no badge.
- [ ] The owner looks at Admin in a repo that states `Get-AdminObjects`: the objects under Home with their counts.

### DEPLOY: feat/3818-admin-objects-seam

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

