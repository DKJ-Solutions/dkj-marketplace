## feat/plugin-page-contents

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

Each plugin's hub page lists what it ships: a card per specialist, hook and skill, each opening a landing page with more about it.

Asked by Dave, November 3, 2026, on `/plugins/dkj-subagents-alpha`: an h2 Specialists with a card per
specialist, each opening a landing page; then also an h2 Hooks and Skills.

### CREATE

- [x] `plugins-page-lib.ps1`: `Resolve-PluginPayloadDir` (the repo's own tree where it is the marketplace, else the clone), `Get-PluginContents` (specialists from subagents/personas/manuals, skills from `SKILL.md`, hooks from `hooks.json` and each script's help), `Format-PluginContentsSectionsHtml` (the three h2 sections) and `Format-PluginItemPageHtml` (the landing pages, a manual or `SKILL.md` rendered by the house markdown renderer).
- [x] `serve-general-pages.ps1`: the plugin page passes `-Contents`; `/plugins/<name>/<specialists|skills|hooks>/<slug>` serves a landing page, a 404 for a slug the plugin has none of.
- [x] Hub README row updated.

### TEST

- [x] `dev-pages.tests.ps1`: 15 asserts on a fixture plugin (resolution, the three readers, the sections, the routes, each landing page, escaping); the suite is 561 passed, 0 failed.
- [x] Served from the branch on port 4891: every route answers 200, an unknown slug 404.
- [x] The owner's look: a visible result, so the branch waited for it; Dave moved the new cards to the top and then said "open the PR" (November 3, 2026).

### DEPLOY: feat/plugin-page-contents

Each plugin's page in the Toolbox now shows what the plugin ships, under three headings: **Specialists**,
**Hooks** and **Skills**, a card per item. Each card opens a landing page of its own: a specialist's title,
description, model, tools and repo lens beside their manual in full; a hook's synopsis, the events that run
it and how it works; a skill's description, how it is invoked and its `SKILL.md`.

**Score:** 3

#### What makes this deploy extra special

**Score:** N/A

#### Pull Request

Plugin page: Specialists, Hooks and Skills sections

