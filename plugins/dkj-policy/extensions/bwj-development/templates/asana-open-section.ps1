<#
.SYNOPSIS
    Keep the Asana task of every OPEN GitHub issue out of the sections that come before the board's
    Filed section: a daily sweep moves such a card into Filed. Copied into a BWJ store repo as
    .github/scripts/asana-open-section.ps1 and driven by .github/workflows/asana-open-section.yml.

.DESCRIPTION
    WHY THIS EXISTS (#4056, Dave, November 13, 2026). The owner's rule: while its GitHub issue exists and
    is open, the Asana task is in '2. In Progress'. report-issue places a new card in the section the
    repo's Get-AsanaStageMap gives Filed, and a repo that wants every open issue shown as in progress
    answers Filed with the same code as InDevelopment -- that half is the repo's own, and needs nothing
    from here. What it could not do is HOLD the rule: a person drags a card back into '1. Todo' while its
    issue is still open, and nothing moved it back. A reopen is covered by asana-closed-message (#3562);
    this sweep covers everything else.

    THE ONE MOVE. For every open issue with exactly one linked task, the card is moved into the section
    whose code Get-AsanaStageMap gives Filed, WHEN AND ONLY WHEN it sits in a section that comes EARLIER
    in the cycle (Select-OpenSectionMove):

      - the cycle order is the stage map's own stages, Requests, NeedsInfo, Filed, InDevelopment,
        InReview, ReadyToTest, Completed; a section code is EARLIER when every stage the map gives it
        ranks before Filed. A code the map does not name, and one it gives a stage at or after Filed,
        is never earlier, so the move fails closed;
      - never a card that sits LATER (in review, done, or a section the map does not know): the issue
        is open, but those are a person's or another workflow's call;
      - never a COMPLETED task;
      - never one in the NeedsInfo section while the issue carries the map's NeedsInfoLabel (or
        awaiting-info-client, the family's current name for it): that card waits on its requester;
      - never a task on several boards, nor one whose board has no single section with the Filed code.

    So on a board whose Filed shares the code of Requests and NeedsInfo ('1. Todo', the default on both
    store boards), there is no earlier section and the sweep moves nothing. It acts only on a board that
    answers Filed later than its inbox, which is what a repo does to show every open issue as in progress.

    WHAT IT WRITES. One request: a move of the linked task within its own board (New-AsanaMoveRequest,
    sent by Invoke-AsanaWrite). It never comments, completes or unticks a task, and it writes nothing on
    GitHub: the token holds issues: read, for the listing.

    HOW THE TASK IS FOUND -- Resolve-AsanaTaskRef, the same three matchers as asana-closed-message: the
    '<!-- asana-task: <gid> -->' marker report-issue writes; the '| **Asana** | ... |' header row of an
    imported ticket; exactly one Asana task URL anywhere else. Several different tasks is 'ambiguous'
    and skipped.

    THE TASK IT MOVES is the one the issue body's marker names, and whoever can edit the body can point
    that marker at any task the token reaches. That is asana-closed-message's trust model unchanged: the
    write can only put that task into a section of its own board, and only forward to Filed.

    THE REPO'S STAGE MAP IS READ AS TEXT, NEVER RUN, as in asana-closed-message (#3017): the job holds
    ASANA_PAT, and dot-sourcing scripts/repo-config.ps1 would run whatever it does.

    IT PRINTS NOTHING ANOTHER PERSON WROTE: no task name, section name, issue body or Asana error text.
    A failed read or write reports its HTTP status or a fixed phrase.

    WHEN IT FAILS THE RUN. A refused move, and a sweep in which every linked task's read failed (a revoked
    or short-scoped ASANA_PAT). A single unreadable task, such as a deleted one, is logged and skipped, so
    one stale link cannot turn every daily run red. A missing ASANA_PAT, and a stage map that states no
    Filed code, are said and end the run without failing it: the session check reports a store with no
    secret.

    SELF-CONTAINED, AND THAT IS WHY THE HELPERS ARE COPIES. This file ships into a consumer's
    .github/scripts/, where no plugin lib exists. The matchers come from asana-task-lib.ps1, the listing
    parse and Invoke-GhCapture from asana-prio-label.ps1, the stage-map reader, the board read, the move
    and the write from asana-closed-message.ps1. scripts/tests/bwj-development.tests.ps1 holds each copy
    equal to its source.

    The script runs its main flow only when invoked directly; dot-sourcing it loads the pure helpers and
    does nothing else, which is how the suite exercises them.

    Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    # 'owner/repo'.
    [string]$Repo = $env:GITHUB_REPOSITORY,
    [string]$AsanaPat = $env:ASANA_PAT,
    # The repo's seam file, read as text. Empty: the checkout's own scripts/repo-config.ps1.
    [string]$RepoConfigPath = ''
)

$ErrorActionPreference = 'Stop'

$script:AsanaApiBase = 'https://app.asana.com/api/1.0'

# The cycle, in order. A section code is EARLIER than Filed only when every stage the map gives it is
# named before 'Filed' here.
$script:StageOrder = @('Requests', 'NeedsInfo', 'Filed', 'InDevelopment', 'InReview', 'ReadyToTest', 'Completed')

# The family's current name for the needs-info label, honoured beside whatever the map names.
$script:NeedsInfoLabelDefault = 'awaiting-info-client'


function Get-AsanaGidsFromText {
    <#
        Pure: the distinct task GIDs of every Asana task URL in a piece of text, in first-seen order.
        Both URL shapes Asana hands out are read; a URL that names no task contributes nothing.
        A copy of asana-task-lib.ps1's function of this name.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    $gids = @()
    foreach ($m in [regex]::Matches($Text, 'https://app\.asana\.com/[^\s)>\]]*')) {
        $url = $m.Value
        $t = [regex]::Match($url, '/task/([0-9]+)')
        if (-not $t.Success) { $t = [regex]::Match($url, '^https://app\.asana\.com/0/[0-9]+/([0-9]+)') }
        if ($t.Success) { $gids += $t.Groups[1].Value }
    }
    return @($gids | Select-Object -Unique)
}

function Get-AsanaHeaderRowText {
    <#
        Pure: the contents of an imported ticket's '| **Asana** | ... |' header row, or ''. A copy of
        asana-task-lib.ps1's function of this name.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$IssueBody)

    $m = [regex]::Match($IssueBody, '(?m)^\|\s*\*{0,2}Asana\*{0,2}\s*\|(.*)$')
    if (-not $m.Success) { return '' }
    return $m.Groups[1].Value
}

function Resolve-AsanaTaskRef {
    <#
        Pure: which Asana task an issue body belongs to -- Gid (or $null), Source ('marker' |
        'header-row' | 'sole-url' | 'ambiguous' | 'none') and Candidates. Non-numeric content never
        matches, so it can never reach a request URL. A copy of asana-task-lib.ps1's function of this name.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$IssueBody)

    $marker = [regex]::Match($IssueBody, '<!--\s*asana-task:\s*([0-9]+)\s*-->')
    if ($marker.Success) {
        return [pscustomobject]@{ Gid = $marker.Groups[1].Value; Source = 'marker'; Candidates = @($marker.Groups[1].Value) }
    }

    $row = Get-AsanaHeaderRowText -IssueBody $IssueBody
    if ($row) {
        $rowGids = @(Get-AsanaGidsFromText -Text $row)
        if ($rowGids.Count -ge 1) {
            return [pscustomobject]@{ Gid = $rowGids[0]; Source = 'header-row'; Candidates = $rowGids }
        }
    }

    $all = @(Get-AsanaGidsFromText -Text $IssueBody)
    if ($all.Count -eq 1) { return [pscustomobject]@{ Gid = $all[0]; Source = 'sole-url'; Candidates = $all } }
    if ($all.Count -gt 1) { return [pscustomobject]@{ Gid = $null; Source = 'ambiguous'; Candidates = $all } }
    return [pscustomobject]@{ Gid = $null; Source = 'none'; Candidates = @() }
}

function Invoke-GhCapture {
    <#
        Run gh with these arguments and keep both streams apart: Out (the stdout lines), ExitCode, and
        Error (gh's own stderr, or a placeholder when it wrote none). A copy of asana-closed-message.ps1's
        function of this name.
    #>
    param([Parameter(Mandatory = $true)][string[]]$GhArgs)

    $prev = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $all  = @(& gh @ghArgs 2>&1)
        $code = $LASTEXITCODE
    } finally { $ErrorActionPreference = $prev }
    $out = @($all | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } | ForEach-Object { [string]$_ })
    $err = (@($all | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] } | ForEach-Object { $_.ToString() }) -join ' ').Trim()
    return [pscustomobject]@{ Out = $out; ExitCode = $code; Error = $(if ($err) { $err } else { '(gh wrote nothing to stderr)' }) }
}

function ConvertFrom-IssueListJson {
    <#
        Pure: the issues out of 'gh issue list --json' text, as a list. Empty text and '[]' are an EMPTY
        list (Count 0) on Windows PowerShell 5.1 as well as 7: 5.1 hands a parsed '[]' down a pipeline as
        one object, so the array is read with -InputObject and unrolled with foreach.
    #>
    param([AllowEmptyString()][string]$Text = '')

    if (-not ([string]$Text).Trim()) { return @() }
    $parsed = ConvertFrom-Json -InputObject ([string]$Text)
    return @(foreach ($x in $parsed) { $x })
}

function Get-RepoStageCode {
    <#
        Pure: the section code the repo's Get-AsanaStageMap gives a stage -- 'Completed' by default, the
        stage whose column a reviewed task is moved to -- read from the TEXT of scripts/repo-config.ps1
        (#3017). '' when the file states no map or the map no such stage: the plugin's built-in map was
        retired with the CI mirror, so there is no default to fall back on, and the ask then names no
        section. A code is a number with at most one letter after it ('4', '3A'), quoted or bare.

        READ, NEVER RUN: the job holds ASANA_PAT, and dot-sourcing the repo's seam file would run whatever
        it does. Only the body of Get-AsanaStageMap is searched, up to the next function, and a line that
        is a comment does not count.
    #>
    param(
        [AllowEmptyString()][string]$ConfigText = '',
        [string]$Stage = 'Completed'
    )
    $start = [regex]::Match([string]$ConfigText, '(?im)^\s*function\s+Get-AsanaStageMap\b')
    if (-not $start.Success) { return '' }
    $body = $ConfigText.Substring($start.Index + $start.Length)
    $next = [regex]::Match($body, '(?im)^\s*function\s+')
    if ($next.Success) { $body = $body.Substring(0, $next.Index) }
    # A <# ... #> block is a comment however many lines it spans (code review, #3017).
    $body = [regex]::Replace($body, '(?s)<#.*?#>', '')
    # The key, bare or quoted, opens a line or follows '{' or ';' (a one-line hashtable), and the value
    # ends the entry.
    $key = [regex]::Escape($Stage)
    $m = [regex]::Match($body, "(?im)(?:^|[{;])\s*(?:$key|'$key'|`"$key`")\s*=\s*['`"]?([0-9]+[A-Za-z]?)['`"]?(?=\s*(?:[;}#]|$))")
    if ($m.Success) { return $m.Groups[1].Value }
    return ''
}

function Get-SectionCode {
    <#
        Pure: a section name's code -- the text before its first '.', as Get-AsanaStageMap reads a board
        ('3. Waiting for review' is '3') -- or '' for a section without one.
    #>
    param([AllowEmptyString()][string]$Name = '')
    $m = [regex]::Match([string]$Name, '^\s*([0-9]+[A-Za-z]?)\.')
    if ($m.Success) { return $m.Groups[1].Value }
    return ''
}

function Read-AsanaTaskBoard {
    <#
        The task's board as both card writes judge it (#3248, #3562): its memberships (Project,
        SectionName), whether it is Completed, and -- where it is on exactly one board -- that board's
        sections (Gid, Name). Ok is $false, with Why, wherever a read failed; it never throws. -Get is the
        read, injectable as in Resolve-DoneSectionName.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Gid,
        [string]$Pat = '',
        [scriptblock]$Get = $null
    )
    $fail = { param($why) [pscustomobject]@{ Ok = $false; Why = $why; Memberships = @(); Sections = @(); Completed = $false } }
    if ($Gid -notmatch '\A[0-9]+\z') { return (& $fail 'the task GID is not numeric') }
    if (-not $Get) { $Get = { param($Uri) Invoke-RestMethod -Method GET -Uri $Uri -Headers @{ Authorization = "Bearer $Pat" } } }
    try {
        $task = & $Get "$script:AsanaApiBase/tasks/$($Gid)?opt_fields=completed,memberships.project.gid,memberships.section.name"
    } catch { return (& $fail 'the task could not be read') }
    $memberships = @(@($task.data.memberships) | Where-Object { ([string]$_.project.gid) -match '\A[0-9]+\z' } |
        ForEach-Object { [pscustomobject]@{ Project = [string]$_.project.gid; SectionName = [string]$_.section.name } })
    $boards = @($memberships | ForEach-Object { $_.Project } | Select-Object -Unique)
    $sections = @()
    if ($boards.Count -eq 1) {
        try {
            $read = & $Get "$script:AsanaApiBase/projects/$($boards[0])/sections?opt_fields=name"
        } catch { return (& $fail "the sections of board $($boards[0]) could not be read") }
        $sections = @(@($read.data) | ForEach-Object { [pscustomobject]@{ Gid = [string]$_.gid; Name = [string]$_.name } })
    }
    return [pscustomobject]@{ Ok = $true; Why = ''; Memberships = $memberships; Sections = $sections; Completed = ($task.data.completed -eq $true) }
}

function New-AsanaMoveRequest {
    <#
        Pure: the POST that moves a task into a section of its board (#3248) -- the second write this
        script can build, beside the comment. A non-numeric task or section GID is refused before it can
        reach a URL.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Gid,
        [Parameter(Mandatory = $true)][string]$SectionGid
    )
    if ($Gid -notmatch '\A[0-9]+\z') { throw "Refusing to build a request for a non-numeric task GID: '$Gid'." }
    if ($SectionGid -notmatch '\A[0-9]+\z') { throw "Refusing to build a request for a non-numeric section GID: '$SectionGid'." }
    [pscustomobject]@{
        Method = 'POST'
        Uri    = "$script:AsanaApiBase/sections/$SectionGid/addTask"
        Body   = (ConvertTo-Json @{ data = @{ task = $Gid } } -Compress -Depth 5)
    }
}

function Invoke-AsanaWrite {
    <#
        Send one request a pure builder made -- the ONLY HTTP write site in this file -- and answer Ok and
        Status ('HTTP <code>', or 'HTTP status unknown'). It never throws: whether a refusal ends the run is
        the caller's call, and only the message's does. UTF-8 BYTES, not the string: Windows PowerShell 5.1
        encodes a string body as ISO-8859-1, which would turn the header's em dash into '?'. pwsh sends
        UTF-8 either way.
    #>
    param(
        [Parameter(Mandatory = $true)]$Request,
        [Parameter(Mandatory = $true)][string]$Pat
    )
    $headers = @{ Authorization = "Bearer $Pat"; 'Content-Type' = 'application/json; charset=utf-8' }
    try {
        Invoke-RestMethod -Method $Request.Method -Uri $Request.Uri -Headers $headers `
            -Body ([System.Text.Encoding]::UTF8.GetBytes([string]$Request.Body)) | Out-Null
        return [pscustomobject]@{ Ok = $true; Status = '' }
    } catch {
        $status = $null
        if ($_.Exception.PSObject.Properties['Response'] -and $_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
        return [pscustomobject]@{ Ok = $false; Status = "HTTP $(if ($status) { $status } else { 'status unknown' })" }
    }
}

function Read-RepoConfigText {
    <#
        The TEXT of the repo's seam file, or '' where there is none -- -RepoConfigPath, else the checkout's
        own scripts/repo-config.ps1 two levels above this script. Read, never run (#3017).
    #>
    $configPath = if ($RepoConfigPath) { $RepoConfigPath } else { Join-Path $PSScriptRoot '../../scripts/repo-config.ps1' }
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return '' }
    return [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $configPath).ProviderPath)
}

function Get-RepoStageLabel {
    <#
        Pure: the NeedsInfoLabel the repo's Get-AsanaStageMap names, read from the TEXT of the seam file
        as Get-RepoStageCode reads a code, or '' when the map names none. Only a label-shaped value is
        read (letters, digits, '-', '_').
    #>
    param([AllowEmptyString()][string]$ConfigText = '')
    $start = [regex]::Match([string]$ConfigText, '(?im)^\s*function\s+Get-AsanaStageMap\b')
    if (-not $start.Success) { return '' }
    $body = $ConfigText.Substring($start.Index + $start.Length)
    $next = [regex]::Match($body, '(?im)^\s*function\s+')
    if ($next.Success) { $body = $body.Substring(0, $next.Index) }
    $body = [regex]::Replace($body, '(?s)<#.*?#>', '')
    $m = [regex]::Match($body, "(?im)(?:^|[{;])\s*(?:NeedsInfoLabel|'NeedsInfoLabel'|`"NeedsInfoLabel`")\s*=\s*['`"]([A-Za-z0-9_-]+)['`"](?=\s*(?:[;}#]|$))")
    if ($m.Success) { return $m.Groups[1].Value }
    return ''
}

function Get-EarlierStageCodes {
    <#
        Pure: the section codes that come EARLIER in the cycle than Filed -- a code every stage of which,
        in -StageCodes (stage -> code), ranks before Filed in $script:StageOrder. A code the map also gives
        Filed or any later stage is left out, so a board whose inbox shares Filed's section has none.
    #>
    param([Parameter(Mandatory = $true)][hashtable]$StageCodes)
    $filedRank = [array]::IndexOf($script:StageOrder, 'Filed')
    $byCode = @{}
    foreach ($stage in $script:StageOrder) {
        $code = [string]$StageCodes[$stage]
        if (-not $code) { continue }
        $key = $code.ToUpperInvariant()
        $rank = [array]::IndexOf($script:StageOrder, $stage)
        if (-not $byCode.ContainsKey($key)) { $byCode[$key] = $true }
        if ($rank -ge $filedRank) { $byCode[$key] = $false }
    }
    return @($byCode.Keys | Where-Object { $byCode[$_] } | Sort-Object)
}

function Select-OpenSectionMove {
    <#
        Pure: whether an OPEN issue's card moves into the Filed section (#4056), and why. -Memberships and
        -Sections are Read-AsanaTaskBoard's; -StageCodes the repo's stage map (stage -> code); -Labels the
        issue's label names; -NeedsInfoLabels the names that hold a card in NeedsInfo. SectionGid is ''
        wherever the move is skipped, and Why never carries a section's or a task's text.
    #>
    param(
        [AllowEmptyCollection()][object[]]$Memberships = @(),
        [AllowEmptyCollection()][object[]]$Sections = @(),
        [Parameter(Mandatory = $true)][hashtable]$StageCodes,
        [bool]$Completed = $false,
        [AllowEmptyCollection()][string[]]$Labels = @(),
        [AllowEmptyCollection()][string[]]$NeedsInfoLabels = @()
    )
    $skip = { param($why) [pscustomobject]@{ SectionGid = ''; Why = $why } }
    $filed = [string]$StageCodes['Filed']
    if (-not $filed) { return (& $skip 'the repo states no Filed stage in Get-AsanaStageMap') }
    if ($Completed) { return (& $skip 'the task is completed') }
    $boards = @(@($Memberships) | ForEach-Object { [string]$_.Project } | Where-Object { $_ } | Select-Object -Unique)
    if ($boards.Count -ne 1) { return (& $skip "the task is on $($boards.Count) boards, not one") }
    $current = Get-SectionCode -Name ([string](@($Memberships)[0].SectionName))
    if (-not $current) { return (& $skip 'the card sits in a section without a code') }
    if ($current -ieq $filed) { return (& $skip "the card is in the Filed section (code $filed)") }
    $earlier = @(Get-EarlierStageCodes -StageCodes $StageCodes)
    if ($earlier -notcontains $current.ToUpperInvariant()) { return (& $skip "the card sits in code $current, which is not before Filed in the cycle") }
    $needsInfo = [string]$StageCodes['NeedsInfo']
    $held = @(@($Labels) | Where-Object { @($NeedsInfoLabels) -contains ([string]$_) })
    if ($needsInfo -and $current -ieq $needsInfo -and $held.Count -gt 0) {
        return (& $skip "the card is in NeedsInfo (code $needsInfo) and the issue carries $($held[0])")
    }
    $hits = @(@($Sections) | Where-Object { (Get-SectionCode -Name ([string]$_.Name)) -ieq $filed -and ([string]$_.Gid) -match '\A[0-9]+\z' })
    if ($hits.Count -ne 1) { return (& $skip "no single section with code $filed on the task's board") }
    return [pscustomobject]@{ SectionGid = [string]$hits[0].Gid; Why = "from code $current into code $filed" }
}

function Read-StageCodes {
    <# Pure: every stage's code from the seam file's text, as a hashtable (an absent stage is ''). #>
    param([AllowEmptyString()][string]$ConfigText = '')
    $codes = @{}
    foreach ($stage in $script:StageOrder) { $codes[$stage] = Get-RepoStageCode -ConfigText $ConfigText -Stage $stage }
    return $codes
}

function Invoke-OpenSectionSweep {
    <#
        Every OPEN issue of the repo, each card judged by Select-OpenSectionMove and moved where it says so.
        One issue failing never ends the walk; the run fails at the END on a refused move, or when every
        linked task's read failed.
    #>
    if ($Repo -notmatch '\A[^\s#/]+/[^\s#/]+\z') { throw "Repo '$Repo' is not 'owner/repo'." }
    $config = Read-RepoConfigText
    $codes = Read-StageCodes -ConfigText $config
    if (-not $codes['Filed']) {
        Write-Host 'The repo states no Filed stage in Get-AsanaStageMap (scripts/repo-config.ps1) -- nothing to keep cards in, so the sweep did nothing.'
        return
    }
    $mapLabel = Get-RepoStageLabel -ConfigText $config
    $needsInfoLabels = @(@($mapLabel, $script:NeedsInfoLabelDefault) | Where-Object { $_ } | Select-Object -Unique)
    $earlier = @(Get-EarlierStageCodes -StageCodes $codes)
    if ($earlier.Count -eq 0) {
        Write-Host "No section comes before Filed (code $($codes['Filed'])) on this repo's stage map, so no card can sit too early -- the sweep did nothing."
        return
    }

    $limit = 1000
    $run = Invoke-GhCapture -GhArgs @('issue', 'list', '--repo', $Repo, '--state', 'open', '--limit', "$limit", '--json', 'number,body,labels')
    if ($run.ExitCode -ne 0) { throw "The open issues of $Repo could not be listed: gh exited $($run.ExitCode): $($run.Error)" }
    $issues = @(ConvertFrom-IssueListJson -Text ([string]($run.Out -join "`n")))
    if ($issues.Count -ge $limit) {
        $capNote = "The listing holds $limit issues, the cap -- older open issues are not swept."
        Write-Host $capNote
        Write-Host "::warning::$capNote"
    }

    $linked = 0; $unread = 0; $moved = 0; $refused = 0
    foreach ($i in $issues) {
        $ref = Resolve-AsanaTaskRef -IssueBody ([string]$i.body)
        if (-not $ref.Gid) { continue }
        $linked++
        $board = Read-AsanaTaskBoard -Gid $ref.Gid -Pat $AsanaPat
        if (-not $board.Ok) {
            $unread++
            Write-Host "  $Repo#$($i.number): skipped -- $($board.Why)."
            continue
        }
        $labels = @(@($i.labels) | ForEach-Object { [string]$_.name })
        $move = Select-OpenSectionMove -Memberships $board.Memberships -Sections $board.Sections -StageCodes $codes `
            -Completed $board.Completed -Labels $labels -NeedsInfoLabels $needsInfoLabels
        if (-not $move.SectionGid) { continue }
        $write = Invoke-AsanaWrite -Request (New-AsanaMoveRequest -Gid $ref.Gid -SectionGid $move.SectionGid) -Pat $AsanaPat
        if ($write.Ok) {
            $moved++
            Write-Host "  $Repo#$($i.number): task $($ref.Gid) moved $($move.Why)."
        } else {
            $refused++
            Write-Host "  $Repo#$($i.number): the move of task $($ref.Gid) was refused ($($write.Status))."
        }
    }
    Write-Host "Open-section sweep: $($issues.Count) open issue(s), $linked with one linked task, $moved moved into Filed (code $($codes['Filed'])), $refused refused, $unread unreadable."
    if ($refused -gt 0) { throw "$refused move(s) were refused; see above." }
    if ($linked -gt 0 -and $unread -eq $linked) { throw "None of the $linked linked task(s) could be read -- is ASANA_PAT still valid?" }
}

function Invoke-Main {
    if (-not $AsanaPat) {
        Write-Host 'ASANA_PAT is not set -- the open-section sweep did nothing. The repo maintainer sets the secret (see step 3 of the adopt-bwj-development skill).'
        return
    }
    Invoke-OpenSectionSweep
}

if ($MyInvocation.InvocationName -ne '.') {
    Invoke-Main
}
