## fix/4429-refresh-suite-durations

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

#4429: `scripts/tests/suite-durations.json` was last written 2026-11-17 and held 168 of the tree's 208
suites, so 40 suites were packed into the CI shards without a measured duration, and the slowest shard
ran 555-668 s against an even split of about 450 s. Refresh it from the three PR runs the issue
measured, with the repo's own `record-suite-durations`.

### CREATE

- [x] `scripts/maintenance/record-suite-durations.ps1 -RunId 45154073407,45156109457,45152244349`:
  208 suite rows read from each run, pool total 9172 s, file rewritten (machine label kept).

### TEST

- [x] The recorder refuses a tableless run and read 208 rows from each of the three; the gates
  `ship-pr` runs judge the rest. Whether the slowest shard actually drops toward 450 s is read off the
  next CI runs, not asserted here: the two suites that pin a shard on their own
  (`guard-live-theme` 465 s, `script-contract` 429 s) set a floor no packing removes, which is #4430.

### DEPLOY: fix/4429-refresh-suite-durations

`scripts/tests/suite-durations.json` holds a measured CI duration for all 208 suites again, read from
three pull-request runs of November 23, 2026, where 40 suites added since November 17 had none and
were packed into the CI shards blind (#4429).

**Score:** 1

#### What makes this deploy extra special

The file is this repo's own CI packing hint and ships to nobody who installs the plugins.

**Score:** N/A

#### Pull Request

suite-durations.json refreshed from three current CI runs

