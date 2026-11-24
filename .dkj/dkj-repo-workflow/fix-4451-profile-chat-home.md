## fix/4451-profile-chat-home

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

#4451: `working-profile.md` put the profile in `~/.claude/CLAUDE.md` "and nowhere else", which a
claude.ai or desktop chat never loads, and that chat is exactly where the orchestrator skill runs. Name
the chat home (the personal preferences) and what may go in it, so nobody pastes the persona there.

### CREATE

- [x] `skills/orchestrator/working-profile.md`: a subsection for chat sessions. The personal preferences
  hold three things (the skill-loading line, standing instructions, a short profile) and never a copy of
  a persona, manual or rule, with #4451's word counts as the reason. The template line names both homes.
- [x] `skills/orchestrator/SKILL.md`: one paragraph under "Do this" pointing at that subsection.
- [x] `personas/specialist-01-01-persona.md`: the parenthesis naming where a profile loads now names both
  homes, so it no longer contradicts the page.

### TEST

- [x] Docs only. The gates, including `orchestrator-skill.tests.ps1` and the anchor-link check, run in
  `ship-pr`.

### DEPLOY: fix/4451-profile-chat-home

The working-profile page and the orchestrator skill now name where a profile lives in a claude.ai or
desktop chat: the account's personal preferences.

**Score:** 2

#### What makes this deploy extra special

If you run Chris in a claude.ai or desktop chat, the page now says what your personal preferences should
hold: the line that loads the orchestrator skill, standing instructions, and a short working profile.
They should never hold a pasted copy of the persona or manual. Such a copy drifts from every release and
loads roughly 10,000 words into every chat.

**Score:** 2

#### Pull Request

Working profile: name its home for claude.ai and desktop chat sessions

