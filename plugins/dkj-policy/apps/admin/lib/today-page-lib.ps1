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

$script:TodayPageStyle = '.today-goal { border-left: 4px solid var(--primary-muted); }' + "`n" +
    '.today-goal .today-goal__title { display: flex; gap: var(--spacing-3); align-items: center; justify-content: space-between; margin: 0 0 var(--spacing-2); font-size: var(--text-h3); }' + "`n" +
    '.today-done h3 { margin: var(--spacing-4) 0 var(--spacing-1); }' + "`n" +
    '.today-items { margin: 0; padding: 0; list-style: none; }' + "`n" +
    '.today-items > li { display: flex; gap: var(--spacing-2); align-items: baseline; padding: var(--spacing-1) 0; border-top: 1px solid var(--bg-4); }' + "`n" +
    '.today-items > li:first-child { border-top: 0; }' + "`n" +
    '.today-items .today-items__title { flex: 1; }' + "`n" +
    '.today-items .today-items__done { color: var(--primary-muted); text-decoration: line-through; }' + "`n" +
    '.today-progress { display: flex; gap: var(--spacing-2); align-items: center; }' + "`n" +
    '.today-progress > .meter { flex: 1; min-width: 80px; }'

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

    if ($Model -and -not $day) {
        [void]$body.AppendLine('<section class="card"><div class="card__head"><h2>No plan yet</h2></div>' +
            '<p>Ask Claude to plan the day (the <code>day-plan</code> skill). Paula proposes one goal and the items for it, each with an hour estimate, inside a day of 6 to 8 hours, and writes it once you agree.</p></section>')
    }
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
        } elseif ($allDone) { '<span class="tag">All done</span>' } else { '<span class="chip">In progress</span>' }
        $tone = if ($allDone) { 'good' } else { 'info' }

        [void]$body.AppendLine('<div class="grid-2">')
        [void]$body.Append('<section class="card grid__full today-goal"><div class="card__head"><h2>Day goal</h2></div>')
        [void]$body.Append('<p class="today-goal__title"><span>' + (& $e $day.goal) + '</span>' + $badge + '</p>')
        [void]$body.Append('<p class="card__sub"><span class="today-progress"><span class="meter meter--' + $tone + '" role="img" aria-label="' + $pct + '% of the planned hours done"><span style="width: ' + $pct + '%"></span></span>' +
            '<span class="num">' + $doneSet.Count + ' of ' + $items.Count + ' done, ' + (& $e (Format-DayPlanHours $doneHours)) + ' of ' + (& $e (Format-DayPlanHours $hours)) + ' planned in a ' + $script:DayPlanBudgetHours + ' h day</span></span></p>')
        foreach ($o in @($day.overrides | Where-Object { $_ })) { [void]$body.Append('<p class="note">Planned on an override (' + (& $e $o.at) + '): ' + (& $e $o.reason) + '</p>') }
        [void]$body.AppendLine('</section>')

        [void]$body.Append('<section class="card"><div class="card__head"><h2>Plan</h2></div><ul class="today-items">')
        for ($i = 0; $i -lt $items.Count; $i++) {
            $it = $items[$i]
            $isDone = [bool]$doneSet[$i]
            $state = if ($isDone) { '<span class="badge badge--sm badge--good" aria-label="done">&#10003;</span>' } else { '<span class="badge badge--sm badge--neutral" aria-label="open"></span>' }
            $mode = if ($it.mode -eq 'plan') { '<span class="tag tag--info">plan first</span>' } else { '<span class="tag">go</span>' }
            $cls = if ($isDone) { 'today-items__title today-items__done' } else { 'today-items__title' }
            $ref = Format-TodayRefHtml -Ref ([string]$it.ref)
            $added = if ($it.added) { ' <span class="tag tag--warn">added</span>' } else { '' }
            [void]$body.Append('<li>' + $state + '<span class="' + $cls + '">' + (& $e $it.title) + $(if ($ref) { ' ' + $ref }) + $added + '</span>' + $mode +
                '<span class="num">' + (& $e (Format-DayPlanHours ([double]$it.hours))) + '</span></li>')
        }
        [void]$body.AppendLine('</ul></section>')

        $unplanned = @($(if ($live) { @($live.unplanned) } elseif ($closed) { @($day.close.unplanned) }) | Where-Object { $_ })
        $prs = if ($live) { [int]$live.prs } elseif ($closed) { [int]$day.close.prs } else { 0 }
        $issues = if ($live) { [int]$live.issues } elseif ($closed) { [int]$day.close.issues } else { 0 }
        [void]$body.Append('<section class="card today-done"><div class="card__head"><h2>Done</h2></div>')
        [void]$body.Append('<dl class="facts facts--row"><dt>PRs merged</dt><dd class="num">' + $prs + '</dd><dt>Issues closed</dt><dd class="num">' + $issues + '</dd></dl>')
        if ($unplanned.Count) {
            [void]$body.Append('<h3>Extra</h3><ul class="today-items">')
            foreach ($u in $unplanned) {
                [void]$body.Append('<li><span class="today-items__title">' + (& $e $u.title) + ' ' + (Format-TodayRefHtml -Ref ([string]$u.ref) -Url ([string]$u.url)) + '</span><span class="tag">' + (& $e $u.kind) + '</span></li>')
            }
            [void]$body.Append('</ul>')
        } else {
            [void]$body.Append('<p class="note">No work outside the plan.</p>')
        }
        $notToday = @($day.notToday | Where-Object { $_ })
        if ($notToday.Count) {
            [void]$body.Append('<h3>Not today</h3><ul class="today-items">')
            foreach ($n in $notToday) { [void]$body.Append('<li><span class="today-items__title">' + (& $e $n) + '</span></li>') }
            [void]$body.Append('</ul>')
        }
        [void]$body.AppendLine('</section>')
    }

    $rows = if ($Model) { @($Model.week | Where-Object { $_ }) } else { @() }
    if ($rows.Count) {
        $wrap = if ($day) { 'card grid__full' } else { 'card' }
        [void]$body.Append('<section class="' + $wrap + '"><div class="card__head"><h2>This week</h2></div><div class="table-wrap"><table class="table table--dense"><thead><tr><th>Day</th><th class="col-start">Goal</th><th class="num">Done</th><th class="num">Extra</th><th>Result</th></tr></thead><tbody>')
        foreach ($r in $rows) {
            $d = ConvertTo-TodayDate $r.date
            $v = if (-not $r.closed) { '<span class="chip">open</span>' } else {
                switch ([string]$r.verdict) {
                    'reached' { '<span class="tag">reached</span>' }
                    'partly'  { '<span class="tag tag--info">partly</span>' }
                    default   { '<span class="tag tag--warn">not reached</span>' }
                } }
            $doneCell = if ($r.closed) { [string]$r.done + ' of ' + [string]$r.planned } else { [string]$r.planned + ' planned' }
            $extraCell = if ($r.closed) { [string]$r.extra } else { '' }
            [void]$body.Append('<tr><td>' + (& $e $d.ToString('ddd d MMM', $inv)) + '</td><td class="col-start">' + (& $e $r.goal) + '</td><td class="num">' + (& $e $doneCell) + '</td><td class="num">' + (& $e $extraCell) + '</td><td>' + $v + '</td></tr>')
        }
        [void]$body.AppendLine('</tbody></table></div></section>')
    }
    if ($day) { [void]$body.AppendLine('</div>') }

    # The crumb and the h1 read 'Today' on today; another day (a -Date the server never asks for, a page left open
    # past midnight) names its date, so the page never claims a day it is not showing.
    $title = 'Today'
    if ($Model -and $Model.date) {
        $dd = ConvertTo-TodayDate $Model.date
        if ($dd -ne $Now.Date) { $title = $dd.ToString('dddd d MMMM', $inv) }
    }
    $when = if ($GeneratedAt) { ', read ' + (& $e $GeneratedAt) } else { '' }
    return Format-GeneralPageHtml -Title $title -Style ($script:TodayPageStyle) -Body $body.ToString() -SiteName $RepoName `
        -Lead 'The day plan: the day goal, the plan and what got done, and the week.' `
        -FooterNote ('The plan is this machine''s day file. An item is done when GitHub shows its PR merged or its issue closed that day, or when the close-out marked it done' + $when + ' (<a class="dp-link" href="/refresh?page=today">read again</a>).')
}
