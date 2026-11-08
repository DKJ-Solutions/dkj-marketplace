## feat/3896-skill-trigger-evals

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

#3896, as decided on its thread (November 8, 2026): `claude plugin eval` cases for a few key skills, run by
hand, no CI spend. The cases test triggering only, the risk the issue names (a description shortened until
the skill stops firing), with free `tool_used: Skill` graders, so no judge model is paid for.

### CREATE

- [x] `plugins/dkj-policy/evals/`: four `*-fires` cases (`claim-issue`, `new-branch`, `sync-trunk`, `day-plan`) and one negative case
- [x] `evals/README.md`: the local command (`--no-publish` required, `--ablation none`), the case table, the cleanup line
- [x] `.gitignore`: the eval results directory
- [x] Filed #3911: the dev-preview hook starts an Admin server per eval run that outlives it

### TEST

- [x] Ran locally November 9, 2026: `claude plugin eval plugins/dkj-policy --runs 1 --ablation none --no-publish --trust-plugin`, 5/5 cases passed, exit 0.
- [x] The repo gates run inside `ship-pr`.

### DEPLOY: feat/3896-skill-trigger-evals

`dkj-policy` carries an eval suite (`plugins/dkj-policy/evals/`) that checks four key skills (`claim-issue`,
`new-branch`, `sync-trunk`, `day-plan`) still fire on everyday phrasing, plus one case that checks a plain
question fires none. It runs by hand with `claude plugin eval`, never in CI, and its README gives the
command, including `--no-publish`, which keeps the report off claude.ai.

**Score:** 2

#### What makes this deploy extra special

N/A

**Score:** N/A

#### Pull Request

Local plugin evals that prove dkj-policy's key skills still fire on natural phrasing

