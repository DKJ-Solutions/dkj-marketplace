## feat/3733-backup-verify-existing

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

Resolves #3733 (split out of #3729, ask 3): a backup that timed out leaves its copy standing, and a
retry duplicated live again. Add `-VerifyExisting <id>` to `backup-live-theme` and a pass-through in
`live-preflight`, refusing any id outside this repo's backup namespace. #3732 (the fill wait) touches
the same script in another session, on a different part of it.

### CREATE

- [x] `Get-ExistingBackupVerdict` in `scripts/lib/theme-lifecycle-rules.ps1`: refuses an empty id, an id
  the theme list lacks, the live theme, a name outside the backup namespace, and a backup with role
  live/main
- [x] `backup-live-theme.ps1 -VerifyExisting <id>`: skips the create, verifies and rotates the adopted
  copy; the dry run plans rotation with it as the survivor
- [x] `live-preflight.ps1 -BackupVerifyExisting <id>` passes it through
- [x] Shopify plugin mirrors synced byte-identical; both skill pages' parameter tables name the new option

### TEST

- [x] `theme-lifecycle-rules.tests.ps1`: every refusal plus the adoption and its rotation -- 151 pass, 0 fail
- [x] All three scripts parse, and stay ASCII

### DEPLOY: feat/3733-backup-verify-existing

`backup-live-theme` takes `-VerifyExisting <id>`, and `live-preflight` passes it through as
`-BackupVerifyExisting <id>`. After a backup that timed out, the retry verifies and rotates the copy that
run left standing instead of duplicating live again. It refuses an id that is live, missing from the
theme list, or outside this repo's backup namespace
([#3733](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3733)).

**Score:** 2

#### What makes this deploy extra special

A Shopify store whose live theme copies slowly no longer spends an extra theme slot on every retry of
the backup: measured in a consumer, one release day cost two extra slots on an 80-theme estate while the
first copy was still filling. Pass the id the timed-out run printed: `live-preflight -BackupVerifyExisting <id>`.

**Score:** 3

#### Pull Request

backup-live-theme verifies an existing copy with -VerifyExisting instead of duplicating live again

