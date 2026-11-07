<#
.SYNOPSIS
    File a goal's breakdown as GitHub issues and sub-issues, or say what to do next on one (#3816). The documented
    entry point is this plugin's plan-goal skill (skills/plan-goal/SKILL.md).

.DESCRIPTION
    A goal is an open issue labelled `goal`; its milestones are its sub-issues, and their tasks are theirs. Admin's
    /dev/goals page reads the same issues, so whatever this files is on that page at its next read.

      -Next [-Goal <n>]        print Now and Next for every open goal, or for goal #n only. Writes nothing.
      -PlanFile <path>         read a breakdown (the JSON ConvertTo-GoalPlan describes), validate it and print it
                               as a tree. Writes nothing.
      -PlanFile <path> -Apply  file it: the goal (unless the plan names an existing one), each milestone as a
                               sub-issue of the goal, each task as a sub-issue of its milestone, in plan order.
                               Creates the `goal` label first where the repo has none.
      -Repo <owner/name>       the repo; else the one `gh repo view` finds from the working directory.

    Every issue is created through `gh api --input <file>`, so a title with quotes in it never passes through a
    command line. A failure part-way stops the run and prints what was filed, so the plan can be rerun with those
    numbers in it instead of filing them twice. Exits 0 on success, 1 on a refusal or a failure.

    Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [switch]$Next,
    [int]$Goal = 0,
    [string]$PlanFile = '',
    [switch]$Apply,
    [string]$Repo = ''
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\lib\goals-lib.ps1')
. (Join-Path $PSScriptRoot '..\..\..\scripts\lib\ref-print-lib.ps1')

function Stop-PlanGoal {
    param([string]$Message)
    Write-Host "[REFUSED] $Message"
    exit 1
}

if (-not (Get-Command gh -CommandType Application -ErrorAction SilentlyContinue)) { Stop-PlanGoal 'gh was not found on the PATH.' }
if (-not $Next -and -not $PlanFile) { Stop-PlanGoal 'name -Next, or a -PlanFile to check (and -Apply to file it).' }

if (-not $Repo) {
    # Under 'Stop' a native stderr line throws through 2>$null in Windows PowerShell 5.1, so the read is
    # wrapped: no answer is the same as no repo, and the refusal below names it.
    try { $Repo = [string](gh repo view --json nameWithOwner --jq .nameWithOwner 2>$null) } catch { $Repo = '' }
    $Repo = $Repo.Trim()
}
if ($Repo -notmatch '\A([^/\s]+)/([^/\s]+)\z') { Stop-PlanGoal 'no GitHub repo: pass -Repo owner/name, or run this in a checkout whose origin is on GitHub.' }
$owner = $Matches[1]; $name = $Matches[2]
$label = Get-GoalLabel

if ($Next) {
    $raw = gh api graphql -f ('query=' + (Get-GoalsGraphQuery)) -f ('owner=' + $owner) -f ('name=' + $name) -f ('label=' + $label)
    if ($LASTEXITCODE -ne 0) { Stop-PlanGoal "gh api graphql exited $LASTEXITCODE." }
    $goals = @(ConvertFrom-GoalsGraph -Data (($raw -join "`n") | ConvertFrom-Json) | Where-Object { $_ })
    if ($Goal) { $goals = @($goals | Where-Object { $_.Number -eq $Goal }) }
    if (-not $goals.Count) {
        if ($Goal) { Write-Host "[OK] #$Goal is not an open issue labelled '$label' in $Repo." }
        else { Write-Host "[OK] $Repo has no open goal: no open issue is labelled '$label'. Plan one with the plan-goal skill." }
        exit 0
    }
    foreach ($g in $goals) { Write-Host (Format-GoalFocusText -Goal $g); Write-Host '' }
    exit 0
}

if (-not (Test-Path -LiteralPath $PlanFile -PathType Leaf)) { Stop-PlanGoal "the plan file '$PlanFile' does not exist." }
$utf8 = New-Object System.Text.UTF8Encoding($false)
$read = ConvertTo-GoalPlan -Json ([System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $PlanFile).Path, $utf8))
if ($read.Error) { Stop-PlanGoal "the plan does not hold: $($read.Error)." }
$plan = $read.Plan
Write-Host (Format-GoalPlanText -Plan $plan)
if (-not $Apply) {
    Write-Host ''
    Write-Host "[OK] the plan holds. Nothing was filed; rerun with -Apply to file it in $Repo."
    exit 0
}

$tmp = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), 'dkj-plan-goal-' + [guid]::NewGuid().ToString('N') + '.json')
$filed = New-Object System.Collections.Generic.List[string]
function Invoke-GhJson {
    <# gh api with a JSON request body from a file; the parsed answer. Throws on a non-zero exit. #>
    param([string]$Method, [string]$Path, $Body)
    $args2 = @('api', '-X', $Method, $Path)
    if ($null -ne $Body) {
        [System.IO.File]::WriteAllText($tmp, ($Body | ConvertTo-Json -Depth 4 -Compress), $utf8)
        $args2 += @('--input', $tmp)
    }
    $out = & gh @args2
    if ($LASTEXITCODE -ne 0) { throw "gh api $Method $Path exited $LASTEXITCODE" }
    if ($out) { return (($out -join "`n") | ConvertFrom-Json) }
    return $null
}
function New-PlanIssue {
    param([string]$Title, [string]$Body, [string[]]$Labels, [string]$Kind)
    $i = Invoke-GhJson -Method POST -Path "repos/$Repo/issues" -Body @{ title = $Title; body = $Body; labels = @($Labels) }
    $filed.Add("$Kind #$($i.number) $Title")
    Write-Host "  filed $Kind #$($i.number): $Title"
    return $i
}
function Get-PlanIssue {
    param([int]$Number)
    return (Invoke-GhJson -Method GET -Path "repos/$Repo/issues/$Number" -Body $null)
}
function Add-PlanSubIssue {
    param([int]$Parent, $Child)
    [void](Invoke-GhJson -Method POST -Path "repos/$Repo/issues/$Parent/sub_issues" -Body @{ sub_issue_id = [int64]$Child.id })
}

try {
    # The label first: an issue cannot be labelled with one the repo does not have.
    & gh api "repos/$Repo/labels/$label" --silent 2>$null
    if ($LASTEXITCODE -ne 0) {
        [void](Invoke-GhJson -Method POST -Path "repos/$Repo/labels" -Body @{ name = $label; color = '5319e7'; description = 'A goal: its milestones are its sub-issues, and their tasks are theirs' })
        Write-Host "  created the label '$label'"
    }
    $g = if ($plan.Goal.Number) { Get-PlanIssue -Number $plan.Goal.Number } else { New-PlanIssue -Title $plan.Goal.Title -Body $plan.Goal.Body -Labels @($label) -Kind 'goal' }
    if ($plan.Goal.Number -and -not @($g.labels | Where-Object { $_.name -eq $label }).Count) {
        [void](Invoke-GhJson -Method POST -Path "repos/$Repo/issues/$($g.number)/labels" -Body @{ labels = @($label) })
        Write-Host "  labelled #$($g.number) '$label'"
    }
    foreach ($m in @($plan.Milestones)) {
        if ($m.Number) {
            $mi = Get-PlanIssue -Number $m.Number
        } else {
            $mi = New-PlanIssue -Title $m.Title -Body $m.Body -Labels @($plan.Labels) -Kind 'milestone'
            Add-PlanSubIssue -Parent $g.number -Child $mi
        }
        foreach ($t in @($m.Tasks)) {
            $ti = New-PlanIssue -Title $t.Title -Body $t.Body -Labels @($plan.Labels) -Kind 'task'
            Add-PlanSubIssue -Parent $mi.number -Child $ti
        }
    }
} catch {
    Write-Host ''
    Write-Host "[FAILED] $(ConvertTo-ConsoleStrippedText $_.Exception.Message)"
    if ($filed.Count) {
        Write-Host '  Filed before the failure -- put these numbers in the plan before you rerun it, so nothing is filed twice:'
        foreach ($f in $filed) { Write-Host "    $f" }
    } else {
        Write-Host '  Nothing was filed.'
    }
    exit 1
} finally {
    Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
}
Write-Host ''
Write-Host "[OK] filed $($filed.Count) issue(s) under goal #$($g.number) in $Repo. It is on Admin's /dev/goals page at its next read."
exit 0
