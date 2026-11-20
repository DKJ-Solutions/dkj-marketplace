<#
.SYNOPSIS
    Switches Claude Code's auto memory off for this repo: adds "autoMemoryEnabled": false to
    .claude/settings.json -- issue #4341. Part 6 of 'adopt-dkj-repo-workflow'.

.DESCRIPTION
    WHY. The constitution keeps lessons in the docs and never in memory (Maikel, November 20, 2026,
    #4341). Claude Code's auto memory is ON by default and writes ~/.claude/projects/<project>/memory/
    whatever the rule says -- on one machine, under one account, where nobody else on the team ever sees
    it. Measured the day the rule was made: one consumer checkout held 12 notes, among them a filing rule
    the owner had decided two weeks earlier, which never reached the shared docs, so a colleague's
    sessions on another machine kept breaking it. The rule alone does not stop the harness; the setting
    does.

    WHY THE PROJECT FILE. .claude/settings.json is committed, so the switch reaches every checkout and
    every person on the team. A user-level setting or CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 switches it off
    for one machine only, which is the very property that made the notes a problem.

    STRICTLY ADDITIVE. The key is INSERTED as text through settings-member-lib (every other byte stays,
    #2505) and parsed back before it is written. An existing autoMemoryEnabled is never replaced: where it
    already reads false there is nothing to do, and where it reads anything else this run says so and
    leaves the edit to a person -- a value somebody wrote is theirs to change.

    NOT REFUSED IN THE REPO THAT PUBLISHES THIS WORKFLOW. Unlike Parts 1, 3 and 5 there is no local
    original this could collide with; the source carries the key itself and a run there finds it.

    THE NOTES ALREADY WRITTEN are not this command's: the auto-memory session check lists them at every
    session start until each one is filed inbound or moved into the repo's lens and deleted.

.PARAMETER Apply
    Write. Without it this is a DRY RUN that prints exactly what it would change and touches nothing --
    the default every adopt-* part uses.

.PARAMETER RootOverride
    Fixture seam: the repo to operate on. A consumer never types it.

.EXAMPLE
    .\scripts\task\adopt-auto-memory.ps1
    .\scripts\task\adopt-auto-memory.ps1 -Apply
#>

[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$RootOverride = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# The source-repo guard, wired the way every shared entry point wires it: a string literal names the
# lib and Assert-OwnCopy is called. It refuses a released copy run from inside the repo that maintains it.
$guardLib = Join-Path $PSScriptRoot '..\lib\source-repo-guard-lib.ps1'
if (Test-Path -LiteralPath $guardLib -PathType Leaf) { . $guardLib; Assert-OwnCopy -ScriptPath $PSCommandPath }

. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
$repoRoot = Resolve-RepoRootOrFail -Override $RootOverride -ScriptName 'adopt-auto-memory.ps1' -OverrideName '-RootOverride'

. (Join-Path $PSScriptRoot '..\lib\document-newline-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\settings-member-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\write-target-lib.ps1')

$settingsRel = '.claude/settings.json'
$settingsAbs = Join-Path $repoRoot ($settingsRel -replace '/', '\')
$key         = 'autoMemoryEnabled'
$block       = "  `"$key`": false"

# NEVER THROUGH A SYMLINK OR JUNCTION (#2546): a junctioned .claude/ would take the write outside the repo.
$settingsReparse = Get-WriteTargetReparsePoint -Path $settingsAbs -Root $repoRoot

Write-Host ''
Write-Host "== adopt-auto-memory -- $repoRoot ==" -ForegroundColor Cyan
if (-not $Apply) {
    Write-Host 'DRY RUN -- nothing is written. Re-run with -Apply to change it.' -ForegroundColor Yellow
}
Write-Host ''

$settings = Read-SettingsFile -Path $settingsAbs
if (-not $settings.Readable) {
    Write-Host "  [refuse] $settingsRel does not parse as JSON -- nothing was changed." -ForegroundColor Red
    Write-Host '           Repair the file first; this command will not rewrite one it cannot read.'
    Write-Host '           The member to add once it parses:'
    Write-Host ''
    Write-Host $block
    exit 1
}

$names = @(Get-SettingsMemberNames $settings.Parsed)
if ($names -contains $key) {
    $value = $settings.Parsed.$key
    if ($value -is [bool] -and -not $value) {
        Write-Host "  [keep]  $settingsRel already sets $key to false -- nothing to do." -ForegroundColor Green
        exit 0
    }
    $shown = Format-SafePathToken -Value ("$value")
    Write-Host "  [keep]  $settingsRel sets $key to '$shown' -- left exactly as it is." -ForegroundColor Yellow
    Write-Host '          The constitution keeps lessons in the docs and never in memory (#4341), so this'
    Write-Host '          should read false. A value somebody wrote is theirs to change; edit it by hand:'
    Write-Host ''
    Write-Host $block
    exit 0
}

if ($settingsReparse) {
    Write-Host "  [refused] $settingsRel -- reached through a symlink or junction ($(Format-SafePathToken -Value "$settingsReparse")), so it was NOT changed:" -ForegroundColor Yellow
    Write-Host '            writing it would land outside the repo. The member to add by hand:'
    Write-Host ''
    Write-Host $block
    exit 1
}

if (-not $Apply) {
    Write-Host "  [would write] $settingsRel -- $key added:"
    Write-Host ''
    Write-Host $block
    Write-Host ''
    Write-Host '  Commit it: the committed file is what switches auto memory off for everybody on the team.'
    exit 0
}

# A missing or blank file is an empty object, so a new file comes out of the same insert as an existing one.
# This literal is the one place that knows what an empty root looks like; the insert reads its LF off it.
$baseText = $(if ($null -ne $settings.Parsed) { $settings.Text } else { "{`n}`n" })
$newText  = Add-SettingsMember -Text $baseText -MemberLines @("`"$key`": false")

# PARSED BACK BEFORE IT IS WRITTEN: the same keys plus this one, or nothing at all.
$verified = $false
if ($newText) {
    try {
        $parsed = $newText | ConvertFrom-Json
        $after  = @(Get-SettingsMemberNames $parsed)
        $verified = ($parsed.$key -is [bool]) -and (-not $parsed.$key) -and
                    ($after.Count -eq $names.Count + 1) -and
                    (@($names | Where-Object { $after -notcontains $_ }).Count -eq 0)
    } catch { $verified = $false }
}
if (-not $verified) {
    Write-Host "  [refuse] $settingsRel -- the insert could not be verified, so nothing was changed." -ForegroundColor Red
    Write-Host '           Add the member by hand:'
    Write-Host ''
    Write-Host $block
    exit 1
}

$settingsDir = Split-Path -Parent $settingsAbs
if (-not (Test-Path -LiteralPath $settingsDir -PathType Container)) {
    New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
}
[System.IO.File]::WriteAllText($settingsAbs, $newText, (New-Object System.Text.UTF8Encoding($settings.HadBom)))
Write-Host "  [write] $settingsRel -- $key set to false, the rest of the file untouched" -ForegroundColor Green
Write-Host ''
Write-Host '  Commit it: the committed file is what switches auto memory off for everybody on the team.'
Write-Host '  Notes written before today are listed by the auto-memory session check until each is moved.'
exit 0
