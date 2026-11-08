<#
.SYNOPSIS
    Tests for scripts/maintenance/retro.ps1 -- the lookup-cost instrument behind the retro skill (#3905).

.DESCRIPTION
    WHAT THIS SUITE IS PROTECTING.

      1. THE COUNTS. Lookups before the first edit is the headline, so a lookup AFTER the first edit must
         not land in it, and a session that never edits must report none rather than zero. A reverted
         edit is an exact swap of an earlier Edit of the same file, and a second, different edit of that
         file is not one.
      2. THE PRIVACY BOUNDARY. The report quotes no transcript text: a search pattern and a message from
         the fixture are asserted absent from both outputs, and a path outside the repo is hidden rather
         than shown with a home directory in it.
      3. THE SCOPE. By default it reads this checkout's own project directory and its lanes', not another
         repo's; -Last and -Since filter.
      4. THE DOCTRINE. It always exits 0 and says it is a measurement, not a gate.

    THE FIXTURE IS SYNTHETIC: its own transcript root in the temp area, never ~/.claude/projects, removed
    in a finally. Dependency-free (no Pester), same style as the rest of the suite.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot   = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$ScriptPath = Join-Path $RepoRoot 'scripts\maintenance\retro.ps1'

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

Assert-True (Test-Path -LiteralPath $ScriptPath) 'retro.ps1 exists'
$src = Get-Content -LiteralPath $ScriptPath -Raw
Assert-True (-not ($src -cmatch '[^\x00-\x7F]')) 'retro.ps1 is pure ASCII'
Assert-True ($src -match 'InvariantCulture') 'it pins the number formatting to the invariant culture'
Assert-True ($src -match '(?m)^exit 0\s*$') 'it ends on an unconditional exit 0'
Assert-True ($src -match 'MEASUREMENT, NOT A GATE') 'it states the measurement-not-a-gate boundary'
Assert-True ($src -match 'Assert-OwnCopy') 'it carries the source-repo guard'

function New-Tool {
    <# One assistant record carrying one tool_use, plus a usage block, as a single JSONL line. #>
    param([string]$Name, [hashtable]$ToolInput, [int]$Out = 10)
    $msg = @{ content = @(@{ type = 'tool_use'; id = 'x'; name = $Name; input = $ToolInput }); usage = @{ input_tokens = 2; cache_read_input_tokens = 100; output_tokens = $Out } }
    return (@{ type = 'assistant'; message = $msg } | ConvertTo-Json -Depth 8 -Compress)
}

function New-Text {
    param([string]$Text)
    return (@{ type = 'assistant'; message = @{ content = @(@{ type = 'text'; text = $Text }) } } | ConvertTo-Json -Depth 8 -Compress)
}

$fixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("retro-" + [guid]::NewGuid().ToString('N'))
$fakeRepo = 'C:\work\acme-repo'
$own      = 'C--work-acme-repo'

try {
    $projOwn   = Join-Path $fixtureRoot $own
    $projLane  = Join-Path $fixtureRoot "$own-lanes-sweep-2"
    $projOther = Join-Path $fixtureRoot 'C--work-other-repo'
    foreach ($p in $projOwn, $projLane, $projOther) { New-Item -ItemType Directory -Path $p -Force | Out-Null }

    # SESSION A -- four lookups before the first edit (a Grep, a shell grep, a Read, a re-Read of the same
    # file), then an edit, then a lookup AFTER it that must not count, then an exact revert of the edit.
    @(
        (New-Text -Text 'SECRET-MESSAGE-TEXT')
        (New-Tool -Name 'Grep' -ToolInput @{ pattern = 'SECRET-SEARCH-PATTERN' })
        (New-Tool -Name 'Bash' -ToolInput @{ command = 'cd x && grep -rn needle .' })
        (New-Tool -Name 'Read' -ToolInput @{ file_path = "$fakeRepo\docs\guide.md" })
        (New-Tool -Name 'Read' -ToolInput @{ file_path = "$fakeRepo\docs\guide.md" })
        (New-Tool -Name 'Edit' -ToolInput @{ file_path = "$fakeRepo\a.ps1"; old_string = 'one'; new_string = 'two' })
        (New-Tool -Name 'Glob' -ToolInput @{ pattern = '**/*.md' })
        (New-Tool -Name 'Edit' -ToolInput @{ file_path = "$fakeRepo\a.ps1"; old_string = 'two'; new_string = 'one' })
        (New-Tool -Name 'Edit' -ToolInput @{ file_path = "$fakeRepo\a.ps1"; old_string = 'one'; new_string = 'three' })
        '{"type":"assistant","message":{"content":[{"type":"tool_u'
    ) | Set-Content -LiteralPath (Join-Path $projOwn 'aaaa1111.jsonl') -Encoding ascii
    (Get-Item -LiteralPath (Join-Path $projOwn 'aaaa1111.jsonl')).LastWriteTime = (Get-Date '2026-11-01 10:00')

    # SESSION B (in a worktree lane) -- never edits; reads the same doc through the lane path, a file
    # outside the repo, and runs an Explore and a shell read.
    @(
        (New-Tool -Name 'Read' -ToolInput @{ file_path = "$fakeRepo-lanes\sweep-2\docs\guide.md" })
        (New-Tool -Name 'Read' -ToolInput @{ file_path = 'D:\private\someone\notes.txt' })
        (New-Tool -Name 'Agent' -ToolInput @{ subagent_type = 'Explore'; prompt = 'find it' })
        (New-Tool -Name 'PowerShell' -ToolInput @{ command = 'Get-Content README.md | Select-Object -First 5' })
    ) | Set-Content -LiteralPath (Join-Path $projLane 'bbbb2222.jsonl') -Encoding ascii
    (Get-Item -LiteralPath (Join-Path $projLane 'bbbb2222.jsonl')).LastWriteTime = (Get-Date '2026-11-05 10:00')

    # SESSION C -- another repo's. The default scope must not read it.
    @( (New-Tool -Name 'Grep' -ToolInput @{ pattern = 'x' }) ) | Set-Content -LiteralPath (Join-Path $projOther 'cccc3333.jsonl') -Encoding ascii

    $env:CLAUDE_PROJECT_DIR = $fakeRepo
    $raw = & $ScriptPath -TranscriptRoot $fixtureRoot -Json 2>&1 | Out-String
    $exit = $LASTEXITCODE
    $human = & $ScriptPath -TranscriptRoot $fixtureRoot 2>&1 | Out-String

    Write-Host ''
    Write-Host 'Scope: this checkout and its lanes, not another repo' -ForegroundColor Cyan
    Assert-Equal 0 $exit '-Json exits 0'
    $r = $raw | ConvertFrom-Json
    Assert-Equal 2 $r.Summary.Sessions 'two sessions read -- the own project directory and its lane'
    Assert-True (-not (@($r.Sessions | Where-Object { $_.Session -eq 'cccc3333' }).Count)) "another repo's session is not read"

    Write-Host ''
    Write-Host 'The counts' -ForegroundColor Cyan
    $a = @($r.Sessions | Where-Object { $_.Session -eq 'aaaa1111' })[0]
    Assert-Equal 4 $a.LookupsBeforeFirstEdit 'four lookups before the first edit; the Glob after it does not count'
    Assert-Equal 3 $a.Searches 'Grep, shell grep and Glob are three searches'
    Assert-Equal 2 $a.Reads 'two reads'
    Assert-Equal 1 $a.ReReads '...one of them a re-read'
    Assert-Equal 3 $a.Edits 'three edits'
    Assert-Equal 1 $a.RevertedEdits 'the exact swap is one reverted edit; the later, different edit is not'
    Assert-Equal 80 $a.OutputTokens 'output tokens are summed over the eight parsed tool records; the half-written line is skipped'

    $b = @($r.Sessions | Where-Object { $_.Session -eq 'bbbb2222' })[0]
    Assert-Equal '' "$($b.LookupsBeforeFirstEdit)" 'a session that never edits reports no lookups-before-edit, not zero'
    Assert-Equal 1 $b.Explores 'an Explore delegation is counted'
    Assert-Equal 1 $b.ShellReads 'Get-Content is a shell read'

    Write-Host ''
    Write-Host 'Across sessions, and the paths it shows' -ForegroundColor Cyan
    $guide = @($r.HotFiles | Where-Object { $_.Path -eq 'docs/guide.md' })[0]
    Assert-True ($null -ne $guide) 'a repo file is shown repo-relative'
    Assert-Equal 2 $guide.Sessions '...and the lane path folds onto the same file: read in two sessions'
    Assert-Equal 1 $guide.ReReadIn '...re-read within one of them'
    Assert-True (@($r.HotFiles | Where-Object { $_.Path -eq '(outside the repo)' }).Count -eq 1) 'a path outside the repo is hidden'

    Write-Host ''
    Write-Host 'No transcript text leaves it' -ForegroundColor Cyan
    foreach ($out in @(@{ N = 'JSON'; T = $raw }, @{ N = 'report'; T = $human })) {
        Assert-True ($out.T -notmatch 'SECRET-SEARCH-PATTERN') "the $($out.N) carries no search pattern"
        Assert-True ($out.T -notmatch 'SECRET-MESSAGE-TEXT') "the $($out.N) carries no message text"
        Assert-True ($out.T -notmatch 'someone') "the $($out.N) carries no path outside the repo"
    }

    Write-Host ''
    Write-Host 'The filters' -ForegroundColor Cyan
    $last1 = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json -Last 1 | Out-String) | ConvertFrom-Json
    Assert-Equal 'bbbb2222' (@($last1.Sessions)[0].Session) '-Last 1 reads the most recent session'
    $since = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json -Since '2026-11-03' | Out-String) | ConvertFrom-Json
    Assert-Equal 1 $since.Summary.Sessions '-Since leaves out the older session'
    $until = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json -Until '2026-11-03' | Out-String) | ConvertFrom-Json
    Assert-Equal 'aaaa1111' (@($until.Sessions)[0].Session) '-Until keeps only the older session'
    $proj = (& $ScriptPath -TranscriptRoot $fixtureRoot -Json -Project 'C--work-other-repo' | Out-String) | ConvertFrom-Json
    Assert-Equal 'cccc3333' (@($proj.Sessions)[0].Session) '-Project reads the directory it names instead'

    & $ScriptPath -TranscriptRoot (Join-Path $fixtureRoot 'missing') *>&1 | Out-Null
    Assert-Equal 0 $LASTEXITCODE 'a missing transcript root is a skip, still exit 0'
}
finally {
    Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $fixtureRoot) { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "Result: $script:pass pass, $script:fail fail." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
