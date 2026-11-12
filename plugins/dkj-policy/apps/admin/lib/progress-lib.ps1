<#
.SYNOPSIS
    Progress (#4004): one Admin page that answers two questions about the repo's project at a glance -- how far the
    app is, and how well the team ran getting there.

.DESCRIPTION
    HOW FAR: the goals of goals-lib.ps1 (#3816), each drawn as a bar of its milestones, one segment per milestone in
    GitHub's order. A closed milestone is filled in the colour of its KIND, read from its labels
    (Get-ProgressMilestoneKind): 'used' (proven in real life), 'measured' (a number crossed its target), and 'built'
    for every other one. An open milestone is an empty segment, the one holding the goal's Now step outlined.

    HOW THE TEAM RAN: the Logbook's finished runs (logbook-lib.ps1, #3364), each one assignment, as how long Claude
    worked and how long it waited on the owner (Get-LogbookWorkTimes). Two signals the issue names are not recorded
    anywhere yet -- how many questions the owner was asked and how many steps the owner did by hand -- and the page
    says so instead of showing a number nobody measured.

    Pure: the server hands in the goals model, the runs and their work times. Needs general-pages-lib.ps1 and
    stopwatch-lib.ps1 (Format-DevSeconds) loaded beside it, as the server has them. Pure ASCII (repo convention for
    .ps1). Tested by scripts/tests/progress.tests.ps1 in the source repo.
#>

# The labels that mark a milestone's kind. A milestone with neither is 'built'.
$script:ProgressKinds = @(
    @{ Name = 'built';    Label = 'Built';    Colour = 'var(--graph-1)'; Means = 'the work is done' },
    @{ Name = 'used';     Label = 'Used';     Colour = 'var(--graph-2)'; Means = 'proven in real life' },
    @{ Name = 'measured'; Label = 'Measured'; Colour = 'var(--graph-3)'; Means = 'a number crossed its target' }
)
# How many of the newest finished runs the chart draws.
$script:ProgressRunsShown = 20

function Get-ProgressMilestoneKind {
    <# Pure: a milestone's kind from its -Labels: 'measured' over 'used' where both are set, else 'built'. #>
    param([AllowEmptyCollection()][string[]]$Labels = @())
    $l = @($Labels | ForEach-Object { ([string]$_).Trim().ToLowerInvariant() })
    if ($l -contains 'measured') { return 'measured' }
    if ($l -contains 'used') { return 'used' }
    return 'built'
}

function ConvertTo-ProgressTeamStats {
    <#
        Pure: the finished -Runs (the Logbook's, cut per issue) with their -WorkTimes (Get-LogbookWorkTimes) as
        @{ Count; Measured; Work; Waiting; Share; Rows }. Only a run with a work time counts towards Work, Waiting and
        Share, since a run the transcripts did not cover says nothing about who waited. Rows are the newest
        $script:ProgressRunsShown of those, oldest first, each @{ Label; Work; Waiting }. Share is waiting of the whole,
        a whole percentage, 0 with nothing measured.
    #>
    param([AllowEmptyCollection()][object[]]$Runs = @(), [hashtable]$WorkTimes = @{})
    $done = @($Runs | Where-Object { $_ -and $_.End } | Sort-Object { $_.Start })
    $measured = @($done | Where-Object { $WorkTimes[$_.Id] })
    $work = 0.0; $wait = 0.0
    foreach ($r in $measured) { $work += [double]$WorkTimes[$r.Id].Work; $wait += [double]$WorkTimes[$r.Id].Waiting }
    $share = if (($work + $wait) -gt 0) { [int][Math]::Round(100.0 * $wait / ($work + $wait)) } else { 0 }
    $tail = if ($measured.Count -gt $script:ProgressRunsShown) { @($measured[($measured.Count - $script:ProgressRunsShown)..($measured.Count - 1)]) } else { $measured }
    $rows = @($tail | ForEach-Object { @{ Label = [string]$_.Label; Work = [double]$WorkTimes[$_.Id].Work; Waiting = [double]$WorkTimes[$_.Id].Waiting } })
    return @{ Count = $done.Count; Measured = $measured.Count; Work = $work; Waiting = $wait; Share = $share; Rows = $rows }
}

$script:ProgressPageStyle = '.progress-goal + .progress-goal { margin-top: var(--spacing-4); }' + "`n" +
    '.progress-goal__head { display: flex; justify-content: space-between; gap: var(--spacing-3); align-items: baseline; margin-bottom: var(--spacing-2); }' + "`n" +
    '.progress-track { display: flex; gap: var(--spacing-1); }' + "`n" +
    '.progress-track > a, .progress-track > span { flex: 1; height: 18px; border-radius: var(--radius-1); background: var(--bg-3); }' + "`n" +
    '.progress-track > .is-done { background: var(--c); }' + "`n" +
    '.progress-track > .is-now { outline: 2px solid var(--primary); outline-offset: 1px; }' + "`n" +
    '.progress-track > a:focus-visible { outline: 2px solid var(--primary); outline-offset: 2px; }'

function Format-ProgressGoalsHtml {
    <# The "how far" card: each goal as a bar of its milestones (ConvertFrom-GoalsGraph's model), with a legend. Escaped here. #>
    param([AllowNull()][object[]]$Goals = $null, [AllowEmptyString()][string]$ReadError = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $kinds = @{}; foreach ($k in $script:ProgressKinds) { $kinds[$k.Name] = $k }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('<section class="card"><div class="card__head"><h2>How far the app is</h2></div>')
    if ($ReadError) { [void]$sb.Append('<p class="msg--warn" role="alert">The goals could not be read from GitHub: ' + (& $e $ReadError) + '.</p>') }
    $list = @($Goals | Where-Object { $_ })
    if ($null -ne $Goals -and -not $list.Count) {
        [void]$sb.Append('<p>No goal yet. A goal is an open issue labelled <code>' + (& $e (Get-GoalLabel)) + '</code>, its milestones its sub-issues; ask Claude to plan one (<code>plan-goal</code>).</p>')
    }
    foreach ($g in $list) {
        $ms = @($g.Milestones)
        $closed = @($ms | Where-Object { $_.Closed }).Count
        $nowMs = if ($g.Now) { [int]$g.Now.Milestone.Number } else { 0 }
        [void]$sb.Append('<div class="progress-goal"><div class="progress-goal__head"><span>' + (Format-GoalItemLink $g) + '</span>' +
            '<span class="num">' + $closed + ' of ' + $ms.Count + ' milestones</span></div>')
        if (-not $ms.Count) {
            [void]$sb.Append('<p class="note">Not broken down into milestones yet.</p></div>')
            continue
        }
        [void]$sb.Append('<div class="progress-track" role="list">')
        foreach ($m in $ms) {
            $kind = $kinds[(Get-ProgressMilestoneKind -Labels @($m.Labels))]
            $state = if ($m.Closed) { $kind.Label.ToLowerInvariant() } elseif ([int]$m.Number -eq $nowMs) { 'open, the next step is here' } else { 'open' }
            $cls = @(); if ($m.Closed) { $cls += 'is-done' }; if (-not $m.Closed -and [int]$m.Number -eq $nowMs) { $cls += 'is-now' }
            $name = '#' + [int]$m.Number + ' ' + $m.Title + ': ' + $state
            $attrs = ' role="listitem" title="' + (& $e $name) + '" aria-label="' + (& $e $name) + '"' +
                $(if ($cls.Count) { ' class="' + ($cls -join ' ') + '"' } else { '' }) +
                $(if ($m.Closed) { ' style="--c: ' + $kind.Colour + '"' } else { '' })
            if ($m.Url) { [void]$sb.Append('<a href="' + (& $e $m.Url) + '" target="_blank" rel="noopener noreferrer"' + $attrs + '></a>') }
            else { [void]$sb.Append('<span' + $attrs + '></span>') }
        }
        [void]$sb.Append('</div></div>')
    }
    if ($list.Count) {
        [void]$sb.Append('<div class="legend">')
        foreach ($k in $script:ProgressKinds) { [void]$sb.Append('<span class="legend__item" style="--c: ' + $k.Colour + '">' + $k.Label + ': ' + $k.Means + '</span>') }
        [void]$sb.Append('<span class="legend__item" style="--c: var(--bg-3)">Open</span></div>')
        [void]$sb.Append('<p class="note">A milestone is marked used or measured by the label <code>used</code> or <code>measured</code> on its issue; without one it counts as built.</p>')
    }
    [void]$sb.Append('</section>')
    return $sb.ToString()
}

function Format-ProgressRunsChartHtml {
    <# An SVG column per run in -Rows (ConvertTo-ProgressTeamStats), work below and waiting on top, sharing one scale. #>
    param([AllowEmptyCollection()][object[]]$Rows = @())
    $rows = @($Rows | Where-Object { $_ })
    if (-not $rows.Count) { return '' }
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $w = 600; $h = 140; $gap = 4
    $max = [double](@($rows | ForEach-Object { $_.Work + $_.Waiting }) | Measure-Object -Maximum).Maximum
    if ($max -le 0) { $max = 1 }
    $col = ($w - $gap * ($rows.Count - 1)) / $rows.Count
    $inv = [Globalization.CultureInfo]::InvariantCulture
    $n = { param([double]$v) $v.ToString('0.#', $inv) }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('<div class="chart"><svg viewBox="0 0 ' + $w + ' ' + $h + '" role="img" aria-label="Work and waiting on you, per assignment, oldest first">')
    $i = 0
    foreach ($r in $rows) {
        $x = $i * ($col + $gap)
        $hw = $h * $r.Work / $max; $hq = $h * $r.Waiting / $max
        $tip = $r.Label + ': work ' + (Format-DevSeconds $r.Work) + ', waiting on you ' + (Format-DevSeconds $r.Waiting)
        [void]$sb.Append('<g class="bar" tabindex="0"><title>' + (& $e $tip) + '</title>' +
            '<rect x="' + (& $n $x) + '" y="' + (& $n ($h - $hw)) + '" width="' + (& $n $col) + '" height="' + (& $n $hw) + '" style="fill: var(--graph-1)"></rect>' +
            '<rect x="' + (& $n $x) + '" y="' + (& $n ($h - $hw - $hq)) + '" width="' + (& $n $col) + '" height="' + (& $n $hq) + '" style="fill: var(--graph-2)"></rect></g>')
        $i++
    }
    [void]$sb.Append('</svg></div>')
    [void]$sb.Append('<div class="legend"><span class="legend__item" style="--c: var(--graph-1)">Work</span><span class="legend__item" style="--c: var(--graph-2)">Waiting on you</span></div>')
    return $sb.ToString()
}

function Format-ProgressTeamHtml {
    <# The "how the team ran" card: four tiles over the Logbook, the two signals nobody records yet, and the chart. #>
    param([Parameter(Mandatory = $true)][hashtable]$Stats, [AllowEmptyString()][string]$ReadError = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $tile = { param($label, $value) '<div class="tile"><div class="label">' + $label + '</div><div class="v num">' + $value + '</div></div>' }
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append('<section class="card"><div class="card__head"><h2>How the team ran</h2></div>')
    if ($ReadError) { [void]$sb.Append('<p class="msg--warn" role="alert">The Logbook could not be read: ' + (& $e $ReadError) + '.</p>') }
    [void]$sb.Append('<div class="tiles">')
    [void]$sb.Append((& $tile 'Assignments' ([string]$Stats.Count)))
    [void]$sb.Append((& $tile 'Claude worked' $(if ($Stats.Measured) { Format-DevSeconds $Stats.Work } else { '&ndash;' })))
    [void]$sb.Append((& $tile 'Waited on you' $(if ($Stats.Measured) { Format-DevSeconds $Stats.Waiting } else { '&ndash;' })))
    [void]$sb.Append((& $tile 'Share waiting' $(if ($Stats.Measured) { [string]$Stats.Share + '%' } else { '&ndash;' })))
    [void]$sb.Append((& $tile 'Questions asked' 'not recorded yet'))
    [void]$sb.Append((& $tile 'Steps by hand' 'not recorded yet'))
    [void]$sb.Append('</div>')
    if (@($Stats.Rows).Count) {
        [void]$sb.Append('<p class="note">The newest ' + @($Stats.Rows).Count + ' assignments the transcripts cover, oldest on the left. Hover a column for its name and times.</p>')
        [void]$sb.Append((Format-ProgressRunsChartHtml -Rows $Stats.Rows))
    } elseif (-not $ReadError) {
        [void]$sb.Append('<p class="note">No finished assignment in the Logbook yet.</p>')
    }
    [void]$sb.Append('</section>')
    return $sb.ToString()
}

function Format-ProgressPageHtml {
    <#
        The Progress page on '/dev/progress' (#4004): the two cards side by side, made for Admin's one screen.
        -Goals is ConvertFrom-GoalsGraph's model (null when unread), -Runs the Logbook's finished runs and -WorkTimes
        their Get-LogbookWorkTimes.
    #>
    param(
        [AllowNull()][object[]]$Goals = $null,
        [AllowEmptyString()][string]$GoalsError = '',
        [AllowEmptyCollection()][object[]]$Runs = @(),
        [hashtable]$WorkTimes = @{},
        [AllowEmptyString()][string]$LogbookError = '',
        [AllowEmptyString()][string]$RepoName = ''
    )
    $stats = ConvertTo-ProgressTeamStats -Runs $Runs -WorkTimes $WorkTimes
    $body = '<div class="grid-2">' + (Format-ProgressGoalsHtml -Goals $Goals -ReadError $GoalsError) + (Format-ProgressTeamHtml -Stats $stats -ReadError $LogbookError) + '</div>'
    return Format-GeneralPageHtml -Title 'Progress' -Style ($script:ProgressPageStyle) -Body $body -SiteName $RepoName `
        -Lead 'How far this repo''s app is, milestone by milestone, and how well the team ran: how long Claude worked and how long it waited on you.' `
        -FooterNote ('The milestones are read from GitHub as the Goals page reads them; the assignments from this machine''s Logbook, the newest page of it, with the transcripts telling work from waiting. ' +
            'How many questions you were asked and how many steps you did by hand are not recorded yet. Built by the dkj-policy plugin''s <code>apps/admin/lib/progress-lib.ps1</code>.')
}
