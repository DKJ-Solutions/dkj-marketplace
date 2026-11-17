## fix/4246-pin-house-style-caller

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

#4237 pinned the read-only consumer runners to the adopted release, but left the house-style caller
that the dkj-brandbook skill gives on `@main`. Pin it as well: `@vX.Y.Z` plus `scripts-ref: vX.Y.Z`.
The release cut writes both tags beside the checksum table's tag, so they are never edited by hand. The
cut's version pins only reached `<Prefix>vX.Y.Z/`, so a pin entry gets an optional `Refs` list of
prefixes after which a bare tag is repointed.

### CREATE

- [x] `cut-release.ps1` (source and plugin mirror): optional `Refs` on a version pin, validated in the preflight and rewritten at the bump
- [x] `repo-config.ps1` and its blueprint text: the dkj-brandbook pin names the caller's two refs (the blueprint regenerated with `build-config-blueprint.ps1`)
- [x] The skill page's caller and `reusable-house-style.yml`'s header: pinned, with the reason
- [x] Tests: the caller and the table name the same release; a Ref is rewritten, and a missing one refuses the cut

### TEST

- [x] Affected suites green standalone: `check-house-style` (189), `cut-release-drive` (140), `script-contract` (516), `config-blueprint` (239); `check-plugin-integrity` 0 errors. The full gate runs in `ship-pr`.

### DEPLOY: fix/4246-pin-house-style-caller

The house-style caller in the `dkj-brandbook` skill is now pinned to the release a repo adopted:
`reusable-house-style.yml@vX.Y.Z` plus `scripts-ref: vX.Y.Z`. #4237 had already pinned the branch-entry,
always-on and repo-settings runners this way (#4246). Before this, a script moved on `main` before a
release turned that gate red in every consumer. The release cut writes both tags beside the checksum
table's tag. To make that possible, a `Get-ReleaseVersionPins` entry takes an optional `Refs` list: the
cut repoints the bare tag after each prefix, and refuses to cut when a prefix has gone missing from the
file.

**Score:** 2

#### What makes this deploy extra special

For the maintainer of a DKJ-Solutions repo with a UI: the brand-book CI gate the skill hands you no
longer goes red when the source moves a script on `main`. It moves when you take a new brand-book
copy. A caller already on `@main` keeps working as before. Copy the new snippet to pin it.

**Score:** 2

#### Pull Request

Pin the house-style caller the dkj-brandbook skill gives to the release, as #4237 pinned the other read-only gates

