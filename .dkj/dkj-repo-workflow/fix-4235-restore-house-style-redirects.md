## fix/4235-restore-house-style-redirects

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

#4209's bulk rename rewrote the redirect patterns that keep the brand book's older addresses alive, so
they matched addresses that never existed. Match the real older names again, keep the new ones (harmless),
and also redirect the page's own pre-#4209 address under `dkj-policy`, which a released Admin still links.

### CREATE

- [x] `Resolve-PluginsPageRequest` redirects `/dev/plugins/{dkj-solutions,dkj-policy}/house-style[/<section>]` and `/dev/plugins/dkj-policy/dkj-brandbook[/<section>]` again
- [x] `Resolve-ProductHouseStyleRedirect` reads any `/plugins/dkj-policy/...` address as the same address under `dkj-repo-workflow`
- [x] The comments and the `dev-pages.tests.ps1` asserts carry the real older names again, plus new asserts for the pre-#4209 addresses

### TEST

- [x] `dev-pages.tests.ps1`: 829 passed, 0 failed

### DEPLOY: fix/4235-restore-house-style-redirects

The brand book's older Admin and product addresses (`/dev/plugins/dkj-solutions/house-style`,
`/dev/plugins/dkj-policy/house-style`, `/plugins/dkj-policy/house-style`) redirect to the brand book
again. #4209's rename had rewritten the redirect patterns themselves, so the old names no longer
matched. The brand book's own address from before #4209, under `dkj-policy`, now redirects too, so a
link from a released Admin still lands. The tests pin the real older names again.

**Score:** 2

#### What makes this deploy extra special

An Admin user who follows a bookmark, or a link from an Admin on v6.18.0 or older, lands on the brand book again instead of a 404.

**Score:** 2

#### Pull Request

The older house-style and brand-book addresses redirect again after the #4209 rename

