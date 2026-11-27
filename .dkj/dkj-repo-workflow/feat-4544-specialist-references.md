## feat/4544-specialist-references

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

Steps 1 and 2 of the plan for #4544: the rule and the docs. A specialist's references are the source
store its repo lens names, and the specialist writes a kept web find there itself instead of handing it
back. Write access needs no change for a Notion store: the specialists carrying the block disallow file
writes, not MCP tools, so a Notion library is reachable already; where the tools cannot reach the store,
the rule falls back to handing the row back. The security look and the reuse measurement follow later.

### CREATE

- [x] `subagent-shared/knowledge-lookup.md`: the lookup order names references, and the specialist maintains them itself, with a fallback where its tools cannot reach the store
- [x] `build-agent-defs.ps1` regenerated the block into the eight subagent defs that carry it
- [x] Rutger (03-33): subagent step 6 and his manual write library pages and source rows himself; Ian places them only as the fallback
- [x] `plugins/dkj-subagents/README.md`: a new section on references as the fifth layer beside the lens, with the canon/references/lens split and why references live in the repo store

### TEST

- [x] `build-agent-defs.ps1 -Check`: all shared blocks in sync with the source
- [x] the lint and test gates run through open-pr

### DEPLOY: feat/4544-specialist-references

Specialists with a canon page now maintain their own **references**: the source store their repo lens
names. A web find worth keeping is written there by the specialist in the same task, one row per source,
general knowledge only; where its tools cannot reach the store it is handed back as before. Rutger writes
his mechanism pages and source rows himself. The plugins README describes references as the fifth layer
beside the repo lens.

**Score:** 3

#### What makes this deploy extra special

A life hub's source library now grows on its own: Rutger and the other specialists with a canon page
add each source they look up to it themselves, so research done last week is not redone and no
teammate has to place it.

**Score:** 3

#### Pull Request

Specialists maintain their own references, a fifth layer beside the lens

Plugins: dkj-subagents-alpha, dkj-subagents-developers, dkj-subagents-lifehub
