<#
.SYNOPSIS
    The bounded pull-request scan the session-start tracker checks share: one filtered `gh pr list`,
    then one `gh pr checks --required` per record under a total wall-clock budget, each record handed
    to the caller's own verdict (issue #2526).

.DESCRIPTION
    WHY THIS FILE EXISTS. check-stranded-sweep.ps1 (#2438) and check-unshipped-pr.ps1 (#2525) carried
    the same ~100-line scaffold twice: the list read and its quiet failure, the per-record required-check
    read, the two budgets (-TimeoutSeconds per call, -MaxElapsedSeconds in total) with the honest
    judged/unjudged split, the ASCII display scrub and the Get-PasteableRef checkout token. They differed
    only in the list filter, the verdict, and the prose around the report. Any repair to the pattern --
    a timeout, a new failure mode, how the resume line prints -- had to land in both by hand, so the
    pattern lives here once and each check keeps only what is genuinely its own.

    WHAT IT DOES NOT TAKE. The preamble -- root resolution, the gh/account/repo-name gates and the order
    they run in -- stays in each script. The order is a per-check decision (check-stranded-sweep.ps1 asks
    about its workflow file before anything else, because without it there is nothing to ask gh), and the
    cheap gates run before the heavy libs are loaded at all, which a function in a lib cannot do for the
    script that loads it.

    NOT PURE, UNLIKE merge-on-green-lib.ps1: this file makes the `gh` reads that lib deliberately does
    not. It is the reading half; the verdicts stay pure over there.

    READ-ONLY: `gh pr list` and `gh pr checks`. Nothing is merged, labelled, commented on or pushed.

    DEPENDENCIES, LOADED BY THE CALLER (this file dot-sources nothing): native-capture-lib.ps1
    (Invoke-NativeCapture, Test-NativeCommandStarted, Test-NativeExitMeasured), pr-issues-lib.ps1
    (Get-MergeBlockVerdict), merge-on-green-lib.ps1 (ConvertFrom-MergeOnGreenListJson,
    Get-RequiredGreenAgeMinutes) and ref-print-lib.ps1 (Get-PasteableRef).

    Pure ASCII, per this repo's script-layer convention.
#>

function Invoke-BoundedPrScan {
    <#
    .SYNOPSIS
        List open pull requests, judge each against its required checks within a total budget, and
        return the findings with the judged/unjudged split.

    .DESCRIPTION
        Status is one of:
          - 'ListFailed'  -- the list read did not start, timed out or exited non-zero (offline, a rate
                             limit, a transient outage). Not a finding: the caller prints its quiet [SKIP].
          - 'ParseFailed' -- the list answered with something that is not the expected JSON.
          - 'Scanned'     -- Total records were read; JudgedCount + UnjudgedCount always equals Total.

        A record is UNJUDGED when the budget is spent before it is reached, when it carries no number,
        or when its own required-check read fails -- fail closed for that one record rather than
        abandoning the rest, and never folded silently into "nothing found" (#2438).

        THE BUDGET STARTS HERE, just before the list read: everything a caller does before this call is
        local feature detection, and counting it would only make the budget less generous.

    .PARAMETER Repo
        The owner/name every gh call is pinned to with --repo.

    .PARAMETER TimeoutSeconds
        How long each gh call gets before it counts as failed. Default 15.

    .PARAMETER MaxElapsedSeconds
        The total wall-clock budget, measured from just before the list read. Once spent, no further
        record is judged and each remaining one counts as unjudged. Default 90.

    .PARAMETER ListFilter
        The arguments that select which pull requests are read, e.g. @('--label', 'merge-when-green')
        or @('--author', 'somebody'). '--state open' and '--limit 100' are always sent.

    .PARAMETER JsonFields
        The --json field list for the list read. Include number, headRefName and title: the findings
        are built from them.

    .PARAMETER Precheck
        (Optional) { param($Record) ... } answering $false for a record that can be declined WITHOUT
        its required-check read -- it is then counted as judged and its `gh pr checks` is not spent.

    .PARAMETER Judge
        { param($Record, $MergeBlockVerdict, $GreenAgeMinutes) ... } answering $null for no finding, or
        a hashtable of extra fields for a finding (an empty @{} is a finding with nothing extra). The
        two verdict inputs are $null where their own parse threw.

    .OUTPUTS
        [pscustomobject] Status, Total, JudgedCount, UnjudgedCount, ReadFailedCount, BudgetCount,
        Findings. ReadFailedCount and BudgetCount say which cause left a record unjudged (#4424); a record
        with no number is the remainder. Each finding carries
        Number, Branch and Title (scrubbed to printable ASCII, for display only), CheckoutToken and
        CheckoutNote (from Get-PasteableRef, judged on the RAW branch name), plus the Judge's fields.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string[]]$ListFilter,
        [Parameter(Mandatory = $true)][string]$JsonFields,
        [Parameter(Mandatory = $true)][scriptblock]$Judge,
        [scriptblock]$Precheck = $null,
        [int]$TimeoutSeconds = 15,
        [int]$MaxElapsedSeconds = 90
    )

    $result = [pscustomobject]@{ Status = ''; Total = 0; JudgedCount = 0; UnjudgedCount = 0; ReadFailedCount = 0; BudgetCount = 0; Findings = @() }

    $scanStart = Get-Date

    $listRead = Invoke-NativeCapture -FilePath 'gh' -DiscardStderr -TimeoutSeconds $TimeoutSeconds -Arguments (@(
        'pr', 'list', '--state', 'open') + $ListFilter + @('--limit', '100', '--repo', $Repo, '--json', $JsonFields))
    if (-not (Test-PrScanReadAnswered -Capture $listRead)) {
        $result.Status = 'ListFailed'
        return $result
    }

    $records = @()
    try {
        $records = @(ConvertFrom-MergeOnGreenListJson -Json ($listRead.Output -join "`n"))
    } catch {
        $result.Status = 'ParseFailed'
        return $result
    }

    $result.Status = 'Scanned'
    $result.Total = $records.Count
    $findings = @()
    $budgetExceeded = $false
    foreach ($record in $records) {
        # THE TOTAL BUDGET, CHECKED ONCE PER RECORD, BEFORE ITS OWN gh CALL (#2438): once spent, every
        # remaining record is counted as unjudged rather than attempted -- this is what keeps the loop's
        # worst case bounded, on top of -TimeoutSeconds bounding each individual call.
        if (-not $budgetExceeded -and ((Get-Date) - $scanStart).TotalSeconds -ge $MaxElapsedSeconds) {
            $budgetExceeded = $true
        }
        if ($budgetExceeded) { $result.UnjudgedCount++; $result.BudgetCount++; continue }

        if ($null -eq $record -or -not $record.PSObject.Properties['number']) { $result.UnjudgedCount++; continue }
        $number = [string]$record.number

        if ($Precheck -and -not (& $Precheck $record)) { $result.JudgedCount++; continue }

        $checksArgs = @('pr', 'checks', $number, '--repo', $Repo, '--required', '--json', 'name,bucket,state,link,completedAt')
        $requiredRead = Invoke-NativeCapture -FilePath 'gh' -DiscardStderr -TimeoutSeconds $TimeoutSeconds -Arguments $checksArgs
        $blockVerdict = $null
        $greenAge = $null
        if (Test-PrScanReadAnswered -Capture $requiredRead) {
            $requiredJson = ($requiredRead.Output -join "`n")
            try { $blockVerdict = Get-MergeBlockVerdict -RequiredChecksJson $requiredJson } catch { $blockVerdict = $null }
            try { $greenAge = Get-RequiredGreenAgeMinutes -RequiredChecksJson $requiredJson -Now (Get-Date) } catch { $greenAge = $null }
        } elseif (Test-PrScanRequiredNotReported -Capture $requiredRead -Arguments $checksArgs -TimeoutSeconds $TimeoutSeconds) {
            # NOT A FAILED READ, A MEASURED "PENDING" (#4424). `gh pr checks --required` exits 1 and prints
            # `no required checks reported on the '<branch>' branch` while CI has not yet CREATED the required
            # check -- in this repo `lint-en-tests` runs after the suite shards, so every freshly armed pull
            # request sits in this state for minutes. Counting it as unjudged left 4 of 8 armed pull requests
            # unjudged on every rerun of one sweep, and a pull request whose required check NEVER appears --
            # the runner-not-firing case [STUCK] exists for -- was never judged at all.
            $blockVerdict = New-PrScanNotReportedVerdict
        } else {
            # FAIL CLOSED FOR THIS ONE RECORD, counted as unjudged: it was never actually checked, so a
            # summary folding it into "nothing found" would report more than it knows (#2438).
            $result.UnjudgedCount++
            $result.ReadFailedCount++
            continue
        }

        $extra = & $Judge $record $blockVerdict $greenAge
        $result.JudgedCount++
        if ($null -eq $extra) { continue }

        $findings += (New-PrScanFinding -Record $record -Number $number -Extra $extra)
    }
    $result.Findings = $findings
    return $result
}

function Test-PrScanReadAnswered {
    <# True when a gh read started, reported an exit, did not time out and exited 0. #>
    param([Parameter(Mandatory = $true)]$Capture)
    return [bool]((Test-NativeCommandStarted -Capture $Capture) -and (Test-NativeExitMeasured -Capture $Capture) `
        -and -not $Capture.TimedOut -and $Capture.ExitCode -eq 0)
}

function Test-PrScanRequiredNotReported {
    <#
    .SYNOPSIS
        True when a failed `gh pr checks --required` read failed because no required check has been
        reported on the head yet -- gh's own words for it -- rather than for any other reason (#4424).
    .DESCRIPTION
        THE FIRST READ DISCARDS STDERR, deliberately: its output is parsed as JSON. gh writes this sentence
        to stderr, so it is asked for once more with stderr merged, and only where the first read reported
        a MEASURED non-zero exit and did not time out. That second read costs one call per record in this
        state and nothing on the ordinary path. Anything that is not that sentence stays a failed read.
    #>
    param(
        [Parameter(Mandatory = $true)]$Capture,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [int]$TimeoutSeconds = 15
    )
    if (-not (Test-NativeCommandStarted -Capture $Capture) -or -not (Test-NativeExitMeasured -Capture $Capture) `
        -or $Capture.TimedOut -or $Capture.ExitCode -eq 0) { return $false }
    $probe = Invoke-NativeCapture -FilePath 'gh' -TimeoutSeconds $TimeoutSeconds -Arguments $Arguments
    if (-not (Test-NativeCommandStarted -Capture $probe) -or -not (Test-NativeExitMeasured -Capture $probe) `
        -or $probe.TimedOut -or $probe.ExitCode -eq 0) { return $false }
    return [bool](($probe.Output | Out-String) -match 'no required checks reported')
}

function New-PrScanNotReportedVerdict {
    <#
    .SYNOPSIS
        The merge-block verdict for a head whose required check has not been reported yet: blocked, no
        failure, nothing named -- in Get-MergeBlockVerdict's shape, so every verdict reads it unchanged.
    #>
    return [pscustomobject]@{
        Blocked            = $true
        Reason             = 'no required check has been reported on this head yet -- CI has not created it'
        FailedRequired     = @()
        FailedOther        = @()
        UnfinishedRequired = @()
    }
}

function New-PrScanFinding {
    <#
    .SYNOPSIS
        One finding: the record's number, its display-safe branch and title, the checkout token, and the
        verdict's own extra fields.

    .DESCRIPTION
        UNTRUSTED DATA. A pull request's branch name and title are chosen by whoever opened it, on a
        repository anybody may open one against. Both are scrubbed with `[^\x20-\x7E]` -> '?' -- the
        pattern Get-MergeOnGreenExecutedPathHit applies to a pushed path -- before either reaches a
        printed line. THAT SCRUB IS FOR PROSE, NOT FOR A COMMAND LINE (Sebastian, #2438): '$', '(', ')',
        '`', ';' and '|' are printable ASCII and pass it untouched, so the checkout token is judged on the
        RAW branch name by Get-PasteableRef (ref-print-lib.ps1, #1594), which answers the branch name
        itself where it is safe to paste, else a placeholder plus a note naming the real branch as prose.
    #>
    param(
        [Parameter(Mandatory = $true)]$Record,
        [Parameter(Mandatory = $true)][string]$Number,
        [hashtable]$Extra = @{}
    )
    $branch = ''
    if ($Record.PSObject.Properties['headRefName']) { $branch = [string]$Record.headRefName }
    $title = ''
    if ($Record.PSObject.Properties['title']) { $title = [string]$Record.title }
    $paste = Get-PasteableRef -Ref $branch

    $fields = [ordered]@{
        Number        = $Number
        Branch        = ($branch -replace '[^\x20-\x7E]', '?')
        Title         = ($title -replace '[^\x20-\x7E]', '?')
        CheckoutToken = $paste.Token
        CheckoutNote  = $paste.Note
    }
    if ($Extra) { foreach ($k in $Extra.Keys) { $fields[$k] = $Extra[$k] } }
    return [pscustomobject]$fields
}

function Get-PrScanIncompleteLine {
    <#
    .SYNOPSIS
        The [INCOMPLETE] line for a scan that left records unjudged, or '' when it left none.
    .PARAMETER Noun
        What the records are, as the report names them -- 'armed', 'open'.
    #>
    param(
        [Parameter(Mandatory = $true)]$Scan,
        [Parameter(Mandatory = $true)][string]$Noun,
        [Parameter(Mandatory = $true)][int]$MaxElapsedSeconds
    )
    if ($Scan.UnjudgedCount -le 0) { return '' }
    # NAME THE CAUSE THAT HIT (#4424): the line used to offer both causes as an "or", so a reader could
    # not tell a budget that ran out (a rerun helps) from reads that fail on every run (a rerun does not).
    $readFailed = 0; $budget = 0
    if ($Scan.PSObject.Properties['ReadFailedCount']) { $readFailed = [int]$Scan.ReadFailedCount }
    if ($Scan.PSObject.Properties['BudgetCount']) { $budget = [int]$Scan.BudgetCount }
    $causes = @()
    if ($readFailed -gt 0) { $causes += "$readFailed whose required-check read failed" }
    if ($budget -gt 0) { $causes += "$budget past the ${MaxElapsedSeconds}s scan budget" }
    $other = $Scan.UnjudgedCount - $readFailed - $budget
    if ($other -gt 0) { $causes += "$other with no readable number" }
    $why = if ($causes.Count -gt 0) { $causes -join ', ' } else { 'cause not recorded' }
    $remedy = if ($budget -gt 0) { 'run this again to cover them' } else { 'a rerun reads them the same way, so read one by hand: gh pr checks <n> --required' }
    return "[INCOMPLETE] judged $($Scan.JudgedCount) of $($Scan.Total) $Noun pull request(s); $($Scan.UnjudgedCount) not checked: $why -- $remedy."
}

function Get-PrScanResumeLines {
    <#
    .SYNOPSIS
        The printed resume for one finding: a checkout, the note where the branch was not safe to
        paste, and a bare ship-pr run.
    .DESCRIPTION
        SHIP-PR.PS1 TAKES NO -Pr OR -Branch PARAMETER: it resumes the open pull request of the CURRENT
        branch, so the resume is a checkout followed by a bare run -- two commands, not one chained with
        '&&', which Windows PowerShell 5.1 does not have.

        THE PATH IS THE ONE THAT EXISTS (inbound #2825). 'scripts/release/ship-pr.ps1' is the source
        repo's own copy, and a consumer has none: its scripts/release/ holds open-pr.ps1 at most, so the
        printed command failed there with "the argument to the -File parameter does not exist". The repo's
        own copy is named where -RepoRoot has one, and otherwise the copy that travels beside this lib --
        the plugin's, in the cache -- quoted as a full path.
    #>
    param(
        [Parameter(Mandatory = $true)]$Finding,
        [string]$RepoRoot = ''
    )
    $lines = @("    git checkout $($Finding.CheckoutToken)")
    if ($Finding.CheckoutNote) { $lines += $Finding.CheckoutNote }
    $lines += "    powershell -NoProfile -ExecutionPolicy Bypass -File $(Get-PrScanShipPrPath -RepoRoot $RepoRoot)"
    return $lines
}

function Get-PrScanShipPrPath {
    <#
    .SYNOPSIS
        The ship-pr.ps1 a resume line should name: the repo's own 'scripts/release/ship-pr.ps1' where it
        exists under -RepoRoot, else this lib's sibling in the plugin, as a quoted full path (#2825).
    #>
    param([string]$RepoRoot = '')
    if ($RepoRoot -and (Test-Path -LiteralPath (Join-Path $RepoRoot 'scripts\release\ship-pr.ps1') -PathType Leaf)) {
        return 'scripts/release/ship-pr.ps1'
    }
    $sibling = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\release\ship-pr.ps1'))
    return "`"$sibling`""
}
