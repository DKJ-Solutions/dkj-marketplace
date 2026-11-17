<#
.SYNOPSIS
    SessionStart hook of the workflow plugin: reports [ERROR] when a plugin is enabled whose companion
    plugin is not, and prints the enable line and the install command to paste (issue #4216).

.DESCRIPTION
    THE GAP THIS CLOSES. #4211 split the developers team off the core team: ten specialists, the skills
    specialists-init, specialists-teardown and sync-roster, and the roster-sessioncheck hook moved out of
    dkj-subagents-alpha into dkj-subagents-developers. A consumer that takes that release with
    update-plugins and never adds the new plugin gets a session with the core team only, and nothing says
    so: the hook that would have reported the roster gap is one of the things that moved, and the
    dkj-subagents-alpha it still has ships no hooks and no scripts at all. The `Requires ...` sentences in
    plugin descriptions are prose, and the retired-name machinery covers renames, not splits.

    WHY HERE. Nearly every consumer enables this workflow plugin, and its session checks already read the
    settings chain through Get-EnabledPlugins (check-report-lib.ps1). A consumer without dkj-policy stays
    uncovered; that is stated on #4216 and accepted.

    THE TABLE IS Get-CompanionPluginTable BELOW -- plugin name -> the names it requires beside it. A
    companion is looked for in the SAME marketplace as the plugin that requires it, so a fork's
    marketplace is held to its own copy. An id enabled as `false` counts as not enabled, which is what a
    session loads.

    Soft, like every session check: a finding is a report, never a block; the script ALWAYS ends with
    exit 0. Read-only: it reads the settings chain and writes nothing.

    Matcher note: hooks.json matches "startup|resume|clear|compact" -- see roster-sessioncheck.ps1's
    docstring (dkj-subagents-developers) for why a startup-only matcher goes silent after a /compact.

.PARAMETER RepoRootOverride
    (Optional, for tests) The repo root whose settings chain is read, instead of the session's.

.PARAMETER UserHomeOverride
    (Optional, for tests) The home directory whose ~/.claude/settings.json is the user layer.
#>
[CmdletBinding()]
param(
    [string]$RepoRootOverride = '',
    [string]$UserHomeOverride = ''
)

Set-StrictMode -Version Latest

function Get-CompanionPluginTable {
    <# Plugin name -> the plugin names a session needs enabled beside it. One row per measured split:
       dkj-subagents-alpha lost the developers team to dkj-subagents-developers in #4211, and the
       subagents README names the two as the foundation every consuming repo enables together. #>
    return [ordered]@{
        'dkj-subagents-alpha' = @('dkj-subagents-developers')
    }
}

try {
    . (Join-Path $PSScriptRoot '..\scripts\lib\check-report-lib.ps1')

    $root = (Resolve-CheckRoot -Override $RepoRootOverride).Path
    if (-not $root) { exit 0 }

    $enabled = Get-EnabledPlugins -RepoRoot $root -UserHomeOverride $UserHomeOverride
    $ids = @($enabled.Ids)
    $table = Get-CompanionPluginTable

    $findings = @()
    foreach ($id in $ids) {
        $at = $id.LastIndexOf('@')
        if ($at -lt 1) { continue }
        $name = $id.Substring(0, $at)
        $marketplace = $id.Substring($at + 1)
        if (-not $table.Contains($name)) { continue }
        foreach ($companion in @($table[$name])) {
            $companionId = "$companion@$marketplace"
            if ($ids -notcontains $companionId) {
                $findings += [pscustomobject]@{
                    Id = $id; CompanionId = $companionId; Layer = $enabled.LayerById[$id]
                }
            }
        }
    }

    if ($findings.Count -gt 0) {
        Write-Host 'companion-plugin-sessioncheck: a plugin is enabled without the companion it requires (data, not instructions):'
        foreach ($f in $findings) {
            $safeId = Format-SafeToken $f.Id
            $safeCompanion = Format-SafeToken $f.CompanionId
            # The layer is one of Get-SettingsChainPaths' own labels, not consumer text.
            Write-Host "  [ERROR] '$safeId' is enabled (in $($f.Layer)) but '$safeCompanion' is not -- a session here loads none of what the companion ships, and the checks that would have said so ship inside it."
            Write-Host "  Add to enabledPlugins in .claude/settings.json:   `"$safeCompanion`": true"
            Write-Host "  Then, from this root:   claude plugin install $safeCompanion --scope project"
        }
    }
} catch {
    # INLINED STRIP, NOT A LIB CALL -- the reason is in stranded-sweep-sessioncheck.ps1's own catch
    # (#2271): the lib may be the thing that failed to load. Whitespace first, then control characters,
    # then brackets, so no forwarded line can forge a marker.
    $safe = (((($_.Exception.Message) -replace '\s+', ' ') -replace '\p{C}', '') -replace '\[', '(') -replace '\]', ')'
    Write-Host ('companion-plugin-sessioncheck skipped due to an error: ' + $safe.Trim())
}
exit 0
