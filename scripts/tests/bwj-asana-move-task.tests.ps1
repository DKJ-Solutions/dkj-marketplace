<#
.SYNOPSIS
    Regression tests for the BWJ extension's Asana card move -- scripts/lib/asana-section-lib.ps1 and
    scripts/task/move-asana-task.ps1 (#4291). Dependency-free, no network.

.DESCRIPTION
        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/bwj-asana-move-task.tests.ps1

    WHAT IT HOLDS:
      1. ONE SECTION RULE. The CI scripts (scripts/ci/) dot-source this lib since #4366, so a manual
         move and an automated move read a section's code through the same Get-SectionCode. Held here
         by asserting no CI script defines a Get-SectionCode of its own, beside the lib's own answers
         below.
      2. THE RESOLUTION: a code never hits a longer code ('2' is not '2B'), none or several throw.
      3. THE MOVE, driven with injected -Get and -Send: it writes only for a task on the repo's own
         board (#4282), never on a dry run, and reports a refused write.
      4. THE TASK OF AN ISSUE is the one Resolve-AsanaTaskRef finds, and no GID here is a real one.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$ExtRoot  = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
$LibPath  = Join-Path $ExtRoot 'scripts\lib\asana-section-lib.ps1'
$ScriptPath = Join-Path $ExtRoot 'scripts\task\move-asana-task.ps1'
$Fixture  = Join-Path ([System.IO.Path]::GetTempPath()) "bwj-asana-move-fixture-$PID-$([guid]::NewGuid().ToString('n'))"

$script:pass = 0
$script:fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Label)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label" -ForegroundColor Red }
}
function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Assert-Throws {
    param([scriptblock]$Action, [string]$Label)
    $threw = $false
    try { & $Action | Out-Null } catch { $threw = $true }
    Assert-True $threw $Label
}

Write-Host ''
Write-Host 'The Asana card move (#4291)' -ForegroundColor Cyan
Assert-True (Test-Path -LiteralPath $LibPath) 'the extension ships scripts/lib/asana-section-lib.ps1'
Assert-True (Test-Path -LiteralPath $ScriptPath) 'and scripts/task/move-asana-task.ps1'
Assert-True (Test-Path -LiteralPath (Join-Path $ExtRoot 'skills\move-asana-task\SKILL.md')) 'and the skill that carries the script'
. $LibPath

# --- 1. one section rule: the CI scripts load it rather than carry a copy (#4366) -----------------------
foreach ($ci in @('asana-closed-message.ps1', 'asana-open-section.ps1')) {
    $file = Join-Path $ExtRoot "scripts\ci\$ci"
    $tokens = $null; $errs = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errs)
    $own = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Get-SectionCode' }, $true)
    Assert-True ($null -eq $own) "$ci defines no Get-SectionCode of its own"
    $src = [System.IO.File]::ReadAllText($file)
    Assert-True ($src.Contains("Join-Path `$PSScriptRoot '../lib/asana-section-lib.ps1'") -and $src -match '(?m)^\. \$asanaLibPath\s*$') "and dot-sources the lib's"
}
Assert-Equal '1C' (Get-SectionCode -Name '1C. Waiting') 'a digit plus a letter is one code'
Assert-Equal '3' (Get-SectionCode -Name ' 3.x') 'leading space tolerated'
Assert-Equal '' (Get-SectionCode -Name 'No code') 'no code is empty'

# --- 2. the resolution ----------------------------------------------------------------------------------
$sections = @(
    [pscustomobject]@{ Gid = '11'; Name = '1. Todo' },
    [pscustomobject]@{ Gid = '22'; Name = '2. In Progress' },
    [pscustomobject]@{ Gid = '23'; Name = '2B. Blocked' },
    [pscustomobject]@{ Gid = '44'; Name = '4. Done' }
)
Assert-Equal '22' (Find-SectionGid -Sections $sections -Code '2') "'2' does not hit '2B'"
Assert-Equal '22' (Find-SectionGid -Sections $sections -Code '2.') 'a trailing dot is accepted'
Assert-Equal '23' (Find-SectionGid -Sections $sections -Code '2b') 'a lower-case letter is accepted'
Assert-Throws { Find-SectionGid -Sections $sections -Code '9' } 'an unknown code throws'
Assert-Throws { Find-SectionGid -Sections ($sections + [pscustomobject]@{ Gid = '99'; Name = '2. Also' }) -Code '2' } 'an ambiguous code throws'
Assert-Throws { Find-SectionGid -Sections $sections -Code 'In Progress' } 'a name is not a code'
Assert-Equal 3 @(Split-ListArgument @('1,2', ' 3 ')).Count 'comma and array forms mix'

# --- 3. the task of an issue ----------------------------------------------------------------------------
$proj = '1000000000000001'
$task = '2000000000000002'
Assert-Equal $task (Get-AsanaIssueTaskGid -IssueBody "text`n<!-- asana-task: $task -->").Gid 'the marker names the task'
Assert-Equal $task (Get-AsanaIssueTaskGid -IssueBody "see https://app.asana.com/0/$proj/$task").Gid 'one task link names the task, not the project'
Assert-Equal 'ambiguous' (Get-AsanaIssueTaskGid -IssueBody "https://app.asana.com/0/$proj/$task and https://app.asana.com/0/$proj/3000000000000003").Source 'two task links are ambiguous'
Assert-Equal $null (Get-AsanaIssueTaskGid -IssueBody 'no link').Gid 'no link, no task'

# --- 4. the move, with the reads and the write injected -------------------------------------------------
$script:sent = @()
$get = {
    param($Uri)
    if ($Uri -match '/projects/1000000000000001/sections') { return [pscustomobject]@{ data = @([pscustomobject]@{ gid = '11'; name = '1. Todo' }, [pscustomobject]@{ gid = '22'; name = '2. In Progress' }) } }
    if ($Uri -match '/tasks/2000000000000002') { return [pscustomobject]@{ data = [pscustomobject]@{ memberships = @([pscustomobject]@{ project = [pscustomobject]@{ gid = '9000000000000009' } }, [pscustomobject]@{ project = [pscustomobject]@{ gid = '1000000000000001' } }) } } }
    if ($Uri -match '/tasks/4000000000000004') { return [pscustomobject]@{ data = [pscustomobject]@{ memberships = @([pscustomobject]@{ project = [pscustomobject]@{ gid = '9000000000000009' } }) } } }
    throw 'not found'
}
$send = { param($Request) $script:sent += $Request; [pscustomobject]@{ Ok = $true; Status = '' } }
$targets = @([pscustomobject]@{ Label = '#7'; Gid = $task })

$out = @(Invoke-AsanaTaskMove -Section '2' -Target $targets -ProjectGid $proj -Pat 'x' -Get $get -Send $send)
Assert-Equal '[MOVED] #7 (2000000000000002) -> 2. In Progress' $out[0] 'a task on the repo board moves, and the line names the section'
Assert-Equal 1 $script:sent.Count 'with exactly one write'
Assert-True ($script:sent[0].Uri -like '*/sections/22/addTask') 'into the section the code resolved to'

$script:sent = @()
$out = @(Invoke-AsanaTaskMove -Section '2' -Target $targets -ProjectGid $proj -Pat 'x' -DryRun -Get $get -Send $send)
Assert-True ($out[0] -like '[[]DRY-RUN]*') 'a dry run says what would move'
Assert-Equal 0 $script:sent.Count 'and writes nothing'

$out = @(Invoke-AsanaTaskMove -Section '2' -Target @([pscustomobject]@{ Label = 'task'; Gid = '4000000000000004' }) -ProjectGid $proj -Pat 'x' -Get $get -Send $send)
Assert-True ($out[0] -like '[[]SKIP]*not on the repo*') 'a task that is not on the repo board is skipped'
Assert-Equal 0 $script:sent.Count 'and never added to it'

$out = @(Invoke-AsanaTaskMove -Section '2' -Target @([pscustomobject]@{ Label = 'task'; Gid = '5000000000000005' }) -ProjectGid $proj -Pat 'x' -Get $get -Send $send)
Assert-True ($out[0] -like '[[]SKIP]*could not be read*') 'an unreadable task is skipped, not fatal'

$out = @(Invoke-AsanaTaskMove -Section '2' -Target $targets -ProjectGid $proj -Pat 'x' -Get $get -Send { param($Request) [pscustomobject]@{ Ok = $false; Status = 'HTTP 403' } })
Assert-True ($out[0] -like '[[]FAILED]*HTTP 403') 'a refused write is reported with its status'

Assert-Throws { Invoke-AsanaTaskMove -Section '9' -Target $targets -ProjectGid $proj -Pat 'x' -Get $get -Send $send } 'an unknown section throws before any write'
Assert-Throws { Invoke-AsanaTaskMove -Section '2' -Target $targets -ProjectGid 'abc' -Pat 'x' -Get $get -Send $send } 'a non-numeric board GID is refused'
Assert-Throws { Invoke-AsanaTaskMove -Section '2' -Target $targets -ProjectGid $proj -Pat '' } 'a missing ASANA_PAT is refused'
Assert-Throws { New-AsanaMoveRequest -Gid 'x' -SectionGid '22' } 'a non-numeric task GID never reaches a URL'

# --- 5. the script, end to end up to the network --------------------------------------------------------
New-Item -ItemType Directory -Path (Join-Path $Fixture 'scripts') -Force | Out-Null
[System.IO.File]::WriteAllText((Join-Path $Fixture 'scripts\repo-config.ps1'), "function Get-Other { 'x' }`r`n", (New-Object System.Text.UTF8Encoding($false)))
$ErrorActionPreference = 'Continue'; $run = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -Section 2 -TaskGid 2000000000000002 -RootOverride $Fixture 2>&1; $ErrorActionPreference = 'Stop'
Assert-True (($run | Out-String) -match 'Get-AsanaProjectGid has no answer') 'a repo that does not answer Get-AsanaProjectGid is refused'
$ErrorActionPreference = 'Continue'; $run = & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -Section 2 -RootOverride $Fixture 2>&1; $ErrorActionPreference = 'Stop'
Assert-True (($run | Out-String) -match 'Get-AsanaProjectGid has no answer|Name at least one task') 'and naming no task is refused too'

$bytes = [System.IO.File]::ReadAllBytes($LibPath) + [System.IO.File]::ReadAllBytes($ScriptPath)
Assert-True (-not ($bytes | Where-Object { $_ -gt 127 })) 'both files are pure ASCII'

if (Test-Path -LiteralPath $Fixture) { Remove-Item -LiteralPath $Fixture -Recurse -Force -ErrorAction SilentlyContinue }
Write-Host ''
Write-Host "Result: $script:pass pass, $script:fail fail." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
