<#
.SYNOPSIS
    Measures what this repo's recent sessions SPENT LOOKING -- searches, reads, re-reads, the lookups made
    before the first edit, reverted edits and tokens -- so a retro can name the doc that cost them (#3905).

.DESCRIPTION
    WHY IT EXISTS. This workflow measures what every session pays UP FRONT: the always-on budget, what a
    skill costs (measure-skill), what the session start loads (measure-session-start). It did not measure
    the other half of the same cost: what a session spends FINDING things once the work is known. A
    session that greps forty times before it edits, or reads the same lens five times, is paying for a
    missing pointer or a stale doc, and the constitution already says where that lesson goes -- into the
    doc that owns it. A retro names which doc; this script finds where to look.

    WHAT IT COUNTS, PER SESSION. Searches (Grep, Glob, and a shell segment led by grep, rg, find,
    Select-String, Get-ChildItem and their kin), delegated explorations (an Agent call of type Explore),
    web lookups, reads (the Read tool, with the distinct paths, so a re-read is visible) and shell reads
    (cat, Get-Content, sed -n and kin), edits, LOOKUPS BEFORE THE FIRST EDIT (the headline: every search
    and read a session made before it changed anything), REVERTED EDITS (an Edit that undoes an earlier
    Edit of the same file exactly), and the tokens the session's assistant turns report. And ACROSS
    sessions, the files read most often: a file read in most sessions, or re-read within them, is the
    first candidate for a missing pointer or a summary that should exist.

    LESS SEARCHING ALONE PROVES NOTHING, and that is why the edits are counted beside it. A session that
    searched little and then reverted three edits did not find the right thing faster -- it found the
    wrong thing sooner. Compare reverted edits along with lookups, before and after a change.

    BEFORE AND AFTER, which is the way to use it. -Until <date> reads the sessions before a change and
    -Since <date> the sessions after it; the medians of the two runs are the comparison. Both filter on
    the transcript's last write.

    IT IS A MEASUREMENT, NOT A GATE. It always exits 0, reads only, and reaches no verdict about any
    session -- the boundary measure-closeouts.ps1 and measure-always-on.ps1 beside it hold, for the same
    reason. The judgement (was this search a missing pointer, a stale doc, or just the work?) is the
    model's, on the skill page, after opening the sessions this report names.

    WHAT LEAVES IT: COUNTS, SESSION IDS AND FILE PATHS -- NEVER TRANSCRIPT TEXT. No search pattern, no
    message, no tool output is printed or written. Paths are made repo-relative; a path in the plugin
    cache or elsewhere under ~/.claude is shown from '~/.claude/'; anything else is '(outside the repo)',
    so a user name in a home path never reaches a report that may be quoted in a public tracker. The
    transcripts are read in place under ~/.claude/projects and never written to.

    WHICH SESSIONS: THIS REPO'S, by default -- unlike measure-closeouts, which measures the machine. The
    paths it names belong to one repo, and the issues a retro files belong in that repo's tracker. The
    project directory Claude Code keeps for a checkout is its path with every character outside
    [A-Za-z0-9] turned into '-'; the default reads that directory and its worktree lanes'
    ('<repo>-lanes-*'). -Project takes a wildcard instead.

    ONLY THE TOP-LEVEL TRANSCRIPTS. A dispatched subagent's own transcript is not read: what the main
    thread delegated is counted at the delegation (an Explore call), not inside it.

.PARAMETER TranscriptRoot
    Where the session transcripts live. Defaults to ~/.claude/projects.

.PARAMETER Project
    A wildcard over the project directory names to read. Default: this checkout's own directory and its
    worktree lanes'.

.PARAMETER Last
    How many sessions to read, most recent first, after -Since and -Until. Defaults to 10.

.PARAMETER Since
    Read only sessions whose transcript was last written at or after this date.

.PARAMETER Until
    Read only sessions whose transcript was last written before this date.

.PARAMETER Top
    How many sessions and files the report lists. Defaults to 10.

.PARAMETER Json
    Emit the result as JSON on stdout instead of the human report.
#>
[CmdletBinding()]
param(
    [string]$TranscriptRoot = (Join-Path $HOME '.claude\projects'),
    [string]$Project = '',
    [int]$Last = 10,
    [Nullable[datetime]]$Since = $null,
    [Nullable[datetime]]$Until = $null,
    [int]$Top = 10,
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Invariant formatting, for measure-closeouts.ps1's reason: a figure meant to be quoted must not change
# spelling with the machine's locale.
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture

# The source-repo guard, as on every instrument: in the repo this is maintained in, the plugin-cache copy
# lags the tree, and a stale instrument hands back a plausible number rather than failing.
$guardLib = Join-Path $PSScriptRoot '..\lib\source-repo-guard-lib.ps1'
if (Test-Path -LiteralPath $guardLib -PathType Leaf) { . $guardLib; Assert-OwnCopy -ScriptPath $PSCommandPath }

# The repo root, dual-context: CLAUDE_PROJECT_DIR for a consumer running the mirror, otherwise the git
# root (repo-root-lib, never rev-parse --show-toplevel -- #2115).
. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
$repoRoot = $null
if ($env:CLAUDE_PROJECT_DIR) { $repoRoot = $env:CLAUDE_PROJECT_DIR }
else { try { $repoRoot = (Get-GitTopLevelPath).Path } catch { $repoRoot = $null } }
if ($repoRoot) { $repoRoot = [System.IO.Path]::GetFullPath($repoRoot.Trim()).TrimEnd('\', '/') }

$script:SearchLeads = '^(grep|egrep|fgrep|rg|ag|ack|find|fd|tree|select-string|sls|get-childitem|gci|ls|dir|git\s+grep|git\s+log\s+.*-[SG])(\s|$)'
$script:ReadLeads   = '^(cat|head|tail|less|more|type|get-content|gc|sed\s+-n)(\s|$)'
$script:EditTools   = @('Edit', 'Write', 'MultiEdit', 'NotebookEdit')

function Get-TranscriptProjectName {
    <# The project directory name Claude Code keeps for a checkout: its path, every character outside
       [A-Za-z0-9] turned into '-'. #>
    param([string]$Path)
    return ($Path -replace '[^A-Za-z0-9]', '-')
}

function Get-Field {
    <# A property's value, or $null when the object does not carry it -- StrictMode-safe. #>
    param($Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    if ($Object.PSObject.Properties.Name -contains $Name) { return $Object.$Name }
    return $null
}

function ConvertTo-ReportPath {
    <#
    .SYNOPSIS
        A file path as the report may show it: repo-relative, '~/.claude/...', or '(outside the repo)'.

    .DESCRIPTION
        A worktree lane ('<repo>-lanes\<lane>\...') is folded onto the repo, since it is the same tree. The
        fallback hides the path entirely, because a home directory carries a user name and this report
        may be quoted into a public tracker.
    #>
    param([string]$Path, [string]$RepoRoot)

    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    $p = $Path -replace '/', '\'
    if ($RepoRoot) {
        $root = $RepoRoot -replace '/', '\'
        if ($p.StartsWith($root + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
            return ($p.Substring($root.Length + 1) -replace '\\', '/')
        }
        $lanes = $root + '-lanes\'
        if ($p.StartsWith($lanes, [System.StringComparison]::OrdinalIgnoreCase)) {
            $rest = $p.Substring($lanes.Length)
            $cut = $rest.IndexOf('\')
            if ($cut -ge 0) { return ($rest.Substring($cut + 1) -replace '\\', '/') }
        }
    }
    $claudeHome = (Join-Path $HOME '.claude') -replace '/', '\'
    if ($p.StartsWith($claudeHome + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        return ('~/.claude/' + ($p.Substring($claudeHome.Length + 1) -replace '\\', '/'))
    }
    return '(outside the repo)'
}

function Get-ShellCommandKind {
    <#
    .SYNOPSIS
        'search', 'read' or '' for one shell command line: the first segment that is either decides.

    .DESCRIPTION
        The line is split on && || ; and |, so `cd x && grep -r y` is a search. One call counts once
        however many segments match: a pipeline of three greps is one lookup.
    #>
    param([string]$Command)

    if ([string]::IsNullOrWhiteSpace($Command)) { return '' }
    foreach ($segment in ($Command -split '&&|\|\||;|\|')) {
        $s = $segment.Trim().TrimStart('(', '{', '&', ' ').ToLower()
        if ($s -match $script:SearchLeads) { return 'search' }
        if ($s -match $script:ReadLeads) { return 'read' }
    }
    return ''
}

function Measure-RetroTranscript {
    <#
    .SYNOPSIS
        One session's lookup cost, from its records in order. Returns $null when it made no tool call.

    .DESCRIPTION
        A LINE THAT DOES NOT PARSE IS SKIPPED, for measure-closeouts' reason: transcripts are appended to
        while sessions run, so a half-written last line is ordinary. Only assistant records are parsed,
        which is where tool calls and usage live, and the cheap string test runs before the JSON parse.

        THE EDIT STRINGS ARE COMPARED IN MEMORY AND NEVER LEAVE THIS FUNCTION. A reverted edit is an Edit
        whose old_string and new_string are an earlier Edit's of the same file, swapped.
    #>
    param([string]$Path, [string]$RepoRoot)

    $searches = 0; $explores = 0; $web = 0; $reads = 0; $shellReads = 0; $edits = 0; $tools = 0
    $reverted = 0; $beforeFirstEdit = 0; $firstEditSeen = $false
    $inTokens = 0L; $outTokens = 0L
    $readPaths = @{}
    $editPairs = New-Object 'System.Collections.Generic.HashSet[string]'

    foreach ($line in [System.IO.File]::ReadLines($Path)) {
        if ($line.IndexOf('"type":"assistant"') -lt 0) { continue }
        try { $rec = $line | ConvertFrom-Json } catch { continue }
        $msg = Get-Field $rec 'message'
        if (-not $msg) { continue }

        $usage = Get-Field $msg 'usage'
        if ($usage) {
            foreach ($f in 'input_tokens', 'cache_creation_input_tokens', 'cache_read_input_tokens') {
                $v = Get-Field $usage $f; if ($v) { $inTokens += [long]$v }
            }
            $o = Get-Field $usage 'output_tokens'; if ($o) { $outTokens += [long]$o }
        }

        $content = Get-Field $msg 'content'
        if (-not $content -or $content -is [string]) { continue }
        foreach ($block in $content) {
            if ((Get-Field $block 'type') -ne 'tool_use') { continue }
            $tools++
            $name = [string](Get-Field $block 'name')
            $inputObj = Get-Field $block 'input'
            $lookup = $false

            switch -Regex ($name) {
                '^(Grep|Glob)$' { $searches++; $lookup = $true; break }
                '^(WebSearch|WebFetch)$' { $web++; $lookup = $true; break }
                '^(Agent|Task)$' {
                    if ([string](Get-Field $inputObj 'subagent_type') -eq 'Explore') { $explores++; $lookup = $true }
                    break
                }
                '^Read$' {
                    $reads++; $lookup = $true
                    $rp = ConvertTo-ReportPath -Path ([string](Get-Field $inputObj 'file_path')) -RepoRoot $RepoRoot
                    if ($rp) { if ($readPaths.ContainsKey($rp)) { $readPaths[$rp]++ } else { $readPaths[$rp] = 1 } }
                    break
                }
                '^(Bash|PowerShell)$' {
                    $kind = Get-ShellCommandKind -Command ([string](Get-Field $inputObj 'command'))
                    if ($kind -eq 'search') { $searches++; $lookup = $true }
                    elseif ($kind -eq 'read') { $shellReads++; $lookup = $true }
                    break
                }
            }

            if ($script:EditTools -contains $name) {
                $edits++
                $firstEditSeen = $true
                if ($name -eq 'Edit') {
                    $fp = [string](Get-Field $inputObj 'file_path')
                    $old = [string](Get-Field $inputObj 'old_string')
                    $new = [string](Get-Field $inputObj 'new_string')
                    $sep = [char]0x1F
                    if ($editPairs.Contains("$fp$sep$new$sep$old")) { $reverted++ }
                    [void]$editPairs.Add("$fp$sep$old$sep$new")
                }
            } elseif ($lookup -and -not $firstEditSeen) {
                $beforeFirstEdit++
            }
        }
    }

    if ($tools -eq 0) { return $null }
    $distinct = $readPaths.Count
    return [pscustomobject]@{
        Session               = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        ToolCalls             = $tools
        Searches              = $searches
        Explores              = $explores
        WebLookups            = $web
        Reads                 = $reads
        DistinctReads         = $distinct
        ReReads               = $reads - $distinct
        ShellReads            = $shellReads
        Edits                 = $edits
        LookupsBeforeFirstEdit = if ($firstEditSeen) { $beforeFirstEdit } else { $null }
        RevertedEdits         = $reverted
        InputTokens           = $inTokens
        OutputTokens          = $outTokens
        ReadPaths             = $readPaths
    }
}

function Get-Median {
    param([double[]]$Values)
    $sorted = @($Values | Sort-Object)
    if ($sorted.Count -eq 0) { return $null }
    $mid = [int][math]::Floor(($sorted.Count - 1) / 2)
    if ($sorted.Count % 2 -eq 1) { return $sorted[$mid] }
    return [math]::Round(($sorted[$mid] + $sorted[$mid + 1]) / 2, 1)
}

# ---------------------------------------------------------------------------------------------------
# Collect
# ---------------------------------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $TranscriptRoot -PathType Container)) {
    Write-Host "[SKIP] No transcript root at '$TranscriptRoot' -- nothing to measure." -ForegroundColor Yellow
    exit 0
}

$patterns = @()
if ($Project) { $patterns = @($Project) }
elseif ($repoRoot) {
    $own = Get-TranscriptProjectName -Path $repoRoot
    $patterns = @($own, "$own-lanes-*")
} else {
    Write-Host "[SKIP] Not inside a repository and no -Project given -- name the sessions to read with -Project." -ForegroundColor Yellow
    exit 0
}

$files = @(Get-ChildItem -LiteralPath $TranscriptRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $d = $_.Name; @($patterns | Where-Object { $d -like $_ }).Count -gt 0 } |
    ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Filter *.jsonl -File -ErrorAction SilentlyContinue } |
    Where-Object { (-not $Since -or $_.LastWriteTime -ge $Since) -and (-not $Until -or $_.LastWriteTime -lt $Until) } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First $Last)

$rows = New-Object System.Collections.Generic.List[object]
$skipped = 0
foreach ($file in $files) {
    try {
        $row = Measure-RetroTranscript -Path $file.FullName -RepoRoot $repoRoot
        if ($row) {
            $row | Add-Member -NotePropertyName LastWrite -NotePropertyValue $file.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
            $row | Add-Member -NotePropertyName Transcript -NotePropertyValue (ConvertTo-ReportPath -Path $file.FullName -RepoRoot $repoRoot)
            $rows.Add($row)
        } else { $skipped++ }
    } catch { $skipped++ }
}
$all = $rows.ToArray()

# Across sessions: per file, in how many sessions it was read, how often in total, and in how many it was
# read more than once.
$fileStats = @{}
foreach ($r in $all) {
    foreach ($k in $r.ReadPaths.Keys) {
        if (-not $fileStats.ContainsKey($k)) { $fileStats[$k] = [pscustomobject]@{ Path = $k; Sessions = 0; Reads = 0; ReReadIn = 0 } }
        $fs = $fileStats[$k]
        $fs.Sessions++
        $fs.Reads += $r.ReadPaths[$k]
        if ($r.ReadPaths[$k] -gt 1) { $fs.ReReadIn++ }
    }
}
$hotFiles = @($fileStats.Values | Sort-Object @{ Expression = 'Sessions'; Descending = $true }, @{ Expression = 'Reads'; Descending = $true }, Path | Select-Object -First $Top)

$withEdit = @($all | Where-Object { $null -ne $_.LookupsBeforeFirstEdit })
$summary = [pscustomobject]@{
    Sessions                    = $all.Count
    SessionsWithAnEdit          = $withEdit.Count
    MedianSearches              = Get-Median -Values @($all | ForEach-Object { $_.Searches })
    MedianReads                 = Get-Median -Values @($all | ForEach-Object { $_.Reads })
    MedianReReads               = Get-Median -Values @($all | ForEach-Object { $_.ReReads })
    MedianLookupsBeforeFirstEdit = Get-Median -Values @($withEdit | ForEach-Object { $_.LookupsBeforeFirstEdit })
    RevertedEdits               = [int](($all | Measure-Object -Property RevertedEdits -Sum).Sum)
    MedianOutputTokens          = Get-Median -Values @($all | ForEach-Object { $_.OutputTokens })
}

$costly = @($all | Sort-Object @{ Expression = { if ($null -eq $_.LookupsBeforeFirstEdit) { $_.Searches + $_.Reads + $_.ShellReads } else { $_.LookupsBeforeFirstEdit } }; Descending = $true } | Select-Object -First $Top)

# ---------------------------------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------------------------------

if ($Json) {
    [pscustomobject]@{
        MeasuredUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        Projects    = $patterns
        Summary     = $summary
        Sessions    = @($all | Select-Object Session, LastWrite, Transcript, ToolCalls, Searches, Explores, WebLookups, Reads, DistinctReads, ReReads, ShellReads, Edits, LookupsBeforeFirstEdit, RevertedEdits, InputTokens, OutputTokens)
        HotFiles    = $hotFiles
    } | ConvertTo-Json -Depth 5
    exit 0
}

Write-Host ''
Write-Host '== retro: what the recent sessions spent looking ==' -ForegroundColor Cyan
Write-Host "   projects: $($patterns -join ', ')" -ForegroundColor DarkGray
Write-Host "   sessions read: $($all.Count)   without a tool call or unreadable: $skipped" -ForegroundColor DarkGray

if ($all.Count -eq 0) {
    Write-Host ''
    Write-Host '  (nothing measured)' -ForegroundColor DarkGray
    exit 0
}

Write-Host ''
Write-Host 'Medians across these sessions -- the figures to compare before and after a change' -ForegroundColor Cyan
Write-Host ("  searches {0}   reads {1}   re-reads {2}   lookups before the first edit {3} (n={4})" -f $summary.MedianSearches, $summary.MedianReads, $summary.MedianReReads, $summary.MedianLookupsBeforeFirstEdit, $summary.SessionsWithAnEdit)
Write-Host ("  reverted edits {0} in total   output tokens {1}" -f $summary.RevertedEdits, $summary.MedianOutputTokens)

Write-Host ''
Write-Host 'The costliest sessions -- open these and read where the looking went' -ForegroundColor Cyan
Write-Host '  before-edit = searches and reads before the first edit (- = the session never edited)' -ForegroundColor DarkGray
foreach ($r in $costly) {
    $be = if ($null -eq $r.LookupsBeforeFirstEdit) { '-' } else { $r.LookupsBeforeFirstEdit }
    Write-Host ("  {0}  {1}  before-edit {2,3}  searches {3,3}  explores {4,2}  reads {5,3} (re-reads {6,2})  edits {7,3}  reverted {8,2}" -f $r.Session, $r.LastWrite, $be, $r.Searches, $r.Explores, $r.Reads, $r.ReReads, $r.Edits, $r.RevertedEdits)
}

Write-Host ''
Write-Host 'The files read most -- a candidate for a pointer, or a summary that should exist' -ForegroundColor Cyan
foreach ($f in $hotFiles) {
    Write-Host ("  {0,2} sessions  {1,3} reads  re-read in {2,2}  {3}" -f $f.Sessions, $f.Reads, $f.ReReadIn, $f.Path)
}

Write-Host ''
$shownRoot = ConvertTo-ReportPath -Path $TranscriptRoot -RepoRoot $repoRoot
Write-Host "  The transcripts are <session>.jsonl under $shownRoot/<project>; this report quotes none of them." -ForegroundColor DarkGray
Write-Host '  A measurement, not a gate: it reaches no verdict about any session.' -ForegroundColor DarkGray
exit 0
