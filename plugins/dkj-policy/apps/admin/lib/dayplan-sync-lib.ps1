<#
.SYNOPSIS
    The day plan's shared copy (#3924): every machine publishes its recent day files to a ref of its own,
    refs/dayplan/<machine id>, in ONE private repo the owner names, and every reader merges all machines' copies of a
    day, so a plan made in the morning on one machine is the plan on every other.

.DESCRIPTION
    WHY (Dave, November 9, 2026). The owner works on several machines at once. With a day file per machine only
    (#3859), a plan made on machine A did not exist on machine B: -Add on B refused, /dev/today on B was empty, and
    -Close on either machine saw half the day.

    THE SAME PLUMBING AS THE STOPWATCH (stopwatch-sync-lib.ps1, #3349): a ref per machine, written with git plumbing
    alone, so two machines never write the same ref and every push is a fast-forward; origin's refs are fetched into
    refs/dayplan-origin/*, never into refs/dayplan/*. No commit on any trunk, no pull request, no write conflict.

    ONE HOME, AND IT MUST BE PRIVATE. The day is the person's, not a repo's, so the refs do not live in the repo the
    session runs in: they live in the repo DKJ_DAYPLAN_REPO names (owner/name), held in a bare git dir of this
    machine's own, sync.git beside the day files. Plan titles can be personal and a public repo's refs are readable
    by anyone, so a repo GitHub does not report as private is refused, and the day stays local ('not shared').
    DKJ_DAYPLAN_REPO is read from the environment, else from the env block of the user's ~/.claude/settings.json
    (an Admin server keeps the environment it was started in, as #3470 measured for the Stopwatch). 'off' in the
    environment is an explicit no.

    THE MERGE (Merge-DayPlanCopies), for one day's copies from every machine, this machine's own first:
      - a closed copy wins whole, the newest close first: its done and carried lists are indexes into its own items;
      - otherwise the copy with the newest 'planned' stamp is the base (the first -Apply; a -Replace is newer), and
        every item another machine ADDED after that stamp joins it, once, in the order it was added;
      - not-today lines and overrides are the union.
    So the 6-8 h band that -Add holds is held against the merged day, not one machine's half of it.

    OFFLINE OR NO PUSH RIGHTS: every failure is returned as a 'not shared' note, never thrown, and the day file on
    this machine still works as it did before #3924.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/dayplan-sync.tests.ps1 in the source repo.
#>

. (Join-Path $PSScriptRoot 'dayplan-lib.ps1')
. (Join-Path $PSScriptRoot 'stopwatch-lib.ps1')
. (Join-Path $PSScriptRoot 'stopwatch-sync-lib.ps1')

$script:DayPlanRefPrefix = 'refs/dayplan/'
$script:DayPlanOriginRefPrefix = 'refs/dayplan-origin/'
$script:DayPlanSharedFile = 'dayplan.json'
# What a machine publishes: its day files of the last two weeks, enough for -Context's carry-over and -Week.
$script:DayPlanShareDays = 14
$script:DayPlanSyncIntervalMinutes = 5
$script:DayPlanCommitIdentity = @{ Name = 'dayplan'; Email = 'dayplan@noreply.invalid' }
# The bounds on what another machine's payload may make this machine read.
$script:DayPlanSharedMaxBytes = 1048576
$script:DayPlanSharedMaxDays = 60
$script:DayPlanSharedMaxList = 24
$script:DayPlanSharedMaxText = 300

function Get-DayPlanShareRepo {
    <#
        The repo the day is shared through, as owner/name, or '' when the day is not shared: DKJ_DAYPLAN_REPO from the
        environment, else from the env block of -SettingsPath (the user's ~/.claude/settings.json). 'off', '0' or
        'false' in the environment is an explicit no, and so is a value that is not owner/name.
    #>
    param([string]$SettingsPath = $(if ($env:USERPROFILE) { Join-Path $env:USERPROFILE '.claude\settings.json' } else { '' }))
    $v = ([string]$env:DKJ_DAYPLAN_REPO).Trim()
    if (-not $v -and $SettingsPath -and (Test-Path -LiteralPath $SettingsPath -PathType Leaf)) {
        try { $v = ([string](([System.IO.File]::ReadAllText($SettingsPath) | ConvertFrom-Json).env.DKJ_DAYPLAN_REPO)).Trim() } catch { $v = '' }
    }
    if ($v -match '\A[A-Za-z0-9](?:[A-Za-z0-9-]{0,38})/[A-Za-z0-9._-]{1,100}\z') { return $v }
    return ''
}

function Get-DayPlanSyncGitDir {
    <# This machine's bare git dir for the shared refs, beside the day files. #>
    return (Join-Path (Get-DayPlanDir) 'sync.git')
}

function Get-DayPlanMachineId {
    <# This machine's id: the Stopwatch's (stopwatch-machine.txt), because it names the machine; under DKJ_ADMIN_STATE_DIR (the tests) one of its own. #>
    $dir = if ($env:DKJ_ADMIN_STATE_DIR) { Get-DayPlanDir } else { Get-AdminTimingBaseDir }
    return (Get-StopwatchMachineId -StoreDir $dir)
}

function ConvertTo-DayPlanInstant {
    <# A stamp as a UTC DateTime, or $null: Windows PowerShell 5.1 leaves an ISO stamp a string, PowerShell 7 makes it a DateTime. Pure. #>
    param($Value)
    if ($Value -is [datetime]) { return $Value.ToUniversalTime() }
    $s = ([string]$Value).Trim()
    if (-not $s) { return $null }
    $o = [DateTimeOffset]::MinValue
    if ([DateTimeOffset]::TryParse($s, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal, [ref]$o)) { return $o.UtcDateTime }
    return $null
}

function Format-DayPlanInstant {
    <# A moment as the day file keeps it: UTC, ISO 8601, milliseconds. Pure. #>
    param([datetime]$At)
    return $At.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ', [System.Globalization.CultureInfo]::InvariantCulture)
}

function ConvertTo-DayPlanDateKey {
    <# A day file's date as 'yyyy-MM-dd', or '' (PowerShell 7's ConvertFrom-Json may hand it back a DateTime). Pure. #>
    param($Value)
    if ($Value -is [datetime]) { return $Value.ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture) }
    $s = ([string]$Value).Trim()
    $d = [datetime]::MinValue
    if ([datetime]::TryParseExact($s, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, 'None', [ref]$d)) { return $s }
    return ''
}

function Get-DayPlanCut {
    <# -Text trimmed, without control characters, and cut to the shared maximum. Pure. #>
    param([AllowNull()]$Text)
    $t = (([string]$Text) -replace ('[' + [char]0 + '-' + [char]31 + [char]127 + ']'), ' ').Trim()
    if ($t.Length -gt $script:DayPlanSharedMaxText) { $t = $t.Substring(0, $script:DayPlanSharedMaxText).Trim() }
    return $t
}

function ConvertTo-DayPlanSharedDay {
    <#
        One day from another machine's payload as the day file's shape, or $null when it does not hold. ANOTHER
        MACHINE'S TEXT IS UNTRUSTED (anyone who can push to the home repo can write a ref), so every value is checked
        the way a plan is (ConvertTo-DayPlanItem) and every list and text is bounded. Pure.
    #>
    param($Raw)
    if ($null -eq $Raw) { return $null }
    $date = ConvertTo-DayPlanDateKey $Raw.date
    $goal = Get-DayPlanCut $Raw.goal
    if (-not $date -or -not $goal) { return $null }
    $items = @()
    $i = 0
    foreach ($r in @(@($Raw.items) | Where-Object { $null -ne $_ } | Select-Object -First $script:DayPlanSharedMaxList)) {
        $i++
        $it = ConvertTo-DayPlanItem -Raw ([pscustomobject]@{ title = (Get-DayPlanCut $r.title); hours = $r.hours; mode = $r.mode; ref = $r.ref; added = $r.added }) -Index $i
        if ($it -is [string]) { return $null }
        $at = ConvertTo-DayPlanInstant $r.addedAt
        if ($it.added -and $at) { $it | Add-Member -NotePropertyName addedAt -NotePropertyValue (Format-DayPlanInstant $at) }
        $items += $it
    }
    if (-not $items.Count) { return $null }
    $notToday = @(@($Raw.notToday) | Select-Object -First $script:DayPlanSharedMaxList | ForEach-Object { Get-DayPlanCut $_ } | Where-Object { $_ })
    $overrides = @(@($Raw.overrides) | Where-Object { $_ } | Select-Object -First $script:DayPlanSharedMaxList | ForEach-Object {
            $at = [string]$_.at
            $reason = Get-DayPlanCut $_.reason
            if (@('start', 'add') -ccontains $at -and $reason) { [pscustomobject]@{ at = $at; reason = $reason } }
        })
    $planned = ConvertTo-DayPlanInstant $Raw.planned
    $close = $null
    if ($Raw.close) {
        $c = $Raw.close
        $cAt = ConvertTo-DayPlanInstant $c.at
        $verdict = [string]$c.verdict
        if ($cAt -and @('reached', 'partly', 'missed') -ccontains $verdict) {
            $inRange = { param($list) @(@($list) | Where-Object { $null -ne $_ -and "$_" -match '\A\d{1,2}\z' -and [int]"$_" -lt $items.Count } | ForEach-Object { [int]"$_" } | Select-Object -Unique) }
            $unplanned = @(@($c.unplanned) | Where-Object { $_ } | Select-Object -First 100 | ForEach-Object {
                    $ref = ConvertTo-DayPlanRef -Ref ([string]$_.ref)
                    $url = [string]$_.url
                    if ($ref -and @('pr', 'issue') -ccontains [string]$_.kind) {
                        [pscustomobject]@{ ref = $ref; title = (Get-DayPlanCut $_.title); url = $(if ($url -match '\Ahttps://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+/(?:issues|pull)/\d+\z') { $url } else { '' }); kind = [string]$_.kind }
                    }
                })
            $close = [pscustomobject]@{
                at = (Format-DayPlanInstant $cAt); done = [object[]](& $inRange $c.done); carried = [object[]](& $inRange $c.carried)
                unplanned = $unplanned; prs = [Math]::Max(0, [Math]::Min(1000, [int]"0$($c.prs -replace '\D', '')"))
                issues = [Math]::Max(0, [Math]::Min(1000, [int]"0$($c.issues -replace '\D', '')")); verdict = $verdict
            }
        }
    }
    return [pscustomobject]@{ date = $date; goal = $goal; items = $items; notToday = $notToday; overrides = $overrides
        close = $close; planned = $(if ($planned) { Format-DayPlanInstant $planned } else { '' }) }
}

function ConvertTo-DayPlanSharedJson {
    <#
        The payload this machine publishes: its id and its day files (-Days, 'yyyy-MM-dd' -> parsed day file), sorted
        by date, as ASCII JSON, so the same days always give the same text and an unchanged day is never pushed again. Pure.
    #>
    param([Parameter(Mandatory = $true)][string]$MachineId, [hashtable]$Days = @{})
    $list = [object[]]@(foreach ($k in @($Days.Keys | Sort-Object)) { if ($Days[$k]) { $Days[$k] } })
    return (ConvertTo-StopwatchAsciiJson ([ordered]@{ machine = $MachineId; days = $list }))
}

function ConvertFrom-DayPlanSharedJson {
    <# One machine's payload as @{ Machine; Days } (ConvertTo-DayPlanSharedDay each, bounded in number), or $null when -Text is not one. Pure. #>
    param([AllowEmptyString()][string]$Text = '')
    try { $json = $Text | ConvertFrom-Json } catch { return $null }
    if ($null -eq $json -or -not ([string]$json.machine -cmatch '^[0-9a-f]{8}\z')) { return $null }
    $days = @(foreach ($d in @(@($json.days) | Where-Object { $null -ne $_ } | Select-Object -First $script:DayPlanSharedMaxDays)) {
            $x = $null
            try { $x = ConvertTo-DayPlanSharedDay $d } catch { $x = $null }
            if ($x) { $x }
        })
    return @{ Machine = [string]$json.machine; Days = $days }
}

function Get-DayPlanItemKey {
    <# An item's identity across machines. The hours are read leniently: a hand-edited local file must not fail the page (Victor, #3924). Pure. #>
    param($Item)
    $h = 0.0
    $hours = if ([double]::TryParse([string]$Item.hours, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$h)) { $h.ToString([System.Globalization.CultureInfo]::InvariantCulture) } else { [string]$Item.hours }
    return ([string]$Item.title + [char]0 + [string]$Item.ref + [char]0 + $hours + [char]0 + [string]$Item.mode)
}

function Merge-DayPlanCopies {
    <#
        One day from every machine's copy of it (-Copies, this machine's own first), as one day file, or $null for none.
        The rules are in the header: a closed copy wins whole; else the newest plan is the base and every item added
        after it on any machine joins it once, in the order it was added. A tie goes to the earlier copy, so this
        machine's own. Pure.
    #>
    param([AllowEmptyCollection()][object[]]$Copies = @())
    $all = @($Copies | Where-Object { $_ })
    if (-not $all.Count) { return $null }
    $closed = $null; $closedAt = $null
    foreach ($c in $all) {
        if (-not $c.close) { continue }
        $at = ConvertTo-DayPlanInstant $c.close.at
        if (-not $at) { $at = [datetime]::MinValue }
        if (-not $closed -or $at -gt $closedAt) { $closed = $c; $closedAt = $at }
    }
    if ($closed) { return $closed }
    $base = $null; $basePlanned = $null
    foreach ($c in $all) {
        $p = ConvertTo-DayPlanInstant $c.planned
        if (-not $p) { $p = [datetime]::MinValue }
        if (-not $base -or $p -gt $basePlanned) { $base = $c; $basePlanned = $p }
    }
    $items = @($base.items | Where-Object { $_ })
    # Ordinal, not @{}: PowerShell's default hashtable ignores case, and 'Y' and 'y' are two items (Victor, #3924).
    $seen = New-Object System.Collections.Hashtable ([StringComparer]::Ordinal)
    foreach ($it in $items) { $seen[(Get-DayPlanItemKey $it)] = $true }
    $joined = @()
    foreach ($c in $all) {
        if ([object]::ReferenceEquals($c, $base)) { continue }
        foreach ($it in @($c.items | Where-Object { $_ -and $_.added })) {
            $at = ConvertTo-DayPlanInstant $it.addedAt
            if (-not $at -or $at -le $basePlanned) { continue }
            $k = Get-DayPlanItemKey $it
            if ($seen[$k]) { continue }
            $seen[$k] = $true
            $joined += [pscustomobject]@{ Item = $it; At = $at }
        }
    }
    # A loop rather than Sort-Object, whose order for equal keys Windows PowerShell 5.1 does not promise.
    $ordered = New-Object System.Collections.Generic.List[object]
    foreach ($j in $joined) {
        $pos = $ordered.Count
        while ($pos -gt 0 -and $ordered[$pos - 1].At -gt $j.At) { $pos-- }
        $ordered.Insert($pos, $j)
    }
    $items += @($ordered | ForEach-Object { $_.Item })
    $notToday = @(@($all | ForEach-Object { @($_.notToday) }) | Where-Object { $_ } | Select-Object -Unique)
    $ovSeen = New-Object System.Collections.Hashtable ([StringComparer]::Ordinal)
    $overrides = @(foreach ($o in @($all | ForEach-Object { @($_.overrides) } | Where-Object { $_ })) {
            $k = [string]$o.at + [char]0 + [string]$o.reason
            if (-not $ovSeen[$k]) { $ovSeen[$k] = $true; $o }
        })
    return [pscustomobject]@{ date = (ConvertTo-DayPlanDateKey $base.date); goal = [string]$base.goal; items = $items; notToday = $notToday
        overrides = $overrides; close = $null; planned = [string]$(if ($base.planned -is [datetime]) { Format-DayPlanInstant $base.planned } else { $base.planned }) }
}

function Read-DayPlanSharedCopies {
    <#
        Every OTHER machine's day copies, from the refs last fetched into -GitDir (no network): @{ Days ('yyyy-MM-dd' ->
        list of copies); Machines (how many machines had a payload) }. -MachineId is this machine's, whose own ref is
        skipped because its day files are newer. A ref whose payload does not parse, or names another machine, is skipped.
    #>
    param([Parameter(Mandatory = $true)][string]$GitDir, [AllowEmptyString()][string]$MachineId = '')
    $days = @{}
    $none = @{ Days = $days; Machines = 0 }
    if (-not (Test-Path -LiteralPath $GitDir -PathType Container)) { return $none }
    $refs = Invoke-StopwatchGit -RepoRoot $GitDir -Arguments @('for-each-ref', '--format=%(refname)', $script:DayPlanOriginRefPrefix.TrimEnd('/'))
    if (-not $refs.Ok) { return $none }
    $machines = 0
    foreach ($ref in @($refs.Out | Where-Object { $_ })) {
        $id = $ref.Substring($script:DayPlanOriginRefPrefix.Length)
        if (-not ($id -cmatch '^[0-9a-f]{8}\z') -or $id -ceq $MachineId) { continue }
        $path = $ref + ':' + $script:DayPlanSharedFile
        $size = Invoke-StopwatchGit -RepoRoot $GitDir -Arguments @('cat-file', '-s', $path)
        if (-not $size.Ok -or -not $size.Out.Count -or [int64]$size.Out[0] -gt $script:DayPlanSharedMaxBytes) { continue }
        $blob = Invoke-StopwatchGit -RepoRoot $GitDir -Arguments @('cat-file', 'blob', $path)
        if (-not $blob.Ok) { continue }
        $p = $null
        try { $p = ConvertFrom-DayPlanSharedJson -Text ($blob.Out -join "`n") } catch { $p = $null }
        if (-not $p -or $p.Machine -cne $id) { continue }
        $machines++
        foreach ($d in @($p.Days)) { $days[$d.date] = [object[]](@($days[$d.date] | Where-Object { $_ }) + $d) }
    }
    return @{ Days = $days; Machines = $machines }
}

function Test-DayPlanRepoPrivate {
    <#
        Whether github.com reports -Repo as PRIVATE, as @{ Private; Error }, through gh -- asked on every sync, not
        cached, so a repo turned public stops receiving the day at the next command (Sebastian, #3924). The host is
        named, because gh's default host can be an enterprise one while the push always goes to github.com; and the
        visibility must read PRIVATE, because 'internal' (which isPrivate also reports) is readable by a whole
        enterprise. Anything else is not private: the day is then not shared.
    #>
    param([Parameter(Mandatory = $true)][string]$Repo)
    if (-not (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue)) { return @{ Private = $false; Error = 'gh was not found, so the repo''s visibility is unknown' } }
    $eap = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $out = [string](@(& gh repo view "github.com/$Repo" --json visibility --jq .visibility 2>$null) -join '')
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $eap }
    if ($code -ne 0) { return @{ Private = $false; Error = "$Repo could not be read on github.com" } }
    if ($out.Trim() -cne 'PRIVATE') { return @{ Private = $false; Error = "$Repo is not private, and plan titles can be personal" } }
    return @{ Private = $true; Error = '' }
}

function Initialize-DayPlanSyncRepo {
    <# Creates the bare git dir -GitDir once, and points its origin at -Url. Returns whether it is ready. #>
    param([Parameter(Mandatory = $true)][string]$GitDir, [Parameter(Mandatory = $true)][string]$Url)
    try {
        if (-not (Test-Path -LiteralPath (Join-Path $GitDir 'HEAD') -PathType Leaf)) {
            if (-not (Test-Path -LiteralPath $GitDir -PathType Container)) { [void](New-Item -ItemType Directory -Path $GitDir -Force) }
            if (-not (Invoke-StopwatchGit -RepoRoot $GitDir -Arguments @('init', '--quiet', '--bare')).Ok) { return $false }
        }
        $cur = Invoke-StopwatchGit -RepoRoot $GitDir -Arguments @('config', '--get', 'remote.origin.url')
        if (-not $cur.Ok -or -not $cur.Out.Count) { return (Invoke-StopwatchGit -RepoRoot $GitDir -Arguments @('remote', 'add', 'origin', $Url)).Ok }
        if ($cur.Out[0].Trim() -cne $Url) { return (Invoke-StopwatchGit -RepoRoot $GitDir -Arguments @('remote', 'set-url', 'origin', $Url)).Ok }
        return $true
    } catch { return $false }
}

function Get-DayPlanLocalDays {
    <#
        This machine's day files of the -Days days up to -Through, as 'yyyy-MM-dd' -> parsed day file. A file that does
        not parse is left out. The default runs a week ahead, so a day planned in advance is shared too (Victor, #3924).
    #>
    param([datetime]$Through = (Get-Date).Date.AddDays(7), [int]$Days = ($script:DayPlanShareDays + 7))
    $out = @{}
    for ($i = 0; $i -lt $Days; $i++) {
        $d = $Through.Date.AddDays(-$i)
        $p = Get-DayPlanPath -Date $d
        if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { continue }
        try { $out[$d.ToString('yyyy-MM-dd')] = [System.IO.File]::ReadAllText($p, (New-Object System.Text.UTF8Encoding($false))) | ConvertFrom-Json } catch { }
    }
    return $out
}

function Invoke-DayPlanSync {
    <#
        One sync of the day plan: -Fetch reads every machine's ref into -GitDir, -Publish writes this machine's day files
        (-LocalDays) to its own ref, retried once from a fresh fetch when the push is refused. Returns @{ Shared (bool);
        Note } -- 'shared through <repo>, N other machine(s)' or 'not shared: <why>'. Never throws.
        -Repo is the home repo (owner/name, its GitHub visibility checked); -Url replaces it with a remote of the tests' own,
        which is not GitHub and so has no visibility to check.
    #>
    param(
        [string]$Repo = '',
        [string]$Url = '',
        [Parameter(Mandatory = $true)][string]$GitDir,
        [AllowEmptyString()][string]$MachineId = '',
        [hashtable]$LocalDays = @{},
        [switch]$Fetch,
        [switch]$Publish
    )
    try {
        if (-not $Url) {
            if (-not $Repo) { return @{ Shared = $false; Note = 'not shared: DKJ_DAYPLAN_REPO names no private repo' } }
            $vis = Test-DayPlanRepoPrivate -Repo $Repo
            if (-not $vis.Private) { return @{ Shared = $false; Note = 'not shared: ' + $vis.Error } }
            $Url = "https://github.com/$Repo.git"
        }
        $where = if ($Repo) { $Repo } else { 'the test remote' }
        if (-not ($MachineId -cmatch '^[0-9a-f]{8}\z')) { return @{ Shared = $false; Note = 'not shared: this machine has no id' } }
        if (-not (Initialize-DayPlanSyncRepo -GitDir $GitDir -Url $Url)) { return @{ Shared = $false; Note = 'not shared: the sync dir could not be set up' } }
        $recv = { Receive-StopwatchShared -RepoRoot $GitDir -RefPrefix $script:DayPlanRefPrefix -OriginRefPrefix $script:DayPlanOriginRefPrefix }
        if ($Fetch -and -not (& $recv)) { return @{ Shared = $false; Note = "not shared: $where did not answer" } }
        if ($Publish) {
            $json = ConvertTo-DayPlanSharedJson -MachineId $MachineId -Days $LocalDays
            $temp = Split-Path -Parent $GitDir
            $pubArgs = @{ RepoRoot = $GitDir; MachineId = $MachineId; Json = $json; TempDir = $temp; RefPrefix = $script:DayPlanRefPrefix
                OriginRefPrefix = $script:DayPlanOriginRefPrefix; FileName = $script:DayPlanSharedFile; Subject = 'dayplan: days of machine'; Identity = $script:DayPlanCommitIdentity }
            $p = Publish-StopwatchShared @pubArgs
            if ($p.Status -eq 'failed') {
                if (-not (& $recv)) { return @{ Shared = $false; Note = "not shared: $where did not answer" } }
                $p = Publish-StopwatchShared @pubArgs
            }
            if ($p.Status -eq 'failed') { return @{ Shared = $false; Note = "not shared: the push to $where was refused ($($p.Message))" } }
        }
        $others = (Read-DayPlanSharedCopies -GitDir $GitDir -MachineId $MachineId).Machines
        return @{ Shared = $true; Note = "shared through $where, with $others other machine(s)" }
    } catch {
        return @{ Shared = $false; Note = 'not shared: ' + (([string]$_.Exception.Message) -replace '\s+', ' ') }
    }
}
