<#
.SYNOPSIS
    The product's Docs coverage pages (#3906): the ten opportunities a comparison of the official Claude Code docs
    against this repo (v6.11.0) found, and every docs page beside them, as one table on /docs-coverage whose every row
    links the docs (no page of its own per item since November 9, 2026, the owner).

.DESCRIPTION
    WHAT IS FIXED AND WHAT IS LIVE. An item's idea (what, why) and what was verified about it against the docs are
    fixed text, here in Get-DocsCoverageItems: they are the issue's own content as a sweep checked it on November 8,
    2026, and they do not move while the issue waits. Its STATUS is live: one GraphQL call reads every item's issue
    (Get-DocsCoverageQuery), and Get-DocsCoverageStatus turns its state and labels into the one word its row shows.
    A failed read shows the rows without a status and says so, never a blank page.

    BESIDE THE TEN, EVERY DOCS PAGE (the owner, November 9, 2026: "really everything from the Claude Code docs"):
    Get-DocsCoverageCatalog, in docs-coverage-catalog.ps1 beside this file and loaded with it, holds each page with a
    fixed status of its own (Covered, Open, Not relevant) and the note and evidence behind it, so the overview
    also says what this repo already uses well and needs no attention.

    No I/O here: the server (scripts/dashboard/serve-consumer-dashboard.ps1) asks gh and hands the answer in, so every
    rule is tested without a server, in scripts/tests/dev-pages.tests.ps1.

    Pure ASCII (repo convention for .ps1).
#>

. (Join-Path $PSScriptRoot 'docs-coverage-catalog.ps1')

function Get-DocsCoverageItems {
    <#
        The ten items in the issue's own order (#3906's table). Label is the row's name (five words at most, no code),
        linking the docs heading the item is about; Sub its one line, What and Why the idea, and Verified what the docs
        said when it was checked, one string per point, all four shown in the row's Details popup; Docs the docs page it rests on, and Section and Group where that page sits in
        the docs navigation (read from code.claude.com/docs/llms.txt on November 9, 2026: its ## heading and its ####
        group; plugins-reference is not listed itself and serves the Plugin manifest reference, so it takes that
        page's place). SectionUrl and GroupUrl are the page each opens on in that navigation (its first link), and
        DocsAnchor the heading on the docs page the item is about, each checked as an id on the live page, with
        DocsHeading the heading's text as that page shows it.
        WhyDeclined, on an item the owner closed as not planned, is the decision that closed it, in one or two
        sentences: the row's Details popup shows it under Declined.
        Impact is how important the item is to this repo, 1 to 8, the higher the more important (the owner, November
        9, 2026): the Impact column shows it as Tier-1 to Tier-8, the same scale as a catalog page's.
    #>
    @(
        @{ Slug = 'plugin-dependencies'; Issue = 3895; Impact = 5; Label = 'Plugin dependencies'
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
        @{ Slug = 'behavioural-evals'; Issue = 3896; Impact = 6; Label = 'Behavioural evals'
           Sub = 'Prove a skill or specialist still fires on its prompts'
           What = 'Add an evals/ suite per plugin, run with claude plugin eval in CI.'
           Why = 'The gates measure structure and cost, not behaviour; an eval catches a description shortened past the point where it still fires.'
           Verified = @(
               'claude plugin eval exists and runs in CI with --json, --threshold and --trust-plugin.'
               'Every case is a model run, so CI evals draw on the same credential as the review workflow.')
           Section = 'Plugins'; SectionUrl = 'https://code.claude.com/docs/en/plugins/overview'
           Group = 'Create plugins'; GroupUrl = 'https://code.claude.com/docs/en/plugins/create'
           Docs = 'https://code.claude.com/docs/en/plugin-evals'; DocsAnchor = 'run-evals-in-ci'; DocsHeading = 'Run evals in CI' }
        @{ Slug = 'subagent-frontmatter'; Issue = 3897; Impact = 6; Label = 'Richer subagent frontmatter'
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
        @{ Slug = 'hook-if-async'; Issue = 3898; Impact = 4; Label = 'Conditional and async hooks'
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
        @{ Slug = 'skill-frontmatter'; Issue = 3899; Impact = 5; Label = 'Richer skill frontmatter'
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
        @{ Slug = 'plugin-workflows'; Issue = 3900; Impact = 3; Label = 'Workflows in a plugin'
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
        @{ Slug = 'deny-ask-rules'; Issue = 3901; Impact = 8; Label = 'Hard deny and ask'
           Sub = 'Let the harness enforce the safety rules'
           What = 'Ship deny and ask permission rules for the constitution''s safety rules.'
           Why = 'The deny rules exist only as a suggested settings file, so a consumer that never applies it has none.'
           Verified = @(
               'A plugin cannot ship permission rules: a plugin settings.json applies only agent and subagentStatusLine.'
               'The remedy has to be another route: an adoption step that writes them, a guard hook, or managed settings.')
           Section = 'Plugins'; SectionUrl = 'https://code.claude.com/docs/en/plugins/overview'
           Group = 'Create plugins'; GroupUrl = 'https://code.claude.com/docs/en/plugins/create'
           Docs = 'https://code.claude.com/docs/en/plugins/components'; DocsAnchor = 'default-settings'; DocsHeading = 'Default settings' }
        @{ Slug = 'bounded-review'; Issue = 3902; Impact = 5; Label = 'Bounded CI review'
           Sub = 'A turn ceiling and its own credential for the review'
           What = 'Pass --max-turns and --model to the Claude review workflow, and evaluate an API key over the OAuth token.'
           Why = 'The subscription token shares its quota with interactive use, and the review has failed on every PR several times.'
           Verified = @(
               'claude_args takes --max-turns and --model; auth is an API key or the OAuth token.'
               'An API key is the owner''s act and bill; a turn ceiling needs the turn count of past green runs first.')
           Section = 'Getting started'; SectionUrl = 'https://code.claude.com/docs/en/overview'
           Group = 'Code review and pull requests'; GroupUrl = 'https://code.claude.com/docs/en/code-review-local'
           Docs = 'https://code.claude.com/docs/en/github-actions'; DocsAnchor = 'pass-cli-arguments'; DocsHeading = 'Pass CLI arguments' }
        @{ Slug = 'user-config'; Issue = 3903; Impact = 5; Label = 'Plugin user configuration'
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
        @{ Slug = 'native-worktrees'; Issue = 3904; Impact = 3; Label = 'Native worktrees'
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
        One issue's status as the one word its row shows. Closed as completed is Covered, the word a docs page this
        repo already uses well reads too: the two are the same state, and the Issue column says which arrived through
        an issue (the owner, November 9, 2026; it read Done before). Closed otherwise is Declined; an
        open issue reads its parking label first (a look at a result, then a decision, then any other wait), then its
        assignee (In progress), and is Open without either. $null (not read) is '--'.
    #>
    param([AllowNull()]$Issue)
    if ($null -eq $Issue) { return '--' }
    if ($Issue.State -ceq 'CLOSED') { if ($Issue.StateReason -ceq 'COMPLETED') { return 'Covered' } else { return 'Declined' } }
    $labels = @($Issue.Labels)
    if ($labels -match '^awaiting-review-') { return 'In review' }
    if ($labels -match '^awaiting-decision-') { return 'Awaiting decision' }
    if ($labels -match '^awaiting-') { return 'Waiting' }
    if ($Issue.Assigned) { return 'In progress' }
    return 'Open'
}

function Get-DocsCoverageStatusColors {
    <#
        Each status its own colour (the owner, November 9, 2026), as the house .dot before the word: an ordered map of
        status to the house token its dot reads. The house names three dot colours (--good, --warn, --bad), so the
        rest read other house tokens through a class of this page's own; nothing is typed or derived, so every theme
        and the dark mode follow. '--' (not read) has no dot.
        The way GitHub colours an issue (Dave, November 9, 2026): Open is green, because there is still something to
        gain there; Covered is purple, done and needing no more attention; Declined and Not relevant are grey, a paper step apart
        so each still has a colour of its own.
    #>
    [ordered]@{
        'Covered' = '--done-3'; 'In progress' = '--graph-1'; 'In review' = '--primary'
        'Awaiting decision' = '--warning-3'; 'Waiting' = '--primary-muted'; 'Open' = '--positive-3'; 'Declined' = '--bg-5'
        'Not relevant' = '--bg-4'
    }
}

function Format-DocsCoverageStatusText {
    # A status as its coloured dot and its word; a status with no colour of its own (--) is the word alone.
    param([AllowEmptyString()][string]$Status)
    $slug = Get-DocsCoverageStatusSlug $Status
    $dot = if ((Get-DocsCoverageStatusColors).Contains($Status)) { '<span class="dot dc-dot--' + $slug + '" aria-hidden="true"></span>' } else { '' }
    return $dot + (ConvertTo-DashboardText $Status)
}

function Get-DocsCoverageStatusStyle {
    # The page's own layer: one rule per status colour, each reading a house token. And the status filter's width and
    # the space between it and the table (the place sets it; a block has no margin).
    $map = Get-DocsCoverageStatusColors
    return ((@($map.Keys | ForEach-Object { '.dc-dot--' + (Get-DocsCoverageStatusSlug $_) + ' { background: var(' + $map[$_] + '); }' }) + @(
        '.dc-filter { display: block; max-width: 280px; margin-bottom: var(--spacing-3); }'
        # The Details icon: quiet until hovered or focused, the size of the row's text line rather than a touch target.
        '.dc-detail { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; margin: -4px 0; padding: 0; border: 0; border-radius: var(--radius-2); background: transparent; color: var(--primary-muted); cursor: pointer; vertical-align: middle; }'
        '.dc-detail:hover, .dc-detail:focus-visible { color: var(--primary); }'
        '.dc-detail:focus-visible { outline: 2px solid var(--primary-muted); outline-offset: 2px; }'
        # The popup is the window's width less 10% (the owner, November 9, 2026), where the house dialog keeps to the
        # narrow column. On the page's own class, so the house .dialog itself is not restyled.
        'dialog.dc-detail-dialog { width: 90vw; }'
        # In the popup a fact may wrap, each h2 block stands apart from the one above, and an h3 from the text above it.
        '.dc-detail__facts dd { white-space: normal; overflow-wrap: anywhere; }'
        '.dc-detail__body > h2 { margin-top: var(--spacing-6); }'
        '.dc-detail__body > h2:first-child { margin-top: 0; }'
        '.dc-detail__body > h3 { margin-top: var(--spacing-4); }'
        '.dc-detail__body p, .dc-detail__body ul { margin: 0 0 var(--spacing-2); }')) -join "`n")
}

function Format-DocsCoverageImpact {
    <#
        A row's Impact cell text (the owner, November 9, 2026): Tier-1 to Tier-8, the higher the more important; N/A
        when the row's status is Not relevant, whatever impact it carries; '--' when a relevant row has none.
    #>
    param([AllowNull()]$Impact, [AllowEmptyString()][string]$Status)
    if ($Status -ceq 'Not relevant') { return 'N/A' }
    if ($null -eq $Impact -or [int]$Impact -lt 1 -or [int]$Impact -gt 8) { return '--' }
    return 'Tier-' + [int]$Impact
}

function Get-DocsCoverageStatusSlug {
    # A status as the slug its dot class and its filter checkbox carry: 'Not relevant' is 'not-relevant', '--' is ''.
    param([AllowEmptyString()][string]$Status)
    return ($Status.ToLowerInvariant() -replace '[^a-z]+', '-').Trim('-')
}

function Format-DocsCoverageStatusFilter {
    <#
        The status filter: the product layer's .field with a select, one choice at a time (the owner, November 9,
        2026: no checklist). "All statuses" first and chosen, then one option per status in -Statuses (the status of
        every row), in the colour map's order and '--' last, each with its row count. Empty when there are no rows.
    #>
    param([AllowEmptyCollection()][string[]]$Statuses)
    if (-not @($Statuses).Count) { return '' }
    $e = { param($v) ConvertTo-DashboardText $v }
    $counts = @{}; foreach ($st in @($Statuses)) { $counts[$st] = 1 + [int]$counts[$st] }
    $order = @(@((Get-DocsCoverageStatusColors).Keys | Where-Object { $counts.ContainsKey($_) }) + @($counts.Keys | Where-Object { -not (Get-DocsCoverageStatusColors).Contains($_) } | Sort-Object))
    $options = @('<option value="all" selected>All statuses (' + @($Statuses).Count + ')</option>') +
        @($order | ForEach-Object { '<option value="' + (Get-DocsCoverageStatusSlug $_) + '">' + (& $e $_) + ' (' + $counts[$_] + ')</option>' })
    return '<label class="field dc-filter"><span>Status</span><select id="status-filter" aria-controls="items">' + ($options -join '') + '</select></label>'
}

function Format-DocsCoveragePageHtml {
    <#
        /docs-coverage: columns Section, Group, Item, Status, Impact, Issue (the owner, November 9, 2026; Impact is
        Format-DocsCoverageImpact's Tier-1 to Tier-8, or N/A for a Not relevant page). One row per item
        in the house .table, the item's name linking the docs heading it is about, then its status, the section and
        group its docs page sits in (each linking the page it opens on), and its issue (the owner, November 9, 2026: a
        table over the cards the page first had). Below the ten, one row per docs page of -Catalog
        (Get-DocsCoverageCatalog): its title linking the page, its fixed status, its section and group, and no issue.
        No cell carries a "?": the row's Details icon opens one popup with everything those tooltips said (the owner,
        November 9, 2026). Every row links the docs and nothing else: no Docs column (it repeated the title) and no page per item (the owner, November 9, 2026). -Query is ConvertFrom-DocsCoverageQuery's result; -Meta @{ GeneratedAt; Seconds } of the read.
    #>
    param([Parameter(Mandatory = $true)][hashtable]$Query, [Parameter(Mandatory = $true)][hashtable]$Meta,
        [AllowEmptyCollection()][object[]]$Items = @(Get-DocsCoverageItems),
        [AllowEmptyCollection()][object[]]$Catalog = @(Get-DocsCoverageCatalog))
    $e = { param($v) ConvertTo-DashboardText $v }
    $sb = New-Object System.Text.StringBuilder
    if ($Query.Error) { [void]$sb.AppendLine('<p class="msg--warn" role="alert">GitHub could not be read: ' + (& $e $Query.Error) + '. The items are shown without their status.</p>') }
    # A status filter over the table (the owner, November 9, 2026): one status at a time, or all of them.
    $rowStatuses = @(@($Items | ForEach-Object { Get-DocsCoverageStatus $Query.ByIssue[[int]$_.Issue] }) + @($Catalog | ForEach-Object { [string]$_.Status }))
    $filterHtml = Format-DocsCoverageStatusFilter -Statuses $rowStatuses
    if ($filterHtml) { [void]$sb.AppendLine($filterHtml) }
    [void]$sb.AppendLine('<div class="table-wrap"><table class="table" id="items">')
    # Section, Group, Item, then Status (the owner, November 9, 2026): read from the docs' section down to the topic,
    # and then how this repo stands to it. Impact after Status (the owner, November 9, 2026): Tier-1 to Tier-8, N/A for
    # a page that is Not relevant. Last, a Details column with no sort: its icon opens the row's popup.
    $heads = (@(@('Section', ''), @('Group', 'col-start'), @('Item', 'col-start'), @('Status', 'col-start'), @('Impact', 'col-start'), @('Issue', '')) |
        ForEach-Object { Format-DocsCoverageSortHead -Label $_[0] -Class $_[1] }) -join ''
    $heads += '<th scope="col" class="col-end"><span class="sr-only">Details</span></th>'
    [void]$sb.AppendLine('<thead><tr>' + $heads + '</tr></thead><tbody>')
    # A row's details go after the table, as a <template> the one dialog takes its content from when the row's icon is
    # clicked.
    $details = New-Object System.Text.StringBuilder
    foreach ($it in @($Items)) {
        $status = Get-DocsCoverageStatus $Query.ByIssue[[int]$it.Issue]
        $issueUrl = 'https://github.com/DKJ-Solutions/dkj-marketplace/issues/' + [int]$it.Issue
        $statusHtml = Format-DocsCoverageStatusText $status
        $detailId = 'detail-item-' + $it.Slug
        # The popup in headings (the owner, November 9, 2026): the item's name the h1, a block per h2, its parts h3.
        $body = '<h2>Where it sits</h2>' + (Format-DocsCoverageFacts ([ordered]@{
                'Section' = '<a href="' + (& $e $it.SectionUrl) + '">' + (& $e $it.Section) + '</a>'
                'Group' = '<a href="' + (& $e $it.GroupUrl) + '">' + (& $e $it.Group) + '</a>'
                'Docs' = '<a href="' + (& $e ($it.Docs + '#' + $it.DocsAnchor)) + '">' + (& $e $it.DocsHeading) + '</a>' })) +
            '<h2>How this repo stands</h2>' + (Format-DocsCoverageFacts ([ordered]@{
                'Status' = Format-DocsCoverageStatusText $status
                'Impact' = Format-DocsCoverageImpact -Impact $it.Impact -Status $status
                'Issue' = '<a href="' + $issueUrl + '">#' + [int]$it.Issue + '</a>' }))
        if ($status -ceq 'Declined' -and $it.WhyDeclined) { $body += '<h3>Why declined</h3><p>' + (& $e $it.WhyDeclined) + '</p>' }
        $body += '<h2>The idea</h2><h3>What</h3><p>' + (& $e $it.What) + '</p><h3>Why</h3><p>' + (& $e $it.Why) + '</p>' +
            '<h3>Checked against the docs</h3><ul>' + ((@($it.Verified) | ForEach-Object { '<li>' + (& $e $_) + '</li>' }) -join '') + '</ul>'
        [void]$details.AppendLine((Format-DocsCoverageDetailTemplate -Id $detailId -Title $it.Label -Sub $it.Sub -BodyHtml $body))
        [void]$sb.AppendLine('<tr><td><a href="' + (& $e $it.SectionUrl) + '">' + (& $e $it.Section) + '</a></td>' +
            '<td class="col-start"><a href="' + (& $e $it.GroupUrl) + '">' + (& $e $it.Group) + '</a></td>' +
            '<td class="col-start"><a href="' + (& $e ($it.Docs + '#' + $it.DocsAnchor)) + '">' + (& $e $it.Label) + '</a></td>' +
            '<td class="col-start">' + $statusHtml + '</td>' +
            '<td class="col-start">' + (Format-DocsCoverageImpact -Impact $it.Impact -Status $status) + '</td>' +
            '<td><a href="' + $issueUrl + '">#' + [int]$it.Issue + '</a></td>' +
            (Format-DocsCoverageDetailCell -Id $detailId -Title $it.Label) + '</tr>')
    }
    $docsBase = 'https://code.claude.com/docs/en/'
    foreach ($pg in @($Catalog)) {
        $id = ($pg.Path -replace '[^a-z0-9-]', '-')
        $ev = @($pg.Evidence | Where-Object { $_ })
        $groupHtml = if ($pg.Group) { '<a href="' + (& $e ($docsBase + $pg.GroupPath)) + '">' + (& $e $pg.Group) + '</a>' } else { '' }
        $detailId = 'detail-page-' + $id
        $where = [ordered]@{ 'Section' = '<a href="' + (& $e ($docsBase + $pg.SectionPath)) + '">' + (& $e $pg.Section) + '</a>' }
        if ($groupHtml) { $where['Group'] = $groupHtml }
        $where['Docs'] = '<a href="' + (& $e ($docsBase + $pg.Path)) + '">' + (& $e $pg.Path) + '</a>'
        # An Open page says whether this repo should take it up, and why; Impact is the one measure of its value
        # (the owner, November 9, 2026: it replaced Potential).
        $stands = [ordered]@{ 'Status' = Format-DocsCoverageStatusText $pg.Status; 'Impact' = Format-DocsCoverageImpact -Impact $pg.Impact -Status $pg.Status }
        if ($pg.Advice) { $stands['Advice'] = & $e $pg.Advice }
        $body = '<h2>Where it sits</h2>' + (Format-DocsCoverageFacts $where) + '<h2>How this repo stands</h2>' + (Format-DocsCoverageFacts $stands) +
            '<h3>Note</h3><p>' + (& $e $pg.Note) + '</p>'
        # Under one Advice heading, the advice itself and then why (the owner, November 9, 2026: not "Why consider").
        if ($pg.AdviceWhy) { $body += '<h3>Advice</h3><p>' + (& $e $pg.Advice) + '. ' + (& $e $pg.AdviceWhy) + '</p>' }
        if ($ev.Count) { $body += '<h3>Evidence</h3><ul>' + ((@($ev) | ForEach-Object { '<li><code>' + (& $e $_) + '</code></li>' }) -join '') + '</ul>' }
        [void]$details.AppendLine((Format-DocsCoverageDetailTemplate -Id $detailId -Title $pg.Title -Sub $pg.Desc -BodyHtml $body))
        [void]$sb.AppendLine('<tr><td><a href="' + (& $e ($docsBase + $pg.SectionPath)) + '">' + (& $e $pg.Section) + '</a></td>' +
            '<td class="col-start">' + $groupHtml + '</td>' +
            '<td class="col-start"><a href="' + (& $e ($docsBase + $pg.Path)) + '">' + (& $e $pg.Title) + '</a></td>' +
            '<td class="col-start">' + (Format-DocsCoverageStatusText $pg.Status) + '</td>' +
            '<td class="col-start">' + (Format-DocsCoverageImpact -Impact $pg.Impact -Status $pg.Status) + '</td>' +
            '<td></td>' + (Format-DocsCoverageDetailCell -Id $detailId -Title $pg.Title) + '</tr>')
    }
    [void]$sb.AppendLine('</tbody></table></div>')
    [void]$sb.Append($details.ToString()); [void]$sb.AppendLine((Get-DocsCoverageDetailDialog)); [void]$sb.AppendLine((Get-DocsCoverageDetailScript))
    [void]$sb.AppendLine((Get-DocsCoverageSortScript))
    if ($filterHtml) { [void]$sb.AppendLine((Get-DocsCoverageFilterScript)) }
    return Format-DevPageHtml -Title 'Docs coverage' -Lead '' -Body $sb.ToString() -Style (Get-DocsCoverageStatusStyle) `
        -FooterNote (Get-DocsCoverageFooter -Meta $Meta -Page 'docs-coverage')
}

function Format-DocsCoverageDetailCell {
    <#
        A row's Details cell (the owner, November 9, 2026): an info icon that opens the row's popup. It names the
        template it opens in data-detail and the one dialog in aria-controls; the icon is drawn in currentColor.
    #>
    param([Parameter(Mandatory = $true)][string]$Id, [Parameter(Mandatory = $true)][string]$Title)
    return '<td class="col-end"><button class="dc-detail" type="button" aria-haspopup="dialog" aria-controls="row-detail" data-detail="' +
        (ConvertTo-DashboardText $Id) + '" aria-label="Details of ' + (ConvertTo-DashboardText $Title) + '">' +
        '<svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">' +
        '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/></svg></button></td>'
}

function Format-DocsCoverageDetailTemplate {
    <#
        A row's popup content, as a <template> the dialog clones when the row's icon is clicked. Headings carry its
        structure (the owner, November 9, 2026): the row's name is the h1 in the product layer's dialog head, with
        its one line as .dialog__sub under it, and -BodyHtml (already escaped) holds an h2 per block and an h3 per
        part of one. The h1 is the docs' own title on a docs page row, so it can run past five words.
    #>
    param([Parameter(Mandatory = $true)][string]$Id, [Parameter(Mandatory = $true)][string]$Title, [AllowEmptyString()][string]$Sub = '',
        [AllowEmptyString()][string]$BodyHtml = '')
    $e = { param($v) ConvertTo-DashboardText $v }
    $subHtml = if ($Sub) { '<p class="dialog__sub">' + (& $e $Sub) + '</p>' } else { '' }
    return '<template id="' + (& $e $Id) + '"><div class="dialog__head"><div><h1 id="row-detail-title">' + (& $e $Title) + '</h1>' + $subHtml + '</div></div>' +
        '<div class="dc-detail__body">' + $BodyHtml + '</div></template>'
}

function Format-DocsCoverageFacts {
    # One block's facts in the popup, as a house .facts list: -Facts maps each label to HTML that is already escaped.
    param([Parameter(Mandatory = $true)][System.Collections.IDictionary]$Facts)
    return '<dl class="facts dc-detail__facts">' + ((@($Facts.Keys) | ForEach-Object { '<div><dt>' + (ConvertTo-DashboardText $_) + '</dt><dd>' + $Facts[$_] + '</dd></div>' }) -join '') + '</dl>'
}

function Get-DocsCoverageDetailDialog {
    # The one dialog every Details icon opens: the product layer's .dialog with its close button, its content cloned in,
    # 90% of the window wide through the page's own .dc-detail-dialog.
    return '<dialog class="dialog dc-detail-dialog" id="row-detail" aria-labelledby="row-detail-title"><div class="dialog__body">' +
        '<button class="dialog__close" type="button" aria-label="Close"><svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg></button>' +
        '<div id="row-detail-content"></div></div></dialog>'
}

function Get-DocsCoverageDetailScript {
    <#
        Opens the dialog on a Details icon: the template the icon names is cloned into it and shown with showModal, so
        Escape and the focus return are the browser's. The close button, or a click on the backdrop (the dialog
        itself, since its padding sits in the body), shuts it, and a shut dialog is emptied, so the popup's h1 is in
        the page only while the popup is open.
    #>
    return '<script>(function () { var d = document.getElementById("row-detail"), c = document.getElementById("row-detail-content"); if (!d || !c || !d.showModal) return;' +
        ' document.addEventListener("click", function (ev) { var b = ev.target.closest && ev.target.closest(".dc-detail"); if (!b) return;' +
        ' var t = document.getElementById(b.getAttribute("data-detail")); if (!t) return; c.innerHTML = ""; c.appendChild(t.content.cloneNode(true)); d.showModal(); });' +
        ' d.addEventListener("click", function (ev) { if (ev.target === d || ev.target.closest(".dialog__close")) d.close(); });' +
        ' d.addEventListener("close", function () { c.innerHTML = ""; }); })();</script>'
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
        dropped, and the Impact column, its "Tier-" dropped), an empty cell (a docs page has no issue, and some no
        group) goes last in either direction, and so do N/A and '--' (an Impact with no tier), and ties
        keep the order the page gave, so a sort never shuffles equal rows.
    #>
    return '<script>(function () { var t = document.getElementById("items"); if (!t) return; var tb = t.tBodies[0];' +
        ' Array.prototype.forEach.call(tb.rows, function (r, i) { r.dataset.i = i; });' +
        ' function key(r, c) { var s = r.cells[c].textContent.trim(); if (s === "N/A" || s === "--") return "";' +
        ' var n = parseFloat(s.replace(/^(#|Tier-)/, "")); return /^(#|Tier-)?\d+(\.\d+)?$/.test(s) ? n : s.toLowerCase(); }' +
        ' t.querySelectorAll("thead th").forEach(function (th, c) { var b = th.querySelector(".sort"); if (!b) return; b.addEventListener("click", function () {' +
        ' var dir = th.getAttribute("aria-sort") === "ascending" ? "descending" : "ascending";' +
        ' t.querySelectorAll("thead th").forEach(function (o) { o.setAttribute("aria-sort", "none"); }); th.setAttribute("aria-sort", dir);' +
        ' var m = dir === "ascending" ? 1 : -1, rows = Array.prototype.slice.call(tb.rows);' +
        ' rows.sort(function (a, b) { var x = key(a, c), y = key(b, c); if (x === "" && y !== "") return 1; if (y === "" && x !== "") return -1;' +
        ' if (x < y) return -m; if (x > y) return m; return a.dataset.i - b.dataset.i; });' +
        ' rows.forEach(function (r) { tb.appendChild(r); }); }); }); })();</script>'
}

function Get-DocsCoverageFilterScript {
    <#
        The status filter: on a change every row shows when "all" is chosen or its status is the one chosen. A row's
        status is read from the one dot class in it (a row whose status has no dot, '--', is the empty value), so the
        row markup carries nothing for the filter, and a sort moves rows without touching their hidden state.
        The browser remembers the last choice (the owner, November 9, 2026: a reload must not fall back to all), in
        localStorage under "docs-coverage-status": restored on load only when the page still offers that status, and
        every read and write in a try, so a browser that refuses storage just starts on all.
    #>
    return '<script>(function () { var t = document.getElementById("items"), f = document.getElementById("status-filter"); if (!t || !f) return;' +
        ' var k = "docs-coverage-status";' +
        ' function slug(r) { var d = r.querySelector("[class*=\"dc-dot--\"]"), m = d && /dc-dot--([a-z-]+)/.exec(d.className); return m ? m[1] : ""; }' +
        ' function apply() { var v = f.value; Array.prototype.forEach.call(t.tBodies[0].rows, function (r) { r.hidden = v !== "all" && slug(r) !== v; }); }' +
        ' f.addEventListener("change", function () { apply(); try { localStorage.setItem(k, f.value); } catch (e) {} });' +
        ' var s = null; try { s = localStorage.getItem(k); } catch (e) {}' +
        ' if (s !== null && Array.prototype.some.call(f.options, function (o) { return o.value === s; })) { f.value = s; apply(); } })();</script>'
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
