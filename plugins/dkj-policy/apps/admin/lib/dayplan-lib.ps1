<#
.SYNOPSIS
    The day plan (#3859): the morning plan Paula proposes and the owner agrees, the bound that keeps a day between
    a full one and too much, and the close-out that matches the plan against what GitHub says got done.

.DESCRIPTION
    WHY IT EXISTS (Dave, November 7, 2026). Every session ends cleanly, but nothing adds those endings up, so the
    work never feels finished. The morning makes the day's goal explicit before anything is built; the close-out
    says what got done, what moves to tomorrow, and that the day can be closed.

    THE DAY FILE. One JSON file per day, <yyyy-MM-dd>.json under Get-DayPlanDir, per machine (the day is the
    person's, not a repo's, so it is not kept per repo):

        { "date": "2026-11-07", "goal": "...",
          "items": [ { "title": "...", "hours": 2, "mode": "plan", "ref": "owner/repo#123", "added": false } ],
          "notToday": [ "..." ],
          "overrides": [ { "at": "start|add", "reason": "..." } ],
          "close": { "at": "...", "done": [0,2], "carried": [1], "unplanned": [ {ref,title,url,kind} ],
                     "prs": 3, "issues": 2, "verdict": "reached|partly|missed" } }

    THE BOUND IS STRICT BOTH WAYS (Dave, November 7, 2026): the day budget is 8 hours, and a plan under 6 is not a
    full day. Test-DayPlanBudget answers which side a plan is on; the script refuses outside the band unless the
    owner gives a reason, which is stored and printed again at the close-out.

    Pure: no gh, no git, no clock except where a date is passed in. Pure ASCII (repo convention for .ps1).
    Tested by scripts/tests/dayplan.tests.ps1 in the source repo.
#>

$script:DayPlanBudgetHours = 8
$script:DayPlanMinHours = 6
$script:DayPlanMaxItems = 12
$script:DayPlanModes = @('plan', 'go')

function Get-DayPlanDir {
    <# The machine's folder for day files: DKJ_ADMIN_STATE_DIR where set (the tests), else %LOCALAPPDATA%\dkj-admin, then dayplan. #>
    $base = if ($env:DKJ_ADMIN_STATE_DIR) { $env:DKJ_ADMIN_STATE_DIR }
            elseif ($env:LOCALAPPDATA) { Join-Path $env:LOCALAPPDATA 'dkj-admin' }
            else { Join-Path ([System.IO.Path]::GetTempPath()) 'dkj-admin' }
    return (Join-Path $base 'dayplan')
}

function Get-DayPlanPath {
    param([datetime]$Date)
    return (Join-Path (Get-DayPlanDir) ($Date.ToString('yyyy-MM-dd') + '.json'))
}

function ConvertTo-DayPlanRef {
    <#
        A plan item's reference as 'owner/repo#n', or '' for none. Takes 'owner/repo#n', '#n' or 'n' (both resolved
        against -Repo), or an issue/PR URL. Anything else is $null, which the caller reports as an error.
    #>
    param([string]$Ref, [string]$Repo = '')
    $r = ([string]$Ref).Trim()
    if (-not $r) { return '' }
    # A ref is printable ASCII without a space ('!' to '~'), so a control or format character never passes as one.
    if ($r -match '[^!-~]') { return $null }
    if ($r -match '\Ahttps://github\.com/([^/\s]+/[^/\s]+)/(?:issues|pull)/(\d+)\z') { return "$($Matches[1])#$($Matches[2])" }
    if ($r -match '\A([^/\s#]+/[^/\s#]+)#(\d+)\z') { return "$($Matches[1])#$($Matches[2])" }
    if ($r -match '\A#?(\d+)\z' -and $Repo) { return "$Repo#$($Matches[1])" }
    return $null
}

function ConvertTo-DayPlanItem {
    <# One item as the day file keeps it, or a string saying why it cannot be. #>
    param($Raw, [string]$Repo = '', [int]$Index = 0)
    $title = ([string]$Raw.title).Trim()
    if (-not $title) { return "item $Index has no title" }
    $hours = 0.0
    # NaN and Infinity parse as doubles, and every comparison with NaN is false, so a 'NaN' estimate would pass both
    # bounds below and then make the whole plan read as inside the band (Victor, #3859). Refused by name first.
    if (-not [double]::TryParse([string]$Raw.hours, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$hours) -or [double]::IsNaN($hours) -or [double]::IsInfinity($hours) -or $hours -le 0 -or $hours -gt $script:DayPlanBudgetHours) {
        return "item $Index ('$title') needs an hour estimate above 0 and at most $($script:DayPlanBudgetHours)"
    }
    $mode = ([string]$Raw.mode).Trim().ToLowerInvariant()
    if ($script:DayPlanModes -notcontains $mode) { return "item $Index ('$title') needs a mode: 'plan' (plan mode first) or 'go'" }
    $ref = ConvertTo-DayPlanRef -Ref ([string]$Raw.ref) -Repo $Repo
    if ($null -eq $ref) { return "item $Index ('$title') has a ref that is not owner/repo#n, #n or an issue URL" }
    return [pscustomobject]@{ title = $title; hours = $hours; mode = $mode; ref = $ref; added = [bool]$Raw.added }
}

function ConvertTo-DayPlan {
    <#
        Read a proposed plan from JSON: { goal, items: [ {title, hours, mode, ref?} ], notToday: [string] }.
        Returns @{ Plan; Error }: Plan is the day file's shape (without date and close), Error a sentence or ''.
    #>
    param([string]$Json, [string]$Repo = '')
    try { $raw = $Json | ConvertFrom-Json } catch { return @{ Plan = $null; Error = 'the plan is not valid JSON' } }
    if ($null -eq $raw) { return @{ Plan = $null; Error = 'the plan is empty' } }
    $goal = ([string]$raw.goal).Trim()
    if (-not $goal) { return @{ Plan = $null; Error = 'the plan has no goal for the day' } }
    $rawItems = @($raw.items | Where-Object { $null -ne $_ })
    if (-not $rawItems.Count) { return @{ Plan = $null; Error = 'the plan has no items' } }
    if ($rawItems.Count -gt $script:DayPlanMaxItems) { return @{ Plan = $null; Error = "the plan has $($rawItems.Count) items; more than $($script:DayPlanMaxItems) is not a day" } }
    $items = @()
    $i = 0
    foreach ($r in $rawItems) {
        $i++
        $it = ConvertTo-DayPlanItem -Raw $r -Repo $Repo -Index $i
        if ($it -is [string]) { return @{ Plan = $null; Error = $it } }
        $items += $it
    }
    $notToday = @($raw.notToday | ForEach-Object { ([string]$_).Trim() } | Where-Object { $_ })
    return @{ Plan = [pscustomobject]@{ goal = $goal; items = $items; notToday = $notToday; overrides = @() }; Error = '' }
}

function Get-DayPlanHours {
    param($Items)
    $sum = 0.0
    foreach ($it in @($Items)) { if ($it) { $sum += [double]$it.hours } }
    return $sum
}

function Test-DayPlanBudget {
    <#
        Which side of the band a set of items is on: @{ Hours; Verdict = 'under' | 'ok' | 'over'; Message }.
        Under 6 hours is not a full day; over 8 is too much. The message is what the script prints when it refuses.
    #>
    param($Items)
    $h = Get-DayPlanHours -Items $Items
    $hs = $h.ToString('0.#', [System.Globalization.CultureInfo]::InvariantCulture)
    if ($h -lt $script:DayPlanMinHours) {
        return @{ Hours = $h; Verdict = 'under'; Message = "the plan holds $hs h, which is not a full day (at least $($script:DayPlanMinHours) of $($script:DayPlanBudgetHours) h). Add what the day is missing, or give -Override with the reason it is a short day." }
    }
    if ($h -gt $script:DayPlanBudgetHours) {
        $over = ($h - $script:DayPlanBudgetHours).ToString('0.#', [System.Globalization.CultureInfo]::InvariantCulture)
        return @{ Hours = $h; Verdict = 'over'; Message = "the plan holds $hs h, $over h over the $($script:DayPlanBudgetHours) h day. Move something to 'not today', or give -Override with the reason this day can take it." }
    }
    return @{ Hours = $h; Verdict = 'ok'; Message = "the plan holds $hs of $($script:DayPlanBudgetHours) h." }
}

function Get-DayPlanMedian {
    <# The median of a list of numbers, 0 for none. #>
    param([double[]]$Values)
    $v = @($Values | Sort-Object)
    if (-not $v.Count) { return 0 }
    $mid = [int][math]::Floor($v.Count / 2)
    if ($v.Count % 2) { return [double]$v[$mid] }
    return ([double]$v[$mid - 1] + [double]$v[$mid]) / 2
}

function Get-DayPlanCapacity {
    <#
        The measured pace: the median number of merged PRs per working day (Monday to Friday) over the working days
        between -From and -To (both dates, -To exclusive), from a list of merge moments. Days with none count as 0,
        which is what makes it a median of the days rather than of the busy ones.
    #>
    param([datetime[]]$MergedAt, [datetime]$From, [datetime]$To)
    $counts = @{}
    foreach ($m in @($MergedAt)) { $k = $m.Date.ToString('yyyy-MM-dd'); $counts[$k] = 1 + [int]$counts[$k] }
    $perDay = @()
    for ($d = $From.Date; $d -lt $To.Date; $d = $d.AddDays(1)) {
        if ($d.DayOfWeek -eq 'Saturday' -or $d.DayOfWeek -eq 'Sunday') { continue }
        $perDay += [double][int]$counts[$d.ToString('yyyy-MM-dd')]
    }
    return [pscustomobject]@{ Median = (Get-DayPlanMedian -Values $perDay); Days = $perDay.Count }
}

function ConvertFrom-DayPlanSearch {
    <#
        gh's JSON for finished work as done records: @{ ref; title; url; kind; closedAt; closes }. Takes gh search's
        answer (fields number,title,url,repository,closedAt) and the PR nodes of Get-DayPlanPrQuery, whose
        closingIssuesReferences become `closes`: the issue refs a merged PR closed, so the close-out can tell a PR that
        finished a planned issue from extra work. -Kind is 'pr' or 'issue'. Deduplicated on ref.
        closedAt is a LOCAL DateTime (or $null): Windows PowerShell 5.1's ConvertFrom-Json leaves an ISO stamp a
        string and PowerShell 7 turns it into a DateTime, so both are normalised here rather than by each caller.
    #>
    param([string]$Json, [string]$Kind)
    if (-not $Json -or -not $Json.Trim()) { return @() }
    $seen = @{}
    $out = @()
    # Assigned first: in Windows PowerShell 5.1 ConvertFrom-Json emits a JSON array as ONE object.
    $parsed = $Json | ConvertFrom-Json
    foreach ($n in @($parsed)) {
        if ($null -eq $n) { continue }
        $repo = [string]$n.repository.nameWithOwner
        if (-not $repo -and $n.url -match '\Ahttps://github\.com/([^/]+/[^/]+)/') { $repo = $Matches[1] }
        $ref = "$repo#$($n.number)"
        if ($seen[$ref]) { continue }
        $seen[$ref] = $true
        $at = $null
        if ($n.closedAt -is [datetime]) { $at = $n.closedAt.ToLocalTime() }
        elseif ($n.closedAt) {
            $o = [DateTimeOffset]::MinValue
            if ([DateTimeOffset]::TryParse([string]$n.closedAt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref]$o)) { $at = $o.LocalDateTime }
        }
        $closes = @(@($n.closingIssuesReferences.nodes) | Where-Object { $_ } | ForEach-Object {
            $cr = [string]$_.repository.nameWithOwner; if (-not $cr) { $cr = $repo }; "$cr#$($_.number)" })
        $out += [pscustomobject]@{ ref = $ref; title = [string]$n.title; url = [string]$n.url; kind = $Kind; closedAt = $at; closes = $closes }
    }
    return $out
}

function Get-DayPlanPrQuery {
    <#
        The GraphQL search for one author's merged PRs since a moment, with the issues each one closed -- which gh
        search's JSON does not carry. Variables: $q (the search string), $after (the page cursor, may be null).
    #>
    return 'query($q: String!, $after: String) { search(query: $q, type: ISSUE, first: 100, after: $after) { pageInfo { hasNextPage endCursor } nodes { ... on PullRequest { number title url closedAt repository { nameWithOwner } closingIssuesReferences(first: 10) { nodes { number repository { nameWithOwner } } } } } } }'
}

function Compare-DayPlanDone {
    <#
        Match a day's items against what got done: @{ Done; Carried; Unplanned; Verdict }.
        Done and Carried are item indexes (0-based). An item is done when its ref is among -Finished, or a finished PR
        closed it, or its index is in -MarkedDone (an item with no ref, which only the owner can say is done).
        Unplanned is the finished work no item names, counted once: a PR that closed a planned issue is that item's
        work, and an issue a finished PR closed is that PR's, so the usual "PR fixes #n" pair is never two extras.
        Verdict: 'reached' when every item is done, 'partly' when some are, 'missed' when none are.
    #>
    param($Items, $Finished, [int[]]$MarkedDone = @())
    $items = @($Items)
    $refs = @{}; $closedByPr = @{}
    foreach ($f in @($Finished)) {
        if (-not $f) { continue }
        $refs[[string]$f.ref] = $true
        foreach ($c in @($f.closes)) { if ($c) { $refs[[string]$c] = $true; $closedByPr[[string]$c] = $true } }
    }
    $done = @(); $carried = @(); $named = @{}
    for ($i = 0; $i -lt $items.Count; $i++) {
        $r = [string]$items[$i].ref
        if ($r) { $named[$r] = $true }
        if (($r -and $refs[$r]) -or ($MarkedDone -contains $i)) { $done += $i } else { $carried += $i }
    }
    $unplanned = @(@($Finished) | Where-Object {
        $_ -and -not $named[[string]$_.ref] -and -not $closedByPr[[string]$_.ref] -and
        -not @(@($_.closes) | Where-Object { $_ -and $named[[string]$_] }).Count })
    $verdict = if ($items.Count -and $done.Count -eq $items.Count) { 'reached' } elseif ($done.Count) { 'partly' } else { 'missed' }
    return @{ Done = $done; Carried = $carried; Unplanned = $unplanned; Verdict = $verdict }
}

function Get-DayPlanCarryOver {
    <# The items a day file leaves for the next day: the close-out's carried ones, or every item when it was never closed. #>
    param($Day)
    if ($null -eq $Day) { return @() }
    $items = @($Day.items)
    if ($Day.close) { return @(@($Day.close.carried) | ForEach-Object { $items[[int]$_] } | Where-Object { $_ }) }
    return $items
}

function Format-DayPlanHours {
    param([double]$Hours)
    return ($Hours.ToString('0.#', [System.Globalization.CultureInfo]::InvariantCulture) + ' h')
}

function Format-DayPlanText {
    <# The plan as the console shows it at the start of the day and on -Add. #>
    param($Day)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("Day goal: $($Day.goal)")
    $i = 0
    foreach ($it in @($Day.items)) {
        $i++
        $mode = if ($it.mode -eq 'plan') { 'plan first' } else { 'go' }
        $ref = if ($it.ref) { "  $($it.ref)" } else { '' }
        $add = if ($it.added) { '  (added during the day)' } else { '' }
        $lines.Add(("  {0}. [{1}] {2} -- {3}{4}{5}" -f $i, $mode, $it.title, (Format-DayPlanHours $it.hours), $ref, $add))
    }
    $b = Test-DayPlanBudget -Items $Day.items
    $lines.Add("  Total: $(Format-DayPlanHours $b.Hours) of $($script:DayPlanBudgetHours) h")
    if (@($Day.notToday).Count) {
        $lines.Add('Not today:')
        foreach ($n in @($Day.notToday)) { $lines.Add("  - $n") }
    }
    foreach ($o in @($Day.overrides)) { if ($o) { $lines.Add("Override ($($o.at)): $($o.reason)") } }
    return ($lines -join "`n")
}

function Format-DayCloseText {
    <# The close-out receipt: what got done, what moves, and that the day can be closed. #>
    param($Day)
    $c = $Day.close
    $items = @($Day.items)
    $lines = New-Object System.Collections.Generic.List[string]
    $word = switch ($c.verdict) { 'reached' { 'reached' } 'partly' { 'partly reached' } default { 'not reached' } }
    $lines.Add("Day goal $word`: $($Day.goal)")
    foreach ($i in @($c.done)) { $lines.Add("  done     $($items[[int]$i].title)") }
    foreach ($i in @($c.carried)) { $lines.Add("  tomorrow $($items[[int]$i].title)") }
    foreach ($u in @($c.unplanned)) { $lines.Add("  extra    $($u.title)  $($u.ref)") }
    foreach ($o in @($Day.overrides)) { if ($o) { $lines.Add("  This day ran on an override ($($o.at)): $($o.reason)") } }
    $lines.Add('')
    $lines.Add(("Today: {0} of {1} planned done, {2} extra. {3} PR(s) merged, {4} issue(s) closed. {5} carried to tomorrow." -f @($c.done).Count, $items.Count, @($c.unplanned).Count, [int]$c.prs, [int]$c.issues, @($c.carried).Count))
    $lines.Add('You can close the day.')
    return ($lines -join "`n")
}

function Get-DayPlanWeek {
    <#
        The week of -Date (Monday to Sunday) as rows: @{ Date; Goal; Planned; Done; Verdict; Closed }, one per day that
        has a day file, read from -Days (a hashtable of 'yyyy-MM-dd' -> parsed day file).
    #>
    param([datetime]$Date, [hashtable]$Days)
    $offset = (([int]$Date.DayOfWeek) + 6) % 7
    $monday = $Date.Date.AddDays(-$offset)
    $rows = @()
    for ($d = 0; $d -lt 7; $d++) {
        $day = $monday.AddDays($d)
        $f = $Days[$day.ToString('yyyy-MM-dd')]
        if ($null -eq $f) { continue }
        $closed = $null -ne $f.close
        $rows += [pscustomobject]@{
            Date = $day; Goal = [string]$f.goal; Planned = @($f.items).Count
            Done = $(if ($closed) { @($f.close.done).Count } else { 0 })
            Extra = $(if ($closed) { @($f.close.unplanned).Count } else { 0 })
            Verdict = $(if ($closed) { [string]$f.close.verdict } else { 'open' }); Closed = $closed
        }
    }
    return [pscustomobject]@{ Monday = $monday; Rows = $rows }
}

function Format-DayPlanWeekText {
    param($Week, [int]$Prs = 0, [int]$Issues = 0)
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("Week of $($Week.Monday.ToString('yyyy-MM-dd'))")
    foreach ($r in @($Week.Rows)) {
        $state = if ($r.Closed) { "$($r.Done)/$($r.Planned) done, $($r.Extra) extra, goal $($r.Verdict)" } else { "$($r.Planned) planned, not closed" }
        $lines.Add(("  {0}  {1} -- {2}" -f $r.Date.ToString('ddd dd', [System.Globalization.CultureInfo]::InvariantCulture), $state, $r.Goal))
    }
    if (-not @($Week.Rows).Count) { $lines.Add('  No day was planned this week.') }
    $reached = @($Week.Rows | Where-Object { $_.Verdict -eq 'reached' }).Count
    $lines.Add('')
    $lines.Add("This week: $Prs PR(s) merged, $Issues issue(s) closed, the day goal reached on $reached of $(@($Week.Rows).Count) planned day(s).")
    $lines.Add('You can close the week.')
    return ($lines -join "`n")
}
