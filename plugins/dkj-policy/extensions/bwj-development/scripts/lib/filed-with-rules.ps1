<#
.SYNOPSIS
    The pure half of hooks/filed-with-stamp.ps1: which plugin versions a session ran, the hidden stamp
    that records them, and where in a 'gh issue create' result the new issue is named (inbound #4220).

.DESCRIPTION
    INBOUND #4220 (November 17, 2026): when an issue on a store repo arrives malformed, the first question
    is which plugin version the filing session ran -- was the guard that should have caught it installed
    at all? Measured in smartwatchbanden: #1390, #1391 and #1394 were filed with no labels the morning
    after guard-kind-label first shipped in v6.18.0 (#4219), and whether the filing machine had 6.18.0
    could not be established from the repo, the PRs or the commits. The version lived only in that
    machine's install record.

    THE STAMP is one HTML comment at the end of the body,
        <!-- filed-with: dkj-policy 6.18.0, bwj-development 6.18.0 -->
    hidden from a reader and from the Asana mirror, and greppable ('gh search issues filed-with').

    WHICH VERSIONS. The install record for THIS checkout in ~/.claude/plugins/installed_plugins.json is
    the authority: it is what the session loaded. A record scoped to this project path wins over a
    pathless one; where the file names no record, bwj-development falls back to the plugin.json beside
    this lib, which is the copy that is running. A version that cannot be read is stamped 'unknown' --
    still an answer, and a different one from a missing stamp.

    WHICH REPOS. The kind-label guard's list (kind-label-rules.ps1): the stores report-issue admits,
    without this plugin's source repo, whose inbound issues the version question does not concern.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/filed-with-stamp.tests.ps1 in the
    source repo -- change one, run the other.
#>

. (Join-Path $PSScriptRoot 'kind-label-rules.ps1')

$script:FiledWithPlugins = @('dkj-policy', 'bwj-development')
$script:FiledWithMarker  = '<!-- filed-with:'

function Get-CreatedIssueRef {
    <#
        Pure: the issues a 'gh issue create' result names, as Repo (owner/name) and Number, without
        repeats. gh prints the new issue's URL on a line of its own, so ONLY a line that is a URL and
        nothing else counts -- a URL quoted inside other output (a body echoed back, a view) is not a
        creation. -Text is every string the tool response carried.
    #>
    param([string[]]$Text)

    $seen = @{}
    foreach ($block in @($Text)) {
        foreach ($line in ([string]$block -split "`r?`n")) {
            $m = [regex]::Match($line, '\A\s*https://github\.com/([A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9._-]+)/issues/(\d+)\s*\z')
            if (-not $m.Success) { continue }
            $key = "$($m.Groups[1].Value)#$($m.Groups[2].Value)"
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true
            [pscustomobject]@{ Repo = $m.Groups[1].Value; Number = [int]$m.Groups[2].Value }
        }
    }
}

function Get-FiledWithResponseText {
    <#
        Pure: every string inside a PostToolUse tool_response, whatever its shape -- a string, an object
        with stdout/stderr, or nested -- so the hook does not depend on which shell tool ran.
    #>
    param($Value, [int]$Depth = 0)
    if ($null -eq $Value -or $Depth -gt 6) { return }
    if ($Value -is [string]) { return $Value }
    if ($Value -is [System.Collections.IEnumerable] -and -not ($Value -is [System.Collections.IDictionary])) {
        foreach ($v in $Value) { Get-FiledWithResponseText -Value $v -Depth ($Depth + 1) }
        return
    }
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($v in $Value.Values) { Get-FiledWithResponseText -Value $v -Depth ($Depth + 1) }
        return
    }
    foreach ($p in @($Value.PSObject.Properties)) { Get-FiledWithResponseText -Value $p.Value -Depth ($Depth + 1) }
}

function Get-FiledWithVersion {
    <#
        Pure: the version of plugin -Name ('<name>@<any marketplace>') the parsed installed_plugins.json
        -Admin records for -ProjectDir. A record whose projectPath is this checkout wins (compared
        case-insensitively, trailing separator ignored); otherwise a record with no projectPath; otherwise
        ''. Several records for this path that disagree answer '' too: not one version, so not stamped
        as one.
    #>
    param($Admin, [Parameter(Mandatory = $true)][string]$Name, [string]$ProjectDir)

    if ($null -eq $Admin -or $null -eq $Admin.plugins) { return '' }
    $key = ([string]$ProjectDir).TrimEnd('\', '/')
    $forPath = @()
    $pathless = @()
    foreach ($entry in @($Admin.plugins.PSObject.Properties)) {
        if ($entry.Name -notlike "$Name@*") { continue }
        foreach ($rec in @($entry.Value)) {
            if ($null -eq $rec) { continue }
            $ver = [string]$rec.version
            if (-not $ver) { continue }
            $pp = [string]$rec.projectPath
            if (-not $pp) { $pathless += $ver }
            elseif ($key -and $pp.TrimEnd('\', '/') -ieq $key) { $forPath += $ver }
        }
    }
    $u = @($forPath | Select-Object -Unique)
    if ($u.Count -eq 0) { $u = @($pathless | Select-Object -Unique) }
    if ($u.Count -eq 1) { return [string]$u[0] }
    return ''
}

function Get-FiledWithStamp {
    <#
        Pure: the stamp line for an ordered map of plugin -> version; an empty version reads 'unknown'.
    #>
    param([Parameter(Mandatory = $true)][System.Collections.IDictionary]$Versions)
    $parts = foreach ($k in $Versions.Keys) {
        $v = [string]$Versions[$k]
        if ($v -notmatch '\A[0-9A-Za-z.+-]{1,40}\z') { $v = 'unknown' }
        "$k $v"
    }
    return "$($script:FiledWithMarker) $($parts -join ', ') -->"
}

function Add-FiledWithStamp {
    <#
        Pure: -Body with -Stamp appended after a blank line, or $null when the body already carries a
        stamp -- a second run never stacks a second one.
    #>
    param([string]$Body, [Parameter(Mandatory = $true)][string]$Stamp)
    if (([string]$Body).Contains($script:FiledWithMarker)) { return $null }
    $trimmed = ([string]$Body).TrimEnd()
    if (-not $trimmed) { return $Stamp }
    return "$trimmed`n`n$Stamp"
}
