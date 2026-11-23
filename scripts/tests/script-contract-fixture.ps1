<#
.SYNOPSIS
    Shared setup, assert helpers and fixture builder for the two script-contract suites -- the
    regression tests for check-script-contract.ps1 (issue #147) and its SessionStart hook.

.DESCRIPTION
    NOT NAMED *.tests.ps1 ON PURPOSE: the test gate globs that pattern, and this file asserts nothing.
    It is dot-sourced by the two suites that do:

      script-contract.tests.ps1         sections 1 to 12h -- the check, the contract-completeness
                                        drift guard, reachability, and the session hook
      script-contract-tables.tests.ps1  sections 14 and 15 -- the branch-prefix table and the
                                        triage-label set, each held to the source's blueprint

    WHY IT IS MORE THAN ONE FILE (#4430, November 23, 2026). The gate parallelises per FILE, and the
    single file measured 429s in CI (measure-suites over PR runs 45154073407, 45156109457 and
    45152244349) against an ideal shard of ~458s over 20 lanes -- about a whole lane on its own, so it
    pinned whichever lane it landed in. Cut at the section boundary that balances measured time:
    standalone on one workstation the single file took 187s, and the two parts take about 106s and 81s
    of it. Sections 14 and 15 read nothing the sections before them create, checked for every variable
    before the cut, so neither part depends on the order the gate runs them in.

    NOTHING WAS REMOVED TO BUY THE TIME. The two suites carry the same sections, and their asserts sum
    to the 516 the single file reported, verified by running them.

    EACH SUITE BUILDS ITS OWN FIXTURES under a per-process directory ($PID plus a GUID in $Fixture), so
    the two can run concurrently under the gate.

    Pure ASCII (repo convention for .ps1).
#>$ErrorActionPreference = 'Stop'

$RepoRoot      = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
# THE PLUGIN COPY, SINCE #3886: the branch-table comparison reads the blueprint that ships beside it, and the
# scripts\sync copy has none next to it, so it would add one "not compared" [INFO] to every scenario below.
# The two copies are byte-identical (check 8), so nothing else about the scenarios changes.
$Script        = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\scripts\sync\check-script-contract.ps1'
# The registry moved out of the check on August 8, 2026 (#456), once a third reader appeared -- the
# blueprint generator. The scenarios below still run the real CHECK; the asserts about how records are
# DECLARED read the lib, which is where they are now.
$ContractLib   = Join-Path $RepoRoot 'scripts\lib\script-contract-lib.ps1'
$Hook          = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\hooks\script-contract-sessioncheck.ps1'
$BranchInfoSrc = Join-Path $RepoRoot 'scripts\lib\branch-info.ps1'
$RepoConfigSrc = Join-Path $RepoRoot 'scripts\repo-config.ps1'
$Fixture       = Join-Path ([System.IO.Path]::GetTempPath()) "script-contract-test-fixture-$PID-$([guid]::NewGuid().ToString('n'))"

$script:pass = 0
$script:fail = 0

function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red
    }
}

function Assert-Match {
    param([string]$Pattern, [string]$Text, [string]$Name)
    if ($Text -match $Pattern) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name`n         pattern not found: '$Pattern'" -ForegroundColor Red
    }
}

function Assert-NotMatch {
    param([string]$Pattern, [string]$Text, [string]$Name)
    if ($Text -notmatch $Pattern) {
        $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green
    } else {
        $script:fail++; Write-Host "  [FAIL] $Name`n         pattern present but should not be: '$Pattern'" -ForegroundColor Red
    }
}

function Invoke-Ps {
    param([string[]]$ScriptArgs)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @ScriptArgs
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

function Invoke-Hook {
    param([string[]]$HookArgs)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook @HookArgs
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

# Removes one PowerShell function definition ('function <Name> { ... }') from $Content, by counting
# braces from the first '{' after the 'function <Name>' token until the matching close -- a plain
# regex cannot reliably find the RIGHT closing brace once the body itself contains nested braces
# (both branch-info.ps1's and repo-config.ps1's functions do, e.g. an inline hashtable literal), so
# this walks the text char-by-char instead. Throws (a fixture-builder bug, not a product bug) if the
# function name is not found, so a typo in a test scenario fails loudly instead of silently keeping
# the "positive" content.
function Remove-PsFunction {
    param([Parameter(Mandatory = $true)][string]$Content, [Parameter(Mandatory = $true)][string]$FunctionName)
    $m = [regex]::Match($Content, "function\s+$([regex]::Escape($FunctionName))\b")
    if (-not $m.Success) {
        throw "Remove-PsFunction: '$FunctionName' not found in the given content -- fixture-builder bug."
    }
    $braceIdx = $Content.IndexOf('{', $m.Index)
    if ($braceIdx -lt 0) {
        throw "Remove-PsFunction: no opening brace found after 'function $FunctionName'."
    }
    $depth = 0
    $i = $braceIdx
    for (; $i -lt $Content.Length; $i++) {
        if ($Content[$i] -eq '{') { $depth++ }
        elseif ($Content[$i] -eq '}') { $depth--; if ($depth -eq 0) { break } }
    }
    if ($i -ge $Content.Length) {
        throw "Remove-PsFunction: no matching closing brace found for '$FunctionName'."
    }
    return $Content.Substring(0, $m.Index) + $Content.Substring($i + 1)
}

$script:RealBranchInfo = [System.IO.File]::ReadAllText($BranchInfoSrc)
$script:RealRepoConfig = [System.IO.File]::ReadAllText($RepoConfigSrc)

# Builds a fixture consumer repo-root with scripts/lib/branch-info.ps1 and/or scripts/repo-config.ps1.
# By default both are the REAL, unmodified content (the positive case). -StripFromBranchInfo /
# -StripFromRepoConfig surgically remove named functions (the negative cases). -OmitBranchInfo /
# -OmitRepoConfig skip writing the file entirely (the "missing lib" cases). -BranchInfoContentOverride
# replaces the whole branch-info.ps1 content outright (the "lib throws on load" case).
function New-FixtureConsumer {
    param(
        [switch]$OmitBranchInfo,
        [switch]$OmitRepoConfig,
        [switch]$OmitWorkflowFolder,
        [string[]]$StripFromBranchInfo = @(),
        [string[]]$StripFromRepoConfig = @(),
        [string]$BranchInfoContentOverride,
        [string]$RepoConfigContentOverride,
        # Repo-relative files to create, for the adoption inventory (issue #2236). Empty by default, so
        # every scenario above keeps testing the record it is about: the adoption section reports three
        # [UNADOPTED] lines against a fixture that has none of them, which is the ordinary state of a
        # throwaway consumer and is asserted deliberately in 12a rather than leaking in as noise.
        [string[]]$PlaceAdoptionFiles = @()
    )
    $root = Join-Path $Fixture 'consumer'
    if (Test-Path -LiteralPath $root) { Remove-Item -Recurse -Force -LiteralPath $root }
    New-Item -ItemType Directory -Path (Join-Path $root 'scripts\lib') -Force | Out-Null
    # The workflow's own root folder (August 14, 2026): present by default so every scenario below keeps
    # testing the record it is about -- the check reports the folder missing as its own [ERROR], which
    # would otherwise leak into every fixture. -OmitWorkflowFolder is the dedicated negative case.
    if (-not $OmitWorkflowFolder) {
        New-Item -ItemType Directory -Path (Join-Path $root '.dkj/dkj-repo-workflow') -Force | Out-Null
    }

    # Empty files: the adoption inventory answers on PRESENCE only, exactly as the workflow-folder line
    # above does, and for the same stated reason -- the contents of a scaffolded runner differ
    # legitimately per repo, so anything finer would need the per-repo exemption list this repo declines.
    foreach ($rel in $PlaceAdoptionFiles) {
        $abs = Join-Path $root ($rel -replace '/', '\')
        $dir = Split-Path -Parent $abs
        if (-not (Test-Path -LiteralPath $dir -PathType Container)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        [System.IO.File]::WriteAllText($abs, '')
    }

    if (-not $OmitBranchInfo) {
        $content = if ($PSBoundParameters.ContainsKey('BranchInfoContentOverride')) { $BranchInfoContentOverride } else { $script:RealBranchInfo }
        foreach ($fn in $StripFromBranchInfo) { $content = Remove-PsFunction -Content $content -FunctionName $fn }
        [System.IO.File]::WriteAllText((Join-Path $root 'scripts\lib\branch-info.ps1'), $content)
    }
    if (-not $OmitRepoConfig) {
        $content = if ($PSBoundParameters.ContainsKey('RepoConfigContentOverride')) { $RepoConfigContentOverride } else { $script:RealRepoConfig }
        foreach ($fn in $StripFromRepoConfig) { $content = Remove-PsFunction -Content $content -FunctionName $fn }
        [System.IO.File]::WriteAllText((Join-Path $root 'scripts\repo-config.ps1'), $content)
    }
    return $root
}
