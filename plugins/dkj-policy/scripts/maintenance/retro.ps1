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

    WHAT IT COUNTS, PER SESSION.
      - LOOKUPS, of five kinds: searches (Grep, Glob, and a shell command led by grep, rg, find,
        Select-String, a recursive or filtered Get-ChildItem, git grep, or git log -S/-G), delegated
        explorations (an Agent call of type Explore), web lookups (WebSearch, WebFetch), reads (the Read
        tool; a re-read is a second read of the same file) and shell reads (cat, head, tail,
        Get-Content, sed -n and kin). A plain directory listing is not a lookup, and neither is a filter
        over a command's own output: `npm test | tail` reads nothing, so only the part of a pipeline
        before its first `|` is classified.
      - EDITS: an Edit, Write, MultiEdit or NotebookEdit that SUCCEEDED and landed IN THE REPO. A failed
        call (its tool_result is an error) and a write to a scratch or plan file outside the repo are not
        the session changing the work.
      - LOOKUPS BEFORE THE FIRST EDIT, the headline: every lookup before the session first changed the
        repo. A session that never edits reports none, not zero.
      - REVERTED EDITS: an Edit that undoes an earlier Edit of the same file exactly.
      - TOKENS, once per assistant message. Claude Code writes one record per content block and repeats
        the message's usage on each, so the usage is summed per message id, not per record.
    And ACROSS sessions, the repo files read most often: a file read in most sessions, or re-read within
    them, is the first candidate for a missing pointer or a summary that should exist.

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

    WHAT LEAVES IT: COUNTS, SESSION IDS AND FILE PATHS -- NEVER TRANSCRIPT TEXT, AND NO HOME PATH. No
    search pattern, message or tool output is printed or written. A path is shown repo-relative when it
    is inside the repo (normalised first, so '..' cannot climb out), as itself under ~/.claude/plugins
    (the plugin cache and the marketplace clones, which are public content), as '~/.claude/(other)'
    anywhere else under ~/.claude (memory and plan files are named after what they hold), and as
    '(outside the repo)' everywhere else. The project directory names Claude Code keeps encode the
    absolute checkout path, user name included, so the scope is printed as a description, never as the
    name, and no transcript path is emitted: the session id finds the file. The transcripts are read in
    place under ~/.claude/projects and never written to.

    WHICH SESSIONS: THIS REPO'S, by default -- unlike measure-closeouts, which measures the machine. The
    paths it names belong to one repo, and the issues a retro files belong in that repo's tracker. The
    project directory Claude Code keeps for a checkout is its path with every character outside
    [A-Za-z0-9] turned into '-'; the default reads the main checkout's directory and its worktree lanes'
    ('<repo>-lanes-*'), and run from inside a lane it resolves the main checkout first. -Project takes a
    wildcard instead.

    ONLY THE TOP-LEVEL TRANSCRIPTS. A dispatched subagent's own transcript is not read: what the main
    thread delegated is counted at the delegation (an Explore call), not inside it.

.PARAMETER TranscriptRoot
    Where the session transcripts live. Defaults to ~/.claude/projects.

.PARAMETER Project
    A wildcard over the project directory names to read. Default: this repo's main checkout and its
    worktree lanes.

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
# root (repo-root-lib, never rev-parse --show-toplevel -- #2115). A worktree lane ('<repo>-lanes\<lane>')
# resolves to its main checkout, so a retro run from a lane reads the same sessions as one run from the
# primary.
. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
$repoRoot = $null
if ($env:CLAUDE_PROJECT_DIR) { $repoRoot = $env:CLAUDE_PROJECT_DIR }
else { try { $repoRoot = (Get-GitTopLevelPath).Path } catch { $repoRoot = $null } }
if ($repoRoot) {
    $repoRoot = [System.IO.Path]::GetFullPath($repoRoot.Trim()).TrimEnd('\', '/')
    if ($repoRoot -match '^(.+)-lanes[\\/][^\\/]+$') { $repoRoot = $Matches[1] }
}

$script:SearchLeads = '^(grep|egrep|fgrep|rg|ag|ack|find|fd|tree|select-string|sls|git\s+grep)(\s|$)|^(get-childitem|gci)\s.*-(recurse|filter|include)'
$script:ReadLeads   = '^(cat|head|tail|less|more|get-content|gc|sed\s+-n)(\s|$)'
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
        A file path as the report may show it: repo-relative, '~/.claude/plugins/...',
        '~/.claude/(other)', or '(outside the repo)'.

    .DESCRIPTION
        NORMALISED BEFORE IT IS TESTED, so 'C:\repo\..\secret\x' is outside the repo rather than shown as
        '../secret/x'. A worktree lane ('<repo>-lanes\<lane>\...') folds onto the repo, since it is the
        same tree. Under ~/.claude only the plugin trees are shown, because they are public content; a
        memory or plan file is named after what it holds. Everything else is hidden entirely, because a
        home directory carries a user name and this report may be quoted into a public tracker.
    #>
    param([string]$Path, [string]$RepoRoot)

    if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
    if (-not [System.IO.Path]::IsPathRooted($Path)) { return '(outside the repo)' }
    try { $p = [System.IO.Path]::GetFullPath($Path) } catch { return '(outside the repo)' }
    if ($RepoRoot) {
        if ($p.StartsWith($RepoRoot + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
            return ($p.Substring($RepoRoot.Length + 1) -replace '\\', '/')
        }
        $lanes = $RepoRoot + '-lanes\'
        if ($p.StartsWith($lanes, [System.StringComparison]::OrdinalIgnoreCase)) {
            $rest = $p.Substring($lanes.Length)
            $cut = $rest.IndexOf('\')
            if ($cut -ge 0) { return ($rest.Substring($cut + 1) -replace '\\', '/') }
        }
    }
    $claudeHome = [System.IO.Path]::GetFullPath((Join-Path $HOME '.claude'))
    if ($p.StartsWith($claudeHome + '\plugins\', [System.StringComparison]::OrdinalIgnoreCase)) {
        return ('~/.claude/' + ($p.Substring($claudeHome.Length + 1) -replace '\\', '/'))
    }
    if ($p.StartsWith($claudeHome + '\', [System.StringComparison]::OrdinalIgnoreCase)) { return '~/.claude/(other)' }
    return '(outside the repo)'
}

function Test-RepoReportPath {
    <# True when a report path names a file in the repo (not a plugin file, not a hidden one). #>
    param([string]$ReportPath)
    return ($ReportPath -and -not $ReportPath.StartsWith('(') -and -not $ReportPath.StartsWith('~'))
}

function Get-ShellCommandKind {
    <#
    .SYNOPSIS
        'search', 'read' or '' for one shell command: the first command in it that is either decides.

    .DESCRIPTION
        The text is split into lines and each line on && || and ;, and of each piece ONLY THE PART BEFORE
        ITS FIRST '|' is classified -- `npm test | tail` and `git status | grep x` filter a command's own
        output and are not lookups. Leading VAR=value assignments are skipped. git log counts only with
        the pickaxe, -S or -G, matched case-sensitively: -s (no patch) and -g (walk reflogs) are not
        searches. One call counts once however many of its commands match. A heredoc body can still
        produce a false piece; that is accepted rather than parsed.
    #>
    param([string]$Command)

    if ([string]::IsNullOrWhiteSpace($Command)) { return '' }
    foreach ($line in ($Command -split "`r?`n")) {
        foreach ($piece in ($line -split '&&|\|\||;')) {
            $s = ($piece -split '\|')[0].Trim().TrimStart('(', '{', '&', ' ')
            while ($s -match '^[A-Za-z_][A-Za-z0-9_]*=\S*\s+(.*)$') { $s = $Matches[1].Trim() }
            if ($s -cmatch '^git\s+log\s.*-[SG]') { return 'search' }
            if ($s -match $script:SearchLeads) { return 'search' }
            if ($s -match $script:ReadLeads) { return 'read' }
        }
    }
    return ''
}

function Measure-RetroTranscript {
    <#
    .SYNOPSIS
        One session's lookup cost, from its records in order. Returns $null when it made no tool call.

    .DESCRIPTION
        TWO PASSES OVER THE FILE. The first collects the ids of tool calls whose result was an error (only
        lines carrying '"is_error":true' are parsed); the second walks the assistant records. A line that
        does not parse is skipped, for measure-closeouts' reason: transcripts are appended to while
        sessions run, so a half-written last line is ordinary.

        THE EDIT STRINGS ARE COMPARED IN MEMORY AND NEVER LEAVE THIS FUNCTION, and re-reads are counted on
        the full normalised path, so two different files outside the repo are two files rather than one
        '(outside the repo)' read twice.
    #>
    param([string]$Path, [string]$RepoRoot)

    $failed = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($line in [System.IO.File]::ReadLines($Path)) {
        if ($line.IndexOf('"is_error":true') -lt 0) { continue }
        try { $rec = $line | ConvertFrom-Json } catch { continue }
        $content = Get-Field (Get-Field $rec 'message') 'content'
        if (-not $content -or $content -is [string]) { continue }
        foreach ($block in $content) {
            if ((Get-Field $block 'type') -eq 'tool_result' -and (Get-Field $block 'is_error') -eq $true) {
                [void]$failed.Add([string](Get-Field $block 'tool_use_id'))
            }
        }
    }

    $searches = 0; $explores = 0; $web = 0; $reads = 0; $shellReads = 0; $edits = 0; $tools = 0
    $reverted = 0; $beforeFirstEdit = 0; $firstEditSeen = $false
    $inTokens = 0L; $outTokens = 0L
    $readPaths = @{}
    $readFull = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $editPairs = New-Object 'System.Collections.Generic.HashSet[string]'
    $seenMessages = New-Object 'System.Collections.Generic.HashSet[string]'

    foreach ($line in [System.IO.File]::ReadLines($Path)) {
        if ($line.IndexOf('"type":"assistant"') -lt 0) { continue }
        try { $rec = $line | ConvertFrom-Json } catch { continue }
        $msg = Get-Field $rec 'message'
        if (-not $msg) { continue }

        $usage = Get-Field $msg 'usage'
        $msgId = [string](Get-Field $msg 'id')
        if ($usage -and (-not $msgId -or $seenMessages.Add($msgId))) {
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
                    $raw = [string](Get-Field $inputObj 'file_path')
                    $full = $raw
                    try { if ([System.IO.Path]::IsPathRooted($raw)) { $full = [System.IO.Path]::GetFullPath($raw) } } catch { }
                    [void]$readFull.Add($full)
                    $rp = ConvertTo-ReportPath -Path $raw -RepoRoot $RepoRoot
                    if ($rp -and -not $rp.StartsWith('(') -and $rp -ne '~/.claude/(other)') {
                        if ($readPaths.ContainsKey($rp)) { $readPaths[$rp]++ } else { $readPaths[$rp] = 1 }
                    }
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
                $target = [string](Get-Field $inputObj 'file_path')
                if (-not $target) { $target = [string](Get-Field $inputObj 'notebook_path') }
                $inRepo = Test-RepoReportPath -ReportPath (ConvertTo-ReportPath -Path $target -RepoRoot $RepoRoot)
                if ($inRepo -and -not $failed.Contains([string](Get-Field $block 'id'))) {
                    $edits++
                    $firstEditSeen = $true
                    if ($name -eq 'Edit') {
                        $old = [string](Get-Field $inputObj 'old_string')
                        $new = [string](Get-Field $inputObj 'new_string')
                        $sep = [char]0x1F
                        if ($editPairs.Contains("$target$sep$new$sep$old")) { $reverted++ }
                        [void]$editPairs.Add("$target$sep$old$sep$new")
                    }
                }
            } elseif ($lookup -and -not $firstEditSeen) {
                $beforeFirstEdit++
            }
        }
    }

    if ($tools -eq 0) { return $null }
    return [pscustomobject]@{
        Session                = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        ToolCalls              = $tools
        Searches               = $searches
        Explores               = $explores
        WebLookups             = $web
        Reads                  = $reads
        DistinctReads          = $readFull.Count
        ReReads                = $reads - $readFull.Count
        ShellReads             = $shellReads
        Edits                  = $edits
        LookupsBeforeFirstEdit = if ($firstEditSeen) { $beforeFirstEdit } else { $null }
        RevertedEdits          = $reverted
        InputTokens            = $inTokens
        OutputTokens           = $outTokens
        ReadPaths              = $readPaths
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
    Write-Host '[SKIP] No transcript root at the given path -- nothing to measure.' -ForegroundColor Yellow
    exit 0
}

# The scope is described, never named: a project directory name is the absolute checkout path.
$patterns = @()
$scope = ''
if ($Project) { $patterns = @($Project); $scope = 'the directories -Project names' }
elseif ($repoRoot) {
    $own = Get-TranscriptProjectName -Path $repoRoot
    $patterns = @($own, "$own-lanes-*")
    $scope = "this repo's checkout and its worktree lanes"
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
            $rows.Add($row)
        } else { $skipped++ }
    } catch { $skipped++ }
}
$all = $rows.ToArray()

# Across sessions: per repo or plugin file, in how many sessions it was read, how often in total, and in
# how many it was read more than once.
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
    Sessions                     = $all.Count
    SessionsWithAnEdit           = $withEdit.Count
    MedianSearches               = Get-Median -Values @($all | ForEach-Object { $_.Searches })
    MedianReads                  = Get-Median -Values @($all | ForEach-Object { $_.Reads })
    MedianReReads                = Get-Median -Values @($all | ForEach-Object { $_.ReReads })
    MedianLookupsBeforeFirstEdit = Get-Median -Values @($withEdit | ForEach-Object { $_.LookupsBeforeFirstEdit })
    RevertedEdits                = [int](($all | Measure-Object -Property RevertedEdits -Sum).Sum)
    MedianOutputTokens           = Get-Median -Values @($all | ForEach-Object { $_.OutputTokens })
}

# Ranked by lookups before the first edit; a session that never edited ranks by all its lookups.
$costly = @($all | Sort-Object @{ Expression = { if ($null -eq $_.LookupsBeforeFirstEdit) { $_.Searches + $_.Explores + $_.WebLookups + $_.Reads + $_.ShellReads } else { $_.LookupsBeforeFirstEdit } }; Descending = $true } | Select-Object -First $Top)

# ---------------------------------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------------------------------

if ($Json) {
    [pscustomobject]@{
        MeasuredUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        Scope       = $scope
        Summary     = $summary
        Sessions    = @($all | Select-Object Session, LastWrite, ToolCalls, Searches, Explores, WebLookups, Reads, DistinctReads, ReReads, ShellReads, Edits, LookupsBeforeFirstEdit, RevertedEdits, InputTokens, OutputTokens)
        HotFiles    = $hotFiles
    } | ConvertTo-Json -Depth 5
    exit 0
}

Write-Host ''
Write-Host '== retro: what the recent sessions spent looking ==' -ForegroundColor Cyan
Write-Host "   scope: $scope" -ForegroundColor DarkGray
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
Write-Host '  before-edit = lookups (searches, explores, web, reads, shell reads) before the first edit in the repo;' -ForegroundColor DarkGray
Write-Host '  - = the session never edited, and ranks by all its lookups' -ForegroundColor DarkGray
foreach ($r in $costly) {
    $be = if ($null -eq $r.LookupsBeforeFirstEdit) { '-' } else { $r.LookupsBeforeFirstEdit }
    Write-Host ("  {0}  {1}  before-edit {2,3}  searches {3,3}  explores {4,2}  reads {5,3} (re-reads {6,2})  edits {7,3}  reverted {8,2}" -f $r.Session, $r.LastWrite, $be, $r.Searches, $r.Explores, $r.Reads, $r.ReReads, $r.Edits, $r.RevertedEdits)
}

Write-Host ''
Write-Host 'The files read most -- a candidate for a pointer, or a summary that should exist' -ForegroundColor Cyan
if ($hotFiles.Count -eq 0) { Write-Host '  (no repo or plugin file was read)' -ForegroundColor DarkGray }
foreach ($f in $hotFiles) {
    Write-Host ("  {0,2} sessions  {1,3} reads  re-read in {2,2}  {3}" -f $f.Sessions, $f.Reads, $f.ReReadIn, $f.Path)
}

Write-Host ''
Write-Host '  A session is <session>.jsonl in a project directory under ~/.claude/projects; this report quotes none of it.' -ForegroundColor DarkGray
Write-Host '  A measurement, not a gate: it reaches no verdict about any session.' -ForegroundColor DarkGray
exit 0
