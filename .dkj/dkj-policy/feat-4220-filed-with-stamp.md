## feat/4220-filed-with-stamp

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

- [x] Verify #4220 still stands: no `filed-with` stamp anywhere in the tree, and the plugin version lives only in the install record

### CREATE

- [x] `filed-with-rules.ps1`: the created-issue URL read, the version read from the install record, the stamp and its idempotent append
- [x] `filed-with-stamp.ps1`: the PostToolUse hook, registered in `hooks.json` behind a `gh issue create` pre-filter
- [x] The README's hooks row

### TEST

- [x] `filed-with-stamp.tests.ps1`: 31 asserts, added to the bwj suite group

### DEPLOY: feat/4220-filed-with-stamp

Every issue a session files with `gh issue create` on a BWJ store repo now carries, at the end of its body, a hidden comment naming the plugin versions that session ran -- `<!-- filed-with: dkj-policy 6.18.0, bwj-development 6.18.0 -->` -- read from this checkout's install record. When an issue arrives malformed, the tracker itself answers whether the guard that should have caught it was installed ([#4220](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4220)). It is a PostToolUse hook rather than a step of `report-issue`, because a bare create is the case that slips past the procedure. It fails open: the issue always stands as created, and a body it cannot edit is named to the session. An inbound issue on the source repo is not stamped.

**Score:** 2

#### What makes this deploy extra special

A maintainer of a BWJ store repo can answer *which version filed this?* with `gh search issues filed-with` instead of asking the colleague who filed it to run `plugin-versions`. Issues filed before the update carry no stamp, and cannot be given one after the fact.

**Score:** 2

#### Pull Request

bwj-development: stamp the filing session's plugin versions on every issue it creates

