<#
.SYNOPSIS
    Tests for the brand book's Figma mirror (#4038): plugins/dkj-policy/extensions/dkj-solutions/scripts/lib/
    figma-tokens-lib.ps1 and the script beside it, scripts/task/figma-tokens.ps1.

.DESCRIPTION
    Group 1 resolves a fixture stylesheet the way the browser does: a light theme is :root plus its line, a dark
    theme :root plus the forced dark block plus its line, and only #rrggbb values are colour tokens. Group 2 holds
    the model to the Figma file's layout (two palettes, one mode per theme, and a semantic layer of aliases).
    Group 3 drives the drift check through every kind of finding, and through a JSON round trip. Group 4 runs the
    real stylesheet and the script end to end: the model, the two Plugin API scripts, and -Compare's exit codes.
    Nothing here talks to Figma.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Plugin   = Join-Path $RepoRoot 'plugins\dkj-policy\extensions\dkj-solutions'
$Script   = Join-Path $Plugin 'scripts\task\figma-tokens.ps1'
$Style    = Join-Path $RepoRoot 'plugins\dkj-policy\assets\dkj-brandbook\house-style.css'

. (Join-Path $Plugin 'scripts\lib\figma-tokens-lib.ps1')

$script:pass = 0
$script:fail = 0
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    Assert-True ("$Expected" -ceq "$Actual") ($Name + $(if ("$Expected" -cne "$Actual") { " (expected '$Expected', got '$Actual')" } else { '' }))
}

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("figma-tokens-tests-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

# A fixture with every theme line the palette lib names, so Get-HouseColourTokens can resolve all twelve. It is
# written with '~~' for '--' and '.~swatch' for the swatch class, and swapped back below: the house-style gate reads
# CSS inside a .ps1 too, and would report the fixture's declarations as redefined house tokens.
$themeLines = foreach ($t in Get-HousePaletteThemes) {
    $extra = if ($t.Id -eq 'rust') { ' ~~warning-3: #B8A; ' } else { ' ' }
    ':root[data-theme="' + $t.Id + '"], .~swatch[data-id="' + $t.Id + '"] { ~~primary: #' + ('{0:x6}' -f ($t.Hue * 1000)) + ';' + $extra + '}'
}
$fixture = @"
/* a comment with ~~bg-1: #ffffff; that must not count */
:root {
  color-scheme: light;
  ~~bg-1: #fdfdff; ~~primary: #0000ff; ~~warning-3: #e0761a;
  ~~spacing-1: 4px; ~~font-mono: ui-monospace, monospace; ~~shadow-pop: 0 4px 16px rgba(0,0,0,0.15);
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme]) { ~~bg-1: #999999; ~~warning-3: #999999; }
}
:root[data-theme="dark"],
:root[data-theme="pink"], :root[data-theme="cyan"] {
  color-scheme: dark;
  ~~bg-1: #01090b; ~~warning-3: #ffc61a;
}
$($themeLines -join "`n")
"@
$fixture = $fixture.Replace('~~', '-' + '-').Replace('.~swatch', '.theme-' + 'swatch')
$fixturePath = Join-Path $tmp 'house-style.css'
[System.IO.File]::WriteAllText($fixturePath, $fixture)

Write-Host '-- group 1: resolving the stylesheet' -ForegroundColor Cyan
$t = Get-HouseColourTokens -StylePath $fixturePath
Assert-Equal 12 $t.Count 'all twelve themes are resolved'
Assert-Equal '#fdfdff' $t['blue'].Tokens['bg-1'] 'a light theme takes the :root paper'
Assert-Equal '#01090b' $t['sky'].Tokens['bg-1'] 'a dark theme takes the forced dark block, not the OS-followed one'
Assert-Equal '#ffc61a' $t['cyan'].Tokens['warning-3'] 'a status colour the dark block overrides reaches a dark theme'
Assert-Equal '#bb88aa' $t['rust'].Tokens['warning-3'] "a theme's own token wins, and #rgb is expanded and lowercased"
Assert-Equal '#e0761a' $t['teal'].Tokens['warning-3'] 'and a light theme without its own keeps the :root value'
Assert-True (-not $t['blue'].Tokens.Contains('spacing-1')) 'spacing is not a colour token'
Assert-True (-not $t['blue'].Tokens.Contains('shadow-pop')) 'nor is a shadow that contains an rgba()'
Assert-Equal 'bg-1,primary,warning-3' ($t['blue'].Tokens.Keys -join ',') 'the commented-out declaration is not read'

Write-Host '-- group 2: the model is the Figma file''s layout' -ForegroundColor Cyan
$m = Get-FigmaTokenModel -StylePath $fixturePath
Assert-Equal 'Color Modus Light|Color Modus Dark|Color Modus' (($m | ForEach-Object { $_.name }) -join '|') 'two palettes first, the semantic layer after them'
Assert-Equal 'magenta,purple,blue,teal,ochre,rust' ($m[0].modes -join ',') 'the light palette has one mode per light theme'
Assert-Equal 'pink,lilac,sky,cyan,yellow,orange' ($m[1].modes -join ',') 'and the dark palette one per dark theme'
Assert-Equal '#ffc61a' $m[1].variables['palette/warning-3']['cyan'] 'a palette value is the resolved hex under palette/<token>'
Assert-Equal 'Light,Dark' ($m[2].modes -join ',') 'the semantic layer has the modes Light and Dark'
Assert-Equal 'alias:Color Modus Dark::palette/primary' $m[2].variables['color/primary']['Dark'] 'color/<token> aliases the palette of its mode'
Assert-Equal 'FRAME_FILL,SHAPE_FILL,TEXT_FILL,STROKE_COLOR' ((Get-FigmaTokenScopes 'bg-3') -join ',') 'paper is a fill, a stroke and text on a primary fill'
Assert-Equal 'TEXT_FILL' ((Get-FigmaTokenScopes 'fg-1') -join ',') 'ink is text only'
Assert-Equal 'ALL_FILLS,STROKE_COLOR' ((Get-FigmaTokenScopes 'graph-2') -join ',') 'the rest fill and stroke'

Write-Host '-- group 3: the drift check' -ForegroundColor Cyan
$json = ConvertTo-FigmaTokenJson -Model $m
$same = ConvertFrom-FigmaTokenJson -Json $json
Assert-Equal 0 @(Compare-FigmaTokenModel -Expected $m -Actual $same).Count 'the model compared with its own JSON round trip is in sync'

$o = $json | ConvertFrom-Json
$o.collections[0].modes = @('rust', 'magenta', 'purple', 'blue', 'teal', 'ochre')
$reordered = ConvertFrom-FigmaTokenJson -Json ($o | ConvertTo-Json -Depth 6 -Compress)
Assert-Equal 0 @(Compare-FigmaTokenModel -Expected $m -Actual $reordered).Count 'mode order is not drift (the file holds purple before magenta)'

$o = $json | ConvertFrom-Json
$o.collections[0].variables.'palette/primary'.blue = '#0000FE'
$o.collections[0].variables.'palette/bg-1'.PSObject.Properties.Remove('teal')
$o.collections[0].variables | Add-Member -NotePropertyName 'palette/old' -NotePropertyValue ([pscustomobject]@{ blue = '#000000' })
$o.collections[1].variables.PSObject.Properties.Remove('palette/primary')
$o.collections[1].modes = @($o.collections[1].modes | Where-Object { $_ -ne 'sky' }) + 'neon'
$o.collections[2].variables.'color/primary'.Light = 'alias:Color Modus Dark::palette/primary'
$drift = ConvertFrom-FigmaTokenJson -Json (ConvertTo-Json -InputObject @{ collections = @($o.collections[0], $o.collections[1], $o.collections[2]) } -Depth 6 -Compress)
$f = @(Compare-FigmaTokenModel -Expected $m -Actual $drift)
$kinds = ($f | ForEach-Object { $_.Kind } | Sort-Object) -join ','
Assert-Equal 'differs,differs,differs,extra-mode,extra-variable,missing-mode,missing-variable' $kinds 'every kind of drift is found once, and nothing else'
$d = $f | Where-Object { $_.Kind -eq 'differs' -and $_.Variable -eq 'palette/primary' }
Assert-Equal '#0000fe' $d.Actual 'a differing value is reported as Figma holds it, lowercased'
Assert-True ($null -ne ($f | Where-Object { $_.Kind -eq 'differs' -and $_.Actual -eq '(none)' -and $_.Mode -eq 'teal' })) 'a value missing in one mode is a difference, not a crash'
Assert-True ($null -ne ($f | Where-Object { $_.Kind -eq 'differs' -and $_.Variable -eq 'color/primary' })) 'an alias pointing at the wrong palette is drift'
Assert-True (@($f | Where-Object { $_.Mode -eq 'sky' -and $_.Kind -eq 'differs' }).Count -eq 0) 'a missing mode is reported once, not again per variable'
Assert-True (@($f | ForEach-Object { Format-FigmaTokenFinding $_ } | Where-Object { -not $_ }).Count -eq 0) 'every finding formats to a line'
Assert-Equal 'missing-collection,missing-collection,missing-collection' ((@(Compare-FigmaTokenModel -Expected $m -Actual @()) | ForEach-Object { $_.Kind }) -join ',') 'a file without the collections reports each as missing'
$other = ConvertFrom-FigmaTokenJson -Json '{"collections":[{"name":"Wireframe","modes":["Default"],"variables":{"color/bg":{"Default":"#ffffff"}}}]}'
Assert-True (@(Compare-FigmaTokenModel -Expected $m -Actual ($same + $other)).Count -eq 0) "the file's other collections are never reported"

Write-Host '-- group 4: the real stylesheet and the script' -ForegroundColor Cyan
$real = Get-FigmaTokenModel -StylePath $Style
Assert-Equal 3 $real.Count 'the real stylesheet yields three collections'
Assert-True ($real[0].variables.Count -ge 22 -and $real[0].variables.Count -eq $real[1].variables.Count -and $real[2].variables.Count -eq $real[0].variables.Count) "both palettes and the semantic layer hold the same tokens ($($real[0].variables.Count))"
$hexOnly = @($real[0].variables.Values + $real[1].variables.Values | ForEach-Object { $_.Values } | Where-Object { $_ -notmatch '^#[0-9a-f]{6}$' })
Assert-Equal 0 $hexOnly.Count 'every palette value is a lowercase #rrggbb'
$palette = Get-HousePalette -Hue 317 -Mode light
Assert-Equal $palette['--primary'] $real[0].variables['palette/primary']['magenta'] "the palette holds what build-house-palette computes (magenta's primary)"

$readJs = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Script -Emit read-js) -join "`n"
Assert-True ($readJs -match [regex]::Escape('const names = ["Color Modus Light","Color Modus Dark","Color Modus"];')) 'the read script names the three collections'
Assert-True ($readJs -match 'return \{ collections: out \};' -and $readJs -notmatch 'setValueForMode|createVariable') 'the read script returns the shape -Compare reads, and writes nothing'
$syncJs = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Script -Emit sync-js) -join "`n"
Assert-True ($syncJs -match 'createVariableAlias' -and $syncJs -match 'setVariableCodeSyntax\(''WEB''') 'the sync script writes aliases and the WEB code syntax'
Assert-True ($syncJs -notmatch '\.remove\(\)') 'the sync script deletes nothing'
Assert-True ($syncJs.Length -lt 50000) "the sync script fits use_figma's 50,000-character limit ($($syncJs.Length))"
Assert-True ((($syncJs + $readJs).ToCharArray() | Where-Object { [int]$_ -gt 127 }).Count -eq 0) 'both scripts are ASCII'

$modelJson = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Script) -join "`n"
$inSync = Join-Path $tmp 'in-sync.json'
[System.IO.File]::WriteAllText($inSync, $modelJson)
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -Compare $inSync 2>&1
Assert-Equal 0 $LASTEXITCODE '-Compare exits 0 on a file in sync'
Assert-True ("$out" -match '\[OK\]') 'and says so'
$drifted = Join-Path $tmp 'drifted.json'
[System.IO.File]::WriteAllText($drifted, ($modelJson -replace '"palette/bg-1":\{"magenta":"#[0-9a-f]{6}"', '"palette/bg-1":{"magenta":"#123456"'))
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -Compare $drifted 2>&1
Assert-Equal 1 $LASTEXITCODE '-Compare exits 1 on drift'
Assert-True ("$out" -match 'magenta / palette/bg-1: Figma #123456') 'and names the value Figma holds'

Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
Write-Host ''
Write-Host "figma-tokens: $script:pass passed, $script:fail failed."
if ($script:fail) { exit 1 }
exit 0
