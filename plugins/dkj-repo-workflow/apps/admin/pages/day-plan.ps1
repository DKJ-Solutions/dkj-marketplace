<#
.SYNOPSIS
    The day plan (#3859): what the morning needs to plan the day, the plan written once the owner agrees, an item
    added during the day, and the day's and the week's close-out. The documented entry point is this plugin's
    day-plan skill (skills/day-plan/SKILL.md); the person behind it is Paula, the Project Planner.

.DESCRIPTION
      -Context                     the morning's input: the last planned day's carry-over, the measured pace (median merged
                                   PRs per working day over the last four weeks), the open issues assigned to the
                                   owner, and the open goals' Now and Next for this repo. Writes nothing.
      -PlanFile <path>             read a proposed plan (JSON, see ConvertTo-DayPlan), check it and the 6-8 h band,
                                   print it. Writes nothing.
      -PlanFile <path> -Apply      write it as today's day file. Refused outside the band unless -Override, and
                                   refused over a day already planned unless -Replace (its additions and
                                   overrides would be lost).
      -Add -Title <t> -Hours <h> -Mode plan|go [-Ref <r>]
                                   add an item to today's plan. Refused when it takes the day over 8 h, unless
                                   -Override.
      -Close [-Done 1,3]           match today's plan against the PRs merged and the issues closed today, write the
                                   close-out into the day file, print the receipt. -Done marks plan items (1-based)
                                   with no ref as done, since only the owner can say so. A second -Close keeps
                                   the first one's done items.
      -Week                        the week so far, from the day files and GitHub.
      -Status                      the Today page's model as JSON (#3860): the day file, its live match against
                                   GitHub, and the week's rows. Writes no day file; a GitHub failure is a field, not an exit.
                                   Where the day is shared it may stamp and start a background -Sync, and
                                   write this machine's id the first time.
      -Sync                        share the day across machines (#3924): fetch every machine's copy and publish this
                                   machine's day files, through refs/dayplan/<machine id> in the private repo
                                   DKJ_DAYPLAN_REPO names (dayplan-sync-lib.ps1). -Context, -Apply, -Add, -Close and
                                   -Week sync themselves; -Status reads the last fetch and starts this in the
                                   background when the last one is over five minutes old. Always exits 0.
      -SyncRemote <path>           the tests' own bare remote in place of DKJ_DAYPLAN_REPO's GitHub repo.
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
    [switch]$Replace,
    [switch]$Status,
    [switch]$Sync,
    [string]$SyncRemote = '',
    [string]$Override = '',
    [string[]]$Author = @(),
    [string]$Date = ''
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\dayplan-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\dayplan-sync-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\goals-lib.ps1')
. (Join-Path $PSScriptRoot '..\..\..\scripts\lib\ref-print-lib.ps1')
. (Join-Path $PSScriptRoot '..\..\..\scripts\lib\native-capture-lib.ps1')

$utf8 = New-Object System.Text.UTF8Encoding($false)

function Stop-DayPlan {
    param([string]$Message)
    # Stripped: a refusal can quote a plan title, a -Date or a path, which are somebody else's characters.
    Write-Host "[REFUSED] $(ConvertTo-ConsoleStrippedText $Message)"
    exit 1
}

$day = if ($Date) {
    $parsed = [datetime]::MinValue
    if (-not [datetime]::TryParseExact($Date, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, 'None', [ref]$parsed)) { Stop-DayPlan "-Date '$Date' is not yyyy-MM-dd." }
    $parsed
} else { (Get-Date).Date }

$modes = @($Context, [bool]$PlanFile, $Add, $Close, $Week, $Status, $Sync) | Where-Object { $_ }
if (@($modes).Count -ne 1) { Stop-DayPlan 'name exactly one of -Context, -PlanFile, -Add, -Close, -Week, -Status or -Sync.' }
if ($SyncRemote -and ($SyncRemote.StartsWith('-') -or -not (Test-Path -LiteralPath $SyncRemote -PathType Container))) { Stop-DayPlan '-SyncRemote names no directory; it is a bare remote of the tests'' own, never a URL.' }

# ---- the shared copy (#3924) -----------------------------------------------------------------------------------
$script:ShareRepo = if ($SyncRemote) { '' } else { Get-DayPlanShareRepo }
$script:ShareOn = [bool]($SyncRemote -or $script:ShareRepo)
$script:ShareNote = if ($script:ShareOn) { 'not synced in this run' } else { 'not shared: DKJ_DAYPLAN_REPO is not set' }
$script:SharedCopies = $null
function Write-DayPlanSyncStamp {
    <# The moment a sync was started, which Test-StopwatchSyncDue reads to hold the next one back. #>
    $dir = Get-DayPlanDir
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
    [System.IO.File]::WriteAllText((Join-Path $dir 'sync.stamp'), (Format-DayPlanInstant ([datetime]::UtcNow)))
}
function Sync-DayPlanShared {
    <# Fetches and/or publishes through the home repo, and keeps the outcome as the run's note and in sync.log beside the day files. #>
    param([switch]$Fetch, [switch]$Publish)
    if (-not $script:ShareOn) { return }
    $dir = Get-DayPlanDir
    # Never fatal: the day file is already written when this runs after -Add or -Close (Victor, #3924).
    try { Write-DayPlanSyncStamp } catch { }
    $r = Invoke-DayPlanSync -Repo $script:ShareRepo -Url $SyncRemote -GitDir (Get-DayPlanSyncGitDir) -MachineId (Get-DayPlanMachineId) `
        -LocalDays $(if ($Publish) { Get-DayPlanLocalDays } else { @{} }) -Fetch:$Fetch -Publish:$Publish
    $script:ShareNote = $r.Note
    $script:SharedCopies = $null
    try { [System.IO.File]::WriteAllText((Join-Path $dir 'sync.log'), ((Format-DayPlanInstant ([datetime]::UtcNow)) + ' ' + $r.Note)) } catch { }
}
function Get-SharedCopiesFor {
    <# The other machines' copies of one day, from the last fetch (no network). #>
    param([datetime]$On)
    if (-not $script:ShareOn) { return @() }
    if ($null -eq $script:SharedCopies) { $script:SharedCopies = (Read-DayPlanSharedCopies -GitDir (Get-DayPlanSyncGitDir) -MachineId (Get-DayPlanMachineId)).Days }
    return @($script:SharedCopies[$On.ToString('yyyy-MM-dd')] | Where-Object { $_ })
}

function Write-SafeLines {
    <# Multi-line text to the console, each line stripped on its own: the strip removes control characters, newlines among them. #>
    param([string]$Text)
    foreach ($l in ($Text -split "`r?`n")) { Write-Host (ConvertTo-ConsoleStrippedText $l) }
}
function Read-DayFile {
    <# The day as every machine has it (#3924): this machine's day file merged with the other machines' copies from the last fetch. -Lenient skips a local file that does not parse. #>
    param([datetime]$On, [switch]$Lenient)
    $p = Get-DayPlanPath -Date $On
    $local = $null
    if (Test-Path -LiteralPath $p -PathType Leaf) {
        # A file that does not parse is refused rather than read as no plan: -Apply would otherwise overwrite it.
        try { $local = [System.IO.File]::ReadAllText($p, $utf8) | ConvertFrom-Json }
        catch { if (-not $Lenient) { Stop-DayPlan "the day file $(Get-DisplayPath $p) does not parse; repair or remove it first." } }
    }
    return (Merge-DayPlanCopies -Copies (@($local) + @(Get-SharedCopiesFor -On $On)))
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
    <#
        Finished work since -From by every author: merged PRs they authored (through GraphQL, so each carries the
        issues it closed), and closed issues assigned to them.
    #>
    param([datetime]$From, [string[]]$Authors, [int]$Limit = 200)
    $stamp = Get-SinceStamp -From $From
    $since = '>=' + $stamp
    $fields = 'number,title,url,repository,closedAt'
    $prs = @(); $issues = @()
    foreach ($a in $Authors) {
        # GitHub's search stops at 1000 results; the pages stop there or at -Limit, whichever comes first.
        $q = "author:$a is:pr is:merged merged:>=$stamp"
        $after = $null
        $read = 0
        do {
            $ghArgs = @('api', 'graphql', '-f', ('query=' + (Get-DayPlanPrQuery)), '-f', ('q=' + $q))
            if ($after) { $ghArgs += @('-f', ('after=' + $after)) }
            # -Utf8: gh writes UTF-8, and a plain & would decode it through the console code page, turning an
            # accented title or an emoji into the wrong characters before it ever reaches a plan (Victor, #3860).
            $res = Invoke-NativeCapture -FilePath 'gh' -Arguments $ghArgs -Utf8 -DiscardStderr
            if ($res.ExitCode -ne 0) { throw "gh api graphql exited $($res.ExitCode) reading the PRs of $a" }
            $page = (@($res.Output) -join "`n") | ConvertFrom-Json
            $nodes = @($page.data.search.nodes | Where-Object { $_ -and $_.number })
            $prs += @(ConvertFrom-DayPlanSearch -Json (ConvertTo-Json -InputObject @($nodes) -Depth 6) -Kind 'pr')
            $read += $nodes.Count
            $after = if ($page.data.search.pageInfo.hasNextPage) { [string]$page.data.search.pageInfo.endCursor } else { $null }
        } while ($after -and $read -lt $Limit)
        $res = Invoke-NativeCapture -FilePath 'gh' -Arguments @('search', 'issues', '--assignee', $a, '--closed', $since, '--json', $fields, '--limit', [string]$Limit) -Utf8 -DiscardStderr
        if ($res.ExitCode -ne 0) { throw "gh search issues exited $($res.ExitCode) for $a" }
        $issues += @(ConvertFrom-DayPlanSearch -Json (@($res.Output) -join "`n") -Kind 'issue')
    }
    $prs = @($prs | Sort-Object ref -Unique)
    $issues = @($issues | Sort-Object ref -Unique)
    return @{ Prs = $prs; Issues = $issues }
}

function Select-DayPlanDay {
    <# A past day keeps only what finished on that day itself; the search reads from its start with no end. #>
    param($Found, [datetime]$On)
    if ($On -ge (Get-Date).Date) { return $Found }
    $end = $On.AddDays(1)
    $inDay = { param($x) $x.closedAt -and ([datetime]$x.closedAt) -lt $end }
    return @{ Prs = @($Found.Prs | Where-Object { & $inDay $_ }); Issues = @($Found.Issues | Where-Object { & $inDay $_ }) }
}

if (-not (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue) -and ($Context -or $Close -or $Week)) {
    Stop-DayPlan 'gh was not found on the PATH.'
}

# ---- the shared copy, on its own -------------------------------------------------------------------------------
if ($Sync) {
    Sync-DayPlanShared -Fetch -Publish
    Write-Host "Day plan: $(ConvertTo-ConsoleStrippedText $script:ShareNote)"
    exit 0
}

# Every mode but -Status reads what the other machines have before it reads or writes the day; -Status stays off the
# network, because a page load waits on it, and so does a plan only checked, not applied.
if (-not $Status -and -not ($PlanFile -and -not $Apply)) { Sync-DayPlanShared -Fetch -Publish:([bool]$Context) }

# ---- the morning's input -------------------------------------------------------------------------------------
if ($Context) {
    $authors = Get-DayPlanAuthors
    Write-Host "Shared: $(ConvertTo-ConsoleStrippedText $script:ShareNote)"
    Write-Host "Day plan for $($day.ToString('dddd yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)) -- counting the work of: $((@($authors) | ForEach-Object { Get-DisplayRef $_ }) -join ', ')"
    Write-Host ''

    $prev = $null
    for ($back = 1; $back -le 7 -and -not $prev; $back++) { $prev = Read-DayFile -On $day.AddDays(-$back); if ($prev) { $prevDate = $day.AddDays(-$back) } }
    if ($prev) {
        $carry = @(Get-DayPlanCarryOver -Day $prev)
        $closedWord = if ($prev.close) { 'closed' } else { 'never closed, so every item counts' }
        Write-Host "Carried over from $($prevDate.ToString('ddd yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)) ($closedWord): $($carry.Count)"
        foreach ($c in $carry) { Write-Host "  - $(ConvertTo-ConsoleStrippedText $c.title) ($(Format-DayPlanHours $c.hours), $(ConvertTo-ConsoleStrippedText $c.mode))$(if ($c.ref) { '  ' + (ConvertTo-ConsoleStrippedText $c.ref) })" }
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
            $median = ([double]$cap.Median).ToString('0.#', [System.Globalization.CultureInfo]::InvariantCulture)
            Write-Host "Pace: a median of $median merged PR(s) per working day over the last $($cap.Days) working days ($(@($found.Prs).Count) PRs, $(@($found.Issues).Count) issues closed)."
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
        # Under 'Stop' a native stderr line throws through 2>$null in Windows PowerShell 5.1, so the read is wrapped:
        # goals that cannot be read are left out of the morning's input rather than ending it.
        try { $raw = gh api graphql -f ('query=' + (Get-GoalsGraphQuery)) -f ('owner=' + $owner) -f ('name=' + $name) -f ('label=' + (Get-GoalLabel)) 2>$null; $goalsOk = ($LASTEXITCODE -eq 0) } catch { $goalsOk = $false }
        if ($goalsOk) {
            $goals = @(ConvertFrom-GoalsGraph -Data (($raw -join "`n") | ConvertFrom-Json) | Where-Object { $_ })
            if ($goals.Count) { Write-Host "Goals in ${repo}:"; foreach ($g in $goals) { Write-SafeLines (Format-GoalFocusText -Goal $g); Write-Host '' } }
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
    if ($existing -and -not $Replace) { Stop-DayPlan "$($day.ToString('yyyy-MM-dd')) is already planned. Add to it with -Add, or give -Replace to start the day over (its additions and overrides are dropped)." }
    # The moment it was planned: the merge's base is the newest plan, so a -Replace on any machine wins (#3924).
    $dayObj | Add-Member -NotePropertyName planned -NotePropertyValue (Format-DayPlanInstant ([datetime]::UtcNow)) -Force
    $p = Save-DayFile -Day $dayObj -On $day
    Sync-DayPlanShared -Publish
    $why = if ($b.Verdict -ne 'ok') { "Written on an override: $(ConvertTo-ConsoleStrippedText $Override.Trim())" } else { $b.Message }
    Write-Host "[OK] the plan for $($day.ToString('yyyy-MM-dd')) is written ($(Get-DisplayPath $p)). $why"
    Write-Host "Shared: $(ConvertTo-ConsoleStrippedText $script:ShareNote)"
    exit 0
}

# ---- an item added during the day ------------------------------------------------------------------------------
if ($Add) {
    $existing = Read-DayFile -On $day
    if (-not $existing) { Stop-DayPlan "there is no plan for $($day.ToString('yyyy-MM-dd')) yet; plan the day first." }
    if ($existing.close) { Stop-DayPlan "$($day.ToString('yyyy-MM-dd')) is already closed." }
    $repo = ''
    if ($Ref -match '\A#?\d+\z') {
        if (-not (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue)) { Stop-DayPlan "-Ref '$Ref' needs gh to name this repo, and gh was not found on the PATH; give owner/repo#n instead." }
        $repo = Get-CurrentRepo
    }
    $it = ConvertTo-DayPlanItem -Raw ([pscustomobject]@{ title = $Title; hours = $Hours; mode = $Mode; ref = $Ref; added = $true }) -Repo $repo -Index (@($existing.items).Count + 1)
    if ($it -is [string]) { Stop-DayPlan $it }
    # When it was added: another machine's merge takes an added item only when it is newer than the plan (#3924).
    $it | Add-Member -NotePropertyName addedAt -NotePropertyValue (Format-DayPlanInstant ([datetime]::UtcNow))
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
    Sync-DayPlanShared -Publish
    Write-SafeLines (Format-DayPlanText -Day $existing)
    Write-Host ''
    $why = if ($b.Verdict -eq 'over') { "Added on an override: $(ConvertTo-ConsoleStrippedText $Override.Trim())" } else { $b.Message }
    Write-Host "[OK] added. $why"
    Write-Host "Shared: $(ConvertTo-ConsoleStrippedText $script:ShareNote)"
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
    $found = Select-DayPlanDay -Found $found -On $day
    $finished = @($found.Prs) + @($found.Issues)
    # A second close keeps the first one's done items, so a -Done given then is not lost now (Victor, #3859).
    $marked = @(@($Done | ForEach-Object { $_ - 1 }) + @($(if ($existing.close) { @($existing.close.done) })) | Where-Object { $null -ne $_ } | ForEach-Object { [int]$_ } | Select-Object -Unique)
    $cmp = Compare-DayPlanDone -Items $existing.items -Finished $finished -MarkedDone $marked
    $closeRec = [pscustomobject]@{
        at = (Get-Date).ToString('o'); done = @($cmp.Done); carried = @($cmp.Carried)
        unplanned = @($cmp.Unplanned | ForEach-Object { [pscustomobject]@{ ref = $_.ref; title = $_.title; url = $_.url; kind = $_.kind } })
        prs = @($found.Prs).Count; issues = @($found.Issues).Count; verdict = $cmp.Verdict
    }
    $existing | Add-Member -NotePropertyName close -NotePropertyValue $closeRec -Force
    [void](Save-DayFile -Day $existing -On $day)
    Sync-DayPlanShared -Publish
    Write-SafeLines (Format-DayCloseText -Day $existing)
    Write-Host "Shared: $(ConvertTo-ConsoleStrippedText $script:ShareNote)"
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

# ---- the Today page's model ------------------------------------------------------------------------------------
if ($Status) {
    $existing = Read-DayFile -On $day
    $live = $null
    $readError = ''
    if ($existing) {
        try {
            if (-not (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue)) { throw 'gh was not found on the PATH' }
            $authors = Get-DayPlanAuthors
            if (-not @($authors).Count) { throw 'no author to count the work of' }
            $found = Select-DayPlanDay -Found (Invoke-DayPlanSearch -From $day -Authors $authors) -On $day
            $marked = @($(if ($existing.close) { @($existing.close.done) }) | Where-Object { $null -ne $_ } | ForEach-Object { [int]$_ })
            $cmp = Compare-DayPlanDone -Items $existing.items -Finished (@($found.Prs) + @($found.Issues)) -MarkedDone $marked
            $live = [pscustomobject]@{
                done = @($cmp.Done); carried = @($cmp.Carried); verdict = $cmp.Verdict
                unplanned = @($cmp.Unplanned | ForEach-Object { [pscustomobject]@{ ref = $_.ref; title = $_.title; url = $_.url; kind = $_.kind } })
                prs = @($found.Prs).Count; issues = @($found.Issues).Count
            }
        } catch {
            $readError = ([string]$_.Exception.Message) -replace '\s+', ' '
        }
    }
    $days = @{}
    $offset = (([int]$day.DayOfWeek) + 6) % 7
    $monday = $day.AddDays(-$offset)
    for ($d = 0; $d -lt 7; $d++) {
        $on = $monday.AddDays($d)
        # The week reads past a broken day file instead of refusing the page: only today's has to parse.
        $f = Read-DayFile -On $on -Lenient
        if ($f) { $days[$on.ToString('yyyy-MM-dd')] = $f }
    }
    $wk = Get-DayPlanWeek -Date $day -Days $days
    $rows = @($wk.Rows | ForEach-Object { [pscustomobject]@{ date = $_.Date.ToString('yyyy-MM-dd'); goal = $_.Goal; planned = $_.Planned; done = $_.Done; extra = $_.Extra; verdict = $_.Verdict; closed = $_.Closed } })
    # The shared copy (#3924): this run stays off the network, so it names what the last sync said and starts the
    # next one in the background once the last is older than the interval. Nothing waits on it.
    $shared = $script:ShareNote
    if ($script:ShareOn) {
        $dir = Get-DayPlanDir
        $logPath = Join-Path $dir 'sync.log'
        $shared = if (Test-Path -LiteralPath $logPath -PathType Leaf) { (([System.IO.File]::ReadAllText($logPath)).Trim() -replace '\A\S+\s+', '') } else { 'not synced yet' }
        if (Test-StopwatchSyncDue -StampPath (Join-Path $dir 'sync.stamp') -Minutes $script:DayPlanSyncIntervalMinutes) {
            $syncArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $PSCommandPath + '"'), '-Sync')
            if ($SyncRemote) { $syncArgs += @('-SyncRemote', ('"' + $SyncRemote + '"')) }
            # Stamped HERE, before the child starts, so the page loads in the second it takes to start do not each
            # start another one (Victor and Sebastian, #3924).
            try { Write-DayPlanSyncStamp; Start-Process -FilePath 'powershell.exe' -WindowStyle Hidden -ArgumentList $syncArgs | Out-Null } catch { }
        }
    }
    $model = [pscustomobject]@{ date = $day.ToString('yyyy-MM-dd'); day = $existing; live = $live; error = $readError; week = $rows; shared = $shared }
    # ConvertTo-Json writes non-ASCII raw, and a redirected Windows PowerShell writes its stdout in the console code page,
    # which Admin then reads as UTF-8 (Victor, #3860). So every character above ASCII is written as a JSON escape: the
    # line is pure ASCII, which every code page agrees on, and ConvertFrom-Json gives the characters back.
    $json = $model | ConvertTo-Json -Depth 8 -Compress
    $escape = ('\' + 'u') + '{0:x4}'
    Write-Output ([regex]::Replace($json, '[^\x00-\x7F]', { param($m) $escape -f [int][char]$m.Value }))
    exit 0
}
