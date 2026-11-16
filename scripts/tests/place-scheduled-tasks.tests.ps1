<#
.SYNOPSIS
    Regression tests for scripts/task/place-scheduled-tasks.ps1 (issue #4162): placing the versioned
    Desktop scheduled-task prompts into ~/.claude/scheduled-tasks/ and refreshing placed copies.

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/place-scheduled-tasks.tests.ps1

    Every case runs against a scratch tasks folder and a scratch home, so the machine's own
    ~/.claude is never read or written. Each write case also asserts what was NOT written: a dry run
    that wrote anyway, or a refresh that touched a task it does not own, is the defect this suite
    exists to catch. The last case holds the shipped tasks/ folder to the shape the script reads.

    Fixture paths carry $PID (repo convention). Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Script   = Join-Path $RepoRoot 'scripts\task\place-scheduled-tasks.ps1'
$Shipped  = Join-Path $RepoRoot 'plugins\dkj-policy\skills\scheduled-tasks\tasks'

$script:pass  = 0
$script:fail  = 0
$script:trees = @()
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-Fixture {
    # A tasks folder with two versioned tasks and an empty home.
    param([string]$Label)
    $base = Join-Path ([System.IO.Path]::GetTempPath()) ("place-tasks-$PID-$Label-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    $script:trees += $base
    $tasks = Join-Path $base 'tasks'
    $home_ = Join-Path $base 'home'
    New-Item -ItemType Directory -Path $tasks, $home_ -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $tasks 'alpha.md'), "---`nname: alpha`ndescription: The alpha task.`nschedule: Weekly, Friday 14:07`ncron: 7 14 * * 5`nfolder: a store repo`nrequires: some-plugin`n---`n`nDo the alpha thing.`n", $Utf8)
    [System.IO.File]::WriteAllText((Join-Path $tasks 'beta.md'), "---`nname: beta`ndescription: The beta task.`n---`n`nDo the beta thing.`n", $Utf8)
    return [pscustomobject]@{ Base = $base; Tasks = $tasks; Home = $home_; Dir = (Join-Path $home_ '.claude\scheduled-tasks') }
}

function Invoke-Place {
    param($Fx, [string[]]$Extra = @())
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -TasksRoot $Fx.Tasks -UserHomeOverride $Fx.Home @Extra 2>&1
    return [pscustomobject]@{ Exit = $LASTEXITCODE; Text = (@($out) -join "`n") }
}

function Read-Placed { param($Fx, [string]$Name) return [System.IO.File]::ReadAllText((Join-Path $Fx.Dir "$Name\SKILL.md"), $Utf8) }

try {
    Write-Host 'Case 1: a dry run lists the unplaced tasks and writes nothing'
    $fx = New-Fixture 'dry'
    $r = Invoke-Place $fx
    Assert-True ($r.Exit -eq 0) 'exits 0'
    Assert-True ($r.Text -match 'unplaced alpha' -and $r.Text -match 'unplaced beta') 'names both tasks as unplaced'
    Assert-True (-not (Test-Path -LiteralPath $fx.Dir)) 'creates no scheduled-tasks folder'
    $r = Invoke-Place $fx @('-Task', 'alpha')
    Assert-True ($r.Text -match 'would place alpha') 'a dry run of one task says it would place it'
    Assert-True (-not (Test-Path -LiteralPath $fx.Dir)) 'and still writes nothing'

    Write-Host 'Case 2: -Task -Name -Apply places the prompt with name and description only'
    $r = Invoke-Place $fx @('-Task', 'alpha', '-Name', 'alpha-store1', '-Apply')
    Assert-True ($r.Exit -eq 0) 'exits 0'
    $placed = Read-Placed $fx 'alpha-store1'
    Assert-True ($placed.StartsWith("---`nname: alpha-store1`ndescription: The alpha task.`n---`n")) 'frontmatter carries the Desktop task name and the description'
    Assert-True ($placed -notmatch 'schedule:|cron:|folder:|requires:') 'the print-only keys are not written to the placed file'
    Assert-True ($placed -match 'Do the alpha thing\.') 'the prompt body is written'
    Assert-True ($placed -match '<!-- placed by dkj-policy scheduled-tasks: alpha -->') 'the marker names the source task'
    Assert-True ($r.Text -match 'name:\s+alpha-store1' -and $r.Text -match 'custom cron: 7 14 \* \* 5' -and $r.Text -match "requires: the 'some-plugin' plugin") 'prints the registration: name, schedule, cron, requirement'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $fx.Dir 'alpha'))) 'places nothing under the default name'

    Write-Host 'Case 3: a second run finds the copy current'
    $r = Invoke-Place $fx @('-Apply')
    Assert-True ($r.Text -match 'current\s+alpha-store1') 'the placed copy is current'
    Assert-True ($r.Text -notmatch 'unplaced alpha') 'alpha is no longer listed as unplaced'
    Assert-True ($r.Text -match 'unplaced beta') 'beta still is'
    Assert-True (@(Get-ChildItem -LiteralPath (Join-Path $fx.Dir 'alpha-store1') -Filter 'SKILL.md.previous-*').Count -eq 0) 'a current copy leaves no backup'

    Write-Host 'Case 4: a changed copy is refreshed by marker, and the old file is kept'
    $file = Join-Path $fx.Dir 'alpha-store1\SKILL.md'
    $edited = (Read-Placed $fx 'alpha-store1') -replace 'Do the alpha thing\.', 'Edited in the app.'
    [System.IO.File]::WriteAllText($file, $edited, $Utf8)
    $r = Invoke-Place $fx
    Assert-True ($r.Text -match 'would update alpha-store1') 'a dry run names the update'
    Assert-True ((Read-Placed $fx 'alpha-store1') -match 'Edited in the app\.') 'and leaves the file as it was'
    $r = Invoke-Place $fx @('-Apply')
    Assert-True ($r.Text -match 'updated\s+alpha-store1') 'the apply run updates it'
    Assert-True ((Read-Placed $fx 'alpha-store1') -match 'Do the alpha thing\.') 'the versioned prompt is back'
    $backups = @(Get-ChildItem -LiteralPath (Join-Path $fx.Dir 'alpha-store1') -Filter 'SKILL.md.previous-*')
    Assert-True ($backups.Count -eq 1 -and [System.IO.File]::ReadAllText($backups[0].FullName, $Utf8) -match 'Edited in the app\.') 'the edited copy is kept as a timestamped SKILL.md.previous-* backup'
    Assert-True ($r.Text -notmatch 'register it once') 'an update prints no registration step'

    Write-Host 'Case 5: an orphan marker and an unmarked task are left untouched'
    $orphan = Join-Path $fx.Dir 'gone-task'; New-Item -ItemType Directory -Path $orphan -Force | Out-Null
    $orphanText = "---`nname: gone-task`ndescription: x`n---`n`nold`n`n<!-- placed by dkj-policy scheduled-tasks: gone -->`n"
    [System.IO.File]::WriteAllText((Join-Path $orphan 'SKILL.md'), $orphanText, $Utf8)
    $own = Join-Path $fx.Dir 'my-own-task'; New-Item -ItemType Directory -Path $own -Force | Out-Null
    # It even quotes the marker mid-file -- only a marker on the last line makes a copy ours.
    $ownText = "---`nname: my-own-task`ndescription: mine`n---`n`nDo the alpha thing differently.`n<!-- placed by dkj-policy scheduled-tasks: alpha -->`nMy own last line.`n"
    [System.IO.File]::WriteAllText((Join-Path $own 'SKILL.md'), $ownText, $Utf8)
    $r = Invoke-Place $fx @('-Apply')
    Assert-True ($r.Text -match 'orphan\s+gone-task') 'the orphan is reported'
    Assert-True ([System.IO.File]::ReadAllText((Join-Path $orphan 'SKILL.md'), $Utf8) -eq $orphanText) 'the orphan file is unchanged'
    Assert-True ([System.IO.File]::ReadAllText((Join-Path $own 'SKILL.md'), $Utf8) -eq $ownText) 'a task without a marker is unchanged'
    Assert-True ($r.Text -notmatch 'my-own-task') 'and is not mentioned'

    Write-Host 'Case 6: refusals'
    $r = Invoke-Place $fx @('-Task', 'nope')
    Assert-True ($r.Exit -eq 1 -and $r.Text -match "no versioned task 'nope'") 'an unknown task is refused'
    $r = Invoke-Place $fx @('-Task', 'alpha', '-Name', 'Bad Name')
    Assert-True ($r.Exit -eq 1 -and $r.Text -match 'kebab-case') 'a name Desktop would not use as a folder is refused'
    $r = Invoke-Place $fx @('-Name', 'alpha-x')
    Assert-True ($r.Exit -eq 1 -and $r.Text -match 'needs -Task') '-Name without -Task is refused'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $fx.Dir 'alpha-x'))) 'and writes nothing'

    Write-Host 'Case 7: a task file whose name disagrees with its file name is skipped'
    [System.IO.File]::WriteAllText((Join-Path $fx.Tasks 'gamma.md'), "---`nname: delta`ndescription: d`n---`n`nbody`n", $Utf8)
    $r = Invoke-Place $fx
    Assert-True ($r.Text -match "gamma\.md names itself 'delta'") 'the mismatch is reported'
    Assert-True ($r.Text -notmatch 'unplaced (gamma|delta)') 'and the task is not offered'
    [System.IO.File]::WriteAllText((Join-Path $fx.Tasks 'Foo_bar.md'), "---`nname: Foo_bar`ndescription: d`n---`n`nbody`n", $Utf8)
    [System.IO.File]::WriteAllText((Join-Path $fx.Tasks 'nodesc.md'), "---`nname: nodesc`n---`n`nbody`n", $Utf8)
    [System.IO.File]::WriteAllText((Join-Path $fx.Tasks 'yamlish.md'), "---`nname: yamlish`ndescription: Note: this breaks YAML`n---`n`nbody`n", $Utf8)
    $r = Invoke-Place $fx
    Assert-True ($r.Exit -eq 0) 'malformed task files do not stop the run'
    Assert-True ($r.Text -match 'Foo_bar\.md is not lowercase kebab-case') 'a non-kebab file name is skipped, since its marker could never be matched'
    Assert-True ($r.Text -match 'nodesc\.md needs a description' -and $r.Text -match 'yamlish\.md needs a description') 'a missing description and one YAML would misread are skipped'
    Assert-True ($r.Text -notmatch 'unplaced (Foo_bar|nodesc|yamlish)') 'none of them is offered'

    Write-Host 'Case 8: both copies find the shipped tasks folder from their own depth'
    # The default -TasksRoot ascends two levels, which is the repo root in the source copy and the
    # plugin root in the mirror (check mirror-depth). Each copy is run without -TasksRoot.
    $fx = New-Fixture 'depth'
    $Mirror = Join-Path $RepoRoot 'plugins\dkj-policy\scripts\task\place-scheduled-tasks.ps1'
    $shippedNames = @(Get-ChildItem -LiteralPath $Shipped -Filter '*.md' -File | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) })
    foreach ($copy in @(@{ Label = 'the source copy'; Path = $Script }, @{ Label = 'the plugin mirror'; Path = $Mirror })) {
        Assert-True (Test-Path -LiteralPath $copy.Path -PathType Leaf) "$($copy.Label) exists"
        $out = (@(& powershell -NoProfile -ExecutionPolicy Bypass -File $copy.Path -UserHomeOverride $fx.Home 2>&1) -join "`n")
        $all = @($shippedNames | Where-Object { $out -match "unplaced $([regex]::Escape($_)) " }).Count -eq $shippedNames.Count
        Assert-True ($LASTEXITCODE -eq 0 -and $all) "$($copy.Label) lists every shipped task"
    }

    Write-Host 'Case 9: every shipped task has the shape the script reads'
    $files = @(Get-ChildItem -LiteralPath $Shipped -Filter '*.md' -File)
    Assert-True ($files.Count -ge 1) 'the skill ships at least one task'
    foreach ($f in $files) {
        $t = [System.IO.File]::ReadAllText($f.FullName, $Utf8) -replace "`r`n", "`n"
        $id = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
        Assert-True ($t -match "\A---\nname: $([regex]::Escape($id))\n") "$($f.Name): starts with frontmatter naming '$id'"
        Assert-True ($t -match '(?m)^description: \S') "$($f.Name): has a description"
        Assert-True ($t -match '(?m)^schedule: \S') "$($f.Name): has a schedule to print"
        Assert-True ($t -match '(?m)^cron: (\S+ ){4}\S+$') "$($f.Name): has a five-field cron"
        Assert-True ($t -match '(?m)^folder: \S') "$($f.Name): names its folder"
    }
}
finally {
    foreach ($t in $script:trees) { Remove-Item -LiteralPath $t -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "place-scheduled-tasks: $script:pass passed, $script:fail failed." -ForegroundColor $(if ($script:fail -gt 0) { 'Red' } else { 'Green' })
exit $(if ($script:fail -gt 0) { 1 } else { 0 })
