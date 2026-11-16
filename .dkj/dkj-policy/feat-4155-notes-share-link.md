## feat/4155-notes-share-link

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

The issue's first proposal (cut-release's close-out naming the note) was corrected by the owner on the issue: the link
wanted is the shareable page URL that only bwj-development's `publish-page` knows. So all three asks land in that
extension: the runbook `prepare-release` prints, and a read-only check it runs days ahead.

### CREATE

- [x] `publish-page.ps1 -CheckAuth`: prints the shareable link, runs the publish's own `Connect-BwjKv`, writes nothing
- [x] `prepare-release.ps1`: where the repo answers `Get-BwjPagesConfig`, step 8 runs `-CheckAuth` -- READY with the link, or ATTENTION when the token or the login is missing
- [x] `Format-ReleaseRunbook` step 9: names `publish-page.ps1 -Kind notes` (not `-Worker`), and that the close-out leads with the shareable link (printed when known) and names the GitHub Release second
- [x] `publish-page` skill: the `-CheckAuth` row

### TEST

- [x] `bwj-page-publish.tests.ps1`: `-CheckAuth` passes on the token route, prints the link, uploads nothing (190 asserts, green)
- [x] `bwj-development.tests.ps1`: step 9 names the publish, the `-ShowUrl` pointer, the Release second, and a known link on its own line with control characters stripped (1007+ asserts, green)

### DEPLOY: feat/4155-notes-share-link

Inside this repo, `publish-page.ps1` gains `-CheckAuth` and `prepare-release` calls it
([#4155](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4155)). Both suites cover the new lines.

**Score:** 2

#### What makes this deploy extra special

A BWJ store's release runbook now names the release-notes publish it actually runs, `publish-page -Kind notes`.
It also prints the page's shareable link and says the close-out leads with it, so the owner gets the note they
read instead of the GitHub Release. `prepare-release` checks the Cloudflare login days ahead, where it used to
fail only on the release day.

**Score:** 3

#### Pull Request

The release runbook names the shareable release-notes link and checks the page login ahead

