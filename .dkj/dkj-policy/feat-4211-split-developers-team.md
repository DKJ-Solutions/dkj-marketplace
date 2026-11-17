## feat/4211-split-developers-team

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

The ten repo-bound specialists and the three repo-bound skills move from dkj-subagents-alpha into a new plugin, dkj-subagents-developers, so the core team travels to the Claude App whole

#### Decisions taken in this branch

- **The plugin name is `dkj-subagents-developers`** (open point 2 of #4211, left to the PR by the decision
  comment): the `dkj-subagents-*` pattern, and the word the issue itself uses for the team.
- **Admin's Plugins page shows both base teams under its first section** ("Alpha"), with the developers team
  labelled `developers team`, because every repo enables the two together.
- **The other consumers' register records keep their single core block** until each consumer enables the new
  plugin, the doctrine of every earlier rename; only this repo's own record moves with its commit.
- **This lands before #4209** (the rename of `dkj-policy`), which has not started its code yet, and ships in
  the same release, as the owner decided.

### CREATE

- [x] Move the subagent defs, manuals and personas of Derek `05-05`, Rendall `05-06`, Sylvester `05-15`,
  Cody `04-13`, Tycho `04-18`, Victor `06-19`, Sebastian `06-23`, Ravi `06-24`, Nolan `06-25` and Tessa `06-16`,
  plus `hooks/`, `scripts/` and the skills `specialists-init`, `specialists-teardown` and `sync-roster`, into
  `plugins/dkj-subagents/dkj-subagents-developers/` (`git mv`, history kept). Edith `06-17` stays in core.
- [x] Write the new `plugin.json`, trim the core one to nine agents, register the plugin in `marketplace.json`
  and enable it in `.claude/settings.json`.
- [x] Repoint the shared-script mirror registrations (`shared-scripts-lib.ps1`) to the new plugin.
- [x] `bootstrap.ps1` reads personas from two plugins: Chris and Bianca from the core team beside it (source
  tree, marketplace clone and plugin cache), Derek and Rendall from its own; the body import keeps naming the
  core team; a pre-split payload is still one source. `teardown.ps1`'s name scan reads the sibling payloads.
- [x] Rewrite every reference to a moved file, skill command or subagent id (35 files), and the dead link
  targets in nine archived release documents (their text unchanged).
- [x] Admin (`dev-pages-lib.ps1`) and the App filter's reasoning (`repo-config.ps1`) know the developers team;
  the developers team stays out of `Get-BusinessMarketplacePlugins`.
- [x] Docs: the Claude App map and install steps in `ADOPTION.md`, the teams README, `SPECIALISTS.md`, the
  repo facts and this repo's register record.
- [x] Review fixes: an exact orchestrator anchor, one persona per id across the two sources, a version sort in
  teardown, and four stale sentences.
- [x] Filed #4216: a consumer that enables the core team without the developers team loses ten specialists and
  the roster check silently, because the hook that would say so moved too.

### TEST

- [x] Lint gate `check-plugin-integrity.ps1`: 0 errors.
- [x] Suites bootstrap-drift (242), roster-sync (422), sync-roster (52), teardown-protocol (28), dev-pages
  (825), check-plugin-integrity-roster (62), -scripts (77), -links (35): all green. The cache scenarios now
  place both plugins side by side, as a real install has them.
- [x] `check-roster-sync.ps1` here: 0 errors. `check-consumers.ps1`: this repo's two base-team blocks OK; the
  developers plugin reads as not installed on this machine until the release.
- [x] A fresh bootstrap with both base teams enabled, measured: 4 persona lenses + 17 scaffolds = 21, the body
  import names `dkj-subagents-alpha/personas/`, Derek's lens names `dkj-subagents-developers/personas/`.
- [x] Victor (code), Edith (copy) and Sebastian (security) reviewed the diff: nothing blocking; their low
  findings are fixed above.

### DEPLOY: feat/4211-split-developers-team

The core team is now two plugins. `dkj-subagents-alpha` keeps the specialists who work anywhere (Chris,
Bianca, Paula, Priya, Rebecca, Vera, Gwen, Uma, Edith, Marlowe, Auden) and is what the Claude App gets. The
specialists whose craft needs a repository (Derek, Rendall, Sylvester, Cody, Tycho, Victor, Sebastian, Ravi,
Nolan, Tessa), the skills `specialists-init`, `specialists-teardown` and `sync-roster`, and the roster session
check moved to a new plugin, `dkj-subagents-developers`
([#4211](https://github.com/DKJ-Solutions/dkj-marketplace/issues/4211)).

**Every repo must enable the new plugin**, or a session there has eleven specialists instead of twenty-one and
no roster check. Add `"dkj-subagents-developers@dkj-marketplace": true` beside the core team in
`.claude/settings.json`, then run `claude plugin install dkj-subagents-developers@dkj-marketplace --scope project`
and restart. Lenses and roster rows need no change; the slash commands are now
`/dkj-subagents-developers:specialists-init`, `/dkj-subagents-developers:sync-roster` and
`/dkj-subagents-developers:specialists-teardown`.

**Score:** 5

#### What makes this deploy extra special

The Claude App now offers only specialists who can work without a repository: the PowerShell skills and the
roster hook no longer travel with the core team.

**Score:** 3

#### Pull Request

Split dkj-subagents-alpha into a portable core team and a repo-only developers team

