<#
.SYNOPSIS
    Tests for scripts/lint/check-eol.ps1: CRLF in the index under an eol=lf pin (issues #4288, #4144).

.DESCRIPTION
    Dependency-free: no Pester, only PowerShell, no network.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/check-eol.tests.ps1

    Two layers that fail independently:
      1. the parser on fixed `git ls-files --eol` lines: CRLF or mixed under eol=lf counts, the rest does not;
      2. the real script against this checkout's index, and against a scratch repo that carries a CRLF blob
         under an eol=lf pin (exit 1, the repair line printed).

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

# The child runs below are captured with 2>&1; under Stop, Windows PowerShell 5.1 turns a child's stderr
# line (git's own 'fatal:' in the not-a-repo case) into a terminating error, so that case is the one lowered.
. (Join-Path $PSScriptRoot '..\lib\check-report-lib.ps1')
. (Join-Path $PSScriptRoot '..\lib\fixture-git-lib.ps1')
$RepoRoot = Resolve-RepoRootOrFail -From $PSScriptRoot -ScriptName 'check-eol.tests.ps1'
$Script = Join-Path $RepoRoot 'scripts\lint\check-eol.ps1'
. $Script

$script:pass = 0
$script:fail = 0
function Assert-Equal {
    param($Expected, $Actual, [string]$Name)
    if ($Expected -eq $Actual) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}

$tab = [char]9

Write-Host 'the parser: what counts as CRLF under an eol=lf pin'

$r = Get-CrlfUnderLfPin -Lines @("i/crlf  w/crlf  attr/text eol=lf      ${tab}snippets/a.liquid")
Assert-Equal 1 $r.Count 'crlf under the pin is flagged'
Assert-Equal 'snippets/a.liquid' $r[0] 'the path comes back as git names it'

$r = Get-CrlfUnderLfPin -Lines @("i/mixed w/mixed attr/text eol=lf      ${tab}config/s.json")
Assert-Equal 1 $r.Count 'mixed under the pin is flagged'

$r = Get-CrlfUnderLfPin -Lines @("i/lf    w/crlf  attr/text eol=lf      ${tab}sections/f.json")
Assert-Equal 0 $r.Count 'lf in the index is not flagged, even with crlf in the working copy'

$r = Get-CrlfUnderLfPin -Lines @(
    "i/crlf  w/crlf  attr/                 ${tab}docs/notes.md",
    "i/crlf  w/crlf  attr/text eol=crlf    ${tab}scripts/x.cmd",
    "i/-text w/-text attr/                 ${tab}assets/logo.png"
)
Assert-Equal 0 $r.Count 'crlf without an eol=lf pin is not flagged'

$r = Get-CrlfUnderLfPin -Lines @("i/crlf  w/crlf  attr/text=auto eol=lf ${tab}a/b.txt")
Assert-Equal 1 $r.Count 'text=auto eol=lf is flagged'

$r = Get-CrlfUnderLfPin -Lines @("i/crlf  w/crlf  attr/text eol=lf      ${tab}sections/a b.liquid")
Assert-Equal 'sections/a b.liquid' $r[0] 'a path with a space stays whole (tab-split parsing)'

$r = Get-CrlfUnderLfPin -Lines @()
Assert-Equal 0 $r.Count 'empty input gives an empty list, not an error'

$r = Get-CrlfUnderLfPin -Lines @('', 'not a git line')
Assert-Equal 0 $r.Count 'lines that are not ls-files output are ignored'

if (Get-Command -Name Convert-GitQuotedPath -CommandType Function -ErrorAction SilentlyContinue) {
    $r = Get-CrlfUnderLfPin -Lines @("i/crlf  w/crlf  attr/text eol=lf      ${tab}" + '"caf\303\251.md"')
    Assert-Equal ('caf' + [char]0x00E9 + '.md') $r[0] 'a C-quoted non-ASCII path is decoded'
}

Write-Host 'the script against real indexes'

$self = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Script 2>&1) -join "`n"
Assert-Equal 0 $LASTEXITCODE 'this checkout: exit 0'
Assert-True ($self -match '^\[OK\]') 'this checkout: reports [OK]'

$fx = Join-Path ([System.IO.Path]::GetTempPath()) ('check-eol-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fx | Out-Null
try {
    Invoke-FixtureGitIn $fx init -q
    Invoke-FixtureGitIn $fx config user.email t@example.invalid
    Invoke-FixtureGitIn $fx config user.name t
    Invoke-FixtureGitIn $fx config core.autocrlf false
    # Commit the CRLF blob BEFORE the pin exists, so git does not normalise it on the way in.
    [System.IO.File]::WriteAllBytes((Join-Path $fx 'a.txt'), [System.Text.Encoding]::ASCII.GetBytes("one`r`ntwo`r`n"))
    Invoke-FixtureGitIn $fx add a.txt
    [System.IO.File]::WriteAllText((Join-Path $fx '.gitattributes'), "*.txt text eol=lf`n")
    Invoke-FixtureGitIn $fx add .gitattributes
    Invoke-FixtureGitIn $fx commit -q -m fixture

    $out = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Script -RootOverride $fx 2>&1) -join "`n"
    Assert-Equal 1 $LASTEXITCODE 'scratch repo with crlf under the pin: exit 1'
    Assert-True ($out -match 'a\.txt') 'the offending path is named'
    Assert-True ($out -match 'git add --renormalize -- "a\.txt"') 'the repair line is printed'

    $notRepo = Join-Path ([System.IO.Path]::GetTempPath()) ('check-eol-no-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $notRepo | Out-Null
    try {
        $ErrorActionPreference = 'Continue'
        $null = (& powershell -NoProfile -ExecutionPolicy Bypass -File $Script -RootOverride $notRepo 2>&1)
        $notRepoExit = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        Assert-Equal 2 $notRepoExit 'outside a git checkout: exit 2'
    } finally { Remove-Item -Recurse -Force $notRepo -ErrorAction SilentlyContinue }
} finally {
    Remove-Item -Recurse -Force $fx -ErrorAction SilentlyContinue
}

$fixtureBroken = Write-FixtureGitSummary -Subject 'check-eol.ps1'
Write-Host ''
Write-Host ("  {0} passed, {1} failed" -f $script:pass, $script:fail) -ForegroundColor $(if ($script:fail -gt 0) { 'Red' } else { 'Green' })
if ($script:fail -gt 0 -or $fixtureBroken) { exit 1 }
exit 0
