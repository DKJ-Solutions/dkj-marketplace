<#
.SYNOPSIS
    Goals (#3816): a goal broken into milestones and tasks, held on GitHub as issues and sub-issues, and the focus
    that follows from it -- the one step to take Now and the few after it.

.DESCRIPTION
    THE DATA IS GITHUB'S OWN (Dave, November 5, 2026, chosen over Asana and a file in the repo): a goal is an open
    issue carrying the label Get-GoalLabel names, its milestones are its sub-issues and their tasks are THEIR
    sub-issues, each list in the order GitHub keeps it. So the page updates itself as sessions claim and close
    issues, and there is no second administration to keep in step.

    Read by Admin's /dev/goals page (Format-GoalsPageHtml, served by pages/serve-general-pages.ps1) and by the
    plan-goal skill's script (pages/plan-goal.ps1), which files a breakdown and answers "what now?". The model
    functions here are pure; the gh calls are their callers'. Format-GoalsPageHtml needs general-pages-lib.ps1
    loaded beside this file, as the server has it.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/goals.tests.ps1 in the source repo.
#>

function Get-GoalLabel {
    <# The label that makes an open issue a goal. #>
    'goal'
}

function Get-GoalsGraphQuery {
    <#
        The one GraphQL query the page and the skill read goals with: every open issue carrying the label in the
        variable $label, oldest first, with its sub-issues (the milestones) and theirs (the tasks), in GitHub's own
        order. $owner, $name and $label are its variables, so the query holds no quote a command line could mangle.
        The bounds (20 goals, 25 milestones, 50 tasks each) keep it far under GitHub's node limit. A milestone also
        carries its labels (10 at most), which the Progress page reads its kind from (#4004); a task does not, which
        keeps the 25,000 tasks the bounds allow from costing ten label nodes each.
    #>
    $issue = 'number title url state assignees(first: 3) { nodes { login } }'
    return 'query($owner: String!, $name: String!, $label: String!) { repository(owner: $owner, name: $name) { ' +
        'issues(first: 20, states: OPEN, labels: [$label], orderBy: { field: CREATED_AT, direction: ASC }) { nodes { ' +
        $issue + ' subIssues(first: 25) { nodes { ' + $issue + ' labels(first: 10) { nodes { name } } subIssues(first: 50) { nodes { ' + $issue + ' } } } } } } } }'
}

function ConvertTo-GoalItem {
    <# Pure: one issue node of the query as @{ Number; Title; Url; Closed; Assignees; Labels } (Labels empty where the node carries none). #>
    param($Node)
    $url = [string]$Node.url
    if ($url -notmatch '\Ahttps://github\.com/[^\s"<>]+\z') { $url = '' }
    return @{
        Number    = [int]$Node.number
        Title     = [string]$Node.title
        Url       = $url
        Closed    = ([string]$Node.state -eq 'CLOSED')
        Assignees = @(@($Node.assignees.nodes) | Where-Object { $_ -and $_.login } | ForEach-Object { [string]$_.login })
        Labels    = @(if ($Node.PSObject.Properties['labels'] -and $Node.labels) { @($Node.labels.nodes) | Where-Object { $_ -and $_.name } | ForEach-Object { [string]$_.name } })
    }
}

function Get-GoalSteps {
    <#
        Pure: the open steps of a goal (ConvertFrom-GoalsGraph's shape), in the order they are to be taken -- the
        open tasks of each open milestone, milestone by milestone, each @{ Item; Milestone; Unplanned }. An open
        milestone with no task yet is a step itself (Unplanned), since breaking it down is the next thing to do
        there. A closed milestone's open tasks are left out: closing it said they no longer stand in the way.
    #>
    param([Parameter(Mandatory = $true)]$Goal)
    $out = New-Object System.Collections.Generic.List[object]
    foreach ($m in @($Goal.Milestones)) {
        if ($m.Closed) { continue }
        $tasks = @($m.Tasks)
        if (-not $tasks.Count) { $out.Add(@{ Item = $m; Milestone = $m; Unplanned = $true }); continue }
        foreach ($t in $tasks) { if (-not $t.Closed) { $out.Add(@{ Item = $t; Milestone = $m; Unplanned = $false }) } }
    }
    return , $out.ToArray()
}

function ConvertFrom-GoalsGraph {
    <#
        Pure: the parsed answer of Get-GoalsGraphQuery (its data object, or the whole answer with a data member) as
        the model the page and the skill read: a list of goals, each @{ Number; Title; Url; Assignees; Milestones;
        Done; Total; Now; Next }. A milestone carries its Tasks and its own Done and Total; one with no task counts as
        one item, done when it is closed, and a closed milestone is done whole. Now is the first of Get-GoalSteps, Next the -NextCount after it.
    #>
    param($Data, [ValidateRange(0, 20)][int]$NextCount = 3)
    if ($Data -and $Data.PSObject.Properties['data']) { $Data = $Data.data }
    $goals = New-Object System.Collections.Generic.List[object]
    $nodes = @(if ($Data -and $Data.repository -and $Data.repository.issues) { $Data.repository.issues.nodes })
    foreach ($n in @($nodes | Where-Object { $_ })) {
        $g = ConvertTo-GoalItem $n
        $done = 0; $total = 0
        $ms = New-Object System.Collections.Generic.List[object]
        foreach ($mn in @(@($n.subIssues.nodes) | Where-Object { $_ })) {
            $m = ConvertTo-GoalItem $mn
            $m.Tasks = @(@($mn.subIssues.nodes) | Where-Object { $_ } | ForEach-Object { ConvertTo-GoalItem $_ })
            if ($m.Tasks.Count) {
                $m.Total = $m.Tasks.Count
                # A closed milestone is done whole: closing it said its leftovers no longer stand in the way, as
                # Get-GoalSteps reads it too.
                $m.Done = if ($m.Closed) { $m.Total } else { @($m.Tasks | Where-Object { $_.Closed }).Count }
            } else {
                $m.Total = 1
                $m.Done = $(if ($m.Closed) { 1 } else { 0 })
            }
            $done += $m.Done; $total += $m.Total
            $ms.Add($m)
        }
        $g.Milestones = $ms.ToArray()
        $g.Done = $done; $g.Total = $total
        # Get-GoalSteps returns its array whole (the leading comma), so it is taken as it comes, never wrapped in
        # @() again: that would make an empty list a list of one empty list.
        $steps = Get-GoalSteps -Goal $g
        $g.Now = $null
        $g.Next = @()
        if ($steps.Count) { $g.Now = $steps[0] }
        if ($steps.Count -gt 1 -and $NextCount -gt 0) { $g.Next = @($steps[1..([Math]::Min($steps.Count - 1, $NextCount))]) }
        $goals.Add($g)
    }
    return , $goals.ToArray()
}

function Get-GoalPercent {
    <# Pure: -Done of -Total as a whole percentage, 0 for an empty total. #>
    param([int]$Done, [int]$Total)
    if ($Total -le 0) { return 0 }
    return [int][Math]::Floor(100.0 * $Done / $Total)
}

function Format-GoalFocusText {
    <#
        Pure: the plain-text answer to "what now?" for one goal (Format-GoalFocusText -Goal), as the skill prints it:
        the goal, its progress, Now and Next. A goal with no milestone says it is not broken down yet.
    #>
    param([Parameter(Mandatory = $true)]$Goal)
    $ref = { param($i) '#' + $i.Number + ' ' + $i.Title }
    $lines = @("Goal $(& $ref $Goal) -- $($Goal.Done) of $($Goal.Total) done")
    if (-not @($Goal.Milestones).Count) {
        $lines += '  Now:  not broken down yet -- run plan-goal on it to propose its milestones and tasks.'
        return ($lines -join "`n")
    }
    if (-not $Goal.Now) {
        $lines += '  Now:  every milestone is done -- close the goal, or add the milestone that is still missing.'
        return ($lines -join "`n")
    }
    $now = $Goal.Now
    $what = if ($now.Unplanned) { 'break down milestone ' + (& $ref $now.Item) } else { (& $ref $now.Item) + '  (milestone #' + $now.Milestone.Number + ')' }
    if (@($now.Item.Assignees).Count) { $what += '  [claimed: ' + (@($now.Item.Assignees) -join ', ') + ']' }
    $lines += '  Now:  ' + $what
    foreach ($s in @($Goal.Next)) {
        $lines += '  Next: ' + $(if ($s.Unplanned) { 'break down milestone ' + (& $ref $s.Item) } else { & $ref $s.Item })
    }
    return ($lines -join "`n")
}

function ConvertTo-GoalPlan {
    <#
        Pure: a breakdown as plan-goal files it, read from its JSON text, validated, as
        @{ Plan = @{ Goal; Milestones; Labels }; Error }. The shape:
          { "goal": { "title": "...", "body": "..." } | { "number": 123 },
            "labels": ["prio-2"],                                  (optional: on every milestone and task filed)
            "milestones": [ { "title": "...", "body": "...", "tasks": [ { "title": "...", "body": "..." } ] }
                            | { "number": 124, "tasks": [ ... ] } ] }
        A number names an issue that already exists, so a breakdown can extend a goal or a milestone instead of
        filing it again. Bounds: 1 to 8 milestones, at most 12 tasks each, titles 1 to 200 characters. Error is the
        first thing wrong, '' when the plan holds.
    #>
    param([AllowEmptyString()][string]$Json)
    $fail = { param($m) @{ Plan = $null; Error = $m } }
    try { $p = ConvertFrom-Json -InputObject $Json } catch { return (& $fail 'the plan is not valid JSON') }
    if (-not $p) { return (& $fail 'the plan is empty') }
    $item = {
        param($o, [string]$what)
        if ($o -and $o.PSObject.Properties['number'] -and $o.number) {
            $num = 0
            if (-not [int]::TryParse([string]$o.number, [ref]$num) -or $num -le 0) { return @{ Error = "$what has a number that is not an issue number" } }
            return @{ Number = $num; Title = ''; Body = ''; Error = '' }
        }
        $t = if ($o -and $o.PSObject.Properties['title']) { ([string]$o.title).Trim() } else { '' }
        if (-not $t) { return @{ Error = "$what has no title" } }
        if ($t.Length -gt 200) { return @{ Error = "$what has a title over 200 characters" } }
        $b = if ($o.PSObject.Properties['body']) { [string]$o.body } else { '' }
        return @{ Number = 0; Title = $t; Body = $b; Error = '' }
    }
    $goal = & $item $p.goal 'the goal'
    if ($goal.Error) { return (& $fail $goal.Error) }
    $labels = @()
    if ($p.PSObject.Properties['labels']) {
        $labels = @(@($p.labels) | ForEach-Object { ([string]$_).Trim() } | Where-Object { $_ })
        foreach ($l in $labels) { if ($l -notmatch '\A[^,\s][^,]{0,49}\z') { return (& $fail "the label '$l' is not a label name") } }
    }
    $msIn = @(if ($p.PSObject.Properties['milestones']) { $p.milestones | Where-Object { $_ } })
    if ($msIn.Count -lt 1 -or $msIn.Count -gt 8) { return (& $fail 'a plan holds 1 to 8 milestones') }
    $ms = @()
    for ($i = 0; $i -lt $msIn.Count; $i++) {
        $m = & $item $msIn[$i] ('milestone ' + ($i + 1))
        if ($m.Error) { return (& $fail $m.Error) }
        $tIn = @(if ($msIn[$i].PSObject.Properties['tasks']) { $msIn[$i].tasks | Where-Object { $_ } })
        if ($tIn.Count -gt 12) { return (& $fail ('milestone ' + ($i + 1) + ' holds more than 12 tasks: split it')) }
        $tasks = @()
        for ($j = 0; $j -lt $tIn.Count; $j++) {
            $t = & $item $tIn[$j] ('task ' + ($j + 1) + ' of milestone ' + ($i + 1))
            if ($t.Error) { return (& $fail $t.Error) }
            if ($t.Number) { return (& $fail ('task ' + ($j + 1) + ' of milestone ' + ($i + 1) + ' names a number: a task is always filed new')) }
            $tasks += , $t
        }
        $m.Tasks = $tasks
        $ms += , $m
    }
    return @{ Plan = @{ Goal = $goal; Milestones = $ms; Labels = $labels }; Error = '' }
}

function Format-GoalPlanText {
    <# Pure: a validated plan (ConvertTo-GoalPlan's Plan) as the tree plan-goal prints before it files anything. #>
    param([Parameter(Mandatory = $true)]$Plan)
    $name = { param($i, $kind) if ($i.Number) { "#$($i.Number) (existing $kind)" } else { $i.Title } }
    $lines = @('Goal: ' + (& $name $Plan.Goal 'goal'))
    $mi = 0
    foreach ($m in @($Plan.Milestones)) {
        $mi++
        $lines += "  $mi. " + (& $name $m 'milestone')
        foreach ($t in @($m.Tasks)) { $lines += '       - ' + $t.Title }
    }
    if (@($Plan.Labels).Count) { $lines += 'Labels on every milestone and task: ' + (@($Plan.Labels) -join ', ') }
    return ($lines -join "`n")
}

$script:GoalsPageStyle = '.goal { display: grid; gap: var(--spacing-4); }' + "`n" +
    '.goal__head { display: flex; align-items: center; gap: var(--spacing-3); }' + "`n" +
    '.goal__head h2 { margin: 0; font-size: var(--text-title); }' + "`n" +
    '.goal__head h2 > a { margin-right: var(--spacing-1); }' + "`n" +
    '.goal .chip { color: var(--primary-muted); font-size: var(--text-xs); font-weight: var(--font-weight-regular); }' + "`n" +
    '.goal-progress__bar { display: flex; gap: var(--spacing-3); align-items: center; color: var(--primary-muted); font-size: var(--text-sm); }' + "`n" +
    '.goal-progress__bar > .meter { flex: 1; min-width: 80px; }' + "`n" +
    '.goal-progress > .goal-progress__bar > .meter { flex: 0 1 60%; }' + "`n" +
    '.goal-now { display: grid; gap: var(--spacing-2); justify-items: start; padding: var(--spacing-4) var(--spacing-5); background: var(--bg-2); border: 2px solid var(--primary); border-radius: var(--radius-2); }' + "`n" +
    '.goal-now__pill { padding: var(--spacing-0-5) var(--spacing-2); border-radius: var(--radius-pill); background: var(--primary); color: var(--bg-1); font-size: var(--text-xs); font-weight: var(--font-weight-bold); text-transform: uppercase; }' + "`n" +
    '.goal-now .goal-now__title { margin: 0; font-size: var(--text-h3); font-weight: var(--font-weight-bold); }' + "`n" +
    '.goal-now .goal-now__sub { margin: 0; color: var(--primary-muted); font-size: var(--text-sm); }' + "`n" +
    '.goal-block { display: grid; gap: var(--spacing-2); }' + "`n" +
    '.goal-block > h3 { margin: 0; font-size: var(--text-xs); font-weight: var(--font-weight-bold); letter-spacing: 0.06em; text-transform: uppercase; color: var(--primary-muted); }' + "`n" +
    '.goal-next { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: var(--spacing-3); margin: 0; padding: 0; list-style: none; }' + "`n" +
    '.goal-next > li { display: grid; gap: var(--spacing-1); padding: var(--spacing-3) var(--spacing-4); border: 1px solid var(--bg-4); border-radius: var(--radius-2); }' + "`n" +
    '.goal-next__title { font-weight: var(--font-weight-bold); }' + "`n" +
    '.goal-next__meta { color: var(--primary-muted); font-size: var(--text-sm); }' + "`n" +
    '.goal-milestones { display: grid; gap: var(--spacing-2); }' + "`n" +
    '.goal-milestone { border: 1px solid var(--bg-3); border-radius: var(--radius-1-5); }' + "`n" +
    '.goal-milestone[open] { background: var(--bg-2); }' + "`n" +
    '.goal-milestone > summary { display: flex; gap: var(--spacing-4); align-items: center; padding: var(--spacing-3); cursor: pointer; list-style: none; }' + "`n" +
    '.goal-milestone > summary::-webkit-details-marker { display: none; }' + "`n" +
    '.goal-milestone > summary::before { content: "\25B8"; color: var(--primary-muted); font-size: var(--text-sm); }' + "`n" +
    '.goal-milestone[open] > summary::before { content: "\25BE"; }' + "`n" +
    '.goal-milestone__name { flex: none; width: var(--spacing-56); font-weight: var(--font-weight-bold); }' + "`n" +
    '.goal-milestone > summary > .goal-progress__bar { flex: 1; }' + "`n" +
    '.goal-milestone > .goal-steps, .goal-milestone > .note { margin: 0; padding: 0 var(--spacing-3) var(--spacing-3) var(--spacing-8); }' + "`n" +
    '.goal-steps { list-style: none; }' + "`n" +
    '.goal-steps > li { display: flex; gap: var(--spacing-2); align-items: baseline; padding: var(--spacing-1) 0; border-top: 1px solid var(--bg-4); }' + "`n" +
    '.goal-steps > li:first-child { border-top: 0; }' + "`n" +
    '.goal-steps .goal-steps__done { color: var(--primary-muted); text-decoration: line-through; }'

function Format-GoalItemLink {
    <# One issue as '#n title', the number a link to it where the model holds its url; escaped here. #>
    param([Parameter(Mandatory = $true)]$Item)
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $num = '#' + [int]$Item.Number
    $ref = if ($Item.Url) { '<a class="dp-link" href="' + (& $e $Item.Url) + '" target="_blank" rel="noopener noreferrer">' + $num + '</a>' } else { $num }
    return $ref + ' ' + (& $e $Item.Title)
}

function Format-GoalProgressHtml {
    <#
        A meter and 'x of y' for -Done of -Total; -Noun follows the count ('2 of 5 milestones'), and -Short writes
        'x/y' instead, with a check mark once all are done (the wireframes' milestone rows).
    #>
    param([int]$Done, [int]$Total, [string]$Noun = '', [switch]$Short)
    $pct = Get-GoalPercent -Done $Done -Total $Total
    $tone = if ($Total -gt 0 -and $Done -ge $Total) { 'good' } else { 'info' }
    $count = if ($Short) { [string]$Done + '/' + $Total + $(if ($Total -gt 0 -and $Done -ge $Total) { ' &#10003;' } else { '' }) }
             else { [string]$Done + ' of ' + $Total + $(if ($Noun) { ' ' + $Noun } else { '' }) }
    return '<span class="goal-progress__bar"><span class="meter meter--' + $tone + '" role="img" aria-label="' + $pct + '% done"><span style="width: ' + $pct + '%"></span></span>' +
        '<span class="num">' + $count + '</span></span>'
}

function Format-GoalsPageHtml {
    <#
        The Goals page from ConvertFrom-GoalsGraph's model (#3816), made for Admin's one 16:9 screen: per goal an h2
        with its progress, one prominent Now card, a short Next card, and the milestones collapsed, each with a
        progress bar and its tasks inside. -ReadError is why GitHub could not be read; -GeneratedAt when it was read.
        No goal is an empty state that says how to make one, never a blank page.
    #>
    param(
        [AllowNull()][object[]]$Model = $null,
        [AllowEmptyString()][string]$ReadError = '',
        [AllowEmptyString()][string]$GeneratedAt = '',
        [AllowEmptyString()][string]$RepoName = ''
    )
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $label = Get-GoalLabel
    $body = New-Object System.Text.StringBuilder
    if ($ReadError) {
        [void]$body.AppendLine('<p class="msg--warn" role="alert">The goals could not be read from GitHub: ' + (& $e $ReadError) + '.</p>')
    }
    $goals = @($Model | Where-Object { $_ })
    if ($null -ne $Model -and -not $goals.Count) {
        [void]$body.AppendLine((Format-AdminEmptyStateHtml -Title 'No goal yet' -Prompt 'plan a goal' -TextHtml (
            'A goal is an open issue labelled <code>' + (& $e $label) + '</code>; its milestones are its sub-issues, and their tasks are theirs. ' +
            'Ask Claude to plan one (the <code>plan-goal</code> skill): it asks a few questions, proposes the milestones and tasks, and files them once you agree.')))
    }
    # Per goal one card, as the Figma wireframes draw it (November 12, 2026): the goal and its progress, one prominent
    # Now box, a row of Next cards, and the milestones as rows, each with a bar and its tasks inside.
    foreach ($g in $goals) {
        [void]$body.AppendLine('<section class="card goal" id="goal-' + [int]$g.Number + '">')
        [void]$body.AppendLine('<div class="goal__head"><h2>' + (Format-GoalItemLink $g) + '</h2><span class="chip">' + (& $e $label) + '</span></div>')
        # The wireframes count milestones here ('2 of 5 milestones'): one is done once all its items are. The goal's own
        # Done and Total count items, so they are not the figure this line names.
        $ms = @($g.Milestones | Where-Object { $_ })
        $msDone = @($ms | Where-Object { [int]$_.Total -gt 0 -and [int]$_.Done -ge [int]$_.Total }).Count
        [void]$body.AppendLine('<div class="goal-progress">' + (Format-GoalProgressHtml -Done $msDone -Total $ms.Count -Noun 'milestones') + '</div>')
        # Now: the one step to take.
        [void]$body.Append('<div class="goal-now"><span class="goal-now__pill">Now</span>')
        if (-not @($g.Milestones).Count) {
            [void]$body.Append('<p class="goal-now__title">Break this goal down</p><p class="goal-now__sub">It has no milestone yet. Ask Claude to plan it (<code>plan-goal</code>).</p>')
        } elseif (-not $g.Now) {
            [void]$body.Append('<p class="goal-now__title">Every milestone is done</p><p class="goal-now__sub">Close the goal, or add the milestone that is still missing.</p>')
        } else {
            $n = $g.Now
            $title = if ($n.Unplanned) { 'Break down ' + (Format-GoalItemLink $n.Item) } else { Format-GoalItemLink $n.Item }
            $sub = if ($n.Unplanned) { 'This milestone has no task yet: plan its tasks first.' } else { 'Milestone: ' + (& $e $n.Milestone.Title) + ' &middot; the one step to take now' }
            if (@($n.Item.Assignees).Count) { $sub += ' &middot; claimed by ' + (& $e (@($n.Item.Assignees) -join ', ')) }
            [void]$body.Append('<p class="goal-now__title">' + $title + '</p><p class="goal-now__sub">' + $sub + '</p>')
        }
        [void]$body.AppendLine('</div>')
        # Next: a row of what follows, so the step after this one is never a question.
        if (@($g.Next).Count) {
            [void]$body.Append('<div class="goal-block"><h3>Next</h3><ul class="goal-next">')
            foreach ($s in @($g.Next)) {
                $t = if ($s.Unplanned) { 'Break down ' + (Format-GoalItemLink $s.Item) } else { Format-GoalItemLink $s.Item }
                $m = if ($s.Milestone -and -not $s.Unplanned) { '<span class="goal-next__meta">Milestone: ' + (& $e $s.Milestone.Title) + '</span>' } else { '' }
                [void]$body.Append('<li><span class="goal-next__title">' + $t + '</span>' + $m + '</li>')
            }
            [void]$body.AppendLine('</ul></div>')
        }
        # The milestones: a row each with a bar, the tasks inside.
        if (@($g.Milestones).Count) {
            [void]$body.Append('<div class="goal-block"><h3>Milestones</h3><div class="goal-milestones">')
            foreach ($m in @($g.Milestones)) {
                [void]$body.Append('<details class="goal-milestone"><summary><span class="goal-milestone__name">' + (& $e $m.Title) + '</span>' +
                    (Format-GoalProgressHtml -Done $m.Done -Total $m.Total -Short) + '</summary>')
                if (@($m.Tasks).Count) {
                    [void]$body.Append('<ul class="goal-steps">')
                    foreach ($t in @($m.Tasks)) {
                        $state = if ($t.Closed) { '<span class="badge badge--sm badge--good" aria-label="done">&#10003;</span>' } else { '<span class="badge badge--sm badge--neutral" aria-label="open"></span>' }
                        $cls = if ($t.Closed) { ' class="goal-steps__done"' } else { '' }
                        [void]$body.Append('<li>' + $state + '<span' + $cls + '>' + (Format-GoalItemLink $t) + '</span></li>')
                    }
                    [void]$body.Append('</ul>')
                } else {
                    [void]$body.Append('<p class="note">No task yet.</p>')
                }
                [void]$body.Append('</details>')
            }
            [void]$body.AppendLine('</div></div>')
        }
        [void]$body.AppendLine('</section>')
    }
    $when = if ($GeneratedAt) { ', read ' + (& $e $GeneratedAt) } else { '' }
    $whose = if ($RepoName) { 'The goals of <code>' + (& $e $RepoName) + '</code>' } else { 'This repo''s goals' }
    # The page header's one action (the wireframes' '+ Plan a goal'), shown once there is a goal: with none, the empty
    # state carries the same prompt.
    $aside = if ($goals.Count) { Format-AdminCopyPromptButton -Prompt 'plan a goal' -Label '+ Plan a goal' } else { '' }
    return Format-GeneralPageHtml -Title 'Goals' -Style ($script:GoalsPageStyle) -Body $body.ToString() -SiteName $RepoName -HeadAside $aside `
        -Lead ($whose + ': each broken into milestones and tasks, with the one step to take now.') `
        -FooterNote ('Read from GitHub: the open issues labelled <code>' + (& $e $label) + '</code> and their sub-issues, as the account <code>gh</code> is logged in as on this machine' + $when + ' (<a class="dp-link" href="/refresh?page=goals">read again</a>).')
}
