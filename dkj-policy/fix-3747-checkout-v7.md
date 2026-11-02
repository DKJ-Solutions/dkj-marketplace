## fix/3747-checkout-v7

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

#### Scope

#3747 named four scaffolds. They cannot move alone: `pin-parity.tests.ps1` holds the generator's SHA equal
to this repo's own `fold-on-merge.yml` and `verify-resolved.yml`, and the Shopify floor's test states that
its pin is the version every other pin in this repo carries. So every v5 pin in the tree moves, as one
change. The two v4 SHA pins in `claude.yml` and `claude-code-review.yml` are the Claude GitHub app's own
workflows and are left alone.

### CREATE

- [x] `actions/checkout@v5` becomes `@v7`, and the v5 SHA pin `fbc6f39...` becomes
  `3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1` (verified against the upstream `v7.0.1` tag), in
  `.github/workflows/`, both scaffolders and their root mirrors, the two `bwj-development` templates,
  `consumer-runner-lib.ps1` and the tests that read them
- [x] v7's one breaking change checked: it refuses a fork PR's checkout under `pull_request_target` and
  `workflow_run`. Only `merge-on-green.yml` runs under `workflow_run`. Its trunk checkout is `ref: main`, and
  the PR checkout only meets a fork in a repo that takes fork PRs, where refusing it is the safer outcome

### TEST

- [x] pin-parity, adopt-ci-floor, adopt-shopify-floor, consumers, merge-queue-prereq and workflow-concurrency
  suites green standalone

### DEPLOY: fix/3747-checkout-v7

Every `actions/checkout` pin in the tree moves from v5 to v7 (#3747): this repo's own workflows, the
reusable ones consumers call, the CI floor and the Shopify floor that `adopt-ci-floor` and
`adopt-shopify-floor` write, and the two `bwj-development` Asana templates. The SHA-pinned write-capable
runners take `3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1`, still equal across the generator and this
repo's own copies, as `pin-parity` requires.

**Score:** 2

#### What makes this deploy extra special

If Dependabot has moved your workflows to `actions/checkout@v7`, re-adopting a scaffold no longer puts v5
back. If yours are still on v5, a re-adopt now writes v7. One behaviour changes with it: `merge-on-green`
now refuses to check out a pull request from a fork, which v7 blocks under `workflow_run`.

**Score:** 2

#### Pull Request

Every actions/checkout pin moves from v5 to v7, scaffolds and this repo's own runners alike

