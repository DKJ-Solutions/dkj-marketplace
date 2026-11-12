<#
.SYNOPSIS
    Tests for scripts/maintenance/measure-decision-stops.ps1 -- the decision-stop instrument behind
    #4005.

.DESCRIPTION
    WHAT THIS SUITE IS PROTECTING.

      1. THE CLASSIFICATION. One question each for: the Recommended option as-is, the Recommended option
         with a note, another offered option, an answer in the owner's own words, a multi-select that
         holds the Recommended option among others, a question that offered no Recommended, and a
         rejected call. The headline share counts only the questions that offered a Recommended.
      2. A ONE-OPTION ANSWER. The first run of the script read 0 stops in 225 real sessions, because a
         single answer unrolled into a bare string and every session holding a stop threw. A fixture
         with ordinary single-select answers is that regression's guard, and so is the unreadable count.
      3. THE PRIVACY BOUNDARY. No question text, label, answer or note from the fixture reaches either
         output, and a project stored outside a '-GitHub-' path is reported as '(other)'.
      4. THE DOCTRINE. It always exits 0 and says it is a measurement, not a gate, and that shape B is
         not counted.

    THE FIXTURE IS SYNTHETIC: its own transcript root in the temp area, never ~/.claude/projects,
    removed in a finally. Dependency-free (no Pester), same style as the rest of the suite.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$ScriptPath = Join-Path $RepoRoot 'scripts\maintenance\measure-decision-stops.ps1'

$script:pass = 0
$script:fail = 0

function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}

function Assert-True {
    param($Condition, [string]$Label)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label" -ForegroundColor Red }
}

Write-Host ''
Write-Host 'The script is present and shaped as a measurement' -ForegroundColor Cyan

Assert-True (Test-Path -LiteralPath $ScriptPath) 'measure-decision-stops.ps1 exists'
$src = Get-Content -LiteralPath $ScriptPath -Raw
Assert-True (-not ($src -cmatch '[^\x00-\x7F]')) 'it is pure ASCII'
Assert-True ($src -match 'InvariantCulture') 'it pins the number formatting to the invariant culture'
Assert-True ($src -match '(?m)^exit 0\s*$') 'it ends on an unconditional exit 0'
Assert-True ($src -match 'MEASUREMENT, NOT A GATE') 'it states the measurement-not-a-gate boundary'
Assert-True ($src -match 'Assert-OwnCopy') 'it carries the source-repo guard'

function New-Ask {
    <# An assistant record with one AskUserQuestion call. $Questions: the questions as the tool takes them. #>
    param([string]$Id, [object[]]$Questions)
    $block = @{ type = 'tool_use'; id = $Id; name = 'AskUserQuestion'; input = @{ questions = $Questions } }
    return (@{ type = 'assistant'; message = @{ content = @($block) } } | ConvertTo-Json -Depth 10 -Compress)
}

function New-Answer {
    <# The user record that answers call $Id, with the structured toolUseResult the harness writes. #>
    param([string]$Id, [object[]]$Questions, [hashtable]$Answers, [hashtable]$Notes = @{}, [string]$When = '2026-11-10T10:00:00Z')
    $ann = @{}; foreach ($k in $Notes.Keys) { $ann[$k] = @{ notes = $Notes[$k] } }
    $rec = @{
        type          = 'user'
        timestamp     = $When
        message       = @{ role = 'user'; content = @(@{ type = 'tool_result'; tool_use_id = $Id; content = 'SECRET-RESULT-TEXT' }) }
        toolUseResult = @{ questions = $Questions; answers = $Answers; annotations = $ann }
    }
    return ($rec | ConvertTo-Json -Depth 10 -Compress)
}

function New-Rejection {
    param([string]$Id)
    $rec = @{
        type          = 'user'
        timestamp     = '2026-11-10T10:00:00Z'
        message       = @{ role = 'user'; content = @(@{ type = 'tool_result'; tool_use_id = $Id; is_error = $true; content = "The user doesn't want to proceed" }) }
        toolUseResult = 'User rejected tool use'
    }
    return ($rec | ConvertTo-Json -Depth 10 -Compress)
}

function New-Q {
    param([string]$Text, [string[]]$Labels, [switch]$Multi)
    return @{ question = $Text; header = 'H'; multiSelect = [bool]$Multi; options = @($Labels | ForEach-Object { @{ label = $_; description = 'SECRET-DESCRIPTION' } }) }
}

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("decision-stops-" + [guid]::NewGuid().ToString('N'))

try {
    $projA = Join-Path $fixtureRoot 'C--Users-someone-Documents-GitHub-acme-repo'
    $projB = Join-Path $fixtureRoot 'C--elsewhere-private-dir'
    foreach ($p in $projA, $projB) { New-Item -ItemType Directory -Path $p -Force | Out-Null }

    $q1 = New-Q -Text 'SECRET-Q1' -Labels @('SECRET-A (Recommended)', 'SECRET-B')
    $q2 = New-Q -Text 'SECRET-Q2' -Labels @('Go (Recommended)', 'Stop')
    $q3 = New-Q -Text 'SECRET-Q3' -Labels @('Keep (Recommended)', 'Drop')
    $q4 = New-Q -Text 'SECRET-Q4' -Labels @('Yes (Recommended)', 'No')
    $q5 = New-Q -Text 'SECRET-Q5' -Labels @('X (Recommended)', 'Y', 'Z') -Multi
    $q6 = New-Q -Text 'SECRET-Q6' -Labels @('Left', 'Right')

    # SESSION ONE (acme-repo): a call with two questions -- Recommended as-is, and Recommended with a
    # note -- then a call answered with another option, then one answered in the owner's own words.
    @(
        '{"type":"attachment","attachment":{"deferredTools":["AskUserQuestion"]}}'
        (New-Ask -Id 'toolu_01' -Questions @($q1, $q2))
        (New-Answer -Id 'toolu_01' -Questions @($q1, $q2) -Answers @{ 'SECRET-Q1' = 'SECRET-A (Recommended)'; 'SECRET-Q2' = 'Go (Recommended)' } -Notes @{ 'SECRET-Q2' = 'SECRET-NOTE' })
        (New-Ask -Id 'toolu_02' -Questions @($q3))
        (New-Answer -Id 'toolu_02' -Questions @($q3) -Answers @{ 'SECRET-Q3' = 'Drop' })
        (New-Ask -Id 'toolu_03' -Questions @($q4))
        (New-Answer -Id 'toolu_03' -Questions @($q4) -Answers @{ 'SECRET-Q4' = 'SECRET-OWN-WORDS' })
    ) | Set-Content -LiteralPath (Join-Path $projA 'aaaa1111.jsonl') -Encoding UTF8

    # SESSION TWO (a directory outside GitHub): a multi-select holding the Recommended among others, a
    # question with no Recommended, and a rejected call. One answer is dated before -Since below.
    @(
        (New-Ask -Id 'toolu_04' -Questions @($q5))
        (New-Answer -Id 'toolu_04' -Questions @($q5) -Answers @{ 'SECRET-Q5' = 'X (Recommended), Z' } -When '2026-10-01T10:00:00Z')
        (New-Ask -Id 'toolu_05' -Questions @($q6))
        (New-Answer -Id 'toolu_05' -Questions @($q6) -Answers @{ 'SECRET-Q6' = 'Right' })
        (New-Ask -Id 'toolu_06' -Questions @($q2))
        (New-Rejection -Id 'toolu_06')
    ) | Set-Content -LiteralPath (Join-Path $projB 'bbbb2222.jsonl') -Encoding UTF8

    # SESSION THREE: no stop at all.
    '{"type":"assistant","message":{"content":[{"type":"text","text":"SECRET-MESSAGE"}]}}' |
        Set-Content -LiteralPath (Join-Path $projA 'cccc3333.jsonl') -Encoding UTF8

    Write-Host ''
    Write-Host 'The classification' -ForegroundColor Cyan
    $j = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json | Out-String) | ConvertFrom-Json
    Assert-Equal 0 $LASTEXITCODE 'exit 0'
    Assert-Equal 3 $j.Sessions 'three sessions read'
    Assert-Equal 2 $j.SessionsWithStop 'two of them hold a stop'
    Assert-Equal 0 $j.Unreadable 'none was unreadable (the single-answer regression)'
    Assert-Equal 7 $j.Questions 'seven questions counted, the rejected call as one'
    Assert-Equal 1 $j.Counts.rec 'Recommended as-is: one'
    Assert-Equal 1 $j.Counts.'rec-note' 'Recommended with a note: one, kept apart from as-is'
    Assert-Equal 2 $j.Counts.other 'another offered option: the plain one and the multi-select'
    Assert-Equal 1 $j.Counts.own 'own words: one'
    Assert-Equal 1 $j.Counts.declined 'a rejected call: declined'
    Assert-Equal 1 $j.Counts.'norec-option' 'a question with no Recommended is counted apart'
    Assert-Equal 5 $j.Offered 'the share is read over the five that offered a Recommended'
    Assert-Equal 20 $j.AsIsPct 'as-is share: 1 of 5'
    Assert-Equal 40 $j.AnyRecPct 'with or without a note: 2 of 5'
    Assert-Equal 'False' $j.ShapeBMeasured 'it says shape B is not measured'

    $names = @($j.Projects | ForEach-Object { $_.Project })
    Assert-True ($names -contains 'acme-repo') 'a GitHub project is reported by its repo part'
    Assert-True ($names -contains '(other)') 'a project outside GitHub is reported as (other)'

    Write-Host ''
    Write-Host 'The privacy boundary' -ForegroundColor Cyan
    $human = (& $ScriptPath -TranscriptRoot $fixtureRoot *>&1 | Out-String)
    $json  = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json | Out-String)
    foreach ($out in @(@{ N = 'report'; T = $human }, @{ N = 'JSON'; T = $json })) {
        Assert-True ($out.T -notmatch 'SECRET') "the $($out.N) carries no question, label, answer, note or message text"
        Assert-True ($out.T -notmatch 'someone|elsewhere|private-dir') "the $($out.N) carries no local path or user name"
    }
    Assert-True ($human -match 'shape B') 'the report says shape B is not counted'
    Assert-True ($human -match 'not a gate') 'the report says it is not a gate'

    Write-Host ''
    Write-Host 'The filters' -ForegroundColor Cyan
    $since = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json -Since '2026-11-01' | Out-String) | ConvertFrom-Json
    Assert-Equal 6 $since.Questions '-Since leaves out the answer dated before it'
    $proj = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json -Project '*acme-repo' | Out-String) | ConvertFrom-Json
    Assert-Equal 2 $proj.Sessions '-Project reads only the directories it matches'

    & $ScriptPath -TranscriptRoot $fixtureRoot -Since 'not-a-date' *>&1 | Out-Null
    Assert-Equal 0 $LASTEXITCODE 'a malformed -Since is a skip, still exit 0'
    & $ScriptPath -TranscriptRoot (Join-Path $fixtureRoot 'missing') *>&1 | Out-Null
    Assert-Equal 0 $LASTEXITCODE 'a missing transcript root is a skip, still exit 0'
}
finally {
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "Result: $script:pass pass, $script:fail fail." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
