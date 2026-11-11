## fix/3993-handover-dkj-policy-root

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

Inbound #3993: `build-handover-page.ps1` resolved dkj-policy as four levels above `scripts\task`, which is
right in the source tree and wrong in the install cache (`cache\<marketplace>\<plugin>\<version>`). Verified
in the script: four up from the cached copy is `cache\<marketplace>`.

### CREATE

- [x] `Resolve-DkjPolicyRoot` in bwj-development's `scripts\lib\repo-root-lib.ps1`: source layout first, then the sibling `dkj-policy\<own version>` in the cache, then the highest version carrying the marker; refuses with the paths it tried
- [x] `build-handover-page.ps1` resolves its dkj-policy root through it, after the repo root

### TEST

- [x] `handover-page.tests.ps1`: four new asserts -- source layout, cache at own version, highest version (by version, not string) when that one is missing, refusal with no dkj-policy

### DEPLOY: fix/3993-handover-dkj-policy-root

`build-handover-page.ps1` runs from an installed plugin again. It looked for dkj-policy's Admin libs four
directories above itself, which only holds in the source tree, so in the plugin cache it failed before
building anything. It now also finds dkj-policy as the sibling plugin in the cache, at its own version
(#3993).

**Score:** 2

#### What makes this deploy extra special

A BWJ store repo can build the preview handover page with the script as shipped, instead of copying the
plugin's files to a temporary folder and running the copy with `-RootOverride`.

**Score:** 3

#### Pull Request

build-handover-page finds dkj-policy's root in the plugin cache

