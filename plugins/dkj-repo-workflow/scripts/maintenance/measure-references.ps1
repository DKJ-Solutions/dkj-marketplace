<#
.SYNOPSIS
    Measures what a specialist's references save: per analysis, the sources taken from the references,
    the sources added to them, and the web searches -- per specialist and per week (issue #4547).

.DESCRIPTION
    WHY IT EXISTS. #4544 made a specialist maintain its own references (the source store its repo lens
    names) and read them before the web. Without a number nobody can tell whether that lookup order
    saves searches and context or only adds a read. This script is that number.

    WHERE THE NUMBERS COME FROM -- TWO SOURCES, AND THEY ARE KEPT APART.
      1. REPORTED. The shared knowledge-lookup block asks every specialist that carries it to end its
         deliverable with one line:
             References: <n> from the store, <n> added, <n> web searches.
         The store is whatever the repo lens names (a Notion database, a folder, ...), so no transcript
         read can count it in general; the specialist's own count is the only store-agnostic source.
      2. MEASURED. The WebSearch and WebFetch tool calls in that same subagent's own transcript. This
         is the half nothing can talk up or down, and printing it beside the reported web searches is
         what shows whether the reported line can be trusted at all.
    A run whose deliverable carries no such line is counted as a run, and its measured web calls are
    still counted -- so "no line" reads as "no line", never as zero reuse.

    WHAT IT READS. Every subagent transcript under ~/.claude/projects/<project>/<session>/subagents/:
    agent-<id>.meta.json for the specialist (agentType) and agent-<id>.jsonl for the calls and the
    deliverable (the SubagentHandback message, else the last assistant text). Built-in agents are
    skipped. Only counts, specialist names, project folder names and ISO weeks leave it -- never a
    line of transcript content.

    This is a measurement, not a gate: it reaches no verdict and always exits 0.

.PARAMETER TranscriptRoot
    The transcript root. Defaults to ~/.claude/projects.

.PARAMETER Project
    A wildcard on the project folder name. Defaults to '*' (every repo on this machine).

.PARAMETER Since
    Only runs on or after this date (yyyy-MM-dd). Defaults to every run.

.PARAMETER All
    Also list specialists whose runs never reported a line. By default only specialists that reported
    at least once are listed, since the rest do not carry the block.

.PARAMETER Json
    Emit the result as JSON (per specialist, plus a per-week series) instead of the console table --
    the shape an Admin chart reads.
#>
[CmdletBinding()]
param(
    [string]$TranscriptRoot = (Join-Path $HOME '.claude\projects'),
    [string]$Project = '*',
    [string]$Since = '',
    [switch]$All,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Invariant formatting, for measure-closeouts.ps1's reason: a figure that is quoted must read the same
# on a Dutch-locale machine as on a US one.
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture

# The source-repo guard, as in every mirrored instrument: in the repo this file is maintained in, the
# plugin-cache copy lags this tree, and a stale instrument reports a plausible number.
$guardLib = Join-Path $PSScriptRoot '..\lib\source-repo-guard-lib.ps1'
if (Test-Path -LiteralPath $guardLib -PathType Leaf) { . $guardLib; Assert-OwnCopy -ScriptPath $PSCommandPath }

# The line the knowledge-lookup block asks for. Tolerant of case, of a missing full stop and of
# markdown around it (backticks, bold), because a specialist writes it inside a deliverable.
$script:LinePattern = '(?im)References:\s*(\d+)\s+from the store,\s*(\d+)\s+added,\s*(\d+)\s+web searches?'

# The tools a web search reaches the web through.
$script:WebTools = @('WebSearch', 'WebFetch')

function Get-ReferenceLine {
    <#
    .SYNOPSIS
        The last References line in a deliverable, as three counts -- or $null when it carries none.
    #>
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    $m = [regex]::Matches($Text, $script:LinePattern)
    if ($m.Count -eq 0) { return $null }
    $last = $m[$m.Count - 1]
    return [pscustomobject]@{
        FromStore = [int]$last.Groups[1].Value
        Added     = [int]$last.Groups[2].Value
        Web       = [int]$last.Groups[3].Value
    }
}

function Get-IsoWeek {
    param([datetime]$Date)
    $cal = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
    # ISO 8601: the week belongs to the year of its Thursday.
    $thursday = $Date.Date.AddDays(3 - (([int]$Date.DayOfWeek + 6) % 7))
    $week = $cal.GetWeekOfYear($thursday, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Monday)
    return ('{0}-W{1:00}' -f $thursday.Year, $week)
}

function Measure-OneSubagent {
    <#
    .SYNOPSIS
        One subagent run: its specialist, its date, its measured web calls and its reported line.
    #>
    param([string]$MetaPath, [string]$ProjectName)

    try { $meta = Get-Content -LiteralPath $MetaPath -Raw | ConvertFrom-Json } catch { return $null }
    if (-not ($meta.PSObject.Properties.Name -contains 'agentType') -or -not $meta.agentType) { return $null }
    if (($meta.PSObject.Properties.Name -contains 'isBuiltIn') -and $meta.isBuiltIn) { return $null }

    $jsonl = $MetaPath -replace '\.meta\.json$', '.jsonl'
    if (-not (Test-Path -LiteralPath $jsonl -PathType Leaf)) { return $null }

    $webCalls = 0
    $handback = ''
    $lastText = ''
    $stamp = $null
    # A line that does not parse is skipped rather than fatal: these files are appended to while a
    # session runs, so a half-written last line is ordinary.
    foreach ($line in @(Get-Content -LiteralPath $jsonl -ErrorAction SilentlyContinue)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $rec = $line | ConvertFrom-Json } catch { continue }
        if (-not $stamp -and ($rec.PSObject.Properties.Name -contains 'timestamp') -and $rec.timestamp) {
            try { $stamp = [datetime]::Parse([string]$rec.timestamp, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AdjustToUniversal) } catch { $stamp = $null }
        }
        if (-not ($rec.PSObject.Properties.Name -contains 'type') -or $rec.type -ne 'assistant') { continue }
        if (-not ($rec.PSObject.Properties.Name -contains 'message') -or -not $rec.message) { continue }
        if (-not ($rec.message.PSObject.Properties.Name -contains 'content') -or -not $rec.message.content) { continue }
        if ($rec.message.content -is [string]) { $lastText = $rec.message.content; continue }
        $texts = @()
        foreach ($block in $rec.message.content) {
            if ($block.type -eq 'tool_use') {
                if ($script:WebTools -contains $block.name) { $webCalls++ }
                if ($block.name -eq 'SubagentHandback' -and $block.input -and ($block.input.PSObject.Properties.Name -contains 'message')) {
                    $handback = [string]$block.input.message
                }
            } elseif ($block.type -eq 'text' -and -not [string]::IsNullOrWhiteSpace($block.text)) {
                $texts += $block.text
            }
        }
        if ($texts.Count -gt 0) { $lastText = ($texts -join "`n") }
    }

    if (-not $stamp) { $stamp = (Get-Item -LiteralPath $jsonl).LastWriteTimeUtc }
    $deliverable = if ($handback) { $handback } else { $lastText }
    $reported = Get-ReferenceLine -Text $deliverable

    $name = [string]$meta.agentType
    if ($name -match ':') { $name = $name.Substring($name.LastIndexOf(':') + 1) }

    return [pscustomobject]@{
        Specialist = $name
        Project    = $ProjectName
        Date       = $stamp
        Week       = Get-IsoWeek -Date $stamp
        WebCalls   = $webCalls
        Reported   = $reported
    }
}

function Get-Summary {
    <#
    .SYNOPSIS
        The totals of a set of runs: runs, runs that reported, the three reported sums, measured web calls.
    #>
    param($Runs)
    $runs = @($Runs)
    $rep = @($runs | Where-Object { $_.Reported })
    $sum = { param($field) $t = 0; foreach ($r in $rep) { $t += $r.Reported.$field }; $t }
    $measured = 0; foreach ($r in $runs) { $measured += $r.WebCalls }
    $measuredRep = 0; foreach ($r in $rep) { $measuredRep += $r.WebCalls }
    $fromStore = & $sum 'FromStore'
    $web = & $sum 'Web'
    return [pscustomobject]@{
        Runs              = $runs.Count
        Reported          = $rep.Count
        FromStore         = $fromStore
        Added             = & $sum 'Added'
        WebReported       = $web
        WebMeasured       = $measured
        WebMeasuredInRep  = $measuredRep
        # Of the sources an analysis started from, the share the references already held.
        ReuseShare        = if (($fromStore + $web) -gt 0) { [math]::Round($fromStore / ($fromStore + $web), 3) } else { $null }
    }
}

# ---------------------------------------------------------------------------------------------------

$sinceDate = $null
if ($Since) {
    try { $sinceDate = [datetime]::ParseExact($Since, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture) }
    catch { Write-Host "[SKIP] -Since '$Since' is not a yyyy-MM-dd date -- nothing measured." -ForegroundColor Yellow; exit 0 }
}

$runs = New-Object System.Collections.Generic.List[object]
if (Test-Path -LiteralPath $TranscriptRoot -PathType Container) {
    foreach ($proj in @(Get-ChildItem -LiteralPath $TranscriptRoot -Directory | Where-Object { $_.Name -like $Project })) {
        foreach ($meta in @(Get-ChildItem -LiteralPath $proj.FullName -Recurse -Filter 'agent-*.meta.json' -File -ErrorAction SilentlyContinue)) {
            $run = Measure-OneSubagent -MetaPath $meta.FullName -ProjectName $proj.Name
            if (-not $run) { continue }
            if ($sinceDate -and $run.Date -lt $sinceDate) { continue }
            $runs.Add($run)
        }
    }
}

$bySpecialist = @($runs | Group-Object Specialist | Sort-Object Name)
$rows = foreach ($g in $bySpecialist) {
    $s = Get-Summary -Runs $g.Group
    if (-not $All -and $s.Reported -eq 0) { continue }
    $weeks = foreach ($w in @($g.Group | Group-Object Week | Sort-Object Name)) {
        $ws = Get-Summary -Runs $w.Group
        [pscustomobject]@{ Week = $w.Name; Runs = $ws.Runs; Reported = $ws.Reported; FromStore = $ws.FromStore; Added = $ws.Added; WebReported = $ws.WebReported; WebMeasured = $ws.WebMeasured }
    }
    [pscustomobject]@{
        Specialist = $g.Name
        Runs = $s.Runs; Reported = $s.Reported; FromStore = $s.FromStore; Added = $s.Added
        WebReported = $s.WebReported; WebMeasured = $s.WebMeasured; WebMeasuredInReported = $s.WebMeasuredInRep
        ReuseShare = $s.ReuseShare
        Weeks = @($weeks)
    }
}
$rows = @($rows)

if ($Json) {
    [pscustomobject]@{
        Project        = $Project
        Since          = $Since
        Runs           = $runs.Count
        Specialists    = $rows
    } | ConvertTo-Json -Depth 6
    exit 0
}

Write-Host ''
Write-Host "measure-references -- what the references save, per specialist (#4547)" -ForegroundColor Cyan
Write-Host ("  {0} subagent run(s) read under the project filter '{1}'{2}." -f $runs.Count, $Project, $(if ($Since) { ", since $Since" } else { '' }))
Write-Host '  REPORTED = the References line the specialist ended its deliverable with;'
Write-Host '  MEASURED = WebSearch + WebFetch calls in that run''s own transcript.'
Write-Host ''
if ($rows.Count -eq 0) {
    Write-Host '  No run ended with a References line yet. The line arrives with the release that ships #4547,'
    Write-Host '  so measure again once specialists carrying the knowledge-lookup block have run. (-All lists'
    Write-Host '  every specialist''s measured web calls meanwhile.)'
    Write-Host ''
    exit 0
}

$fmt = '  {0,-12} {1,5} {2,9} {3,10} {4,6} {5,12} {6,12} {7,7}'
Write-Host ($fmt -f 'specialist', 'runs', 'reported', 'from store', 'added', 'web (rep.)', 'web (meas.)', 'reuse') -ForegroundColor DarkGray
foreach ($r in $rows) {
    $reuse = if ($null -eq $r.ReuseShare) { 'n/a' } else { ('{0}%' -f [math]::Round($r.ReuseShare * 100)) }
    Write-Host ($fmt -f $r.Specialist, $r.Runs, $r.Reported, $r.FromStore, $r.Added, $r.WebReported, $r.WebMeasured, $reuse)
}
Write-Host ''
Write-Host '  reuse = from store / (from store + web searches), over the runs that reported. A rising reuse'
Write-Host '  with falling web searches week over week is the store paying off; -Json carries the weeks.'
Write-Host '  Where web (rep.) and the measured calls of the same runs diverge, the reported line is not'
Write-Host '  being counted honestly, and the reported columns should not be read on their own.'
Write-Host ''
exit 0
