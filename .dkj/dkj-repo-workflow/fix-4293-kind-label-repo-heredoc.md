## fix/4293-kind-label-repo-heredoc

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

Inbound #4293, both causes verified in `reach-reason-rules.ps1`: `Get-GhIssueLabelCall` blanked a non-literal
`--repo` to `''`, which every hook reads as "fall back to the checkout's repo"; and its tokeniser had no notion
of a heredoc, so a call quoted in a body read as a second call. Repair it in the one parser both guards share.

### CREATE

- [x] `Get-GhIssueLabelCall` returns `RepoUnknown` for a `--repo`/`-R` value that is not a literal owner/name
- [x] it strips heredoc bodies first (`Remove-ShellHeredocBody`): not when an interpreter reads the heredoc, and not when the opener sits inside a quoted string (`--body "$(cat <<'EOF' ...)"`, whose body is the text gh receives)
- [x] `guard-kind-label` and `guard-reach-reason` read `RepoUnknown` as "repo unknown, not judged" instead of the checkout's repo

### TEST

- [x] `guard-kind-label.tests.ps1`: 47 passed, including both measured commands from #4293 at lib and hook level
- [x] `guard-reach-reason.tests.ps1` 58, `guard-stale-paste-block.tests.ps1` 156, `filed-with-stamp.tests.ps1` 31: all green

### DEPLOY: fix/4293-kind-label-repo-heredoc

The BWJ issue guards no longer judge an issue create against the checkout's own repo when the target repo is
passed through a shell variable (`-R $R`): the target counts as unknown, and the create passes with the
not-judged warning. A `gh issue create` quoted inside a heredoc body is no longer read as a second call
(#4293).

**Score:** 3

#### What makes this deploy extra special

In a store checkout, filing an inbound issue on the plugin's source repo with `-R $R`, or with a body written
through a heredoc that quotes a command, is no longer refused as "carries none of the kind labels".

**Score:** 3

#### Pull Request

guard-kind-label: a non-literal --repo is unknown, and heredoc bodies are not commands

