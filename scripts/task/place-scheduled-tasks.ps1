<#
.SYNOPSIS
    Place the versioned Claude Code Desktop scheduled-task prompts into this machine's
    ~/.claude/scheduled-tasks/, and refresh every copy already placed (issue #4162).

.DESCRIPTION
    WHY THE PROMPTS ARE VERSIONED. A Desktop scheduled task keeps its prompt in
    ~/.claude/scheduled-tasks/<task-name>/SKILL.md, on one machine. Written by hand there, it is
    unversioned and different on each owner's machine -- #4162's first task was tested on one machine
    and absent on the other. So the prompts live in the scheduled-tasks skill (tasks/<task>.md), and
    this command places them.

    WHAT THE FILE CAN CARRY, AND WHAT IT CANNOT. Per the Desktop scheduled-tasks documentation
    (code.claude.com/docs/en/desktop-scheduled-tasks), SKILL.md holds YAML frontmatter for 'name' and
    'description' and the prompt as its body, and a change takes effect on the next run. The schedule,
    the working folder and the enabled state are NOT in the file: they live in the Desktop app and are
    set in its Edit form or by asking Claude in a Desktop session. So this command writes the prompt and
    PRINTS the schedule and folder for a person to set once; it cannot register a task, and does not
    pretend to. The source file's extra frontmatter keys (schedule, cron, folder, requires) are for that
    print and are not written to the placed file.

    ONE PROMPT, SEVERAL TASKS. A Desktop task has one folder, so a prompt meant for each store repo is
    placed once per repo under its own task name: '-Task bwj-release-prep -Name bwj-release-prep-<repo>'.
    Every placed file ends with a marker line naming its source task, and a run without -Task refreshes
    every placed copy it finds by that marker -- so a release that changes a prompt reaches every task
    that uses it with one command, on each machine.

    A CHANGED LOCAL COPY IS KEPT, NOT LOST. Where the placed file differs from what this run would write
    (an edit made in the Desktop app, or an older release), the old file is saved beside it as
    SKILL.md.previous before it is replaced. The versioned prompt wins: a change worth keeping is made in
    the skill, through a branch.

    A DRY RUN BY DEFAULT, like every command in this family that writes outside the repo: without
    -Apply it prints what it would write and writes nothing.

    Where the config root is: -UserHomeOverride\.claude when given (tests), else CLAUDE_CONFIG_DIR when
    set (the documentation names it), else ~/.claude.

    Dual-context: run the root copy in this repo, the plugin mirror in a consumer. Pure ASCII, per this
    repo's script-layer convention.

.PARAMETER Task
    The versioned task to place, by its file name under the skill's tasks/ folder. Without it the run
    refreshes every copy already placed and lists the tasks not placed anywhere yet.

.PARAMETER Name
    The Desktop task name (and folder) to place -Task under. Default: the task's own name. Lowercase
    kebab-case, which is what Desktop uses for the folder.

.PARAMETER Apply
    Write. Without it nothing is written.

.PARAMETER TasksRoot
    The folder holding the versioned task files. Default: the scheduled-tasks skill's tasks/ folder,
    found beside this script in the plugin or in the source repo. For the test suite.

.PARAMETER UserHomeOverride
    The home directory '.claude' hangs off, for the test suite. A consumer never types this.

.EXAMPLE
    ./scripts/task/place-scheduled-tasks.ps1
.EXAMPLE
    ./scripts/task/place-scheduled-tasks.ps1 -Task bwj-release-prep -Name bwj-release-prep-mystore -Apply
#>
[CmdletBinding()]
param(
    [string]$Task = '',
    [string]$Name = '',
    [switch]$Apply,
    [string]$TasksRoot = '',
    [string]$UserHomeOverride = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# The source-repo guard, wired the way every shared entry point wires it.
$guardLib = Join-Path $PSScriptRoot '..\lib\source-repo-guard-lib.ps1'
if (Test-Path -LiteralPath $guardLib -PathType Leaf) { . $guardLib; Assert-OwnCopy -ScriptPath $PSCommandPath }

$Utf8 = New-Object System.Text.UTF8Encoding($false)
$MarkerPrefix = '<!-- placed by dkj-policy scheduled-tasks: '

function Read-TaskSource {
    # Splits a versioned task file into its frontmatter keys and its body. Returns $null when the file
    # carries no frontmatter or no name.
    param([string]$Path)
    $text = [System.IO.File]::ReadAllText($Path, $Utf8) -replace "`r`n", "`n"
    $m = [regex]::Match($text, '\A---\n(?<fm>.*?)\n---\n(?<body>.*)\z', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $m.Success) { return $null }
    $keys = @{}
    foreach ($line in ($m.Groups['fm'].Value -split "`n")) {
        $kv = [regex]::Match($line, '^(?<k>[a-z]+):\s*(?<v>.*)$')
        if ($kv.Success) { $keys[$kv.Groups['k'].Value] = $kv.Groups['v'].Value.Trim() }
    }
    if (-not $keys.ContainsKey('name') -or -not $keys['name']) { return $null }
    return [pscustomobject]@{ Keys = $keys; Body = $m.Groups['body'].Value.Trim() }
}

function Format-PlacedTask {
    # The file Desktop reads: name and description only, the prompt, and the marker line.
    param($Source, [string]$TaskName, [string]$SourceName)
    $desc = if ($Source.Keys.ContainsKey('description')) { $Source.Keys['description'] } else { '' }
    return "---`nname: $TaskName`ndescription: $desc`n---`n`n$($Source.Body)`n`n$MarkerPrefix$SourceName -->`n"
}

function Get-PlacedSourceName {
    # The source task a placed SKILL.md names in its marker line, or '' when it carries none.
    param([string]$Path)
    $m = [regex]::Match([System.IO.File]::ReadAllText($Path, $Utf8), '<!-- placed by dkj-policy scheduled-tasks: (?<n>[a-z0-9-]+) -->')
    if ($m.Success) { return $m.Groups['n'].Value } else { return '' }
}

# --- Where the versioned tasks are, and where Desktop keeps its tasks -------------------------------
if (-not $TasksRoot) {
    foreach ($candidate in @(
            (Join-Path $PSScriptRoot '..\..\skills\scheduled-tasks\tasks'),                       # plugin mirror
            (Join-Path $PSScriptRoot '..\..\plugins\dkj-policy\skills\scheduled-tasks\tasks'))) {   # source repo
        if (Test-Path -LiteralPath $candidate -PathType Container) { $TasksRoot = (Resolve-Path -LiteralPath $candidate).Path; break }
    }
}
if (-not $TasksRoot -or -not (Test-Path -LiteralPath $TasksRoot -PathType Container)) {
    Write-Host "place-scheduled-tasks: cannot find the versioned tasks folder (skills/scheduled-tasks/tasks)." -ForegroundColor Red
    exit 1
}

$configRoot = if ($UserHomeOverride) { Join-Path $UserHomeOverride '.claude' }
              elseif ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR }
              else { Join-Path $HOME '.claude' }
$tasksDir = Join-Path $configRoot 'scheduled-tasks'

$sources = @{}
foreach ($f in @(Get-ChildItem -LiteralPath $TasksRoot -Filter '*.md' -File | Sort-Object Name)) {
    $s = Read-TaskSource -Path $f.FullName
    $id = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    if (-not $s) { Write-Host "place-scheduled-tasks: $($f.Name) has no frontmatter with a name -- skipped." -ForegroundColor Yellow; continue }
    if ($s.Keys['name'] -ne $id) { Write-Host "place-scheduled-tasks: $($f.Name) names itself '$($s.Keys['name'])' -- the file name and the name must agree; skipped." -ForegroundColor Yellow; continue }
    $sources[$id] = $s
}

function Write-Schedule {
    param($Source, [string]$TaskName)
    $k = $Source.Keys
    Write-Host "           register it once in Claude Desktop (Scheduled -> New task, or ask Claude in a Desktop session):"
    Write-Host "             name:     $TaskName"
    if ($k.ContainsKey('schedule')) { Write-Host "             schedule: $($k['schedule'])$(if ($k.ContainsKey('cron')) { "  (custom cron: $($k['cron']))" })" }
    if ($k.ContainsKey('folder'))   { Write-Host "             folder:   $($k['folder'])" }
    if ($k.ContainsKey('requires')) { Write-Host "             requires: the '$($k['requires'])' plugin enabled in that folder" }
    Write-Host "           Creating it there may write its own prompt over this file: run this command with -Apply again afterwards."
}

function Invoke-Place {
    # Places one source task under one Desktop task name. Returns the outcome.
    param([string]$SourceName, [string]$TaskName)
    $src = $sources[$SourceName]
    $dir = Join-Path $tasksDir $TaskName
    $file = Join-Path $dir 'SKILL.md'
    $want = Format-PlacedTask -Source $src -TaskName $TaskName -SourceName $SourceName
    $exists = Test-Path -LiteralPath $file -PathType Leaf
    $have = if ($exists) { [System.IO.File]::ReadAllText($file, $Utf8) -replace "`r`n", "`n" } else { '' }
    if ($exists -and $have -eq $want) {
        Write-Host ("  current  {0}  (from {1})" -f $TaskName, $SourceName) -ForegroundColor Green
        return 'current'
    }
    $outcome = if ($exists) { 'update' } else { 'new' }
    $verb = if ($Apply) { @{ new = 'placed'; update = 'updated' }[$outcome] } else { @{ new = 'would place'; update = 'would update' }[$outcome] }
    Write-Host ("  {0,-8} {1}  (from {2}) -> {3}" -f $verb, $TaskName, $SourceName, $file) -ForegroundColor Cyan
    if ($Apply) {
        if (-not (Test-Path -LiteralPath $dir -PathType Container)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        if ($exists) {
            [System.IO.File]::WriteAllText("$file.previous", $have, $Utf8)
            Write-Host "           the previous file is kept as SKILL.md.previous"
        }
        [System.IO.File]::WriteAllText($file, $want, $Utf8)
    }
    if ($outcome -eq 'new') { Write-Schedule -Source $src -TaskName $TaskName }
    return $outcome
}

Write-Host "place-scheduled-tasks -- $tasksDir$(if (-not $Apply) { ' (dry run: nothing is written)' })" -ForegroundColor Cyan

if ($Task) {
    if (-not $sources.ContainsKey($Task)) {
        Write-Host "place-scheduled-tasks: no versioned task '$Task'. Known: $((@($sources.Keys) | Sort-Object) -join ', ')." -ForegroundColor Red
        exit 1
    }
    $taskName = if ($Name) { $Name } else { $Task }
    if ($taskName -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
        Write-Host "place-scheduled-tasks: '$taskName' is not lowercase kebab-case, the form Desktop uses for a task's folder." -ForegroundColor Red
        exit 1
    }
    $null = Invoke-Place -SourceName $Task -TaskName $taskName
    exit 0
}
if ($Name) {
    Write-Host 'place-scheduled-tasks: -Name places one task, so it needs -Task.' -ForegroundColor Red
    exit 1
}

# No -Task: refresh every placed copy, found by its marker line, and list what is placed nowhere.
$placed = @{}
if (Test-Path -LiteralPath $tasksDir -PathType Container) {
    foreach ($d in @(Get-ChildItem -LiteralPath $tasksDir -Directory | Sort-Object Name)) {
        $f = Join-Path $d.FullName 'SKILL.md'
        if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { continue }
        $srcName = Get-PlacedSourceName -Path $f
        if (-not $srcName) { continue }
        if (-not $sources.ContainsKey($srcName)) {
            Write-Host ("  orphan   {0}  -- names '{1}', which this release no longer ships; delete the task in Desktop and its folder by hand." -f $d.Name, $srcName) -ForegroundColor Yellow
            continue
        }
        $placed[$srcName] = $true
        $null = Invoke-Place -SourceName $srcName -TaskName $d.Name
    }
}
foreach ($id in (@($sources.Keys) | Sort-Object)) {
    if ($placed.ContainsKey($id)) { continue }
    Write-Host ("  unplaced {0}  -- {1}" -f $id, $sources[$id].Keys['description']) -ForegroundColor Yellow
    Write-Host "           place it with: -Task $id [-Name <task-name>] -Apply"
}
exit 0
