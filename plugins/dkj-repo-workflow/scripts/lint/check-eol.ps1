<#
.SYNOPSIS
    Refuses a file that sits in the git index with CRLF while .gitattributes pins it to eol=lf.

.DESCRIPTION
    WHY (issues #4288 and #4144). An `eol=lf` pin in .gitattributes only normalises what git itself
    writes. A commit made from a checkout or a tool that writes blobs without normalisation still puts
    CRLF in the index. Every checkout then shows that file as modified, `git checkout -- <file>` cannot
    make it clean, and ship-pr trips over the EOL-only modification at the fast-forward (#4144). The pin
    alone does not stop that, so this is the gate: open-pr runs it before the push, and a consumer may run
    it as a CI step on pull requests too.

    WHAT COUNTS: every line of `git ls-files --eol` whose index status is `i/crlf` or `i/mixed` and whose
    attribute names `eol=lf`. A file without the pin may keep CRLF; that is not this gate's business.

    ROOT: Resolve-CheckRoot (-RootOverride, then CLAUDE_PROJECT_DIR, then the git root of the working
    directory), the same dual-context resolution the sibling checks use, so it runs from the plugin mirror too.

    EXIT CODES: 0 clean, 1 on a hit (the paths and the repair are printed), 2 when git itself fails.

    THE REPAIR, which the report also prints:  git add --renormalize -- <paths>  (line endings only).

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/lint/check-eol.ps1

    Dot-sourcing (`. scripts/lint/check-eol.ps1`) loads only the pure function Get-CrlfUnderLfPin, which
    is what scripts/tests/check-eol.tests.ps1 does.

    PATHS: `git ls-files --eol` C-quotes a path carrying a byte above 0x7F. The call forces
    `-c core.quotePath=true` (the wire stays ASCII whatever the console code page) and the function
    decodes with Convert-GitQuotedPath from git-porcelain-lib.ps1, as the language-layers rule prescribes.
    The decoder is loaded guarded: a payload whose mirror predates that lib reports the quoted form
    instead of failing.

    Pure ASCII (repo convention for .ps1).
#>
[CmdletBinding()]
param(
    # A fixture root, so the suite can judge a scratch repo; a consumer never types it.
    [string]$RootOverride = ''
)

$ErrorActionPreference = 'Stop'

$eolPorcelainLib = Join-Path $PSScriptRoot '..\lib\git-porcelain-lib.ps1'
if (Test-Path -LiteralPath $eolPorcelainLib -PathType Leaf) { . $eolPorcelainLib }

function Get-CrlfUnderLfPin {
    <# Returns the paths from `git ls-files --eol` lines that carry CRLF in the index under an eol=lf pin. #>
    param([AllowEmptyCollection()][AllowEmptyString()][string[]]$Lines = @())
    $hits = @()
    foreach ($line in $Lines) {
        if ($line -match '^i/(?<index>\S+)\s+w/\S*\s+attr/(?<attr>[^\t]*)\t(?<path>.+)$') {
            # Capture first: the -match on the attribute below overwrites $Matches.
            $index = $Matches['index']; $attr = $Matches['attr']; $path = $Matches['path']
            if (($index -eq 'crlf' -or $index -eq 'mixed') -and ($attr -match '(^|\s)eol=lf(\s|$)')) {
                if (Get-Command -Name Convert-GitQuotedPath -CommandType Function -ErrorAction SilentlyContinue) {
                    $path = Convert-GitQuotedPath -Path $path
                }
                $hits += $path
            }
        }
    }
    return , $hits
}

if ($MyInvocation.InvocationName -eq '.') { return }

. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
$eolScope = Resolve-CheckRoot -Override $RootOverride
if (-not $eolScope.Path) {
    Write-Host '[ERROR] cannot resolve the repo root -- is this a git checkout?' -ForegroundColor Red
    exit 2
}

$lines = @(& git -C $eolScope.Path -c core.quotePath=true ls-files --eol)
if ($LASTEXITCODE -ne 0) {
    Write-Host '[ERROR] git ls-files --eol failed -- is this a git checkout?' -ForegroundColor Red
    exit 2
}

$bad = Get-CrlfUnderLfPin -Lines $lines
if ($bad.Count -eq 0) {
    Write-Host ("[OK] no CRLF in the index under an eol=lf pin ({0} files read)." -f $lines.Count)
    exit 0
}

Write-Host ("[FAIL] {0} file(s) are in the index with CRLF although .gitattributes pins them to eol=lf (#4288):" -f $bad.Count) -ForegroundColor Red
foreach ($p in $bad) { Write-Host "  $p" -ForegroundColor Red }
Write-Host ''
Write-Host 'Repair it on the branch, line endings only, and commit the result:'
Write-Host ('  git add --renormalize -- ' + (($bad | ForEach-Object { '"' + $_ + '"' }) -join ' '))
exit 1
