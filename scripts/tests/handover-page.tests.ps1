<#
.SYNOPSIS
    Tests for the preview handover page (#3925): plugins/dkj-policy/scripts/lib/qr-lib.ps1 (the QR code drawn locally),
    plugins/dkj-policy/apps/admin/lib/handover-page-lib.ps1 (the model, its page and its route), and bwj-development's
    scripts/task/build-handover-page.ps1 (the builder, end to end against a fixture store).

    THE QR HALF IS HELD TO PUBLISHED VECTORS, not to a decoder: the Reed-Solomon codewords of ISO/IEC 18004's worked
    example, the format and version bit tables, and the version a length chooses. Those are where an encoder goes wrong
    without anything erroring. The whole code was scanned by phone when the page was first reviewed.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Admin = Join-Path $RepoRoot 'plugins\dkj-policy\apps\admin\lib'
. (Join-Path $Admin 'general-pages-lib.ps1')
. (Join-Path $Admin 'handover-page-lib.ps1')
$Builder = Join-Path $RepoRoot 'plugins\dkj-policy\extensions\bwj-development\scripts\task\build-handover-page.ps1'

$script:pass = 0
$script:fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
trap { $script:fail++; Write-Host "  [FAIL] unhandled terminating error: $_" -ForegroundColor Red; continue }
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -eq "$Actual") ($Name + $(if ("$Expected" -ne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}
$bin = { param([int]$v, [int]$w) [Convert]::ToString($v, 2).PadLeft($w, '0') }

Write-Host '-- the QR code' -ForegroundColor Cyan
Assert-Equal '196,35,39,119,235,215,231,226,93,23' ((Get-QrErrorCorrection -Data @(32, 91, 11, 120, 209, 114, 220, 77, 67, 64, 236, 17, 236, 17, 236, 17) -Count 10) -join ',') 'the error correction of the standard''s 1-M example is its published codewords'
Assert-Equal '101010000010010' (& $bin (Get-QrFormatBits 0) 15) 'the format bits for level M, mask 0, are the table''s'
Assert-Equal '100101010100000' (& $bin (Get-QrFormatBits 7) 15) '...and for mask 7'
Assert-Equal '000111110010010100' (& $bin (Get-QrVersionBits 7) 18) 'the version bits for version 7 are the table''s'
Assert-Equal '001111100100101000' (& $bin (Get-QrVersionBits 15) 18) '...and for version 15'
Assert-Equal '1|2|6|10|11|15' ((@(1, 20, 100, 213, 214, 412) | ForEach-Object { Get-QrVersion -ByteCount $_ }) -join '|') 'a length takes the smallest version that holds it at level M (a one-group version included, which a flattened array once broke)'
Assert-Equal 0 (Get-QrVersion -ByteCount 413) 'past version 15 no version is chosen'
$thrown = $false; try { [void](ConvertTo-QrMatrix -Text ('h' * 413)) } catch { $thrown = $true }
Assert-True $thrown 'a text longer than version 15 holds throws rather than drawing a code cut short'
$q = ConvertTo-QrMatrix -Text 'https://x.nl/?preview_theme_id=1&_ab=0&_fd=0&_sc=1'
$finder = { param($r0, $c0) (@(0..6 | ForEach-Object { $q.Modules[($r0) * $q.Size + $c0 + $_] }) -join '') }
Assert-True ($q.Size -eq 17 + 4 * $q.Version -and $q.Modules.Length -eq $q.Size * $q.Size) 'the matrix is (17 + 4v) modules a side'
Assert-True ((& $finder 0 0) -eq '1111111' -and (& $finder 0 ($q.Size - 7)) -eq '1111111' -and (& $finder ($q.Size - 7) 0) -eq '1111111') 'the three finders open with a full dark row'
Assert-Equal 1 $q.Modules[($q.Size - 8) * $q.Size + 8] 'the dark module is set'
$svg = ConvertTo-QrSvg -Text 'https://x.nl/' -Label 'a <code>'
Assert-True ($svg -match '\A<svg ' -and $svg -match 'fill="currentColor"' -and $svg -notmatch '#[0-9a-fA-F]{3,6}' -and $svg -notmatch 'https?://(?!www\.w3\.org/2000/svg)') 'the SVG draws in currentColor, types no colour, and references nothing outside itself'
Assert-True ($svg.Contains('aria-label="a &lt;code&gt;"')) 'its label is escaped'

Write-Host '-- the model and the page' -ForegroundColor Cyan
$card = { param($m, $p, $c = '') [pscustomobject]@{ market = $m; path = '/a'; previewUrl = $p; controlUrl = $c; copy = '' } }
$good = [pscustomobject]@{ name = 'feat-12-x'; title = 'Amber notice'; createdAt = '2026-11-09 12:00'; issue = '#12'; branch = 'feat/12-x'
    howToSee = "Open a product.`n`nOn a phone."; prerequisites = @('Metafield <x>'); proven = 'Gates green.'; asked = 'Is it right?'
    golive = [pscustomobject]@{ task = 'Task 1'; block = "Line <b>1</b>" }
    cards = @((& $card 'NL' 'https://x.nl/a?preview_theme_id=1' 'https://x.nl/a?preview_theme_id=2'), (& $card 'DE' 'https://x.de/a?preview_theme_id=1')) }
Assert-True ((ConvertTo-HandoverModel -Raw $good) -isnot [string]) 'a complete model reads'
$bad = { param([scriptblock]$Change) $m = $good | ConvertTo-Json -Depth 5 | ConvertFrom-Json; & $Change $m; ConvertTo-HandoverModel -Raw $m }
Assert-True ((& $bad { param($m) $m.cards[0].previewUrl = 'javascript:alert(1)' }) -match 'not an https URL') 'a preview URL that is not https is refused, so no script URL becomes a link or a code'
Assert-True ((& $bad { param($m) $m.cards[1].controlUrl = 'http://x.de/' }) -match 'control URL') 'a control URL that is not https is refused'
Assert-True ((& $bad { param($m) $m.name = '../x' }) -match 'not a handover name') 'a name that is not a slug is refused, so no file outside the folder is named'
Assert-True ((& $bad { param($m) $m.cards = @() }) -match 'no market card') 'a handover without a card is refused'
Assert-Equal 'feat-3925-handover-page' (ConvertTo-HandoverName 'feat/3925-handover-page') 'a branch name becomes the default handover name'

$dir = Join-Path ([System.IO.Path]::GetTempPath()) ('handover-tests-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
try {
    $path = Save-HandoverModel -Dir $dir -Model $good
    Assert-True ((Test-Path -LiteralPath $path) -and ([System.IO.File]::ReadAllText($path) -notmatch '[^\x00-\x7F]')) 'the model is written as ASCII JSON'
    $r = Read-HandoverModel -Dir $dir -Name 'feat-12-x'
    Assert-True ($r.Model -and -not $r.Error) 'it reads back'
    Assert-True ($null -eq (Read-HandoverModel -Dir $dir -Name 'nope').Model -and -not (Read-HandoverModel -Dir $dir -Name 'nope').Error) 'a handover that is not there is no model and no error'
    [System.IO.File]::WriteAllText((Join-Path $dir 'broken.json'), '{')
    Assert-True ((Read-HandoverModel -Dir $dir -Name 'broken').Error -match 'not valid JSON') 'a file that is not JSON is an error, not a page'
    $html = Format-HandoverPageHtml -Model $r.Model -RepoName 'demo'
    Assert-Equal 2 ([regex]::Matches($html, '<svg class="qr"')).Count 'the page draws one QR code per market card'
    Assert-True ($html.Contains('&lt;b&gt;1') -and $html.Contains('Metafield &lt;x&gt;') -and $html -notmatch '<b>1') 'every text on it is escaped'
    Assert-True ($html.Contains('Control (live)') -and $html.Contains('Open store-admin prerequisites') -and $html.Contains('Asked:')) 'it carries the control link, the prerequisites and the question'
    Assert-True ($html.IndexOf('Open store-admin prerequisites') -lt $html.IndexOf('class="handover-cards"')) 'the prerequisites stand above the cards'
    $none = Format-HandoverPageHtml -Model $null -ReadError 'x is wrong'
    Assert-True ($none -match 'does not read: x is wrong') 'a handover that does not read says why instead of drawing half a page'
    $index = Format-HandoverIndexHtml -List (Get-HandoverList -Dir $dir)
    Assert-True ($index.Contains('href="/dev/handover/feat-12-x"') -and $index.Contains('does not read')) 'the index links each handover and names one that does not read'
    Assert-True ((Format-HandoverIndexHtml -List @()).Contains('build-handover-page.ps1')) 'an empty index names the builder'
} finally { Remove-Item -LiteralPath $dir -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host '-- the route' -ForegroundColor Cyan
Assert-Equal '' (Resolve-HandoverRequest '/dev/handover').Name '/dev/handover is the index'
Assert-Equal 'feat-12-x' (Resolve-HandoverRequest '/dev/handover/feat-12-x/').Name '/dev/handover/<name> is that handover'
Assert-True ($null -eq (Resolve-HandoverRequest '/dev/handover/../x') -and $null -eq (Resolve-HandoverRequest '/dev/handover/A')) 'a path that is not a slug is no handover'

Write-Host '-- the reported link' -ForegroundColor Cyan
Assert-Equal '[handover: feat-12-x](http://localhost:4891/dev/handover/feat-12-x)' (Format-HandoverLink -Name 'feat-12-x' -Url 'http://localhost:4891/dev/handover/feat-12-x') 'the handover link is reported as a markdown link, so it can be clicked (#3954)'

Write-Host '-- the builder' -ForegroundColor Cyan
$fix = Join-Path ([System.IO.Path]::GetTempPath()) ('handover-store-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$prevLocal = $env:LOCALAPPDATA
try {
    [void](New-Item -ItemType Directory -Path (Join-Path $fix 'scripts') -Force)
    [void](New-Item -ItemType Directory -Path (Join-Path $fix 'local') -Force)
    [System.IO.File]::WriteAllText((Join-Path $fix 'scripts\repo-config.ps1'), "function Get-StorefrontMarkets { @(@{ Market = 'NL'; Domain = 'store.example' }, @{ Market = 'DE'; Domain = 'store.example'; PathPrefix = '/de' }) }`nfunction Get-ShopifyLiveThemeId { '222' }`n")
    $golive = Join-Path $fix 'golive.txt'
    [System.IO.File]::WriteAllText($golive, "lead`n---`nWaar kijken: https://store.example/`n---`ntail`n")
    $env:LOCALAPPDATA = Join-Path $fix 'local'
    $run = { param([string[]]$a) $o = & powershell -NoProfile -ExecutionPolicy Bypass -File $Builder -RootOverride $fix @a 2>&1; @{ Code = $LASTEXITCODE; Out = (@($o) -join "`n") } }
    $r = & $run @('-ThemeId', '111', '-Path', '/products/a', '-Title', 'Notice', '-HowToSee', 'Open it.', '-Proven', 'Gates.', '-Asked', 'Right?', '-GoliveFile', $golive, '-Name', 'feat-1-notice')
    Assert-True ($r.Code -eq 0 -and $r.Out -match '2 market card' -and $r.Out -notmatch 'preview_theme_id') 'the builder writes the handover and prints no preview URL to the terminal'
    $hoDir = & { . (Join-Path $Admin 'stopwatch-lib.ps1'); Get-HandoverDir -RepoRoot $fix }
    $read = Read-HandoverModel -Dir $hoDir -Name 'feat-1-notice'
    Assert-True ($read.Model -and @($read.Model.cards).Count -eq 2) 'the model lands in this repo''s handover folder outside the checkout'
    Assert-True ($read.Model.cards[1].previewUrl -match '^https://store\.example/de/products/a\?preview_theme_id=111&_ab=0&_fd=0&_sc=1$' -and $read.Model.cards[1].controlUrl -match 'preview_theme_id=222') 'each card carries the preview and its live-pinned control, from the store''s own markets'
    Assert-Equal 'Waar kijken: https://store.example/' $read.Model.golive.block 'the go-live block is the text between the -OutFile''s two rules'
    $r = & $run @('-ThemeId', '111', '-Title', 'Notice', '-Proven', 'Gates.', '-Asked', 'Right?', '-Name', 'feat-1-notice')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'HowToSee') 'a handover without its how-to-see block is refused'
    $r = & $run @('-ThemeId', '111', '-Title', 'Notice', '-HowToSee', 'x', '-Proven', 'Gates.', '-Asked', 'Right?', '-Name', 'Not A Slug')
    Assert-True ($r.Code -eq 1 -and $r.Out -match 'not a handover name') 'a name that is not a slug is refused'
} finally {
    $env:LOCALAPPDATA = $prevLocal
    Remove-Item -LiteralPath $fix -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host '-- finding dkj-policy from the extension (#3993)' -ForegroundColor Cyan
. (Join-Path $RepoRoot 'plugins\dkj-policy\extensions\bwj-development\scripts\lib\repo-root-lib.ps1')
$marker = 'apps\admin\lib\handover-page-lib.ps1'
Assert-Equal (Join-Path $RepoRoot 'plugins\dkj-policy') (Resolve-DkjPolicyRoot -From (Split-Path -Parent $Builder)) 'in the source tree the root is four levels up'
$cache = Join-Path ([System.IO.Path]::GetTempPath()) ('handover-cache-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
try {
    $task = Join-Path $cache 'mk\bwj-development\6.13.0\scripts\task'
    [void](New-Item -ItemType Directory -Path $task -Force)
    foreach ($v in '6.12.0', '6.13.0', '6.9.0') {
        [void](New-Item -ItemType Directory -Path (Join-Path $cache "mk\dkj-policy\$v\apps\admin\lib") -Force)
        [System.IO.File]::WriteAllText((Join-Path $cache "mk\dkj-policy\$v\$marker"), '#')
    }
    Assert-Equal (Join-Path $cache 'mk\dkj-policy\6.13.0') (Resolve-DkjPolicyRoot -From $task) 'in the install cache it is the sibling dkj-policy at this plugin''s own version'
    Remove-Item -LiteralPath (Join-Path $cache 'mk\dkj-policy\6.13.0') -Recurse -Force
    Assert-Equal (Join-Path $cache 'mk\dkj-policy\6.12.0') (Resolve-DkjPolicyRoot -From $task) 'without that version, the highest one present (by version, not by string)'
    Remove-Item -LiteralPath (Join-Path $cache 'mk\dkj-policy') -Recurse -Force
    $thrown = ''; try { [void](Resolve-DkjPolicyRoot -From $task) } catch { $thrown = $_.Exception.Message }
    Assert-True ($thrown -match 'not found' -and $thrown.Contains($marker)) 'with no dkj-policy at all it refuses, naming what it looked for'
} finally {
    Remove-Item -LiteralPath $cache -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host "handover-page: $script:pass passed, $script:fail failed"
if ($script:fail) { exit 1 }
exit 0
