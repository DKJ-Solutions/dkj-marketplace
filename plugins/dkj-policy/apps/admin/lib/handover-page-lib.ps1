<#
.SYNOPSIS
    The preview handover page (#3925): one Admin page per handover, at /dev/handover/<name>, carrying the four blocks a
    preview handover owes -- how to see the change, one card per market with a QR code to the preview and the preview
    and control links, what is proven and what is asked, and the paste-ready go-live block -- and /dev/handover listing
    them.

.DESCRIPTION
    WHY AN ADMIN PAGE (#3772, #3925). The handover is ONE LINK to a published page (bwj-development's
    PREVIEW-portable.md), and since November 3, 2026 a result someone must judge is an Admin page, never a claude.ai
    Artifact. Nothing carried the page until this: the URL and pair builders existed, and the handover went into an
    issue comment without the QR codes, which is the form that page argues against for review on a phone.

    THE MODEL LIVES OUTSIDE THE CHECKOUT, beside this repo's Stopwatch store
    (repos\<Get-AdminRepoKey>\handover\<name>.json under Get-AdminTimingBaseDir), because the branch it hands over is
    parked for the owner's eye and a file in the tree would dirty it. A builder writes it (bwj-development's
    build-handover-page.ps1, which knows the store's markets); this lib reads it and draws it, and is the one place
    that knows the shape. Save-HandoverModel and Read-HandoverModel are the two halves.

    THE QR CODES ARE DRAWN HERE, per request, by scripts/lib/qr-lib.ps1, as inline SVG: no image host, no CDN, so the
    preview URL never leaves the machine and the page draws offline. A code is cached per URL for the server's life,
    since one takes about half a second to encode.

    WHAT IS TRUSTED. The model file is this machine's own, but it is read as data: every text is escaped, a link is
    drawn only when it is an https URL, and a name is a slug, so no request can reach outside the handover folder.

    Rendered in Admin, where general-pages-lib.ps1 is loaded (ConvertTo-GeneralPageText, Format-GeneralPageHtml).
    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/handover-page.tests.ps1 in the source repo.
#>

if (-not (Get-Command Get-AdminRepoKey -CommandType Function -ErrorAction SilentlyContinue)) { . (Join-Path $PSScriptRoot 'stopwatch-lib.ps1') }
if (-not (Get-Command ConvertTo-QrSvg -CommandType Function -ErrorAction SilentlyContinue)) { . (Join-Path $PSScriptRoot '..\..\..\scripts\lib\qr-lib.ps1') }

$script:HandoverNameRx = '\A[a-z0-9][a-z0-9-]{0,79}\z'
$script:HandoverMaxBytes = 1048576
$script:HandoverMaxCards = 60
$script:HandoverQrCache = @{}
# The page's own layer: names the house file does not define, tokens only. The code is the page's ink on its surface.
$script:HandoverPageStyle = '.handover-cards { display: grid; gap: var(--spacing-4); grid-template-columns: repeat(auto-fill, minmax(16rem, 1fr)); }' + "`n" +
    '.handover-card .qr { display: block; width: 100%; max-width: 14rem; margin: var(--spacing-2) auto; color: var(--fg-1); }' + "`n" +
    '.handover-card .qr__bg { fill: var(--bg-1); }' + "`n" +
    '.handover-card .handover-links { margin: 0; padding: 0; list-style: none; overflow-wrap: anywhere; font-size: var(--text-sm); }' + "`n" +
    '.handover-card .handover-links > li + li { margin-top: var(--spacing-1); }' + "`n" +
    '.handover-text p { margin: 0 0 var(--spacing-2); }' + "`n" +
    '.handover-golive pre { white-space: pre-wrap; overflow-wrap: anywhere; margin: 0; }'

function Test-HandoverName {
    <# Whether -Name is a handover's name: a lowercase slug, at most 80 characters. Pure. #>
    param([AllowEmptyString()][string]$Name = '')
    return [bool]($Name -cmatch $script:HandoverNameRx)
}

function ConvertTo-HandoverName {
    <# -Text (a branch name, an issue title) as a handover's name: lowercased, every run of other characters one dash, cut to 80. '' when nothing is left. Pure. #>
    param([AllowEmptyString()][string]$Text = '')
    $s = ($Text.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    if ($s.Length -gt 80) { $s = $s.Substring(0, 80).TrimEnd('-') }
    return $s
}

function Get-HandoverDir {
    <# This machine's handover folder for the repo at -RepoRoot: repos\<Get-AdminRepoKey>\handover under Get-AdminTimingBaseDir. #>
    param([Parameter(Mandatory = $true)][string]$RepoRoot)
    return (Join-Path (Get-AdminTimingBaseDir) ('repos\' + (Get-AdminRepoKey -RepoRoot $RepoRoot) + '\handover'))
}

function Format-HandoverLink {
    <#
    The line a session reports for the handover at -Url: a markdown link '[handover: <name>](<url>)', on its own line.
    A bare URL was relayed verbatim and the owner could not click it in the terminal (#3954, smartwatchbanden#1149);
    the same address as a markdown link was. The label is the handover's name, a slug, so nothing in it can break the
    link's brackets. Pure.
    #>
    param([Parameter(Mandatory = $true)][string]$Name, [Parameter(Mandatory = $true)][string]$Url)
    return ('[handover: ' + $Name + '](' + $Url + ')')
}

function Test-HandoverUrl {
    <# Whether -Url may be drawn as a link or a code: an absolute https URL with no space or control character. Pure. #>
    param([AllowEmptyString()][string]$Url = '')
    return [bool]($Url -cmatch '\Ahttps://[^\s/?#]+[^\s]*\z' -and $Url -notmatch '[\x00-\x1F\x7F]')
}

function ConvertTo-HandoverModel {
    <#
        A handover model from -Raw (parsed JSON), normalised and bounded, or a string saying why it is not one:
        @{ name; title; createdAt; issue; branch; howToSee; prerequisites; cards; proven; asked; golive }, each card
        @{ market; path; previewUrl; controlUrl; copy }, golive @{ task; block } or $null. Pure.
    #>
    param($Raw)
    if ($null -eq $Raw) { return 'the handover is empty' }
    $txt = { param($v, [int]$max = 20000) $s = [string]$v; if ($s.Length -gt $max) { $s = $s.Substring(0, $max) }; $s }
    $name = [string]$Raw.name
    if (-not (Test-HandoverName $name)) { return "'$name' is not a handover name (a lowercase slug)" }
    $title = (& $txt $Raw.title 200).Trim()
    if (-not $title) { return 'the handover has no title' }
    $cards = @()
    foreach ($c in @(@($Raw.cards) | Where-Object { $null -ne $_ } | Select-Object -First $script:HandoverMaxCards)) {
        $market = (& $txt $c.market 20).Trim()
        $preview = [string]$c.previewUrl; $control = [string]$c.controlUrl
        if (-not $market) { return 'a card has no market' }
        if (-not (Test-HandoverUrl $preview)) { return "the $market card's preview URL is not an https URL" }
        if ($control -and -not (Test-HandoverUrl $control)) { return "the $market card's control URL is not an https URL" }
        $cards += [pscustomobject]@{ market = $market; path = (& $txt $c.path 500); previewUrl = $preview; controlUrl = $control; copy = (& $txt $c.copy 2000) }
    }
    if (-not $cards.Count) { return 'the handover has no market card' }
    $golive = $null
    if ($Raw.golive -and ([string]$Raw.golive.block).Trim()) { $golive = [pscustomobject]@{ task = (& $txt $Raw.golive.task 500); block = (& $txt $Raw.golive.block 20000) } }
    return [pscustomobject]@{
        name = $name; title = $title; createdAt = (& $txt $Raw.createdAt 40); issue = (& $txt $Raw.issue 200); branch = (& $txt $Raw.branch 200)
        howToSee = (& $txt $Raw.howToSee); prerequisites = @(@($Raw.prerequisites) | ForEach-Object { (& $txt $_ 500).Trim() } | Where-Object { $_ } | Select-Object -First 30)
        cards = $cards; proven = (& $txt $Raw.proven); asked = (& $txt $Raw.asked 2000); golive = $golive
    }
}

function Save-HandoverModel {
    <# Writes -Model (checked by ConvertTo-HandoverModel first) to -Dir\<name>.json through a file beside it. Returns the path; throws when the model does not hold. #>
    param([Parameter(Mandatory = $true)][string]$Dir, [Parameter(Mandatory = $true)]$Model)
    $m = ConvertTo-HandoverModel -Raw $Model
    if ($m -is [string]) { throw "handover: $m." }
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) { [void](New-Item -ItemType Directory -Path $Dir -Force) }
    $path = Join-Path $Dir ($m.name + '.json')
    # ASCII on disk: every character above 0x7E as a JSON escape, so the file reads the same under any code page.
    $json = ($m | ConvertTo-Json -Depth 6)
    $escape = ('\' + 'u') + '{0:x4}'
    $json = [regex]::Replace($json, '[^\x00-\x7E]', { param($x) $escape -f [int][char]$x.Value })
    [System.IO.File]::WriteAllText("$path.tmp", $json, (New-Object System.Text.UTF8Encoding($false)))
    Move-Item -LiteralPath "$path.tmp" -Destination $path -Force
    return $path
}

function Read-HandoverModel {
    <# The handover -Name in -Dir as @{ Model; Error }: Model $null and Error '' when there is none; Error a sentence when the file does not hold. #>
    param([Parameter(Mandatory = $true)][string]$Dir, [Parameter(Mandatory = $true)][string]$Name)
    if (-not (Test-HandoverName $Name)) { return @{ Model = $null; Error = '' } }
    $path = Join-Path $Dir ($Name + '.json')
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return @{ Model = $null; Error = '' } }
    if ((Get-Item -LiteralPath $path).Length -gt $script:HandoverMaxBytes) { return @{ Model = $null; Error = 'the handover file is larger than 1 MB' } }
    try { $raw = [System.IO.File]::ReadAllText($path, (New-Object System.Text.UTF8Encoding($false))) | ConvertFrom-Json } catch { return @{ Model = $null; Error = 'the handover file is not valid JSON' } }
    $m = ConvertTo-HandoverModel -Raw $raw
    if ($m -is [string]) { return @{ Model = $null; Error = $m } }
    return @{ Model = $m; Error = '' }
}

function Get-HandoverList {
    <# The handovers in -Dir, newest first: @{ Name; Title; At (the file's write time) }. A file whose name is not a handover name is left out. #>
    param([Parameter(Mandatory = $true)][string]$Dir)
    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) { return @() }
    return @(Get-ChildItem -LiteralPath $Dir -Filter '*.json' -File -ErrorAction SilentlyContinue |
            Where-Object { Test-HandoverName $_.BaseName } | Sort-Object LastWriteTimeUtc -Descending | ForEach-Object {
                $r = Read-HandoverModel -Dir $Dir -Name $_.BaseName
                [pscustomobject]@{ Name = $_.BaseName; Title = $(if ($r.Model) { $r.Model.title } else { '(does not read: ' + $r.Error + ')' }); At = $_.LastWriteTime }
            })
}

function Get-HandoverQrSvg {
    <# The QR code for -Url as inline SVG, cached per URL for the server's life (an encode takes about half a second). #>
    param([Parameter(Mandatory = $true)][string]$Url, [string]$Label = 'QR code')
    $key = $Url + [char]0 + $Label
    if (-not $script:HandoverQrCache.ContainsKey($key)) {
        if ($script:HandoverQrCache.Count -gt 500) { $script:HandoverQrCache.Clear() }
        $script:HandoverQrCache[$key] = ConvertTo-QrSvg -Text $Url -Label $Label
    }
    return $script:HandoverQrCache[$key]
}

function Format-HandoverTextHtml {
    <# Plain text as escaped paragraphs: a blank line starts a new one, a single line break stays one. Pure. #>
    param([AllowEmptyString()][string]$Text = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $paras = @(($Text -replace "`r", '') -split "`n\s*`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    return (($paras | ForEach-Object { '<p>' + ((@($_ -split "`n") | ForEach-Object { & $e $_ }) -join '<br>') + '</p>' }) -join '')
}

function Format-HandoverPageHtml {
    <#
        One handover's page from -Model (ConvertTo-HandoverModel): the open store-admin prerequisites above everything,
        then how to see the change, the market cards, what is proven and what is asked, and the go-live block. -ReadError
        is why the model could not be read; then the page says so instead of drawing a half.
    #>
    param([AllowNull()]$Model = $null, [AllowEmptyString()][string]$ReadError = '', [AllowEmptyString()][string]$RepoName = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $crumbs = @(@{ Label = 'Handovers'; Href = '/dev/handover' })
    if (-not $Model) {
        $why = if ($ReadError) { 'This handover does not read: ' + (& $e $ReadError) + '.' } else { 'There is no handover of that name on this machine.' }
        return Format-GeneralPageHtml -Title 'Handover' -Lead 'A preview handover.' -Body ('<p class="msg--warn" role="alert">' + $why + '</p>') -SiteName $RepoName -ParentCrumbs $crumbs
    }
    $b = New-Object System.Text.StringBuilder
    if (@($Model.prerequisites).Count) {
        [void]$b.Append('<section class="card" role="alert"><div class="card__head"><h2>Open store-admin prerequisites</h2></div><p>The go-live block is held until each of these is ticked on the issue:</p><ul>')
        foreach ($p in @($Model.prerequisites)) { [void]$b.Append('<li>' + (& $e $p) + '</li>') }
        [void]$b.AppendLine('</ul></section>')
    }
    [void]$b.AppendLine('<section class="card handover-text"><div class="card__head"><h2>How to see the change</h2></div>' + (Format-HandoverTextHtml $Model.howToSee) + '</section>')
    [void]$b.Append('<section class="handover-cards" aria-label="One card per market">')
    foreach ($c in @($Model.cards)) {
        $qr = Get-HandoverQrSvg -Url $c.previewUrl -Label ('QR code to the ' + $c.market + ' preview')
        [void]$b.Append('<article class="card handover-card"><div class="card__head"><h2>' + (& $e $c.market) + '</h2>' + $(if ($c.path) { '<span class="chip">' + (& $e $c.path) + '</span>' } else { '' }) + '</div>' + $qr)
        [void]$b.Append('<ul class="handover-links"><li><a class="dp-link" href="' + (& $e $c.previewUrl) + '" target="_blank" rel="noopener noreferrer">Preview</a> ' + (& $e $c.previewUrl) + '</li>')
        if ($c.controlUrl) { [void]$b.Append('<li><a class="dp-link" href="' + (& $e $c.controlUrl) + '" target="_blank" rel="noopener noreferrer">Control (live)</a> ' + (& $e $c.controlUrl) + '</li>') }
        [void]$b.Append('</ul>')
        if ($c.copy) { [void]$b.Append('<p class="note">Expected copy: ' + (& $e $c.copy) + '</p>') }
        [void]$b.Append('</article>')
    }
    [void]$b.AppendLine('</section>')
    [void]$b.AppendLine('<section class="card handover-text"><div class="card__head"><h2>What is proven, and what is asked</h2></div>' + (Format-HandoverTextHtml $Model.proven) +
        $(if ($Model.asked) { '<p><strong>Asked:</strong> ' + (& $e $Model.asked) + '</p>' } else { '' }) + '</section>')
    if ($Model.golive) {
        $task = if ($Model.golive.task) { ' It goes to ' + (& $e $Model.golive.task) + '.' } else { '' }
        [void]$b.AppendLine('<section class="card handover-golive"><div class="card__head"><h2>The go-live block, as the requester will read it</h2></div>' +
            '<p class="note">This is what closing the issue sends to the requester.' + $task + ' This page is private to its owner, so it is never linked there.</p><pre>' + (& $e $Model.golive.block) + '</pre></section>')
    }
    $foot = 'Built ' + (& $e $Model.createdAt) + $(if ($Model.branch) { ' on ' + (& $e $Model.branch) } else { '' }) + $(if ($Model.issue) { ' for ' + (& $e $Model.issue) } else { '' }) +
        '. The codes are drawn on this machine; the preview URLs never leave it. The link is as sensitive as the URLs on it: to the reviewer, and not onward.'
    return Format-GeneralPageHtml -Title $Model.title -Lead 'A preview handover: the preview beside its live control, per market.' -Body $b.ToString() -Style $script:HandoverPageStyle -SiteName $RepoName -ParentCrumbs $crumbs -FooterNote $foot
}

function Format-HandoverIndexHtml {
    <# /dev/handover: every handover on this machine for this repo, newest first, or an empty state naming the builder. -List is Get-HandoverList. #>
    param([AllowEmptyCollection()][object[]]$List = @(), [AllowEmptyString()][string]$RepoName = '')
    $e = { param($v) ConvertTo-GeneralPageText $v }
    $inv = [System.Globalization.CultureInfo]::InvariantCulture
    if (-not @($List).Count) {
        $body = '<section class="card"><div class="card__head"><h2>No handover yet</h2></div><p>A preview handover is built from a pushed preview theme, by the builder the store''s plugin ships (bwj-development''s <code>build-handover-page.ps1</code>), and it prints this page''s address.</p></section>'
    } else {
        $rows = foreach ($h in @($List)) { '<tr><td class="col-start"><a href="/dev/handover/' + (& $e $h.Name) + '">' + (& $e $h.Title) + '</a></td><td>' + (& $e $h.At.ToString('ddd d MMM HH:mm', $inv)) + '</td></tr>' }
        $body = '<section class="admin-list"><table class="table table--dense"><thead><tr><th class="col-start">Handover</th><th>Built</th></tr></thead><tbody>' + ($rows -join '') + '</tbody></table></section>'
    }
    return Format-GeneralPageHtml -Title 'Handovers' -Lead 'The preview handovers built on this machine for this repo.' -Body $body -SiteName $RepoName
}

function Resolve-HandoverRequest {
    <# '/dev/handover' as @{ Name = '' } (the index), '/dev/handover/<name>' as @{ Name }, anything else $null. Pure. #>
    param([AllowEmptyString()][string]$Path = '')
    if ($Path -cmatch '\A/dev/handover/?\z') { return @{ Name = '' } }
    $m = [regex]::Match($Path, '\A/dev/handover/([a-z0-9][a-z0-9-]{0,79})/?\z')
    if ($m.Success) { return @{ Name = $m.Groups[1].Value } }
    return $null
}
