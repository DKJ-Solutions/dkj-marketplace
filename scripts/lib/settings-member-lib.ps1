<#
.SYNOPSIS
    Read a Claude Code settings file and add ONE top-level member to it as text, leaving every other
    byte alone (issues #2505, #4341).

.DESCRIPTION
    Dot-source this file:

        . (Join-Path $PSScriptRoot 'settings-member-lib.ps1')

    It needs Get-DocumentNewline (document-newline-lib.ps1) loaded first.

    ONE COPY OF THE INSERT, FOR EVERY adopt-* PART THAT ADDS A SETTINGS KEY. adopt-statusline (Part 5)
    carried it inline from #2505; adopt-auto-memory (Part 6, #4341) is the second caller, so it moved
    here rather than being typed twice.

    ADDITIVE MEANS THE BYTES, NOT ONLY THE KEYS (#2505). A ConvertFrom-Json / ConvertTo-Json round trip
    keeps every key and loses every line: Windows PowerShell 5.1's serialiser re-pads each member and
    drops blank lines, so a one-key addition came back as a full-file diff nobody could review. So the
    member is INSERTED as text before the root object's closing brace, in the file's own indent unit and
    line ending. Read-SettingsFile reports a BOM so the caller can write one back where there was one.

    THE CALLER VERIFIES. Add-SettingsMember is text surgery on somebody else's file, so every caller
    parses the result back and writes nothing unless it is the same keys plus the one it added.

    Pure ASCII (repo convention for .ps1).
#>

function Read-SettingsFile {
    <# Reads a settings file as BYTES, so a BOM can be written back exactly as it was found.
       Returns @{ Exists; Readable; Text; HadBom; Parsed } -- Parsed is $null for a missing or blank file
       and Readable is $false for one that does not parse as JSON. #>
    param([Parameter(Mandatory = $true)][string]$Path)
    $result = @{ Exists = $false; Readable = $true; Text = ''; HadBom = $false; Parsed = $null }
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $result }
    $result.Exists = $true
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        $result.HadBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        $offset = $(if ($result.HadBom) { 3 } else { 0 })
        $result.Text = (New-Object System.Text.UTF8Encoding($false)).GetString($bytes, $offset, $bytes.Length - $offset)
        if ($result.Text.Trim()) { $result.Parsed = $result.Text | ConvertFrom-Json }
    } catch {
        $result.Readable = $false
    }
    return $result
}

function Get-SettingsMemberNames {
    <# The top-level member names of a parsed settings object -- none for $null and for '{}'. Callers
       wrap the call in @(), since a function returning @() hands back $null. Not
       '.PSObject.Properties.Name': under StrictMode that member enumeration THROWS on an object with
       no properties, which crashed -Apply on an empty settings file (#2505). #>
    param($Object)
    # A non-object root (an array, a scalar) has no members: its PSObject properties are Count, Length...
    if ($null -eq $Object -or $Object -is [array] -or $Object -is [ValueType] -or $Object -is [string]) { return @() }
    return @($Object.PSObject.Properties | ForEach-Object { $_.Name })
}

function ConvertTo-JsonStringBody {
    <# The body of a JSON string literal for $Value: backslash and double quote escaped, nothing else.
       One definition for every writer -- an insert and the block printed for placing by hand -- because a
       printed block once interpolated a command raw, and its inner quotes broke the settings file it was
       pasted into (#2849). #>
    param([string]$Value)
    return ($Value -replace '\\', '\\') -replace '"', '\"'
}

function Add-SettingsMember {
    <# Insert a member into a settings file's TEXT, before the root object's closing brace, and return the
       new text -- or $null where the text has no closing brace to insert before.

       -MemberLines are the member's lines with no base indent; a leading TAB stands for one indent unit
       of NESTING (so "`t`"type`": `"command`"," sits one level inside the member). Each line is written in
       the file's own indent unit (read off its first member, two spaces where there is none), one unit
       deep, in the file's own line ending, and the text after the closing brace -- a trailing newline, or
       none -- is kept as found. The caller has already parsed the text, so the last '}' in it IS the
       root's: valid JSON ends there. #>
    param([AllowEmptyString()][string]$Text, [Parameter(Mandatory = $true)][string[]]$MemberLines)
    $close = $Text.LastIndexOf('}')
    if ($close -lt 0) { return $null }
    $eol  = Get-DocumentNewline -Content $Text
    $unit = '  '
    # A bare '{' line followed by the first member is the ordinary shape. Where the first member shares
    # the '{' line, the first indented member line elsewhere is the next-best reading of the file's unit.
    $first = [regex]::Match($Text, '^\s*\{[ \t]*\r?\n([ \t]+)"')
    if (-not $first.Success) { $first = [regex]::Match($Text, '(?m)^([ \t]+)"') }
    if ($first.Success) { $unit = $first.Groups[1].Value }
    $head = $Text.Substring(0, $close).TrimEnd()
    $tail = $Text.Substring($close)
    # An empty root ends its head in the '{' itself; anything else ends in a member, which takes a comma.
    $sep  = $(if ($head.EndsWith('{')) { '' } else { ',' })
    $lines = foreach ($line in $MemberLines) {
        $depth = 0
        while ($depth -lt $line.Length -and $line[$depth] -eq "`t") { $depth++ }
        ($unit * ($depth + 1)) + $line.Substring($depth)
    }
    return ($head + $sep + $eol + (@($lines) -join $eol) + $eol + $tail)
}
