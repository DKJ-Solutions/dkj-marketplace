<#
.SYNOPSIS
    Summarise a live-drift sync in readable form: what colleagues changed directly in the Shopify admin.

.DESCRIPTION
    The live theme is edited by third parties in the theme editor. Those edits reach git as sync
    commits (the commit subjects Get-ShopifySyncReferencePattern recognises) or, where the live theme
    is connected to a branch of its own (Get-ShopifyLiveDeployBranch), as bot commits on that branch
    that flow back into the trunk. Either way those commits are the audit trail. The catch: such a
    commit is often thousands of lines and nobody reads that, so it feels as if there is no view of
    what happens in the admin, while it is simply in git.

    This script makes that commit readable: per theme area what was added, changed and removed, and
    then an explanation block with the things that really matter:

      - Removed sections that a template still points at. The failure is a section removed live while
        a template keeps naming it: the page returns HTTP 200 and renders nothing, and nothing errors.
      - New sections -- new work from a colleague that nobody requested through the repo.
      - Changes to `config/settings_data.json` -- theme editor settings.
      - Removed templates -- a page layout is gone.

    Read-only: this script reads git and touches nothing. No network, no Shopify API.

    The store's facts come from the seams in its scripts/repo-config.ps1, read the way the plugin's
    other scripts read them, each with a default when unanswered: Get-ShopifySyncReferencePattern (what
    a sync commit's subject looks like), Get-TrunkBranchName and Get-ShopifyLiveDeployBranch (only for
    -SinceTrunk).

    Moved here from a store repo (#4289), beside sync-main.

    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.

.PARAMETER Commit
    The sync commit to summarise. Default: the most recent sync commit on the current branch.

.PARAMETER Range
    Summarise a RANGE instead of one commit: '<base>...<head>', for example 'origin/main...origin/live'.
    That is the shape of the live-to-trunk back-flow: where the live theme hangs on a branch, third-party
    edits arrive as separate bot commits on it, and a back-flow PR often carries dozens. What counts is
    what the head has and the base does not since they split -- exactly what the three dots of git diff
    give. The checks below read the state at the HEAD of the range.

.PARAMETER SinceTrunk
    Shorthand for -Range 'origin/<trunk>...origin/<deploy branch>', built from the store's own
    Get-TrunkBranchName and Get-ShopifyLiveDeployBranch answers. Refuses, naming the seam, when the
    deploy branch is unanswered. It does not fetch: refresh the refs first if they may be stale.

.PARAMETER List
    Show the recent sync commits instead of summarising one.

.PARAMETER Count
    How many commits -List shows. Default 15.

.PARAMETER MaxFiles
    The maximum number of file names listed per area. Default 12.

.PARAMETER RootOverride
    A fixture repo root; a consumer never types it.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/sync-summary.ps1

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/sync-summary.ps1 -List

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/sync-summary.ps1 -Commit 19d6034

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/sync-summary.ps1 -Range origin/main...origin/live
#>
[CmdletBinding()]
param(
    [string]$Commit,
    [string]$Range,
    [switch]$SinceTrunk,
    [switch]$List,
    [int]$Count = 15,
    [int]$MaxFiles = 12,
    [string]$RootOverride = ''
)
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\command-probe-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\sync-rules.ps1')
. (Join-Path $PSScriptRoot '..\lib\git-porcelain-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\live-push-rules.ps1')
. (Join-Path $PSScriptRoot '..\lib\sync-summary-rules.ps1')

function Stop-Refused {
    param([string]$Message)
    Write-Host "REFUSED: $(Format-SafeProseToken -Value $Message)" -ForegroundColor Red
    exit 1
}

$repoRoot = Resolve-RepoRootOrFail -Override $RootOverride -ScriptName 'sync-summary.ps1' -OverrideName '-RootOverride'
$repoRoot = ([string]$repoRoot).Trim() -replace '/', '\'

# The seam is read in a child scope with StrictMode off and inside a try, as this plugin's other scripts
# read repo-config.ps1: the file belongs to the consumer, so a fault in it must degrade to defaults
# rather than take this script down.
$seam = & {
    Set-StrictMode -Off
    $answers = @{ Pattern = ''; Trunk = ''; DeployBranch = '' }
    $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) { return $answers }
    try { . $configPath } catch { return $answers }
    try {
        if (Test-FunctionDefined 'Get-ShopifySyncReferencePattern') { $answers.Pattern = [string](Get-ShopifySyncReferencePattern) }
        if (Test-FunctionDefined 'Get-TrunkBranchName') { $answers.Trunk = [string](Get-TrunkBranchName) }
        if (Test-FunctionDefined 'Get-ShopifyLiveDeployBranch') { $answers.DeployBranch = [string](Get-ShopifyLiveDeployBranch) }
    } catch { }
    return $answers
} $repoRoot

# The same default sync-main uses, so one repo has one notion of "a sync commit". An answer that is not a
# valid regex falls back to it rather than failing the read.
$syncPattern = if (Test-SyncSummaryPatternValid $seam.Pattern) { $seam.Pattern } else { Get-SyncDefaultReferencePattern }
$trunk = if ($seam.Trunk) { $seam.Trunk } else { 'main' }

# A LOCAL QUERY, so Invoke-SyncGitQuiet (as sync-main uses it for its own local queries) and not the
# bounded native-capture lib, which exists for calls that leave the machine. Paths are asked for as
# ASCII-quoted (core.quotePath=true) and decoded by Convert-GitQuotedPath, so the console code page
# cannot corrupt them.
function Invoke-SummaryGit {
    param([string[]]$GitArgs)
    $full = @('-C', $repoRoot, '-c', 'core.quotePath=true') + $GitArgs
    Invoke-SyncGitQuiet @full
}

function Get-SyncCommits {
    param([int]$Limit = 60)
    $raw = Invoke-SummaryGit @('log', "-$Limit", '--format=%H%x1f%h%x1f%ad%x1f%an%x1f%s', '--date=short')
    return @(ConvertFrom-SyncSummaryLog -Lines @($raw) -Pattern $syncPattern)
}

# ---------------------------------------------------------------------------------------------
if ($List) {
    $all = @(Get-SyncCommits -Limit 400)
    Write-Host 'Recent live-drift syncs (newest first):' -ForegroundColor Cyan
    if ($all.Count -eq 0) { Write-Host '  none found'; exit 0 }
    foreach ($c in ($all | Select-Object -First $Count)) {
        Write-Host ("  {0}  {1}  {2}" -f $c.Short, $c.Date, $c.Subject)
    }
    Write-Host ''
    Write-Host 'Summarise one with: sync-summary.ps1 -Commit <hash>'
    exit 0
}

if ($SinceTrunk) {
    if ($Range -or $Commit) { Stop-Refused '-SinceTrunk cannot be combined with -Range or -Commit.' }
    $built = Get-SyncSummaryDeployRange -Trunk $trunk -DeployBranch $seam.DeployBranch
    if (-not $built.Ok) { Stop-Refused $built.Reason }
    $Range = $built.Range
}

if ($Range) {
    # The back-flow shape. $grepRef is the state the checks below look in: for a range the HEAD, because
    # that is what the trunk carries after the merge.
    if ($Commit) { Stop-Refused 'Give -Commit OR -Range, not both.' }
    $parts = ConvertFrom-SyncSummaryRange -Range $Range
    if (-not $parts) { Stop-Refused "-Range expects '<base>...<head>' (three dots), for example 'origin/main...origin/live'." }
    $rangeBase = $parts.Base
    $rangeHead = $parts.Head
    foreach ($ref in @($rangeBase, $rangeHead)) {
        if (-not (Invoke-SummaryGit @('rev-parse', '--verify', '-q', "$ref^{commit}"))) { Stop-Refused "Ref '$ref' not found." }
    }
    $ahead = @(Invoke-SummaryGit @('rev-list', '--count', "$rangeBase..$rangeHead")) | Select-Object -First 1

    Write-Host ''
    Write-Host ("=== Live back-flow {0} ===" -f $Range) -ForegroundColor Cyan
    Write-Host ("    {0} commit(s) on {1} that {2} does not have yet" -f $ahead, $rangeHead, $rangeBase)
    Write-Host '    (the edits come from third parties in the editors; a bot commit names the last admin editor, not necessarily whoever saved)' -ForegroundColor DarkGray

    $nameArgs = @('diff', '--name-status', '-M', $Range, '--')
    $namestatus = Invoke-SummaryGit $nameArgs
    $grepRef    = $rangeHead
    $fullDiff   = "git diff $Range"
}
else {
    if (-not $Commit) {
        $found = @(Get-SyncCommits -Limit 400)
        if ($found.Count -eq 0) {
            Write-Host 'No sync commit found on this branch.' -ForegroundColor Yellow
            Write-Host 'Use -Commit <hash> for a specific commit, -Range for a range, or -List to search.'
            exit 0
        }
        $Commit = $found[0].Sha
    }
    # A revision that reads as an option, or carries whitespace, is not handed to git at all.
    if (-not (Test-SyncSummaryCommitArg $Commit)) { Stop-Refused "-Commit '$Commit' is not a plain revision." }
    if (-not (Invoke-SummaryGit @('rev-parse', '--verify', '-q', "$Commit^{commit}"))) { Stop-Refused "Commit '$Commit' not found." }

    $fs = Get-SyncSummaryFieldSeparator
    $metaArgs = @('show', '-s', '--format=%h%x1f%ad%x1f%an%x1f%s', '--date=short', $Commit, '--')
    $meta = Invoke-SummaryGit $metaArgs
    $m = ([string]($meta | Select-Object -First 1)) -split [regex]::Escape($fs)

    Write-Host ''
    Write-Host ("=== Live-drift sync {0} ({1}) ===" -f $m[0], $m[1]) -ForegroundColor Cyan
    Write-Host ("    {0}" -f $m[3])
    Write-Host ("    committed by: {0}   (the admin edits themselves come from third parties in the theme editor)" -f $m[2]) -ForegroundColor DarkGray

    $nameArgs = @('show', '--name-status', '--format=', '-M', $Commit, '--')
    $namestatus = Invoke-SummaryGit $nameArgs
    $grepRef    = $Commit
    $fullDiff   = "git show $($m[0])"
}

# --- Files per status -------------------------------------------------------------------------
$files = @(ConvertFrom-SyncSummaryNameStatus -Lines @($namestatus))

if ($files.Count -eq 0) {
    Write-Host ''
    if ($Range) {
        Write-Host 'This range touches no files: there is nothing to flow back.' -ForegroundColor Yellow
    } else {
        Write-Host 'This commit touches no files (possibly a merge commit; name the child commit).' -ForegroundColor Yellow
    }
    exit 0
}

Write-Host ''
Write-Host ("--- What was touched ({0} files) ---" -f $files.Count)
$seen = @{}
foreach ($area in (Get-SyncSummaryAreas)) {
    $inArea = @($files | Where-Object { (Get-SyncSummaryAreaOf $_.Path) -eq $area.Key })
    if ($inArea.Count -eq 0) { continue }
    foreach ($f in $inArea) { $seen[$f.Path] = $true }
    Write-Host ''
    Write-Host ("  {0}" -f $area.Label) -ForegroundColor White
    foreach ($s in @('A', 'D', 'M', 'R')) {
        $set = @($inArea | Where-Object { $_.Status -eq $s })
        if ($set.Count -eq 0) { continue }
        $color = switch ($s) { 'A' { 'Green' } 'D' { 'Red' } default { 'Gray' } }
        Write-Host ("    {0,-8} {1,3}: " -f (Get-SyncSummaryStatusLabel $s), $set.Count) -NoNewline -ForegroundColor $color
        $names = @($set | ForEach-Object { Split-Path -Leaf $_.Path })
        Write-Host (Format-SyncSummaryNames -Names $names -Max $MaxFiles) -ForegroundColor $color
    }
}
$other = @($files | Where-Object { -not $seen.ContainsKey($_.Path) })
if ($other.Count) {
    Write-Host ''
    Write-Host ("  Other ({0})" -f $other.Count) -ForegroundColor DarkGray
    Write-Host ("    {0}" -f ((@($other | ForEach-Object { $_.Path }) | Select-Object -First $MaxFiles) -join ', ')) -ForegroundColor DarkGray
}

# --- Explanation: the things that really matter ------------------------------------------------
Write-Host ''
Write-Host '--- What to look at ---' -ForegroundColor Cyan

# Does anything in templates/ still point at this section, in the state AFTER the sync?
#
# Search on the section name BETWEEN QUOTES, not on the full `"type": "<name>"`. Two reasons, both
# learned the hard way: a -F pattern holding both quotes and a space does not survive the argv hand-off
# to the native exe, and `git grep -E` uses POSIX regex and has no `\s` -- both variants silently
# returned 0 hits and so the conclusion "clean removal" while a template did still point at it. Inside
# templates/ an exactly quoted section name only occurs as a type/handle reference, so it is precise
# enough. The pathspec is passed by splatting an array, never as an inline '--' (see sync-rules.ps1).
$lookup = {
    param([string]$SectionName)
    $grepArgs = @('grep', '-l', '-F', ('"' + $SectionName + '"'), $grepRef, '--', 'templates')
    $hits = @(Invoke-SummaryGit $grepArgs | Where-Object { $_ })
    return @($hits | ForEach-Object {
        Convert-GitQuotedPath ($_ -replace ('^' + [regex]::Escape($grepRef) + ':'), '')
    })
}
$findings = @(Get-SyncSummaryFindings -Files $files -ReferenceLookup $lookup -MaxFiles $MaxFiles)

$marker = @{ 'alert' = '[!]'; 'info' = '[i]'; 'new' = '[+]'; 'notice' = '[~]' }
$color  = @{ 'alert' = 'Red'; 'info' = 'DarkGray'; 'new' = 'Green'; 'notice' = 'Yellow' }
$count = 0
foreach ($f in $findings) {
    if ($f.Level -ne 'info') { $count++ }
    Write-Host ("  {0} {1}" -f $marker[$f.Level], $f.Message) -ForegroundColor $color[$f.Level]
    foreach ($d in @($f.Detail)) {
        $detailColor = if ($f.Kind -eq 'removed-section-referenced' -and $d -notmatch '^Such a page') { 'Red' }
                       elseif ($f.Level -eq 'new') { 'Green' } else { 'DarkGray' }
        Write-Host ("      {0}" -f $d) -ForegroundColor $detailColor
    }
}
if ($count -eq 0) {
    Write-Host '  Nothing special: no removed or new sections that matter, no templates gone, no editor settings.'
}

Write-Host ''
Write-Host ("Full diff: {0}" -f $fullDiff) -ForegroundColor DarkGray
exit 0
