<#
.SYNOPSIS
    Tests for start-task.ps1 as dkj-repo-workflow-bwj ships it -- the store layer over the shared
    new-branch.ps1: its refusals, their ORDER relative to anything being created, and the seams it reads.

.DESCRIPTION
    Run:
        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/start-task.tests.ps1

    WHAT THIS GUARDS. The script exists for the refusals that are stricter than the shared script's, and
    a refusal is only worth having if it fires BEFORE anything is created. So the behavioural cases run
    the real script in a child process against a fixture repository, with the Shopify CLI stubbed on PATH
    (or scrubbed from it), and assert both the refusal and that no branch or document appeared. Every one
    of them exits before the shared new-branch.ps1 is resolved, so no plugin payload is needed and
    nothing here can create a branch outside the fixture. The success path -- the handover itself -- is
    new-branch's own suite's business.

    THE SEAMS ARE MEASURED, not assumed: the branch prefix table comes from the FIXTURE's own
    scripts/lib/branch-info.ps1 (a copy of this repo's, because from inside the plugin a relative path
    would point at the plugin), and the trunk comes from the fixture's Get-TrunkBranchName in
    scripts/repo-config.ps1. One case sets the trunk to a name nobody would hard-code and asserts the
    base refusal names it.

    WHAT IS ASSERTED AS SOURCE: that the CLI check precedes the handover, that there is no git-identity
    check (the shared script owns that refusal), and that the file holds no email address. Proving the
    ordering by running the handover would be letting the damage happen.

    Exit 0 = green. Dependency-free; no Pester. Pure ASCII.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$BwjRoot  = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
. (Join-Path $BwjRoot 'scripts\tests\test-lib.ps1')
trap { Add-SuiteFault $_ ; continue }

$Script   = Join-Path $BwjRoot 'scripts\task\start-task.ps1'
$Scratch  = Join-Path ([System.IO.Path]::GetTempPath()) ("start-task-tests-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Scratch -Force | Out-Null
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

Write-SuiteHeader 'start-task.ps1 (dkj-repo-workflow-bwj)'

function Invoke-GitQuiet {
    param([string]$Dir, [string[]]$GitArgs)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & git -C $Dir @GitArgs 2>&1
        return [pscustomobject]@{ Code = $LASTEXITCODE; Text = (@($out) | ForEach-Object { "$_" }) -join "`n" }
    } finally { $ErrorActionPreference = $prev }
}

# A fixture store: a git repo on its trunk with one commit and the repo-owned branch-info.ps1. -Trunk
# names the branch it sits on; -ConfigBody, when given, becomes scripts/repo-config.ps1.
function New-StoreFixture {
    param([string]$Label, [string]$Trunk = 'main', [string]$ConfigBody = '', [switch]$NoBranchInfo)
    $dir = Join-Path $Scratch $Label
    New-Item -ItemType Directory -Path (Join-Path $dir 'scripts\lib') -Force | Out-Null
    $null = Invoke-GitQuiet $dir @('init', '-q')
    $null = Invoke-GitQuiet $dir @('symbolic-ref', 'HEAD', "refs/heads/$Trunk")
    if (-not $NoBranchInfo) {
        Copy-Item -LiteralPath (Join-Path $RepoRoot 'scripts\lib\branch-info.ps1') -Destination (Join-Path $dir 'scripts\lib\branch-info.ps1')
    }
    if ($ConfigBody) { [System.IO.File]::WriteAllText((Join-Path $dir 'scripts\repo-config.ps1'), $ConfigBody, $Utf8NoBom) }
    $null = Invoke-GitQuiet $dir @('add', '-A')
    $null = Invoke-GitQuiet $dir @('-c', 'user.name=Tester', '-c', 'user.email=tester@example.com', 'commit', '-q', '--allow-empty', '-m', 'init')
    return $dir
}

# PATH variants. The CLI is hidden by dropping every PATH entry that holds a shopify shim, and shown by
# a stub folder with a shopify.cmd -- neither depends on whether this box has the real CLI.
$shimNames = @('shopify', 'shopify.cmd', 'shopify.ps1', 'shopify.exe', 'shopify.bat')
$cleanPath = (($env:Path -split ';') | Where-Object {
    $d = $_
    $d -and -not ($shimNames | Where-Object { Test-Path -LiteralPath (Join-Path $d $_) })
}) -join ';'
$stubDir = Join-Path $Scratch 'cli-stub'
New-Item -ItemType Directory -Path $stubDir | Out-Null
Set-Content -LiteralPath (Join-Path $stubDir 'shopify.cmd') -Value '@echo off'
$pathWithCli    = "$stubDir;$cleanPath"
$pathWithoutCli = $cleanPath

# The same, through -EncodedCommand: a double quote inside an argument survives that route, where
# 'powershell -File' strips it before the script can see it (the best-effort the script's own comment
# measures). Only the quote cases need it.
function Invoke-StartTaskEncoded {
    param([string]$Fixture, [string]$ArgText, [string]$PathValue)
    $cmd = "& '$Script' $ArgText -RootOverride '$Fixture'; exit `$LASTEXITCODE"
    $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($cmd))
    $prevPath = $env:Path
    $prevEap = $ErrorActionPreference
    try {
        $env:Path = $PathValue
        $ErrorActionPreference = 'Continue'
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc 2>&1
        $code = $LASTEXITCODE
    } finally {
        $env:Path = $prevPath
        $ErrorActionPreference = $prevEap
    }
    return [pscustomobject]@{ Code = $code; Text = (ConvertTo-CapturedText $out) }
}

# Run the real script in a child process against a fixture and hand back what it said.
function Invoke-StartTask {
    param([string]$Fixture, [string[]]$ScriptArgs, [string]$PathValue)
    $prevPath = $env:Path
    $prevEap = $ErrorActionPreference
    try {
        $env:Path = $PathValue
        $ErrorActionPreference = 'Continue'
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @ScriptArgs -RootOverride $Fixture 2>&1
        $code = $LASTEXITCODE
    } finally {
        $env:Path = $prevPath
        $ErrorActionPreference = $prevEap
    }
    return [pscustomobject]@{ Code = $code; Text = (ConvertTo-CapturedText $out) }
}

function Get-BranchList { param([string]$Dir) return (Invoke-GitQuiet $Dir @('branch', '--format=%(refname:short)')).Text }
function Get-HeadName   { param([string]$Dir) return (Invoke-GitQuiet $Dir @('rev-parse', '--abbrev-ref', 'HEAD')).Text.Trim() }

try {
    Assert-True (Test-Path -LiteralPath $Script) 'start-task.ps1 ships in the extension'
    $src = Get-Content -LiteralPath $Script -Raw

    # -----------------------------------------------------------------------------------------------
    Write-Case 'no Shopify CLI on PATH: refused, and nothing created'
    $fx = New-StoreFixture 'cli-absent'
    $r = Invoke-StartTask $fx @('-Name', 'feat/x') $pathWithoutCli
    Assert-Equal 1 $r.Code 'exit 1 -- a refusal, not a crash'
    Assert-Match $r.Text 'Shopify CLI is not on PATH' 'it names the cause'
    Assert-Match $r.Text 'npm i -g @shopify/cli' 'and prints the shared repair'
    Assert-Match $r.Text 'Nothing has been touched' 'and says nothing was created'
    Assert-NoMatch (Get-BranchList $fx) 'feat/x' 'no branch was created'

    # -----------------------------------------------------------------------------------------------
    Write-Case 'the name guardrails, each refused before anything is created'
    $fx = New-StoreFixture 'names'
    foreach ($case in @(
        @{ Name = 'sync/drift-pull';   Match = 'sync/ branches by hand';  Why = 'sync/ is refused' },
        @{ Name = 'dependabot/npm/x';  Match = 'Dependabot';              Why = 'dependabot/ is refused' },
        @{ Name = 'bogus/thing';       Match = 'Unknown branch prefix';   Why = 'an unknown prefix is refused, where the shared script only warns' },
        @{ Name = 'main';              Match = 'Invalid branch name';     Why = 'the trunk name is refused through Test-BranchName' },
        @{ Name = 'feat/x..y';     Match = 'not a valid git branch name'; Why = 'a name git refuses is refused' }
    )) {
        $r = Invoke-StartTask $fx @('-Name', $case.Name) $pathWithCli
        Assert-Equal 1 $r.Code "$($case.Name): exit 1"
        Assert-Match $r.Text $case.Match "$($case.Name): $($case.Why)"
    }
    Assert-Equal 'main' (Get-HeadName $fx) 'HEAD did not move'
    Assert-Equal 'main' (Get-BranchList $fx).Trim() 'and no branch exists beyond the trunk'

    # -----------------------------------------------------------------------------------------------
    Write-Case 'a double quote in -Title or -Intent is refused with a hint'
    $fx = New-StoreFixture 'quotes'
    $r = Invoke-StartTaskEncoded $fx "-Name feat/x -Title 'Say `"hi`"'" $pathWithCli
    Assert-Equal 1 $r.Code '-Title: exit 1'
    Assert-Match $r.Text '-Title must not contain a double quote' '-Title: the refusal names the parameter'
    $r = Invoke-StartTaskEncoded $fx "-Name feat/x -Intent 'Say `"hi`"'" $pathWithCli
    Assert-Equal 1 $r.Code '-Intent: exit 1'
    Assert-Match $r.Text '-Intent must not contain a double quote' '-Intent: the refusal names the parameter'
    Assert-NoMatch (Get-BranchList $fx) 'feat/x' 'no branch was created'

    # -----------------------------------------------------------------------------------------------
    Write-Case 'the base refusal: HEAD is not on the trunk, so the branch is not cut'
    $fx = New-StoreFixture 'base-off-trunk'
    $null = Invoke-GitQuiet $fx @('checkout', '-q', '-b', 'feat/other-work')
    $r = Invoke-StartTask $fx @('-Name', 'docs/x') $pathWithCli
    Assert-Equal 1 $r.Code 'exit 1'
    Assert-Match $r.Text "HEAD is on 'feat/other-work', not on 'main'" 'it names where HEAD is and what the trunk is'
    Assert-Match $r.Text '-Base main' 'and offers -Base'
    Assert-Match $r.Text '-Stacked' 'and -Stacked'
    Assert-Equal 'feat/other-work' (Get-HeadName $fx) 'HEAD did not move'
    Assert-NoMatch (Get-BranchList $fx) 'docs/x' 'no branch was created'

    $r = Invoke-StartTask $fx @('-Name', 'docs/x', '-Base', 'main', '-Stacked') $pathWithCli
    Assert-Equal 1 $r.Code '-Base with -Stacked: exit 1'
    Assert-Match $r.Text 'contradict' 'the two flags are refused as contradicting'

    $r = Invoke-StartTask $fx @('-Name', 'docs/x', '-Base', 'no-such-branch') $pathWithCli
    Assert-Equal 1 $r.Code 'an unknown -Base: exit 1'
    Assert-Match $r.Text "is not a local branch" 'it says the base is not a local branch'
    Assert-Equal 'feat/other-work' (Get-HeadName $fx) 'and HEAD still did not move'

    # -----------------------------------------------------------------------------------------------
    Write-Case 'the trunk is the repo seam: Get-TrunkBranchName in repo-config.ps1'
    $fx = New-StoreFixture 'trunk-seam' -ConfigBody "function Get-TrunkBranchName { 'release-line' }`r`n"
    $r = Invoke-StartTask $fx @('-Name', 'docs/x') $pathWithCli
    Assert-Equal 1 $r.Code 'HEAD on main with a trunk named release-line: exit 1'
    Assert-Match $r.Text "not on 'release-line'" 'the refusal names the seam''s trunk, not a literal main'

    # -----------------------------------------------------------------------------------------------
    Write-Case 'the consumer''s branch-info.ps1 is required, and read from the checkout'
    $fx = New-StoreFixture 'no-branch-info' -NoBranchInfo
    $r = Invoke-StartTask $fx @('-Name', 'feat/x') $pathWithCli
    Assert-Equal 1 $r.Code 'without it: exit 1'
    Assert-Match $r.Text 'missing repo-owned file' 'with a pointer to the missing file'
    Assert-Match $r.Text 'branch-info.ps1' 'naming it'

    # -----------------------------------------------------------------------------------------------
    Write-Case 'the order, held as source: every refusal precedes the handover'
    $handover = $src.IndexOf('Resolve-PluginScript -RelativePath')
    Assert-True ($handover -gt 0) 'the handover to the shared new-branch.ps1 is present'
    foreach ($needle in @('Test-ShopifyCliPresent', 'Test-BranchName', "'dependabot'", "'sync'", 'Get-BranchBaseVerdict', 'Contains(')) {
        $at = $src.IndexOf($needle)
        Assert-True ($at -ge 0 -and $at -lt $handover) "$needle appears before the handover"
    }
    $cliLine = ($src -split "`n" | Where-Object { $_ -match 'if \(-not \(Test-ShopifyCliPresent\)\)' } | Select-Object -First 1)
    Assert-NoMatch $cliLine 'Skip' 'the CLI check has no skip switch'
    Assert-NoMatch $cliLine 'Prefix' 'and is not per-prefix'

    Write-Case 'what was deliberately left out stays out'
    Assert-NoMatch $src 'Test-GitIdentity' 'no git-identity check: the shared new-branch.ps1 refuses that before creating anything'
    $mails = @([regex]::Matches($src, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}') | ForEach-Object { $_.Value } | Sort-Object -Unique)
    Assert-Equal 0 $mails.Count "no email address anywhere in the file (found: $($mails -join ', '))"
    Assert-NoMatch $src '..\lib\branch-info.ps1' 'branch-info is not read from beside the script (that would be the plugin)'
    Assert-NoMatch $src 'plugin-scripts.ps1' 'and the locator is plugin-payload-lib, not a store plugin-scripts.ps1'
    Assert-Match $src 'Get-TrunkBranchName' 'it reads the seam'
} finally {
    Remove-Item -LiteralPath $Scratch -Recurse -Force -ErrorAction SilentlyContinue
}

Complete-Suite
