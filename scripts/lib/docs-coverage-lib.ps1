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

    No I/O here: the server (scripts/dashboard/serve-consumer-dashboard.ps1) asks gh and hands the answer in, so every
    rule is tested without a server, in scripts/tests/dev-pages.tests.ps1.

    Pure ASCII (repo convention for .ps1).
#>

function Get-DocsCoverageItems {
    <#
        The ten items in the issue's own order (#3906's table). Label is the row's link and the page's h1 (five words
        at most, no code); Sub the row's one line; What and Why the idea; Verified what the docs said when it was
        checked, one string per point; Docs the docs page it rests on.
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
           Docs = 'https://code.claude.com/docs/en/plugins/dependencies' }
        @{ Slug = 'behavioural-evals'; Issue = 3896; Label = 'Behavioural evals'
           Sub = 'Prove a skill or specialist still fires on its prompts'
           What = 'Add an evals/ suite per plugin, run with claude plugin eval in CI.'
           Why = 'The gates measure structure and cost, not behaviour; an eval catches a description shortened past the point where it still fires.'
           Verified = @(
               'claude plugin eval exists and runs in CI with --json, --threshold and --trust-plugin.'
               'Every case is a model run, so CI evals draw on the same credential as the review workflow.')
           Docs = 'https://code.claude.com/docs/en/plugin-evals' }
        @{ Slug = 'subagent-frontmatter'; Issue = 3897; Label = 'Richer subagent frontmatter'
           Sub = 'Effort, turn limit, skills, memory and a model per role'
           What = 'Use effort, maxTurns, skills, memory and a per-role model on the specialist agent definitions.'
           Why = 'Every agent runs on sonnet with no effort level and no turn limit, whatever its role.'
           Verified = @(
               'All five keys exist on subagent frontmatter.'
               'skills preloads skills, not manuals: a manual would first have to become a skill.'
               'memory writes an agent memory store, next to the rule that lessons go into the docs.')
           Docs = 'https://code.claude.com/docs/en/sub-agents' }
        @{ Slug = 'hook-if-async'; Issue = 3898; Label = 'Conditional and async hooks'
           Sub = 'Start PowerShell only when a hook has work to do'
           What = 'Use if and async on the hooks in hooks.json.'
           Why = 'Every hook starts a PowerShell process on every matching event.'
           Verified = @(
               'if exists on tool events only, and the docs call it a best-effort filter.'
               'async exists on command hooks; its timeout is not enforced.'
               'The PreToolUse hook is the subagent safety guard, so a best-effort filter in front of it is a trade.')
           Docs = 'https://code.claude.com/docs/en/hooks' }
        @{ Slug = 'skill-frontmatter'; Issue = 3899; Label = 'Richer skill frontmatter'
           Sub = 'Tool grants, argument hints and the shell a skill runs in'
           What = 'Use allowed-tools, argument-hint and shell in SKILL.md frontmatter.'
           Why = 'A skill could grant the exact script it runs, and the slash menu would show its arguments.'
           Verified = @(
               'All three keys exist.'
               'allowed-tools grants the tools without a prompt for the invoking turn, so it is a permission shipped to every consumer.'
               'argument-hint is harmless and could land on its own.')
           Docs = 'https://code.claude.com/docs/en/skills' }
        @{ Slug = 'plugin-workflows'; Issue = 3900; Label = 'Workflows in a plugin'
           Sub = 'The sweep and the review chains as workflow scripts'
           What = 'Ship workflows/*.js as a plugin component for the sweep and the review chains.'
           Why = 'Only the final result would return to the main context, and every run would take the same steps.'
           Verified = @(
               'Plugin workflows exist, namespaced as plugin:name.'
               'A workflow script has no file or shell access, so every claim, branch and gate step becomes an agent.'
               'Dynamic workflows need a paid plan, the API or a supported cloud provider.')
           Docs = 'https://code.claude.com/docs/en/workflows' }
        @{ Slug = 'deny-ask-rules'; Issue = 3901; Label = 'Hard deny and ask'
           Sub = 'Let the harness enforce the safety rules'
           What = 'Ship deny and ask permission rules for the constitution''s safety rules.'
           Why = 'The deny rules exist only as a suggested settings file, so a consumer that never applies it has none.'
           Verified = @(
               'A plugin cannot ship permission rules: a plugin settings.json applies only agent and subagentStatusLine.'
               'The remedy has to be another route: an adoption step that writes them, a guard hook, or managed settings.')
           Docs = 'https://code.claude.com/docs/en/plugins/components' }
        @{ Slug = 'bounded-review'; Issue = 3902; Label = 'Bounded CI review'
           Sub = 'A turn ceiling and its own credential for the review'
           What = 'Pass --max-turns and --model to the Claude review workflow, and evaluate an API key over the OAuth token.'
           Why = 'The subscription token shares its quota with interactive use, and the review has failed on every PR several times.'
           Verified = @(
               'claude_args takes --max-turns and --model; auth is an API key or the OAuth token.'
               'An API key is the owner''s act and bill; a turn ceiling needs the turn count of past green runs first.')
           Docs = 'https://code.claude.com/docs/en/github-actions' }
        @{ Slug = 'user-config'; Issue = 3903; Label = 'Plugin user configuration'
           Sub = 'Install-time settings, default-off teams, a main agent'
           What = 'Use userConfig, defaultEnabled and a plugin settings.json with agent in the manifests.'
           Why = 'Plain repo-config values would get a settings dialog, add-on teams could start off, and the orchestrator could run without a cache-path import.'
           Verified = @(
               'All three exist, and a CLAUDE.md at a plugin root is not loaded.'
               'This repo does not rely on one: a consumer imports the constitution by path.'
               'agent runs a plugin agent as the main thread with its own tools and model.')
           Docs = 'https://code.claude.com/docs/en/plugins-reference' }
        @{ Slug = 'native-worktrees'; Issue = 3904; Label = 'Native worktrees'
           Sub = 'Claude Code worktrees against worktree-lane.ps1'
           What = 'Evaluate claude --worktree, .worktreeinclude, worktree.baseRef and the WorktreeCreate hook against worktree-lane.ps1.'
           Why = 'They looked like they might answer the two objections to dispatching a review into a worktree.'
           Verified = @(
               '.worktreeinclude copies gitignored files only, and baseRef takes fresh or head: neither carries uncommitted work.'
               'The worktree path inside the checkout was already ignored here.'
               'A native lane cuts a worktree- branch, which this repo''s branch table refuses.')
           Docs = 'https://code.claude.com/docs/en/worktrees' }
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
        /docs-coverage: one row per item in the house .table, the item linking its own page, then its one line, its
        status and its issue, so the ten compare at a glance (the owner, November 9, 2026: a table over the cards
        the page first had). -Query is ConvertFrom-DocsCoverageQuery's result; -Meta @{ GeneratedAt; Seconds } of
        the read.
    #>
    param([Parameter(Mandatory = $true)][hashtable]$Query, [Parameter(Mandatory = $true)][hashtable]$Meta,
        [AllowEmptyCollection()][object[]]$Items = @(Get-DocsCoverageItems))
    $e = { param($v) ConvertTo-DashboardText $v }
    $sb = New-Object System.Text.StringBuilder
    if ($Query.Error) { [void]$sb.AppendLine('<p class="msg--warn" role="alert">GitHub could not be read: ' + (& $e $Query.Error) + '. The items are shown without their status.</p>') }
    [void]$sb.AppendLine('<div class="table-wrap"><table class="table" id="items">')
    [void]$sb.AppendLine('<thead><tr><th scope="col">Item</th><th scope="col" class="col-start">What</th><th scope="col" class="col-start">Status</th><th scope="col">Issue</th></tr></thead><tbody>')
    foreach ($it in @($Items)) {
        $status = Get-DocsCoverageStatus $Query.ByIssue[[int]$it.Issue]
        $issueUrl = 'https://github.com/DKJ-Solutions/dkj-marketplace/issues/' + [int]$it.Issue
        [void]$sb.AppendLine('<tr><td><a href="/docs-coverage/' + (& $e $it.Slug) + '">' + (& $e $it.Label) + '</a></td>' +
            '<td class="col-start">' + (& $e $it.Sub) + '</td><td class="col-start">' + (& $e $status) + '</td>' +
            '<td><a href="' + $issueUrl + '">#' + [int]$it.Issue + '</a></td></tr>')
    }
    [void]$sb.AppendLine('</tbody></table></div>')
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
    [void]$sb.AppendLine('<div><dt>Docs</dt><dd><a href="' + (& $e $Item.Docs) + '">' + (& $e ($Item.Docs -replace '^https://', '')) + '</a></dd></div>')
    [void]$sb.AppendLine('</dl>')
    [void]$sb.AppendLine('<div class="grid-2">')
    [void]$sb.AppendLine('<section class="card"><h2>The idea</h2><p>' + (& $e $Item.What) + '</p><p>' + (& $e $Item.Why) + '</p></section>')
    $points = (@($Item.Verified) | ForEach-Object { '<li>' + (& $e $_) + '</li>' }) -join ''
    [void]$sb.AppendLine('<section class="card"><h2>What the docs say</h2><ul>' + $points + '</ul></section>')
    [void]$sb.AppendLine('</div>')
    return Format-DevPageHtml -Title $Item.Label -Lead '' -Body $sb.ToString() -ParentCrumbs @(@{ Label = 'Docs coverage'; Href = '/docs-coverage' }) `
        -FooterNote (Get-DocsCoverageFooter -Meta $Meta -Page ('docs-coverage/' + $Item.Slug))
}

function Get-DocsCoverageFooter {
    # Where the page's data comes from, and the link that reads it again.
    param([Parameter(Mandatory = $true)][hashtable]$Meta, [Parameter(Mandatory = $true)][string]$Page)
    $e = { param($v) ConvertTo-DashboardText $v }
    $secs = if ($null -ne $Meta.Seconds) { ' in ' + ([double]$Meta.Seconds).ToString('0.0', [Globalization.CultureInfo]::InvariantCulture) + 's' } else { '' }
    return 'The ideas and the docs checks are the issues'' own, verified November 8, 2026; the status is read with one <code>gh api graphql</code> call, ' +
        (& $e $Meta.GeneratedAt) + $secs + ' (<a class="cd-link" href="/refresh?page=' + (& $e $Page) + '">read again</a>). Built by <code>scripts/lib/docs-coverage-lib.ps1</code>.'
}
