<#
.SYNOPSIS
    Tests for scripts/maintenance/measure-references.ps1 -- what a specialist's references save (#4547).

.DESCRIPTION
    WHAT THIS SUITE IS PROTECTING. The script keeps two sources apart: the References line a specialist
    REPORTS and the web calls MEASURED in its own transcript. A refactor that read "no line" as zero
    reuse, counted a built-in agent, or took the line from the prompt instead of the deliverable would
    report a plausible number. The fixture pins each of those.

    The fixture is synthetic and self-contained: it builds its own transcript root in the temp area and
    never reads ~/.claude/projects, and it is removed in a finally. Dependency-free (no Pester).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$ScriptPath = Join-Path $RepoRoot 'scripts\maintenance\measure-references.ps1'

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

Assert-True (Test-Path -LiteralPath $ScriptPath) 'measure-references.ps1 exists'
$src = Get-Content -LiteralPath $ScriptPath -Raw
Assert-True (-not ($src -cmatch '[^\x00-\x7F]')) 'it is pure ASCII'
Assert-True ($src -match 'InvariantCulture') 'it pins the number formatting to the invariant culture'
Assert-True ($src -match '(?m)^exit 0\s*$') 'it ends on an unconditional exit 0'
Assert-True ($src -match 'measurement, not a gate') 'it states the measurement-not-a-gate boundary'

# The line the script parses must be the line the shared block asks for, word for word.
$block = Get-Content -LiteralPath (Join-Path $RepoRoot 'plugins\dkj-subagents\subagent-shared\knowledge-lookup.md') -Raw
Assert-True ($block -match [regex]::Escape('`References: <n> from the store, <n> added, <n> web searches.`')) 'the knowledge-lookup block asks for the line the script parses'

# ---------------------------------------------------------------------------------------------------

function New-Line {
    param([hashtable]$Record)
    return ($Record | ConvertTo-Json -Depth 10 -Compress)
}

function New-Subagent {
    param([string]$Dir, [string]$Id, [string]$AgentType, [bool]$BuiltIn, [string[]]$Lines)
    New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    (@{ agentType = $AgentType; isBuiltIn = $BuiltIn } | ConvertTo-Json -Compress) | Set-Content -LiteralPath (Join-Path $Dir "agent-$Id.meta.json") -Encoding utf8
    $Lines | Set-Content -LiteralPath (Join-Path $Dir "agent-$Id.jsonl") -Encoding utf8
}

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('measure-references-' + [guid]::NewGuid().ToString('N'))
try {
    $sub = Join-Path $fixtureRoot 'C--repo\sess-1\subagents'

    # Rebecca: two web calls, a prompt that QUOTES the line (must not count), and a handback that reports.
    New-Subagent -Dir $sub -Id 'a1' -AgentType 'dkj-subagents-alpha:rebecca' -BuiltIn $false -Lines @(
        (New-Line @{ type = 'user'; timestamp = '2026-11-23T10:00:00Z'; message = @{ role = 'user'; content = 'End with References: 9 from the store, 9 added, 9 web searches.' } }),
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'tool_use'; name = 'WebSearch'; input = @{ query = 'x' } }) } }),
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'tool_use'; name = 'WebFetch'; input = @{ url = 'https://example.org' } }) } }),
        'not json {',
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'tool_use'; name = 'SubagentHandback'; input = @{ message = "Draft said References: 7 from the store, 7 added, 7 web searches.`n`n**References: 3 from the store, 1 added, 2 web searches.**" } }) } })
    )
    # Rebecca again, a week later, with no line: a run, never zero reuse.
    New-Subagent -Dir $sub -Id 'a2' -AgentType 'dkj-subagents-alpha:rebecca' -BuiltIn $false -Lines @(
        (New-Line @{ type = 'user'; timestamp = '2026-11-30T10:00:00Z'; message = @{ role = 'user'; content = 'go' } }),
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'tool_use'; name = 'WebSearch'; input = @{ query = 'y' } }) } }),
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'text'; text = 'Done, no line.' }) } })
    )
    # Rebecca, a third run whose line carries an oversized count: read as no line, never fatal.
    New-Subagent -Dir $sub -Id 'a5' -AgentType 'dkj-subagents-alpha:rebecca' -BuiltIn $false -Lines @(
        (New-Line @{ type = 'user'; timestamp = '2026-11-30T11:00:00Z'; message = @{ role = 'user'; content = 'go' } }),
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'text'; text = 'References: 99999999999 from the store, 0 added, 0 web searches.' }) } })
    )
    # A built-in agent that reports a line: skipped.
    New-Subagent -Dir $sub -Id 'a3' -AgentType 'Explore' -BuiltIn $true -Lines @(
        (New-Line @{ type = 'user'; timestamp = '2026-11-23T10:00:00Z'; message = @{ role = 'user'; content = 'go' } }),
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'text'; text = 'References: 5 from the store, 0 added, 0 web searches.' }) } })
    )
    # Victor: no web work and no line -- listed only under -All.
    New-Subagent -Dir $sub -Id 'a4' -AgentType 'dkj-subagents-developers:victor' -BuiltIn $false -Lines @(
        (New-Line @{ type = 'user'; timestamp = '2026-11-23T10:00:00Z'; message = @{ role = 'user'; content = 'review' } }),
        (New-Line @{ type = 'assistant'; message = @{ content = @(@{ type = 'text'; text = 'LGTM' }) } })
    )

    Write-Host ''
    Write-Host 'The JSON over the fixture' -ForegroundColor Cyan

    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -TranscriptRoot $fixtureRoot -Json
    Assert-Equal 0 $LASTEXITCODE 'it exits 0'
    $j = ($out -join "`n") | ConvertFrom-Json
    Assert-Equal 4 $j.Runs 'four runs are read: the built-in agent is skipped'
    $names = @($j.Specialists | ForEach-Object { $_.Specialist })
    Assert-Equal 'rebecca' ($names -join ',') 'only a specialist that reported is listed by default'
    $r = $j.Specialists[0]
    Assert-Equal 3 $r.Runs 'every Rebecca run counts as a run'
    Assert-Equal 1 $r.Reported 'only the run with a valid line counts as reported: an oversized count is no line'
    Assert-Equal 3 $r.FromStore 'from store is the LAST line of the handback, not the quoted prompt or an earlier line'
    Assert-Equal 1 $r.Added 'added is read'
    Assert-Equal 2 $r.WebReported 'reported web searches are read'
    Assert-Equal 3 $r.WebMeasured 'measured web calls span every run, line or not'
    Assert-Equal 2 $r.WebMeasuredInReported 'measured web calls of the reporting runs alone'
    Assert-Equal 0.6 $r.ReuseShare 'reuse = 3 / (3 + 2)'
    Assert-Equal '2026-W48,2026-W49' ((@($r.Weeks | ForEach-Object { $_.Week })) -join ',') 'the runs fall into two ISO weeks'

    $outAll = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -TranscriptRoot $fixtureRoot -Json -All
    $jAll = ($outAll -join "`n") | ConvertFrom-Json
    Assert-Equal 'rebecca,victor' ((@($jAll.Specialists | ForEach-Object { $_.Specialist })) -join ',') '-All also lists a specialist that never reported'

    $outSince = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -TranscriptRoot $fixtureRoot -Json -Since 2026-11-25
    $jSince = ($outSince -join "`n") | ConvertFrom-Json
    Assert-Equal 2 $jSince.Runs '-Since drops the runs before it'

    Write-Host ''
    Write-Host 'The console report' -ForegroundColor Cyan
    $txt = (& powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -TranscriptRoot $fixtureRoot) -join "`n"
    Assert-Equal 0 $LASTEXITCODE 'it exits 0'
    Assert-True ($txt -match 'rebecca\s+3\s+1\s+3\s+1\s+2\s+2\s+60%\s+3') 'the row prints runs, reported, the three counts, measured calls of the same runs, reuse and all-run calls'

    $none = (& powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -TranscriptRoot (Join-Path $fixtureRoot 'missing')) -join "`n"
    Assert-Equal 0 $LASTEXITCODE 'a missing root exits 0'
    Assert-True ($none -match 'No run ended with a References line yet') 'a root with no reporting run says so'

    $bad = (& powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -TranscriptRoot $fixtureRoot -Since 'yesterday') -join "`n"
    Assert-Equal 0 $LASTEXITCODE 'a bad -Since exits 0'
    Assert-True ($bad -match '\[SKIP\]') 'a bad -Since is reported, not measured'
}
finally {
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force }
}

Write-Host ''
Write-Host ("measure-references: {0} passed, {1} failed" -f $script:pass, $script:fail)
if ($script:fail -gt 0) { exit 1 }
exit 0
