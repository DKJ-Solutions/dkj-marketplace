<#
.SYNOPSIS
    The day plan (#3859): what the morning needs to plan the day, the plan written once the owner agrees, an item
    added during the day, and the day's and the week's close-out. The documented entry point is this plugin's
    day-plan skill (skills/day-plan/SKILL.md); the person behind it is Paula, the Project Planner.

.DESCRIPTION
      -Context                     the morning's input: yesterday's carry-over, the measured pace (median merged
                                   PRs per working day over the last four weeks), the open issues assigned to the
                                   owner, and the open goals' Now and Next for this repo. Writes nothing.
      -PlanFile <path>             read a proposed plan (JSON, see ConvertTo-DayPlan), check it and the 6-8 h band,
                                   print it. Writes nothing.
      -PlanFile <path> -Apply      write it as today's day file. Refused outside the band unless -Override.
      -Add -Title <t> -Hours <h> -Mode plan|go [-Ref <r>]
                                   add an item to today's plan. Refused when it takes the day over 8 h, unless
                                   -Override.
      -Close [-Done 1,3]           match today's plan against the PRs merged and the issues closed today, write the
                                   close-out into the day file, print the receipt. -Done marks plan items (1-based)
                                   with no ref as done, since only the owner can say so.
      -Week                        the week so far, from the day files and GitHub.
      -Override <reason>           go past the band anyway; the reason is kept in the day file and printed again at
                                   the close-out.
      -Author <login,...>          whose work counts. Default: DKJ_DAYPLAN_AUTHORS (comma-separated), else the login
                                   gh acts as plus git's user.name. Both, because a checkout can act as one account
                                   and commit as another, and searching one would silently miss the other's work.
      -Date <yyyy-MM-dd>           the day to act on (default today).

    Exits 0 on success, 1 on a refusal or a failure. Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [switch]$Context,
    [string]$PlanFile = '',
    [switch]$Apply,
    [switch]$Add,
    [string]$Title = '',
    [double]$Hours = 0,
    [string]$Mode = '',
    [string]$Ref = '',
    [switch]$Close,
    [int[]]$Done = @(),
    [switch]$Week,
    [string]$Override = '',
    [string[]]$Author = @(),
    [string]$Date = ''
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\dayplan-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\goals-lib.ps1')
. (Join-Path $PSScriptRoot '..\..\scripts\lib\ref-print-lib.ps1')

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Stop-DayPlan {
    param([string]$Message)
    Write-Host "[REFUSED] $Message"
    exit 1
}

$day = if ($Date) {
    $parsed = [datetime]::MinValue
    if (-not [datetime]::TryParseExact($Date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, 'None', [ref]$parsed)) { Stop-DayPlan "-Date '$Date' is not yyyy-MM-dd." }
    $parsed
} else { (Get-Date).Date }

$modes = @($Context, [bool]$PlanFile, $Add, $Close, $Week) | Where-Object { $_ }
if (@($modes).Count -ne 1) { Stop-DayPlan 'name exactly one of -Context, -PlanFile, -Add, -Close or -Week.' }

function Write-SafeLines {
    <# Multi-line text to the console, each line stripped on its own: the strip removes control characters, newlines among them. #>
    param([string]$Text)
    foreach ($l in ($Text -split "`r?`n")) { Write-Host (ConvertTo-ConsoleStrippedText $l) }
}
function Read-DayFile {
    param([datetime]$On)
    $p = Get-DayPlanPath -Date $On
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { return $null }
    try { return ([System.IO.File]::ReadAllText($p, $utf8) | ConvertFrom-Json) } catch { return $null }
}
function Save-DayFile {
    param($Day, [datetime]$On)
    $dir = Get-DayPlanDir
    if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
    $p = Get-DayPlanPath -Date $On
    $tmp = "$p.tmp"
    [System.IO.File]::WriteAllText($tmp, ($Day | ConvertTo-Json -Depth 6), $utf8)
    Move-Item -LiteralPath $tmp -Destination $p -Force
    return $p
}
function Get-CurrentRepo {
    try { $r = [string](gh repo view --json nameWithOwner --jq .nameWithOwner 2>$null) } catch { $r = '' }
    return $r.Trim()
}
function Get-DayPlanAuthors {
    if (@($Author).Count) { return @($Author | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique) }
    if ($env:DKJ_DAYPLAN_AUTHORS) { return @($env:DKJ_DAYPLAN_AUTHORS -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique) }
    $list = @()
    try { $login = [string](gh api user --jq .login 2>$null) } catch { $login = '' }
    if ($login.Trim()) { $list += $login.Trim() }
    try { $name = [string](git config user.name 2>$null) } catch { $name = '' }
    # A git user.name is a login only when it could be one: no spaces, GitHub's own character set.
    if ($name.Trim() -match '\A[A-Za-z0-9](?:[A-Za-z0-9-]{0,38})\z') { $list += $name.Trim() }
    return @($list | Select-Object -Unique)
}
function Get-SinceStamp {
    param([datetime]$From)
    # Local midnight with its offset, so 'today' is the owner's day and not UTC's.
    return ([DateTimeOffset]$From.Date).ToString('yyyy-MM-ddTHH:mm:sszzz', [System.Globalization.CultureInfo]::InvariantCulture)
}
function Invoke-DayPlanSearch {
    <# Finished work since -From by every author: merged PRs they authored, closed issues assigned to them. #>
    param([datetime]$From, [string[]]$Authors, [int]$Limit = 200)
    $since = '>=' + (Get-SinceStamp -From $From)
    $fields = 'number,title,url,repository,closedAt'
    $prs = @(); $issues = @()
    foreach ($a in $Authors) {
        $p = gh search prs --author $a --merged-at $since --json $fields --limit $Limit
        if ($LASTEXITCODE -ne 0) { throw "gh search prs exited $LASTEXITCODE for $a" }
        $prs += @(ConvertFrom-DayPlanSearch -Json ($p -join "`n") -Kind 'pr')
        $i = gh search issues --assignee $a --closed $since --json $fields --limit $Limit
        if ($LASTEXITCODE -ne 0) { throw "gh search issues exited $LASTEXITCODE for $a" }
        $issues += @(ConvertFrom-DayPlanSearch -Json ($i -join "`n") -Kind 'issue')
    }
    $prs = @($prs | Sort-Object ref -Unique)
    $issues = @($issues | Sort-Object ref -Unique)
    return @{ Prs = $prs; Issues = $issues }
}

if (-not (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue) -and ($Context -or $Close -or $Week)) {
    Stop-DayPlan 'gh was not found on the PATH.'
}

# ---- the morning's input -------------------------------------------------------------------------------------
if ($Context) {
    $authors = Get-DayPlanAuthors
    Write-Host "Day plan for $($day.ToString('dddd yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)) -- counting the work of: $((@($authors) | ForEach-Object { Get-DisplayRef $_ }) -join ', ')"
    Write-Host ''

    $prev = $null
    for ($back = 1; $back -le 7 -and -not $prev; $back++) { $prev = Read-DayFile -On $day.AddDays(-$back); if ($prev) { $prevDate = $day.AddDays(-$back) } }
    if ($prev) {
        $carry = @(Get-DayPlanCarryOver -Day $prev)
        $closedWord = if ($prev.close) { 'closed' } else { 'never closed, so every item counts' }
        Write-Host "Carried over from $($prevDate.ToString('ddd yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)) ($closedWord): $($carry.Count)"
        foreach ($c in $carry) { Write-Host "  - $(ConvertTo-ConsoleStrippedText $c.title) ($(Format-DayPlanHours $c.hours), $($c.mode))$(if ($c.ref) { '  ' + $c.ref })" }
    } else {
        Write-Host 'Carried over: nothing -- no day file in the last week.'
    }
    Write-Host ''

    if (@($authors).Count) {
        try {
            $from = $day.AddDays(-28)
            $found = Invoke-DayPlanSearch -From $from -Authors $authors -Limit 1000
            $merged = @($found.Prs | Where-Object { $_.closedAt } | ForEach-Object { [datetime]$_.closedAt })
            $cap = Get-DayPlanCapacity -MergedAt $merged -From $from -To $day
            Write-Host ("Pace: a median of {0} merged PR(s) per working day over the last {1} working days ({2} PRs, {3} issues closed)." -f $cap.Median, $cap.Days, @($found.Prs).Count, @($found.Issues).Count)
        } catch {
            Write-Host "Pace: unknown -- $(ConvertTo-ConsoleStrippedText $_.Exception.Message)"
        }
        Write-Host ''
        Write-Host 'Open issues assigned:'
        $openSeen = @{}
        foreach ($a in $authors) {
            $o = gh search issues --assignee $a --state open --json number,title,url,repository,labels --limit 50
            if ($LASTEXITCODE -ne 0) { continue }
            # Assigned first: in Windows PowerShell 5.1 ConvertFrom-Json emits a JSON array as ONE object, so
            # @(... | ConvertFrom-Json) is a one-element list holding the whole array.
            $parsed = ($o -join "`n") | ConvertFrom-Json
            foreach ($n in @($parsed)) {
                $r = "$($n.repository.nameWithOwner)#$($n.number)"
                if ($openSeen[$r]) { continue }
                $openSeen[$r] = $true
                $prio = (@($n.labels | Where-Object { $_.name -match '\Aprio-\d\z' } | ForEach-Object { $_.name }) -join ',')
                Write-Host "  - $r  $(ConvertTo-ConsoleStrippedText $n.title)$(if ($prio) { "  [$prio]" })"
            }
        }
        if (-not $openSeen.Count) { Write-Host '  none' }
    }
    Write-Host ''

    $repo = Get-CurrentRepo
    if ($repo -match '\A([^/\s]+)/([^/\s]+)\z') {
        $owner = $Matches[1]; $name = $Matches[2]
        $raw = gh api graphql -f ('query=' + (Get-GoalsGraphQuery)) -f ('owner=' + $owner) -f ('name=' + $name) -f ('label=' + (Get-GoalLabel)) 2>$null
        if ($LASTEXITCODE -eq 0) {
            $goals = @(ConvertFrom-GoalsGraph -Data (($raw -join "`n") | ConvertFrom-Json) | Where-Object { $_ })
            if ($goals.Count) { Write-Host "Goals in ${repo}:"; foreach ($g in $goals) { Write-Host (Format-GoalFocusText -Goal $g); Write-Host '' } }
            else { Write-Host "Goals in ${repo}: none open." }
        }
    }
    Write-Host "The band: at least $($script:DayPlanMinHours) and at most $($script:DayPlanBudgetHours) planned hours."
    exit 0
}

# ---- the plan --------------------------------------------------------------------------------------------------
if ($PlanFile) {
    if (-not (Test-Path -LiteralPath $PlanFile -PathType Leaf)) { Stop-DayPlan "the plan file '$PlanFile' does not exist." }
    $repo = if (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue) { Get-CurrentRepo } else { '' }
    $read = ConvertTo-DayPlan -Json ([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $PlanFile).Path, $utf8)) -Repo $repo
    if ($read.Error) { Stop-DayPlan "the plan does not hold: $($read.Error)." }
    $plan = $read.Plan
    $b = Test-DayPlanBudget -Items $plan.items
    if ($b.Verdict -ne 'ok' -and $Override.Trim()) { $plan.overrides = @([pscustomobject]@{ at = 'start'; reason = $Override.Trim() }) }
    $dayObj = [pscustomobject]@{ date = $day.ToString('yyyy-MM-dd'); goal = $plan.goal; items = @($plan.items); notToday = @($plan.notToday); overrides = @($plan.overrides); close = $null }
    Write-SafeLines (Format-DayPlanText -Day $dayObj)
    Write-Host ''
    if ($b.Verdict -ne 'ok' -and -not $Override.Trim()) { Stop-DayPlan $b.Message }
    if (-not $Apply) { Write-Host "[OK] $($b.Message) Nothing was written; rerun with -Apply once it is agreed."; exit 0 }
    $existing = Read-DayFile -On $day
    if ($existing -and $existing.close) { Stop-DayPlan "$($day.ToString('yyyy-MM-dd')) is already closed; plan another -Date." }
    $p = Save-DayFile -Day $dayObj -On $day
    $why = if ($b.Verdict -ne 'ok') { "Written on an override: $(ConvertTo-ConsoleStrippedText $Override.Trim())" } else { $b.Message }
    Write-Host "[OK] the plan for $($day.ToString('yyyy-MM-dd')) is written ($(Get-DisplayPath $p)). $why"
    exit 0
}

# ---- an item added during the day ------------------------------------------------------------------------------
if ($Add) {
    $existing = Read-DayFile -On $day
    if (-not $existing) { Stop-DayPlan "there is no plan for $($day.ToString('yyyy-MM-dd')) yet; plan the day first." }
    if ($existing.close) { Stop-DayPlan "$($day.ToString('yyyy-MM-dd')) is already closed." }
    $repo = if ($Ref -match '\A#?\d+\z') { Get-CurrentRepo } else { '' }
    $it = ConvertTo-DayPlanItem -Raw ([pscustomobject]@{ title = $Title; hours = $Hours; mode = $Mode; ref = $Ref; added = $true }) -Repo $repo -Index (@($existing.items).Count + 1)
    if ($it -is [string]) { Stop-DayPlan $it }
    $items = @($existing.items) + $it
    $b = Test-DayPlanBudget -Items $items
    if ($b.Verdict -eq 'over' -and -not $Override.Trim()) {
        Write-SafeLines (Format-DayPlanText -Day $existing)
        Write-Host ''
        Stop-DayPlan "adding '$(ConvertTo-ConsoleStrippedText $it.title)' ($(Format-DayPlanHours $it.hours)) does not fit: $($b.Message)"
    }
    $overrides = @($existing.overrides | Where-Object { $_ })
    if ($b.Verdict -eq 'over') { $overrides += [pscustomobject]@{ at = 'add'; reason = $Override.Trim() } }
    $existing.items = $items
    $existing.overrides = $overrides
    $p = Save-DayFile -Day $existing -On $day
    Write-SafeLines (Format-DayPlanText -Day $existing)
    Write-Host ''
    $why = if ($b.Verdict -eq 'over') { "Added on an override: $(ConvertTo-ConsoleStrippedText $Override.Trim())" } else { $b.Message }
    Write-Host "[OK] added. $why"
    exit 0
}

# ---- the close-out ---------------------------------------------------------------------------------------------
if ($Close) {
    $existing = Read-DayFile -On $day
    if (-not $existing) { Stop-DayPlan "there is no plan for $($day.ToString('yyyy-MM-dd')) to close." }
    $authors = Get-DayPlanAuthors
    if (-not @($authors).Count) { Stop-DayPlan 'no author to count the work of: pass -Author, or set DKJ_DAYPLAN_AUTHORS.' }
    $count = @($existing.items).Count
    foreach ($n in $Done) { if ($n -lt 1 -or $n -gt $count) { Stop-DayPlan "-Done $n is not an item of today's plan (1..$count)." } }
    try { $found = Invoke-DayPlanSearch -From $day -Authors $authors } catch { Stop-DayPlan "GitHub could not be read: $(ConvertTo-ConsoleStrippedText $_.Exception.Message)" }
    if ($day -lt (Get-Date).Date) {
        # A past day: only what finished on that day itself.
        $end = $day.AddDays(1)
        $inDay = { param($x) $x.closedAt -and ([datetime]$x.closedAt) -lt $end }
        $found.Prs = @($found.Prs | Where-Object { & $inDay $_ }); $found.Issues = @($found.Issues | Where-Object { & $inDay $_ })
    }
    $finished = @($found.Prs) + @($found.Issues)
    $cmp = Compare-DayPlanDone -Items $existing.items -Finished $finished -MarkedDone @($Done | ForEach-Object { $_ - 1 })
    $closeRec = [pscustomobject]@{
        at = (Get-Date).ToString('o'); done = @($cmp.Done); carried = @($cmp.Carried)
        unplanned = @($cmp.Unplanned | ForEach-Object { [pscustomobject]@{ ref = $_.ref; title = $_.title; url = $_.url; kind = $_.kind } })
        prs = @($found.Prs).Count; issues = @($found.Issues).Count; verdict = $cmp.Verdict
    }
    $existing | Add-Member -NotePropertyName close -NotePropertyValue $closeRec -Force
    [void](Save-DayFile -Day $existing -On $day)
    Write-SafeLines (Format-DayCloseText -Day $existing)
    exit 0
}

# ---- the week --------------------------------------------------------------------------------------------------
if ($Week) {
    $days = @{}
    $offset = (([int]$day.DayOfWeek) + 6) % 7
    $monday = $day.AddDays(-$offset)
    for ($d = 0; $d -lt 7; $d++) { $f = Read-DayFile -On $monday.AddDays($d); if ($f) { $days[$monday.AddDays($d).ToString('yyyy-MM-dd')] = $f } }
    $wk = Get-DayPlanWeek -Date $day -Days $days
    $prs = 0; $issues = 0
    $authors = Get-DayPlanAuthors
    if (@($authors).Count) {
        try { $found = Invoke-DayPlanSearch -From $monday -Authors $authors -Limit 500; $prs = @($found.Prs).Count; $issues = @($found.Issues).Count }
        catch { Write-Host "[note] GitHub could not be read; the totals below count 0." }
    }
    Write-SafeLines (Format-DayPlanWeekText -Week $wk -Prs $prs -Issues $issues)
    exit 0
}
