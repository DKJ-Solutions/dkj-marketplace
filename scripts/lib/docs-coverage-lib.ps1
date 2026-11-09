<#
.SYNOPSIS
    The product's Docs coverage pages (#3906): the ten opportunities a comparison of the official Claude Code docs
    against this repo (v6.11.0) found, as an overview table on /docs-coverage and a page of its own per item on
    /docs-coverage/<slug>, so the owner follows them in one place rather than as ten loose issues.

.DESCRIPTION
    WHAT IS FIXED AND WHAT IS LIVE. An item's idea (what, why) and what was verified about it against the docs are
    fixed text, here in Get-DocsCoverageItems: they are the issue's own content as a sweep checked it on November 8,
    2026, and they do not move while the issue waits. Its STATUS is live: one GraphQL call reads every item's issue
    (Get-DocsCoverageQuery), and Get-DocsCoverageStatus turns its state and labels into the one word its row shows.
    A failed read shows the rows without a status and says so, never a blank page.

    BESIDE THE TEN, EVERY DOCS PAGE (the owner, November 9, 2026: "really everything from the Claude Code docs"):
    Get-DocsCoverageCatalog, in docs-coverage-catalog.ps1 beside this file and loaded with it, holds each page with a
    fixed status of its own (Covered, Not used, Not relevant) and the note and evidence behind it, so the overview
    also says what this repo already uses well and needs no attention.

    No I/O here: the server (scripts/dashboard/serve-consumer-dashboard.ps1) asks gh and hands the answer in, so every
    rule is tested without a server, in scripts/tests/dev-pages.tests.ps1.

    Pure ASCII (repo convention for .ps1).
#>

. (Join-Path $PSScriptRoot 'docs-coverage-catalog.ps1')

function Get-DocsCoverageItems {
    <#
        The ten items in the issue's own order (#3906's table). Label is the row's link and the page's h1 (five words
        at most, no code); Sub its one line and What and Why the idea, which the "?" beside its name shows; Verified what the docs said when it was
        checked, one string per point; Docs the docs page it rests on, and Section and Group where that page sits in
        the docs navigation (read from code.claude.com/docs/llms.txt on November 9, 2026: its ## heading and its ####
        group; plugins-reference is not listed itself and serves the Plugin manifest reference, so it takes that
        page's place). SectionUrl and GroupUrl are the page each opens on in that navigation (its first link), and
        DocsAnchor the heading on the docs page the item is about, each checked as an id on the live page, with
        DocsHeading the heading's text as that page shows it: the link text on the item's own page.
        WhyDeclined, on an item the owner closed as not planned, is the decision that closed it, in one or two
        sentences: the overview shows it behind a "?" beside Declined.
    #>
    @(
        @{ Slug = 'plugin-dependencies'; Issue = 3895; Label = 'Plugin dependencies'
           Sub = 'Declare which plugins a plugin needs in its manifest'
           What = 'Declare plugin dependencies in plugin.json (dependencies) instead of in prose checked by a session check.'
           Why = 'Claude Code then installs a missing dependency itself, before any session runs.'
           Verified = @(
               'The dependencies key exists, and install, enable and auto-update pull in a missing dependency.'
               'Tags of the form plugin--vX.Y.Z are needed only for a version-constrained dependency, beside the lockstep vX.Y.Z tag.'
               'A disabled dependency disables the plugin that depends on it.')
           Section = 'Plugins'; SectionUrl = 'https://code.claude.com/docs/en/plugins/overview'
           Group = 'Create plugins'; GroupUrl = 'https://code.claude.com/docs/en/plugins/create'
           Docs = 'https://code.claude.com/docs/en/plugins/dependencies'; DocsAnchor = 'declare-dependencies'; DocsHeading = 'Declare dependencies' }
        @{ Slug = 'behavioural-evals'; Issue = 3896; Label = 'Behavioural evals'
           Sub = 'Prove a skill or specialist still fires on its prompts'
           What = 'Add an evals/ suite per plugin, run with claude plugin eval in CI.'
           Why = 'The gates measure structure and cost, not behaviour; an eval catches a description shortened past the point where it still fires.'
           Verified = @(
               'claude plugin eval exists and runs in CI with --json, --threshold and --trust-plugin.'
               'Every case is a model run, so CI evals draw on the same credential as the review workflow.')
           Section = 'Plugins'; SectionUrl = 'https://code.claude.com/docs/en/plugins/overview'
           Group = 'Create plugins'; GroupUrl = 'https://code.claude.com/docs/en/plugins/create'
           Docs = 'https://code.claude.com/docs/en/plugin-evals'; DocsAnchor = 'run-evals-in-ci'; DocsHeading = 'Run evals in CI' }
        @{ Slug = 'subagent-frontmatter'; Issue = 3897; Label = 'Richer subagent frontmatter'
           Sub = 'Effort, turn limit, skills, memory and a model per role'
           What = 'Use effort, maxTurns, skills, memory and a per-role model on the specialist agent definitions.'
           Why = 'Every agent runs on sonnet with no effort level and no turn limit, whatever its role.'
           Verified = @(
               'All five keys exist on subagent frontmatter.'
               'skills preloads skills, not manuals: a manual would first have to become a skill.'
               'memory writes an agent memory store, next to the rule that lessons go into the docs.')
           Section = 'Build with Claude Code'; SectionUrl = 'https://code.claude.com/docs/en/agents'
           Group = 'Agents and parallel work'; GroupUrl = 'https://code.claude.com/docs/en/agents'
           Docs = 'https://code.claude.com/docs/en/sub-agents'; DocsAnchor = 'supported-frontmatter-fields'; DocsHeading = 'Frontmatter reference' }
        @{ Slug = 'hook-if-async'; Issue = 3898; Label = 'Conditional and async hooks'
           Sub = 'Start PowerShell only when a hook has work to do'
           What = 'Use if and async on the hooks in hooks.json.'
           Why = 'Every hook starts a PowerShell process on every matching event.'
           Verified = @(
               'if exists on tool events only, and the docs call it a best-effort filter.'
               'async exists on command hooks; its timeout is not enforced.'
               'The PreToolUse hook is the subagent safety guard, so a best-effort filter in front of it is a trade.')
           Section = 'Reference'; SectionUrl = 'https://code.claude.com/docs/en/cli-reference'
           Group = 'Reference'; GroupUrl = 'https://code.claude.com/docs/en/cli-reference'
           Docs = 'https://code.claude.com/docs/en/hooks'; DocsAnchor = 'hook-handler-fields'; DocsHeading = 'Hook handler fields'
           WhyDeclined = 'Measured: if cannot filter the safety guard or the one thing publish-background-run acts on, and async on the Stop hooks saves no wall-clock. The owner chose a shell-side pre-filter instead (#3920), November 9, 2026.' }
        @{ Slug = 'skill-frontmatter'; Issue = 3899; Label = 'Richer skill frontmatter'
           Sub = 'Tool grants, argument hints and the shell a skill runs in'
           What = 'Use allowed-tools, argument-hint and shell in SKILL.md frontmatter.'
           Why = 'A skill could grant the exact script it runs, and the slash menu would show its arguments.'
           Verified = @(
               'All three keys exist.'
               'allowed-tools grants the tools without a prompt for the invoking turn, so it is a permission shipped to every consumer.'
               'argument-hint is harmless and could land on its own.')
           Section = 'Build with Claude Code'; SectionUrl = 'https://code.claude.com/docs/en/agents'
           Group = 'Skills'; GroupUrl = 'https://code.claude.com/docs/en/skills'
           Docs = 'https://code.claude.com/docs/en/skills'; DocsAnchor = 'frontmatter-reference'; DocsHeading = 'Frontmatter reference' }
        @{ Slug = 'plugin-workflows'; Issue = 3900; Label = 'Workflows in a plugin'
           Sub = 'The sweep and the review chains as workflow scripts'
           What = 'Ship workflows/*.js as a plugin component for the sweep and the review chains.'
           Why = 'Only the final result would return to the main context, and every run would take the same steps.'
           Verified = @(
               'Plugin workflows exist, namespaced as plugin:name.'
               'A workflow script has no file or shell access, so every claim, branch and gate step becomes an agent.'
               'Dynamic workflows need a paid plan, the API or a supported cloud provider.')
           Section = 'Build with Claude Code'; SectionUrl = 'https://code.claude.com/docs/en/agents'
           Group = 'Agents and parallel work'; GroupUrl = 'https://code.claude.com/docs/en/agents'
           Docs = 'https://code.claude.com/docs/en/workflows'; DocsAnchor = 'distribute-a-workflow-in-a-plugin'; DocsHeading = 'Distribute a workflow in a plugin'
           WhyDeclined = 'Workflows are off by default on Pro, a consumer can switch them off, and each needs approval on its first run. The owner kept the sweep and the review chains as prose plus scripts, November 8, 2026.' }
        @{ Slug = 'deny-ask-rules'; Issue = 3901; Label = 'Hard deny and ask'
           Sub = 'Let the harness enforce the safety rules'
           What = 'Ship deny and ask permission rules for the constitution''s safety rules.'
           Why = 'The deny rules exist only as a suggested settings file, so a consumer that never applies it has none.'
           Verified = @(
               'A plugin cannot ship permission rules: a plugin settings.json applies only agent and subagentStatusLine.'
               'The remedy has to be another route: an adoption step that writes them, a guard hook, or managed settings.')
           Section = 'Plugins'; SectionUrl = 'https://code.claude.com/docs/en/plugins/overview'
           Group = 'Create plugins'; GroupUrl = 'https://code.claude.com/docs/en/plugins/create'
           Docs = 'https://code.claude.com/docs/en/plugins/components'; DocsAnchor = 'default-settings'; DocsHeading = 'Default settings' }
        @{ Slug = 'bounded-review'; Issue = 3902; Label = 'Bounded CI review'
           Sub = 'A turn ceiling and its own credential for the review'
           What = 'Pass --max-turns and --model to the Claude review workflow, and evaluate an API key over the OAuth token.'
           Why = 'The subscription token shares its quota with interactive use, and the review has failed on every PR several times.'
           Verified = @(
               'claude_args takes --max-turns and --model; auth is an API key or the OAuth token.'
               'An API key is the owner''s act and bill; a turn ceiling needs the turn count of past green runs first.')
           Section = 'Getting started'; SectionUrl = 'https://code.claude.com/docs/en/overview'
           Group = 'Code review and pull requests'; GroupUrl = 'https://code.claude.com/docs/en/code-review-local'
           Docs = 'https://code.claude.com/docs/en/github-actions'; DocsAnchor = 'pass-cli-arguments'; DocsHeading = 'Pass CLI arguments' }
        @{ Slug = 'user-config'; Issue = 3903; Label = 'Plugin user configuration'
           Sub = 'Install-time settings, default-off teams, a main agent'
           What = 'Use userConfig, defaultEnabled and a plugin settings.json with agent in the manifests.'
           Why = 'Plain repo-config values would get a settings dialog, add-on teams could start off, and the orchestrator could run without a cache-path import.'
           Verified = @(
               'All three exist, and a CLAUDE.md at a plugin root is not loaded.'
               'This repo does not rely on one: a consumer imports the constitution by path.'
               'agent runs a plugin agent as the main thread with its own tools and model.')
           Section = 'Plugins'; SectionUrl = 'https://code.claude.com/docs/en/plugins/overview'
           Group = 'Reference'; GroupUrl = 'https://code.claude.com/docs/en/plugins/manifest-reference'
           Docs = 'https://code.claude.com/docs/en/plugins-reference'; DocsAnchor = 'user-configuration'; DocsHeading = 'User configuration' }
        @{ Slug = 'native-worktrees'; Issue = 3904; Label = 'Native worktrees'
           Sub = 'Claude Code worktrees against worktree-lane.ps1'
           What = 'Evaluate claude --worktree, .worktreeinclude, worktree.baseRef and the WorktreeCreate hook against worktree-lane.ps1.'
           Why = 'They looked like they might answer the two objections to dispatching a review into a worktree.'
           Verified = @(
               '.worktreeinclude copies gitignored files only, and baseRef takes fresh or head: neither carries uncommitted work.'
               'The worktree path inside the checkout was already ignored here.'
               'A native lane cuts a worktree- branch, which this repo''s branch table refuses.')
           Section = 'Build with Claude Code'; SectionUrl = 'https://code.claude.com/docs/en/agents'
           Group = 'Agents and parallel work'; GroupUrl = 'https://code.claude.com/docs/en/agents'
           Docs = 'https://code.claude.com/docs/en/worktrees'; DocsAnchor = 'customize-worktree-creation'; DocsHeading = 'Customize worktree creation' }
    )
}

function Get-DocsCoverageQuery {
    <#
        The one GraphQL query the pages ask: every item's issue, by number, under an alias of its own. Owner and name
        go as variables, so the query holds no double quote, which Windows PowerShell 5.1 would split on its way to gh.
    #>
    param([AllowEmptyCollection()][object[]]$Items = @(Get-DocsCoverageItems))
    $fields = @($Items | ForEach-Object { 'i' + $_.Issue + ': issue(number: ' + $_.Issue + ') { number state stateReason assignees(first: 1) { totalCount } labels(first: 30) { nodes { name } } }' })
    return 'query($owner: String!, $name: String!) { repository(owner: $owner, name: $name) { ' + ($fields -join ' ') + ' } }'
}

function ConvertFrom-DocsCoverageQuery {
    <#
        Get-DocsCoverageQuery's answer, as text, into @{ ByIssue; Error }: ByIssue maps an issue number to
        @{ State; StateReason; Labels; Assigned }. An empty or unreadable answer is an Error and an empty map.
    #>
    param([AllowEmptyString()][string]$Json)
    $byIssue = @{}
    if (-not $Json) { return @{ ByIssue = $byIssue; Error = 'gh returned nothing' } }
    try { $doc = $Json | ConvertFrom-Json } catch { return @{ ByIssue = $byIssue; Error = 'the answer was not JSON' } }
    if (-not $doc.data -or -not $doc.data.repository) { return @{ ByIssue = $byIssue; Error = 'the answer named no repository' } }
    foreach ($p in $doc.data.repository.PSObject.Properties) {
        $i = $p.Value
        if ($null -eq $i -or $null -eq $i.number) { continue }
        $byIssue[[int]$i.number] = @{
            State = [string]$i.state; StateReason = [string]$i.stateReason
            Labels = @($i.labels.nodes | ForEach-Object { [string]$_.name })
            Assigned = ([int]$i.assignees.totalCount -gt 0) }
    }
    return @{ ByIssue = $byIssue; Error = '' }
}

function Get-DocsCoverageStatus {
    <#
        One issue's status as the one word its card shows. Closed as completed is Done, closed otherwise Declined; an
        open issue reads its parking label first (a look at a result, then a decision, then any other wait), then its
        assignee (In progress), and is Open without either. $null (not read) is '--'.
    #>
    param([AllowNull()]$Issue)
    if ($null -eq $Issue) { return '--' }
    if ($Issue.State -ceq 'CLOSED') { if ($Issue.StateReason -ceq 'COMPLETED') { return 'Done' } else { return 'Declined' } }
    $labels = @($Issue.Labels)
    if ($labels -match '^awaiting-review-') { return 'In review' }
    if ($labels -match '^awaiting-decision-') { return 'Awaiting decision' }
    if ($labels -match '^awaiting-') { return 'Waiting' }
    if ($Issue.Assigned) { return 'In progress' }
    return 'Open'
}

function Format-DocsCoveragePageHtml {
    <#
        /docs-coverage: one row per item in the house .table, the item linking its own page with a "?" explaining it
        (its one line and the idea), then its status, the section and group its docs page sits in (each linking the
        page it opens on), and its issue (the owner, November 9, 2026: a table over the cards the page first had). A
        "?" beside a Declined status says why. Below the ten, one row per docs page of -Catalog
        (Get-DocsCoverageCatalog): its title linking the page with a "?" giving the docs' own description, its fixed
        status with a "?" giving the note and the evidence, its section and group, and no issue. There is no Docs
        column: on a page row it repeated the title (the owner, November 9, 2026), and an item's heading link is on
        its own page. -Query is ConvertFrom-DocsCoverageQuery's result; -Meta @{ GeneratedAt; Seconds } of the read.
    #>
    param([Parameter(Mandatory = $true)][hashtable]$Query, [Parameter(Mandatory = $true)][hashtable]$Meta,
        [AllowEmptyCollection()][object[]]$Items = @(Get-DocsCoverageItems),
        [AllowEmptyCollection()][object[]]$Catalog = @(Get-DocsCoverageCatalog))
    $e = { param($v) ConvertTo-DashboardText $v }
    $sb = New-Object System.Text.StringBuilder
    if ($Query.Error) { [void]$sb.AppendLine('<p class="msg--warn" role="alert">GitHub could not be read: ' + (& $e $Query.Error) + '. The items are shown without their status.</p>') }
    [void]$sb.AppendLine('<div class="table-wrap"><table class="table" id="items">')
    $heads = (@(@('Item', ''), @('Status', 'col-start'), @('Section', 'col-start'), @('Group', 'col-start'), @('Issue', '')) |
        ForEach-Object { Format-DocsCoverageSortHead -Label $_[0] -Class $_[1] }) -join ''
    [void]$sb.AppendLine('<thead><tr>' + $heads + '</tr></thead><tbody>')
    # A tooltip goes after the table, not in its cell: a .table cell does not wrap, and the text would run on one line.
    $tips = New-Object System.Text.StringBuilder
    foreach ($it in @($Items)) {
        $status = Get-DocsCoverageStatus $Query.ByIssue[[int]$it.Issue]
        $issueUrl = 'https://github.com/DKJ-Solutions/dkj-marketplace/issues/' + [int]$it.Issue
        $statusHtml = & $e $status
        if ($status -ceq 'Declined' -and $it.WhyDeclined) {
            $tipId = 'why-' + $it.Slug
            $statusHtml += '<button class="info-button" type="button" aria-label="Why ' + (& $e $it.Label) + ' was declined" aria-describedby="' + $tipId + '" aria-expanded="false">?</button>'
            [void]$tips.AppendLine('<div class="tooltip tooltip--explain" role="tooltip" id="' + $tipId + '"><b>Why declined</b>' + (& $e $it.WhyDeclined) + '</div>')
        }
        $aboutId = 'about-' + $it.Slug
        $aboutButton = '<button class="info-button" type="button" aria-label="About ' + (& $e $it.Label) + '" aria-describedby="' + $aboutId + '" aria-expanded="false">?</button>'
        [void]$tips.AppendLine('<div class="tooltip tooltip--explain" role="tooltip" id="' + $aboutId + '"><b>' + (& $e $it.Sub) + '</b>' + (& $e $it.What) + '<p>' + (& $e $it.Why) + '</p></div>')
        [void]$sb.AppendLine('<tr><td><a href="/docs-coverage/' + (& $e $it.Slug) + '">' + (& $e $it.Label) + '</a>' + $aboutButton + '</td>' +
            '<td class="col-start">' + $statusHtml + '</td>' +
            '<td class="col-start"><a href="' + (& $e $it.SectionUrl) + '">' + (& $e $it.Section) + '</a></td>' +
            '<td class="col-start"><a href="' + (& $e $it.GroupUrl) + '">' + (& $e $it.Group) + '</a></td>' +
            '<td><a href="' + $issueUrl + '">#' + [int]$it.Issue + '</a></td></tr>')
    }
    $docsBase = 'https://code.claude.com/docs/en/'
    foreach ($pg in @($Catalog)) {
        $id = ($pg.Path -replace '[^a-z0-9-]', '-')
        $noteHtml = & $e $pg.Note
        $ev = @($pg.Evidence | Where-Object { $_ })
        if ($ev.Count) { $noteHtml += '<p>Evidence: ' + ((@($ev) | ForEach-Object { & $e $_ }) -join ', ') + '</p>' }
        [void]$tips.AppendLine('<div class="tooltip tooltip--explain" role="tooltip" id="status-' + $id + '"><b>' + (& $e $pg.Status) + '</b>' + $noteHtml + '</div>')
        [void]$tips.AppendLine('<div class="tooltip tooltip--explain" role="tooltip" id="page-' + $id + '"><b>' + (& $e $pg.Title) + '</b>' + (& $e $pg.Desc) + '</div>')
        $groupHtml = if ($pg.Group) { '<a href="' + (& $e ($docsBase + $pg.GroupPath)) + '">' + (& $e $pg.Group) + '</a>' } else { '' }
        [void]$sb.AppendLine('<tr><td><a href="' + (& $e ($docsBase + $pg.Path)) + '">' + (& $e $pg.Title) + '</a><button class="info-button" type="button" aria-label="About ' + (& $e $pg.Title) + '" aria-describedby="page-' + $id + '" aria-expanded="false">?</button></td>' +
            '<td class="col-start">' + (& $e $pg.Status) + '<button class="info-button" type="button" aria-label="Why ' + (& $e $pg.Title) + ' is ' + (& $e $pg.Status) + '" aria-describedby="status-' + $id + '" aria-expanded="false">?</button></td>' +
            '<td class="col-start"><a href="' + (& $e ($docsBase + $pg.SectionPath)) + '">' + (& $e $pg.Section) + '</a></td>' +
            '<td class="col-start">' + $groupHtml + '</td>' +
            '<td></td></tr>')
    }
    [void]$sb.AppendLine('</tbody></table></div>')
    [void]$sb.Append($tips.ToString()); [void]$sb.AppendLine((Get-DocsCoverageTipScript)); [void]$sb.AppendLine((Get-DocsCoverageSortScript))
    return Format-DevPageHtml -Title 'Docs coverage' -Lead '' -Body $sb.ToString() `
        -FooterNote (Get-DocsCoverageFooter -Meta $Meta -Page 'docs-coverage')
}

function Format-DocsCoverageItemPageHtml {
    <#
        /docs-coverage/<slug>: the trail Home > Docs coverage > the item, its status, issue and docs page in one row of
        facts, then two cards side by side: the idea, and what was verified against the docs. -Issue is the item's
        entry in ConvertFrom-DocsCoverageQuery's ByIssue, or $null when it was not read.
    #>
    param([Parameter(Mandatory = $true)][hashtable]$Item, [AllowNull()]$Issue, [Parameter(Mandatory = $true)][hashtable]$Meta)
    $e = { param($v) ConvertTo-DashboardText $v }
    $issueUrl = 'https://github.com/DKJ-Solutions/dkj-marketplace/issues/' + [int]$Item.Issue
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('<dl class="facts facts--row">')
    [void]$sb.AppendLine('<div><dt>Status</dt><dd>' + (& $e (Get-DocsCoverageStatus $Issue)) + '</dd></div>')
    [void]$sb.AppendLine('<div><dt>Issue</dt><dd><a href="' + $issueUrl + '">#' + [int]$Item.Issue + '</a></dd></div>')
    [void]$sb.AppendLine('<div><dt>Docs</dt><dd><a href="' + (& $e ($Item.Docs + '#' + $Item.DocsAnchor)) + '">' + (& $e $Item.DocsHeading) + '</a></dd></div>')
    [void]$sb.AppendLine('</dl>')
    [void]$sb.AppendLine('<div class="grid-2">')
    [void]$sb.AppendLine('<section class="card"><h2>The idea</h2><p>' + (& $e $Item.What) + '</p><p>' + (& $e $Item.Why) + '</p></section>')
    $points = (@($Item.Verified) | ForEach-Object { '<li>' + (& $e $_) + '</li>' }) -join ''
    [void]$sb.AppendLine('<section class="card"><h2>What the docs say</h2><ul>' + $points + '</ul></section>')
    [void]$sb.AppendLine('</div>')
    return Format-DevPageHtml -Title $Item.Label -Lead '' -Body $sb.ToString() -ParentCrumbs @(@{ Label = 'Docs coverage'; Href = '/docs-coverage' }) `
        -FooterNote (Get-DocsCoverageFooter -Meta $Meta -Page ('docs-coverage/' + $Item.Slug))
}

function Get-DocsCoverageTipScript {
    <#
        The "?" beside a row's name or its status: every .info-button opens the .tooltip its aria-describedby names, the way
        Get-PageInfoScript opens the one beside an h1 (the house .tooltip is position: fixed, so this places it under
        the button, inside the window). It stays open while the pointer is on the button or on the text (WCAG
        1.4.13) or while the button has focus; Escape closes it.
    #>
    return '<script>(function () { document.querySelectorAll(".info-button[aria-describedby]").forEach(function (b) {' +
        ' var t = document.getElementById(b.getAttribute("aria-describedby")); if (!t) return; var h;' +
        ' function show() { clearTimeout(h); t.classList.add("tooltip--open"); b.setAttribute("aria-expanded", "true"); var r = b.getBoundingClientRect();' +
        ' t.style.top = (r.bottom + 8) + "px"; t.style.left = Math.max(8, Math.min(r.left, window.innerWidth - t.offsetWidth - 8)) + "px"; }' +
        ' function close() { t.classList.remove("tooltip--open"); b.setAttribute("aria-expanded", "false"); }' +
        ' function hide() { h = setTimeout(close, 150); }' +
        ' [b, t].forEach(function (el) { el.addEventListener("mouseenter", show); el.addEventListener("mouseleave", hide); });' +
        ' b.addEventListener("focus", show); b.addEventListener("blur", hide);' +
        ' document.addEventListener("keydown", function (e) { if (e.key === "Escape") { clearTimeout(h); close(); } }); }); })();</script>'
}

function Format-DocsCoverageSortHead {
    <#
        One column head in the house's sortable form (house-style.css, "Sortable column header"): a .sort button
        with its .arrow of two chevrons, on a th that starts at aria-sort="none".
    #>
    param([Parameter(Mandatory = $true)][string]$Label, [AllowEmptyString()][string]$Class = '')
    $cls = if ($Class) { ' class="' + $Class + '"' } else { '' }
    return '<th scope="col"' + $cls + ' aria-sort="none"><button class="sort" type="button">' + (ConvertTo-DashboardText $Label) +
        ' <span class="arrow" aria-hidden="true"><svg viewBox="0 0 8 12"><path class="u" d="M1 4.5 4 1.5 7 4.5"/><path class="d" d="M1 7.5 4 10.5 7 7.5"/></svg></span></button></th>'
}

function Get-DocsCoverageSortScript {
    <#
        Sorts #items by the column whose head is clicked: ascending first, then flipping on each click, the other
        heads back to "none". A cell sorts by its text, as a number where both are one (the Issue column, its "#"
        dropped), an empty cell (a docs page has no issue, and some no group) goes last in either direction, and ties
        keep the order the page gave, so a sort never shuffles equal rows.
    #>
    return '<script>(function () { var t = document.getElementById("items"); if (!t) return; var tb = t.tBodies[0];' +
        ' Array.prototype.forEach.call(tb.rows, function (r, i) { r.dataset.i = i; });' +
        ' function key(r, c) { var s = r.cells[c].textContent.replace(/\?/g, "").trim(), n = parseFloat(s.replace(/^#/, "")); return /^#?\d+(\.\d+)?$/.test(s) ? n : s.toLowerCase(); }' +
        ' t.querySelectorAll("thead th").forEach(function (th, c) { var b = th.querySelector(".sort"); if (!b) return; b.addEventListener("click", function () {' +
        ' var dir = th.getAttribute("aria-sort") === "ascending" ? "descending" : "ascending";' +
        ' t.querySelectorAll("thead th").forEach(function (o) { o.setAttribute("aria-sort", "none"); }); th.setAttribute("aria-sort", dir);' +
        ' var m = dir === "ascending" ? 1 : -1, rows = Array.prototype.slice.call(tb.rows);' +
        ' rows.sort(function (a, b) { var x = key(a, c), y = key(b, c); if (x === "" && y !== "") return 1; if (y === "" && x !== "") return -1;' +
        ' if (x < y) return -m; if (x > y) return m; return a.dataset.i - b.dataset.i; });' +
        ' rows.forEach(function (r) { tb.appendChild(r); }); }); }); })();</script>'
}

function Get-DocsCoverageFooter {
    # Where the page's data comes from, and the link that reads it again.
    param([Parameter(Mandatory = $true)][hashtable]$Meta, [Parameter(Mandatory = $true)][string]$Page)
    $e = { param($v) ConvertTo-DashboardText $v }
    $secs = if ($null -ne $Meta.Seconds) { ' in ' + ([double]$Meta.Seconds).ToString('0.0', [Globalization.CultureInfo]::InvariantCulture) + 's' } else { '' }
    return 'The ideas and the docs checks are the issues'' own, verified November 8, 2026; their status is read with one <code>gh api graphql</code> call, ' +
        (& $e $Meta.GeneratedAt) + $secs + ' (<a class="cd-link" href="/refresh?page=' + (& $e $Page) + '">read again</a>). The docs pages are llms.txt as read November 9, 2026, ' +
        'each classified against this repo that day. Built by <code>scripts/lib/docs-coverage-lib.ps1</code> and <code>docs-coverage-catalog.ps1</code>.'
}
