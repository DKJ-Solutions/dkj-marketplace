<#
.SYNOPSIS
    Which section of the repo's Asana board a stage code names, and the one write that moves a task
    into it -- the pure, network-free half of move-asana-task.ps1 (#4291).

.DESCRIPTION
    ONE PLACE FOR "A SECTION'S CODE". A section is named by its CODE, the text before its leading '.'
    ('2' for '2. In Progress', '1C' for '1C. Waiting'). The CI runner templates (asana-closed-message,
    asana-open-section) resolve sections the same way, and a manual move and an automated move must
    never pick different sections. The templates cannot dot-source this file: they are copied into a
    consumer's .github/scripts/, where no plugin lib exists, so each carries its own copy of
    Get-SectionCode and New-AsanaMoveRequest. scripts/tests/dkj-repo-workflow-bwj.tests.ps1 holds those
    copies equal to this file's, and scripts/tests/bwj-asana-move-task.tests.ps1 runs both Get-SectionCode
    over one table of section names, so they cannot drift.

    ONE BOARD ONLY (#4282). A task can sit on several boards, and adding it to a section of a board it
    is not on would put it there. Invoke-AsanaTaskMove therefore moves a task only when it is a member
    of the repo's own board (Get-AsanaProjectGid), and skips it otherwise.

    The HTTP calls are injectable (-Get, -Send), so the suite runs without a network. The task GID of an
    issue comes from Resolve-AsanaTaskRef (asana-task-lib.ps1), the matcher the CI runners use.

    Pure ASCII (repo convention for .ps1).
#>

. (Join-Path $PSScriptRoot 'asana-task-lib.ps1')

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

function Find-SectionGid {
    <#
        Pure: the GID of the one section whose code is -Code, compared without regard to case. A trailing
        '.' on -Code is accepted ('2.'). Throws on no match and on several, because the move must not
        guess which column is meant. -Sections are objects with Gid and Name.
    #>
    param(
        [AllowEmptyCollection()][object[]]$Sections = @(),
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Code
    )
    $want = ([string]$Code).Trim().TrimEnd('.')
    if ($want -notmatch '\A[0-9]+[A-Za-z]?\z') { throw "Not a section code: '$Code' (a number with at most one letter, like 2 or 1C)." }
    $hits = @(@($Sections) | Where-Object { (Get-SectionCode -Name ([string]$_.Name)) -ieq $want })
    $names = (@($Sections) | ForEach-Object { [string]$_.Name }) -join ' | '
    if ($hits.Count -eq 0) { throw "No section with code '$want' on the board. Sections: $names" }
    if ($hits.Count -gt 1) { throw "Several sections carry code '$want': $((@($hits) | ForEach-Object { [string]$_.Name }) -join ' | ')" }
    return [string]$hits[0].Gid
}

function Split-ListArgument {
    <# Pure: comma-separated and repeated values flattened to one list of trimmed, non-empty items. #>
    param([AllowEmptyCollection()][string[]]$Values = @())
    return @(@($Values) | ForEach-Object { ([string]$_) -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
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

function Get-AsanaIssueTaskGid {
    <#
        Pure: the Asana task GID an issue body links, by the CI runners' own matcher (Resolve-AsanaTaskRef:
        the asana-task marker, the header row, one sole task URL). Returns Gid ($null when none) and Source.
    #>
    param([AllowEmptyString()][string]$IssueBody = '')
    $ref = Resolve-AsanaTaskRef -IssueBody $IssueBody
    return [pscustomobject]@{ Gid = $ref.Gid; Source = $ref.Source }
}

function Read-AsanaIssueBodyText {
    <# The body of issue -Number via gh, run from -WorkingDirectory; $null when gh cannot read it. #>
    param([Parameter(Mandatory = $true)][int]$Number, [string]$WorkingDirectory = '')
    $run = Invoke-AsanaGhBounded -Arguments "issue view $Number --json body -q .body" -WorkingDirectory $WorkingDirectory
    if ($run.TimedOut -or -not $run.Started -or $run.ExitCode -ne 0) { return $null }
    return [string]$run.Out
}

function Invoke-AsanaSend {
    <# The default -Send: one request a builder made, answered as Ok and Status; never throws. #>
    param([Parameter(Mandatory = $true)]$Request, [Parameter(Mandatory = $true)][string]$Pat)
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

function Invoke-AsanaTaskMove {
    <#
        Move each -Target (objects with Label and Gid) into the section of the board -ProjectGid whose
        code is -Section. Returns one result line per target as text ('[MOVED] ...', '[DRY-RUN] ...',
        '[SKIP] ...', '[FAILED] ...'); throws only for a bad section code, an unreadable board, or a
        missing PAT. A task that is not a member of -ProjectGid is skipped, never added to it (#4282).
        -Get is the read (param Uri, answers the parsed reply) and -Send the write (param Request, answers
        Ok and Status), both injectable. Nothing another person wrote is echoed except the section name.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Section,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Target,
        [Parameter(Mandatory = $true)][string]$ProjectGid,
        [string]$Pat = '',
        [switch]$DryRun,
        [scriptblock]$Get = $null,
        [scriptblock]$Send = $null
    )
    if ($ProjectGid -notmatch '\A[0-9]+\z') { throw "The board's project GID is not numeric: '$ProjectGid'." }
    if (-not $Get -and -not $Pat) { throw 'ASANA_PAT is not set.' }
    if (-not $Get) { $Get = { param($Uri) Invoke-RestMethod -Method GET -Uri $Uri -Headers @{ Authorization = "Bearer $Pat" } } }
    if (-not $Send) { $Send = { param($Request) Invoke-AsanaSend -Request $Request -Pat $Pat } }

    try {
        $read = & $Get "$script:AsanaApiBase/projects/$ProjectGid/sections?opt_fields=name"
    } catch { throw 'The sections of the repo board could not be read.' }
    $sections = @(@($read.data) | ForEach-Object { [pscustomobject]@{ Gid = [string]$_.gid; Name = [string]$_.name } })
    $sectionGid = Find-SectionGid -Sections $sections -Code $Section
    $sectionName = (@($sections | Where-Object { $_.Gid -eq $sectionGid })[0]).Name

    $lines = @()
    foreach ($t in @($Target)) {
        $gid = [string]$t.Gid
        if ($gid -notmatch '\A[0-9]+\z') { $lines += "[SKIP] $($t.Label) carries no usable task GID"; continue }
        try {
            $task = & $Get "$script:AsanaApiBase/tasks/$($gid)?opt_fields=memberships.project.gid"
        } catch { $lines += "[SKIP] $($t.Label) ($gid): the task could not be read"; continue }
        $boards = @(@($task.data.memberships) | ForEach-Object { [string]$_.project.gid })
        if ($boards -notcontains $ProjectGid) { $lines += "[SKIP] $($t.Label) ($gid) is not on the repo's board"; continue }
        if ($DryRun) { $lines += "[DRY-RUN] $($t.Label) ($gid) -> $sectionName"; continue }
        $result = & $Send (New-AsanaMoveRequest -Gid $gid -SectionGid $sectionGid)
        if ($result.Ok) { $lines += "[MOVED] $($t.Label) ($gid) -> $sectionName" }
        else { $lines += "[FAILED] $($t.Label) ($gid): $($result.Status)" }
    }
    return $lines
}
