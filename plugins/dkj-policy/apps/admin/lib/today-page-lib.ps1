<#
.SYNOPSIS
    The Today page of every repo's admin (#3860): the day plan from day-plan.ps1 -Status, its goal and progress, each
    item's live state, what got done (the extra work included), what is not today, and the week.

.DESCRIPTION
    Rendered in Admin, where general-pages-lib.ps1 is loaded: ConvertTo-GeneralPageText escapes and
    Format-GeneralPageHtml draws the shell. The model is day-plan.ps1 -Status's JSON, so the GitHub search behind it has
    one source; the server only runs it and caches the answer (Get-TodayModel in serve-general-pages.ps1).

    The page's own layer names only classes the house file does not define and reads only tokens.

    Pure. Pure ASCII (repo convention for .ps1). Tested by scripts/tests/dayplan.tests.ps1 in the source repo.
#>

. (Join-Path $PSScriptRoot 'dayplan-lib.ps1')

$script:TodayPageStyle = '.today-goal { display: grid; gap: var(--spacing-2); }' + "`n" +
    '.shell__body .today-goal > h2 { margin: 0; font-size: var(--text-xs); font-weight: var(--font-weight-bold); letter-spacing: 0.06em; text-transform: uppercase; color: var(--primary-muted); }' + "`n" +
    '.today-goal .today-goal__title { display: flex; gap: var(--spacing-3); align-items: center; margin: 0; font-size: var(--text-title); font-weight: var(--font-weight-bold); }' + "`n" +
    '.today-progress { display: flex; gap: var(--spacing-3); align-items: center; margin: 0; color: var(--primary-muted); font-size: var(--text-sm); }' + "`n" +
    '.today-progress > .meter { flex: 0 1 65%; }' + "`n" +
    '.shell__body .card > h2 + * { margin-top: var(--spacing-2); }' + "`n" +
    '.today-items { margin: 0; padding: 0; list-style: none; }' + "`n" +
    '.today-items > li { display: flex; gap: var(--spacing-3); align-items: center; padding: var(--spacing-3) 0; border-top: 1px solid var(--bg-3); }' + "`n" +
    '.today-items .today-items__mark { flex: none; width: var(--spacing-4); color: var(--primary-muted); text-align: center; }' + "`n" +
    '.today-items .today-items__title { flex: 1; min-width: 0; font-weight: var(--font-weight-bold); }' + "`n" +
    '.today-items .today-items__done { color: var(--primary-muted); font-weight: var(--font-weight-regular); }' + "`n" +
    '.today-items .num { color: var(--primary-muted); font-size: var(--text-sm); }' + "`n" +
    '.today-items .chip { color: var(--primary-muted); font-size: var(--text-xs); font-weight: var(--font-weight-regular); }' + "`n" +
    '.today-list { display: grid; gap: var(--spacing-2); margin: 0; padding-left: var(--spacing-5); color: var(--primary-muted); font-size: var(--text-sm); }' + "`n" +
    '.today-week { display: grid; gap: var(--spacing-2); margin: 0; padding: 0; list-style: none; }' + "`n" +
    '.today-week > li { display: flex; gap: var(--spacing-3); align-items: center; }' + "`n" +
    '.today-week__day { flex: none; width: var(--spacing-8); color: var(--primary-muted); font-size: var(--text-sm); font-weight: var(--font-weight-bold); }' + "`n" +
    '.today-week > li > .meter { flex: 1; }'

function Get-TodayRefUrl {
    <# An item's ref as a GitHub link; GitHub sends an issue URL that is a pull request on to the pull request. #>
    param([string]$Ref)
    if ($Ref -match '\A([^/\s#]+)/([^/\s#]+)#(\d+)\z') { return "https://github.com/$($Matches[1])/$($Matches[2])/issues/$($Matches[3])" }
    return ''
}

function Format-TodayRefHtml {
    <# '#n' linked to its issue or PR, the full owner/repo#n as its title; escaped here. #>
    param([string]$Ref, [string]$Url = '')
    if (-not $Ref) { return '' }
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $u = if ($Url -match '\Ahttps://github\.com/') { $Url } else { Get-TodayRefUrl -Ref $Ref }
    $label = if ($Ref -match '#(\d+)\z') { '#' + $Matches[1] } else { $Ref }
    if (-not $u) { return (& $e $label) }
    return '<a class="dp-link" href="' + (& $e $u) + '" target="_blank" rel="noopener noreferrer" title="' + (& $e $Ref) + '">' + (& $e $label) + '</a>'
}

function ConvertTo-TodayDate {
    <# A model date as a DateTime: Windows PowerShell's ConvertFrom-Json leaves 'yyyy-MM-dd' a string, PowerShell 7's makes it a DateTime. #>
    param($Value)
    if ($Value -is [datetime]) { return $Value.Date }
    return [datetime]::ParseExact([string]$Value, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
}

function Format-TodayPageHtml {
    <#
        The page from day-plan.ps1 -Status's model. -ReadError is why the model could not be read at all; the model's
        own error field is why GitHub could not be, and then the plan still shows, from the day file alone. No plan is
        an empty state that says how to make one, never a blank page. -Now is the date the page treats as today (tests).
    #>
    param(
        [AllowNull()]$Model = $null,
        [AllowEmptyString()][string]$ReadError = '',
        [AllowEmptyString()][string]$GeneratedAt = '',
        [AllowEmptyString()][string]$RepoName = '',
        [datetime]$Now = (Get-Date)
    )
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $inv = [System.Globalization.CultureInfo]::InvariantCulture
    $body = New-Object System.Text.StringBuilder
    if ($ReadError) { [void]$body.AppendLine('<p class="msg--warn" role="alert">The day plan could not be read: ' + (& $e $ReadError) + '.</p>') }
    if ($Model -and $Model.error) { [void]$body.AppendLine('<p class="msg--warn" role="alert">GitHub could not be read, so nothing below is marked done by its PR or issue: ' + (& $e $Model.error) + '.</p>') }
    $day = if ($Model) { $Model.day } else { $null }
    $live = if ($Model) { $Model.live } else { $null }

    $hours = 0.0
    if ($Model -and -not $day) {
        [void]$body.AppendLine((Format-AdminEmptyStateHtml -Title 'No plan yet' -Prompt 'plan my day' -TextHtml (
            'Ask Claude to plan the day (the <code>day-plan</code> skill). Paula proposes one goal and the items for it, each with an hour estimate, inside a day of ' +
            $script:DayPlanMinHours + ' to ' + $script:DayPlanBudgetHours + ' hours, and writes it once you agree.')))
    }
    # The layout is the Figma wireframes' (November 12, 2026): the day goal across the page, then two columns -- the
    # plan and what got done on the left, what is not for today and the week on the right.
    $left = New-Object System.Text.StringBuilder
    $right = New-Object System.Text.StringBuilder
    if ($day) {
        # Not filtered: an item's index is its number in the plan, which the close-out's done list counts by.
        $items = @($day.items)
        $doneSet = @{}
        $doneList = if ($live) { @($live.done) } elseif ($day.close) { @($day.close.done) } else { @() }
        foreach ($i in $doneList) { if ($null -ne $i) { $doneSet[[int]$i] = $true } }
        $closed = $null -ne $day.close
        $hours = Get-DayPlanHours -Items $items
        $doneHours = 0.0
        for ($i = 0; $i -lt $items.Count; $i++) { if ($doneSet[$i]) { $doneHours += [double]$items[$i].hours } }
        $pct = if ($hours -gt 0) { [int][math]::Round(100 * $doneHours / $hours) } else { 0 }
        $allDone = $items.Count -and $doneSet.Count -eq $items.Count
        $badge = if ($closed) {
            switch ([string]$day.close.verdict) {
                'reached' { '<span class="tag">Goal reached</span>' }
                'partly'  { '<span class="tag tag--info">Partly reached</span>' }
                default   { '<span class="tag tag--warn">Not reached</span>' }
            }
        } elseif ($allDone) { '<span class="tag">All done</span>' } else { '' }
        $tone = if ($allDone) { 'good' } else { 'info' }

        [void]$body.Append('<section class="card today-goal"><h2>Day goal</h2>')
        [void]$body.Append('<p class="today-goal__title"><span>' + (& $e $day.goal) + '</span>' + $badge + '</p>')
        [void]$body.Append('<p class="today-progress"><span class="meter meter--' + $tone + '" role="img" aria-label="' + $pct + '% of the planned hours done"><span style="width: ' + $pct + '%"></span></span>' +
            '<span class="num">' + $doneSet.Count + ' of ' + $items.Count + ' items &middot; ' + (& $e (Format-DayPlanHours $doneHours)) + ' of ' + (& $e (Format-DayPlanHours $hours)) + '</span></p>')
        foreach ($o in @($day.overrides | Where-Object { $_ })) { [void]$body.Append('<p class="note">Planned on an override (' + (& $e $o.at) + '): ' + (& $e $o.reason) + '</p>') }
        [void]$body.AppendLine('</section>')

        [void]$left.Append('<section class="card"><h2>The plan</h2><ul class="today-items">')
        for ($i = 0; $i -lt $items.Count; $i++) {
            $it = $items[$i]
            $isDone = [bool]$doneSet[$i]
            $mark = if ($isDone) { '<span class="today-items__mark" aria-label="done">&#10003;</span>' } else { '<span class="today-items__mark" aria-label="open">&#9675;</span>' }
            $mode = if ($it.mode -eq 'plan') { '<span class="chip">plan first</span>' } else { '<span class="chip">go</span>' }
            $state = if ($isDone) { '<span class="chip">done</span>' } else { '<span class="chip">open</span>' }
            $cls = if ($isDone) { 'today-items__title today-items__done' } else { 'today-items__title' }
            $ref = Format-TodayRefHtml -Ref ([string]$it.ref)
            $added = if ($it.added) { ' <span class="tag tag--warn">added</span>' } else { '' }
            [void]$left.Append('<li>' + $mark + '<span class="' + $cls + '">' + $(if ($ref) { $ref + ' ' }) + (& $e $it.title) + $added + '</span>' + $mode +
                '<span class="num">' + (& $e (Format-DayPlanHours ([double]$it.hours))) + '</span>' + $state + '</li>')
        }
        [void]$left.AppendLine('</ul></section>')

        # What got done: the plan's done items, then the work outside the plan, and the day's PR and issue count.
        $unplanned = @($(if ($live) { @($live.unplanned) } elseif ($closed) { @($day.close.unplanned) }) | Where-Object { $_ })
        $prs = if ($live) { [int]$live.prs } elseif ($closed) { [int]$day.close.prs } else { 0 }
        $issues = if ($live) { [int]$live.issues } elseif ($closed) { [int]$day.close.issues } else { 0 }
        [void]$left.Append('<section class="card today-done"><h2>What got done</h2>')
        $got = @()
        for ($i = 0; $i -lt $items.Count; $i++) {
            if (-not $doneSet[$i]) { continue }
            $ref = Format-TodayRefHtml -Ref ([string]$items[$i].ref)
            $got += '<li>' + $(if ($ref) { $ref + ' ' }) + (& $e $items[$i].title) + '</li>'
        }
        foreach ($u in $unplanned) {
            $got += '<li>' + (Format-TodayRefHtml -Ref ([string]$u.ref) -Url ([string]$u.url)) + ' ' + (& $e $u.title) + ' &middot; extra, not planned (' + (& $e $u.kind) + ')</li>'
        }
        if ($got.Count) { [void]$left.Append('<ul class="today-list">' + ($got -join '') + '</ul>') } else { [void]$left.Append('<p class="note">Nothing yet.</p>') }
        [void]$left.Append('<p class="note">' + $prs + ' PR(s) merged, ' + $issues + ' issue(s) closed today.</p>')
        [void]$left.AppendLine('</section>')

        $notToday = @($day.notToday | Where-Object { $_ })
        if ($notToday.Count) {
            [void]$right.Append('<section class="card"><h2>Not today</h2><ul class="today-list">')
            foreach ($n in $notToday) { [void]$right.Append('<li>' + (& $e $n) + '</li>') }
            [void]$right.AppendLine('</ul></section>')
        }
    }

    # The week: a row per planned day, its bar the share of its items done.
    $rows = if ($Model) { @($Model.week | Where-Object { $_ }) } else { @() }
    if ($rows.Count) {
        [void]$right.Append('<section class="card"><h2>The week</h2><ul class="today-week">')
        foreach ($r in $rows) {
            $d = ConvertTo-TodayDate $r.date
            $planned = [int]$r.planned; $doneN = [int]$r.done
            $wp = if ($planned -gt 0) { [int][math]::Round(100 * [math]::Min($doneN, $planned) / $planned) } else { 0 }
            $v = if (-not $r.closed) { 'open' } else { switch ([string]$r.verdict) { 'reached' { 'reached' } 'partly' { 'partly reached' } default { 'not reached' } } }
            $tip = (& $e $r.goal) + ' &middot; ' + $doneN + ' of ' + $planned + ' done &middot; ' + $v
            [void]$right.Append('<li title="' + $tip + '"><span class="today-week__day">' + (& $e $d.ToString('ddd', $inv)) + '</span>' +
                '<span class="meter meter--' + $(if ($r.closed -and [string]$r.verdict -eq 'reached') { 'good' } else { 'info' }) + '" role="img" aria-label="' + (& $e $d.ToString('dddd', $inv)) + ': ' + $tip + '"><span style="width: ' + $wp + '%"></span></span></li>')
        }
        [void]$right.AppendLine('</ul></section>')
    }
    if ($left.Length -or $right.Length) {
        if ($day) { [void]$body.AppendLine('<div class="admin-cols"><div>' + $left.ToString() + '</div><div>' + $right.ToString() + '</div></div>') }
        else { [void]$body.AppendLine($right.ToString()) }
    }

    # The crumb and the h1 read 'Today'; the date stands beside the h1, outside it (the wireframes' 'Today - Thursday
    # 12 November'). Another day (a -Date the server never asks for, a page left open past midnight) names its date as
    # the title, so the page never claims a day it is not showing.
    $title = 'Today'
    $meta = '<span class="page-head__meta">&middot; ' + (& $e $Now.ToString('dddd d MMMM', $inv)) + '</span>'
    if ($Model -and $Model.date) {
        $dd = ConvertTo-TodayDate $Model.date
        if ($dd -ne $Now.Date) { $title = $dd.ToString('dddd d MMMM', $inv); $meta = '' }
    }
    $planned = if ($day) { (& $e (Format-DayPlanHours $hours)) + ' of ' + $script:DayPlanMinHours + '&ndash;' + $script:DayPlanBudgetHours + ' h planned' } else { '0 h planned' }
    $when = if ($GeneratedAt) { ', read ' + (& $e $GeneratedAt) } else { '' }
    # Where the plan comes from (#3924): every machine's copy when the day is shared, else this machine's file alone.
    $sharedNote = if ($Model) { [string]$Model.shared } else { '' }
    $source = if ($sharedNote -like 'shared *') { 'The plan is merged from every machine''s day file (' + (& $e $sharedNote) + ').' }
              elseif ($sharedNote) { 'The plan is this machine''s day file (' + (& $e $sharedNote) + ').' }
              else { 'The plan is this machine''s day file.' }
    return Format-GeneralPageHtml -Title $title -TitleMetaHtml $meta -HeadAside $planned -Style ($script:TodayPageStyle) -Body $body.ToString() -SiteName $RepoName `
        -Lead 'The day plan: the day goal, the plan and what got done, and the week.' `
        -FooterNote ($source + ' An item is done when GitHub shows its PR merged or its issue closed that day, or when the close-out marked it done' + $when + ' (<a class="dp-link" href="/refresh?page=today">read again</a>).')
}
