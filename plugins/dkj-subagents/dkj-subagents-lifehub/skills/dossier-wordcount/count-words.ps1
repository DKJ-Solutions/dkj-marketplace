<#
.SYNOPSIS
    Counts the words in a dossier page body, the same way for every writer (#4371).

.DESCRIPTION
    A life hub keeps a word-count property on each dossier so the owner can see which one nears the
    split limit. Ian and every skill that writes into a dossier recount after the write, and they all
    call this one counter so the number means the same thing whoever wrote last.

    The rule, in order:
      1. A markdown link or image keeps its text and loses its URL: [text](url) -> text.
      2. Every tag goes, attributes and all: <page url="...">Title</page> -> Title. This is how
         notion-fetch renders mentions, callouts and tables.
      3. A bare URL goes, and so does an HTML entity (&nbsp;, &#160;).
      4. A code fence keeps its content and loses its marker and language name.
      5. What is left is split on whitespace, and a token counts when it holds a letter or a digit.
         So '-', '|', '#', '**' and '---' are not words; '**bold**' and '2026-11-20' are one each.

    It reads a file (-Path) or a string (-Text), prints the count on the first line and, with
    -Threshold, a second line when the count is above it. It writes nothing and calls nothing.

.PARAMETER Path
    A file holding the page body, as notion-fetch returned it. Read as UTF-8.

.PARAMETER Text
    The page body itself, for a short page.

.PARAMETER Threshold
    The owner's split limit, from the settings page. When the count is above it, a second line says so.

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File count-words.ps1 -Path body.md -Threshold 1500
#>
[CmdletBinding(DefaultParameterSetName = 'Path')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0)][string]$Path,
    [Parameter(Mandatory, ParameterSetName = 'Text')][AllowEmptyString()][string]$Text,
    [int]$Threshold = 0
)
$ErrorActionPreference = 'Stop'

function Get-DossierWordCount {
    param([AllowEmptyString()][string]$Body)
    if ([string]::IsNullOrWhiteSpace($Body)) { return 0 }
    $t = $Body
    $t = [regex]::Replace($t, '!?\[([^\]]*)\]\([^)]*\)', '$1')
    # Only a tag-shaped '<...>' goes, so 'x < 5 and y > 3' in prose keeps its words.
    $t = [regex]::Replace($t, '<!--.*?-->', ' ', 'Singleline')
    $t = [regex]::Replace($t, '</?[A-Za-z][A-Za-z0-9:_-]*(?:\s[^<>]*)?/?>', ' ')
    $t = [regex]::Replace($t, '(?i)\b(?:https?|ftp)://\S+', ' ')
    $t = [regex]::Replace($t, '&(?:[a-zA-Z]+|#\d+|#x[0-9a-fA-F]+);', ' ')
    $t = [regex]::Replace($t, '(?m)^\s*(```|~~~)\S*', ' ')
    $n = 0
    foreach ($tok in ($t -split '\s+')) {
        if ($tok -match '[\p{L}\p{N}]') { $n++ }
    }
    return $n
}

if ($PSCmdlet.ParameterSetName -eq 'Path') {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Host "[ERROR] no file at '$Path' -- nothing was counted."
        exit 1
    }
    $Text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $Path).Path, [System.Text.Encoding]::UTF8)
}

$count = Get-DossierWordCount -Body $Text
Write-Output $count
if ($Threshold -gt 0 -and $count -gt $Threshold) {
    Write-Output "OVER: $count words is above the split threshold of $Threshold -- propose the split into child dossiers."
}
exit 0
