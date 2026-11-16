## fix/4157-backup-full-store

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

Issue #4157 has three parts. This branch takes two of them, both in `backup-live-theme`: the count before the
duplicate, and the message after it. The full-store refusal names the preview sweep, so the deadlock the issue
measured already resolves at the step that hit it. The third part stays open on the issue: `prepare-release` and
`live-preflight` would order the sweep before the backup when the store is near the limit. That needs a theme-list
read in two more scripts.

### CREATE

- [x] `Get-ThemeSlotVerdict` in `theme-lifecycle-rules.ps1`: pure, Shopify's limit of 20 as a parameter default
- [x] `backup-live-theme.ps1` refuses a full store before the duplicate (a dry run reports it), naming the count and `sweep-preview-themes`
- [x] Its post-duplicate message no longer claims a copy it cannot find was created
- [x] Shopify-plugin mirrors kept byte-identical

### TEST

- [x] `theme-lifecycle-rules.tests.ps1`: the verdict at, below and with a stated limit, and that the script asks before it duplicates and no longer carries the false claim

### DEPLOY: fix/4157-backup-full-store

`backup-live-theme` counts the store's themes before it duplicates live
([#4157](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4157)). At Shopify's limit of 20 it refuses, and
names `sweep-preview-themes` as the step that frees a slot. When the duplicate leaves no copy in the theme list,
it now says so, instead of claiming the copy was created.

**Score:** 2

#### What makes this deploy extra special

On release day in a Shopify store repo holding 20 themes, the backup step stops with "the store is full (20/20)
... sweep spent previews first", instead of a misleading message and a push the preflight then refuses. Sweeping
and re-running clears it.

**Score:** 3

#### Pull Request

backup-live-theme refuses a full store before duplicating, and stops claiming a failed duplicate was created
