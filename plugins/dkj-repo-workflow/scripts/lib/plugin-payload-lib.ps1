<#
.SYNOPSIS
    The ONE locator for a plugin's payload on this machine: where is dkj-repo-workflow (or any other
    plugin of the marketplace) installed, and which script inside it do I run.

.DESCRIPTION
    Dot-source it, from a plugin script by its own directory, or from a consumer repo through the
    forwarder (plugins/dkj-repo-workflow/templates/plugin-scripts-forwarder.ps1):

        . (Join-Path $PSScriptRoot 'plugin-payload-lib.ps1')
        $newBranch = Resolve-PluginScript -RelativePath 'scripts\task\new-branch.ps1'

    WHY THIS EXISTS. Two consumer repos each carried their own scripts/lib/plugin-scripts.ps1 -- the same
    locator, diverged, with the plugin names hard-coded in each. Every plugin rename was therefore a code
    change in each private copy, and the copies had already drifted: one had the worktree rule and the
    path normalisation, the other had the resolution report. A locator that exists to stop path-guessing
    copies had become path-guessing copies. It now has one source, here, and a consumer's
    plugin-scripts.ps1 is a few-line forwarder that finds this file and dot-sources it, so a rename is
    one table edit (Get-PluginPriorNames) that reaches every consumer with the plugin release.

    THE SAME FUNCTION AND PARAMETER NAMES AS THE CONSUMER COPIES, ON PURPOSE (Get-PluginsHome,
    Get-PluginNameCandidates, Get-PluginRoot, Resolve-PluginScript, Get-PluginProjectRegistration,
    Get-PluginResolution; -Plugin -Marketplace -RepoRoot -PluginsRoot -RelativePath). A consumer's call
    sites, and the allow-list line in its settings.json that runs
    `. ./scripts/lib/plugin-scripts.ps1; & (Resolve-PluginScript -RelativePath ...)`, keep working
    unchanged.

    RESOLUTION ORDER, UNCHANGED FROM THE CONSUMER COPIES, and it is the whole point of Get-PluginRoot:

      1. $env:CLAUDE_PLUGIN_ROOT, when a running hook or skill of THIS plugin handed it over;
      2. the install registry (installed_plugins.json): the version-bound cache this checkout loaded;
      3. the marketplace clone, through the family folders. The last resort.

    ALL NAMES PER STEP, NOT ALL STEPS PER NAME. A renamed plugin is looked for under its current id and
    its retired ids at step 1, then again at step 2, then at step 3 -- never the whole three steps for the
    new name before the old name is tried at all. The latter lets the CLONE of the new name beat the
    INSTALL CACHE of the old one, which is exactly the machine the retired ids exist for (registry still
    on the old id, clone already updated), and silently runs a version other than the one the checkout
    loaded.

    ONE PRIOR-NAME TABLE, AND THIS IS ITS ONLY COPY (Get-PluginPriorNames: current id -> its retired ids,
    newest first). scripts/lib/claude-md-import-lib.ps1 already stated part of this history as a flat
    retired-to-current map (Get-RetiredPolicyExtensionNames, for the extensions and the workflow plugin).
    Two statements of one fact drift, so that map no longer states anything: it is DERIVED from this table
    (retired names whose current id is the workflow plugin or one of its extensions), and the table here
    is the single source because it is the richer one -- it also carries the team-plugin chain and the
    oldest workflow names, which the import lib never needed. A rename is an edit to this table and
    nowhere else.

    DEPENDENCY-FREE, like plugin-tree-lib and source-repo-guard-lib, and for the same reason: it is
    dot-sourced first thing, before anything has resolved where anything is, so it can rely on nothing
    being loaded. It also sets no script-scope variable and no strict mode, so loading it (including
    inside a function, as the import lib does to read the table) defines functions and nothing else.

    WHAT IS NOT HERE, DELIBERATELY: the loader-backed verdict some consumer copies of Get-PluginResolution
    carried (LoaderBacked / LoaderNote). It reads a consumer-local plugin-floor.ps1 -- a file this plugin
    does not ship -- so a fields-and-note answer here would either be always empty or would drag that file
    in. Get-PluginResolution reports where the bytes are (Path, Source, Version); whether the running
    Claude Code loads a clone-only plugin is a question for a check that owns the loader version.

    THE REPO ROOT. The consumer copies derived the default -RepoRoot from their own location
    (`$PSScriptRoot\..\..`), which is only right while the file sits in the consumer's scripts/lib. This
    file does not, so the default is: $script:PluginPayloadRepoRoot when the caller set it (the forwarder
    does, from ITS location, so call sites stay unchanged), else the repo containing the current
    directory, else the current directory.

    No absolute paths anywhere: a machine has its own user profile, so everything goes through
    $env:USERPROFILE (or $HOME) unless -PluginsRoot overrides it, which is how the test suite runs the
    whole lookup on a fixture and never reads the real ~/.claude.

    No Set-StrictMode here: dot-sourcing would change the strict mode of the calling script. Dotted reads
    of registry entry fields go through Get-PluginEntryValue for the same reason in the other direction:
    this file cannot know whether its caller is strict, and an entry of scope 'user' has no projectPath.
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.
#>

function Get-PluginPriorNames {
    <#
        The prior-name table: each plugin's CURRENT id mapped to the ids it was called before, NEWEST
        FIRST. With -Plugin, just that plugin's retired ids (an empty array for a plugin with no history).

        THE ONLY COPY of this history (see the file header). The order inside an entry is load-bearing:
        the current id is always tried first by Get-PluginNameCandidates, then the newest predecessor,
        so a machine holding both a fresh and a stale record cannot silently run the stale one. A
        predecessor is only ever tried after the current id was looked for at the SAME step.

        The rows, with the release that retired each id:
          dkj-repo-workflow       <- dkj-policy (7.0.0, #4209) <- contributing-davekjohn <- workflow-davekjohn
          dkj-repo-workflow-bwj   <- bwj-development (7.0.0, #4209) <- dkj-policy-bwj (#2788) <- bwj-codex
          dkj-repo-workflow-dkj   <- dkj-solutions (7.0.0, #4209) <- dkj-policy-dkjs (#2788)
          dkj-subagents-<team>    <- dkj-team-<team> (#1698) <- team-<team>, for alpha, shopify, ecomm
                                     and lifehub

        Returned as a fresh ordered table on every call, so a caller cannot mutate the source.
    #>
    param([string]$Plugin = '')

    $table = [ordered]@{
        'dkj-repo-workflow'     = @('dkj-policy', 'contributing-davekjohn', 'workflow-davekjohn')
        'dkj-repo-workflow-bwj' = @('bwj-development', 'dkj-policy-bwj', 'bwj-codex')
        'dkj-repo-workflow-dkj' = @('dkj-solutions', 'dkj-policy-dkjs')
        'dkj-subagents-alpha'   = @('dkj-team-alpha', 'team-alpha')
        'dkj-subagents-shopify' = @('dkj-team-shopify', 'team-shopify')
        'dkj-subagents-ecomm'   = @('dkj-team-ecomm', 'team-ecomm')
        'dkj-subagents-lifehub' = @('dkj-team-lifehub', 'team-lifehub')
    }
    if (-not $Plugin) { return $table }
    if ($table.Contains($Plugin)) { return [string[]]@($table[$Plugin]) }
    return [string[]]@()
}

function Get-PluginFamilyPaths {
    <#
        The folders INSIDE the marketplace clone that hold plugin folders, in the order they are tried.
        The source repo keeps its plugins in family folders, so the clone has a layer the install cache
        does not. The kept order is: today's layout first ('plugins', the team family
        'plugins\dkj-subagents', the extensions nested INSIDE the workflow plugin), then the layouts
        earlier releases used -- a clone that has not pulled past a rename still has them, and a missing
        folder is one more Test-Path miss, never a wrong answer. No two families hold a folder of the same
        name, so first match wins safely.
    #>
    return @('plugins', 'plugins\dkj-subagents', 'plugins\dkj-repo-workflow\extensions',
             'plugins\dkj-policy', 'plugins\dkj-teams', 'plugins\workflows', 'plugins\teams')
}

function Get-PluginsHome {
    <# This user's .claude/plugins folder. -PluginsRoot overrides it, so the test suite can run the whole
       lookup against a fixture. #>
    param([string]$PluginsRoot = '')
    if ($PluginsRoot) { return $PluginsRoot }
    $profileDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
    return (Join-Path $profileDir '.claude\plugins')
}

function Get-PluginDefaultRepoRoot {
    <#
        The repo root a lookup defaults to when the caller passed none (see the file header, THE REPO
        ROOT): the forwarder's answer when it set one, else the repo containing the current directory
        (asked through --show-cdup, which names no file and so cannot be corrupted by a code page), else
        the current directory itself.
    #>
    # Get-Variable and not a bare read: an unset variable THROWS under a strict caller, and this file
    # cannot know whether it was loaded by one.
    $set = Get-Variable -Scope Script -Name PluginPayloadRepoRoot -ErrorAction SilentlyContinue
    if ($set -and $set.Value) { return [string]$set.Value }
    $here = (Get-Location).ProviderPath
    try {
        $inside = & git -C $here rev-parse --is-inside-work-tree 2>$null
        if ($LASTEXITCODE -eq 0 -and "$inside".Trim() -eq 'true') {
            $cdup = & git -C $here rev-parse --show-cdup 2>$null
            if ($LASTEXITCODE -eq 0) {
                $up = "$cdup".Trim()
                if (-not $up) { return $here }
                return (Resolve-Path -LiteralPath (Join-Path $here $up)).ProviderPath
            }
        }
    } catch { }
    return $here
}

function ConvertTo-PluginComparablePath {
    <#
        A path in the form two paths may be COMPARED in: '/' made equal to '\' and the trailing separator
        dropped. No Resolve-Path -- the registry carries paths of folders that need not exist, and that is
        exactly the state worth being able to name. -eq on strings is already case-insensitive in
        PowerShell, which is the right answer on Windows.

        ONE FUNCTION BECAUSE TWO COMPARISONS DRIFT: the lookup once trimmed only the trailing slash while
        the registration check also converted slashes, so a projectPath written with forward slashes
        matched in the check and not in the lookup, and the check said 'ok' about a different install
        than the one the lookup returned. Same fact, two statements.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][AllowNull()][string]$Path)
    if (-not $Path) { return '' }
    return ($Path -replace '/', '\').TrimEnd('\')
}

function Get-PluginProjectPathCandidates {
    <#
        The projectPaths (in comparable form) under which the registry may name THIS checkout, in order of
        preference: the repo root itself first, and -- only when that root is a LINKED WORKTREE -- the main
        checkout it belongs to.

        WHY THE MAIN CHECKOUT COUNTS. A project-scoped install writes ONE projectPath, and a worktree is
        not a second project but a second working copy of the same repository. Without this candidate a
        worktree refused a correct branch only because of where it was checked out.

        WHAT IS NOT WIDENED. An arbitrary other path is no match, and neither is a worktree of a
        DIFFERENT repository: the main checkout comes from `git rev-parse --git-common-dir` of this root,
        never from a name comparison. No git, or a root that is no repo, leaves only the root itself.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$RepoRoot)

    $wants = New-Object System.Collections.Generic.List[string]
    $self  = ConvertTo-PluginComparablePath -Path $RepoRoot
    if (-not $self) { return @() }
    $wants.Add($self)

    if (Test-Path -LiteralPath $RepoRoot -PathType Container) {
        $common = $null
        try {
            $common = & git -C $RepoRoot rev-parse --path-format=absolute --git-common-dir 2>$null
            if ($LASTEXITCODE -ne 0) { $common = $null }
        } catch { $common = $null }
        if ($common) {
            $common = ConvertTo-PluginComparablePath -Path ([string]$common).Trim()
            # Only the standard '<main>\.git' shape yields a main checkout; a bare repo or a loose GIT_DIR
            # has none, and then there is nothing to widen.
            if ((Split-Path -Leaf $common) -eq '.git') {
                $main = ConvertTo-PluginComparablePath -Path (Split-Path -Parent $common)
                if ($main -and $main -ne $self) { $wants.Add($main) }
            }
        }
    }
    return @($wants.ToArray())
}

function Get-PluginEntryValue {
    <#
        One field of a registry entry, or '' when the entry does not carry it. Read through
        PSObject.Properties and never as a dotted property, because a dotted read of an absent property
        yields $null for a lax caller and THROWS for a strict one, and this file cannot know which it was
        loaded by. installed_plugins.json has two entry shapes -- scope 'project' carries a projectPath,
        scope 'user' does not carry one at all -- so absent fields are the ordinary case, not a corrupt
        one.
    #>
    param([AllowNull()]$Entry, [Parameter(Mandatory = $true)][string]$Name)
    if (-not $Entry) { return '' }
    $prop = $Entry.PSObject.Properties[$Name]
    if (-not $prop -or -not $prop.Value) { return '' }
    return [string]$prop.Value
}

function Get-PluginEntryProjectPath {
    <# The projectPath of a registry entry, or '' when the entry carries none (a machine-wide install). #>
    param([Parameter(Mandatory = $true)][AllowNull()]$Entry)
    return (Get-PluginEntryValue -Entry $Entry -Name 'projectPath')
}

function Get-PluginRegistryEntries {
    <#
        The entries of installed_plugins.json for <plugin>@<marketplace>, plus why there are none. Returns
        an object with Status ('ok' | 'no-registry' | 'unreadable-registry' | 'no-key') and Entries.

        ONE READ PATH FOR TWO QUESTIONS: Get-PluginInstallPathFromRegistry asks 'which path do I run?' and
        Get-PluginProjectRegistration asks 'is it attached to THIS project?'. When each read and parsed the
        registry itself, their key lookup and entry filter diverged, and that divergence was the finding.

        It does NOT filter on installPath: one caller needs a path and filters itself, the other must see
        an entry with an EMPTY installPath, because 'registered with a broken cache' is a different repair
        from 'never registered'.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$PluginsHome,
        [Parameter(Mandatory = $true)][string]$Plugin,
        [Parameter(Mandatory = $true)][string]$Marketplace
    )

    $result = [pscustomobject]@{ Status = 'no-registry'; Entries = @() }

    $registry = Join-Path $PluginsHome 'installed_plugins.json'
    if (-not (Test-Path -LiteralPath $registry -PathType Leaf)) { return $result }

    try {
        $data = Get-Content -LiteralPath $registry -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        $result.Status = 'unreadable-registry'
        return $result
    }
    if (-not $data -or -not $data.plugins) {
        $result.Status = 'unreadable-registry'
        return $result
    }

    # ConvertFrom-Json yields a PSCustomObject, not a hashtable (PS 5.1 has no -AsHashtable), and the key
    # contains an '@' -- so via PSObject.Properties rather than dot access.
    $key  = "$Plugin@$Marketplace"
    $prop = $data.plugins.PSObject.Properties | Where-Object { $_.Name -eq $key }
    if (-not $prop) {
        $result.Status = 'no-key'
        return $result
    }

    $result.Status  = 'ok'
    $result.Entries = @($prop.Value | Where-Object { $_ })
    return $result
}

function Get-PluginInstallPathFromRegistry {
    <# The installPath from installed_plugins.json for this plugin: the entry of THIS project (the root
       itself, then a worktree's main checkout) wins; with none, the highest version that really exists on
       disk. $null on a missing or unreadable registry -- the caller then goes to the clone. #>
    param(
        [Parameter(Mandatory = $true)][string]$PluginsHome,
        [Parameter(Mandatory = $true)][string]$Plugin,
        [Parameter(Mandatory = $true)][string]$Marketplace,
        [string]$RepoRoot = ''
    )

    $read = Get-PluginRegistryEntries -PluginsHome $PluginsHome -Plugin $Plugin -Marketplace $Marketplace
    if ($read.Status -ne 'ok') { return $null }

    $entries = @($read.Entries | Where-Object { Get-PluginEntryValue -Entry $_ -Name 'installPath' })
    if ($entries.Count -eq 0) { return $null }

    if ($RepoRoot) {
        # THE SAME COMPARISON as Get-PluginProjectRegistration, candidates included -- see
        # ConvertTo-PluginComparablePath for what happens when the two differ.
        foreach ($want in @(Get-PluginProjectPathCandidates -RepoRoot $RepoRoot)) {
            foreach ($e in $entries) {
                $projectPath = Get-PluginEntryProjectPath -Entry $e
                if ($projectPath -and (ConvertTo-PluginComparablePath -Path $projectPath) -eq $want) {
                    $installPath = Get-PluginEntryValue -Entry $e -Name 'installPath'
                    if (Test-Path -LiteralPath $installPath -PathType Container) { return $installPath }
                }
            }
        }
    }

    # No entry for this project (or its installPath is gone): the highest version that really exists.
    $sorted = $entries | Sort-Object -Property @{ Expression = {
        $v = $null
        if ([version]::TryParse((Get-PluginEntryValue -Entry $_ -Name 'version'), [ref]$v)) { $v } else { [version]'0.0.0' }
    } } -Descending
    foreach ($e in $sorted) {
        $installPath = Get-PluginEntryValue -Entry $e -Name 'installPath'
        if (Test-Path -LiteralPath $installPath -PathType Container) { return $installPath }
    }
    return $null
}

function Get-PluginNameCandidates {
    <# The plugin names to try, in order: the id asked for, then the ids IT was called before (from
       Get-PluginPriorNames). An id that has no history is not widened -- a -Plugin is a statement, and
       the table names per plugin only its own past. #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Plugin)
    return @(@($Plugin) + @(Get-PluginPriorNames -Plugin $Plugin))
}

function Get-PluginRoot {
    <#
        The folder holding the plugin's content (agents/, scripts/, skills/, ...), or $null when the plugin
        is nowhere. Order: CLAUDE_PLUGIN_ROOT of a running call from this plugin, then the registry (the
        version THIS checkout loaded), then the marketplace clone. ALL NAMES PER STEP, NOT ALL STEPS PER
        NAME -- see the file header for why that is the whole reason this function looks like it does.
    #>
    param(
        [string]$Plugin = 'dkj-repo-workflow',
        [string]$Marketplace = 'dkj-marketplace',
        [string]$RepoRoot = '',
        [string]$PluginsRoot = ''
    )

    if (-not $RepoRoot) { $RepoRoot = Get-PluginDefaultRepoRoot }
    $pluginsHome = Get-PluginsHome -PluginsRoot $PluginsRoot
    $candidates  = @(Get-PluginNameCandidates -Plugin $Plugin)

    # 1. Inside a hook or skill OF THIS PLUGIN the path is already known. The name check is not a
    #    formality: several plugins of one marketplace are enabled at once, and a hook of another plugin
    #    sets CLAUDE_PLUGIN_ROOT to ITS OWN folder, which has no scripts/ of ours.
    #
    #    TWO SHAPES, because the two locations are layered differently. In the install cache the path ends
    #    in the VERSION (...\dkj-repo-workflow\7.0.0), so the PARENT carries the plugin name; in the
    #    marketplace clone it ends in the plugin name itself. Testing only the parent lets the clone shape
    #    through the mesh: a hook running from the clone fell silently to step 2 or 3 -- no error, the
    #    wrong version.
    if ($env:CLAUDE_PLUGIN_ROOT -and (Test-Path -LiteralPath $env:CLAUDE_PLUGIN_ROOT -PathType Container)) {
        $self   = Split-Path $env:CLAUDE_PLUGIN_ROOT -Leaf
        $parent = Split-Path (Split-Path $env:CLAUDE_PLUGIN_ROOT -Parent) -Leaf
        foreach ($name in $candidates) {
            if ($self -eq $name -or $parent -eq $name) { return $env:CLAUDE_PLUGIN_ROOT }
        }
    }

    # 2. The version this checkout actually loaded.
    foreach ($name in $candidates) {
        $fromRegistry = Get-PluginInstallPathFromRegistry -PluginsHome $pluginsHome -Plugin $name `
            -Marketplace $Marketplace -RepoRoot $RepoRoot
        if ($fromRegistry) { return $fromRegistry }
    }

    # 3. Last resort: the marketplace clone. It may sit at another commit than the loaded version, which
    #    is why it comes last and not earlier.
    $marketRoot = Join-Path (Join-Path $pluginsHome 'marketplaces') $Marketplace
    foreach ($name in $candidates) {
        foreach ($family in @(Get-PluginFamilyPaths)) {
            $clone = Join-Path $marketRoot (Join-Path $family $name)
            if (Test-Path -LiteralPath $clone -PathType Container) { return $clone }
        }
    }

    return $null
}

function Get-PluginProjectRegistration {
    <#
        Is this plugin attached to THIS project in the registry? Returns an object with:

          Registered     $true only when an entry for <plugin>@<marketplace> carries a projectPath EQUAL
                         to this repo root -- or, for a linked worktree, to its main checkout -- and an
                         installPath that really exists;
          MatchedProject the projectPath that matched (comparable form), or '';
          InstallPath    that installPath, or '';
          Reason         'ok' | 'no-registry' | 'unreadable-registry' | 'no-key' | 'no-project-entry' |
                         'installpath-missing';
          KnownPaths     the projectPaths that ARE registered, so a mismatch names itself.

        WHY THIS STANDS BESIDE Get-PluginRoot AND IS NOT PART OF IT. Get-PluginRoot must keep working: it
        falls back to the highest version, then to the clone, because a script that finds nothing can do
        nothing. That fallback is right, and it is exactly why it cannot answer 'did the harness load this
        plugin for THIS project?' -- it returns a path either way. This function asks that second question
        and answers NO where Get-PluginRoot answers with a path.

        A PROXY AND NOT DIRECT PROOF: the harness cannot be queried from a script, so what is measured is
        whether the administration it loads from names this repo. A registered plugin the harness fails to
        load for another reason stays invisible; a path mismatch (a registry naming a folder that does not
        exist, beside one that does) is caught. KnownPaths is not a luxury for that reason: the two paths
        look alike, and the fault is only visible side by side.

        The read, the entry's projectPath and the path comparison are shared with
        Get-PluginInstallPathFromRegistry, and so is the name fallback (Get-PluginNameCandidates).
    #>
    param(
        [string]$Plugin = 'dkj-repo-workflow',
        [string]$Marketplace = 'dkj-marketplace',
        [string]$RepoRoot = '',
        [string]$PluginsRoot = ''
    )

    if (-not $RepoRoot) { $RepoRoot = Get-PluginDefaultRepoRoot }
    $pluginsHome = Get-PluginsHome -PluginsRoot $PluginsRoot
    $candidates  = @(Get-PluginNameCandidates -Plugin $Plugin)
    $wants       = @(Get-PluginProjectPathCandidates -RepoRoot $RepoRoot)
    $self        = ConvertTo-PluginComparablePath -Path $RepoRoot

    $result = [pscustomobject]@{
        Registered     = $false
        InstallPath    = ''
        Reason         = 'no-registry'
        KnownPaths     = @()
        MatchedProject = ''
    }

    $known       = New-Object System.Collections.Generic.List[string]
    $live        = @{}   # comparable projectPath -> first live installPath
    $dead        = @{}   # comparable projectPath -> an entry exists, but with no live cache
    $sawRegistry = $false
    $sawKey      = $false

    foreach ($name in $candidates) {
        $read = Get-PluginRegistryEntries -PluginsHome $pluginsHome -Plugin $name -Marketplace $Marketplace
        if ($read.Status -eq 'unreadable-registry') {
            $result.Reason = 'unreadable-registry'
            return $result
        }
        if ($read.Status -eq 'no-registry') { continue }
        $sawRegistry = $true
        if ($read.Status -eq 'no-key') { continue }
        $sawKey = $true

        # ONE pass, and entries WITHOUT an installPath count: filtering them as the lookup does would hide
        # an entry that names this project with an empty cache, and 'registered, cache broken' would read
        # as 'never registered' -- two different repairs. Entries are collected first and laid against the
        # candidates afterwards, so the root's own entry always beats the main checkout's, whatever order
        # the registry carries them in.
        foreach ($e in $read.Entries) {
            $projectPath = Get-PluginEntryProjectPath -Entry $e
            if (-not $projectPath) { continue }
            $known.Add($projectPath)
            $cmp = ConvertTo-PluginComparablePath -Path $projectPath
            if ($live.ContainsKey($cmp)) { continue }
            $installPath = Get-PluginEntryValue -Entry $e -Name 'installPath'
            if ($installPath -and (Test-Path -LiteralPath $installPath -PathType Container)) {
                $live[$cmp] = $installPath
            } else {
                $dead[$cmp] = $true
            }
        }
    }

    $result.KnownPaths = @($known.ToArray())
    foreach ($want in $wants) {
        if ($live.ContainsKey($want)) {
            $result.Registered     = $true
            $result.InstallPath    = $live[$want]
            $result.Reason         = 'ok'
            $result.MatchedProject = $want
            return $result
        }
    }
    # A dead cache counts only for the root itself: the main checkout's is a repair THERE, and a worktree
    # that lacks it reads more honestly as 'no entry for this project'.
    $lastBad = if ($self -and $dead.ContainsKey($self)) { 'installpath-missing' } else { '' }

    # The order is the repair that follows, specific to general.
    if ($lastBad) { $result.Reason = $lastBad }
    elseif (-not $sawRegistry) { $result.Reason = 'no-registry' }
    elseif (-not $sawKey) { $result.Reason = 'no-key' }
    else { $result.Reason = 'no-project-entry' }
    return $result
}

function Resolve-PluginScript {
    <# The full path to a script IN the plugin, e.g. 'scripts\task\new-branch.ps1'. Throws an actionable
       message when the plugin or the script is absent -- a bare $null would turn into an unreadable
       "cannot find path" further along, which is what this lib exists against. #>
    param(
        # AllowEmptyString: without it parameter binding cuts an empty string off with its own "Cannot
        # bind argument" message and the explanation below is unreachable.
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$RelativePath,
        [string]$Plugin = 'dkj-repo-workflow',
        [string]$Marketplace = 'dkj-marketplace',
        [string]$RepoRoot = '',
        [string]$PluginsRoot = ''
    )

    if ([string]::IsNullOrWhiteSpace($RelativePath)) {
        throw 'Resolve-PluginScript: -RelativePath must not be empty.'
    }

    $root = Get-PluginRoot -Plugin $Plugin -Marketplace $Marketplace -RepoRoot $RepoRoot -PluginsRoot $PluginsRoot
    if (-not $root) {
        throw ("The plugin '$Plugin@$Marketplace' was not found, so '$RelativePath' cannot be run. Is the " +
            "plugin enabled? Check enabledPlugins in .claude/settings.json and run " +
            "'claude plugin marketplace update $Marketplace'; a freshly updated plugin only loads after " +
            "Claude Code restarts.")
    }

    $full = Join-Path $root $RelativePath
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        throw ("'$RelativePath' does not exist in the plugin '$Plugin@$Marketplace' (looked in: $root). " +
            "If the script was renamed or moved there, that change belongs in the source repo -- not in " +
            "a copy here. If it is NEWER than what resolved here, that path is what this checkout runs, so " +
            "update the plugin first: 'claude plugin marketplace update $Marketplace' for a clone, " +
            "'claude plugin install' for a registered one (the version-bound cache). " +
            "Get-PluginResolution says which of the two answered, and at what version.")
    }
    return $full
}

function Get-PluginResolution {
    <#
        WHICH copy answered, and at what version -- the diagnostic that replaced a promise. A lookup used
        to assert in prose that it runs 'the version this checkout loaded'; for a plugin that is not
        registered that sentence has no mechanism behind it, and nothing could tell that the shared clone
        had moved under it. What IS knowable is which step produced the answer, so it is reported rather
        than assumed.

        Returns $null when the plugin is nowhere, so a caller can report absence without catching.
        Otherwise an object with:

          Plugin, Marketplace  as asked;
          Path                 the folder Get-PluginRoot returned;
          Source               'marketplace-clone' | 'install-cache' | 'plugin-root-env' | 'unknown';
          Version              read from the copy's own .claude-plugin\plugin.json -- the copy's claim
                               about itself, never a number typed in a doc -- or $null when unreadable.

        THE SOURCE IS READ OFF THE RESOLVED PATH, not tracked through the steps, so it cannot drift from
        what Get-PluginRoot returned: 'marketplaces' and 'cache' are the two folder names Claude Code uses
        under .claude/plugins, and anything else is a CLAUDE_PLUGIN_ROOT handed over by a running hook.

        NO LoaderBacked / LoaderNote FIELDS. Some consumer copies carried them, computed from a
        consumer-local plugin-floor.ps1 that this plugin does not ship. See the file header: Path and
        Source say where the BYTES are; they must not be read as 'the plugin is loaded'.
    #>
    param(
        [string]$Plugin = 'dkj-repo-workflow',
        [string]$Marketplace = 'dkj-marketplace',
        [string]$RepoRoot = '',
        [string]$PluginsRoot = ''
    )

    $root = Get-PluginRoot -Plugin $Plugin -Marketplace $Marketplace -RepoRoot $RepoRoot -PluginsRoot $PluginsRoot
    if (-not $root) { return $null }

    $normalised = ($root -replace '/', '\')
    $source =
        if ($normalised -match '\\marketplaces\\')            { 'marketplace-clone' }
        elseif ($normalised -match '\\cache\\')               { 'install-cache' }
        elseif ($env:CLAUDE_PLUGIN_ROOT -and
                ($normalised -eq ($env:CLAUDE_PLUGIN_ROOT -replace '/', '\'))) { 'plugin-root-env' }
        else                                                  { 'unknown' }

    $version = $null
    $manifest = Join-Path $root '.claude-plugin\plugin.json'
    if (Test-Path -LiteralPath $manifest -PathType Leaf) {
        try {
            $version = (Get-Content -LiteralPath $manifest -Raw -Encoding UTF8 | ConvertFrom-Json).version
        } catch {
            $version = $null   # a manifest we cannot parse is a missing version, not a failed lookup
        }
    }

    return [pscustomobject]@{
        Plugin      = $Plugin
        Marketplace = $Marketplace
        Path        = $root
        Source      = $source
        Version     = $version
    }
}
