## feat/4430-split-heavy-suites

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

- [x] Time both suites per section on a workstation, and cut each at the boundary that balances it
  (guard-live-theme 147s -> 74s / 72s; script-contract 187s -> 106s / 81s)
- [x] Check that the second half reads no state the first half creates; rebuild what it does use

### CREATE

- [x] `guard-live-theme-fixture.ps1` + `guard-live-theme.tests.ps1` (groups 1-9, rule 5's #3014 push)
  + `guard-live-theme-deploy.tests.ps1` (rule 5's #4329 routes, group 10)
- [x] `script-contract-fixture.ps1` + `script-contract.tests.ps1` (sections 1-12h)
  + `script-contract-tables.tests.ps1` (sections 14-15)
- [x] Restore the group 9 assert that two `Assert-Equal` calls on one line had silently swallowed
- [x] `ci.yml`: six shards, with the re-pricing written beside the matrix; the selection test's
  `-ShardCount` assert no longer pins a number (ci-shard.tests.ps1 holds matrix and count together)
- [x] The new suites join their siblings' groups in `suite-groups.json`, and the `check-script-contract`  mirror declaration names the suite that now runs section 14

### TEST

- [x] guard-live-theme: 220 + 192 = 412 asserts (411 before, plus the restored one), all green
- [x] script-contract: 451 + 65 = 516 asserts, the same as before, all green
- [x] ci-shard, ci-suite-selection-lib and affected-suites suites green

### DEPLOY: feat/4430-split-heavy-suites

The two heaviest test suites no longer pin a CI shard each, and CI runs on six shards instead of five.
`guard-live-theme.tests.ps1` (465s in CI) and `script-contract.tests.ps1` (429s) each took about as long as
an ideal shard on their own, so the packer could not balance around them. Both are now two suites over a
shared fixture file (`guard-live-theme-deploy.tests.ps1` and `script-contract-tables.tests.ps1` are the new
halves), cut where measured time balances, with every assert preserved. That puts the heaviest file at
about 274s, under the ~382s work bound over 24 lanes, so the sixth shard the #2304 note priced and
declined at 141 suites now pays: about 76s off the bound for about 20s of provisioning. The split also
restored one assert in the guard's group 9 that had never run, because it shared a line with another.

**Score:** 3

#### What makes this deploy extra special

N/A: this repo's own CI and test suites, which no consumer runs or installs.

**Score:** N/A

#### Pull Request

Split the two heaviest test suites and run CI on six shards

