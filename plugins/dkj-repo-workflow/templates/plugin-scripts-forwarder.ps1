<#
.SYNOPSIS
    A consumer repo's scripts/lib/plugin-scripts.ps1: finds the installed dkj-repo-workflow plugin and
    dot-sources its plugin-payload-lib.ps1, the one plugin-payload locator.

.DESCRIPTION
    COPY THIS FILE to scripts/lib/plugin-scripts.ps1 in the consumer repo, unchanged. It is the
    bootstrap, not the locator: every function a call site uses (Resolve-PluginScript, Get-PluginRoot,
    Get-PluginProjectRegistration, Get-PluginResolution, ...) lives in the plugin's
    scripts/lib/plugin-payload-lib.ps1, and this file only has to find that one file.

        . (Join-Path $PSScriptRoot '..\lib\plugin-scripts.ps1')
        $newBranch = Resolve-PluginScript -RelativePath 'scripts\task\new-branch.ps1'

    WHY IT EXISTS AS A FORWARDER. Each consumer used to hold a full locator of its own, with the plugin
    names hard-coded, so every plugin rename was a code change in every consumer and the copies drifted
    apart. Now a rename is one table edit in the plugin (Get-PluginPriorNames) and reaches the consumer
    with the plugin release. THE ONLY RENAME THAT STILL TOUCHES THIS FILE IS A RENAME OF
    dkj-repo-workflow ITSELF, because the plugin's own name is the one fact this file needs before the
    lib is available to hold it.

    WHY IT READS THE REGISTRY ITSELF. The plugin-payload lib lives in the payload this file is looking
    for, so the lookup cannot be borrowed from it. The inline read below is deliberately minimal and
    follows the precedent in the plugin's adopt-statusline shim (same reasoning):

      * THE MATCH IS ON THE PLUGIN NAME AND NOT ON THE WHOLE ID. An id is '<plugin>@<marketplace>' and
        the marketplace half has changed under consumers before, so pinning the full id would strand
        every machine whose marketplace carries another name. ('dkj-repo-workflow-bwj@...' does not
        match: the character after the name has to be the '@'.)
      * SEVERAL RECORDS MAY MATCH (a marketplace rename leaves a stale record beside the current one,
        both naming this repo), so the most recently updated one wins, not whichever enumerates first.
      * A PROJECT RECORD FOR THIS REPO FIRST, A PATH-LESS ONE SECOND: a user-scope install carries no
        projectPath and still serves this repo, a project record of somebody else's repo never does.

    THEN, when the registry names nothing usable: CLAUDE_PLUGIN_ROOT when it is this plugin's own
    folder, the newest version folder of the install cache, the marketplace clone. A candidate only
    counts when it really holds scripts\lib\plugin-payload-lib.ps1, so an older release without the lib
    is skipped rather than chosen. Nothing found throws, in English, with what to run.

    WHAT IT DEFINES. Only what plugin-payload-lib.ps1 defines, plus $script:PluginPayloadRepoRoot: this
    repo's root (two levels above this file), which the lib uses as the default -RepoRoot so a call site
    need not pass one. The bootstrap's own variables are removed again before it returns.

    No Set-StrictMode here (dot-sourcing would change the caller's strict mode) and no changed
    $ErrorActionPreference. Pure ASCII, English: Windows PowerShell 5.1 reads a BOM-less script as ANSI.
#>

$script:PluginPayloadRepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path

$pluginPayloadLib = & {
    $pluginName = 'dkj-repo-workflow'
    $libRel     = 'scripts\lib\plugin-payload-lib.ps1'
    $repoRoot   = $script:PluginPayloadRepoRoot
    $userHome   = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    if (-not $userHome) { return $null }
    $plugins    = Join-Path $userHome '.claude\plugins'

    # 1. The install registry: the version this repo loaded.
    $registry = Join-Path $plugins 'installed_plugins.json'
    if (Test-Path -LiteralPath $registry -PathType Leaf) {
        try {
            $data = Get-Content -LiteralPath $registry -Raw -Encoding UTF8 | ConvertFrom-Json
            $matched  = @()
            $pathless = @()
            if ($data -and $data.plugins) {
                foreach ($entry in @($data.plugins.PSObject.Properties)) {
                    if ("$($entry.Name)" -notlike "$pluginName@*") { continue }
                    foreach ($record in @($entry.Value)) {
                        if (-not $record) { continue }
                        # PSObject.Properties, not a dotted read: a user-scope record has no projectPath.
                        $installProp = $record.PSObject.Properties['installPath']
                        if (-not $installProp -or -not $installProp.Value) { continue }
                        $pathProp    = $record.PSObject.Properties['projectPath']
                        $projectPath = if ($pathProp -and $pathProp.Value) { ([string]$pathProp.Value -replace '/', '\').TrimEnd('\') } else { '' }
                        if (-not $projectPath) { $pathless += $record; continue }
                        if ($projectPath -eq $repoRoot.TrimEnd('\', '/')) { $matched += $record }
                    }
                }
            }
            $pool = @(if ($matched.Count) { $matched } else { $pathless })
            # lastUpdated first, installedAt behind it; an unparseable stamp sorts oldest.
            $ranked = @($pool | Sort-Object -Property @{ Expression = {
                $stamp = [datetime]::MinValue
                foreach ($field in @($_.PSObject.Properties['lastUpdated'].Value, $_.PSObject.Properties['installedAt'].Value)) {
                    if ($field -and [datetime]::TryParse("$field", [ref]$stamp)) { break }
                }
                $stamp
            } } -Descending)
            foreach ($record in $ranked) {
                $candidate = Join-Path ([string]$record.PSObject.Properties['installPath'].Value) $libRel
                if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
            }
        } catch { }
    }

    # 2. A running hook or skill of this plugin handed over its own root (the cache form ends in the
    #    version, so the parent carries the name; the clone form ends in the name itself).
    if ($env:CLAUDE_PLUGIN_ROOT) {
        $self   = Split-Path $env:CLAUDE_PLUGIN_ROOT -Leaf
        $parent = Split-Path (Split-Path $env:CLAUDE_PLUGIN_ROOT -Parent) -Leaf
        if ($self -eq $pluginName -or $parent -eq $pluginName) {
            $candidate = Join-Path $env:CLAUDE_PLUGIN_ROOT $libRel
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }

    # 3. The newest version folder in the install cache, whichever marketplace folder holds it.
    $cache = Join-Path $plugins 'cache'
    if (Test-Path -LiteralPath $cache -PathType Container) {
        $versions = @(Get-ChildItem -LiteralPath $cache -Directory -ErrorAction SilentlyContinue |
            ForEach-Object { Join-Path $_.FullName $pluginName } |
            Where-Object { Test-Path -LiteralPath $_ -PathType Container } |
            ForEach-Object { Get-ChildItem -LiteralPath $_ -Directory -ErrorAction SilentlyContinue })
        $newest = @($versions | Sort-Object -Property @{ Expression = {
            $v = $null
            if ([version]::TryParse($_.Name, [ref]$v)) { $v } else { [version]'0.0.0' }
        } } -Descending)
        foreach ($dir in $newest) {
            $candidate = Join-Path $dir.FullName $libRel
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }

    # 4. The marketplace clone: last, because it may sit at another commit than the loaded version.
    $markets = Join-Path $plugins 'marketplaces'
    if (Test-Path -LiteralPath $markets -PathType Container) {
        foreach ($market in @(Get-ChildItem -LiteralPath $markets -Directory -ErrorAction SilentlyContinue)) {
            $candidate = Join-Path $market.FullName (Join-Path "plugins\$pluginName" $libRel)
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
        }
    }

    return $null
}

if (-not $pluginPayloadLib) {
    Remove-Variable -Name pluginPayloadLib -ErrorAction SilentlyContinue
    throw ("The dkj-repo-workflow plugin was not found on this machine, so its plugin-payload lib " +
        "(scripts\lib\plugin-payload-lib.ps1) cannot be loaded. Is the plugin enabled? Check " +
        "enabledPlugins in .claude/settings.json, then run 'claude plugin marketplace update " +
        "dkj-marketplace' and 'claude plugin install dkj-repo-workflow@dkj-marketplace --scope project'; " +
        "a freshly installed plugin only loads after Claude Code restarts. If it is installed, it may " +
        "predate the plugin-payload lib: update the plugin.")
}

. $pluginPayloadLib
Remove-Variable -Name pluginPayloadLib -ErrorAction SilentlyContinue
