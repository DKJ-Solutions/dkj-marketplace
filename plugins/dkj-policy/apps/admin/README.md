# Admin — the dev-preview hook and the general pages server

**On screen it is called Admin** ([#3815](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3815), November 5, 2026; **Toolbox** from October 27 until then): Admin is for managing and the product for using, after the Shopify Admin. The session-start line opens with `Admin:`, a product links it on an **Admin** card, and the first crumb reads **Home**. The code said *hub* for the mechanism until #3873 (November 7, 2026) renamed it to *admin* as well: this folder moved from `hub/` to `apps/admin/`, the route `/hub` to `/admin` (the old one answers with a 301 to `/`), the machine's state folder from `%LOCALAPPDATA%\dkj-hub\` to `%LOCALAPPDATA%\dkj-admin\` (copied over once, `Copy-AdminLegacyStateDir`), and `DKJ_HUB_AIRSQUATS_GIST` to `DKJ_ADMIN_AIRSQUATS_GIST` (the old name still read for one release). Two names keep *hub* on purpose, because something outside this tree holds them: the gist's description `dkj-hub-airsquats`, which every machine searches its account for, and the timing store's mutex `dkj-hub-timing-`, which two plugin versions on one machine must share.

**Admin's side navigation is flat, under section headings, never a tree** (#3815, `Get-AdminNav`):

| Section | What it holds |
|---|---|
| (no heading) | **Home**, the dashboard on `/`, then the repo's **domain objects** (Tracks, Playlists, Artists) at the top level, with no "Manage" wrapper, since everything in Admin is management (#3818). A repo states them in `Get-AdminObjects` in its `scripts/repo-config.ps1`, returning `@{ Label; Href; Count }` items; the count is drawn as a badge. **The repo's own server serves those routes, not Admin**: an `Href` that is a path (`/tracks`) is resolved against the product's address, and an http(s) URL is kept. Admin reads the seam in a child process at most once a minute, never in its own scope, keeps at most 12 items, and drops one without a label or with any other address. |
| **Product** | **Storefront**, a link to the product this session started (the state file's `Product`); left out where the repo states none. Admin links to and manages the product, it is not the product. |
| **Development** | Admin's own pages, under `/dev/...`: GitHub, Goals, Release notes, Claude, Installed plugins (`Get-AdminMenu`). A group page such as Claude is one item, and its members are reached on it. |
| (foot) | **Settings**, on `/settings`, pinned to the bottom. |

**Every address from before #3815 redirects** (`Resolve-AdminLegacyPath`, a 301): `/test-gate/...`, `/claude/...`, `/plugins/...` and the rest go to `/dev` and the same path, the query kept, so links and bookmarks keep working. The `-BrandTag` a caller passes is `admin` now; `toolbox` is still read as `admin` for this release (`ConvertTo-AdminBrandTag`).

**Every repo that runs `dkj-policy` gets an Admin at session start**, served by the plugin, with the
General pages linked from it: Issues, Release notes, SessionStart, Test gate, Stopwatch, Logbook
(Test gate and those two since [#3470](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3470)) and Plugins
(since [#3482](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3482)), and the **Claude** card. Issues and
the Test gate are linked from the **GitHub** page instead, the Test gate beside the CI runs it measures (since
November 2, 2026). The Performance card's `/dev/performance` page (October 30, 2026) holds two sections since
November 3, 2026 (Dave): **Clock**, an `h2` over the Stopwatch and Logbook `h3` cards, and **Context**, over
SessionStart's. Clock had a `/dev/clock` page of its own from October 27, and that address now moves to `/dev/performance`. The `/dev/claude`
page (the `/ai` page, with Claude as its section, until Maikel made Claude its `h1` on November 2, 2026; an old `/ai`
link is moved there) holds the Rules, Skills, Specialists and Performance cards (Performance there since
November 2, 2026, because what it measures is what Claude's work costs; its route did not change), the Skills page a
landing page with nothing on it yet, the Specialists page a Lenses section, a card per `.claude/specialists/lenses/specialist-NN-NN-lens.md` of the repo, each
opening on `/dev/claude/specialists/lenses/<name>` with the lens's text (Maikel, October 30, 2026; groups may nest, and a `Section`
group is a heading, `Get-AdminGroups`), and the Rules page cards read from the repo the same way: a card per
`.claude/rules/*.md` and nothing else, under no heading but the page's own, each opening on `/dev/claude/rules/<name>`
with its text (Maikel, November 3, 2026; `Get-AdminRulePages`, a `Bare` section). A rule file's card reads its
`description:` frontmatter key, and the file's `# ` title where it has none. Claude Code reads only `paths:` there.
That covers
BWJ-Development's repos too. Until [#3198](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3198)
(the owner's decision, October 20, 2026) all of this shipped with `dkj-solutions`, which BWJ-Development
never enables, so a General page reached only the DKJ-Solutions repos. **"General" means what every repo
has, whichever organisation it belongs to**, so the machinery moved here. The DKJ-Solutions card and its
Brandbook stayed in [`dkj-solutions`](../../dkj-solutions/README.md) until #3475 took them off every consumer
Admin (below).

| Part | Where |
|---|---|
| The SessionStart hook | [`../hooks/dev-preview-sessionstart.ps1`](../../hooks/dev-preview-sessionstart.ps1) |
| Its rules (the seam, the ports, the ownership rule, the state file) | [`lib/dev-preview-rules.ps1`](lib/dev-preview-rules.ps1), [`lib/general-pages-state.ps1`](lib/general-pages-state.ps1) |
| The general pages server, which is Admin | [`pages/serve-general-pages.ps1`](pages/serve-general-pages.ps1), its pages in [`lib/general-pages-lib.ps1`](lib/general-pages-lib.ps1), Admin's page in [`lib/repo-admin-page.ps1`](lib/repo-admin-page.ps1) |
| The request rules the servers share | [`lib/loopback-server-lib.ps1`](lib/loopback-server-lib.ps1) |
| The banner's airsquats state, and its sync with every other machine | [`lib/airsquats-lib.ps1`](lib/airsquats-lib.ps1), [`pages/sync-airsquats.ps1`](pages/sync-airsquats.ps1) |
| The Test gate page | [`lib/test-gate-lib.ps1`](lib/test-gate-lib.ps1) |
| The Goals page on `/dev/goals`, second of Admin's own cards after Today: each open issue labelled `goal`, its sub-issues as milestones and theirs as tasks, with one **Now** card, a **Next** row and the milestones collapsed with a progress bar each ([#3816](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3816)); and the script behind the [`plan-goal`](../../skills/plan-goal/SKILL.md) skill, which files a breakdown and answers "what now?" | [`lib/goals-lib.ps1`](lib/goals-lib.ps1), [`pages/plan-goal.ps1`](pages/plan-goal.ps1) |
| The day plan behind the [`day-plan`](../../skills/day-plan/SKILL.md) skill: the morning's plan inside a 6-8 h band, items added during the day, and the day's and the week's close-out matched against GitHub, kept as one day file per machine under `%LOCALAPPDATA%\dkj-admin\dayplan\` ([#3859](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3859)) | [`lib/dayplan-lib.ps1`](lib/dayplan-lib.ps1), [`pages/day-plan.ps1`](pages/day-plan.ps1) |
| The Today page on `/dev/today`, first of Admin's own cards: the day goal with its progress, the plan with each item's live state, what got done (the extra work included), what is not today, and the week, from `day-plan.ps1 -Status` run as a child, so the GitHub search behind it has one source ([#3860](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3860)) | [`lib/today-page-lib.ps1`](lib/today-page-lib.ps1) |
| The Plugins page, a card per enabled plugin, and each plugin's own page on `/dev/plugins/<name>`, from `plugin-versions.ps1 -Json`, with a Specialists, Hooks and Skills section of what it ships, each item a landing page on `/dev/plugins/<name>/<kind>/<slug>` | [`lib/plugins-page-lib.ps1`](lib/plugins-page-lib.ps1) |
| The Stopwatch and the Logbook: their pages, their router, the hooks that time a run, and the Stopwatch's sync | [`lib/stopwatch-lib.ps1`](lib/stopwatch-lib.ps1), [`lib/logbook-lib.ps1`](lib/logbook-lib.ps1), [`lib/timing-pages.ps1`](lib/timing-pages.ps1), [`../hooks/stopwatch-hook.ps1`](../../hooks/stopwatch-hook.ps1), [`../hooks/logbook-hook.ps1`](../../hooks/logbook-hook.ps1), [`lib/stopwatch-sync-lib.ps1`](lib/stopwatch-sync-lib.ps1), [`pages/stopwatch-sync.ps1`](pages/stopwatch-sync.ps1), [`pages/stopwatch-hide.ps1`](pages/stopwatch-hide.ps1), the [`stopwatch-hide`](../../skills/stopwatch-hide/SKILL.md) skill, [`pages/stopwatch-prepare.ps1`](pages/stopwatch-prepare.ps1) and the [`stopwatch-prepare`](../../skills/stopwatch-prepare/SKILL.md) skill |

These are plugin-only files, like [`../worker/`](../../worker/): no root copy in the source repo mirrors
them. They are tested there by `dev-preview-sessionstart.tests.ps1`, `dev-pages.tests.ps1`,
`consumer-dashboard.tests.ps1`, `goals.tests.ps1`, `dayplan.tests.ps1`, `stopwatch.tests.ps1`, `stopwatch-sync.tests.ps1` and `logbook.tests.ps1`.

## One look in every repo

**The rule, in three parts** (Maikel, October 29, 2026,
[#3643](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3643)):

1. **Every repo that runs `dkj-policy` gets Admin, with no exceptions.** The plugin serves it at
   session start whatever the repo states, and no repo can opt out of it or put its own server in its place.
2. **Admin renders in the brand book in every one of those repos, BWJ-Development's included.** It is
   this plugin's own tooling, not a repo's product, so it keeps one look wherever it runs, the way any tool's
   own screens do. Nothing in the repo can change that.
3. **A repo's product port is the repo's own, and the brand book reaches it only in a DKJ-Solutions repo.**
   There it is a rule, not an automatism: the `dkj-solutions` extension says every page a DKJ-Solutions app
   renders starts from the brand book, the app copies `house-style.css` and `house-theme.js` in unchanged
   (and, for a product page, `house-product.css`, the mobile-first product layer that lives in that extension),
   and that extension's `check-house-style` gate holds the copies to the pinned release. A BWJ-Development
   repo, which never enables `dkj-solutions`, styles its product itself.

The stylesheet and theme script come from this plugin's own
[`assets/dkj-brandbook/`](../../assets/dkj-brandbook/) (`Get-HouseStyleDir`), which every install of `dkj-policy`
carries. They sat in the `dkj-solutions` extension's folder until
[#3531](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3531); the rule that a DKJ-Solutions app
starts from them stays there. **Admin renders from these two files alone**: the product layer (`house-product.css`,
the site header, the breadcrumb bar and the mobile-first components) is the `dkj-solutions` extension's, loaded
after them on a product page and never alone ([#3831](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3831)).
`Format-GeneralPageHtml` draws Admin's desktop shell and refuses `-BrandTag 'product'`.

**No Admin shows or serves the Brandbook, whether or not the repo enables `dkj-solutions`**
([#3475](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3475), the owner, October 25, 2026). The
Brandbook app was a product of `dkj-claude-plugins`, shown only there on its own product port (#3283), and
that app is retired (#3493). On every Admin `/brandbook` is a plain 404 and the home page has no Brand book
card. Until #3475, a repo enabling `dkj-solutions` got both (#3198, #3270).

## Admin and the product

**The plugin serves Admin in every repo, whether or not the repo states `Get-DevPreview`** (the
owner's decision, October 21, 2026,
[#3245](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3245), replacing the placeholder of
[#3047](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3047)). Admin is the general pages
server itself, on the first free port from **4890 to 4899**, so Admin and its General pages share one
origin and one stored theme choice. A server a repo states in `Get-DevPreview` is its **product**: one
link on that Admin, not Admin itself.

**Admin has one screen; the product has every screen** (Maikel, November 4, 2026). The two ports are
read in different places, and that decides whether a page width is anybody's choice:

- **Admin is read in VS Code's Simple Browser**, so its screen is always about 16:9 and never a phone.
  A width choice has nothing to decide there, so Admin offers none: every Admin page pins the brand
  book's width to `full` right after `house-theme.js` (`Get-AdminWidthScript`, which also overwrites a
  Phone or Fluid stored while the choice was still offered), its Settings page has no Width group, and a
  floating settings panel on one of its pages draws with `widths: false`. Design an Admin page for that one
  screen.
- **The product port is where a repo builds its app** (`dkj-recipes`, for one), read in the Simple Browser
  *and* on a phone. There the page must be responsive, and the brand book's width choice (Fluid, Phone,
  Full) is the app's to offer.

**Admin has one form, in every repo** (the owner's decision, October 16, 2026,
[#3066](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3066)): the one laid down in
[`assets/dkj-brandbook/README.md`](../../assets/dkj-brandbook/README.md), section
"Admin": one page on `/` (#3289, which ended #3270's separate About this repo page; an old link to
`/about` is sent to `/`), with a separate **GitHub** page since #3383 (called Repository until it took the
GitHub name and logo), both drawn in Admin's desktop shell since #3830. The blocks and their order are fixed.
The home page opens the shell with **Home** as its one crumb and marked in the side navigation, and with no
toolbar and no `h1`, because the shell names the repo (`Format-RepoHomeHeadHtml`). The general banner comes
first in the main pane, and under it one `.table--dense` of links, a row per page with its description and no
heading above it (`Format-AdminLinkTableHtml`):

- the **product**, where the repo states a server: its link, or a line saying it is not running;
- **GitHub**, the page on `/dev/repository` holding the facts (the GitHub repo where the `origin` remote is
  on github.com, the folder, the dev preview, where it is stated and who serves Admin) and a row for
  **Issues** and the **Test gate** and, on GitHub, for the pull requests and the CI runs;
- the **General** pages but Issues and the Test gate, by bare path.

Under the list, only where the repo states no `Get-DevPreview` at all, two **setup cards**: how to add one,
and which port to route to VS Code's Simple Browser. A footer names the serving script. **The site header
and the card grid Admin had before #3830 are the product layer's now**: a product's own home page takes
the site header and the breadcrumb bar through `dkj-solutions`' `Format-ProductHomeHeadHtml` (#3831), and its
cards follow that layer's README.

Both pages are built per request from the state file below, and the repo's name, its `origin` slug and the
product url, the only values from outside, are HTML-escaped. The line the hook prints opens with `Admin:` (`Hub:` until the owner renamed the hub Toolbox, October 27, 2026, and `Toolbox:` until #3815), and a repo cannot
choose another word. A `Name` a repo still states in `Get-DevPreview` is ignored, so delete it at your next
edit. "dev-preview" names the mechanism, which is why the hook's lines about its own setup (skipped) still
open with it.

**There is no opt-out** ([#3643](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3643), Maikel,
October 29, 2026). From #3245 to #3643 a repo could state `OwnHub = $true` in `Get-DevPreview`, and its own
server was then Admin instead of this plugin's, with a nested `Product = @{ ... }` beside it from
[#3283](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3283). Such an Admin was the repo's own, so
nothing held it to the brand book, and a BWJ-Development repo could leave Admin's one look behind.
Since #3540 every repo has a product port and #3464 had rolled this plugin's Admin out to every DKJ repo, so
the opt-out had no remaining use. **Both keys are ignored where a repo still states them**, the way `Name`
has been since #3064: the repo's server is its product on this plugin's Admin, a `Product` beside it is
never started, and in a DKJ-Solutions repo the line ends `-- config drift: delete Get-DevPreview's OwnHub,
Product`. This repo was the last to use the opt-out, until #3540.

## The dev-preview hook

[`hooks/dev-preview-sessionstart.ps1`](../../hooks/dev-preview-sessionstart.ps1) runs at session start
(`startup`, `resume`, `clear`; not `compact`, which is mid-work). It replaced a copy per repo in
`dkj-brandbook`, `dkj-etf-tracker` and `life-hub`
([#2967](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/2967)). In order:

1. It reads `Get-DevPreview` from `scripts/repo-config.ps1`, then takes one snapshot of the listening sockets
   and the process table.
2. **It starts or reuses Admin first, before anything that can end the hook early** (the product's ports
   taken, a `Requires` path missing, a `%` or `^` in the repo root, a config that does not parse or cannot
   be read), so the General pages always run, also where the repo's own server cannot
   ([#3244](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3244)). Only Admin's own problems
   stop it: ports 4890-4899 all taken, a `%` or `^` in the plugin or repo path, a plugin install without
   Admin's libraries. The line then names that instead of a link.
3. Where the repo states a server, it reuses this checkout's product or starts the
   `Command` on the first free port, then waits until each server it started listens: **a dead link is worse
   than none.** Both waits run in one loop, so the common case costs the longer of the two, not their sum.
   Admin's own deadline is 12 seconds; the product's is `WaitSeconds`.
   **A server it starts does not outlive its session**
   ([#3569](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3569)): a disconnected Windows session
   keeps its processes, so a product started there held its port for every later session, including another
   account's, which cannot stop it without elevation. So each server gets a watcher in the same session,
   [`pages/dev-preview-watch.ps1`](pages/dev-preview-watch.ps1). Once that session has stayed disconnected for
   a minute, the watcher stops the server's whole tree, and it exits with the server either way. Session 0 gets
   none, because it always reads as disconnected. **A disconnect counts only after the session was seen
   connected** ([#3595](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3595)): a session that
   reads disconnected from the start is in use while disconnected, because the hook ran there. Claude Code
   under a second account on a machine that switches accounts runs exactly so, and its Admin used to stop about
   two minutes after every start. **And it counts only while no Claude Code runs in the session**
   ([#3798](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3798)): a session that was switched away
   from while Claude Code kept working in it is in use, and the owner reads its Admin from the other session.
   Once no `claude.exe` (or `@anthropic-ai/claude-code` under node) is left there, the session counts as
   abandoned again.
4. It writes the state file, and prints **one line**, which hands out both links:

| The repo | The line |
|---|---|
| states no `Get-DevPreview` (or one that answers nothing) | `Admin: http://localhost:4890/ (started) -- this repo states no Get-DevPreview yet; route localhost:4890 to simpleBrowser.open in .vscode/settings.json to open it in VS Code` |
| states a server | `Admin: http://localhost:4890/ -- product: http://localhost:4321/dkj-recipes/ (started)`; `(already running)` where it is reused |
| states a server that cannot start | `Admin: http://localhost:4890/ -- product not started: port 3000 taken by other processes: 3000 by dkj-lifehub (pid 19544)` |
| and the holder's command line cannot be read | `... 3000 by pid 22588 (its command line cannot be read)` |
| and the holder runs in another Windows logon session | `... 3000 by pid 22588 (another logon session, 29 -- its command line cannot be read; stop it in that session, or from an elevated shell: Stop-Process -Id 22588)` (#3401, #3569) |
| states a server that binds and then quits | `... -- product: the server on port 3001 stopped right after it started listening -- see <log>`: a started server reads as `(started)` only once it is still listening two seconds after its first answer (#3404) |
| `Requires` a `node_modules` older than the `package-lock.json` beside it | the product's clause ends `; 'node_modules' is older than its package-lock.json -- run npm install` where a package the lock pins is installed at another version, or not at all, according to npm's own `node_modules/.package-lock.json`. A lock that was only rewritten is not named (#3419), and the server is still started (#3404) |
| still states a retired key (`Name`, `OwnHub`, `Product`), in a DKJ-Solutions repo | the line as for a server, ending `-- config drift: delete Get-DevPreview's OwnHub, Product`; the keys are not read (#3064, #3643) |
| and Admin cannot start | `Admin: not started -- <why>`, then the product's clause where there is one |

The route hint appears only where the repo states no server and does not route Admin's port; with the
route, Admin opens in VS Code by itself. Routing the port is done once in the repo's
`.vscode/settings.json`, and a repo opened beside others takes a later port, so list as many of the ten as
the repo needs:

```json
"workbench.externalUriOpeners": {
    "localhost:4890": "simpleBrowser.open",
    "localhost:4891": "simpleBrowser.open"
}
```

A repo with a server of its own states it like this:

```powershell
function Get-DevPreview {
    @{
        Command      = 'npm run dev -- --port {port} --strictPort'   # required; {port} is filled in
        Ports        = 5173..5180       # required: one port (1024-65535), or a list tried in order (at most 32)
        Path         = '/'              # optional: the URL path (default '/')
        Requires     = 'node_modules'   # optional: relative path(s) inside the repo that must exist first
        WaitSeconds  = 20               # optional: how long to wait until it listens (1-45, default 20)
        OpenInVsCode = $false           # optional: also hand Admin's URL to VS Code (see below)
        DefaultTheme = 'teal'           # optional: the theme the plugin's Admin and general pages open in (default lilac)
    }
}
```

- **Trusted repos only.** The hook runs the repo's own `Command` at every session start, the same trust
  the repo's `scripts/repo-config.ps1` already gets from every hook that reads it. Enable this plugin only
  in repos you own.
- **`OwnHub` and `Product` are retired** (#3643): a repo that still states them keeps its server as the
  product, and deletes the two keys at its next edit.
- **`DefaultTheme` is the theme the plugin's pages open in while the visitor has picked none**
  ([#3390](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3390)): a house theme id, such as
  `teal`. A repo whose own product or Admin opens in its own theme states it here, so Admin and the general
  pages it links do not open in another. Unstated, they keep lilac (#3162). A product that opens in a
  light/dark pair states the same pair, `DefaultTheme = @{ Light = 'blue'; Dark = 'sky' }`
  ([#3608](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3608)), and the pages then open in the
  half that matches the OS mode; a pair states both halves and nothing else. Each theme must have a theme id's shape
  (a lowercase letter, then lowercase letters, digits or hyphens); anything else is a problem the line
  names. It belongs to Admin alone, so a `Product` may not state it. The hook writes it into the state
  file, and the general pages server reads it per request, so a change reaches the next page after a
  session start without a restart.
- **The `Command` runs under `cmd.exe`:** it expands `%VAR%`, and where it chains commands with `&&` the
  log captures the last one's output only. A `Write-Host` in the config is harmless.
- **Bind to `127.0.0.1` in the `Command`** wherever the server shows something private, e.g.
  `python -m http.server {port} --bind 127.0.0.1` or `next dev -H 127.0.0.1 -p {port}`. The hook cannot
  know what a server exposes. A server you started by hand in the checkout is reused as well, without
  your `Command`, so when the `Command` names a loopback host and the reused server listens on every
  interface, the product's part of the line says `LISTENING ON ALL INTERFACES`. Restarting it is up to you.
- **A running server is reused, never doubled.** A listener counts as this checkout's when its own
  command line, or one of its four nearest ancestors' command lines, names this checkout's root at a path
  boundary. The hook starts every server under a `cmd.exe` that changes into the root first, which is how
  a server whose own command line names no path is still recognised. A foreign app, another clone, a
  `worktree-lane` lane (a sibling `<repo>-lanes/` folder) or a Claude Code worktree under `.claude/worktrees/` is never mistaken for it:
  its port is skipped and the next one tried.
- **The servers outlive the session.** They run hidden and detached, logging to
  `%TEMP%\dev-preview-<repo>-<hash>.log` (the product) and `%TEMP%\dev-preview-general-<repo>-<hash>.log`
  (Admin). Each log is overwritten when its server
  starts, and the servers are stopped like any process. A server that exits at start is reported at once,
  with that log's path. **The price of Admin is one small PowerShell server per
  checkout**, whatever the repo's own server is: a repo on Vite or Next.js gets the same pages without
  touching its server.
- **`OpenInVsCode`** runs `code --open-url <admin url>`, only when
  the session runs in VS Code's terminal. A repo that states no server needs no setting: it is on where the
  repo routes Admin's port. To land in VS Code's Simple Browser rather than the system browser, the
  repo routes the URL as above.
- **It never fails the session.** Every path exits 0 with at most one line. It runs on Windows only, like
  the copies it replaced; elsewhere it prints nothing.

## The general pages server

**These pages are the same in every repo, so the plugin serves them, not the repo** (the owner's decision,
October 18, 2026, [#3119](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3119)).
[`pages/serve-general-pages.ps1`](pages/serve-general-pages.ps1) runs on the first free port from **4890 to
4899**, under the same rules as every server here: loopback only, reused and never doubled (its `cmd.exe`
names the checkout), started hidden and detached.

**It serves no Brandbook, in any repo** ([#3475](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3475),
the owner, October 25, 2026). From #3198 to #3475 a DKJ-Solutions repo's server served a fifth page, the
Brandbook app's build from `dkj-solutions/assets/brandbook/`, under `/brandbook/`. The route went with #3475, and the app itself with #3493: no repo has a Brand book to
show. The brand book's own specimens are a page under Plugins instead, on `/dev/plugins/dkj-policy/dkj-brandbook`, its card named dkj-brandbook as the product's is (#3704),
in every repo that runs Admin, BWJ-Development's included ([#3629](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3629));
the older `/dev/plugins/dkj-solutions/house-style` and `/dev/plugins/dkj-policy/house-style` redirect there.

| Page | Reads, from the repo it was started in | When it is absent |
|---|---|---|
| `/`, `/index.html`, `/admin` | The state file below, on every request: the home page of this plugin's Admin; `/about` and the retired `/artifacts` answer 303 to `/` (#3289, #3772). No repo's `/admin` redirects elsewhere any more (the `OwnHub` 303 went with #3643) | Always answers |
| `/dev/repository` | The state file and the `origin` remote: Admin's GitHub page, its facts and a card for Issues and, where the remote is on github.com, its pull requests and CI runs (#3383) | Always answers; with no github.com remote the facts carry no GitHub row and the page no GitHub cards |
| `/dev/issues` | `gh issue list`, three calls (the open issues, and those opened and closed in the last 28 days), for `--repo <owner/name>` taken from the `origin` remote when it is on github.com, else for the repo `gh` finds in the working directory; kept for five minutes | A `gh` that fails or is missing is a warning on the page |
| `/dev/release-notes` | `.dkj/dkj-policy/releases/page/release-notes.html`, dressed in the brand book on the way out. Built first where it is absent or older than a file under `.dkj/dkj-policy/releases`, by `build-release-notes-page.ps1` in a child process (bounded at 60 s), the repo's own copy else this plugin's: the page is a gitignored snapshot that nothing else builds (#3189) | A plain 404 text naming why it could not be built; where a rebuild fails, the older page is served |
| `/dev/sessionstart` | The always-on path, measured in a child process (bounded at 60 s) by `always-on-budget-lib.ps1`, the repo's own copy else this plugin's; kept for a minute | The reason it could not measure, on the page |
| `/dev/test-gate` | `scripts/tests/suite-durations.json`, grouped by `scripts/tests/suite-groups.json` where the repo keeps one, and each suite's own `.SYNOPSIS` (#3470) | The page says no test gate has been measured in this repo yet |
| `/dev/stopwatch`, `/dev/stopwatch/<label>[/<run>]` | This repo's Stopwatch store on this machine, and the session transcripts for a run's phases (#3470; see the timing pages below) | An empty overview |
| `/dev/logbook`, `/dev/logbook/<slug>` | This repo's Logbook store on this machine, and the session transcripts (#3470; see the timing pages below) | An empty overview |
| `/api/airsquats` | The banner's state as JSON; `POST /api/airsquats/clear` ticks its box off, the one `POST` the server takes, served same-origin only (#3438). Below | A state that cannot be read is a 503, and the banner stays hidden |

**Two things to know about what these pages read and who can read them.** `/dev/sessionstart` and
`/dev/release-notes` run a child process that first dot-sources the repo's own `scripts/repo-config.ps1`, and
the repo's own `scripts/lib/always-on-budget-lib.ps1` or `scripts/release/build-release-notes-page.ps1`
where it has one: the same trust the dev-preview hook already gives
`scripts/repo-config.ps1`, so enable the plugin only in repos you own. And the pages are **unauthenticated on
loopback**: any process on the machine can read them, so a private repo's issue titles are readable by
every local process, not only by the browser of whoever started the session.

Every page's first crumb is `/`, Admin's own root (Maikel, November 2, 2026). It was `/admin` while the
source repo's product relayed these pages from its own origin with `Copy-LoopbackUpstream` (in
[`lib/loopback-server-lib.ps1`](lib/loopback-server-lib.ps1),
[#3168](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3168)), where `/` is the product's home.
That relay ended with #3540, so nothing serves these pages from another origin now. A caller that ever does
again names its own `-AdminHref`, and `/admin` keeps answering, so an old link still lands on Admin. The pages
carry the repo's name, `owner/name` from the `origin` remote, else the folder's. Each issue links to the
`url` `gh` returned for it, and only when that is a GitHub issue link.

**How the servers find each other: one state file per checkout**,
`%TEMP%\dkj-repo-admin-<folder>-<hash>.json`, which the hook writes at every session start, whatever it found:

```json
{ "root": "<repo root>", "admin": "<url>", "pages": "<http://localhost:489x, or empty>", "product": "<url, or empty>", "mode": "none|product" }
```

`mode` is what the repo states: `none` (no `Get-DevPreview`, so Admin shows the setup cards), `product`
(a server of its own, one link on the plugin's Admin). `admin` is the general server's own base plus `/`;
`product` is the repo's own server url, or empty. The hash is the one the hook's log paths use (SHA1 of the lowercased
root). A reader believes the file only when `root` names its own checkout. `admin` and `product` are believed
only as `http://localhost:<port>` plus an optional path of the characters `Path` allows (at most 240
characters: no other host, no other scheme, no control character), `pages` only on a port of 4890-4899, and
`mode` only as `none` or `product`, so the file is never a way to send a link elsewhere. A file written
before #3245 has no `mode` and no `product`, and reads as `none`; an `ownhub` written before #3643 reads as
`product`, until the next session start writes the file again.

**An open port does not say whose server it is** (two checkouts race for the same ports, and a stale file
can name a port another checkout has taken), so the server answers `/whoami` with the hash of the root it
was started in, and a product that relays the pages links them only when that is its own root's hash
(`Get-GeneralPagesUrl`). A product that is not PowerShell (Vite, Next.js) reads the same file in its
own language; a request for one of the four paths on its own server is best answered with a redirect to
`<pages><path>`, and the source repo's server answers a short 404 text naming the general pages server when
no server answers as this checkout's.

**Ports do not count toward "site", so the links between the servers are same-site navigations.** The
Fetch Metadata check both plugin servers (and the source repo's) apply refuses `same-site` unless it is a
top-level `GET` navigation (`Sec-Fetch-Mode: navigate`): the product's link on Admin and the 303 to an
opted-out repo's Admin are served, a same-site fetch or image request is not. **`cross-site` is refused
unless it is that same navigation into a document of its own** (`Sec-Fetch-Dest: document`, #3834), which
is how Claude in Chrome opens a page: its initiator is the extension. Another site can then send the user
to a page but never read it, and the one GET with an effect, `/refresh`, is rate-limited. A cross-site frame
stays refused by that `Dest` check, and every response forbids framing on its own as well
(`Content-Security-Policy: frame-ancestors 'none'` and `X-Frame-Options: DENY`, #3835), which is what keeps out
a same-site frame. The 403 names the three headers it judged.

## The banner, in sync on every machine

**Ticking the airsquats box on one machine clears it on every machine, and in every repo's Admin on each**
([#3438](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3438), Dave, October 25, 2026). Until
then the banner kept its count in the browser's `localStorage`. That is one count per origin, and every repo
Admin has its own port, so two repo Admin servers on one machine already disagreed.

**And it shows only while something is due** (Dave, October 27, 2026): hidden until an hour is owed, it
slides down when the hour turns on an open page and back up once the box is ticked. A page opened with squats
already owed shows it at once, and `prefers-reduced-motion` drops the slide.

- **The page asks its own server**: `GET /api/airsquats` every 15 seconds and at the turn of the hour, and a
  `POST` to `/api/airsquats/clear` when the box is ticked. It counts the minutes down by itself.
- **Every Admin server on a machine shares one file**, `%LOCALAPPDATA%\dkj-admin\airsquats.json`, written under
  a lock. The plugin's servers and the source repo's product read the same file, since every page of either
  carries the banner.
- **Where you opt in, that file is merged with a private GitHub gist**, by `pages/sync-airsquats.ps1` in a
  hidden child at most every 20 seconds while an Admin page is open, and at once after a tick-off. The server
  never waits on the network, so another machine sees a tick-off within about half a minute.

**The state merges without conflict**: the full hours at whose start an Admin was open (merged as the union)
and the last tick-off (the later one wins). Ten airsquats are owed for every such hour after the last
tick-off. An hour counts only where an Admin saw it begin, so a night with every Admin closed adds nothing, as
before. The tone plays once per machine, within two minutes of the hour.

**The gist is an opt-in** (#3439), set with the `DKJ_ADMIN_AIRSQUATS_GIST` environment variable in the `env`
block of the machine's own `~/.claude/settings.json`. **Unset**, nothing syncs and nothing is written to
your GitHub account: the banner agrees across the repo Admin servers of this machine only. **`auto`** makes the child
look for a gist described `dkj-hub-airsquats` among the gists of the account `gh` is logged in as, and
create it, private, on first use, so machines on the same `gh` account find each other with that one
setting. **A gist id** pins that gist, which is how machines on different accounts share one. Any other
value syncs nothing and says so as `syncError`. A failed sync (no `gh`, logged out, offline) is written into
the state file as `syncError` too. The banner then goes on with this machine's own count, and the next sync
catches up.

**After updating the plugin from a version before #3245:** a general pages server that the old plugin
started is reused until it exits, and it answers `/` with its old 303 or 404 until then. Stop it (or restart
the machine) once. And a product's `Ports` must not overlap 4890-4899, which Admin takes first.

## The timing pages, in every repo

**They time how long an assignment takes, from the prompt to the moment Claude is back on the trunk**, and
both were the source repo's own pages until the owner moved them here
([#3470](https://github.com/DKJ-Solutions/dkj-claude-plugins/issues/3470), October 25, 2026). The
**Stopwatch** times a prompt whose first line begins with `stopwatch:`, and every release cut even without
one. The **Logbook** times every session that begins on a clean trunk, without anybody marking it. This plugin's `UserPromptSubmit` and `Stop` hooks
record the runs (`hooks/stopwatch-hook.ps1`, `hooks/logbook-hook.ps1`), and the pages only read them. The
one run a script starts is the cut's: `cut-release.ps1` starts a `release cut` run as it begins, unless a run
is already going, and the Stop hook ends it on the cut's `release: vX.Y.Z release notes` commit. A cut refused
after that start leaves its run going; the next cut discards it once it is over 12 hours old
([#3781](https://github.com/DKJ-Solutions/dkj-marketplace/issues/3781)).

- **One store per repo, on each machine**: `%LOCALAPPDATA%\dkj-claude-plugins\repos\<repo>-<hash>\`, named by
  the checkout's folder and a hash of its path, so two repos in folders of one name never share one (a
  `worktree-lane` lane and a Claude Code worktree count as the repo they were cut from). It is outside the tree, so a hook writing it never dirties the checkout it is timing.
- **Not shared unless the repo opts in.** A run's label is the first line of a prompt, so the Stopwatch
  publishes its finished runs to `refs/stopwatch/<machine>` on the repo's `origin` only where the repo sets
  `DKJ_STOPWATCH_SHARE` to `1` in the `env` block of its `.claude/settings.json`. Then each machine's
  Stopwatch shows the others' runs too, and the push runs with your own git credentials. **The repo decides,**
  so a repo you clone can turn it on; a machine answers otherwise with `DKJ_STOPWATCH_SHARE` set to `0` in
  that repo's `.claude/settings.local.json`, which wins. The Logbook is never shared.
- **The Logbook keeps the first line of every logged session's first prompt** in that store, unencrypted, on
  this machine. Do not open a session with a secret on its first line.
- **The hooks cost every prompt and every turn's end two short PowerShell processes.** An unmarked prompt
  ends the Stopwatch's hook before it loads anything, and a session already seen ends the Logbook's at its
  store read.
- **The Test gate needs a measurement the repo takes itself**: `scripts/tests/suite-durations.json`, the
  mean CI duration per suite. The source repo writes it with its own `record-suite-durations.ps1`; a repo
  without the file sees the page's empty state.

## In the source repo

This repo's Admin is this plugin's, as in every other repo: since #3540 its `Get-DevPreview` states no `OwnHub`; #3643 then retired that opt-out for every repo. Its product is the **consumer dashboard** (every repo
registered under `consumers/` and what `check-consumers.ps1` reports for it), the specialists and their
context cost, and, on the DKJ group's consumer page, every DKJ repo on GitHub, served on `127.0.0.1` by `scripts/dashboard/serve-consumer-dashboard.ps1`,
with the brand book from this tree and a first card back to Admin. `scripts/lib/dev-pages-lib.ps1` reads
`lib/general-pages-lib.ps1` from this tree for the page shell. The General pages, the Test gate among them,
are Admin's alone: the suite selection this checkout's change makes, which the old own Admin added to its Test
gate, went with it. That server uses a
`TcpListener` rather than an `HttpListener`: under the latter the socket belongs to `http.sys` (PID 4), and
the hook could never recognise the server as this checkout's.

**Admin on `:4892` is the installed release, so a merged Admin change shows there only after the next
release.** To see this tree's Admin first, serve it on a free port from the repo root:
`./plugins/dkj-policy/apps/admin/pages/serve-general-pages.ps1 -Port 4910`, backgrounded -- not a port from 4890 up, where the other checkouts' Admin servers sit. `.claude/settings.json`
allows exactly that command, so a session runs it without a permission refusal.
