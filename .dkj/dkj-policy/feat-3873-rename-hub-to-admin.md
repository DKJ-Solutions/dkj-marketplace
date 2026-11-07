## feat/3873-rename-hub-to-admin

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

Rename the hub mechanism to admin everywhere, so the code matches the name on screen (#3873; Dave unparked it
on November 7, 2026). The folder goes to `plugins/dkj-policy/apps/admin/` (placement decided on the issue).

#### Decisions

- **Two names keep *hub* on purpose**, because something outside this tree holds them: the gist description
  `dkj-hub-airsquats` (every machine searches its own account for it, so renaming it would split the shared
  state) and the timing store's mutex `dkj-hub-timing-` (two plugin versions on one machine must share it).
- **`hub` in `repo-session` is a different word**: there it means this repo as the centre of every DKJ repo,
  not the Admin mechanism, so that skill and its script are left alone.
- **`OwnHub` stays**: it names a retired key (#3643) as history.
- **Compatibility for one release**: `/hub` answers with a 301 (to `/` on the general server, to `/admin` on
  the consumer dashboard); `%LOCALAPPDATA%\dkj-hub\` is copied to `dkj-admin\` once by the session-start hook
  (a copy, so a checkout still on the old plugin keeps its folder); `DKJ_HUB_AIRSQUATS_GIST` is still read where
  `DKJ_ADMIN_AIRSQUATS_GIST` is unset; the stale-server check knows both the old and the new path of
  `serve-general-pages.ps1`, so an old version's server is still recognised and replaced after the update.

### CREATE

- [x] Move `plugins/dkj-policy/hub/` to `plugins/dkj-policy/apps/admin/` and deepen its relative paths
- [x] Rename identifiers, file names (`repo-admin-page.ps1`, `admin-processes-sessioncheck.ps1`,
  `check-admin-processes.ps1`, `admin-airsquats.tests.ps1`), env vars, the state file and the prose
- [x] `/hub` redirects, the state-folder copy, the env-var fallback, the stale-server regex for both layouts
- [x] Repair the history sentences and anchors the mechanical pass got wrong

### TEST

- [x] New assertions: `/hub` redirects (dev-pages), the state-folder copy (dev-preview-sessionstart), the old
  env-var name (admin-airsquats)
- [x] The touched suites pass locally: dev-preview-sessionstart, dev-pages, tidy-lib, check-house-style,
  admin-airsquats

### DEPLOY: feat/3873-rename-hub-to-admin

The code now says *admin* where the screen already did (#3873). Admin's folder moved from
`plugins/dkj-policy/hub/` to [`plugins/dkj-policy/apps/admin/`](../../plugins/dkj-policy/apps/admin/README.md),
the first app under `apps/`; the identifiers (`Format-AdminCardLinkHtml`, `Get-AdminMenu`, ...), the
`admin-processes-sessioncheck` hook, `check-admin-processes.ps1`, the per-checkout state file
(`%TEMP%\dkj-repo-admin-*.json`) and the route `/admin` follow. Two names keep *hub* on purpose: the gist
description `dkj-hub-airsquats` and the timing store's mutex, both shared with things outside this tree.

**Score:** 3

#### What makes this deploy extra special

Nothing to do but update the plugin, in every checkout: the first session start copies the machine's state
folder `%LOCALAPPDATA%\dkj-hub\` (the day plan, the airsquats banner) to `%LOCALAPPDATA%\dkj-admin\`, and a
bookmark to `/hub` is redirected. Where you set `DKJ_HUB_AIRSQUATS_GIST` in your settings, rename it to
`DKJ_ADMIN_AIRSQUATS_GIST`: the old name is still read for this release only.

**Score:** 3

#### Pull Request

Rename the hub mechanism to admin