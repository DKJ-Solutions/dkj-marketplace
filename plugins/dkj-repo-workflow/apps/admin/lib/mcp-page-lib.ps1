<#
.SYNOPSIS
    Admin's MCP connections page on /dev/claude/mcp (#4173): the MCP servers a Claude session in this checkout can reach,
    where each one comes from, whether it answers, and whether this repo switches it off.

.DESCRIPTION
    The page never runs the health check itself. `claude mcp list` checks every server and takes about 15 s (measured
    November 16, 2026: 36 servers, 15.1 s), so the page reads a CACHE: one JSON file per checkout under the machine's
    Admin folder (Get-McpCachePath), written by the server's /refresh?page=mcp (Update-McpCache in
    serve-general-pages.ps1). With no cache yet, the page says so and offers that one button.

    What is kept is what the page shows, and nothing more: a connector's URL can carry an account-specific path, so
    only its HOST is parsed out and written (ConvertFrom-McpListOutput); a stdio server keeps only its command's file
    name, never its arguments.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/mcp-page.tests.ps1 in the source repo.
#>

function ConvertFrom-McpListOutput {
    <#
        Pure: the rows of `claude mcp list`'s text -Text, each @{ Name; Source; Host; State; Raw }, in its order.
        A server line reads '<name>: <url or command> - <state>'. The name ends at its first ': ' (a plugin's server
        name holds colons, never a colon and a space); the state is past the LAST ' - '. Source is 'claude.ai' (a
        'claude.ai ' name, kept without that prefix), 'plugin' (a 'plugin:<plugin>:<server>' name, kept as
        '<plugin>/<server>'), 'project' (a name -ProjectNames holds: the repo's .mcp.json) or 'user' (the user's or
        the local config). State is connected, auth, failed, disabled or unknown; Raw keeps the state's own words
        for unknown. Host is a URL's host only, or a command's file name.
    #>
    param([AllowEmptyString()][string]$Text = '', [AllowEmptyCollection()][string[]]$ProjectNames = @())
    $rows = New-Object System.Collections.Generic.List[object]
    foreach ($line in @($Text -split "`r?`n")) {
        $m = [regex]::Match($line.Trim(), '\A(?<name>.+?): (?<target>.*) - (?<state>[^\r\n]+)\z')
        if (-not $m.Success) { continue }
        $name = $m.Groups['name'].Value.Trim()
        $target = $m.Groups['target'].Value.Trim()
        $stateText = $m.Groups['state'].Value.Trim()
        if ($name.StartsWith('claude.ai ')) { $source = 'claude.ai'; $name = $name.Substring(10).Trim() }
        elseif ($name -cmatch '\Aplugin:([^:]+):(.+)\z') { $source = 'plugin'; $name = $Matches[1] + '/' + $Matches[2] }
        elseif ($ProjectNames -contains $name) { $source = 'project' }
        else { $source = 'user' }
        $state = if ($stateText -match 'Needs authentication') { 'auth' }
                 elseif ($stateText -match 'Disabled') { 'disabled' }
                 elseif ($stateText -match 'Failed') { 'failed' }
                 elseif ($stateText -match 'Connected') { 'connected' }
                 else { 'unknown' }
        $hostName = ''
        if ($target -match '\A[A-Za-z][A-Za-z0-9+.-]*://') {
            try { $hostName = ([uri]$target).Host } catch { $hostName = '' }
        } elseif ($target) {
            $cmd = [regex]::Match($target, '\A"([^"]+)"|\A(\S+)')
            $exe = if ($cmd.Groups[1].Success) { $cmd.Groups[1].Value } else { $cmd.Groups[2].Value }
            $hostName = ($exe -split '[\\/]')[-1]
        }
        # The state's own words only where they say something the page has no name for, and never a URL.
        $raw = if ($state -eq 'unknown') { ($stateText -replace '[^\x20-\x7E]', '').Trim() -replace 'https?://\S+', '' } else { '' }
        $rows.Add(@{ Name = $name; Source = $source; Host = $hostName; State = $state; Raw = $raw })
    }
    return $rows.ToArray()
}

function Get-McpProjectNames {
    <# The server names the .mcp.json at the root of -RepoRoot declares; none without the file or when it is not valid JSON. #>
    param([AllowEmptyString()][string]$RepoRoot = '')
    if (-not $RepoRoot) { return @() }
    $path = Join-Path $RepoRoot '.mcp.json'
    try {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return @() }
        $servers = (ConvertFrom-Json -InputObject ([System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8))).mcpServers
        if ($null -eq $servers) { return @() }
        return @($servers.PSObject.Properties | ForEach-Object { $_.Name })
    } catch { return @() }
}

function Get-McpCachePath {
    <#
        The cache file for the checkout at -Root: mcp-<root hash>.json in DKJ_ADMIN_STATE_DIR where set (the tests), else
        %LOCALAPPDATA%\dkj-admin, the machine's Admin folder. Per checkout, because 'disabled for this project' is; the
        hash is the checkout's own tag (Get-DevPreviewRootHash, dev-preview-rules.ps1), which the caller has loaded.
    #>
    param([Parameter(Mandatory = $true)][string]$Root)
    $dir = if ($env:DKJ_ADMIN_STATE_DIR) { $env:DKJ_ADMIN_STATE_DIR }
           else { Join-Path $(if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { [System.IO.Path]::GetTempPath() }) 'dkj-admin' }
    return (Join-Path $dir ('mcp-' + (Get-DevPreviewRootHash -Root $Root) + '.json'))
}

function Write-McpCache {
    <# Writes -Rows, -GeneratedAt (yyyy-MM-dd HH:mm:ss), -Seconds and -ReadError to -Path, making its folder where needed. Throws on a write failure. #>
    param([Parameter(Mandatory = $true)][string]$Path, [AllowEmptyCollection()][object[]]$Rows = @(), [string]$GeneratedAt = '',
        [double]$Seconds = 0, [AllowEmptyString()][string]$ReadError = '')
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir -PathType Container)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $o = [pscustomobject]@{
        GeneratedAt = $GeneratedAt; Seconds = [Math]::Round($Seconds, 1); Error = $ReadError
        Rows = @($Rows | ForEach-Object { [pscustomobject]@{ Name = [string]$_.Name; Source = [string]$_.Source; Host = [string]$_.Host; State = [string]$_.State; Raw = [string]$_.Raw } })
    }
    [System.IO.File]::WriteAllText($Path, (ConvertTo-Json -InputObject $o -Depth 4), (New-Object System.Text.UTF8Encoding($false)))
}

function Read-McpCache {
    <# @{ Rows; GeneratedAt; Seconds; Error } from the cache at -Path; $null where it is absent or not valid JSON. #>
    param([Parameter(Mandatory = $true)][string]$Path)
    try {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
        $o = ConvertFrom-Json -InputObject ([System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8))
        $rows = @(@($o.Rows) | Where-Object { $_ } | ForEach-Object {
            @{ Name = [string]$_.Name; Source = [string]$_.Source; Host = [string]$_.Host; State = [string]$_.State; Raw = [string]$_.Raw } })
        return @{ Rows = $rows; GeneratedAt = [string]$o.GeneratedAt; Seconds = $o.Seconds; Error = [string]$o.Error }
    } catch { return $null }
}

function Format-AdminMcpPageHtml {
    <#
        The MCP connections page from -Cache (Read-McpCache's shape, or $null for none yet), under Home > Claude: the
        counts as tiles, then one row per server in a .table--dense -- by source (claude.ai, plugin, project, user),
        then by name -- with its host, its state and whether this repo switches it off. -RefreshHref is the button
        that reads the connections again.
    #>
    param([AllowNull()]$Cache = $null, [AllowEmptyString()][string]$RepoName = '', [string]$RefreshHref = '/refresh?page=mcp')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $inv = [Globalization.CultureInfo]::InvariantCulture
    $body = New-Object System.Text.StringBuilder
    $readBtn = '<a class="btn btn--primary" href="' + (& $e $RefreshHref) + '">Read the connections</a>'
    if ($null -eq $Cache) {
        [void]$body.Append('<section class="empty-state" role="status"><span class="empty-state__mark" aria-hidden="true"></span>' +
            '<h2>Not read yet</h2><p class="empty-state__text">Reading runs <code>claude mcp list</code>, which checks every server and takes about 15 seconds, so this page shows what the last read found rather than reading on every visit.</p>' +
            $readBtn + '</section>')
    } else {
        $rows = @($Cache.Rows)
        $count = { param($s) @($rows | Where-Object { $_.State -eq $s }).Count }
        [void]$body.Append((Format-DevTiles @(
            @{ L = 'Servers'; V = $rows.Count },
            @{ L = 'Connected'; V = (& $count 'connected') },
            @{ L = 'Needs authentication'; V = (& $count 'auth') },
            @{ L = 'Failed'; V = (& $count 'failed') },
            @{ L = 'Switched off here'; V = (& $count 'disabled') })))
        if ($Cache.Error) {
            [void]$body.AppendLine('<p class="msg--warn" role="alert">The last read failed: ' + (& $e $Cache.Error) + '.</p>')
        }
        $order = @{ 'claude.ai' = 0; 'plugin' = 1; 'project' = 2; 'user' = 3 }
        $sourceName = @{ 'claude.ai' = 'claude.ai connector'; 'plugin' = 'Plugin'; 'project' = 'Project .mcp.json'; 'user' = 'User config' }
        $stateBadge = @{
            'connected' = @('good', 'Connected'); 'auth' = @('warn', 'Needs authentication'); 'failed' = @('bad', 'Failed')
            'disabled' = @('neutral', 'Not checked'); 'unknown' = @('info', 'Unknown')
        }
        $sorted = @($rows | Sort-Object @{ Expression = { if ($order.ContainsKey($_.Source)) { $order[$_.Source] } else { 9 } } }, @{ Expression = { $_.Name } })
        [void]$body.Append('<section class="admin-list"><table class="table table--dense"><thead><tr><th class="col-start">Server</th><th class="col-start">Source</th>' +
            '<th class="col-start">Host</th><th class="col-start">State</th><th class="col-start">In this repo</th></tr></thead><tbody>')
        if (-not $sorted.Count) {
            [void]$body.Append('<tr><td class="col-start" colspan="5" role="status">No MCP server is configured for this checkout.</td></tr>')
        }
        foreach ($r in $sorted) {
            $b = if ($stateBadge.ContainsKey($r.State)) { $stateBadge[$r.State] } else { $stateBadge['unknown'] }
            $label = if ($r.State -eq 'unknown' -and $r.Raw) { $r.Raw } else { $b[1] }
            $src = if ($sourceName.ContainsKey($r.Source)) { $sourceName[$r.Source] } else { $r.Source }
            $here = if ($r.State -eq 'disabled') { 'Switched off' } else { 'On' }
            [void]$body.Append('<tr><td class="col-start">' + (& $e $r.Name) + '</td><td class="col-start">' + (& $e $src) + '</td><td class="col-start">' +
                $(if ($r.Host) { '<code>' + (& $e $r.Host) + '</code>' } else { '--' }) + '</td><td class="col-start"><span class="badge badge--sm badge--' + $b[0] + '">' +
                (& $e $label) + '</span></td><td class="col-start">' + $here + '</td></tr>')
        }
        [void]$body.Append('</tbody></table></section>')
        [void]$body.Append('<p>' + $readBtn + '</p>')
    }
    $when = if ($Cache -and $Cache.GeneratedAt) {
        ' Last read ' + (& $e $Cache.GeneratedAt) + $(if ($null -ne $Cache.Seconds) { ' in ' + ([double]$Cache.Seconds).ToString('0.0', $inv) + ' s' } else { '' }) + '.'
    } else { '' }
    $whose = if ($RepoName) { ' in <code>' + (& $e $RepoName) + '</code>' } else { '' }
    return Format-GeneralPageHtml -Title 'MCP connections' -Body $body.ToString() -SiteName $RepoName `
        -Lead ('The MCP servers a Claude session' + $whose + ' can reach, where each comes from, and whether it answers.') `
        -ParentCrumbs @(@{ Label = 'Claude'; Href = '/dev/claude' }) `
        -FooterNote ('Read with <code>claude mcp list</code> on this machine, from this checkout.' + $when + ' Only a server''s host is kept: a connector''s full URL can carry an account-specific path. Switched off is a server this project has disabled (<code>/mcp</code> turns it back on).')
}
