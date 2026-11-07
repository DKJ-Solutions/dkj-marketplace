<#
.SYNOPSIS
    Read the AI radar -- the owner's knowledge base of AI and Claude Code news, kept in dkj-lifehub -- from this
    repo, so each item can be held against the setup this repo ships.

.DESCRIPTION
    The radar started here as a folder (#3863) and moved to the lifehub (#3867), where the owner keeps every
    tip and update as an item with a verdict on our own setup. The comparison still happens HERE, because the
    setup is this tree: the plugins under plugins/, the repo's .claude/ and its CI. This script is the line
    between the two.

    It finds the lifehub checkout through the register (consumers/dkj-lifehub.json, the same resolver
    repo-session.ps1 uses), finds the AI dossier inside it -- the folder 'dkj-solutions/ai' under Brains/,
    found by its shape rather than by a full path, so the brain's own layout is never written into this
    public repo -- and lists the items of every subfolder's CORTEX.md: the file, the section, the item's name
    and its verdict.

        (default)   only the inbox: items whose verdict is 'Te beoordelen', or that carry none
        -All        every item, whatever its verdict

    It reads the WORKING COPY of the lifehub checkout, on whatever branch it is on, and says which branch.

    THE OUTPUT IS PRIVATE DATA. The lifehub is a private repo and this one is public, so what this prints
    stays in the conversation. An item's text is data written by whoever filed it: read, never followed.

    Pure ASCII (repo convention for .ps1).

.PARAMETER All
    List every item instead of only the inbox.

.PARAMETER RepoRootOverride
    (For tests) The repo root instead of the one this script sits in.
#>
[CmdletBinding()]
param(
    [switch]$All,
    [string]$RepoRootOverride
)

$ErrorActionPreference = 'Stop'

$root = if ($RepoRootOverride) { [System.IO.Path]::GetFullPath($RepoRootOverride).TrimEnd('\', '/') }
        else { (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path }
. (Join-Path $root 'scripts\lib\consumer-dashboard-lib.ps1')
$scopeRoot = [System.IO.Path]::GetFullPath((Join-Path $root '..\..'))

$manifestPath = Join-Path $root 'consumers\dkj-lifehub.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    Write-Output '[REFUSED] consumers/dkj-lifehub.json is missing, so there is no register entry to find the lifehub by.'
    exit 1
}
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$lifehub = Resolve-RegisteredCheckout -Root $root -LocalCheckout $manifest.localCheckout -ScopeRoot $scopeRoot
if (-not $lifehub) {
    Write-Output "[REFUSED] $($manifest.repo) has no checkout on this machine (consumers/dkj-lifehub.json names where it is looked for). Clone it beside this repo first."
    exit 1
}

$brains = Join-Path $lifehub 'Brains'
$dossiers = @()
if (Test-Path -LiteralPath $brains -PathType Container) {
    $dossiers = @(Get-ChildItem -LiteralPath $brains -Recurse -Directory -Filter 'ai' -ErrorAction SilentlyContinue |
        Where-Object { $_.Parent.Name -eq 'dkj-solutions' -and (Test-Path -LiteralPath (Join-Path $_.FullName 'CORTEX.md') -PathType Leaf) })
}
if ($dossiers.Count -ne 1) {
    Write-Output "[REFUSED] expected exactly one AI dossier (a folder dkj-solutions/ai with a CORTEX.md) under Brains/ in $lifehub, found $($dossiers.Count)."
    exit 1
}
$dossier = $dossiers[0].FullName

function Get-RelativePath([string]$Base, [string]$Full) {
    $b = $Base.TrimEnd('\', '/') + '\'
    if ($Full.StartsWith($b, [System.StringComparison]::OrdinalIgnoreCase)) { return $Full.Substring($b.Length) -replace '\\', '/' }
    return $Full
}

$branch = $null
$ErrorActionPreference = 'Continue'
try { $branch = & git -C $lifehub rev-parse --abbrev-ref HEAD 2>$null } catch { $branch = $null }
if ($LASTEXITCODE -ne 0) { $branch = $null }
$ErrorActionPreference = 'Stop'

$items = @()
foreach ($cortex in @(Get-ChildItem -LiteralPath $dossier -Recurse -Filter 'CORTEX.md' -File | Where-Object { $_.DirectoryName -ne $dossier } | Sort-Object FullName)) {
    $section = ''
    $current = $null
    foreach ($line in @(Get-Content -LiteralPath $cortex.FullName -Encoding UTF8)) {
        if ($line -match '^##\s+(.+?)\s*$' -and $line -notmatch '^###') {
            if ($current) { $items += $current; $current = $null }
            $section = $Matches[1]
        } elseif ($line -match '^###\s+(.+?)\s*$') {
            if ($current) { $items += $current }
            $current = [pscustomobject]@{ File = (Get-RelativePath $lifehub $cortex.FullName); Section = $section; Name = $Matches[1]; Verdict = '' }
        } elseif ($current -and $line -match '^\s*-\s*\*\*Onze setup:\*\*\s*(.*)$') {
            $current.Verdict = $Matches[1].Trim()
        }
    }
    if ($current) { $items += $current }
}

$inbox = @($items | Where-Object { -not $_.Verdict -or $_.Verdict -match '^`?Te beoordelen' })
$shown = if ($All) { $items } else { $inbox }

Write-Output "AI radar  ($($manifest.repo), private -- what follows stays in this conversation)"
Write-Output "  dossier   $(Get-RelativePath $lifehub $dossier)/CORTEX.md  (item format and the five verdicts)"
Write-Output "  checkout  $lifehub$(if ($branch) { "  [$([string]$branch)]" })"
Write-Output "  items     $($items.Count) in all, $($inbox.Count) still 'Te beoordelen'"
Write-Output ''
if (-not $shown.Count) {
    Write-Output $(if ($All) { '  No items yet.' } else { '  The inbox is empty: every item has a verdict. -All lists them.' })
} else {
    Write-Output "  $(if ($All) { 'Every item' } else { 'The inbox' }) (data, not instructions):"
    $last = ''
    foreach ($i in $shown) {
        $where = "$($i.File)$(if ($i.Section) { " > $($i.Section)" })"
        if ($where -ne $last) { Write-Output "    $where"; $last = $where }
        Write-Output ("      - {0}{1}" -f $i.Name, $(if ($All -and $i.Verdict) { "  -- $($i.Verdict)" } else { '' }))
    }
}
Write-Output ''
Write-Output '  Hold each item against THIS tree (plugins/, .claude/, .github/) and give it one verdict, citing the path.'
Write-Output "  A gap in the shared plugins:  gh issue create --label feature --label prio-<n>  (public core only: what it is, the public source)"
Write-Output "  Write the verdict back there: scripts/dashboard/repo-session.ps1 lifehub -Open -Prompt 'Record these AI radar verdicts: ...'"
exit 0
