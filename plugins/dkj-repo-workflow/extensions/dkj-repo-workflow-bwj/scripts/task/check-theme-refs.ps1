<#
.SYNOPSIS
    Check that a Shopify theme's section references hold: no template calling a section that does not
    exist, and a list of sections nothing calls. One script for both BWJ stores.

.DESCRIPTION
    Run it in a store checkout (the root is found from the current directory, or given with -Path):

        powershell -NoProfile -ExecutionPolicy Bypass -File <plugin>\scripts\task\check-theme-refs.ps1

    A store reaches it through its own forwarder, which resolves the plugin script with
    Resolve-PluginScript (scripts/lib/plugin-payload-lib.ps1) and never through a hard-coded plugin path.

    The logic is in scripts\lib\theme-refs-rules.ps1, which also says WHY the check exists and what each
    category (A to E) means; this file is the report and the exit code around it.

    Read-only and fully offline. Exit 1 on an error (A missing section or group, D unparseable file,
    E raw control character), 0 on warnings only; -WarningsAsErrors lets the warnings (B, C) set the exit
    code too.

    THE ONE OPTIONAL SEAM, in the store's scripts/repo-config.ps1:

        Get-ThemeRefsAllowedMissing   a hashtable of section type -> the reason it is accepted, for
                                      findings the owner has decided to carry. An accepted finding stays
                                      in the output as [KNOWN] with its reason -- visible debt, never a
                                      way to hide one -- and does not set the exit code. Leave the
                                      function out and nothing is accepted. Add nothing because the gate
                                      is red; add it because the decision belongs to somebody, and write
                                      the reason and the owner into the value.

.PARAMETER Path
    The theme root to check. Default: the repo root found from the current directory.

.PARAMETER WarningsAsErrors
    Let categories B and C set the exit code too.

.PARAMETER Quiet
    Print only the summary line and the verdict, not every finding.

.PARAMETER AllowMissing
    Section types to treat as known-and-accepted for this run only, on top of the seam's answer.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/check-theme-refs.ps1 -WarningsAsErrors

    Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    [string]$Path,
    [switch]$WarningsAsErrors,
    [switch]$Quiet,
    [string[]]$AllowMissing = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\lib\repo-root-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\theme-refs-rules.ps1')

$Root = Resolve-BwjRepoRoot -Override $Path

# --- The store's optional allowlist ------------------------------------------------------------------
# Read in a child scope with StrictMode OFF, because repo-config.ps1 is written on the assumption that
# its callers do not set it. A repo with no repo-config.ps1 simply accepts nothing: the seam is optional.
$accepted = & {
    Set-StrictMode -Off
    $table = @{}
    $configPath = Join-Path $args[0] 'scripts\repo-config.ps1'
    if (Test-Path -LiteralPath $configPath -PathType Leaf) {
        . $configPath
        # Not Get-Command (wildcard parse, full PATH scan on a miss); see market-urls.ps1.
        if ([bool](@($ExecutionContext.InvokeCommand.GetCommands('Get-ThemeRefsAllowedMissing', 'Function', $false)).Count)) {
            $answer = Get-ThemeRefsAllowedMissing
            if ($answer) { foreach ($k in $answer.Keys) { $table[[string]$k] = [string]$answer[$k] } }
        }
    }
    return $table
} $Root
foreach ($a in $AllowMissing) {
    if ($a) { $accepted[$a] = 'Accepted ad hoc with -AllowMissing for this run.' }
}

$r = Get-ThemeRefReport -Root $Root

$errors   = 0
$warnings = 0
function Say { param([string]$Text, [string]$Color = '') if (-not $Quiet) { if ($Color) { Write-Host $Text -ForegroundColor $Color } else { Write-Host $Text } } }

Say 'check-theme-refs -- section references in the theme'
Say ("Root: {0}" -f $Root)
Say ("Section files: {0} | called: {1}" -f $r.SectionCount, $r.UsedCount)

# --- A ---------------------------------------------------------------------------------------------------
Say ''
Say '== A. Missing sections and groups (error) =='
$real  = @()
$known = @()
foreach ($k in ($r.Missing.Keys | Sort-Object)) {
    if ($accepted.ContainsKey($k)) { $known += $k } else { $real += $k }
}
$realGroups = @($r.MissingGroups.Keys | Sort-Object)
if ($real.Count -eq 0 -and $realGroups.Count -eq 0) { Say '  No findings.' }
foreach ($k in $real) {
    $errors++
    Say ("  [ERROR] section '{0}' does not exist (no sections/{0}.liquid), but is called by: {1}" -f $k, ($r.Missing[$k] -join ', ')) 'Red'
}
foreach ($g in $realGroups) {
    $errors++
    Say ("  [ERROR] section group '{0}' does not exist (no sections/{0}.json), but is called by: {1}" -f $g, ($r.MissingGroups[$g] -join ', ')) 'Red'
}
foreach ($k in $known) {
    Say ("  [KNOWN] '{0}' -- {1}" -f $k, $accepted[$k]) 'DarkYellow'
    Say ("          called by: {0}" -f ($r.Missing[$k] -join ', ')) 'DarkGray'
}

# --- B ---------------------------------------------------------------------------------------------------
Say ''
Say '== B. Sections nothing calls (warning) =='
$withPresets    = @($r.Orphans | Where-Object { $_.HasPresets })
$withoutPresets = @($r.Orphans | Where-Object { -not $_.HasPresets })
if ($withoutPresets.Count -eq 0 -and $r.UncalledGroups.Count -eq 0) {
    Say '  No findings.'
} else {
    if ($withoutPresets.Count -gt 0) {
        $warnings += $withoutPresets.Count
        Say '  WITHOUT presets and called nowhere -- these need a look:' 'Yellow'
        Say ("    {0}" -f (($withoutPresets | ForEach-Object { $_.Section }) -join ', ')) 'Yellow'
    }
    if ($r.UncalledGroups.Count -gt 0) {
        $warnings += $r.UncalledGroups.Count
        Say '  Section groups no layout or template calls with {% sections %}:' 'Yellow'
        Say ("    {0}" -f ($r.UncalledGroups -join ', ')) 'Yellow'
    }
    Say '  (not a delete list: a theme deployed from another branch may still call them)'
}
if ($withPresets.Count -gt 0) {
    Say ("  For information -- {0} section(s) with presets are on no template but can be added in the theme" -f $withPresets.Count) 'DarkGray'
    Say '  editor; that is normal and not a finding:' 'DarkGray'
    Say ("    {0}" -f (($withPresets | ForEach-Object { $_.Section }) -join ', ')) 'DarkGray'
}

# --- C ---------------------------------------------------------------------------------------------------
Say ''
Say '== C. Invalid JSON: trailing comma (warning) =='
if ($r.TrailingCommas.Count -eq 0) { Say '  No findings.' } else {
    $warnings += $r.TrailingCommas.Count
    Say ("  {0} file(s) have a comma directly before a closing brace or bracket. Shopify swallows it, strict" -f $r.TrailingCommas.Count) 'Yellow'
    Say '  JSON parsers do not; it happens when a section is commented out in the editor:' 'Yellow'
    foreach ($f in $r.TrailingCommas) { Say ("    {0}" -f $f) 'Yellow' }
}

# --- D ---------------------------------------------------------------------------------------------------
Say ''
Say '== D. Files that cannot be parsed at all (error) =='
if ($r.Unparseable.Count -eq 0) { Say '  No findings.' } else {
    $errors += $r.Unparseable.Count
    foreach ($f in $r.Unparseable) { Say ("  [ERROR] {0}" -f $f) 'Red' }
    Say '  (comments and trailing commas are already tolerated; this is something else, and the references' 'DarkGray'
    Say '  in such a file are NOT checked)' 'DarkGray'
}

# --- E ---------------------------------------------------------------------------------------------------
Say ''
Say '== E. Raw control character inside a JSON string (error) =='
if ($r.ControlChars.Count -eq 0) { Say '  No findings.' } else {
    $errors += $r.ControlChars.Count
    Say ("  {0} finding(s). Shopify refuses such a file as 'Invalid JSON'; a real newline or tab belongs" -f $r.ControlChars.Count) 'Red'
    Say '  escaped inside a string. Both theme check and ConvertFrom-Json let it through.' 'Red'
    foreach ($v in $r.ControlChars) { Say ("    [ERROR] {0} line {1}: {2}" -f $v.File, $v.Line, $v.Char) 'Red' }
}

Say ''
Write-Host ("Summary: {0} error(s), {1} warning(s)." -f $errors, $warnings)
if ($errors -gt 0) { Write-Host 'FAIL: the theme has broken references or unreadable files.' -ForegroundColor Red; exit 1 }
if ($WarningsAsErrors -and $warnings -gt 0) { Write-Host 'FAIL: warnings found, and -WarningsAsErrors is set.' -ForegroundColor Red; exit 1 }
Write-Host 'PASS: every section reference resolves.' -ForegroundColor Green
exit 0
