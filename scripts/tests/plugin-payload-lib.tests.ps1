<#
.SYNOPSIS
    Tests for scripts/lib/plugin-payload-lib.ps1 -- the one plugin-payload locator -- and for the
    forwarder template (plugins/dkj-repo-workflow/templates/plugin-scripts-forwarder.ps1) a consumer
    repo copies to find it (#4259).

.DESCRIPTION
    Dependency-free (no Pester), same style as the rest of the suite:

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/plugin-payload-lib.tests.ps1

    WHY THIS SUITE. The locator existed twice, in two consumer repos, diverged. Its cases were ported here
    from the more correct of the two copies -- the registry match, the slash and trailing-separator
    normalisation, the linked-worktree candidate, the prior-name fallback, the clone fallback, the env
    root, the missing plugin and the missing file, the registration statuses -- plus the resolution
    report of the other copy, the prior-name table that is now the one place rename history is stated,
    the derivation of claude-md-import-lib's retired-name map from it, and the forwarder.

    EVERY CASE RUNS ON A FIXTURE under a temp directory, through -PluginsRoot (the lib) or a scratch
    USERPROFILE handed to a child process (the forwarder). Nothing here reads the real ~/.claude, and
    each case clears CLAUDE_PLUGIN_ROOT and restores it afterwards: set in the real environment, step 1
    of the lookup would overrule every other case and the suite would be green without proving anything.

    THE FORWARDER IS DRIVEN IN A CHILD PROCESS, because what it does is define functions into the scope
    that dot-sources it and read USERPROFILE. The child prints which lib file it loaded (read off the
    function's own ScriptBlock) and what Get-PluginRoot answered without a -RepoRoot, so one run proves
    both the bootstrap and the repo-root default it sets.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
. (Join-Path $PSScriptRoot '..\lib\fixture-git-lib.ps1')
. (Join-Path $RepoRoot 'scripts\lib\native-capture-lib.ps1')
. (Join-Path $RepoRoot 'scripts\lib\command-probe-lib.ps1')

$LibPath       = Join-Path $RepoRoot 'scripts\lib\plugin-payload-lib.ps1'
$MirrorPath    = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\scripts\lib\plugin-payload-lib.ps1'
$ForwarderPath = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\templates\plugin-scripts-forwarder.ps1'
$ImportLibPath = Join-Path $RepoRoot 'scripts\lib\claude-md-import-lib.ps1'

$script:pass = 0
$script:fail = 0

function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Assert-True {
    param($Condition, [string]$Label)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label" -ForegroundColor Red }
}
function Assert-False {
    param($Condition, [string]$Label)
    Assert-True (-not $Condition) $Label
}
function Assert-Match {
    param([string]$Text, [string]$Needle, [string]$Label)
    if ($Text -match [regex]::Escape($Needle)) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         '$Needle' not found in: $Text" -ForegroundColor Red }
}
function Write-SuiteHeader { param([string]$Text) Write-Host ''; Write-Host "-- $Text" -ForegroundColor Cyan }

Write-Host '== plugin-payload-lib ==' -ForegroundColor Cyan

Assert-True (Test-Path -LiteralPath $LibPath -PathType Leaf) 'the lib exists at its registered source path'
Assert-True (Test-Path -LiteralPath $MirrorPath -PathType Leaf) 'the plugin mirror exists'
Assert-True (Test-Path -LiteralPath $ForwarderPath -PathType Leaf) 'the forwarder template exists'

# --- The import lib derives from the table, and loading it defines nothing else ------------------
# Asserted BEFORE the payload lib is dot-sourced into this scope: the claim is that loading
# claude-md-import-lib and asking for the retired-name map leaves no locator function behind, and that
# claim is only measurable while none is here yet.
Write-SuiteHeader 'claude-md-import-lib: the retired-name map is derived, and leaks nothing'
$leak = & {
    . $ImportLibPath
    $map = Get-RetiredPolicyExtensionNames
    [pscustomobject]@{
        Map    = $map
        Leaked = Test-FunctionDefined 'Get-PluginRoot'
    }
}
Assert-False $leak.Leaked 'the locator functions live in the call scope of Get-RetiredPolicyExtensionNames only'

. $LibPath

$map = $leak.Map
Assert-Equal 'dkj-repo-workflow-bwj' $map['dkj-policy-bwj'] 'dkj-policy-bwj still maps to the bwj extension'
Assert-Equal 'dkj-repo-workflow-dkj' $map['dkj-policy-dkjs'] 'dkj-policy-dkjs still maps to the dkj extension'
Assert-Equal 'dkj-repo-workflow-bwj' $map['bwj-development'] 'bwj-development still maps to the bwj extension'
Assert-Equal 'dkj-repo-workflow-dkj' $map['dkj-solutions'] 'dkj-solutions still maps to the dkj extension'
Assert-Equal 'dkj-repo-workflow'     $map['dkj-policy'] 'dkj-policy still maps to the workflow plugin itself'
$table = Get-PluginPriorNames
$derivedPairs = 0
foreach ($current in @($table.Keys)) {
    foreach ($old in @($table[$current])) {
        if ($map.Contains($old)) { $derivedPairs++; Assert-Equal $current $map[$old] "derived: '$old' maps to '$current', as the table says" }
    }
}
Assert-True ($derivedPairs -ge 5) 'at least the five names the map always carried come from the table'
Assert-False ($map.Contains('team-alpha') -or $map.Contains('dkj-team-alpha')) 'team-plugin names are no concern of a constitution import and stay out of the map'

# --- The prior-name table ------------------------------------------------------------------------
Write-SuiteHeader 'prior-name table: the one place rename history is stated'
$wf = @(Get-PluginPriorNames -Plugin 'dkj-repo-workflow')
Assert-Equal 'dkj-policy' $wf[0] 'the workflow plugin: the newest retired id comes first'
Assert-Equal 'contributing-davekjohn' $wf[1] 'then the one before it'
Assert-Equal 'workflow-davekjohn' $wf[2] 'and the oldest last'
$bwj = @(Get-PluginPriorNames -Plugin 'dkj-repo-workflow-bwj')
Assert-Equal 'bwj-development|dkj-policy-bwj|bwj-codex' ($bwj -join '|') 'the bwj extension: three retired ids, newest first'
$alpha = @(Get-PluginPriorNames -Plugin 'dkj-subagents-alpha')
Assert-Equal 'dkj-team-alpha|team-alpha' ($alpha -join '|') 'a team plugin renamed twice carries both retired ids, newest first'
Assert-Equal 0 @(Get-PluginPriorNames -Plugin 'a-plugin-nobody-renamed').Count 'a plugin with no history has no prior names'
Assert-Equal 0 @(Get-PluginPriorNames -Plugin 'dkj-team-alpha').Count 'a RETIRED id is not a key: no chain starts from it'
$seen = @{}
$dupes = 0
foreach ($current in @($table.Keys)) {
    foreach ($old in @($table[$current])) {
        if ($seen.ContainsKey($old) -or $table.Contains($old)) { $dupes++ }
        $seen[$old] = $current
    }
}
Assert-Equal 0 $dupes 'no id appears twice, and no retired id is also a current id (no second statement of one fact)'
$mutated = Get-PluginPriorNames
$mutated['dkj-repo-workflow'] = @('x')
Assert-Equal 'dkj-policy' (@(Get-PluginPriorNames -Plugin 'dkj-repo-workflow'))[0] 'a caller mutating the returned table cannot change the source'

$cand = @(Get-PluginNameCandidates -Plugin 'dkj-repo-workflow')
Assert-Equal 4 $cand.Count 'the default gets its three retired names behind it'
Assert-Equal 'dkj-repo-workflow' $cand[0] 'and the current name comes first'
Assert-Equal 1 @(Get-PluginNameCandidates -Plugin 'team-shopify').Count 'an unknown or retired name is not widened'

# --- Self-containment: the lib and the forwarder call nothing they do not define -----------------
Write-SuiteHeader 'dependency-free: every Verb-Noun call is defined in the file or built in'
function Get-UnresolvedCall {
    param([Parameter(Mandatory = $true)][string]$Path)
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$errors)
    if ($errors -and $errors.Count -gt 0) { return $null }
    $defined = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
        ForEach-Object { $_.Name })
    $called = @($ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true) |
        ForEach-Object { $_.GetCommandName() } | Where-Object { $_ -and $_ -like '*-*' } | Sort-Object -Unique)
    return ,@($called | Where-Object { $defined -notcontains $_ -and -not $ExecutionContext.SessionState.InvokeCommand.GetCmdlet($_) })
}
foreach ($f in @($LibPath, $ForwarderPath)) {
    $unresolved = Get-UnresolvedCall -Path $f
    Assert-True ($null -ne $unresolved) "$(Split-Path -Leaf $f) parses"
    Assert-Equal '' (@($unresolved) -join ',') "$(Split-Path -Leaf $f) calls no function it does not define"
    $text = [System.IO.File]::ReadAllText($f)
    Assert-False ($text -match '(?m)^\s*Set-StrictMode\b') "$(Split-Path -Leaf $f) sets no strict mode at file level"
}

# --- Fixture --------------------------------------------------------------------------------------
$marketplace = 'dkj-marketplace'
$pluginName  = 'dkj-repo-workflow'
$relScript   = 'scripts\task\new-branch.ps1'
$fx          = Join-Path ([System.IO.Path]::GetTempPath()) "plugin-payload-fixture-$PID-$([guid]::NewGuid().ToString('n'))"
New-Item -ItemType Directory -Force -Path $fx | Out-Null
$otherRepo   = 'C:\Users\Someone\GitHub\other-project'
$thisRepo    = Join-Path $fx 'consumer-repo'
New-Item -ItemType Directory -Force -Path $thisRepo | Out-Null
$registryPath = Join-Path $fx 'installed_plugins.json'
$Utf8NoBom   = New-Object System.Text.UTF8Encoding $false

function New-FixturePayload {
    <# A plugin folder with one script, and -Version writing .claude-plugin\plugin.json too. -WithLib also
       carries a copy of the real lib, so the forwarder has something to dot-source. #>
    param([Parameter(Mandatory = $true)][string]$Root, [string]$Version = '', [switch]$WithLib)
    New-Item -ItemType Directory -Force -Path (Join-Path $Root 'scripts\task') | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $Root $relScript), "# fixture`r`n")
    if ($Version) {
        New-Item -ItemType Directory -Force -Path (Join-Path $Root '.claude-plugin') | Out-Null
        [System.IO.File]::WriteAllText((Join-Path $Root '.claude-plugin\plugin.json'), "{ `"version`": `"$Version`" }", $Utf8NoBom)
    }
    if ($WithLib) {
        New-Item -ItemType Directory -Force -Path (Join-Path $Root 'scripts\lib') | Out-Null
        Copy-Item -LiteralPath $LibPath -Destination (Join-Path $Root 'scripts\lib\plugin-payload-lib.ps1') -Force
    }
    return $Root
}

function Write-FixtureRegistryNamed {
    <# installed_plugins.json with the keys the caller gives; $null removes the file. #>
    param($Keys, [string]$Path = $registryPath)
    if ($null -eq $Keys) { Remove-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue; return }
    [System.IO.File]::WriteAllText($Path, (@{ version = 2; plugins = $Keys } | ConvertTo-Json -Depth 8), $Utf8NoBom)
}
function Write-FixtureRegistry {
    <# The common shape: entries under <current plugin>@<marketplace>. @() is a key with no entries. #>
    param($Entries)
    if ($null -eq $Entries) { Write-FixtureRegistryNamed -Keys $null; return }
    Write-FixtureRegistryNamed -Keys @{ "$pluginName@$marketplace" = $Entries }
}

$cacheThis  = New-FixturePayload -Root (Join-Path $fx "cache\$marketplace\$pluginName\4.0.0") -Version '4.0.0'
$cacheOther = New-FixturePayload -Root (Join-Path $fx "cache\$marketplace\$pluginName\3.0.8") -Version '3.0.8'
$cloneRoot  = New-FixturePayload -Root (Join-Path $fx "marketplaces\$marketplace\plugins\$pluginName") -Version '5.0.0'

$prevPluginRoot = $env:CLAUDE_PLUGIN_ROOT
try {
    $env:CLAUDE_PLUGIN_ROOT = ''

    # --- The registry entry of THIS project wins --------------------------------------------------
    Write-SuiteHeader 'lookup: the version THIS repo loaded wins, and the cache beats the clone'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheOther; version = '3.0.8' },
        @{ scope = 'project'; projectPath = $thisRepo;  installPath = $cacheThis;  version = '4.0.0' }
    )
    $root = Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-Equal $cacheThis $root 'the installPath of this project is chosen, not that of another project'
    Assert-True ($root -notmatch 'marketplaces') 'the clone is not chosen while the registry points at a live cache'

    Write-SuiteHeader 'lookup: with no entry for this project, the highest version that exists wins'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheOther; version = '3.0.8' },
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheThis;  version = '4.0.0' }
    )
    Assert-Equal $cacheThis (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        '4.0.0 beats 3.0.8 by version, and 10.0.0 would beat 9.0.0 (not a text sort)'
    $cache10 = New-FixturePayload -Root (Join-Path $fx "cache\$marketplace\$pluginName\10.0.0") -Version '10.0.0'
    $cache9  = New-FixturePayload -Root (Join-Path $fx "cache\$marketplace\$pluginName\9.0.0")  -Version '9.0.0'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cache9;  version = '9.0.0' },
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cache10; version = '10.0.0' }
    )
    Assert-Equal $cache10 (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        '10.0.0 wins over 9.0.0'

    Write-SuiteHeader 'lookup: an installPath that is gone is skipped'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $thisRepo;  installPath = (Join-Path $fx 'cache\gone\9.9.9'); version = '9.9.9' },
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheOther; version = '3.0.8' }
    )
    Assert-Equal $cacheOther (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'a vanished installPath of this project does not block the lookup'

    # --- The clone as the last resort -------------------------------------------------------------
    Write-SuiteHeader 'lookup: with no registry the marketplace clone answers'
    Write-FixtureRegistry -Entries $null
    Assert-Equal $cloneRoot (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'the clone is the last resort, not the first choice'

    Write-SuiteHeader 'lookup: an unreadable registry does not make the lookup fall over'
    [System.IO.File]::WriteAllText($registryPath, '{ this is not json', $Utf8NoBom)
    Assert-Equal $cloneRoot (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'broken JSON falls back to the clone instead of throwing'

    Write-SuiteHeader 'lookup: the extension family folder of the clone is searched too'
    $extClone = New-FixturePayload -Root (Join-Path $fx "marketplaces\$marketplace\plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-dkj") -Version '1.0.0'
    Assert-Equal $extClone (Get-PluginRoot -Plugin 'dkj-repo-workflow-dkj' -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'an extension nested under plugins\dkj-repo-workflow\extensions is found'
    $teamClone = New-FixturePayload -Root (Join-Path $fx "marketplaces\$marketplace\plugins\dkj-subagents\dkj-subagents-alpha") -Version '1.0.0'
    Assert-Equal $teamClone (Get-PluginRoot -Plugin 'dkj-subagents-alpha' -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'a team plugin under plugins\dkj-subagents is found'

    # --- A retired id: still readable, never preferred ----------------------------------------------
    $priorName  = 'dkj-policy'
    $cachePrior = New-FixturePayload -Root (Join-Path $fx "cache\$marketplace\$priorName\4.18.0") -Version '4.18.0'

    Write-SuiteHeader 'prior names: only the OLD id in the registry is still found'
    Write-FixtureRegistryNamed -Keys @{ "$priorName@$marketplace" = @(
        @{ scope = 'project'; projectPath = $thisRepo; installPath = $cachePrior; version = '4.18.0' }) }
    Assert-Equal $cachePrior (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'a machine that has not installed the renamed plugin yet keeps working'

    Write-SuiteHeader 'prior names: with BOTH ids registered the new one wins, even at a lower version'
    Write-FixtureRegistryNamed -Keys @{
        "$priorName@$marketplace"  = @(@{ scope = 'project'; projectPath = $thisRepo; installPath = $cachePrior; version = '4.18.0' })
        "$pluginName@$marketplace" = @(@{ scope = 'project'; projectPath = $thisRepo; installPath = $cacheThis;  version = '4.0.0' })
    }
    Assert-Equal $cacheThis (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'the new name wins ahead of an old cache carrying a HIGHER version number'

    Write-SuiteHeader 'prior names: ALL NAMES PER STEP -- the cache of the old id beats the clone of the new id'
    Write-FixtureRegistryNamed -Keys @{ "$priorName@$marketplace" = @(
        @{ scope = 'project'; projectPath = $thisRepo; installPath = $cachePrior; version = '4.18.0' }) }
    $r = Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-True ($r -ne $cloneRoot) 'the clone of the CURRENT name does not override what the checkout loaded under the old name'

    Write-SuiteHeader 'prior names: the OLD id in the clone is found when nothing else is'
    $oldClonePlugins = Join-Path $fx 'oldclone-plugins'
    $oldCloneRoot = New-FixturePayload -Root (Join-Path $oldClonePlugins "marketplaces\$marketplace\plugins\$priorName") -Version '4.0.0'
    Assert-Equal $oldCloneRoot (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $oldClonePlugins) `
        'a clone that has not pulled past the rename is still read'

    # --- CLAUDE_PLUGIN_ROOT ------------------------------------------------------------------------
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $thisRepo; installPath = $cacheThis; version = '4.0.0' })
    Write-SuiteHeader 'env root: the folder of ANOTHER plugin is ignored'
    $foreign = New-FixturePayload -Root (Join-Path $fx "cache\$marketplace\dkj-subagents-shopify\4.0.0")
    $env:CLAUDE_PLUGIN_ROOT = $foreign
    Assert-Equal $cacheThis (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'a hook of another plugin does not hand its own folder over as ours'

    Write-SuiteHeader 'env root: the cache shape (the VERSION is the leaf) is taken'
    $env:CLAUDE_PLUGIN_ROOT = $cacheOther
    Assert-Equal $cacheOther (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'inside a call of this plugin the cache path counts, parent = plugin name'

    Write-SuiteHeader 'env root: the clone shape (the plugin name is the leaf) is taken too'
    $env:CLAUDE_PLUGIN_ROOT = $cloneRoot
    Assert-Equal $cloneRoot (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'a path that ENDS in the plugin name counts as well'

    Write-SuiteHeader 'env root: a RETIRED name as the folder still counts for the renamed plugin'
    $env:CLAUDE_PLUGIN_ROOT = $cachePrior
    Assert-Equal $cachePrior (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx) `
        'the candidates apply at step 1 as well'
    $env:CLAUDE_PLUGIN_ROOT = ''

    # --- Nothing at all ----------------------------------------------------------------------------
    Write-SuiteHeader 'missing plugin: $null from the lookup, an actionable message from Resolve-PluginScript'
    $empty = Join-Path $fx 'empty'
    New-Item -ItemType Directory -Force -Path $empty | Out-Null
    Assert-True ($null -eq (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $empty)) `
        'Get-PluginRoot is $null when the plugin is nowhere'
    Assert-True ($null -eq (Get-PluginResolution -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $empty)) `
        'Get-PluginResolution is $null when the plugin is nowhere'
    $msg = ''
    try { Resolve-PluginScript -RelativePath $relScript -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $empty | Out-Null }
    catch { $msg = $_.Exception.Message }
    Assert-Match $msg 'enabledPlugins' 'the message points at where the plugin is enabled'
    Assert-Match $msg 'restarts' 'and names the restart caveat of a freshly updated plugin'
    Assert-Match $msg "$pluginName@$marketplace" 'and names the plugin it looked for'

    # --- Resolve-PluginScript ----------------------------------------------------------------------
    Write-SuiteHeader 'Resolve-PluginScript: the full path, an empty path refused, a missing script named'
    $full = Resolve-PluginScript -RelativePath $relScript -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-Equal (Join-Path $cacheThis $relScript) $full 'the path is the chosen plugin root plus the relative path'
    Assert-True (Test-Path -LiteralPath $full -PathType Leaf) 'and it exists'
    $msg = ''
    try { Resolve-PluginScript -RelativePath '' -PluginsRoot $fx -RepoRoot $thisRepo | Out-Null } catch { $msg = $_.Exception.Message }
    Assert-Match $msg 'must not be empty' 'an empty -RelativePath is refused with its own message'
    $msg = ''
    try { Resolve-PluginScript -RelativePath 'scripts\task\nope.ps1' -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx | Out-Null }
    catch { $msg = $_.Exception.Message }
    Assert-Match $msg 'nope.ps1' 'a missing script is named'
    Assert-Match $msg $cacheThis 'and so is where it was looked for'

    # --- Get-PluginResolution ----------------------------------------------------------------------
    Write-SuiteHeader 'Get-PluginResolution: Source and Version, and no loader fields'
    $res = Get-PluginResolution -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-Equal $cacheThis $res.Path 'Path is what Get-PluginRoot returned'
    Assert-Equal 'install-cache' $res.Source 'a registry answer is the install cache'
    Assert-Equal '4.0.0' $res.Version 'Version is read from the copy''s own plugin.json'
    Assert-Equal $pluginName $res.Plugin 'Plugin is echoed'
    Assert-Equal $marketplace $res.Marketplace 'Marketplace is echoed'
    Assert-False ($res.PSObject.Properties.Name -contains 'LoaderBacked' -or $res.PSObject.Properties.Name -contains 'LoaderNote') `
        'no LoaderBacked / LoaderNote: they depend on a consumer-local file this plugin does not ship'
    Write-FixtureRegistry -Entries $null
    $res = Get-PluginResolution -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-Equal 'marketplace-clone' $res.Source 'no registry: the clone is the Source'
    Assert-Equal '5.0.0' $res.Version 'and its own version is reported'
    $env:CLAUDE_PLUGIN_ROOT = $foreign
    $nameless = New-FixturePayload -Root (Join-Path $fx "elsewhere\$pluginName")
    $env:CLAUDE_PLUGIN_ROOT = $nameless
    $res = Get-PluginResolution -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $empty
    Assert-Equal 'plugin-root-env' $res.Source 'a root handed over by a running hook is plugin-root-env'
    Assert-True ($null -eq $res.Version) 'a copy without a manifest has a $null Version, not a failed lookup'
    $env:CLAUDE_PLUGIN_ROOT = ''
    [System.IO.File]::WriteAllText((Join-Path $cloneRoot '.claude-plugin\plugin.json'), '{ not json', $Utf8NoBom)
    $res = Get-PluginResolution -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-True ($null -eq $res.Version) 'an unparseable manifest is a missing version, never a throw'
    [System.IO.File]::WriteAllText((Join-Path $cloneRoot '.claude-plugin\plugin.json'), '{ "version": "5.0.0" }', $Utf8NoBom)

    # --- Get-PluginProjectRegistration -------------------------------------------------------------
    Write-SuiteHeader 'registration: an entry for THIS project with a live installPath'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheOther; version = '3.0.8' },
        @{ scope = 'project'; projectPath = $thisRepo;  installPath = $cacheThis;  version = '4.0.0' }
    )
    $reg = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-True $reg.Registered 'registered'
    Assert-Equal 'ok' $reg.Reason 'reason ok'
    Assert-Equal $cacheThis $reg.InstallPath 'the install of THIS project comes back'

    Write-SuiteHeader 'registration: only another path is registered -> no-project-entry, and it names what is known'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheOther; version = '3.0.8' })
    $reg = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-False $reg.Registered 'not registered'
    Assert-Equal 'no-project-entry' $reg.Reason 'the reason names the missing project, not the key'
    Assert-True ($reg.KnownPaths -contains $otherRepo) 'the paths that ARE registered come along'
    Assert-True ([bool](Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx)) `
        'while Get-PluginRoot still finds a plugin on disk -- that difference is the point'

    Write-SuiteHeader 'registration: a look-alike path is no match; separators and a trailing slash are'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = ($thisRepo + '-fork'); installPath = $cacheThis; version = '4.0.0' })
    Assert-False (Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx).Registered `
        'a path that merely starts like the root is not a match'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = (($thisRepo -replace '\\', '/') + '/'); installPath = $cacheThis; version = '4.0.0' })
    Assert-True (Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx).Registered `
        'forward slashes plus a trailing slash are the same folder'

    Write-SuiteHeader 'registration: the lookup and the check compare identically'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheOther; version = '3.0.8' },
        @{ scope = 'project'; projectPath = ($thisRepo -replace '\\', '/'); installPath = $cacheThis; version = '1.0.0' }
    )
    $root = Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    $reg  = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-Equal $cacheThis $root 'the lookup recognises a slash-form projectPath as this project'
    Assert-Equal $root $reg.InstallPath 'and the check names the same install: one comparison, not two'

    Write-SuiteHeader 'registration: a dead cache, a missing key, a missing or broken registry'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $thisRepo; installPath = (Join-Path $fx 'cache\gone\9.9.9'); version = '9.9.9' })
    $reg = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-False $reg.Registered 'an entry with no live cache is not registered'
    Assert-Equal 'installpath-missing' $reg.Reason 'and says so, apart from a missing project'
    Write-FixtureRegistry -Entries @(@{ scope = 'project'; projectPath = $thisRepo; version = '4.0.0' })
    $reg = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-Equal 'installpath-missing' $reg.Reason 'an entry with NO installPath at all reads the same'
    Assert-True ($reg.KnownPaths -contains $thisRepo) 'and stays visible in KnownPaths'
    Write-FixtureRegistry -Entries @()
    Assert-Equal 'no-key' (Get-PluginProjectRegistration -Plugin 'not-registered' -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx).Reason `
        'a plugin absent from the registry is no-key'
    Write-FixtureRegistry -Entries $null
    $reg = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
    Assert-Equal 'no-registry' $reg.Reason 'no registry file is no-registry'
    [System.IO.File]::WriteAllText($registryPath, '{ not json', $Utf8NoBom)
    Assert-Equal 'unreadable-registry' (Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx).Reason `
        'broken JSON reports itself and does not throw'

    Write-SuiteHeader 'registration: a RETIRED id registered for this project counts'
    Write-FixtureRegistryNamed -Keys @{ "$priorName@$marketplace" = @(
        @{ scope = 'project'; projectPath = $thisRepo; installPath = $cacheThis; version = '4.18.0' }) }
    Assert-True (Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx).Registered `
        'the check reads the same candidates as the lookup'

    Write-SuiteHeader 'strict callers: an entry without projectPath or installPath throws nowhere'
    Write-FixtureRegistry -Entries @(
        @{ scope = 'user'; installPath = $cacheOther; version = '9.9.9' },
        @{ scope = 'user'; version = '9.9.9' },
        @{ scope = 'project'; projectPath = $thisRepo; installPath = $cacheThis; version = '4.0.0' }
    )
    $strict = & {
        Set-StrictMode -Version Latest
        try {
            [pscustomobject]@{
                Root  = Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
                Reg   = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $thisRepo -PluginsRoot $fx
                Dflt  = Get-PluginDefaultRepoRoot
                Error = ''
            }
        } catch { [pscustomobject]@{ Root = ''; Reg = $null; Dflt = ''; Error = [string]$_.FullyQualifiedErrorId } }
    }
    Assert-Equal '' $strict.Error 'no lookup throws under Set-StrictMode, with the repo-root default unset as well'
    Assert-Equal $cacheThis $strict.Root 'the lookup still prefers this project over the higher machine-wide version'
    Assert-True $strict.Reg.Registered 'and the check still sees the project as registered'
    Assert-Equal '' (Get-PluginEntryProjectPath -Entry ([pscustomobject]@{ scope = 'user'; installPath = 'x' })) 'no projectPath property is ''''.'
    Assert-Equal '' (Get-PluginEntryProjectPath -Entry $null) 'a null entry is ''''.'
    Assert-Equal 'C:\r' (Get-PluginEntryProjectPath -Entry ([pscustomobject]@{ projectPath = 'C:\r' })) 'a filled projectPath comes back as is'

    # --- A linked worktree counts through its main checkout ---------------------------------------
    Write-SuiteHeader 'worktree: a linked worktree is registered through its main checkout'
    $gitMain  = Join-Path $fx 'wt-main'
    $gitLane  = Join-Path $fx 'wt-lane'
    $gitOther = Join-Path $fx 'wt-other'
    New-Item -ItemType Directory -Force -Path $gitMain, $gitOther | Out-Null
    foreach ($g in @($gitMain, $gitOther)) {
        Invoke-FixtureGitIn $g init -q
        Invoke-FixtureGitIn $g -c user.name=fixture -c user.email=fixture@example.invalid commit -q --allow-empty -m init
    }
    Invoke-FixtureGitIn $gitMain worktree add -q --detach $gitLane
    Assert-True (Test-Path -LiteralPath (Join-Path $gitLane '.git') -PathType Leaf) 'the fixture worktree exists (a .git FILE, not a folder)'

    $cands = @(Get-PluginProjectPathCandidates -RepoRoot $gitLane)
    Assert-Equal 2 $cands.Count 'a worktree has two candidates'
    Assert-Equal (ConvertTo-PluginComparablePath -Path $gitLane) $cands[0] 'itself first'
    Assert-Equal 1 @(Get-PluginProjectPathCandidates -RepoRoot $gitMain).Count 'a main checkout has only itself'
    Assert-Equal 1 @(Get-PluginProjectPathCandidates -RepoRoot (Join-Path $fx 'not-a-repo-at-all')).Count 'a folder that is no repo has only itself'

    Write-FixtureRegistry -Entries @(@{ scope = 'project'; projectPath = $gitMain; installPath = $cacheThis; version = '4.0.0' })
    $reg = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $gitLane -PluginsRoot $fx
    Assert-True $reg.Registered 'registered through the main checkout'
    Assert-Equal (ConvertTo-PluginComparablePath -Path $gitMain) $reg.MatchedProject 'and the match names the main checkout'
    Assert-Equal $cacheThis (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $gitLane -PluginsRoot $fx) `
        'the lookup picks the same install in the worktree'

    Write-FixtureRegistry -Entries @(
        @{ scope = 'project'; projectPath = $gitMain; installPath = $cacheThis;  version = '4.0.0' },
        @{ scope = 'project'; projectPath = $gitLane; installPath = $cacheOther; version = '3.0.8' })
    Assert-Equal $cacheOther (Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $gitLane -PluginsRoot $fx).InstallPath `
        'the worktree''s own entry beats the main checkout''s, whatever order the registry carries them'
    Assert-Equal $cacheOther (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -RepoRoot $gitLane -PluginsRoot $fx) 'and so does the lookup'

    Write-FixtureRegistry -Entries @(@{ scope = 'project'; projectPath = $gitMain; installPath = $cacheThis; version = '4.0.0' })
    $reg = Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -RepoRoot $gitOther -PluginsRoot $fx
    Assert-False $reg.Registered 'a separate repo beside the registered one is no match'
    Assert-Equal 'no-project-entry' $reg.Reason 'and the reason stays no-project-entry'

    # --- The default repo root ---------------------------------------------------------------------
    Write-SuiteHeader 'default repo root: the forwarder''s answer first, else the repo around the current directory'
    $sub = Join-Path $gitMain 'deep\er'
    New-Item -ItemType Directory -Force -Path $sub | Out-Null
    Push-Location -LiteralPath $sub
    try {
        Assert-Equal (ConvertTo-PluginComparablePath -Path $gitMain) (ConvertTo-PluginComparablePath -Path (Get-PluginDefaultRepoRoot)) `
            'from a subfolder the default is the repo root'
        $script:PluginPayloadRepoRoot = $thisRepo
        Assert-Equal $thisRepo (Get-PluginDefaultRepoRoot) 'a root the caller set wins'
        Write-FixtureRegistry -Entries @(
            @{ scope = 'project'; projectPath = $otherRepo; installPath = $cacheOther; version = '3.0.8' },
            @{ scope = 'project'; projectPath = $thisRepo;  installPath = $cacheThis;  version = '4.0.0' })
        Assert-Equal $cacheThis (Get-PluginRoot -Plugin $pluginName -Marketplace $marketplace -PluginsRoot $fx) `
            'Get-PluginRoot with no -RepoRoot uses it'
        Assert-True (Get-PluginProjectRegistration -Plugin $pluginName -Marketplace $marketplace -PluginsRoot $fx).Registered `
            'so does the registration check'
    } finally {
        Remove-Variable -Name PluginPayloadRepoRoot -Scope Script -ErrorAction SilentlyContinue
        Pop-Location
    }
    Invoke-FixtureGitIn $gitMain worktree remove --force $gitLane

    # --- The forwarder -----------------------------------------------------------------------------
    # Each case builds a scratch USERPROFILE and a consumer repo carrying the forwarder as
    # scripts\lib\plugin-scripts.ps1, runs a probe in a CHILD process, and reads back WHICH lib file the
    # forwarder dot-sourced and what Get-PluginRoot answers with no -RepoRoot.
    Write-SuiteHeader 'forwarder: it finds the lib through a fixture registry and sets the repo-root default'

    function New-ForwarderCase {
        param([Parameter(Mandatory = $true)][string]$Name)
        $case = Join-Path $fx "fwd-$Name"
        $repo = Join-Path $case 'repo'
        $userHome = Join-Path $case 'home'
        New-Item -ItemType Directory -Force -Path (Join-Path $repo 'scripts\lib'), (Join-Path $userHome '.claude\plugins') | Out-Null
        Copy-Item -LiteralPath $ForwarderPath -Destination (Join-Path $repo 'scripts\lib\plugin-scripts.ps1') -Force
        [System.IO.File]::WriteAllText((Join-Path $repo 'probe.ps1'), @'
. (Join-Path $PSScriptRoot 'scripts\lib\plugin-scripts.ps1')
$libFile = (Get-Command Resolve-PluginScript).ScriptBlock.File
"LIB=$libFile"
"ROOT=$(Get-PluginRoot)"
"REPOROOT=$($script:PluginPayloadRepoRoot)"
"LEAK=$([bool](Get-Variable -Name pluginPayloadLib -ErrorAction SilentlyContinue))"
'@, $Utf8NoBom)
        return [pscustomobject]@{
            Repo    = $repo
            Home    = $userHome
            Plugins = (Join-Path $userHome '.claude\plugins')
            Registry = (Join-Path $userHome '.claude\plugins\installed_plugins.json')
        }
    }
    function Invoke-ForwarderProbe {
        param($Case, [string]$PluginRootEnv = '')
        $prevProfile = $env:USERPROFILE
        $prevHome    = $env:HOME
        $prevRoot    = $env:CLAUDE_PLUGIN_ROOT
        try {
            $env:USERPROFILE = $Case.Home
            $env:HOME = $Case.Home
            $env:CLAUDE_PLUGIN_ROOT = $PluginRootEnv
            $run = Invoke-NativeCapture -FilePath 'powershell' -Utf8 -Arguments @(
                '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $Case.Repo 'probe.ps1'))
        } finally {
            $env:USERPROFILE = $prevProfile
            if ($null -eq $prevHome) { Remove-Item Env:HOME -ErrorAction SilentlyContinue } else { $env:HOME = $prevHome }
            $env:CLAUDE_PLUGIN_ROOT = $prevRoot
        }
        $text = (($run.Output | ForEach-Object { "$_" }) -join "`n")
        $get = { param($k) if ($text -match "(?m)^$k=(.*)$") { $Matches[1].Trim() } else { '' } }
        return [pscustomobject]@{
            Code = $run.ExitCode; Text = $text; Squish = ($text -replace '\s', '')
            Lib = (& $get 'LIB'); Root = (& $get 'ROOT'); RepoRoot = (& $get 'REPOROOT'); Leak = (& $get 'LEAK')
        }
    }
    function New-ForwarderInstall {
        param($Case, [string]$Marketplace, [string]$Plugin, [string]$Version, [switch]$NoLib)
        $root = New-FixturePayload -Root (Join-Path $Case.Plugins "cache\$Marketplace\$Plugin\$Version") -Version $Version -WithLib:(-not $NoLib)
        return $root
    }
    function Write-ForwarderRegistry {
        param($Case, [hashtable]$Keys)
        Write-FixtureRegistryNamed -Keys $Keys -Path $Case.Registry
    }
    function Get-LibIn { param([string]$InstallRoot) Join-Path $InstallRoot 'scripts\lib\plugin-payload-lib.ps1' }

    # F1. This repo's record wins over a newer cache folder; the repo-root default makes Get-PluginRoot agree.
    $c = New-ForwarderCase -Name 'registry'
    $mine  = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '7.0.0'
    $newer = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '9.0.0'
    Write-ForwarderRegistry -Case $c -Keys @{ "$pluginName@$marketplace" = @(
        @{ scope = 'project'; projectPath = $c.Repo; installPath = $mine; version = '7.0.0' }) }
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal 0 $r.Code 'F1: the probe exits 0'
    Assert-Equal (Get-LibIn $mine) $r.Lib 'F1: the lib of the install THIS repo is registered for is loaded, not the newer cache folder'
    Assert-Equal $mine $r.Root 'F1: Get-PluginRoot with no -RepoRoot resolves this repo''s record -- the default root is the forwarder''s own repo'
    Assert-Equal $c.Repo $r.RepoRoot 'F1: PluginPayloadRepoRoot is the repo two levels above the forwarder'
    Assert-Equal 'False' $r.Leak 'F1: the bootstrap''s own variable is removed again'

    # F2. Matched on the plugin NAME: another marketplace name, and the bwj extension is not mistaken for it.
    $c = New-ForwarderCase -Name 'name-only'
    $ext   = New-ForwarderInstall -Case $c -Marketplace 'renamed-market' -Plugin 'dkj-repo-workflow-bwj' -Version '9.9.9'
    $other = New-ForwarderInstall -Case $c -Marketplace 'renamed-market' -Plugin $pluginName -Version '7.1.0'
    Write-ForwarderRegistry -Case $c -Keys @{
        'dkj-repo-workflow-bwj@renamed-market' = @(@{ scope = 'project'; projectPath = $c.Repo; installPath = $ext; version = '9.9.9' })
        'dkj-repo-workflow@renamed-market'     = @(@{ scope = 'project'; projectPath = $c.Repo; installPath = $other; version = '7.1.0' })
    }
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal (Get-LibIn $other) $r.Lib 'F2: a record under ANOTHER marketplace name is matched on the plugin name, and the bwj extension is not it'

    # F3. Two matching records: the most recently updated wins.
    $c = New-ForwarderCase -Name 'stale'
    $old = New-ForwarderInstall -Case $c -Marketplace 'old-market' -Plugin $pluginName -Version '9.0.0'
    $new = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '7.0.0'
    Write-ForwarderRegistry -Case $c -Keys @{
        'dkj-repo-workflow@old-market' = @(@{ scope = 'project'; projectPath = $c.Repo; installPath = $old; version = '9.0.0'; lastUpdated = '2026-01-01T00:00:00Z' })
        "dkj-repo-workflow@$marketplace" = @(@{ scope = 'project'; projectPath = $c.Repo; installPath = $new; version = '7.0.0'; lastUpdated = '2026-11-01T00:00:00Z' })
    }
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal (Get-LibIn $new) $r.Lib 'F3: of two records naming this repo the most recently updated wins, not the first enumerated or the highest version'

    # F4. Somebody else's project record is ignored; a path-less record serves this repo.
    $c = New-ForwarderCase -Name 'pathless'
    $theirs = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '7.0.0'
    $wide   = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '6.0.0'
    Write-ForwarderRegistry -Case $c -Keys @{ "$pluginName@$marketplace" = @(
        @{ scope = 'project'; projectPath = $otherRepo; installPath = $theirs; version = '7.0.0' },
        @{ scope = 'user'; installPath = $wide; version = '6.0.0' }) }
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal (Get-LibIn $wide) $r.Lib 'F4: a project record of ANOTHER repo is never used; the machine-wide record serves this one'

    # F5. A record whose install lacks the lib is skipped, not chosen.
    $c = New-ForwarderCase -Name 'nolib'
    $bare = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '6.0.0' -NoLib
    $good = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '5.0.0'
    Write-ForwarderRegistry -Case $c -Keys @{ "$pluginName@$marketplace" = @(
        @{ scope = 'project'; projectPath = $c.Repo; installPath = $bare; version = '6.0.0' }) }
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal (Get-LibIn $good) $r.Lib 'F5: an install that predates the lib is skipped and the next candidate (the cache) is used'

    # F6. No registry: CLAUDE_PLUGIN_ROOT of this plugin.
    $c = New-ForwarderCase -Name 'env'
    $viaEnv = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '3.0.0'
    $newest = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '8.0.0'
    $r = Invoke-ForwarderProbe -Case $c -PluginRootEnv $viaEnv
    Assert-Equal (Get-LibIn $viaEnv) $r.Lib 'F6: with no registry the plugin root a running hook handed over is used ahead of the cache scan'
    $foreignEnv = New-FixturePayload -Root (Join-Path $c.Plugins "cache\$marketplace\dkj-subagents-shopify\9.9.9")
    $r = Invoke-ForwarderProbe -Case $c -PluginRootEnv $foreignEnv
    Assert-Equal (Get-LibIn $newest) $r.Lib 'F6b: the root of ANOTHER plugin is ignored'

    # F7. Cache scan: the newest version by number.
    $c = New-ForwarderCase -Name 'cache'
    $v9  = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '9.0.0'
    $v10 = New-ForwarderInstall -Case $c -Marketplace $marketplace -Plugin $pluginName -Version '10.0.0'
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal (Get-LibIn $v10) $r.Lib 'F7: the newest cache version by number (10.0.0 over 9.0.0), with no registry at all'

    # F8. Marketplace clone, last.
    $c = New-ForwarderCase -Name 'clone'
    $cloneInstall = New-FixturePayload -Root (Join-Path $c.Plugins "marketplaces\$marketplace\plugins\$pluginName") -Version '7.0.0' -WithLib
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal (Get-LibIn $cloneInstall) $r.Lib 'F8: the marketplace clone answers when nothing else does'

    # F9. Nothing installed: a clear, actionable English error and a non-zero exit.
    $c = New-ForwarderCase -Name 'nothing'
    $r = Invoke-ForwarderProbe -Case $c
    Assert-True ($r.Code -ne 0) 'F9: the probe fails when no plugin is installed'
    Assert-Match $r.Squish ('The' + 'dkj-repo-workflowpluginwasnotfoundonthismachine') 'F9: the error says what was not found'
    Assert-Match $r.Squish 'enabledPlugins' 'F9: it points at where the plugin is enabled'
    Assert-Match $r.Squish 'claudepluginmarketplaceupdate' 'F9: and at what to run'
    Assert-Equal '' $r.Lib 'F9: and no lib was loaded'

    # F10. An empty install registry and a broken one behave like a missing one.
    $c = New-ForwarderCase -Name 'brokenreg'
    $viaClone = New-FixturePayload -Root (Join-Path $c.Plugins "marketplaces\$marketplace\plugins\$pluginName") -Version '7.0.0' -WithLib
    [System.IO.File]::WriteAllText($c.Registry, '{ not json', $Utf8NoBom)
    $r = Invoke-ForwarderProbe -Case $c
    Assert-Equal (Get-LibIn $viaClone) $r.Lib 'F10: an unreadable registry falls through to the clone instead of failing'
} finally {
    if ($null -eq $prevPluginRoot) {
        Remove-Item Env:CLAUDE_PLUGIN_ROOT -ErrorAction SilentlyContinue
    } else {
        $env:CLAUDE_PLUGIN_ROOT = $prevPluginRoot
    }
    Remove-Item -LiteralPath $fx -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
$fixtureBroken = Write-FixtureGitSummary -Subject 'the plugin-payload locator'
Write-Host "Result: $script:pass pass, $script:fail fail." -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0 -or $fixtureBroken) { exit 1 }
exit 0
