## fix/4277-lifehub-inherit-mcp-tools

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

#4277: the five lifehub subagent defs carried a file-only `tools:` allowlist, so in a session with the
Notion connector Ian could not reach the brain. Claude Code's docs: a def without `tools:` inherits every
built-in and MCP tool, and `disallowedTools:` removes tools from that pool. So the allowlist becomes a
denylist, and check 36 learns that a tools-less subagent def inherits Bash unless it denies it.

### CREATE

- [x] Ian (04-03) and Onyx (04-04): `disallowedTools: Bash, PowerShell, NotebookEdit`.
- [x] Astrid (02-10), Fiona (03-08), Hugo (03-14), which never place material: `disallowedTools: Bash, PowerShell, Write, Edit, NotebookEdit`.
- [x] `Get-AgentDefDisallowedTools` and `Test-AgentDefHoldsTool` in `scripts/lib/subagent-shared-lib.ps1`; check 36 (`[tool-block]`) uses the latter, so a def that inherits Bash is still obliged to carry `working-copy-boundary`.
- [x] `plugins/dkj-subagents/README.md`: the `maxTurns` paragraph names the lifehub exception.

### TEST

- [x] `scripts/tests/subagent-shared.tests.ps1`: new asserts for denylist-with-Bash (unobliged), no lines at all (obliged), denylist without Bash (obliged), a body-quoted `disallowedTools` line (not read), and the real lifehub defs (do not inherit Bash) -- 55 asserts pass.
- [x] The full gate runs in `ship-pr`.

### DEPLOY: fix/4277-lifehub-inherit-mcp-tools

The lifehub subagents (Ian, Onyx, Astrid, Fiona, Hugo) now inherit the session's connector tools through
a `disallowedTools:` denylist instead of a file-only `tools:` allowlist, so they can read and file in a
knowledge base that lives behind a connector such as Notion. Shell access stays denied to all five, and
writing stays denied to the three that only deliver material. The integrity gate's tool-block check now
counts an inherited tool as held, so a tools-less subagent def cannot pick up Bash without the
working-copy boundary.

**Score:** 2

#### What makes this deploy extra special

A lifehub user whose brain lives in Notion can hand filing to Ian or Onyx as subagents again, instead of
the work falling back to the main loop.

**Score:** 3

#### Pull Request

Lifehub subagents inherit connector tools through a denylist instead of a file-only allowlist

