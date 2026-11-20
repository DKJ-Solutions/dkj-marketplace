<#
.SYNOPSIS
    Tests for the lifehub dossier-wordcount counter (#4371).

.DESCRIPTION
    The counter is the one definition of "a word" every dossier writer shares, so the asserts pin the
    rule itself: markup, tags and link URLs never count, link text does, and a token counts only when
    it holds a letter or a digit. Plus the threshold line and the two input routes.

    Dependency-free (no Pester), exit 1 on any failure, same style as the rest of the suite.
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Counter  = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-lifehub\skills\dossier-wordcount\count-words.ps1'

$script:pass = 0
$script:fail = 0
function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Invoke-Counter {
    param([string[]]$CounterArgs)
    $out = @(& powershell -NoProfile -ExecutionPolicy Bypass -File $Counter @CounterArgs 2>&1)
    return [pscustomobject]@{ Code = $LASTEXITCODE; Lines = @($out | ForEach-Object { "$_" }) }
}

Write-Host "== dossier-wordcount: the counting rule ==" -ForegroundColor Cyan

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) "dossier-wordcount-$PID-$([guid]::NewGuid().ToString('n'))"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
try {
    $cases = @(
        @{ Label = 'plain words';                          Body = 'one two three';                                        Want = 3 },
        @{ Label = 'markdown markers are not words';       Body = "# Title`n`n- item one`n- item two`n`n---";             Want = 5 },
        @{ Label = 'emphasis around a word is one word';   Body = '**bold** and _soft_';                                  Want = 3 },
        @{ Label = 'a link keeps its text, not its URL';   Body = 'see [the release notes](https://example.com/a/b?c=d)'; Want = 4 },
        @{ Label = 'a tag and its attributes go';          Body = '<page url="https://www.notion.so/abc">Health dossier</page> moved'; Want = 3 },
        @{ Label = 'a self-closing mention leaves nothing'; Body = 'with <mention-user url="user://123"/> today';         Want = 2 },
        @{ Label = 'a bare URL is not a word';             Body = 'source https://example.com/post/42 read';              Want = 2 },
        @{ Label = 'an entity is not a word';              Body = 'a&nbsp;b &amp; c';                                     Want = 3 },
        @{ Label = 'a code fence keeps content only';      Body = "``````powershell`nGet-Item x`n``````";                 Want = 2 },
        @{ Label = 'digits and dates count';               Body = 'paid 120 on 2026-11-20 | |';                           Want = 4 },
        @{ Label = 'letters outside ASCII count';          Body = "caf$([char]0xE9) na$([char]0xEF)ve";                   Want = 2 },
        @{ Label = 'a comparison in prose is not a tag';   Body = 'x < 5 and y > 3';                                      Want = 5 },
        @{ Label = 'a tilde fence keeps content only';     Body = "~~~text`nhello world`n~~~";                            Want = 2 },
        @{ Label = 'an image keeps its alt text only';     Body = 'see ![a chart](https://example.com/c.png) here';       Want = 4 },
        @{ Label = 'a br between words splits them';       Body = 'one<br>two<br/>three';                                 Want = 3 },
        @{ Label = 'a table keeps its cells';              Body = '<table><tr><td>Rent</td><td>950</td></tr></table>';    Want = 2 },
        @{ Label = 'an HTML comment is not words';         Body = 'kept <!-- hidden note --> kept';                       Want = 2 },
        @{ Label = 'CRLF line endings count the same';     Body = "one two`r`nthree`r`n- four";                           Want = 4 },
        @{ Label = 'an empty body is zero';               Body = "  `n  ";                                               Want = 0 }
    )
    $i = 0
    foreach ($c in $cases) {
        $i++
        $f = Join-Path $tmp "case-$i.md"
        [System.IO.File]::WriteAllText($f, $c.Body, (New-Object System.Text.UTF8Encoding($false)))
        $r = Invoke-Counter -CounterArgs @('-Path', $f)
        Assert-Equal $c.Want $r.Lines[0] $c.Label
    }

    Write-Host "== dossier-wordcount: input routes and the threshold ==" -ForegroundColor Cyan

    $r = Invoke-Counter -CounterArgs @('-Text', 'alpha beta gamma')
    Assert-Equal 3 $r.Lines[0] '-Text counts the same as -Path'

    $r = Invoke-Counter -CounterArgs @('-Text', 'alpha beta gamma', '-Threshold', '3')
    Assert-Equal 1 $r.Lines.Count 'at the threshold: no OVER line'

    $r = Invoke-Counter -CounterArgs @('-Text', 'alpha beta gamma delta', '-Threshold', '3')
    Assert-Equal 2 $r.Lines.Count 'above the threshold: a second line'
    Assert-Equal 'OVER' ($r.Lines[1] -replace ':.*$', '') 'the second line starts with OVER'

    $r = Invoke-Counter -CounterArgs @('-Path', (Join-Path $tmp 'missing.md'))
    Assert-Equal 1 $r.Code 'a missing file exits 1'
}
finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "dossier-wordcount: $($script:pass) passed, $($script:fail) failed"
if ($script:fail -gt 0) { exit 1 }
exit 0
