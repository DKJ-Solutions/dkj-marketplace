<#
.SYNOPSIS
    Measures the DECISION STOPS on this machine -- how often a session stopped to ask the owner a menu
    question, and how often the owner then simply picked the option marked Recommended (issue #4005).

.DESCRIPTION
    WHY IT EXISTS. The owner's impression, filed as #4005: sessions stop for a decision slightly too
    often, and in roughly 90% of those stops the owner picks the option marked "(Recommended)". A question
    whose answer is that predictable buys little -- it costs a wait and an interruption, and it turns the
    owner into an approver. But 90% was an estimate, and the step #4005 proposes after it (a per-person
    dial on how readily a session stops) is only worth building if the number holds. So this script is
    the measurement that comes first, in the style of measure-closeouts.ps1 beside it: a repair judged
    against an impression cannot be told from a repair that did nothing.

    WHAT A STOP IS HERE. One AskUserQuestion call. Each call carries one to four questions, and each
    question is classified on its own, because a call that asks two things can be answered "Recommended"
    on one and in the owner's own words on the other:

        recommended      the answer is exactly the option whose label carries "(Recommended)", with no
                         note added to it
        recommended+note the same option, with a note the owner typed beside it -- a yes with a condition,
                         which is NOT the predictable answer this script is counting
        other option     another of the offered options (for a multi-select: any set that is not just
                         the recommended option)
        own words        an answer matching no offered label -- the "Other" field, typically a
                         correction or a question back
        declined         the call was rejected or interrupted and nothing was answered

    A question that offered no Recommended option is counted apart, never in the share: there was no
    predictable answer to pick.

    WHAT IT DOES NOT COUNT, AND SAYS SO. #4005 also names the close-out of shape B -- a decision written
    as a menu in prose. That shape leaves no structured trace: telling a menu from an explanation means
    reading the message, and this script reads no message text (below). So shape B is NOT measured, and
    the report prints that line every time rather than letting the AskUserQuestion figure stand in for
    all decision stops.

    IT IS A MEASUREMENT, NOT A GATE. It always exits 0, reads only, and reaches no verdict about any
    single question -- the same boundary as measure-closeouts.ps1 and retro.ps1.

    THE TRANSCRIPTS IT READS ARE THIS MACHINE'S OWN, under ~/.claude/projects, read in place and never
    written to. Only counts leave this script: no question text, no option label, no answer, no note --
    which is what makes it safe to quote in a public repo while the sessions stay private. A project is
    reported by the part of its directory name after '-GitHub-', and one stored anywhere else is reported
    as '(other)', because the rest of that name encodes a local path with a user name in it.

    ONLY THE LINES THAT CAN CARRY A STOP ARE PARSED. A transcript is mostly tool output, and parsing every
    line of ~200 sessions as JSON is minutes of work for a figure that lives in a handful of lines per
    session. A line is parsed only when it names AskUserQuestion, or carries a tool result for a call
    this file already saw.

.PARAMETER TranscriptRoot
    Where the session transcripts live. Defaults to ~/.claude/projects.

.PARAMETER Project
    Limit to project directories whose name matches this wildcard. Default: all of them.

.PARAMETER Since
    Count only stops answered on or after this date (yyyy-MM-dd, read as UTC midnight). A stop whose
    timestamp cannot be read is left out under -Since. Default: everything recorded.

.PARAMETER Json
    Emit the result as JSON on stdout instead of the human report.
#>
[CmdletBinding()]
param(
    [string]$TranscriptRoot = (Join-Path $HOME '.claude\projects'),
    [string]$Project = '*',
    [string]$Since = '',
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Invariant formatting, for measure-closeouts.ps1's reason: every figure here is meant to be quoted, and
# a Dutch-locale console would otherwise print 0,9 where a US one prints 0.9.
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture

# The source-repo guard: in the repo this file is maintained in, the plugin-cache copy lags this tree,
# and a stale instrument hands back a plausible number. Silent for a consumer.
$guardLib = Join-Path $PSScriptRoot '..\lib\source-repo-guard-lib.ps1'
if (Test-Path -LiteralPath $guardLib -PathType Leaf) { . $guardLib; Assert-OwnCopy -ScriptPath $PSCommandPath }

$sinceDate = $null
if ($Since) {
    try { $sinceDate = [datetime]::SpecifyKind([datetime]::ParseExact($Since, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture), [System.DateTimeKind]::Utc) }
    catch { Write-Host "[SKIP] -Since '$Since' is not a yyyy-MM-dd date. Nothing measured." -ForegroundColor Yellow; exit 0 }
}

$script:RecommendedMark = '(Recommended)'

function Get-ProjectLabel {
    <# The reportable part of a project directory name -- never the local path it encodes. #>
    param([string]$DirName)
    if ($DirName -match '-GitHub-(.+)$') { return $Matches[1] }
    return '(other)'
}

function Get-QuestionVerdict {
    <#
    .SYNOPSIS
        Classifies one answered question: recommended, recommended+note, other option, own words -- or
        no-recommendation when the question offered none.
    #>
    param($Question, [string]$Answer, [string]$Note)

    $labels = @()
    if ($Question.PSObject.Properties.Name -contains 'options' -and $Question.options) {
        # Trimmed like the answer, or a label with a stray space never matches its own answer.
        $labels = @($Question.options | ForEach-Object { ([string]$_.label).Trim() })
    }
    $rec = @($labels | Where-Object { $_.Contains($script:RecommendedMark) })
    $multi = ($Question.PSObject.Properties.Name -contains 'multiSelect') -and [bool]$Question.multiSelect

    $answer = ([string]$Answer).Trim()
    $picked = New-Object System.Collections.Generic.List[string]
    $allOffered = $false
    if ($labels -contains $answer) {
        # The whole answer is one label -- checked first, because a label may itself hold a comma
        # ("Yes, merge it (Recommended)"), and splitting it would read a plain pick as own words.
        $picked.Add($answer); $allOffered = $true
    } elseif ($multi -and $answer) {
        # A multi-select answer joins the picked labels with ', '. Take the offered labels out of it,
        # longest first so a label containing another is not split, and whatever text is left over
        # is the owner's own words.
        $rest = $answer
        foreach ($l in @($labels | Sort-Object { $_.Length } -Descending)) {
            if ($l -and $rest.Contains($l)) { $picked.Add($l); $rest = $rest.Replace($l, '') }
        }
        $allOffered = ($picked.Count -gt 0) -and (($rest -replace '[,\s]', '') -eq '')
    }

    if ($rec.Count -eq 0) {
        if ($allOffered) { return 'norec-option' } else { return 'norec-own' }
    }
    if (-not $allOffered) { return 'own' }
    if ($picked.Count -eq 1 -and $rec -contains $picked[0]) {
        if ([string]::IsNullOrWhiteSpace($Note)) { return 'rec' } else { return 'rec-note' }
    }
    return 'other'
}

function Measure-OneTranscript {
    <# The stops in one session, as a list of verdicts (one per question, or one 'declined' per call). #>
    param([string]$Path)

    $verdicts = New-Object System.Collections.Generic.List[string]
    $pending = @{}   # tool_use id -> $true, for AskUserQuestion calls not yet answered
    $lines = @(Get-Content -LiteralPath $Path -Encoding UTF8 -ErrorAction SilentlyContinue)

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        $isAsk = $line.Contains('"AskUserQuestion"')
        $isAnswer = $false
        if (-not $isAsk -and $pending.Count -gt 0 -and $line.Contains('"tool_result"')) {
            foreach ($id in @($pending.Keys)) { if ($line.Contains($id)) { $isAnswer = $true; break } }
        }
        if (-not ($isAsk -or $isAnswer)) { continue }

        try { $rec = $line | ConvertFrom-Json } catch { continue }
        if (-not ($rec.PSObject.Properties.Name -contains 'type')) { continue }
        if (-not ($rec.PSObject.Properties.Name -contains 'message') -or -not $rec.message) { continue }
        if (-not ($rec.message.PSObject.Properties.Name -contains 'content')) { continue }
        $content = $rec.message.content
        if ($content -is [string]) { continue }

        if ($rec.type -eq 'assistant') {
            foreach ($block in @($content)) {
                if ($block.type -eq 'tool_use' -and $block.name -eq 'AskUserQuestion' -and $block.id) { $pending[[string]$block.id] = $true }
            }
            continue
        }
        if ($rec.type -ne 'user') { continue }

        foreach ($block in @($content)) {
            if ($block.type -ne 'tool_result') { continue }
            $id = [string]$block.tool_use_id
            if (-not $pending.ContainsKey($id)) { continue }
            $pending.Remove($id)

            # -Since is a UTC midnight, compared with the record's UTC timestamp. A record whose date
            # cannot be read is left out under -Since rather than counted on a guess.
            if ($sinceDate) {
                $when = [datetime]::MinValue
                $stamp = if ($rec.PSObject.Properties.Name -contains 'timestamp') { [string]$rec.timestamp } else { '' }
                $ok = [datetime]::TryParse($stamp, [System.Globalization.CultureInfo]::InvariantCulture,
                        ([System.Globalization.DateTimeStyles]::AdjustToUniversal -bor [System.Globalization.DateTimeStyles]::AssumeUniversal), [ref]$when)
                if (-not $ok -or $when -lt $sinceDate) { continue }
            }

            # The structured answer: toolUseResult.questions (with their options) and .answers, keyed by
            # question text. A rejected or interrupted call carries a string there, or nothing.
            $result = $null
            if ($rec.PSObject.Properties.Name -contains 'toolUseResult') { $result = $rec.toolUseResult }
            $hasAnswers = $result -and ($result -isnot [string]) -and
                ($result.PSObject.Properties.Name -contains 'answers') -and $result.answers -and
                ($result.PSObject.Properties.Name -contains 'questions') -and $result.questions
            if (-not $hasAnswers) { $verdicts.Add('declined'); continue }

            $notes = $null
            if ($result.PSObject.Properties.Name -contains 'annotations') { $notes = $result.annotations }
            # Answers are keyed by question text; the tool refuses two questions with the same text in one
            # call, so the key is unique. A question record missing its text is one declined question,
            # not a throw that would lose the rest of the session.
            foreach ($q in @($result.questions)) {
                if (-not ($q.PSObject.Properties.Name -contains 'question')) { $verdicts.Add('declined'); continue }
                $text = [string]$q.question
                $answerProp = $result.answers.PSObject.Properties[$text]
                if (-not $answerProp) { $verdicts.Add('declined'); continue }
                $note = ''
                if ($notes -and $notes.PSObject.Properties[$text]) {
                    $ann = $notes.PSObject.Properties[$text].Value
                    if ($ann -and ($ann.PSObject.Properties.Name -contains 'notes')) { $note = [string]$ann.notes }
                }
                $verdicts.Add((Get-QuestionVerdict -Question $q -Answer ([string]$answerProp.Value) -Note $note))
            }
        }
    }
    # Enumerated into the output stream; the caller collects it with @(), so an empty session is @().
    return $verdicts.ToArray()
}

# ---------------------------------------------------------------------------------------------------
# Collect
# ---------------------------------------------------------------------------------------------------

if (-not (Test-Path -LiteralPath $TranscriptRoot -PathType Container)) {
    Write-Host "[SKIP] No transcript root at '$TranscriptRoot' -- nothing to measure." -ForegroundColor Yellow
    exit 0
}

$kinds = @('rec', 'rec-note', 'other', 'own', 'declined', 'norec-option', 'norec-own')
function New-Tally { $t = [ordered]@{}; foreach ($k in $kinds) { $t[$k] = 0 }; return $t }

$total = New-Tally
$byProject = [ordered]@{}
$sessions = 0
$sessionsWithStop = 0
# Counted and PRINTED rather than swallowed: the first run of this script read 0 stops in 225 sessions
# because every session holding one threw inside the classifier, and nothing said so.
$unreadable = 0
$stopsPerSession = New-Object System.Collections.Generic.List[int]

foreach ($dir in Get-ChildItem -LiteralPath $TranscriptRoot -Directory -ErrorAction SilentlyContinue) {
    if ($dir.Name -notlike $Project) { continue }
    $label = Get-ProjectLabel -DirName $dir.Name
    foreach ($file in Get-ChildItem -LiteralPath $dir.FullName -Filter *.jsonl -ErrorAction SilentlyContinue) {
        $sessions++
        $v = @()
        try { $v = @(Measure-OneTranscript -Path $file.FullName) } catch { $unreadable++; $v = @() }
        if ($v.Count -eq 0) { continue }
        $sessionsWithStop++
        $stopsPerSession.Add($v.Count)
        if (-not $byProject.Contains($label)) { $byProject[$label] = New-Tally }
        foreach ($x in $v) { $total[$x]++; $byProject[$label][$x]++ }
    }
}

function Get-Share {
    <# The headline: of the answered questions that offered a Recommended option, how many took it as-is. #>
    param($Tally)
    $offered = $Tally['rec'] + $Tally['rec-note'] + $Tally['other'] + $Tally['own']
    if ($offered -eq 0) { return [pscustomobject]@{ Offered = 0; AsIsPct = $null; AnyRecPct = $null } }
    return [pscustomobject]@{
        Offered   = $offered
        AsIsPct   = [math]::Round(100 * $Tally['rec'] / $offered)
        AnyRecPct = [math]::Round(100 * ($Tally['rec'] + $Tally['rec-note']) / $offered)
    }
}

$share = Get-Share -Tally $total
$questions = 0; foreach ($k in $kinds) { $questions += $total[$k] }
$sorted = @($stopsPerSession | Sort-Object)
$median = if ($sorted.Count) { $sorted[[int][math]::Floor(0.5 * ($sorted.Count - 1))] } else { 0 }

# ---------------------------------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------------------------------

if ($Json) {
    $projects = @(foreach ($p in $byProject.Keys) {
        $s = Get-Share -Tally $byProject[$p]
        [pscustomobject]@{ Project = $p; Counts = [pscustomobject]$byProject[$p]; Offered = $s.Offered; AsIsPct = $s.AsIsPct; AnyRecPct = $s.AnyRecPct }
    })
    [pscustomobject]@{
        MeasuredUtc       = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        Since             = $Since
        Sessions          = $sessions
        SessionsWithStop  = $sessionsWithStop
        Unreadable        = $unreadable
        Questions         = $questions
        MedianPerSession  = $median
        Counts            = [pscustomobject]$total
        Offered           = $share.Offered
        AsIsPct           = $share.AsIsPct
        AnyRecPct         = $share.AnyRecPct
        ShapeBMeasured    = $false
        Projects          = $projects
    } | ConvertTo-Json -Depth 6
    exit 0
}

Write-Host ''
Write-Host '== decision stops: AskUserQuestion menus, and how they were answered ==' -ForegroundColor Cyan
$scope = if ($Since) { "since $Since" } else { 'everything recorded' }
Write-Host "   sessions read: $sessions   with at least one stop: $sessionsWithStop   unreadable: $unreadable   ($scope)" -ForegroundColor DarkGray
Write-Host '   NOT counted: close-outs of shape B (a menu in prose) -- they leave no structured trace.' -ForegroundColor DarkGray

Write-Host ''
Write-Host 'The share #4005 asks for' -ForegroundColor Cyan
if ($share.Offered -eq 0) {
    Write-Host '  (no answered question offered a Recommended option)' -ForegroundColor DarkGray
} else {
    Write-Host ("  Recommended picked as-is        : {0} / {1}  ({2}%)" -f $total['rec'], $share.Offered, $share.AsIsPct)
    Write-Host ("  Recommended, with or without note: {0} / {1}  ({2}%)" -f ($total['rec'] + $total['rec-note']), $share.Offered, $share.AnyRecPct)
}

Write-Host ''
Write-Host 'Every answered or declined question' -ForegroundColor Cyan
Write-Host ("  questions                       : {0}   per session with a stop, median: {1}" -f $questions, $median)
Write-Host ("  recommended, as-is              : {0}" -f $total['rec'])
Write-Host ("  recommended, with a note        : {0}" -f $total['rec-note'])
Write-Host ("  another offered option          : {0}" -f $total['other'])
Write-Host ("  own words (matched no option)   : {0}" -f $total['own'])
Write-Host ("  declined / interrupted          : {0}" -f $total['declined'])
Write-Host ("  no Recommended offered          : {0} option, {1} own words" -f $total['norec-option'], $total['norec-own'])

if ($byProject.Count -gt 0) {
    Write-Host ''
    Write-Host '  per project (questions that offered a Recommended)' -ForegroundColor Cyan
    $rows = @(foreach ($p in $byProject.Keys) { $s = Get-Share -Tally $byProject[$p]; [pscustomobject]@{ P = $p; S = $s } })
    foreach ($r in ($rows | Sort-Object { $_.S.Offered } -Descending)) {
        $pct = if ($null -eq $r.S.AsIsPct) { '-' } else { "$($r.S.AsIsPct)%" }
        Write-Host ("    {0,-42} n={1,-5} as-is={2}" -f $r.P, $r.S.Offered, $pct)
    }
}

Write-Host ''
Write-Host '  A measurement, not a gate: it reaches no verdict on any single question.' -ForegroundColor DarkGray
Write-Host ''
# ALWAYS 0. See the header: this is a measurement, not a gate.
exit 0
