## fix/3923-preview-fill-wait

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

Inbound #3923 (from BWJ-Development/smartwatchbanden#1066). Verified before repair: #3732 (v6.3.0)
already lets the wait run on while the copy grows, up to 3x `-TimeoutMinutes`. But the measured copy
held 843 of 910 files at ~55 min and was still rising, so the 60-minute cap of the 20-minute default
still refuses it. The default is the part that still stands. The counting method (a full pull per
sample) is a separate subject, filed as #3926.

### CREATE

- [x] `push-preview.ps1`: `-TimeoutMinutes` default 20 -> 40 (hard cap 120 min), docstring cites #3923
- [x] `skills/push-preview/SKILL.md`: the parameter row says the new default and why

### TEST

- [x] No suite pins push-preview's default (the script is deliberately not driven, see its NOTES); the
  wait logic itself is unchanged and stays pinned in `theme-lifecycle-rules.tests.ps1`. ship-pr's gate runs.

### DEPLOY: fix/3923-preview-fill-wait

`push-preview` now waits 40 minutes for a fresh copy of live to fill before giving up, instead of 20.
Past that it still runs on while the copy grows, up to three times that value, so up to two hours.
A 910-file live theme's copy was measured still filling at ~55 minutes, with the context templates
arriving last, so the old default's 60-minute cap refused a copy that was not stuck
([#3923](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3923)).

**Score:** 3

#### What makes this deploy extra special

A Shopify consumer with a large live theme no longer has to re-run `push-preview` once or twice per new
preview: the first run waits long enough for the copy to fill.

**Score:** 3

#### Pull Request

push-preview: raise the fill wait's default for a large store's copy of live

