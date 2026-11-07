<#
.SYNOPSIS
    Admin's Plugins page (#3482): every plugin enabled in the repo, and whether it is healthy on this machine.

.DESCRIPTION
    ONE READING, NOT TWO. The page reads nothing itself: the server runs plugin-versions.ps1 -Json in a child
    process (the repo's own copy first, then this plugin's, Get-DkjPolicyScriptCandidates) and hands its one
    line in here. So the page and the plugin-versions skill can never disagree about a plugin: the verdict, its
    code and the paste-ready command are that script's.

    WHAT COUNTS AS A PROBLEM is Get-PluginRowStatus: an install behind its clone or missing for this checkout,
    or an install folder gone from disk, is an error; a stale clone, a retired name or a verdict that could not
    be reached is a warning; up to date, or on the released version with unreleased commits in the clone, is
    fine. The overview is a card per plugin, problems first (Format-PluginsPageHtml), and each plugin has its own
    page on /dev/plugins/<name> (Format-PluginPageHtml), routed by Resolve-PluginsPageRequest.

    Read-PluginsPageModel is the one function here that starts a process; the rest has no I/O, so every rule
    is tested without a server (dev-pages.tests.ps1). Every value that reaches the page is escaped. Pure ASCII
    (repo convention for .ps1).
#>

function Read-PluginsPageModel {
    <#
        Runs -Script (plugin-versions.ps1) with -Json -RootOverride -RepoRoot in a child powershell.exe, bounded
        at -TimeoutSeconds, and returns @{ Model; Error }. The child, not this server, because the script
        dot-sources a chain of libs whose functions must not land in a server's scope. It takes under a second.
    #>
    param(
        [AllowEmptyString()][string]$Script = '',
        [Parameter(Mandatory = $true)][string]$RepoRoot,
        [int]$TimeoutSeconds = 30
    )
    $empty = ConvertFrom-PluginVersionsJson -Text ''
    if (-not $Script -or -not (Test-Path -LiteralPath $Script -PathType Leaf)) {
        return @{ Model = $empty; Error = 'plugin-versions.ps1 was not found in the repo or in the dkj-policy plugin' }
    }
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = Join-Path $PSHOME 'powershell.exe'
        $psi.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + $Script + '" -Json -RootOverride "' + $RepoRoot + '"'
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.WorkingDirectory = $RepoRoot
        $p = [System.Diagnostics.Process]::Start($psi)
        try {
            # Both pipes read at once, so a full one never stalls the child.
            $out = $p.StandardOutput.ReadToEndAsync()
            $err = $p.StandardError.ReadToEndAsync()
            if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
                try { $p.Kill() } catch { }
                return @{ Model = $empty; Error = "plugin-versions.ps1 did not finish within $TimeoutSeconds s" }
            }
            $p.WaitForExit()
            $model = ConvertFrom-PluginVersionsJson -Text ([string]$out.Result)
            if ($model.Error) {
                $first = @(([string]$err.Result + "`n" + [string]$out.Result) -split "`r?`n" | Where-Object { $_.Trim() }) | Select-Object -First 1
                $why = "plugin-versions.ps1 exited $($p.ExitCode)" + $(if ($first) { ': ' + ($first.Trim() -replace '\s+', ' ') } else { '' })
                return @{ Model = $empty; Error = $why }
            }
            return @{ Model = $model; Error = '' }
        } finally { $p.Dispose() }
    } catch {
        return @{ Model = $empty; Error = (([string]$_.Exception.Message) -replace '\s+', ' ') }
    }
}

function ConvertFrom-PluginVersionsJson {
    <#
        plugin-versions.ps1 -Json's output as the page's model: @{ Plugins; Clones; Consulted; Error }. -Text is the
        child's whole stdout; the LAST line that parses as an object is taken, so a stray line before it is
        harmless. Never throws: what cannot be read is the Error, and Plugins is empty.
    #>
    param([AllowNull()][AllowEmptyString()][string]$Text)
    $model = @{ Plugins = @(); Clones = @(); Consulted = ''; Error = '' }
    $line = @(([string]$Text) -split "`r?`n" | Where-Object { $_.TrimStart().StartsWith('{') }) | Select-Object -Last 1
    if (-not $line) { $model.Error = 'plugin-versions.ps1 returned no JSON'; return $model }
    try { $o = $line | ConvertFrom-Json } catch { $model.Error = 'plugin-versions.ps1 returned JSON that does not parse'; return $model }
    $model.Consulted = [string]$o.Consulted
    $model.Plugins = @(@($o.Plugins) | Where-Object { $_ } | ForEach-Object {
        @{
            Id = [string]$_.Id; Name = [string]$_.Name; Marketplace = [string]$_.Marketplace
            InstVersion = [string]$_.InstVersion; InstSha = [string]$_.InstSha; InstScope = [string]$_.InstScope; InstText = [string]$_.InstText
            InstallPathMissing = [bool]$_.InstallPathMissing
            CloneVer = [string]$_.CloneVer; CloneText = [string]$_.CloneText; Description = [string]$_.Description
            Code = [string]$_.Code; Verdict = [string]$_.Verdict; Action = [string]$_.Action
        }
    })
    $model.Clones = @(@($o.Clones) | Where-Object { $_ } | ForEach-Object {
        @{ Marketplace = [string]$_.Marketplace; Dir = [string]$_.Dir; Exists = [bool]$_.Exists; Head = [string]$_.Head
           HeadDate = [string]$_.HeadDate; FetchTime = [string]$_.FetchTime; IsShallow = [bool]$_.IsShallow; Error = [string]$_.Error }
    })
    return $model
}

function Get-PluginRowStatus {
    <#
        One plugin's state on the page: @{ Level = 'ok' | 'warn' | 'error'; Label }. -Code is plugin-versions'
        verdict code; -InstallPathMissing wins over every code, since a folder gone from disk loads nothing.
    #>
    param([AllowEmptyString()][string]$Code = '', [bool]$InstallPathMissing = $false)
    if ($InstallPathMissing) { return @{ Level = 'error'; Label = 'Install folder missing' } }
    switch ($Code) {
        'match'         { return @{ Level = 'ok'; Label = 'Up to date' } }
        'ver-match'     { return @{ Level = 'ok'; Label = 'Up to date' } }
        'unreleased'    { return @{ Level = 'ok'; Label = 'Up to date' } }
        'behind'        { return @{ Level = 'error'; Label = 'Behind' } }
        'not-installed' { return @{ Level = 'error'; Label = 'Not installed here' } }
        'clone-behind'  { return @{ Level = 'warn'; Label = 'Clone behind' } }
        'retired'       { return @{ Level = 'warn'; Label = 'Retired' } }
        default         { return @{ Level = 'warn'; Label = 'Undetermined' } }
    }
}

function Resolve-PluginsPageRequest {
    <#
        Which Plugins page -Path asks for: @{ Name = ''; Page = '' } for the overview on /dev/plugins, @{ Name = '<plugin>';
        Page = '' } for one plugin's page on /dev/plugins/<plugin>, @{ Name = 'dkj-policy'; Page = 'dkj-brandbook' } for
        the brand book's specimens under the plugin whose files they document (#3493; under dkj-solutions until
        #3629, which BWJ-Development never enables), or $null for a path that is none of these. Section is '' on the
        specimens' overview and the section's slug on /dev/plugins/dkj-policy/dkj-brandbook/<section>, one page per section
        (#3563); whether a section of that slug exists is the page's question. The page took the brand book's name
        (#3704), as the product's had: both older addresses, /dev/plugins/dkj-solutions/house-style[/<section>] and
        /dev/plugins/dkj-policy/house-style[/<section>], return @{ Redirect = '<the same page under dkj-brandbook>' }, so
        a link to either still lands. The name is held to a plugin slug, so nothing else reaches a lookup; whether a plugin of that name is
        enabled is the page's question (a 404 when not).
    #>
    param([AllowEmptyString()][string]$Path = '')
    if ($Path -eq '/dev/plugins' -or $Path -eq '/dev/plugins/') { return @{ Name = ''; Page = ''; Section = '' } }
    if ($Path -cmatch '^/dev/plugins/([a-z0-9][a-z0-9-]{0,63})/?$') { return @{ Name = $Matches[1]; Page = ''; Section = '' } }
    if ($Path -cmatch '^/dev/plugins/dkj-policy/dkj-brandbook(?:/([a-z][a-z-]{0,39}))?/?$') {
        return @{ Name = 'dkj-policy'; Page = 'dkj-brandbook'; Section = [string]$Matches[1] }
    }
    if ($Path -cmatch '^/dev/plugins/(?:dkj-policy|dkj-solutions)/house-style(?:/([a-z][a-z-]{0,39}))?/?$') {
        return @{ Redirect = '/dev/plugins/dkj-policy/dkj-brandbook' + $(if ($Matches[1]) { '/' + $Matches[1] }) }
    }
    # One specialist, skill or hook the plugin ships, on a landing page of its own (Dave, November 3, 2026).
    if ($Path -cmatch '^/dev/plugins/([a-z0-9][a-z0-9-]{0,63})/(specialists|skills|hooks)/([a-z0-9][a-z0-9._-]{0,79})/?$') {
        return @{ Name = $Matches[1]; Page = $Matches[2]; Section = $Matches[3] }
    }
    return $null
}

function Find-PluginsPageRow {
    <# The row of -Model whose Name is -Name, with its Status set, or $null. #>
    param([Parameter(Mandatory = $true)][hashtable]$Model, [Parameter(Mandatory = $true)][string]$Name)
    $r = @($Model.Plugins | Where-Object { $_ -and $_.Name -ceq $Name }) | Select-Object -First 1
    if ($r) { $r.Status = Get-PluginRowStatus -Code $r.Code -InstallPathMissing $r.InstallPathMissing }
    return $r
}

function Get-PluginProblemText {
    <# What is wrong with one plugin, in a sentence: the missing folder where that is the case, else the verdict. #>
    param([Parameter(Mandatory = $true)][hashtable]$Row)
    if ($Row.InstallPathMissing) { return 'its install record names a folder that is no longer on disk, so it loads nothing; reinstall it' }
    return $Row.Verdict
}

function ConvertTo-PluginDescriptionHtml {
    <#
        A plugin's description as paragraphs rather than one block (the owner, October 26, 2026): a manifest
        description runs to a dozen sentences and marks its chapters with a lead-in in capitals ("THE HOUSE STYLE:"),
        so each such lead-in becomes an h3 in sentence case ("The house style") over the paragraph it opens. The text is
        escaped first; a lead-in is two or more capital letters, spaces or hyphens before a colon, after a sentence end.
    #>
    param([AllowNull()][AllowEmptyString()][string]$Text)
    $html = ConvertTo-GeneralPageText ([string]$Text)
    $parts = @([regex]::Split($html, '(?<=[.!?])\s+(?=[A-Z][A-Z -]*[A-Z]:)') | Where-Object { $_.Trim() })
    return (@($parts | ForEach-Object {
        $part = $_.Trim()
        if ($part -cmatch '^([A-Z][A-Z -]*[A-Z]):\s*(.*)$') {
            $head = $Matches[1].Substring(0, 1) + $Matches[1].Substring(1).ToLowerInvariant()
            '<h3>' + $head + '</h3>' + $(if ($Matches[2]) { '<p>' + $Matches[2] + '</p>' })
        } else { '<p>' + $part + '</p>' }
    }) -join '')
}

function Format-PluginBadgeHtml {
    <#
        The status badge for -Level: the house .badge is an 18px round icon, so it holds a mark -- a check, a '!' or a
        cross -- and never the label, and it is decorative (aria-hidden); the text beside it says the status (the
        owner, October 25, 2026; the house rule for a badge before a title).
    #>
    param([Parameter(Mandatory = $true)][string]$Level)
    $badge = @{ ok = @('badge--good', '&#10003;'); warn = @('badge--warn', '!'); error = @('badge--bad', '&#10007;') }[$Level]
    return '<span class="badge badge--sm ' + $badge[0] + '" aria-hidden="true">' + $badge[1] + '</span>'
}

function Format-PluginsPageHtml {
    <#
        The Plugins overview, as compact as the Stopwatch's (the owner, October 25, 2026): no tiles, lead or status
        line, only a card per plugin -- its state as a badge, its name as the card's one link to
        its own page (Format-PluginPageHtml), and its installed version or what is wrong. Problems first, then by
        name, under two h2 sections -- dkj-marketplace's plugins, and MCP for every other marketplace's -- whose cards'
        names are h3s. Everything else -- the description, the command, the clone -- is on the plugin's page. -Model is
        ConvertFrom-PluginVersionsJson's; -ReadError is set when the script could not be found or run. -RepoName
        names the repo; -AdminHref is the Home crumb's target ('/', the root of Admin
        that serves the page).
    #>
    param(
        [Parameter(Mandatory = $true)][hashtable]$Model,
        [AllowEmptyString()][string]$ReadError = '',
        [AllowEmptyString()][string]$RepoName = '',
        [string]$AdminHref = '/'
    )
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $rows = @($Model.Plugins | Where-Object { $_ })
    foreach ($r in $rows) { $r.Status = Get-PluginRowStatus -Code $r.Code -InstallPathMissing $r.InstallPathMissing }
    $rank = @{ error = 0; warn = 1; ok = 2 }
    $rows = @($rows | Sort-Object @{ Expression = { $rank[$_.Status.Level] } }, @{ Expression = { $_.Name } })

    # No tile row, no lead and no status line (the owner, October 25, 2026): the cards' badges already say it. A
    # message is drawn only where there are no cards to say anything: a failed read, or no plugin enabled.
    $body = New-Object System.Text.StringBuilder
    if ($ReadError -or $Model.Error) {
        $why = if ($ReadError) { $ReadError } else { $Model.Error }
        [void]$body.AppendLine('<p class="msg--warn" role="alert">The plugins could not be read: ' + (& $e $why) + '.</p>')
    } elseif (-not $rows.Count) {
        [void]$body.AppendLine('<p role="status">No plugin is enabled in this repo. Consulted: ' + (& $e $Model.Consulted) + '.</p>')
    }
    # Two sections, each an h2 over its cards' h3s (the owner, October 30, 2026): the plugins from dkj-marketplace,
    # and MCP for every other marketplace's (Figma's). A section with no card is not drawn.
    $sections = @(
        @{ Id = 'dkj-marketplace'; Title = 'dkj-marketplace'; Rows = @($rows | Where-Object { $_.Marketplace -ceq 'dkj-marketplace' }) }
        @{ Id = 'mcp'; Title = 'MCP'; Rows = @($rows | Where-Object { $_.Marketplace -cne 'dkj-marketplace' }) }
    )
    foreach ($section in @($sections | Where-Object { $_.Rows.Count })) {
        # Admin's form (#3830): a .table--dense per section under its h2, one row per plugin.
        $items = foreach ($r in $section.Rows) {
            # The sub line says the status in words, since the badge is only its mark.
            $sub = (& $e $r.Status.Label) + ': ' + $(if ($r.Status.Level -ne 'ok') { & $e (Get-PluginProblemText $r) }
                   elseif ($r.InstVersion) { (& $e $r.InstVersion) + $(if ($r.InstScope) { ', ' + (& $e $r.InstScope) + ' scope' } else { '' }) }
                   else { & $e $r.InstText })
            @{ Href = ('/dev/plugins/' + $r.Name); Label = $r.Name; SubHtml = $sub; BadgeHtml = (Format-PluginBadgeHtml $r.Status.Level) }
        }
        [void]$body.AppendLine((Format-AdminLinkTableHtml -Items @($items) -Heading $section.Title -Id ('plugins-' + $section.Id) -NameHead 'Plugin' -SubHead 'Status'))
    }
    return Format-GeneralPageHtml -Title 'Installed plugins' -Body $body.ToString() -SiteName $RepoName -AdminHref $AdminHref `
        -Lead '' `
        -FooterNote 'Read on every request by the plugin-versions skill''s own script, <code>plugin-versions.ps1 -Json</code>: the enable state from the settings files, the install record from <code>~/.claude/plugins/installed_plugins.json</code>, and the marketplace clone under <code>~/.claude/plugins/marketplaces</code>.'
}

function Format-PluginPageHtml {
    <#
        One plugin's page on /dev/plugins/<name>, under the Plugins crumb: its state, what is wrong and the command that
        closes it where plugin-versions names one, its description, and the facts -- installed here, the marketplace
        clone and that clone's HEAD. -Row is Find-PluginsPageRow's; -Model the whole model, for the clone. -Cards are
        Admin's own pages below this plugin, each @{ Href; Label; Sub; Icon }, linked as cards after what the plugin
        ships itself: an admin that builds a page about a plugin hangs it here rather than on its own home page.
    #>
    param(
        [Parameter(Mandatory = $true)][hashtable]$Row,
        [Parameter(Mandatory = $true)][hashtable]$Model,
        [AllowEmptyString()][string]$RepoName = '',
        [string]$AdminHref = '/',
        [AllowEmptyCollection()][object[]]$Cards = @(),
        [AllowNull()][hashtable]$Contents = $null
    )
    $e = { param($v) ConvertTo-GeneralPageText $v }
    if (-not $Row.Status) { $Row.Status = Get-PluginRowStatus -Code $Row.Code -InstallPathMissing $Row.InstallPathMissing }
    # The house badge row: the mark, then the status in words (as the Issues page's Done row does), at the far
    # right of the h1's row (the owner, October 26, 2026).
    $badge = '<p class="badge-row">' + (Format-PluginBadgeHtml $Row.Status.Level) + (& $e $Row.Status.Label) + '</p>'
    $body = New-Object System.Text.StringBuilder
    # What the plugin ships comes first, each kind an h2 over a card per item that opens its landing page (Dave,
    # November 3, 2026). -Contents is Get-PluginContents'; a kind the plugin ships none of is not drawn.
    if ($Contents) { [void]$body.Append((Format-PluginContentsSectionsHtml -PluginName ([string]$Row.Name) -Contents $Contents)) }
    # One screen, side by side (the owner, October 26, 2026; the house density rule): the description and the
    # state of this machine as two cards in one row, rather than a status block and two full-width groups stacked.
    [void]$body.AppendLine('<div class="grid-2">')
    if ($Row.Description) {
        [void]$body.AppendLine('<section class="card dp-about" id="about"><h2>What it is</h2>' + (ConvertTo-PluginDescriptionHtml $Row.Description) + '</section>')
    }
    [void]$body.AppendLine('<section class="card' + $(if (-not $Row.Description) { ' grid__full' }) + '" id="facts"><h2>On this machine</h2>')
    # A healthy plugin gets no verdict line: the badge beside the h1 already says it (the owner, October 26, 2026).
    if ($Row.Status.Level -ne 'ok') {
        [void]$body.AppendLine('<p class="msg--warn" role="status">' + (& $e (Get-PluginProblemText $Row)) + '.</p>')
        if ($Row.Action -and -not $Row.InstallPathMissing) { [void]$body.AppendLine('<p class="note">To close it: <code>' + (& $e $Row.Action) + '</code></p>') }
    }
    [void]$body.AppendLine('<dl class="facts">')
    [void]$body.AppendLine('<div><dt>Id</dt><dd><code>' + (& $e $Row.Id) + '</code></dd></div>')
    [void]$body.AppendLine('<div><dt>Installed here</dt><dd>' + (& $e $Row.InstText) + '</dd></div>')
    [void]$body.AppendLine('<div><dt>Marketplace clone</dt><dd>' + (& $e $Row.CloneText) + '</dd></div>')
    $c = @($Model.Clones | Where-Object { $_ -and $_.Marketplace -eq $Row.Marketplace }) | Select-Object -First 1
    if ($c) {
        $bits = if ($c.Exists) { @($(if ($c.HeadDate) { 'committed ' + $c.HeadDate }), $(if ($c.FetchTime) { 'last fetch ' + $c.FetchTime }), $(if ($c.IsShallow) { 'shallow clone' })) } else { @('not present') }
        [void]$body.AppendLine('<div><dt>Clone</dt><dd>' + (& $e ((@($bits) | Where-Object { $_ }) -join ', ')) + '</dd></div>')
    }
    [void]$body.AppendLine('<div><dt>Enabled in</dt><dd>' + $(if ($Model.Consulted) { & $e $Model.Consulted } else { '--' }) + '</dd></div>')
    [void]$body.AppendLine('</dl></section></div>')
    # What a plugin ships that can be looked at: dkj-policy's brand book, its specimens one page below (#3493,
    # #3629; named dkj-brandbook as on the product, #3704), then Admin's own pages about this plugin.
    $below = @()
    if ($Row.Name -ceq 'dkj-policy') {
        $below += @{ Href = '/dev/plugins/dkj-policy/dkj-brandbook'; Label = 'dkj-brandbook'; Sub = 'Every token, the twelve themes and every component, with their variants and states'; Icon = 'house-style' }
    }
    $below += @($Cards | Where-Object { $_ })
    if ($below.Count) { [void]$body.AppendLine((Format-AdminLinkTableHtml -Items $below -NameHead 'Page')) }
    # No lead: the crumbs and the Id fact already say which plugin and marketplace this is (the density rule).
    return Format-GeneralPageHtml -Title ([string]$Row.Name) -Body $body.ToString() -SiteName $RepoName -AdminHref $AdminHref `
        -ParentCrumbs @(@{ Label = 'Installed plugins'; Href = '/dev/plugins' }) -HeadAside $badge `
        -Style '.dp-about p { font-size: var(--text-base); }' `
        -Lead '' `
        -FooterNote 'Read on every request by <code>plugin-versions.ps1 -Json</code>, the plugin-versions skill''s own script.'
}

function Resolve-PluginPayloadDir {
    <#
        The folder holding -Row's plugin files, or '' where none is found. The repo's own tree first when the repo IS
        that plugin's marketplace (its .claude-plugin/marketplace.json carries the row's marketplace name), so the
        source repo shows the branch it is on; otherwise the marketplace clone plugin-versions names in -Model. The
        plugin's folder is its marketplace entry's source, and only a relative one ('./...') is followed.
    #>
    param([Parameter(Mandatory = $true)][hashtable]$Row, [Parameter(Mandatory = $true)][hashtable]$Model, [AllowEmptyString()][string]$RepoRoot = '')
    $roots = @()
    if ($RepoRoot) { $roots += $RepoRoot }
    $roots += @($Model.Clones | Where-Object { $_ -and $_.Marketplace -eq $Row.Marketplace -and $_.Dir } | ForEach-Object { $_.Dir })
    foreach ($root in $roots) {
        $mf = Join-Path $root '.claude-plugin\marketplace.json'
        if (-not (Test-Path -LiteralPath $mf -PathType Leaf)) { continue }
        try { $m = [System.IO.File]::ReadAllText($mf, (New-Object System.Text.UTF8Encoding($false))) | ConvertFrom-Json } catch { continue }
        if ([string]$m.name -cne [string]$Row.Marketplace) { continue }
        $p = @($m.plugins | Where-Object { $_ -and [string]$_.name -ceq [string]$Row.Name }) | Select-Object -First 1
        $src = if ($p) { [string]$p.source } else { '' }
        if ($src -cnotmatch '^\./[A-Za-z0-9._/-]+$' -or $src -match '\.\.') { continue }
        $dir = Join-Path $root ($src.Substring(2) -replace '/', '\')
        if (Test-Path -LiteralPath $dir -PathType Container) { return $dir }
    }
    return ''
}

function ConvertFrom-PluginFrontmatter {
    <#
        Pure: the frontmatter of a markdown file as a hashtable of its top-level keys. A folded or literal value
        ('>', '>-', '|') joins its indented lines with a space; a quoted value loses its quotes. No frontmatter, empty.
    #>
    param([AllowEmptyString()][string]$Text)
    $h = @{}
    $m = [regex]::Match($Text, '\A---\r?\n([\s\S]*?)\r?\n---')
    if (-not $m.Success) { return $h }
    $lines = @($m.Groups[1].Value -split '\r?\n')
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -notmatch '^([A-Za-z0-9_-]+):[ \t]*(.*)$') { continue }
        $key = $Matches[1]; $val = $Matches[2].Trim()
        if ($val -match '^[>|][+-]?$') {
            $parts = @()
            while ($i + 1 -lt $lines.Count -and $lines[$i + 1] -match '^\s+\S') { $i++; $parts += $lines[$i].Trim() }
            $val = $parts -join ' '
        } elseif ($val -match '^"(.*)"$' -or $val -match "^'(.*)'$") { $val = $Matches[1] }
        $h[$key] = $val
    }
    return $h
}

function Get-PluginScriptHelp {
    <# Pure: the .SYNOPSIS and .DESCRIPTION of a script's opening comment-based help, each dedented, as @{ Synopsis; Description }. #>
    param([AllowEmptyString()][string]$Text)
    $out = @{ Synopsis = ''; Description = '' }
    $m = [regex]::Match($Text, '\A\s*<#([\s\S]*?)#>')
    if (-not $m.Success) { return $out }
    $cur = ''; $buf = @{ SYNOPSIS = @(); DESCRIPTION = @() }
    foreach ($l in @($m.Groups[1].Value -split '\r?\n')) {
        if ($l -match '^\s*\.([A-Z]+)\b') { $cur = $Matches[1]; continue }
        if ($buf.ContainsKey($cur)) { $buf[$cur] += $l }
    }
    foreach ($k in 'SYNOPSIS', 'DESCRIPTION') {
        $ls = @($buf[$k])
        $ind = @($ls | Where-Object { $_.Trim() } | ForEach-Object { ($_ -replace '^(\s*).*$', '$1').Length } | Measure-Object -Minimum).Minimum
        $txt = (@($ls | ForEach-Object { if ($_.Length -ge $ind) { $_.Substring([int]$ind) } else { $_.Trim() } }) -join "`n").Trim()
        if ($k -eq 'SYNOPSIS') { $out.Synopsis = $txt } else { $out.Description = $txt }
    }
    return $out
}

function ConvertTo-PluginParagraphsHtml {
    <# Pure: plain text as escaped paragraphs, one per blank-line-separated block, its wrapped lines joined; a block of '- ' lines is a list. #>
    param([AllowEmptyString()][string]$Text)
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $html = foreach ($b in @([regex]::Split($Text.Trim(), '\r?\n\s*\r?\n') | Where-Object { $_.Trim() })) {
        $ls = @($b -split '\r?\n')
        if ($ls[0].TrimStart().StartsWith('- ')) {
            $items = @(); foreach ($l in $ls) { if ($l.TrimStart().StartsWith('- ')) { $items += $l.Trim().Substring(2) } elseif ($items.Count) { $items[$items.Count - 1] += ' ' + $l.Trim() } }
            '<ul>' + (@($items | ForEach-Object { '<li>' + (& $e $_) + '</li>' }) -join '') + '</ul>'
        } else { '<p>' + (& $e ((@($ls | ForEach-Object { $_.Trim() }) -join ' '))) + '</p>' }
    }
    return (@($html) -join "`n")
}

function Get-PluginContents {
    <#
        What the plugin in -Dir ships, as @{ Specialists; Skills; Hooks }, each a list of items with a Slug that names its
        landing page (Dave, November 3, 2026). Read per request, so the page shows the files as they are now.
        - A specialist is every id under subagents/, personas/ or manuals/ (specialist-GG-II-<kind>.md). Its name, emoji
          and title are its document's '# ' heading ("Victor <emoji> -- the Code Reviewer (...)"), the document being the
          manual where there is one, else the persona, else the subagent definition; a subagent's frontmatter adds its
          description, model and tools. Slug: the name in lower case, else the id.
        - A skill is skills/<folder>/SKILL.md, named and described by its frontmatter. Slug: the folder.
        - A hook is a script hooks/hooks.json runs, one item per script whatever events run it, with that script's
          .SYNOPSIS and .DESCRIPTION. Slug: the script's name without its extension.
        Nothing is read outside -Dir, and an unreadable file leaves its item out rather than the page.
    #>
    param([AllowEmptyString()][string]$Dir = '')
    $out = @{ Specialists = @(); Skills = @(); Hooks = @() }
    if (-not $Dir -or -not (Test-Path -LiteralPath $Dir -PathType Container)) { return $out }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $read = { param($p) try { [System.IO.File]::ReadAllText($p, $utf8) -replace "`r`n", "`n" } catch { $null } }
    $dash = [string][char]0x2014

    # Specialists.
    $files = @{}
    foreach ($kind in 'subagent', 'persona', 'manual') {
        $sub = Join-Path $Dir ($kind + 's')
        if (-not (Test-Path -LiteralPath $sub -PathType Container)) { continue }
        foreach ($f in @(Get-ChildItem -LiteralPath $sub -File | Where-Object { $_.Name -cmatch ('^specialist-(\d{2}-\d{2})-' + $kind + '\.md\z') })) {
            $id = $f.Name.Substring(11, 5)
            if (-not $files[$id]) { $files[$id] = @{} }
            $files[$id][$kind] = $f.FullName
        }
    }
    foreach ($id in @($files.Keys | Sort-Object)) {
        $set = $files[$id]
        $docPath = @($set['manual'], $set['persona'], $set['subagent']) | Where-Object { $_ } | Select-Object -First 1
        $doc = & $read $docPath
        if ($null -eq $doc) { continue }
        # The name and title from the persona's heading where there is one: a manual beside a persona titles itself
        # as the playbook ("..., the on-demand playbook"), not as the specialist.
        $headDoc = if ($set['persona'] -and $docPath -ne $set['persona']) { [string](& $read $set['persona']) } else { $doc }
        $heading = ''
        foreach ($l in @(($headDoc -replace '\A---\n[\s\S]*?\n---\n', '') -split "`n")) { if ($l -match '^#\s+(.+)$') { $heading = $Matches[1].Trim(); break } }
        $name = ''; $emoji = ''; $title = ''
        if ($heading -match ('^(.+?)\s+' + $dash + '\s+(.+)$')) {
            $who = @($Matches[1].Trim() -split '\s+'); $title = $Matches[2]
            $name = $who[0]; $emoji = (@($who | Select-Object -Skip 1) -join ' ')
            $title = ($title -replace '\s*\(.*\)\s*$', '' -replace '^(?i:the)\s+', '').Trim()
            if ($title) { $title = $title.Substring(0, 1).ToUpperInvariant() + $title.Substring(1) }
        } else { $name = $heading }
        $fm = if ($set['subagent']) { ConvertFrom-PluginFrontmatter -Text ([string](& $read $set['subagent'])) } else { @{} }
        if (-not $name -and $fm.name) { $name = $fm.name.Substring(0, 1).ToUpperInvariant() + $fm.name.Substring(1) }
        $desc = [string]$fm.description
        if (-not $desc) { $desc = ((Split-AdminLensIntro -Text (ConvertTo-AdminLensBody -Text $doc)).Intro -split "`n`n")[0] }
        $slug = if ($name -cmatch '^[A-Za-z][A-Za-z0-9-]*$') { $name.ToLowerInvariant() } else { $id }
        $out.Specialists += @{ Slug = $slug; Id = $id; Name = $(if ($name) { $name } else { $id }); Emoji = $emoji; Title = $title
            Kind = $(if ($set['subagent']) { 'subagent' } else { 'persona' }); Description = $desc; Model = [string]$fm.model; Tools = [string]$fm.tools
            DocPath = $docPath; DocLabel = (Split-Path (Split-Path $docPath -Parent) -Leaf) + '/' + (Split-Path $docPath -Leaf) }
    }

    # Skills.
    $skillsDir = Join-Path $Dir 'skills'
    if (Test-Path -LiteralPath $skillsDir -PathType Container) {
        foreach ($d in @(Get-ChildItem -LiteralPath $skillsDir -Directory | Sort-Object Name)) {
            $p = Join-Path $d.FullName 'SKILL.md'
            if ($d.Name -cnotmatch '^[a-z0-9][a-z0-9._-]{0,79}$' -or -not (Test-Path -LiteralPath $p -PathType Leaf)) { continue }
            $t = & $read $p
            if ($null -eq $t) { continue }
            $fm = ConvertFrom-PluginFrontmatter -Text $t
            $out.Skills += @{ Slug = $d.Name; Name = $(if ($fm.name) { [string]$fm.name } else { $d.Name }); Description = [string]$fm.description
                DocPath = $p; DocLabel = 'skills/' + $d.Name + '/SKILL.md' }
        }
    }

    # Hooks.
    $hj = Join-Path $Dir 'hooks\hooks.json'
    $ht = if (Test-Path -LiteralPath $hj -PathType Leaf) { & $read $hj } else { $null }
    if ($ht) {
        $o = $null; try { $o = $ht | ConvertFrom-Json } catch { }
        $byScript = [ordered]@{}
        if ($o -and $o.hooks) {
            foreach ($ev in @($o.hooks.PSObject.Properties)) {
                $n = 0
                foreach ($grp in @($ev.Value)) {
                    foreach ($hk in @($grp.hooks)) {
                        $n++
                        $cmd = [string]$hk.command
                        $script = if ($cmd -match 'hooks/([A-Za-z0-9._-]+\.(?:ps1|sh|js|py))') { $Matches[1] } else { '' }
                        $slug = if ($script) { ([System.IO.Path]::GetFileNameWithoutExtension($script)).ToLowerInvariant() } else { ($ev.Name + '-' + $n).ToLowerInvariant() }
                        if ($slug -cnotmatch '^[a-z0-9][a-z0-9._-]{0,79}$') { continue }
                        if (-not $byScript.Contains($slug)) {
                            $help = if ($script) { Get-PluginScriptHelp -Text ([string](& $read (Join-Path $Dir ('hooks\' + $script)))) } else { @{ Synopsis = ''; Description = '' } }
                            $byScript[$slug] = @{ Slug = $slug; Name = $(if ($script) { [System.IO.Path]::GetFileNameWithoutExtension($script) } else { $ev.Name + ' hook ' + $n })
                                Script = $(if ($script) { 'hooks/' + $script } else { '' }); Synopsis = $help.Synopsis; Description = $help.Description; Runs = @() }
                        }
                        $byScript[$slug].Runs += @{ Event = $ev.Name; Matcher = [string]$grp.matcher; Timeout = [string]$hk.timeout; StatusMessage = [string]$hk.statusMessage; Command = $cmd }
                    }
                }
            }
        }
        $out.Hooks = @($byScript.Values | Sort-Object { $_.Name })
    }
    return $out
}

function Format-PluginContentsSectionsHtml {
    <#
        Pure: the Specialists, Hooks and Skills sections of a plugin's page (Dave, November 3, 2026), each an h2 over
        a .table--dense with a row per item (Format-AdminLinkTableHtml, #3830), opening
        /dev/plugins/<plugin>/<kind>/<slug>. A kind with no item is not drawn.
    #>
    param([Parameter(Mandatory = $true)][string]$PluginName, [Parameter(Mandatory = $true)][hashtable]$Contents)
    $sb = New-Object System.Text.StringBuilder
    $kinds = @(
        @{ Key = 'specialists'; Title = 'Specialists'; Items = @($Contents.Specialists) }
        @{ Key = 'hooks'; Title = 'Hooks'; Items = @($Contents.Hooks) }
        @{ Key = 'skills'; Title = 'Skills'; Items = @($Contents.Skills) }
    )
    foreach ($k in $kinds) {
        $items = @($k.Items | Where-Object { $_ })
        if (-not $items.Count) { continue }
        # Admin's form (#3830): a .table--dense per kind under its h2, one row per item.
        $rows = foreach ($it in $items) {
            $href = '/dev/plugins/' + $PluginName + '/' + $k.Key + '/' + $it.Slug
            switch ($k.Key) {
                'specialists' {
                    @{ Href = $href; Label = ((@($it.Name, $it.Emoji) | Where-Object { $_ }) -join ' ')
                       Sub = ((@($it.Title, $(if ($it.Kind -eq 'persona') { 'main loop' })) | Where-Object { $_ }) -join ' - ') }
                }
                'hooks' { @{ Href = $href; Label = $it.Name; Sub = (@($it.Runs | ForEach-Object { $_.Event } | Select-Object -Unique) -join ', ') } }
                'skills' { @{ Href = $href; Label = $it.Name; Sub = ($PluginName + ':' + $it.Name) } }
            }
        }
        [void]$sb.AppendLine((Format-AdminLinkTableHtml -Items @($rows) -Heading $k.Title -Id ('plugin-' + $k.Key) -NameHead $(if ($k.Key -eq 'specialists') { 'Specialist' } else { $k.Title.TrimEnd('s') })))
    }
    return $sb.ToString()
}

function Format-PluginMarkdownCardHtml {
    <#
        A markdown file rendered in a card, the way a lens page renders its lens (Format-AdminLensPageHtml): its frontmatter,
        its '# ' title and a quote before its first heading go, its headings shift so the highest is an h2, and the house's
        one renderer draws it in the browser from JSON, the raw text kept in a <noscript>. A file that cannot be read is
        a warning in its place.
    #>
    param([Parameter(Mandatory = $true)][string]$Path, [Parameter(Mandatory = $true)][string]$Heading)
    $e = { param($v) ConvertTo-GeneralPageText $v }
    try {
        $utf8 = New-Object System.Text.UTF8Encoding($false)
        $text = [System.IO.File]::ReadAllText($Path, $utf8) -replace "`r`n", "`n"
        $parts = Split-AdminLensIntro -Text (ConvertTo-AdminLensBody -Text $text)
        $md = (@($parts.Intro, $parts.Body) | Where-Object { $_ }) -join "`n`n"
        $renderer = [System.IO.File]::ReadAllText($script:MarkdownRendererPath, $utf8)
        $json = (ConvertTo-Json -InputObject ([ordered]@{ body = $md }) -Compress) -replace '<', ('\' + 'u003c')
        return '<section class="card dp-doc" id="doc"><h2>' + (& $e $Heading) + '</h2><div id="doc-body"><noscript><pre tabindex="0"><code>' + (& $e $md) + '</code></pre></noscript></div></section>' + "`n" +
            '<script type="application/json" id="doc-md">' + $json + '</script>' + "`n" +
            "<script>`n(function () {`n  'use strict';`n" + $renderer.TrimEnd() + "`n  document.getElementById('doc-body').innerHTML = renderMd(JSON.parse(document.getElementById('doc-md').textContent).body);`n})();`n</script>"
    } catch {
        return '<section class="card dp-doc"><p class="msg--warn" role="alert">' + (& $e $Heading) + ' could not be read: ' + (& $e $_.Exception.Message) + '</p></section>'
    }
}

function Format-PluginItemPageHtml {
    <#
        The landing page of one specialist, skill or hook a plugin ships, on /dev/plugins/<plugin>/<kind>/<slug> under the
        Installed plugins and plugin crumbs (Dave, November 3, 2026): what it is and the facts about it as two cards side
        by side (the house density rule), then its own document in full -- a specialist's manual (or persona), a skill's
        SKILL.md -- or, for a hook, every event that runs it. -Kind is 'specialists', 'skills' or 'hooks'; -Contents is
        Get-PluginContents'. $null for a slug the plugin has no item of, which the server answers with a 404. -RepoRoot
        is read only to link a specialist's repo lens where this checkout has one.
    #>
    param(
        [Parameter(Mandatory = $true)][hashtable]$Row,
        [Parameter(Mandatory = $true)][hashtable]$Contents,
        [Parameter(Mandatory = $true)][ValidateSet('specialists', 'skills', 'hooks')][string]$Kind,
        [Parameter(Mandatory = $true)][string]$Slug,
        [AllowEmptyString()][string]$RepoName = '',
        [AllowEmptyString()][string]$RepoRoot = '',
        [string]$AdminHref = '/'
    )
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $list = switch ($Kind) { 'specialists' { $Contents.Specialists } 'skills' { $Contents.Skills } 'hooks' { $Contents.Hooks } }
    $it = @($list | Where-Object { $_ -and $_.Slug -ceq $Slug }) | Select-Object -First 1
    if (-not $it) { return $null }
    $plugin = [string]$Row.Name
    $fact = { param($dt, $ddHtml) '<div><dt>' + $dt + '</dt><dd>' + $ddHtml + '</dd></div>' }
    $body = New-Object System.Text.StringBuilder
    $facts = @(); $about = ''; $after = ''; $title = $it.Name; $lead = ''
    switch ($Kind) {
        'specialists' {
            $title = (@($it.Name, $it.Emoji) | Where-Object { $_ }) -join ' '
            # The lead is only the page's meta description (#3585), so the title heads the card that says what they do.
            $lead = & $e $it.Title
            $about = '<h2>' + $(if ($it.Title) { & $e $it.Title } else { 'What they do' }) + '</h2>' + (ConvertTo-PluginParagraphsHtml $it.Description)
            $facts += & $fact 'Id' ('<code>' + (& $e $it.Id) + '</code>')
            $facts += & $fact 'Runs as' $(if ($it.Kind -eq 'subagent') { 'A subagent, handed work by Chris' } else { 'A persona in the main loop' })
            if ($it.Model) { $facts += & $fact 'Model' (& $e $it.Model) }
            if ($it.Tools) { $facts += & $fact 'Tools' (& $e $it.Tools) }
            $lensName = 'specialist-' + $it.Id + '-lens'
            if ($RepoRoot -and (Test-Path -LiteralPath (Join-Path $RepoRoot ('.claude\specialists\lenses\' + $lensName + '.md')) -PathType Leaf)) {
                $facts += & $fact 'Lens in this repo' ('<a href="/dev/claude/specialists/lenses/' + $lensName + '">' + $lensName + '</a>')
            }
            $facts += & $fact 'Source' ('<code>' + (& $e $it.DocLabel) + '</code>')
            $after = Format-PluginMarkdownCardHtml -Path $it.DocPath -Heading $(if ($it.DocLabel -like 'manuals/*') { 'Manual' } elseif ($it.DocLabel -like 'personas/*') { 'Persona' } else { 'Definition' })
        }
        'skills' {
            $about = '<h2>What it does</h2>' + (ConvertTo-PluginParagraphsHtml $it.Description)
            $facts += & $fact 'Invoked as' ('<code>/' + (& $e ($plugin + ':' + $it.Name)) + '</code>')
            $facts += & $fact 'Source' ('<code>' + (& $e $it.DocLabel) + '</code>')
            $after = Format-PluginMarkdownCardHtml -Path $it.DocPath -Heading 'SKILL.md'
        }
        'hooks' {
            $about = '<h2>What it does</h2>' + $(if ($it.Synopsis) { ConvertTo-PluginParagraphsHtml $it.Synopsis } else { '<p class="note">The script carries no synopsis.</p>' })
            if ($it.Script) { $facts += & $fact 'Script' ('<code>' + (& $e $it.Script) + '</code>') }
            foreach ($r in @($it.Runs)) {
                $bits = @((& $e $r.Event) + $(if ($r.Matcher) { ' <code>' + (& $e $r.Matcher) + '</code>' }))
                if ($r.Timeout) { $bits += 'timeout ' + (& $e $r.Timeout) + ' s' }
                if ($r.StatusMessage) { $bits += '&quot;' + (& $e $r.StatusMessage) + '&quot;' }
                $facts += & $fact 'Runs on' ($bits -join ', ')
            }
            if ($it.Description) { $after = '<section class="card dp-doc" id="doc"><h2>How it works</h2>' + (ConvertTo-PluginParagraphsHtml $it.Description) + '</section>' }
        }
    }
    [void]$body.AppendLine('<div class="grid-2">')
    [void]$body.AppendLine('<section class="card" id="about">' + $about + '</section>')
    [void]$body.AppendLine('<section class="card" id="facts"><h2>Facts</h2><dl class="facts">' + ($facts -join '') + '</dl></section>')
    [void]$body.AppendLine('</div>')
    if ($after) { [void]$body.AppendLine($after) }
    $style = '.dp-doc { max-width: 800px; }' + "`n" +
        '#doc-body > * + *, .dp-doc > * + * { margin-top: var(--spacing-3); }' + "`n" +
        '#doc-body > * + :is(h2, h3) { margin-top: var(--spacing-6); }' + "`n" +
        '#doc-body li + li, #doc-body li > :is(ul, ol) { margin-top: var(--spacing-1); }'
    return Format-GeneralPageHtml -Title $title -Body $body.ToString() -SiteName $RepoName -AdminHref $AdminHref -Style $style `
        -ParentCrumbs @(@{ Label = 'Installed plugins'; Href = '/dev/plugins' }, @{ Label = $plugin; Href = '/dev/plugins/' + $plugin }) -Lead $lead `
        -FooterNote ('Read on every request from the ' + (& $e $plugin) + ' plugin''s own files.')
}

function Split-HouseStyleSpecimens {
    <#
        assets/dkj-brandbook/specimens.html cut along its sections (#3563), so each can be a page of its own. A section is
        a column-0 <div class="grid-N"> opening on a grid__head with <h2 id="hs-<slug>">, up to the next column-0
        </div>. Returns @{ Head; Sections; Tail }: Head is what precedes <div class="spec-page"> (the specimens' own
        style block and icon sprite), Tail is from the first column-0 <dialog> or <script> on (the modal specimens, which
        the product layer's own specimens carry since #3831, and the script), and
        each section is @{ Slug; Title; Sub; Grid; Inner; Cards }, Title as text, Sub the file's own markup and Cards the
        number of cards in it. One file stays the single source: the split is read, never written.
        Column 0, because the Overlays section shows dialogs open in place, indented inside its cards: a tail from the
        first <dialog> anywhere carried half that section onto every page, outside .spec-stage, floating over it (#3703).
        <script> too, because the core file has no dialog of its own since the split (#3831) and its script still draws
        the live theme picker on the Themes page.
    #>
    param([AllowEmptyString()][string]$Body = '')
    $pageAt = $Body.IndexOf('<div class="spec-page">')
    $head = if ($pageAt -gt 0) { $Body.Substring(0, $pageAt) } else { '' }
    $tailMatch = [regex]::Match($Body, '(?m)^<(?:dialog|script)\b')
    $tail = if ($tailMatch.Success) { $Body.Substring($tailMatch.Index) } else { '' }
    $sections = @()
    $rx = '(?ms)^<div class="(grid-\d)">\r?\n\s*<div class="grid__head"><h2 id="hs-([a-z][a-z-]*)">([^<]+)</h2><p class="card__sub">(.*?)</p></div>\r?\n(.*?)^</div>\r?$'
    foreach ($m in [regex]::Matches($Body, $rx)) {
        # The title is the file's markup, decoded to text here because every page escapes it again (the h1, the crumb).
        $sections += @{ Grid = $m.Groups[1].Value; Slug = $m.Groups[2].Value; Title = [System.Net.WebUtility]::HtmlDecode($m.Groups[3].Value); Sub = $m.Groups[4].Value
            Inner = $m.Groups[5].Value; Cards = [regex]::Matches($m.Groups[5].Value, '<section class="card[ "]').Count }
    }
    return @{ Head = $head; Sections = $sections; Tail = $tail }
}

function Get-HouseStyleSpecimensParts {
    <#
        What a specimens page holds, without the page around it, so Admin and the source repo's product
        (#3540) render the same page each in its own shell: @{ Title; Lead; Body; Section }, Section $true on a
        section's own page. -BasePath is where the overview lives, each section's card opening <BasePath>/<slug>.
        A -Section no section has returns $null. -Body and -ReadError as Format-HouseStyleSpecimensPageHtml takes them.
    #>
    param(
        [AllowEmptyString()][string]$Body = '',
        [AllowEmptyString()][string]$ReadError = '',
        [AllowEmptyString()][string]$Section = '',
        [string]$BasePath = '/dev/plugins/dkj-policy/dkj-brandbook',
        [switch]$Cards
    )
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $split = if ($ReadError) { @{ Head = ''; Sections = @(); Tail = '' } } else { Split-HouseStyleSpecimens -Body $Body }

    if ($Section) {
        $s = @($split.Sections | Where-Object { $_.Slug -ceq $Section }) | Select-Object -First 1
        if (-not $s) { return $null }
        # The section's own cards, without its grid__head: the page's h1 and lead already carry its name and line.
        $content = $split.Head + '<div class="spec-page">' + "`n" + '<div class="' + $s.Grid + '">' + "`n" + $s.Inner + '</div>' + "`n" + '</div>' + "`n" + $split.Tail
        return @{ Title = $s.Title; Lead = $s.Sub; Body = $content; Section = $true }
    }

    $out = New-Object System.Text.StringBuilder
    if ($ReadError) {
        [void]$out.AppendLine('<section class="card"><p class="msg--warn" role="status">The specimens could not be read: ' + (& $e $ReadError) + '</p></section>')
    } elseif (-not @($split.Sections).Count) {
        [void]$out.AppendLine('<section class="card"><p class="msg--warn" role="status">The specimens were read, but no section was found in them.</p></section>')
    } elseif ($Cards) {
        # -Cards: the product's form, a card per section in a .grid-3 (the product's brand book page).
        [void]$out.AppendLine('<div class="grid-3">')
        foreach ($s in $split.Sections) {
            $count = if ($s.Cards -eq 1) { '1 specimen' } else { [string]$s.Cards + ' specimens' }
            [void]$out.AppendLine((Format-AdminCardLinkHtml -Href ($BasePath + '/' + $s.Slug) -Label $s.Title -Sub $count))
        }
        [void]$out.AppendLine('</div>')
    } else {
        # Admin's form (#3830): one .table--dense, a row per section of the specimens.
        $rows = foreach ($s in $split.Sections) {
            @{ Href = ($BasePath + '/' + $s.Slug); Label = $s.Title; Sub = $(if ($s.Cards -eq 1) { '1 specimen' } else { [string]$s.Cards + ' specimens' }) }
        }
        [void]$out.AppendLine((Format-AdminLinkTableHtml -Items @($rows) -NameHead 'Section' -SubHead 'Specimens'))
    }
    return @{ Title = 'dkj-brandbook'; Body = $out.ToString(); Section = $false
              Lead = 'Every token, the twelve themes and every component of the DKJ-Solutions brand book, with their variants and states.' }
}

function Format-HouseStyleSpecimensPageHtml {
    <#
        The brand book's specimens under /dev/plugins/dkj-policy/dkj-brandbook (#3493, #3704): every token, theme and component
        of the stylesheet, under the Plugins and dkj-policy crumbs, because the files they document sit in dkj-policy
        (#3531) and every repo running its Admin renders with them (#3629); the rule to start from them stays
        dkj-solutions'. -Body is assets/dkj-brandbook/specimens.html
        from the same payload as house-style.css (Get-HouseStyleDir), a body fragment trusted as the plugin's own
        markup; -ReadError is why it could not be read, shown, escaped, in its place.

        A LONG PAGE BECOMES CARDS WITH A PAGE EACH (#3563): with no -Section the page is an overview, one card per
        section of the specimens naming how many specimens it holds, and each card opens
        /dev/plugins/dkj-policy/dkj-brandbook/<section>, that section alone. A -Section no section has returns $null,
        which the server answers with a 404. What the page holds is Get-HouseStyleSpecimensParts'; this is its
        Admin shell.
    #>
    param(
        [AllowEmptyString()][string]$Body = '',
        [AllowEmptyString()][string]$ReadError = '',
        [AllowEmptyString()][string]$RepoName = '',
        [AllowEmptyString()][string]$Section = '',
        [string]$AdminHref = '/'
    )
    $base = '/dev/plugins/dkj-policy/dkj-brandbook'
    $parts = Get-HouseStyleSpecimensParts -Body $Body -ReadError $ReadError -Section $Section -BasePath $base
    if ($null -eq $parts) { return $null }
    $crumbs = @(@{ Label = 'Installed plugins'; Href = '/dev/plugins' }, @{ Label = 'dkj-policy'; Href = '/dev/plugins/dkj-policy' })
    if ($parts.Section) { $crumbs += @{ Label = 'dkj-brandbook'; Href = $base } }
    return Format-GeneralPageHtml -Title $parts.Title -Body $parts.Body -SiteName $RepoName -AdminHref $AdminHref `
        -ParentCrumbs $crumbs -Lead $parts.Lead `
        -FooterNote 'The stylesheet and these specimens are <code>assets/dkj-brandbook/</code> in the dkj-policy plugin Admin runs from.'
}

function Resolve-HouseStyleProductUrl {
    <#
        Where Admin sends its house-style pages instead of serving them (Maikel, October 31, 2026): in the
        house style's SOURCE repo, whose product shows them at /marketplace/dkj-policy/dkj-brandbook[/<section>]
        beside the plugin they belong to (named after the brand book since October 31, 2026, Maikel; the product
        redirects the older house-style address a released Admin still sends). -IsSource is whether this checkout holds the canonical
        plugins/dkj-policy/assets/dkj-brandbook/specimens.html; -ProductUrl is the product the state file names.
        '' -- serve them here -- in every other repo, and where no plain loopback product is known.
    #>
    param([bool]$IsSource, [AllowEmptyString()][string]$ProductUrl = '', [AllowEmptyString()][string]$Section = '')
    if (-not $IsSource -or $ProductUrl -cnotmatch '^http://localhost:[0-9]{4,5}/?\z') { return '' }
    return $ProductUrl.TrimEnd('/') + '/marketplace/dkj-policy/dkj-brandbook' + $(if ($Section) { '/' + $Section })
}
