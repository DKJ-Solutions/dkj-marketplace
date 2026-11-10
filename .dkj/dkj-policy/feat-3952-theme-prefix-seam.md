## feat/3952-theme-prefix-seam

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

#3952: the reserved theme prefix `dkj-` was hard-coded and written onto every theme a BWJ store's scripts
create, while those repos only consume the plugins. Dave chose `smartwatchbanden-main` (November 10,
2026). The prefix becomes the optional seam `Get-ShopifyThemePrefix`, default `dkj-`, with `dkj-` kept as
a legacy prefix for ownership, the sweep's spare sets, rotation and push-preview's lookup.

### CREATE

- [x] `theme-lifecycle-rules.ps1` (source + mirror): `Set-RepoThemePrefix`, `Get-ThemePrefixRefusal`,
  legacy-aware ownership and backup test, `Get-RepoPreviewThemeNames`, `-Prefix` on the name builder
- [x] `push-preview`, `sweep-preview-themes`, `backup-live-theme` (source + mirror) read the seam and
  refuse an unusable answer; push-preview looks up legacy names, the sweep spares them
- [x] README, `theme-lifecycle` and `push-preview` skill pages: the seam and the move

### TEST

- [x] `theme-lifecycle-rules.tests.ps1`: validation, the store-prefixed names, legacy ownership and
  rotation, bounding under the longer prefix, the sweep sparing a living branch's legacy preview (206 green)
- [x] `push-preview.tests.ps1` and `stranded-sweep-gate.tests.ps1` still green
- [x] Victor's review of the destructive path: no spared theme can be swept; four small findings fixed (a legacy name handed back is not prefixed twice, `backup-` refused in a prefix, `z` in the pattern, a comment count)

### DEPLOY: feat/3952-theme-prefix-seam

A Shopify store repo can name the themes the plugin creates after itself: answer `Get-ShopifyThemePrefix`
in `scripts/repo-config.ps1` (e.g. `'smartwatchbanden-'`), and previews and backups are named
`smartwatchbanden-main`, `smartwatchbanden-fix-x`, `smartwatchbanden-backup-<stamp>` instead of `dkj-...`
([#3952](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3952)). Unanswered, nothing changes.
After the move `dkj-` themes stay the repo's own: the sweep still spares a living branch's preview and
retires a gone one's, rotation still retires an old backup, and `push-preview` finds a branch's existing
preview instead of creating a second.

**Score:** 2

#### What makes this deploy extra special

A store maintainer sees the store's own name on its preview and backup themes instead of a vendor
label, by answering one seam, with no cleanup of the themes already there.

**Score:** 3

#### Pull Request

dkj-subagents-shopify: the reserved theme prefix becomes a per-repo seam
