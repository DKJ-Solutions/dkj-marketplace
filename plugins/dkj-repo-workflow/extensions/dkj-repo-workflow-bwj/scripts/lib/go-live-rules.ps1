<#
.SYNOPSIS
    The decisions go-live.ps1 makes, without a network: which steps run in which order, what the app-deploy
    switch on the line means, how the required checks read, which files the live theme is verified on, how a
    pulled file is compared, and how a skipped app deploy is written into the live-push record.

.DESCRIPTION
    WHY A LIB (#4402). go-live reaches git, gh, the Shopify CLI and a real store at every step, and a suite
    must not be able to reach a store. So everything that can be judged from data alone is here, and
    scripts/tests/bwj-go-live.tests.ps1 asserts it; the script itself only runs commands and reads this.

    Dependency-free and no strict mode, like the other rules libs of this extension: dot-sourcing it defines
    functions and nothing else. Pure ASCII (repo convention for .ps1).
#>

function Get-GoLiveSteps {
    <# The steps, in the order they run. -ResumeFrom names one of the last four. #>
    return @('preflight', 'promote', 'checks', 'merge', 'verify', 'app', 'cut', 'notify')
}

function Get-GoLiveResumeSteps {
    <# The steps a run may resume from: each one after the merge, the point past which nothing re-runs. #>
    return @('verify', 'app', 'cut', 'notify')
}

function Test-GoLiveVersion {
    <# X.Y.Z of ASCII digits, an optional leading 'v'. [0-9], not \d: .NET's \d is every Unicode digit. #>
    param([AllowEmptyString()][string]$Version)
    return ([string]$Version).Trim() -cmatch '\Av?[0-9]+\.[0-9]+\.[0-9]+\z'
}

function Get-GoLiveAppDecision {
    <#
        What the app-deploy switch on the go-live line means. The owner's decision on #4402: the app deploy
        rides inside the one go-live word as a REQUIRED switch on that same line, so the line says, visibly,
        whether a new app version is released. Returns { Ok; Mode = 'deploy' | 'hold' | 'none'; Message }.

          both switches                      refused -- the line contradicts itself;
          an app root, neither switch        refused -- the choice is the owner's and has to be on the line;
          an app root, -AppDeploy            deploy;
          an app root, -SkipAppDeploy        hold -- the record's app lines become 'hold';
          no app root, -AppDeploy            refused -- there is no app to deploy;
          no app root, otherwise             none.

        -AppChanged false (the range touched no file under the app root) turns deploy and hold into none:
        there is nothing to release and nothing to hold, and the run says so rather than refusing.
    #>
    param(
        [AllowEmptyString()][string]$AppRoot = '',
        [switch]$AppDeploy,
        [switch]$SkipAppDeploy,
        [bool]$AppChanged = $true
    )
    $root = ([string]$AppRoot).Trim()
    if ($AppDeploy -and $SkipAppDeploy) {
        return [pscustomobject]@{ Ok = $false; Mode = ''; Message = 'the line carries both -AppDeploy and -SkipAppDeploy. Keep the one you mean.' }
    }
    if (-not $root) {
        if ($AppDeploy) {
            return [pscustomobject]@{ Ok = $false; Mode = ''; Message = 'the line asks for -AppDeploy, but this repo answers no Get-ShopifyAppRoot, so there is no app to deploy. Drop the switch.' }
        }
        return [pscustomobject]@{ Ok = $true; Mode = 'none'; Message = 'this repo ships no app (Get-ShopifyAppRoot is unanswered).' }
    }
    if (-not $AppDeploy -and -not $SkipAppDeploy) {
        return [pscustomobject]@{ Ok = $false; Mode = ''; Message = "this repo ships an app under '$root', so the go-live line has to say whether its deploy runs: add -AppDeploy or -SkipAppDeploy." }
    }
    if (-not $AppChanged) {
        return [pscustomobject]@{ Ok = $true; Mode = 'none'; Message = "the release changes no file under '$root', so there is no app deploy to run or hold." }
    }
    if ($AppDeploy) {
        return [pscustomobject]@{ Ok = $true; Mode = 'deploy'; Message = "the app under '$root' is deployed after the live theme is verified." }
    }
    return [pscustomobject]@{ Ok = $true; Mode = 'hold'; Message = "the app deploy is skipped: its files are written as 'hold' in the live-push record, so the cut and notify-live treat them as not live." }
}

function Get-GoLiveRequiredContexts {
    <#
        The status-check contexts the deploy branch requires, from 'gh api repos/{owner}/{repo}/rules/branches/<b>'
        (every active ruleset rule on the branch). $null when the answer cannot be read -- which a caller must
        not read as "none required".
    #>
    param([AllowEmptyString()][string]$RulesJson)
    # Windows PowerShell 5.1's ConvertFrom-Json hands a JSON array back as ONE object, so @() around it
    # holds one element; 'foreach' over the parsed value enumerates the rules themselves.
    try { $parsed = ConvertFrom-Json -InputObject ([string]$RulesJson) } catch { return $null }
    $rules = @(foreach ($x in $parsed) { $x })
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($r in $rules) {
        if ($null -eq $r -or [string]$r.type -ne 'required_status_checks') { continue }
        foreach ($c in @($r.parameters.required_status_checks)) {
            $ctx = ([string]$c.context).Trim()
            if ($ctx -and -not $out.Contains($ctx)) { $out.Add($ctx) }
        }
    }
    return , [string[]]@($out)
}

function Get-GoLiveCheckState {
    <#
        One state for the required checks, from 'gh pr checks --required --json name,bucket': 'fail' when any
        check failed or was cancelled, 'pending' while any is still running, 'pass' when every one passed or
        was skipped, 'none' when there are none. A bucket this does not know reads as pending, so an unknown
        state is waited on rather than merged over.

        -Required names the contexts the deploy branch's rules require. 'gh pr checks' lists only checks that
        have REPORTED, so a required one that has not started yet is absent rather than pending (Victor's
        review of #4402): each required context missing from -Checks reads as pending, never as 'none'.
    #>
    param(
        [AllowNull()][AllowEmptyCollection()][object[]]$Checks = @(),
        [AllowNull()][AllowEmptyCollection()][string[]]$Required = @()
    )
    $all = @(@($Checks) | Where-Object { $null -ne $_ })
    $names = @($all | ForEach-Object { ([string]$_.name).Trim().ToLower() })
    foreach ($ctx in @($Required)) {
        if ($ctx -and ($names -notcontains ([string]$ctx).Trim().ToLower())) { return 'pending' }
    }
    if ($all.Count -eq 0) { return 'none' }
    $buckets = @($all | ForEach-Object { ([string]$_.bucket).Trim().ToLower() })
    if (@($buckets | Where-Object { $_ -in @('fail', 'cancel') }).Count -gt 0) { return 'fail' }
    if (@($buckets | Where-Object { $_ -notin @('pass', 'skipping') }).Count -gt 0) { return 'pending' }
    return 'pass'
}

function Test-GoLiveUnderAppRoot {
    param([string]$Path, [AllowEmptyString()][string]$AppRoot)
    $root = (([string]$AppRoot).Trim() -replace '\\', '/').TrimEnd('/')
    if (-not $root) { return $false }
    $p = ([string]$Path).Trim() -replace '\\', '/'
    return $p.StartsWith("$root/", [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-GoLiveVerifyPaths {
    <#
        The paths the live theme is verified on: every 'live' line of the record that is not under the app
        root. An app file is on no theme, and a 'hold' file is by definition not what the trunk holds.
    #>
    param(
        [AllowNull()][AllowEmptyCollection()][string[]]$Live = @(),
        [AllowEmptyString()][string]$AppRoot = ''
    )
    return @(@($Live) | Where-Object { $_ -and -not (Test-GoLiveUnderAppRoot -Path $_ -AppRoot $AppRoot) })
}

function Test-GoLiveGlobPath {
    <# A path 'theme pull --only' would read as a glob, not literally ('templates/product.[handle].json'). #>
    param([string]$Path)
    return ([string]$Path) -match '[\[\]{}*?!]'
}

function Split-GoLiveChunks {
    <#
        The verify paths in groups of -Size, one 'theme pull' each: one '--only' per path, and a few hundred
        of them overrun the Windows command line through the shopify.cmd shim (Victor's review of #4402).
    #>
    # Each chunk is an object with a Paths array: a bare string[] per chunk is flattened by @() in the
    # caller whenever there is only one, and the pull would then run once per path.
    param([AllowNull()][AllowEmptyCollection()][string[]]$Paths = @(), [int]$Size = 40)
    $all = @(@($Paths) | Where-Object { $_ })
    for ($i = 0; $i -lt $all.Count; $i += $Size) {
        [pscustomobject]@{ Paths = [string[]]@($all[$i..([Math]::Min($i + $Size, $all.Count) - 1)]) }
    }
}

function Compare-GoLiveTheme {
    <#
        The paths where the live theme does not yet hold what the promoted commit holds. -Expected and
        -Actual map a path to a git blob id, and '' means absent: a file the range deletes is expected
        absent, so a pulled copy of it is a mismatch. Compared ignoring case on the id only.

        BY CONTENT HASH, NOT BY TEXT (#4402). Measured on a release day: a text compare through the console
        mis-decoded non-ASCII and read 'differs' on a file that matched, while 'git hash-object' of the pulled
        file against the commit's blob id was reliable. A path missing from -Actual reads as absent.
    #>
    param([hashtable]$Expected, [hashtable]$Actual)
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($p in @($Expected.Keys | Sort-Object)) {
        $want = ([string]$Expected[$p]).Trim().ToLower()
        $have = if ($Actual.ContainsKey($p)) { ([string]$Actual[$p]).Trim().ToLower() } else { '' }
        if ($want -ne $have) { $out.Add([string]$p) }
    }
    return @($out)
}

function Set-GoLiveRecordAppHold {
    <#
        The record's text with every 'live <path>' under the app root turned into 'hold <path>', for a run
        whose line said -SkipAppDeploy -- so the record never needs the hand edit the preflight asks for.
        Every other line, comments included, is kept byte for byte. Hard LF in, hard LF out.
    #>
    param([AllowEmptyString()][string]$Text, [AllowEmptyString()][string]$AppRoot)
    $lines = @(([string]$Text -replace "`r`n", "`n") -split "`n")
    $out = foreach ($line in $lines) {
        $m = [regex]::Match($line, '^(\s*)live(\s+)(\S.*)$')
        if ($m.Success -and (Test-GoLiveUnderAppRoot -Path $m.Groups[3].Value -AppRoot $AppRoot)) {
            "$($m.Groups[1].Value)hold$($m.Groups[2].Value)$($m.Groups[3].Value)"
        } else { $line }
    }
    return (@($out) -join "`n")
}

function Format-GoLiveResumeLine {
    <#
        The go-live line to run again from -From, for a person to add the marker to. It never carries the
        marker -- the line a person authorises is theirs to write, the rule live-preflight keeps for the push.
        Every value is validated before it is printed. The record path is single-quoted with any quote
        doubled, so a TEMP under an 8.3 name ('DAVEK_~2') or a non-ASCII user folder still resumes; only a
        path with a control character is left out (Victor's review of #4402).
    #>
    param(
        [Parameter(Mandatory)][string]$From,
        [Parameter(Mandatory)][string]$RecordPath,
        [string]$Version = '',
        [string]$AppSwitch = ''
    )
    $parts = @('go-live.ps1')
    if (Test-GoLiveVersion $Version) { $parts += "-Version $(([string]$Version).Trim().TrimStart('v'))" }
    if ($From -in (Get-GoLiveResumeSteps)) { $parts += "-ResumeFrom $From" }
    if ($RecordPath -and $RecordPath -notmatch '[\x00-\x1F\x7F]') { $parts += "-LivePushRecord '$($RecordPath -replace "'", "''")'" }
    if ($AppSwitch -in @('-AppDeploy', '-SkipAppDeploy')) { $parts += $AppSwitch }
    return ($parts -join ' ')
}
