<#
.SYNOPSIS
    The pure logic of the theme-reference check -- which sections a Shopify theme calls, which it
    calls without having, and which nothing calls -- one mechanism for the two BWJ stores.

.DESCRIPTION
    Dot-source this from scripts/task/check-theme-refs.ps1 or from a suite:

        . (Join-Path $PSScriptRoot '..\lib\theme-refs-rules.ps1')
        $report = Get-ThemeRefReport -Root $themeRoot

    WHY IT SHIPS HERE (issue #4272, step 2 of #4259; Dave's ruling of September 11, 2026 on #1881:
    anything the two stores share goes to dkj-repo-workflow-bwj). Both stores carried their own copy of
    this check and the copies had diverged -- one counted section groups as sections, one scanned for
    "type" with a regex, one never recursed into templates/, one was in Dutch. The reconciliation per
    behaviour is in the issue; the short form is that each behaviour takes whichever copy was measured
    to be more correct.

    WHY THE CHECK EXISTS AT ALL: '.theme-check.yml' runs on 'extends: nothing' in both stores, because the
    full check set is red on arrival, so a template that points at a removed section slips through
    'shopify theme check' with 0 offenses and only a real 'theme push' complains. Read-only, offline.

    THIS FILE HOLDS NO STORE FACT. It reads a theme tree it is handed and nothing else: no domain, no
    theme id, no market table. The one thing a store may add is an allowlist of accepted findings, and
    that is the optional seam Get-ThemeRefsAllowedMissing in the store's scripts/repo-config.ps1, read
    by the caller script and never by this file.

    The categories, in the letters the report uses:

      A. MISSING SECTION (error)      a template or section group names a section type that has no
                                      sections/<type>.liquid. The page breaks SILENTLY (a gap, HTTP 200).
         MISSING GROUP (error)        {% sections 'x' %} names a group with no sections/x.json.
      B. UNCALLED SECTION (warning)   a section nothing calls. Only a section WITHOUT presets counts: one
                                      with presets is addable in the theme editor, so being unplaced is
                                      its normal state. A group nothing calls is listed with these.
      C. TRAILING COMMA (warning)     Shopify swallows it, strict parsers do not.
      D. UNPARSEABLE (error)          not parseable even after tolerating C.
      E. RAW CONTROL CHARACTER IN A STRING (error)
                                      the one category that does NOT lean on ConvertFrom-Json: Windows
                                      PowerShell 5.1 accepts a real newline inside a string literal,
                                      while 'shopify theme push' refuses the file as Invalid JSON.

    Pure ASCII (repo convention for .ps1). Windows PowerShell 5.1 compatible, and written to survive
    Set-StrictMode -Version Latest in the caller.
#>

# Section types Shopify provides itself, which therefore have no file in sections/ and are never a
# finding. '_blocks' is the wrapper section that renders theme blocks and nothing else: established
# from a real theme (it appears in page-builder output, there is no such file anywhere in the tree, and
# every child of it is a theme block that does exist in blocks/), and without it half of the findings
# on that theme were this one name.
$script:ThemeRefReservedTypes = @('_blocks')

# The file kinds worth searching for dynamic-render evidence. Binary assets (fonts, images) are left out:
# reading them as text is slow and can only produce coincidental matches.
$script:ThemeRefTextExtensions = @('.js', '.mjs', '.ts', '.liquid', '.json', '.css', '.html')

function Get-JsonControlCharFinding {
    <#
        An UNESCAPED control character inside a JSON string -- the error ConvertFrom-Json (Windows
        PowerShell 5.1) swallows and Shopify does not. Measured: the same text gives node 'Bad control
        character in string literal', and 'shopify theme push' refuses the file with 'Invalid JSON'.

        JSON allows only ESCAPED control characters inside a string. OUTSIDE a string the very same
        characters are ordinary layout (newlines, tabs, indentation), so position is everything: the
        text is walked and a string/escape state is kept. /* */ and // comments outside a string are
        skipped, so a quote character inside a banner cannot flip the state.

        The line number belongs to the character being examined, so the counter goes up only after a
        newline has been handled -- otherwise exactly the error looked for (a raw newline in a string)
        would be reported one line too low. Calibrated against node's own 'line N' on the same text.

        Returns a list of objects with Line and Char (the character's name); empty when clean. A raw
        newline never closes the string, so a file with several cases reports them all.
    #>
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Text)

    $found    = New-Object System.Collections.ArrayList
    $inString = $false
    $escaped  = $false
    $comment  = ''
    $line     = 1
    $n        = $Text.Length

    for ($i = 0; $i -lt $n; $i++) {
        $c = $Text[$i]
        $lineOfChar = $line
        if ($c -eq "`n") { $line++ }

        if ($comment -eq 'block') {
            if ($c -eq '*' -and ($i + 1) -lt $n -and $Text[$i + 1] -eq '/') { $comment = ''; $i++ }
            continue
        }
        if ($comment -eq 'line') {
            if ($c -eq "`n") { $comment = '' }
            continue
        }
        if ($escaped) { $escaped = $false; continue }

        if ($inString) {
            if ($c -eq '\') { $escaped = $true; continue }
            if ($c -eq '"') { $inString = $false; continue }
            if ([int]$c -lt 0x20) {
                $name = switch ([int]$c) {
                    0x0A    { 'newline (0x0A)' }
                    0x0D    { 'carriage return (0x0D)' }
                    0x09    { 'tab (0x09)' }
                    default { ('0x{0:X2}' -f [int]$c) }
                }
                $null = $found.Add([pscustomobject]@{ Line = $lineOfChar; Char = $name })
            }
            continue
        }

        if ($c -eq '"') { $inString = $true; continue }
        if ($c -eq '/' -and ($i + 1) -lt $n) {
            $next = $Text[$i + 1]
            if ($next -eq '*') { $comment = 'block'; $i++ }
            elseif ($next -eq '/') { $comment = 'line'; $i++ }
        }
    }
    return $found
}

function Read-ThemeJson {
    <#
        Read a Shopify template or section-group file and say what was wrong with its shape.

        These files are not strict JSON. Shopify writes a /* */ banner at the top, and the theme editor
        leaves // lines behind when somebody comments a section out -- and the commas of the removed
        section with them, which is a trailing comma. Shopify swallows both; ConvertFrom-Json does not.
        So what Shopify tolerates is tolerated here, and the fact that it was needed is handed back:
        a trailing comma is still invalid JSON and a trap for every other strict reader.

        ONLY A LEADING BANNER IS STRIPPED, never a /* */ anywhere in the file: a block-comment strip
        over the whole text also eats the text of a string value that happens to contain one (custom
        CSS settings do), and then parses a file that is not the file Shopify reads.

        Returns Data (the parsed object, or $null), TrailingComma (bool), Empty (bool: nothing but
        comments or whitespace -- nothing to check, which is not a failure) and Raw (the text as read,
        for the control-character pass). Throws when the text is unparseable even after the tolerance.
    #>
    param([Parameter(Mandatory = $true)][string]$FilePath)

    $raw = Get-Content -LiteralPath $FilePath -Raw -Encoding UTF8
    if (-not $raw) { return [pscustomobject]@{ Data = $null; TrailingComma = $false; Empty = $true; Raw = '' } }

    $text = [regex]::Replace($raw, '^(?:\s*/\*.*?\*/)+\s*', '', 'Singleline')
    $text = [regex]::Replace($text, '(?m)^[ \t]*//.*$', '')
    if (-not $text.Trim()) { return [pscustomobject]@{ Data = $null; TrailingComma = $false; Empty = $true; Raw = $raw } }

    try {
        $data = $text | ConvertFrom-Json -ErrorAction Stop
        return [pscustomobject]@{ Data = $data; TrailingComma = $false; Empty = $false; Raw = $raw }
    } catch {
        # Second try with trailing commas removed (a comma directly before } or ]). When this fails
        # as well it throws to the caller, which reports the file as unparseable.
        $fixed = [regex]::Replace($text, ',(\s*[}\]])', '$1')
        $data  = $fixed | ConvertFrom-Json -ErrorAction Stop
        return [pscustomobject]@{ Data = $data; TrailingComma = $true; Empty = $false; Raw = $raw }
    }
}

function Get-ThemeJsonProperty {
    <# One property of a parsed JSON node, or $null when it is absent -- safe under StrictMode, where a
       dotted read of a property that is not there throws. #>
    param($Node, [string]$Name)
    if ($null -eq $Node) { return $null }
    $p = $Node.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Get-ThemeRelPath {
    <# A path relative to the theme root, with forward slashes, for a message a person reads. #>
    param([string]$Root, [string]$Full)
    if ($Full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return (($Full.Substring($Root.Length).TrimStart('\', '/')) -replace '\\', '/')
    }
    return ($Full -replace '\\', '/')
}

function Get-ThemeRefReport {
    <#
        The whole report as an object, so a suite can hold the very logic the gate runs.

        WHAT COUNTS AS A SECTION: only sections/<type>.liquid. The .json files in sections/ are section
        GROUPS -- consumers of sections, called by name with {% sections 'x' %} -- and a template that
        names a group as a section type is a missing section, which counting groups as sections would
        have hidden.

        WHAT COUNTS AS A REFERENCE, by parsing and not by grepping: only the 'type' directly under
        sections.<id> of a template or group. A regex for '"type": "..."' over the same files reported
        1407 missing sections on a real theme, because every BLOCK inside every section carries a 'type'
        too and a block type is not a section.

        Missing is an ordered map: type -> list of 'file (section 'id')' strings.
    #>
    param([Parameter(Mandatory = $true)][string]$Root)

    $secDir = Join-Path $Root 'sections'
    $tplDir = Join-Path $Root 'templates'
    $layDir = Join-Path $Root 'layout'

    $defined = @{}   # section type -> $true, from sections/*.liquid
    $groups  = @{}   # group name   -> $true, from sections/*.json
    if (Test-Path -LiteralPath $secDir) {
        foreach ($f in @(Get-ChildItem -LiteralPath $secDir -File)) {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
            if ($f.Extension -eq '.liquid') { $defined[$base] = $true }
            elseif ($f.Extension -eq '.json') { $groups[$base] = $true }
        }
    }

    $used          = @{}   # section type -> how it is used
    $groupsCalled  = @{}
    $missing       = @{}
    $missingGroups = @{}
    $unparseable   = New-Object System.Collections.ArrayList
    $trailing      = New-Object System.Collections.ArrayList
    $ctrlChars     = New-Object System.Collections.ArrayList

    # --- JSON consumers: templates (recursive: templates/customers/*.json is real) and groups --------
    $jsonFiles = @()
    if (Test-Path -LiteralPath $tplDir) { $jsonFiles += @(Get-ChildItem -LiteralPath $tplDir -Filter '*.json' -File -Recurse) }
    if (Test-Path -LiteralPath $secDir) { $jsonFiles += @(Get-ChildItem -LiteralPath $secDir -Filter '*.json' -File) }

    foreach ($f in $jsonFiles) {
        $rel = Get-ThemeRelPath -Root $Root -Full $f.FullName
        $res = $null
        try { $res = Read-ThemeJson -FilePath $f.FullName }
        catch {
            $null = $unparseable.Add($rel)
            # An unparseable file can still hold a raw control character, and saying so helps.
            $rawText = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
            if ($rawText) {
                foreach ($v in @(Get-JsonControlCharFinding -Text $rawText)) {
                    $null = $ctrlChars.Add([pscustomobject]@{ File = $rel; Line = $v.Line; Char = $v.Char })
                }
            }
            continue
        }
        if ($res.TrailingComma) { $null = $trailing.Add($rel) }

        # The strict pass runs on the RAW text and beside the parse, because the parse is blind to it.
        foreach ($v in @(Get-JsonControlCharFinding -Text $res.Raw)) {
            $null = $ctrlChars.Add([pscustomobject]@{ File = $rel; Line = $v.Line; Char = $v.Char })
        }

        $sections = Get-ThemeJsonProperty -Node $res.Data -Name 'sections'
        if ($null -eq $sections) { continue }
        foreach ($p in $sections.PSObject.Properties) {
            $type = Get-ThemeJsonProperty -Node $p.Value -Name 'type'
            # '.context.*' variants often carry only setting overrides, so a missing type is normal.
            if (-not $type) { continue }
            $type = [string]$type
            if (-not $used.ContainsKey($type)) { $used[$type] = 'template or group' }
            if ($script:ThemeRefReservedTypes -contains $type) { continue }
            if (-not $defined.ContainsKey($type)) {
                if (-not $missing.ContainsKey($type)) { $missing[$type] = New-Object System.Collections.ArrayList }
                $null = $missing[$type].Add(("{0} (section '{1}')" -f $rel, $p.Name))
            }
        }
    }

    # --- Liquid consumers: {% section 'x' %} and {% sections 'x-group' %}, either quote style ---------
    $liquidFiles = @()
    foreach ($d in @($tplDir, $layDir, $secDir)) {
        if (Test-Path -LiteralPath $d) { $liquidFiles += @(Get-ChildItem -LiteralPath $d -Filter '*.liquid' -File -Recurse) }
    }
    foreach ($f in $liquidFiles) {
        $rel   = Get-ThemeRelPath -Root $Root -Full $f.FullName
        $raw   = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
        if (-not $raw) { continue }
        $lines = $raw -split "`r?`n"
        for ($i = 0; $i -lt $lines.Count; $i++) {
            foreach ($m in [regex]::Matches($lines[$i], "{%-?\s*section\s+['""]([^'""]+)['""]")) {
                $type = $m.Groups[1].Value
                if (-not $used.ContainsKey($type)) { $used[$type] = 'liquid' }
                if ($script:ThemeRefReservedTypes -contains $type) { continue }
                if (-not $defined.ContainsKey($type)) {
                    if (-not $missing.ContainsKey($type)) { $missing[$type] = New-Object System.Collections.ArrayList }
                    $null = $missing[$type].Add(("{0} (line {1})" -f $rel, ($i + 1)))
                }
            }
            foreach ($m in [regex]::Matches($lines[$i], "{%-?\s*sections\s+['""]([^'""]+)['""]")) {
                $group = $m.Groups[1].Value
                $groupsCalled[$group] = $true
                if (-not $groups.ContainsKey($group)) {
                    if (-not $missingGroups.ContainsKey($group)) { $missingGroups[$group] = New-Object System.Collections.ArrayList }
                    $null = $missingGroups[$group].Add(("{0} (line {1})" -f $rel, ($i + 1)))
                }
            }
        }
    }

    # A '<group>.context.<market>' variant is looked up by Shopify itself next to its base group and is
    # never called by name, so it is called when its base is. The market part is a locale-ish token
    # ('nl', 'nl-gb'), not just letters.
    $uncalledGroups = New-Object System.Collections.ArrayList
    foreach ($g in ($groups.Keys | Sort-Object)) {
        if ($groupsCalled.ContainsKey($g)) { continue }
        if ($g -match '^(.+)\.context\.[A-Za-z0-9_-]+$' -and $groupsCalled.ContainsKey($Matches[1])) { continue }
        $null = $uncalledGroups.Add($g)
    }

    # --- Sections that live without being on a template ---------------------------------------------
    # Two signals, deliberately only these two: they are precise, where 'the name occurs somewhere in
    # the JS' is not (that older heuristic called a section alive purely because assets/<name>.js, its
    # own companion file, sat beside it).
    #   1. Section Rendering API:  ?section_id=<name>  in liquid or JS.
    #   2. Cart Sections API:      the name quoted on a line that also mentions 'sections', e.g.
    #                              sectionsToBundle = ["variant-added"].
    $texts = @{}
    foreach ($d in @('assets', 'sections', 'templates', 'layout', 'snippets', 'blocks')) {
        $dir = Join-Path $Root $d
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        foreach ($f in @(Get-ChildItem -LiteralPath $dir -File -Recurse)) {
            if ($script:ThemeRefTextExtensions -notcontains $f.Extension.ToLowerInvariant()) { continue }
            $t = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
            if ($t) { $texts[$f.FullName] = $t }
        }
    }

    $orphans = New-Object System.Collections.ArrayList
    foreach ($s in ($defined.Keys | Sort-Object)) {
        if ($used.ContainsKey($s)) { continue }

        $viaApi = $null
        # The name is escaped, and the section_id match is bounded on the right: 'section_id=foo' must
        # not count as evidence for a section called 'foo-bar' ... nor the reverse.
        $esc   = [regex]::Escape($s)
        $rxSra = [regex]("section_id=" + $esc + "(?![A-Za-z0-9_-])")
        # (?m) because ^ would otherwise anchor to the whole file, not to a line; and the boundary
        # goes only BEFORE 'sections', since 'sectionsToBundle' has a word character straight after it.
        $rxCart = [regex]('(?im)^.*\bsections.*["'']' + $esc + '["''].*$')
        foreach ($path in $texts.Keys) {
            # A section's own file and its own companion assets are not evidence that it is rendered.
            if ([System.IO.Path]::GetFileNameWithoutExtension($path) -eq $s) { continue }
            $t = $texts[$path]
            if ($rxSra.IsMatch($t))  { $viaApi = 'section-rendering-api'; break }
            if ($rxCart.IsMatch($t)) { $viaApi = 'cart-sections-api'; break }
        }
        if ($viaApi) { $used[$s] = $viaApi; continue }

        # A section with presets is ADDABLE in the theme editor, so not being on a template is its
        # normal state -- somebody drops it in the moment they need it. Measured on a real theme: all
        # thirteen 'orphans' had presets, standard building blocks included, and thirteen warnings
        # none of which asked for action is exactly how a check loses its credibility.
        $hasPresets = $false
        $file = Join-Path $secDir ($s + '.liquid')
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            $content = Get-Content -LiteralPath $file -Raw -Encoding UTF8
            if ($content -and $content -match '"presets"') { $hasPresets = $true }
        }
        $null = $orphans.Add([pscustomobject]@{ Section = $s; HasPresets = $hasPresets })
    }

    return [pscustomobject]@{
        SectionCount    = $defined.Count
        UsedCount       = $used.Count
        Missing         = $missing
        MissingGroups   = $missingGroups
        Orphans         = $orphans
        UncalledGroups  = $uncalledGroups
        Unparseable     = $unparseable
        TrailingCommas  = $trailing
        ControlChars    = $ctrlChars
    }
}
