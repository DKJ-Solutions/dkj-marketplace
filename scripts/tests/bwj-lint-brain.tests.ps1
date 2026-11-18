<#
.SYNOPSIS
    Regression tests for the shared BWJ documentation linter that dkj-repo-workflow-bwj ships --
    scripts/maintenance/lint-brain.ps1 and its Stop hook scripts/maintenance/lint-changed-hook.ps1.

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/bwj-lint-brain.tests.ps1

    WHY A SUITE HERE FOR A SCRIPT NOBODY IN THIS REPO RUNS -- the same answer bwj-market-urls.tests.ps1
    and bwj-test-lib.tests.ps1 give. The two BWJ stores each carried their own diverged copy of this
    linter and of its hook, and their own suite for it; the converged copy is the union of two unequal
    trees. Shipping it without a suite in the repo that ships it would put it straight back where it
    started: a mechanism with no owner watching it. This suite is the union of the two stores' suites
    (deduplicated, fixtures rebuilt in a temp directory) plus the cases the merge itself created.

    A LINTER THAT REPORTS NOTHING IS ONLY GOOD NEWS IF IT CAN BE SHOWN TO REPORT SOMETHING. Every case
    runs the script on a fixture tree with a KNOWN defect and checks that it is found, and on a clean
    tree and checks that it is not.

    WHAT IT HOLDS, and each is a way the convergence can be undone:

      1. THE UNION. Every check either store had still fires: dead links and anchors (whole-file and
         bare-reference forms), mojibake, the execution-policy flag, stale version claims, the tests/
         table, a paragraph pulled into a blockquote, the README index gaps.
      2. THE SEAMS. What differs per repo is read from the SCANNED repo's scripts/repo-config.ps1 and
         every seam has a default: record documents, frozen records, and the two opt-in checks. A repo
         with no config gets no exemption and no opt-in check, never a crash.
      3. THE HOOK counts every error category from ONE run, stays fail-soft, and finds the lint as its
         sibling, not through the repo it is scanning.
      4. THE LANGUAGE. English, pure ASCII, and no store fact written into the script.

    Every fixture is a temp directory, deliberately NOT a git repo unless the case is about git: that is
    itself a regression test (a stderr redirect on a native exe is a terminating error in Windows
    PowerShell 5.1 under EAP=Stop, and the lint once fell over on it outside a git repo).

    Pure ASCII (repo convention for .ps1).
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot  = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$ExtRoot   = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
$Lint      = Join-Path $ExtRoot 'scripts\maintenance\lint-brain.ps1'
$Hook      = Join-Path $ExtRoot 'scripts\maintenance\lint-changed-hook.ps1'

. (Join-Path $ExtRoot 'scripts\tests\test-lib.ps1')
. (Join-Path $RepoRoot 'scripts\lib\fixture-git-lib.ps1')
trap { Add-SuiteFault $_ ; continue }

$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("bwj-lint-brain-$PID-" + [guid]::NewGuid().ToString('n').Substring(0, 8))
$script:caseNr = 0

function Write-Utf8 {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false)))
}

# The scanned repo's seams, with neutral paths. -Options is the BODY of Get-LintBrainOptions.
$ConfigTemplate = @'
function Get-ChangelogPath { 'docs/workflow/CHANGELOG.md' }
function Get-ReleaseHistoryPath { 'docs/workflow/releases/history.md' }
function Get-ReleaseNoteRoot { 'docs/workflow/releases/audience' }
function Get-ReleaseChangelogNotesRoot { 'docs/workflow/releases/changelog' }
function Get-ReleaseGithubNotesRoot { 'docs/workflow/releases/github' }
function Get-LintBrainOptions { __OPTIONS__ }
'@
function Get-ConfigText { param([string]$Options = '@{}') return $ConfigTemplate.Replace('__OPTIONS__', $Options) }

# A bare tree: exactly the files given, no config.
function New-Tree {
    param([hashtable]$Files)
    $script:caseNr++
    $root = Join-Path $Fixture "case$($script:caseNr)"
    New-Item -ItemType Directory -Force -Path $root | Out-Null
    foreach ($rel in $Files.Keys) { Write-Utf8 (Join-Path $root $rel) $Files[$rel] }
    return $root
}

# A small, correct repo with the seam config in it: a root README that names its two folders, a docs
# folder whose README names its one file, and a valid link with a valid anchor. Every case gets its own
# copy and breaks ONE thing, so a finding is attributable to exactly that mutation.
function New-Fixture {
    param([hashtable]$Extra = @{}, [string]$Options = '@{}')
    $files = @{
        'README.md'              = "# fixture`n`n## Overview of the parts`n`nSee [the guide](docs/guide.md) and the scripts/ folder.`n"
        'docs/README.md'         = "# docs`n`nThis folder holds guide.md.`n"
        'docs/guide.md'          = "# guide`n`n## Getting started`n`nBack to [the overview](../README.md#overview-of-the-parts).`n"
        'scripts/repo-config.ps1' = (Get-ConfigText -Options $Options)
    }
    foreach ($k in $Extra.Keys) { $files[$k] = $Extra[$k] }
    return (New-Tree -Files $files)
}

function Set-FileText { param([string]$Root, [string]$Rel, [string]$Text) Write-Utf8 (Join-Path $Root $Rel) $Text }
function Edit-FileText {
    param([string]$Root, [string]$Rel, [string]$From, [string]$To)
    $p = Join-Path $Root $Rel
    Write-Utf8 $p ((Get-Content -LiteralPath $p -Raw -Encoding UTF8) -replace $From, $To)
}

# The lint as a CHILD process: it ends with `exit`, and an in-process call would take this suite along.
function Invoke-Lint {
    param([string]$Root, [switch]$Quiet, [switch]$WarningsAsErrors)
    $ErrorActionPreference = 'Continue'   # 2>&1 on a native exe is terminating under Stop
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Lint, '-Path', $Root)
    if ($Quiet) { $a += '-Quiet' }
    if ($WarningsAsErrors) { $a += '-WarningsAsErrors' }
    $out = & powershell @a 2>&1
    return [pscustomobject]@{ Text = (ConvertTo-CapturedText $out); Code = $LASTEXITCODE }
}

function New-GitFixture {
    param([string]$Branch, [hashtable]$Extra = @{}, [string]$Options = '@{}')
    $root = New-Fixture -Extra $Extra -Options $Options
    Invoke-FixtureGitIn $root init -q
    Invoke-FixtureGitIn $root symbolic-ref HEAD "refs/heads/$Branch"
    return $root
}

function Invoke-GitFixture {
    param([string]$Root, [string[]]$GitArgs)
    Invoke-FixtureGitIn $Root -c user.name=fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false @GitArgs
}

# The hook as a child process with the fixture as the working directory (it finds its repo from there).
function Invoke-Hook {
    param([string]$Cwd)
    $ErrorActionPreference = 'Continue'
    Push-Location -LiteralPath $Cwd
    try {
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook 2>&1
        $code = $LASTEXITCODE
    } finally { Pop-Location }
    return [pscustomobject]@{ Text = (ConvertTo-CapturedText $out); Code = $code }
}

try {

Write-SuiteHeader 'bwj lint-brain: the plugin ships both scripts'
Assert-True (Test-Path -LiteralPath $Lint) 'dkj-repo-workflow-bwj ships scripts/maintenance/lint-brain.ps1'
Assert-True (Test-Path -LiteralPath $Hook) 'and scripts/maintenance/lint-changed-hook.ps1 beside it'

Write-SuiteHeader 'bwj lint-brain: the language, and no store fact in the script'
foreach ($f in @($Lint, $Hook)) {
    $bytes = [System.IO.File]::ReadAllBytes($f)
    $nonAscii = @($bytes | Where-Object { $_ -gt 127 }).Count
    Assert-Equal 0 $nonAscii "$(Split-Path -Leaf $f) is pure ASCII"
    $text = [System.IO.File]::ReadAllText($f)
    # A store's market, theme, name or workflow-folder history written into the shared copy would hand
    # one store the other's facts. The seam is the place for those.
    foreach ($needle in @('smartwatch', 'xoxo', 'wildhearts', 'dkj-policy', 'myshopify', 'Dode link', 'Samenvatting')) {
        Assert-NoMatch -Text $text -Needle $needle -Name "$(Split-Path -Leaf $f) does not contain '$needle'"
    }
}

Write-SuiteHeader 'bwj lint-brain: a clean fixture (baseline)'
$fix = New-Fixture
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'a correct tree exits 0'
Assert-Match -Text $r.Text -Needle 'PASS: 0 error(s), 0 warning(s).' -Name 'and says so on the summary line'
# Regression: the fixture is no git repo. Before the fix the lint fell over on `git check-ignore`.
Assert-NoMatch -Text $r.Text -Needle 'not a git repository' -Name 'the lint survives a directory outside a git repo'
Assert-NoMatch -Text $r.Text -Needle 'NativeCommandError' -Name 'with no NativeCommandError from the git calls'
$fix = New-Fixture -Options '@{ IndexGaps = $true }'
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'the same tree with the index check on exits 0'
Assert-Match -Text $r.Text -Needle '0 warning(s)' -Name 'with no index gap'
Assert-NoMatch -Text $r.Text -Needle 'NativeCommandError' -Name 'and no NativeCommandError from check-ignore either'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain A: dead links'
$fix = New-Fixture
Edit-FileText $fix 'README.md' 'docs/guide\.md' 'docs/does-not-exist.md'
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a link to a missing file is an error'
Assert-Match -Text $r.Text -Needle "Dead link to 'docs/does-not-exist.md'" -Name 'names the missing path'
Assert-Match -Text $r.Text -Needle 'README.md:5' -Name 'and the file and line'

$fix = New-Fixture
Edit-FileText $fix 'docs/guide.md' '\.\./README\.md#overview-of-the-parts' '../../../outside-the-repo.md'
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a link that climbs out of the repo is an error, not a crash'
Assert-NoMatch -Text $r.Text -Needle 'NativeCommandError' -Name 'no crash on a path outside the root'

$fix = New-Fixture
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle 'Dead link to' -Name 'positive twin: a valid path gives no dead-link finding'
Assert-NoMatch -Text $r.Text -Needle 'Anchor' -Name 'and a valid anchor gives no anchor finding'

Write-SuiteHeader 'bwj lint-brain A: anchors'
$fix = New-Fixture
Edit-FileText $fix 'docs/guide.md' '#overview-of-the-parts' '#no-such-heading'
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'an anchor with no heading is an error'
Assert-Match -Text $r.Text -Needle "Anchor '#no-such-heading' not found in README.md" -Name 'names the anchor and the target file'

$t = New-Tree @{
    'a.md'          = "# Title`n`n[the folder](sub#a-real-heading)`n[bad anchor](sub#nope)`n"
    'sub/README.md' = "# A real heading`n"
}
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a link into a directory resolves through its README.md'
Assert-Match -Text $r.Text -Needle "'#nope' not found" -Name 'and the bad anchor is the one caught'
Assert-NoMatch -Text $r.Text -Needle "'#a-real-heading'" -Name 'while the good one is not'

Write-SuiteHeader 'bwj lint-brain A: fences are skipped in both directions'
$t = New-Tree @{
    'a.md'     = "# Title`n`n" + '```' + "`n[example](sub/nope.md)`n" + '```' + "`n`n[real](sub/b.md#a-real-heading)`n"
    'sub/b.md' = "# A real heading`n`n" + '```sh' + "`n# Not A Heading`n" + '```' + "`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a dead link inside a fence is an example, not a finding'
Assert-NoMatch -Text $r.Text -Needle 'sub/nope.md' -Name 'fence content is skipped'
$t = New-Tree @{
    'a.md'     = "# Title`n`n[into a fence comment](sub/b.md#not-a-heading)`n"
    'sub/b.md' = "# A real heading`n`n" + '```sh' + "`n# Not A Heading`n" + '```' + "`n"
}
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a "#" line inside a fence does not become an anchor'

Write-SuiteHeader 'bwj lint-brain A: a link whose text wraps over two lines is one link'
$t = New-Tree @{
    'a.md'     = "# Title`n`nthe judgement is [a link whose text wraps`nover two lines](sub/b.md#no-such-rule) here`n"
    'sub/b.md' = "# A real heading`n"
}
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a wrapped link is still checked'
Assert-Match -Text $r.Text -Needle "Anchor '#no-such-rule' not found" -Name 'names the anchor of the wrapped link'
$t = New-Tree @{
    'a.md'     = "# Title`n`nthe judgement is [a link whose text wraps`nover two lines](sub/b.md#a-real-heading) here`n"
    'sub/b.md' = "# A real heading`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a wrapped link that resolves is not a finding'

Write-SuiteHeader 'bwj lint-brain A: a bare <file>.md#<anchor> in prose is a reference too'
$t = New-Tree @{
    'a.md' = "# Title`n`nsee b.md#a-real-heading, and b.md#does-not-exist, and ghost.md#whatever.`n"
    'b.md' = "# B`n`n## A real heading`n"
}
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a bare reference with a dead anchor, or to a file that resolves nowhere, is an error'
Assert-Match -Text $r.Text -Needle "Bare reference 'b.md#does-not-exist'" -Name 'a bare reference with a dead anchor'
Assert-Match -Text $r.Text -Needle "Bare reference 'ghost.md#whatever'" -Name 'a bare reference to a file that does not resolve'
Assert-NoMatch -Text $r.Text -Needle "Bare reference 'b.md#a-real-heading'" -Name 'the one that resolves is not reported'
$t = New-Tree @{
    'a.md' = "# Title`n`nthe whole form is in SOME-portable.md, which ships with a plugin.`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a bare filename with no anchor is prose, not a reference'
$t = New-Tree @{ 'a.md' = "# Title`n`nDiscussed: ``ghost.md#nope`` is what we repaired.`n" }
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a backticked reference is being discussed, not made'
$t = New-Tree @{ 'a.md' = "# Title`n`nDiscussed: ``ghost.md#nope``.`n`nBut refer to ghost.md#nope for the rule.`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'and the plain-prose one beside it still fires'

Write-SuiteHeader 'bwj lint-brain A: GitHub slug rules'
$t = New-Tree @{
    'a.md' = @(
        '# Index'
        ''
        '[stripped punctuation between spaces](b.md#the-merge-rule--green-gates)'
        '[punctuation](b.md#never-on-main-what-then)'
        '[underscore](b.md#get_branch_info)'
        '[duplicate](b.md#gates-1)'
        '[literal hyphens stay hyphens](b.md#a-b---c)'
        ''
    ) -join "`n"
    'b.md' = @(
        '# The merge rule : green gates'
        '## Never on `main`, what then?'
        '## get_branch_info'
        '## Gates'
        '## Gates'
        '## a b - c'
        ''
    ) -join "`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'every slug shape resolves (double hyphen, dropped punctuation, underscore, duplicate, literal hyphens)'
Assert-NoMatch -Text $r.Text -Needle 'Anchor' -Name 'and no anchor is reported dead'

Write-SuiteHeader 'bwj lint-brain: a single-file tree does not crash the lint'
# Under StrictMode Latest a pipeline yielding ONE file hands back a bare FileInfo and '.Count' throws.
$t = New-Tree @{ 'only.md' = "# Only`n`nNothing to link.`n" }
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'exit 0 on a one-file tree'
Assert-Match -Text $r.Text -Needle '1 markdown file(s)' -Name 'and it counted the one file'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain A: frozen release records come off the seam'
$rec = @{
    'docs/workflow/CHANGELOG.md'                        = "# Changelog`n"
    'docs/workflow/releases/changelog/1.x/1.2.0.md'     = "# v1.2.0`n`nRetired [the page](../../../CONTRIBUTING.md).`n`nIt moved out of CONTRIBUTING.md#some-rule when it went.`n"
    'docs/workflow/releases/github/1.x/1.2.0.md'        = "# v1.2.0`n`nSee [the page](../../../CONTRIBUTING.md).`n"
}
$cfg = @{ 'scripts/repo-config.ps1' = (Get-ConfigText) }
$t = New-Tree ($rec + $cfg)
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a dead LINK and a dead bare reference in a frozen record are both exempt'

# #4312: every v7 consumer keeps its records under the dot-folder .dkj/, and the normaliser once stripped
# that dot, so no record there was ever exempt. A leading './' is still stripped.
$dotRec = @{
    '.dkj/flow/CHANGELOG.md'                    = "# Changelog`n"
    '.dkj/flow/releases/changelog/1.x/1.2.0.md' = "# v1.2.0`n`nRetired [the page](../../../CONTRIBUTING.md).`n`nIt moved out of CONTRIBUTING.md#some-rule when it went.`n"
    '.dkj/flow/releases/github/1.x/1.2.0.md'    = "# v1.2.0`n`nSee [the page](../../../CONTRIBUTING.md).`n"
}
$dotCfg = @{ 'scripts/repo-config.ps1' = (Get-ConfigText).Replace("'docs/workflow/CHANGELOG.md'", "'.dkj/flow/CHANGELOG.md'").Replace("'docs/workflow/releases/changelog'", "'.dkj/flow/releases/changelog'").Replace("'docs/workflow/releases/github'", "'./.dkj/flow/releases/github'") }
$t = New-Tree ($dotRec + $dotCfg)
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a frozen record under a dot-folder root (.dkj/, and ./.dkj/) is exempt too'

$hand = @{
    'docs/workflow/CHANGELOG.md'                       = "# Changelog`n"
    'docs/workflow/releases/history.md'                = "# Releases`n`nSee [the page](../CONTRIBUTING.md).`n"
    'docs/workflow/releases/audience/1.x/1.1.0.md'     = "# 1.1.0`n`nSee [the page](../../../CONTRIBUTING.md).`n"
}
$t = New-Tree ($hand + $cfg)
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'the hand-written release pages did NOT gain the exemption'
Assert-Match -Text $r.Text -Needle 'releases/history.md' -Name 'the release index is measured'
Assert-Match -Text $r.Text -Needle 'audience' -Name 'and so is an audience note'

$t = New-Tree $rec
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a repo with NO config gets no exemption: the frozen record is scanned like any page'

$bad = @{
    'scripts/repo-config.ps1' = "function Get-ChangelogPath { throw 'broken config' }`n"
    'a.md'                    = "# Title`n`nNothing wrong here.`n"
}
$t = New-Tree $bad
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a config that throws degrades to the defaults instead of taking the lint down'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain B: mojibake'
# Built from character codes, never typed: this suite is ASCII, and a fixture holding literal mangled
# characters would not survive a careless re-save -- the very failure under test.
$moji = [string][char]0x00E2 + [char]0x20AC + [char]0x201D
$t = New-Tree @{ 'a.md' = "# Title`n`n- [ ] n/a $moji this branch touches no file`n"; 'ok.md' = "# Fine`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a mangled em dash is an error'
Assert-Match -Text $r.Text -Needle 'Mojibake U+00E2 U+20AC' -Name 'names the code points, not the garbled glyphs'
Assert-Match -Text $r.Text -Needle 'a.md' -Name 'and the file'
Assert-Match -Text $r.Text -Needle 'UTF-8' -Name 'and how to fix it'

$nbsp = [string][char]0x00C2 + [char]0x00A0
$t = New-Tree @{ 'a.md' = "# Title`n`nsome$nbsp" + "text`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a mangled non-breaking space is an error'
Assert-Match -Text $r.Text -Needle 'Mojibake U+00C2/U+00C3' -Name 'the other shape has its own message'

# The case that makes the two above safe to keep: ordinary accents are not a pair that cannot occur.
$accented = "# Titel`n`ncaf" + [char]0x00E9 + ", " + [char]0x00E9 + [char]0x00E9 + "n, cr" + [char]0x00E8 +
    "me, na" + [char]0x00EF + "ef, Fran" + [char]0x00E7 + "ois`n`na real em dash " + [char]0x2014 + " like so`n"
$t = New-Tree @{ 'a.md' = $accented }
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'real accented prose and a real em dash pass'
Assert-NoMatch -Text $r.Text -Needle 'Mojibake U+' -Name 'with no finding (the section heading says Mojibake on every run, a finding carries code points)'

# #4313: a record that QUOTES the mojibake it repaired, in an inline code span, is not mojibake.
$t = New-Tree @{ 'a.md' = "# Title`n`nShown as ``$moji`` instead of a dash. Fixed.`n" }
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'mojibake quoted inside an inline code span is not a finding (#4313)'
Assert-NoMatch -Text $r.Text -Needle 'Mojibake U+' -Name 'and carries no B finding'

# Its twin: the span is removed, not the line, so mojibake beside a quoted span is still caught.
$t = New-Tree @{ 'a.md' = "# Title`n`nShown as ``$moji`` and also $moji here.`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'mojibake outside the span on the same line is still an error'
Assert-Match -Text $r.Text -Needle 'Mojibake U+00E2 U+20AC' -Name 'with its B finding'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain C: the -ExecutionPolicy Bypass convention'
$t = New-Tree @{ 'a.md' = "# Title`n`n" + '```sh' + "`npowershell -NoProfile -File scripts/task/start.ps1 -Name docs/x`n" + '```' + "`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a fenced command missing -ExecutionPolicy Bypass is an error'
Assert-Match -Text $r.Text -Needle "no '-ExecutionPolicy Bypass'" -Name 'names the missing flag'
Assert-Match -Text $r.Text -Needle 'a.md:4' -Name 'and the file and line'

$t = New-Tree @{ 'a.md' = "# Title`n`n" + '```sh' + "`npowershell -NoProfile -ExecutionPolicy Bypass -File scripts/task/start.ps1`n" + '```' + "`n" }
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'the flag present in a fence passes'

$t = New-Tree @{ 'a.md' = "# Title`n`nthe scopes read Undefined, so ``powershell -NoProfile -File scripts/lint/check.ps1`` fails.`n" }
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'the broken form quoted in inline prose is discussion, not a command'

$t = New-Tree @{
    'scripts/x.ps1' = @('<#', '.SYNOPSIS', '    x', '.EXAMPLE', '    powershell -NoProfile -File scripts/x.ps1 -Name foo', '.NOTES', '    y', '#>', 'param()', '') -join "`n"
}
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a .ps1 .EXAMPLE missing the flag is an error'
Assert-Match -Text $r.Text -Needle "in a .EXAMPLE with no '-ExecutionPolicy Bypass'" -Name 'the .ps1 message says where'
Assert-Match -Text $r.Text -Needle 'scripts/x.ps1:5' -Name 'and names the file and line'

$t = New-Tree @{
    'scripts/y.ps1' = @(
        '<#', '.SYNOPSIS', '    y', '.EXAMPLE',
        '    powershell -NoProfile -ExecutionPolicy Bypass -File scripts/y.ps1',
        '.NOTES',
        '    The documented route runs through powershell.exe with -File, and a bare',
        '    ''powershell -File script.ps1 -Body ...'' reconstructs argv across a process boundary.',
        '#>', 'param()', ''
    ) -join "`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code '.ps1 comment prose about -File binding is not a command'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain D: a version literal claimed as current'
$t = New-Tree @{ 'a.md' = "# Title`n`nThe workflow plugin loads **4.21.0** now, so the forwarder is safe.`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'a bold literal tied to a present-tense adverb is an error'
Assert-Match -Text $r.Text -Needle 'presented as the version in force' -Name 'names the defect'
Assert-Match -Text $r.Text -Needle 'Get-PluginResolution' -Name 'names the repair'
Assert-Match -Text $r.Text -Needle 'plugin-payload-lib.ps1' -Name 'and where that function lives'
Assert-Match -Text $r.Text -Needle 'a.md:3' -Name 'and the file and line'

$t = New-Tree @{ 'a.md' = "# Title`n`nThose files exist in plugin **4.17.0**, and this repo is loaded on **4.16.0**.`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'the copula shape with NO adverb is an error (the shape the adverb-only rule missed)'

$t = New-Tree @{
    'a.md' = @(
        '# Title', '',
        'It has shipped `prune-merged.ps1` since **4.21.0**, so the file holds no logic.',
        '`some-plugin` **4.17.0** was what this repo loaded then; it has moved beyond that.',
        'Verified on 2026-08-19: Shopify CLI **3.94.3**, Windows PowerShell **5.1.26100.9168**.',
        'The delete capability needs some-plugin **4.17.0** or newer.', ''
    ) -join "`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a DATED or pinned mention is not a currency claim'

$t = New-Tree @{
    'a.md' = "# Title`n`n> On 2026-08-21 this session ran **4.16.0** now, while the record said otherwise.`n`n" +
             '```text' + "`nsome-plugin is loaded on **4.16.0**`n" + '```' + "`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'a blockquote is a record and a fenced sample is not a claim'

$sentence = 'while this repo is loaded on **4.16.0**, and the two differ in what they ship'
$t = New-Tree @{
    'scripts/repo-config.ps1'                          = (Get-ConfigText)
    'docs/workflow/CHANGELOG.md'                       = "# Changelog`n`n$sentence`n"
    'docs/workflow/releases/changelog/1.x/1.2.0.md'    = "# v1.2.0`n`n$sentence`n"
    'docs/workflow/releases/audience/1.2.0.md'         = "# v1.2.0`n`n$sentence`n"
    'docs/workflow/releases/history.md'                = "# Releases`n`n$sentence`n"
}
$r = Invoke-Lint $t
Assert-Equal 0 $r.Code 'the changelog and every release root the seams name are records'
$t = New-Tree @{
    'scripts/repo-config.ps1' = (Get-ConfigText)
    'scripts/README.md'       = "# scripts`n`n$sentence`n"
}
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'the identical sentence on a live page is the defect (the exemption is about the path)'
Assert-Match -Text $r.Text -Needle 'scripts/README.md:3' -Name 'and it is named'

$t = New-Tree @{
    'scripts/repo-config.ps1'     = (Get-ConfigText)
    'docs/workflow/development.md' = "# Branch`n`n### DEPLOY: x`n`nsome-plugin is loaded on **4.16.0**.`n"
}
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'the branch document is deliberately NOT a record: an entry is checked before it folds'

$t = New-Tree @{ 'docs/workflow/CHANGELOG.md' = "# Changelog`n`n$sentence`n" }
$r = Invoke-Lint $t
Assert-Equal 1 $r.Code 'with no config there is no record list, so the changelog is scanned like any page'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain E: the tests/ table against the tests/ directory (opt-in)'
$optE = '@{ TestTable = @{} }'
function New-TableFixture {
    param([string]$Readme, [string[]]$Suites, [string]$Options = $optE)
    $files = @{ 'scripts/README.md' = $Readme }
    foreach ($s in $Suites) { $files["scripts/tests/$s"] = "# suite`n" }
    return (New-Fixture -Extra $files -Options $Options)
}
$tbl2  = "# scripts`n`nIndexed here.`n`n### ``tests/```n`n| suite | what it pins |`n|---|---|`n| ``one.tests.ps1`` | the first thing |`n"
$tblOk = $tbl2 + "| ``two.tests.ps1`` | the second thing |`n"

$fix = New-TableFixture -Readme $tbl2 -Suites @('one.tests.ps1', 'two.tests.ps1')
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a suite on disk with no row is an error'
Assert-Match -Text $r.Text -Needle 'two.tests.ps1' -Name 'and the missing suite is named'
Assert-Match -Text $r.Text -Needle '2 suite(s) on disk, 1 in the table' -Name 'with both counts, so the gap is legible'

$fix = New-TableFixture -Readme $tblOk -Suites @('one.tests.ps1', 'two.tests.ps1')
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'a table complete in both directions passes'

$fix = New-TableFixture -Readme ($tbl2 + "| ``gone.tests.ps1`` | a suite that was deleted |`n") -Suites @('one.tests.ps1')
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a row for a suite that no longer exists is an error too'
Assert-Match -Text $r.Text -Needle 'gone.tests.ps1' -Name 'and the phantom is named'

# A whole-file substring match would go green here; reading the region is what makes it a gate.
$fix = New-TableFixture -Readme ("# scripts`n`nSee ``tests/two.tests.ps1`` for the details.`n`n### ``tests/```n`n| suite | what it pins |`n|---|---|`n| ``one.tests.ps1`` | the first thing |`n") -Suites @('one.tests.ps1', 'two.tests.ps1')
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a mention OUTSIDE the tests/ region does not count as a row'

$fix = New-TableFixture -Readme "# scripts`n`nIndexed here.`n`n| suite | what it pins |`n|---|---|`n| ``one.tests.ps1`` | the first thing |`n" -Suites @('one.tests.ps1')
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a table moved out from under its heading reports everything'
Assert-Match -Text $r.Text -Needle "No '### tests/' section" -Name 'and says which claim went missing'

$fix = New-Fixture -Extra @{ 'scripts/README.md' = "# scripts`n`nNo tests here.`n" } -Options $optE
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'silent where there is no tests directory'
$fix = New-Fixture -Extra @{ 'scripts/tests/one.tests.ps1' = "# suite`n" } -Options $optE
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'silent where there is no scripts README'

# The paths are the seam's: another heading and folder are honoured.
$fix = New-Fixture -Extra @{
    'tools/README.md'        = "# tools`n`n### ``suites/```n`n| suite | pins |`n|---|---|`n| ``a.tests.ps1`` | a |`n"
    'tools/suites/a.tests.ps1' = "# suite`n"
    'tools/suites/b.tests.ps1' = "# suite`n"
} -Options '@{ TestTable = @{ Readme = ''tools/README.md''; Heading = ''suites/''; TestsDir = ''tools/suites'' } }'
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'the readme, heading and directory come from the seam'
Assert-Match -Text $r.Text -Needle 'b.tests.ps1' -Name 'and the unlisted suite there is named'

# Off by default: a repo that never promised the table must not be red on arrival.
$fix = New-Fixture -Extra @{ 'scripts/README.md' = $tbl2; 'scripts/tests/one.tests.ps1' = "# suite`n"; 'scripts/tests/two.tests.ps1' = "# suite`n" }
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'with no TestTable option the check is off'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain F: a paragraph pulled into the blockquote above it'
$head = "# guide`n`n## Getting started`n`n"
$tail = "`nBack to [the overview](../README.md#overview-of-the-parts).`n"

$fix = New-Fixture -Extra @{ 'docs/guide.md' = $head + "> A side note on the line below.`n**This is a RULE and belongs outside the quote.**`n" + $tail }
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a paragraph with no blank line after a blockquote is an error'
Assert-Match -Text $r.Text -Needle 'lazy continuation' -Name 'names the lazy continuation'
Assert-Match -Text $r.Text -Needle 'guide.md:6' -Name 'and the line where the blank line belongs'

$fix = New-Fixture -Extra @{ 'docs/guide.md' = $head + "> A side note.`n`n**This is a RULE, set apart properly.**`n" + $tail }
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'positive twin: with a blank line between there is no finding'
Assert-NoMatch -Text $r.Text -Needle 'lazy continuation' -Name 'no false report on correct markdown'

# A table row does NOT end the quote (it needs a separator row to be a table).
$fix = New-Fixture -Extra @{ 'docs/guide.md' = $head + "> A side note in the middle of a table.`n| **Row** | that vanishes into the quote |`n" + $tail }
$r = Invoke-Lint $fix
Assert-Equal 1 $r.Code 'a table row straight after a blockquote is an error'

# What DOES end it must not be reported: every missed exception is a false block on correct markdown.
$fix = New-Fixture -Extra @{ 'docs/guide.md' = $head +
    "> A note.`n## A heading ends the quote`n`n> A note.`n- A bullet too`n`n> A note.`n2. A numbered item too`n`n" +
    "> A note.`n---`n`n> A note.`n<div>An HTML block too</div>`n" + $tail }
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle 'lazy continuation' -Name 'heading, bullet, numbered item, thematic break and HTML block all end the quote'

$fix = New-Fixture -Extra @{ 'docs/guide.md' = $head + "> A note.`n>`nThis line is outside the quote.`n" + $tail }
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle 'lazy continuation' -Name 'a bare > ends the paragraph'

$fix = New-Fixture -Extra @{ 'docs/guide.md' = $head + '``````' + "`n> this is a prompt, not a quote`nand this is its output`n" + '``````' + "`n" + $tail }
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle 'lazy continuation' -Name 'a > inside a fence is not a blockquote'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain G: index gaps (opt-in warning)'
$optG = '@{ IndexGaps = $true }'
$fix = New-Fixture -Extra @{ 'docs/not-mentioned.md' = "# loose`n" } -Options $optG
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'an index gap is a WARNING, never an error'
Assert-Match -Text $r.Text -Needle "'not-mentioned.md' is not mentioned or linked in this README" -Name 'and it is reported'

$fix = New-Fixture -Extra @{ 'docs/not-mentioned.md' = "# loose`n" }
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle 'not-mentioned.md' -Name 'off by default: no index check without the option'

$fix = New-Fixture -Extra @{ 'docs/.hidden.md' = "# hidden`n" } -Options $optG
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle '.hidden.md' -Name 'a hidden file is configuration and not index-bound'

$fix = New-Fixture -Options $optG
foreach ($v in @('2.13', '2.x', '1.2.3')) {
    Write-Utf8 (Join-Path $fix "docs\$v\note.md") "# note`n"
}
$r = Invoke-Lint $fix
Assert-Equal 0 $r.Code 'version subdirectories give no error'
foreach ($v in @('2.13', '2.x', '1.2.3')) {
    Assert-NoMatch -Text $r.Text -Needle "'$v' is not mentioned" -Name "the version subdirectory '$v' is not index-bound"
}
$fix = New-Fixture -Options $optG
Write-Utf8 (Join-Path $fix 'docs\x.y\note.md') "# note`n"
$r = Invoke-Lint $fix
Assert-Match -Text $r.Text -Needle "'x.y' is not mentioned" -Name "'x.y' is NOT a version folder and stays index-bound (the exclusion is not too wide)"

$fix = New-Fixture -Extra @{ 'docs/not-mentioned.md' = "# loose`n" } -Options $optG
$r = Invoke-Lint $fix -WarningsAsErrors
Assert-Equal 1 $r.Code '-WarningsAsErrors lets a warning set the exit code'
Assert-Match -Text $r.Text -Needle 'FAIL: 0 error(s), 1 warning(s).' -Name 'and the summary says FAIL with the warning counted'

# The branch's own document sits in the workflow folder (named by the changelog seam) and is excluded
# there only: git fixtures, because the branch name decides the file name.
$wf = @{
    'docs/README.md'                = "# docs`n`nThis folder holds guide.md and workflow/.`n"
    'docs/workflow/README.md'       = "# workflow`n`nThe CHANGELOG.md lives here.`n"
    'docs/workflow/CHANGELOG.md'    = "# Changelog`n"
}
$fix = New-GitFixture -Branch 'docs/my-branch' -Extra ($wf + @{ 'docs/workflow/docs-my-branch.md' = "# branch document`n" }) -Options $optG
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle 'docs-my-branch.md' -Name 'the current branch document in the workflow folder is not an index gap'
$fix = New-GitFixture -Branch 'docs/my-branch' -Extra ($wf + @{ 'docs/workflow/docs-other-branch.md' = "# another branch`n" }) -Options $optG
$r = Invoke-Lint $fix
Assert-Match -Text $r.Text -Needle "'docs-other-branch.md' is not mentioned" -Name 'another branch name is not excluded'
$fix = New-GitFixture -Branch 'docs/my-branch' -Extra ($wf + @{ 'docs/docs-my-branch.md' = "# same name, wrong folder`n" }) -Options $optG
$r = Invoke-Lint $fix
Assert-Match -Text $r.Text -Needle "'docs-my-branch.md' is not mentioned" -Name 'the same name outside the workflow folder is index-bound'

# The gitignore filter: an ignored path is not an index gap. Needs a git repo.
$fix = New-GitFixture -Branch 'docs/my-branch' -Extra @{ 'docs/scratch.md' = "# scratch`n"; '.gitignore' = "docs/scratch.md`n" } -Options $optG
$r = Invoke-Lint $fix
Assert-NoMatch -Text $r.Text -Needle 'scratch.md' -Name 'a gitignored path is not an index gap'
$fix = New-GitFixture -Branch 'docs/my-branch' -Extra @{ 'docs/scratch.md' = "# scratch`n" } -Options $optG
$r = Invoke-Lint $fix
Assert-Match -Text $r.Text -Needle "'scratch.md' is not mentioned" -Name 'and the same file without the ignore rule is reported'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-brain: -Quiet and the summary line'
$fix = New-Fixture -Extra @{ 'docs/guide.md' = $head + "> A note.`nPulled in.`n`n[gone](nope.md)`n" }
$r = Invoke-Lint $fix -Quiet
Assert-Equal 1 $r.Code 'exit 1 under -Quiet'
Assert-Match -Text $r.Text -Needle 'FAIL: 2 error(s) (A: 1, F: 1), 0 warning(s).' -Name 'the summary line counts every error category, by letter'
Assert-Match -Text $r.Text -Needle '== A.' -Name 'a category with findings is still shown'
Assert-NoMatch -Text $r.Text -Needle '== B.' -Name 'a clean category is not'
Assert-NoMatch -Text $r.Text -Needle 'Repo root:' -Name 'and the header is not'
$fix = New-Fixture
$r = Invoke-Lint $fix -Quiet
Assert-Equal 'PASS: 0 error(s), 0 warning(s).' $r.Text.Trim() 'a clean tree under -Quiet prints the summary line and nothing else'

# ---------------------------------------------------------------------------------------------------
Write-SuiteHeader 'bwj lint-changed-hook: one run, every error category, fail-soft'
$fix = New-GitFixture -Branch 'docs/my-branch'
Invoke-GitFixture $fix @('add', '-A')
Invoke-GitFixture $fix @('commit', '-q', '-m', 'fixture')
$r = Invoke-Hook $fix
Assert-Equal 0 $r.Code 'a committed clean tree: exit 0'
Assert-Equal '' $r.Text.Trim() 'and silent'

# A change with no markdown in it must not even start the lint.
Write-Utf8 (Join-Path $fix 'notes.txt') "not markdown`n"
$r = Invoke-Hook $fix
Assert-Equal '' $r.Text.Trim() 'a change that touches no *.md file is silent'

Write-Utf8 (Join-Path $fix 'docs\extra.md') "# extra`n`nA clean new page.`n"
$r = Invoke-Hook $fix
Assert-Equal 0 $r.Code 'a changed .md with no findings: exit 0'
Assert-Equal '' $r.Text.Trim() 'and silent'

# The merge's point: ONE run counts A and F together (one store counted two categories, the other
# re-ran the lint and named only dead links).
Write-Utf8 (Join-Path $fix 'docs\extra.md') ("# extra`n`n> A note.`nPulled in.`n`n[gone](nope.md)`n")
$r = Invoke-Hook $fix
Assert-Equal 0 $r.Code 'findings never fail the hook'
Assert-Match -Text $r.Text -Needle '"continue":true' -Name 'it hands back continue: true, so it never blocks'
Assert-Match -Text $r.Text -Needle '2 error(s) (A: 1, F: 1)' -Name 'and counts both the dead link and the lazy continuation from a single run'
Assert-Match -Text $r.Text -Needle 'systemMessage' -Name 'in a systemMessage'

# A mojibake finding is counted too (a category the old hooks could not see).
Write-Utf8 (Join-Path $fix 'docs\extra.md') ("# extra`n`nn/a " + [string][char]0x00E2 + [char]0x20AC + [char]0x201D + " here`n")
$r = Invoke-Hook $fix
Assert-Match -Text $r.Text -Needle '1 error(s) (B: 1)' -Name 'a mojibake finding is counted as well'

# Fail-soft outside a repo, and the lint is found as the hook's sibling (the fixture ships none).
$none = New-Tree @{ 'a.md' = "# x`n" }
$r = Invoke-Hook $none
Assert-Equal 0 $r.Code 'outside a git repository the hook exits 0'
Assert-Equal '' $r.Text.Trim() 'and says nothing'
Assert-False (Test-Path -LiteralPath (Join-Path $fix 'scripts\maintenance\lint-brain.ps1')) 'the fixture holds no lint-brain, so the hook found its sibling, not one in the repo'

# The hook must not be registered by the plugin while the stores still register their own copy.
$hooksJson = Get-Content -LiteralPath (Join-Path $ExtRoot 'hooks\hooks.json') -Raw -Encoding UTF8
Assert-NoMatch -Text $hooksJson -Needle 'lint-changed-hook' -Name 'the plugin does not register the hook yet (a second registration would run it twice)'

} finally {
    if (Test-Path -LiteralPath $Fixture) { Remove-Item -LiteralPath $Fixture -Recurse -Force -ErrorAction SilentlyContinue }
}

if (Write-FixtureGitSummary -Subject 'lint-brain.ps1') { $script:Fail++ }
Complete-Suite
