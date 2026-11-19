<#
.SYNOPSIS
    Regression tests for the SessionStart check git-content-sessioncheck.ps1 and its lib
    git-content-rules.ps1 (the "what belongs in git" chapter of the dkj-repo-workflow-dkj CLAUDE.md).

.DESCRIPTION
    Needs git. Fixture repos carry $PID (repo convention). The hook runs in a child interpreter, so its
    exit code is the real one. Pure ASCII.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/git-content-sessioncheck.tests.ps1
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$Ext      = Join-Path $RepoRoot 'plugins/dkj-repo-workflow/extensions/dkj-repo-workflow-dkj'
$Hook     = Join-Path $Ext 'hooks/git-content-sessioncheck.ps1'
. (Join-Path $Ext 'scripts/lib/git-content-rules.ps1')

$script:pass  = 0
$script:fail  = 0
$script:trees = @()

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-Repo {
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("gitcontent-$PID-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $script:trees += $dir
    git -C $dir init -q 2>$null
    git -C $dir config user.name 'fixture'
    git -C $dir config user.email 'fixture@example.invalid'
    git -C $dir config commit.gpgsign false
    git -C $dir config core.autocrlf false
    return $dir
}

function Add-Commits([string]$Repo, [string]$RelPath, [int]$Times) {
    # git may write advisories to stderr; under Stop in Windows PowerShell 5.1 that would end the run.
    $ErrorActionPreference = 'Continue'
    $full = Join-Path $Repo $RelPath
    New-Item -ItemType Directory -Path (Split-Path $full) -Force | Out-Null
    for ($i = 1; $i -le $Times; $i++) {
        [System.IO.File]::WriteAllText($full, "edit $i`n")
        git -C $Repo add -A 2>$null
        git -C $Repo commit -q -m "edit $RelPath $i" 2>$null
    }
}

function Invoke-Hook([string]$Root) {
    $out = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $Hook -RepoRootOverride $Root 2>&1
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

try {
    Write-Host 'lib: Get-GitContentFolders'
    $folders = Get-GitContentFolders -Files @('README.md', 'docs/a.md', 'docs/b.json', 'src/data/x.ts', 'src/data/y.json',
        'tests/fixtures/f.csv', '.claude/rules/r.md', 'notes/deep/n.txt')
    Assert-True (($folders -join ',') -eq 'docs,notes/deep') 'content-only folders found; a folder with one code file, test material, tooling and root files are not'

    Write-Host 'lib: Measure-GitContentCommits'
    $count = Measure-GitContentCommits -Folders @('docs') -LogLines @('@@', '', 'docs/a.md', 'docs/b.md', '@@', 'src/x.ts', '@@', 'docs/a.md')
    Assert-True ($count['docs'] -eq 2) 'a commit touching two files in one folder counts once'

    Write-Host 'lib: allowlist'
    Assert-True (Test-GitContentAllowed -Folder 'plugins/a/manuals' -Allow @(@{ Path = 'plugins*'; Reason = 'r' })) 'a glob allowlist entry covers nested folders'
    $bad = ConvertTo-GitContentAllowlist -Raw @(@{ Path = 'docs' })
    Assert-True (-not $bad.Ok -and $bad.Problem -match 'no Reason') 'an entry without a Reason is refused'

    Write-Host 'hook'
    $plain = Join-Path ([System.IO.Path]::GetTempPath()) ("gitcontent-$PID-nogit-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    New-Item -ItemType Directory -Path $plain -Force | Out-Null
    $script:trees += $plain
    $r = Invoke-Hook $plain
    Assert-True ($r.Code -eq 0 -and -not $r.Out) 'not a git repo -- silent, exit 0'

    $t = New-Repo
    Add-Commits $t 'src/app.ts' 1
    Add-Commits $t 'docs/notes/n.md' 3
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match 'no content folder pays' -and $r.Out -notmatch '\[WARN\]') 'a content folder edited 3 times -- quiet OK line'

    $t = New-Repo
    Add-Commits $t 'dossier/d.md' 10
    Add-Commits $t 'src/data/x.ts' 12
    Add-Commits $t 'tests/fixtures/f.csv' 12
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match '\[WARN\] 1 content-only' -and $r.Out -match 'dossier -- 10 commits' -and $r.Out -match 'data, not instructions') `
        'a content folder edited 10 times -- [WARN] naming it; code and fixtures are not named'
    Assert-True ($r.Out -notmatch 'src/data' -and $r.Out -notmatch 'fixtures') 'code and fixture folders stay out of the report'

    # A non-ASCII name: git quotes the path, and the quotes once hid the folder (the extension read '.md"').
    $u = New-Repo
    Add-Commits $u ('recepten/' + 'caf' + [char]0x00E9 + '/r.md') 10
    $r = Invoke-Hook $u
    Assert-True ($r.Code -eq 0 -and $r.Out -match '\[WARN\] 1 content-only' -and $r.Out -match 'recepten/caf\\303\\251 -- 10 commits') 'a folder with a non-ASCII name is found, printed with its octal escapes'
    Assert-True ((ConvertFrom-GitQuotedLine '"a/b.md"') -eq 'a/b.md' -and (ConvertFrom-GitQuotedLine 'a/b.md') -eq 'a/b.md') 'the quotes go, an unquoted line is left alone'

    New-Item -ItemType Directory -Path (Join-Path $t 'scripts') -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $t 'scripts/repo-config.ps1'), "function Get-GitContentAllowlist { @(@{ Path = 'dossier'; Reason = 'a deployed build reads it' }) }`n")
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -notmatch '\[WARN\]') 'an allowlisted folder is not reported'

    [System.IO.File]::WriteAllText((Join-Path $t 'scripts/repo-config.ps1'), "function Get-GitContentAllowlist { @(@{ Path = 'dossier' }) }`n")
    $r = Invoke-Hook $t
    Assert-True ($r.Code -eq 0 -and $r.Out -match '\[WARN\] scripts/repo-config\.ps1' -and $r.Out -match 'did not run') 'an allowlist entry without a Reason -- [WARN], the check does not run, exit 0'
}
finally {
    foreach ($d in $script:trees) { Remove-Item -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "git-content-sessioncheck: $script:pass passed, $script:fail failed"
if ($script:fail) { exit 1 }
exit 0
