<#
.SYNOPSIS
    The brand book's colour tokens as Figma variables (#4038): the model the repo holds, the drift check against what
    a Figma file holds, and the two Plugin API scripts the session runs through the Figma MCP's use_figma.

.DESCRIPTION
    ONE direction: house-style.css is the source and Figma is a mirror. A computed colour edited in Figma would
    bypass the contrast floors build-house-palette.ps1 enforces, so nothing here ever reads a Figma value back
    into the stylesheet; a change wanted in Figma becomes an issue on the brand book.

    Scope (the owner, November 13, 2026, on #4038): the colour tokens only -- every custom property whose value
    is a #rrggbb colour. Spacing, radius and type are not mirrored.

    Resolution, per theme, exactly as the browser resolves it: a light theme is the :root block plus its own
    theme line; a dark theme is :root, then the forced dark block, then its own theme line. So a status colour
    the dark block overrides, and a theme's own --warning-3, both reach the right mode.

    The layout is the one the brand book's Figma file (w44J5aQPeST96RJ71vU3ev) already held when this was built,
    measured November 13, 2026, so the sync keeps it rather than inventing a parallel one:
      Color / Palette light, Color / Palette dark   primitives: one mode per theme, palette/<token>, hidden from
                                                    the pickers (no scope), no code syntax
      Color / Theme                                 the semantic layer: modes Light and Dark, color/<token>, each an
                                                    alias to palette/<token> in the palette of that mode, with the
                                                    token's scopes and var(--<token>) as WEB code syntax
    Six modes in one collection is therefore measured on the owner's plan, not assumed (#4038's question 1).

    Pure ASCII (repo convention for .ps1).
#>

. (Join-Path $PSScriptRoot 'house-palette-lib.ps1')

function Get-FigmaTokenNames {
    @{ Palette = @{ light = 'Color / Palette light'; dark = 'Color / Palette dark' }; Theme = 'Color / Theme'; ThemeModes = @{ light = 'Light'; dark = 'Dark' } }
}

# The scopes a semantic variable carries, by token family -- the file's own convention: paper is a fill, a
# stroke and the text on a primary fill; ink is text only; the rest fills and strokes.
function Get-FigmaTokenScopes {
    param([Parameter(Mandatory)][string]$Token)
    if ($Token -match '^bg-\d$') { return @('FRAME_FILL', 'SHAPE_FILL', 'TEXT_FILL', 'STROKE_COLOR') }
    if ($Token -match '^fg-\d$') { return @('TEXT_FILL') }
    @('ALL_FILLS', 'STROKE_COLOR')
}

# The colour declarations of one CSS block body, in source order: token name (without --) -> lowercase #rrggbb.
function Get-CssColourDeclarations {
    param([string]$Body)
    $out = [ordered]@{}
    foreach ($d in [regex]::Matches($Body, '--([a-z][\w-]*)\s*:\s*([^;]+);')) {
        $v = $d.Groups[2].Value.Trim().ToLowerInvariant()
        if ($v -match '^#([0-9a-f])([0-9a-f])([0-9a-f])$') { $v = '#' + ($Matches[1] * 2) + ($Matches[2] * 2) + ($Matches[3] * 2) }
        if ($v -match '^#[0-9a-f]{6}$') { $out[$d.Groups[1].Value] = $v }
    }
    $out
}

# Every theme's resolved colour tokens: theme id -> @{ Mode; Tokens = ordered token -> hex }.
function Get-HouseColourTokens {
    param([Parameter(Mandatory)][string]$StylePath)
    $css = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $StylePath).Path)
    $bare = $css -replace '(?s)/\*.*?\*/', ''
    $base = $null; $dark = $null; $lines = @{}
    # [^{}]+ cannot cross a brace, so a block nested in @media is read from its own selector on
    foreach ($b in [regex]::Matches($bare, '([^{}]+)\{([^{}]*)\}')) {
        $sel = ($b.Groups[1].Value -replace '\s+', ' ').Trim()
        if ($sel -eq ':root') { if ($null -eq $base) { $base = Get-CssColourDeclarations $b.Groups[2].Value } }
        elseif ($sel.StartsWith(':root[data-theme="dark"]')) { $dark = Get-CssColourDeclarations $b.Groups[2].Value }
        elseif ($sel -match '^:root\[data-theme="([a-z]+)"\], \.theme-swatch\[data-id="\1"\]$') { $lines[$Matches[1]] = Get-CssColourDeclarations $b.Groups[2].Value }
    }
    if ($null -eq $base) { throw "no :root block in $StylePath" }
    if ($null -eq $dark) { throw "no forced dark block (:root[data-theme=`"dark`"]) in $StylePath" }
    $themes = [ordered]@{}
    foreach ($t in Get-HousePaletteThemes) {
        if (-not $lines.ContainsKey($t.Id)) { throw "no theme line for '$($t.Id)' in $StylePath" }
        $r = [ordered]@{}
        $layers = if ($t.Mode -eq 'dark') { @($base, $dark, $lines[$t.Id]) } else { @($base, $lines[$t.Id]) }
        foreach ($layer in $layers) { foreach ($k in $layer.Keys) { $r[$k] = $layer[$k] } }
        $themes[$t.Id] = @{ Mode = $t.Mode; Tokens = $r }
    }
    $themes
}

# The value an alias is written as, in the model and in what the read script returns.
function Format-FigmaTokenAlias { param([string]$Collection, [string]$Variable) "alias:$Collection::$Variable" }

# The model the Figma file should hold: an array of collections, each @{ name; modes; variables = ordered name ->
# ordered mode -> value }, a value being #rrggbb or an alias. The palettes come first, so the sync has the alias
# targets before the semantic layer needs them.
function Get-FigmaTokenModel {
    param([Parameter(Mandatory)][string]$StylePath)
    $themes = Get-HouseColourTokens -StylePath $StylePath
    $n = Get-FigmaTokenNames
    $collections = @()
    $tokens = @()
    foreach ($mode in 'light', 'dark') {
        $ids = @($themes.Keys | Where-Object { $themes[$_].Mode -eq $mode })
        $vars = [ordered]@{}
        foreach ($id in $ids) {
            foreach ($k in $themes[$id].Tokens.Keys) {
                if (-not $vars.Contains("palette/$k")) { $vars["palette/$k"] = [ordered]@{} }
                $vars["palette/$k"][$id] = $themes[$id].Tokens[$k]
                if ($tokens -notcontains $k) { $tokens += $k }
            }
        }
        $collections += , ([ordered]@{ name = $n.Palette[$mode]; modes = $ids; variables = $vars })
    }
    $sem = [ordered]@{}
    foreach ($k in $tokens) {
        $sem["color/$k"] = [ordered]@{}
        foreach ($mode in 'light', 'dark') { $sem["color/$k"][$n.ThemeModes[$mode]] = Format-FigmaTokenAlias $n.Palette[$mode] "palette/$k" }
    }
    $collections += , ([ordered]@{ name = $n.Theme; modes = @($n.ThemeModes.light, $n.ThemeModes.dark); variables = $sem })
    , $collections
}

# Read a model back from JSON (the shape the read script returns) into the same ordered shape. A hex value is
# lowercased; an alias keeps its case, since it carries collection and variable names.
function ConvertFrom-FigmaTokenJson {
    param([Parameter(Mandatory)][string]$Json)
    $o = $Json | ConvertFrom-Json
    $list = if ($o.PSObject.Properties.Name -contains 'collections') { @($o.collections) } else { @($o) }
    $out = @()
    foreach ($c in $list) {
        $vars = [ordered]@{}
        if ($c.variables) {
            foreach ($p in $c.variables.PSObject.Properties) {
                $m = [ordered]@{}
                foreach ($q in $p.Value.PSObject.Properties) { $v = "$($q.Value)"; $m[$q.Name] = if ($v.StartsWith('#')) { $v.ToLowerInvariant() } else { $v } }
                $vars[$p.Name] = $m
            }
        }
        $out += , ([ordered]@{ name = "$($c.name)"; modes = @($c.modes | ForEach-Object { "$_" }); variables = $vars })
    }
    , $out
}

# Drift between the model and what Figma holds. Only the collections the model names are compared, so the file's
# other collections (Wireframe, Scale, a library's) are never reported, and mode ORDER is not drift. Returns
# findings, empty when in sync: @{ Kind = missing-collection|missing-mode|extra-mode|missing-variable|
# extra-variable|differs; Collection; Mode; Variable; Expected; Actual }.
function Compare-FigmaTokenModel {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Expected, [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Actual)
    $find = New-Object System.Collections.Generic.List[object]
    $byName = @{}; foreach ($a in $Actual) { $byName[$a.name] = $a }
    foreach ($e in $Expected) {
        $a = $byName[$e.name]
        if ($null -eq $a) { $find.Add(@{ Kind = 'missing-collection'; Collection = $e.name }); continue }
        foreach ($m in $e.modes) { if ($a.modes -notcontains $m) { $find.Add(@{ Kind = 'missing-mode'; Collection = $e.name; Mode = $m }) } }
        foreach ($m in $a.modes) { if ($e.modes -notcontains $m) { $find.Add(@{ Kind = 'extra-mode'; Collection = $e.name; Mode = $m }) } }
        foreach ($v in $e.variables.Keys) {
            if (-not $a.variables.Contains($v)) { $find.Add(@{ Kind = 'missing-variable'; Collection = $e.name; Variable = $v }); continue }
            foreach ($m in $e.modes) {
                if ($a.modes -notcontains $m) { continue }   # already reported as a missing mode
                $want = $e.variables[$v][$m]; $got = $a.variables[$v][$m]
                if ("$want" -cne "$got") { $find.Add(@{ Kind = 'differs'; Collection = $e.name; Mode = $m; Variable = $v; Expected = $want; Actual = $(if ($got) { $got } else { '(none)' }) }) }
            }
        }
        foreach ($v in $a.variables.Keys) { if (-not $e.variables.Contains($v)) { $find.Add(@{ Kind = 'extra-variable'; Collection = $e.name; Variable = $v }) } }
    }
    $find.ToArray()   # unwrapped: a caller writes @(Compare-FigmaTokenModel ...), so in sync is an empty array
}

function Format-FigmaTokenFinding {
    param([Parameter(Mandatory)][hashtable]$Finding)
    $f = $Finding
    switch ($f.Kind) {
        'missing-collection' { "missing collection '$($f.Collection)'" }
        'missing-mode'       { "'$($f.Collection)': missing mode '$($f.Mode)'" }
        'extra-mode'         { "'$($f.Collection)': mode '$($f.Mode)' is not in the stylesheet" }
        'missing-variable'   { "'$($f.Collection)': missing variable '$($f.Variable)'" }
        'extra-variable'     { "'$($f.Collection)': variable '$($f.Variable)' is not a colour token of the stylesheet" }
        'differs'            { "'$($f.Collection)' / $($f.Mode) / $($f.Variable): Figma $($f.Actual), repo $($f.Expected)" }
    }
}

# The JSON a script embeds: compact, ASCII.
function ConvertTo-FigmaTokenJson {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Model)
    ConvertTo-Json -InputObject @{ collections = $Model } -Depth 6 -Compress
}

# The read script for use_figma: returns the named collections only, each COLOR variable's value per mode as
# #rrggbb (#rrggbbaa below full alpha) or alias:<collection>::<variable>, in the shape ConvertFrom-FigmaTokenJson
# reads. Small enough to return whole: three collections of 25 variables.
function Get-FigmaTokenReadScript {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Model)
    $names = ConvertTo-Json -InputObject @($Model | ForEach-Object { $_.name }) -Compress
    @"
const names = $names;
const hex = (x) => Math.round(x * 255).toString(16).padStart(2, '0');
const all = await figma.variables.getLocalVariableCollectionsAsync();
const collName = Object.fromEntries(all.map((c) => [c.id, c.name]));
const out = [];
for (const c of all.filter((c) => names.includes(c.name))) {
  const vars = await Promise.all(c.variableIds.map((id) => figma.variables.getVariableByIdAsync(id)));
  const variables = {};
  for (const v of vars) {
    if (!v || v.resolvedType !== 'COLOR') continue;
    const row = {};
    for (const m of c.modes) {
      const val = v.valuesByMode[m.modeId];
      if (val && val.type === 'VARIABLE_ALIAS') {
        const t = await figma.variables.getVariableByIdAsync(val.id);
        row[m.name] = t ? 'alias:' + (collName[t.variableCollectionId] || t.variableCollectionId) + '::' + t.name : 'alias:?::' + val.id;
      } else if (val && 'r' in val) {
        row[m.name] = '#' + hex(val.r) + hex(val.g) + hex(val.b) + ('a' in val && val.a < 1 ? hex(val.a) : '');
      }
    }
    variables[v.name] = row;
  }
  out.push({ name: c.name, modes: c.modes.map((m) => m.name), variables });
}
return { collections: out };
"@
}

# The sync script for use_figma: makes each collection the model names hold the model's modes and values. It
# creates what is missing and overwrites what differs; it deletes nothing -- an extra variable or mode is the
# drift check's to report and a person's to remove. A new palette variable is hidden (no scope), as the file's
# primitives are; a new semantic variable gets its family's scopes and var(--<token>) as WEB code syntax.
function Get-FigmaTokenSyncScript {
    param([Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Model)
    $json = ConvertTo-FigmaTokenJson -Model $Model
    $scopes = [ordered]@{}
    foreach ($c in $Model) { foreach ($v in $c.variables.Keys) { if ($v -like 'color/*') { $scopes[$v] = @(Get-FigmaTokenScopes ($v -replace '^color/', '')) } } }
    $scopeJson = ConvertTo-Json -InputObject $scopes -Depth 3 -Compress
    @"
const model = $json;
const scopes = $scopeJson;
const ch = (h, i) => parseInt(h.slice(i, i + 2), 16);
const rgba = (h) => ({ r: ch(h, 1) / 255, g: ch(h, 3) / 255, b: ch(h, 5) / 255, a: 1 });
const sameColour = (a, h) => a && !('type' in a) && Math.round(a.r * 255) === ch(h, 1) && Math.round(a.g * 255) === ch(h, 3) && Math.round(a.b * 255) === ch(h, 5) && (!('a' in a) || a.a === 1);
const all = await figma.variables.getLocalVariableCollectionsAsync();
const report = [];
const byPath = {};
for (const want of model.collections) {
  let c = all.find((x) => x.name === want.name);
  const created = !c;
  if (!c) { c = figma.variables.createVariableCollection(want.name); c.renameMode(c.modes[0].modeId, want.modes[0]); }
  for (const m of want.modes) { if (!c.modes.some((x) => x.name === m)) c.addMode(m); }
  const modeId = Object.fromEntries(c.modes.map((m) => [m.name, m.modeId]));
  const existing = (await Promise.all(c.variableIds.map((id) => figma.variables.getVariableByIdAsync(id)))).filter((v) => v);
  const byName = Object.fromEntries(existing.map((v) => [v.name, v]));
  let made = 0, written = 0, unchanged = 0;
  for (const [name, values] of Object.entries(want.variables)) {
    let v = byName[name];
    if (!v) {
      v = figma.variables.createVariable(name, c, 'COLOR');
      if (scopes[name]) { v.scopes = scopes[name]; v.setVariableCodeSyntax('WEB', 'var(--' + name.replace(/^color\//, '') + ')'); } else { v.scopes = []; }
      made++;
    }
    byPath[want.name + '::' + name] = v;
    for (const [mode, value] of Object.entries(values)) {
      const cur = v.valuesByMode[modeId[mode]];
      if (value.startsWith('alias:')) {
        const target = byPath[value.slice(6)];
        if (!target) throw new Error('alias target ' + value.slice(6) + ' is not in the model');
        if (cur && cur.type === 'VARIABLE_ALIAS' && cur.id === target.id) { unchanged++; continue; }
        v.setValueForMode(modeId[mode], figma.variables.createVariableAlias(target));
      } else {
        if (sameColour(cur, value)) { unchanged++; continue; }
        v.setValueForMode(modeId[mode], rgba(value));
      }
      written++;
    }
  }
  const extra = existing.map((v) => v.name).filter((n) => !(n in want.variables));
  report.push({ collection: c.name, createdCollection: created, modes: c.modes.map((m) => m.name), variablesCreated: made, valuesWritten: written, valuesUnchanged: unchanged, extraVariables: extra });
}
return { report };
"@
}
