## fix/4374-branch-entry-live-lane

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

Inbound #4374: the branch-entry caller that adopt-workflow-folder scaffolds triggers on `branches: [main]`
only, so in a Shopify consumer with a hotfix lane the gate never ran on PRs to the live deploy branch.
Verified in the tree: the template literal in `adopt-workflow-folder.ps1`, and `check-branch-entry.ps1`
judges the head branch's document with no assumption about the base, so the trigger is the whole gap.

### CREATE

- [x] `adopt-workflow-folder.ps1` (plugin copy and root mirror): read `Get-ShopifyLiveDeployBranch` from the consumer's repo-config in a child scope; a plain, non-placeholder name other than `main` joins the branch-entry caller as `branches: [main, <live>]`, with a #4374 comment; an unusable answer leaves `main` only and the run says why
- [x] An existing branch-entry caller whose `branches:` line lacks the declared live branch is reported with the line to add, never rewritten
- [x] The adopt skill page states the second trigger branch
- [x] `check-branch-entry.ps1` and `reusable-branch-entry.yml` read: no base filter, no change needed

### TEST

- [x] `adopt-workflow-folder.tests.ps1`: live branch declared, not declared, five unusable answers, existing caller with and without the live branch -- 237 asserts, 0 failed; the full gate runs in ship-pr

### DEPLOY: fix/4374-branch-entry-live-lane

`adopt-workflow-folder` now reads `Get-ShopifyLiveDeployBranch` and, where it answers a plain branch name,
writes it into the branch-entry caller's trigger beside `main`; an existing caller missing it is reported
with the line to add (#4374).

**Score:** 2

#### What makes this deploy extra special

A Shopify consumer that ships hotfix PRs straight to its live branch now gets the branch-entry gate on
those PRs too. Before, a malformed DEPLOY section could land on live unjudged, flow back to the trunk and
turn fold-on-merge red on every later merge. An already-adopted repo is told the one line to change when it
re-runs Part 1 of `adopt-dkj-repo-workflow`.

**Score:** 3

#### Pull Request

Branch-entry gate also runs on PRs to the live deploy branch
