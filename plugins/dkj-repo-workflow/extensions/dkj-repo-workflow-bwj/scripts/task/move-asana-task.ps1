<#
.SYNOPSIS
    Move Asana tasks on this repo's own board into the section with a given stage code.

.DESCRIPTION
    A raw Invoke-RestMethod with ASANA_PAT is refused by the auto-mode classifier; this script is the
    narrow route instead. It can do exactly one thing -- add a task to a section of the board
    Get-AsanaProjectGid names -- and only a task already on that board (#4282).

    The section is named by its CODE, the text before the leading '.' ('2' for '2. In Progress'), and
    resolved by name from the board at run time, so a rebuilt section never leaves a stale GID. The
    resolution is scripts/lib/asana-section-lib.ps1's, the same the CI runners' templates are held equal to.

    Tasks are named by Asana task GID (-TaskGid) or by GitHub issue number (-Issue): for an issue the task
    is the one Resolve-AsanaTaskRef finds in its body, as the CI runners find it.

    Usage, from the root of the store repo:
        move-asana-task.ps1 -Section 2 -Issue 123,124
        move-asana-task.ps1 -Section 2 -TaskGid 1200000000000001
        move-asana-task.ps1 -Section 2 -Issue 123 -DryRun

    Needs ASANA_PAT in the environment (the same secret the asana-* workflows use) and the repo's
    Get-AsanaProjectGid in scripts/repo-config.ps1. Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Section,
    [string[]]$TaskGid = @(),
    [string[]]$Issue = @(),
    [switch]$DryRun,
    [string]$RootOverride = ''
)

$ErrorActionPreference = 'Stop'

# Captured before the repo's own config is dot-sourced below: repo-config.ps1 is the consumer's, and it
# may bind any name it likes.
$SectionArg = $Section; $TaskArg = @($TaskGid); $IssueArg = @($Issue); $DryArg = [bool]$DryRun; $RootArg = $RootOverride

. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\asana-section-lib.ps1')

$root = Resolve-BwjRepoRoot -Override $RootArg

# The board is the repo's own answer. Read in a child scope with StrictMode off: repo-config.ps1 is
# written on the assumption that its callers do not set it.
$projectGid = & {
    Set-StrictMode -Off
    $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return '' }
    . $configPath
    if (-not @($ExecutionContext.InvokeCommand.GetCommands('Get-AsanaProjectGid', 'Function', $false)).Count) { return '' }
    return [string](Get-AsanaProjectGid)
} $root
if (-not $projectGid) { throw 'Get-AsanaProjectGid has no answer in scripts/repo-config.ps1.' }

$taskIds = Split-ListArgument $TaskArg
$issueNums = Split-ListArgument $IssueArg
if (-not $taskIds -and -not $issueNums) { throw 'Name at least one task: -TaskGid or -Issue.' }

$targets = @()
$notes = @()
foreach ($id in $taskIds) {
    if ($id -notmatch '^[0-9]{10,20}$') { throw "Not an Asana task GID: $id" }
    $targets += [pscustomobject]@{ Label = "task $id"; Gid = $id }
}
foreach ($n in $issueNums) {
    if ($n -notmatch '^[0-9]+$') { throw "Not an issue number: $n" }
    $body = Read-AsanaIssueBodyText -Number ([int]$n) -WorkingDirectory $root
    if ($null -eq $body) { throw "gh could not read issue $n." }
    $ref = Get-AsanaIssueTaskGid -IssueBody $body
    if (-not $ref.Gid) { $notes += "[SKIP] #$n carries no single Asana task link ($($ref.Source))"; continue }
    $targets += [pscustomobject]@{ Label = "#$n"; Gid = $ref.Gid }
}
$notes | ForEach-Object { Write-Output $_ }
if (-not $targets) { Write-Output 'Nothing to move.'; return }

Invoke-AsanaTaskMove -Section $SectionArg -Target $targets -ProjectGid $projectGid -Pat $env:ASANA_PAT -DryRun:$DryArg |
    ForEach-Object { Write-Output $_ }
