<#
.SYNOPSIS
    Tests for dkj-subagents-shopify's sync-summary: the pure rules in scripts/lib/sync-summary-rules.ps1
    and the script itself against a tiny local git repo (issue #4289).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell. Exit code 0 if everything passes, 1 on a failure.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/shopify-sync-summary.tests.ps1

    No network. The rules are driven directly; the script is driven against a throw-away repo that this
    suite builds under the system temp folder with 'git init' and local commits only (the same idiom
    consumers.tests.ps1 uses for its fixture), and removes at the end. Made-up fixtures only (this repo
    is public): no real store, section or domain names.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Plugin   = Join-Path $RepoRoot 'plugins\dkj-subagents\dkj-subagents-shopify'
$RulesLib = Join-Path $Plugin 'scripts\lib\sync-summary-rules.ps1'
$Script   = Join-Path $Plugin 'scripts\task\sync-summary.ps1'

. (Join-Path $Plugin 'scripts\lib\sync-rules.ps1')
. (Join-Path $Plugin 'scripts\lib\live-push-rules.ps1')
. $RulesLib

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Label)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label" -ForegroundColor Red }
}
function Assert-Equal {
    param($Expected, $Actual, [string]$Label)
    if ("$Expected" -eq "$Actual") { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label`n         expected: '$Expected'`n         got:      '$Actual'" -ForegroundColor Red }
}
function Write-Group { param([string]$Title) Write-Host ""; Write-Host "== $Title" -ForegroundColor Cyan }

$fs = Get-SyncSummaryFieldSeparator

Write-Group '1. the field separator is the unit separator'
Assert-Equal 31 ([int][char]$fs) 'U+001F, built from its code point'

Write-Group '2. Get-SyncSummaryAreaOf'
Assert-Equal 'sections' (Get-SyncSummaryAreaOf 'sections/banner.liquid') 'a section'
Assert-Equal 'templates' (Get-SyncSummaryAreaOf 'templates/page.x.json') 'a template'
Assert-Equal 'config' (Get-SyncSummaryAreaOf 'config/settings_data.json') 'config'
Assert-Equal 'sections' (Get-SyncSummaryAreaOf 'Sections/Banner.liquid') 'case-insensitive'
Assert-Equal 'sections' (Get-SyncSummaryAreaOf 'sections\banner.liquid') 'backslashes read as slashes'
Assert-Equal '' (Get-SyncSummaryAreaOf 'README.md') 'a root file is in no area'
Assert-Equal '' (Get-SyncSummaryAreaOf 'sectionsx/a.liquid') 'a longer directory name is not the area'
Assert-Equal 8 @(Get-SyncSummaryAreas).Count 'eight areas, the same eight directories as the live push'
Assert-Equal 'removed' (Get-SyncSummaryStatusLabel 'D') 'status D'
Assert-Equal 'T' (Get-SyncSummaryStatusLabel 'T') 'an unknown status is returned as it is'

Write-Group '3. sync-commit subjects, by the default pattern sync-main uses'
$pat = Get-SyncDefaultReferencePattern
Assert-True (Test-SyncSummarySubject -Subject 'sync: live theme drift 2026-08-03' -Pattern $pat) 'sync: ...'
Assert-True (Test-SyncSummarySubject -Subject 'Sync main with live theme' -Pattern $pat) 'Sync main with live theme'
Assert-True (-not (Test-SyncSummarySubject -Subject 'fix: resync the banner' -Pattern $pat)) 'a subject that merely contains sync is not one'
Assert-True (-not (Test-SyncSummarySubject -Subject 'sync: x' -Pattern '')) 'an empty pattern matches nothing'
Assert-True (Test-SyncSummaryPatternValid '^drift') 'a regex is valid'
Assert-True (-not (Test-SyncSummaryPatternValid '(')) 'a broken regex is not'
Assert-True (-not (Test-SyncSummaryPatternValid '')) 'an empty one is not'

Write-Group '4. ConvertFrom-SyncSummaryLog keeps sync commits in git order'
$lines = @(
    ('a1' + $fs + 'a' + $fs + '2026-08-03' + $fs + 'bot' + $fs + 'sync: live theme drift'),
    ('b2' + $fs + 'b' + $fs + '2026-08-02' + $fs + 'dev' + $fs + 'feat: a thing'),
    'short line',
    '',
    ('c3' + $fs + 'c' + $fs + '2026-08-01' + $fs + 'bot' + $fs + 'Sync main with live theme')
)
$c = @(ConvertFrom-SyncSummaryLog -Lines $lines -Pattern $pat)
Assert-Equal 2 $c.Count 'two sync commits of five lines'
Assert-Equal 'a1' $c[0].Sha 'newest first, as git printed them'
Assert-Equal 'bot' $c[1].Author 'the author field'
Assert-Equal 0 @(ConvertFrom-SyncSummaryLog -Lines @() -Pattern $pat).Count 'no lines, no commits'

Write-Group '5. ConvertFrom-SyncSummaryNameStatus'
$rows = @(ConvertFrom-SyncSummaryNameStatus -Lines @("A`tsections/a.liquid", "M`tconfig/settings_data.json", "R100`told/x.liquid`tsnippets/x.liquid", '', 'junk'))
Assert-Equal 3 $rows.Count 'blank and tab-less lines are skipped'
Assert-Equal 'A' $rows[0].Status 'status letter'
Assert-Equal 'R' $rows[2].Status 'R100 reads as R'
Assert-Equal 'snippets/x.liquid' $rows[2].Path 'a rename keeps its new path'
Assert-Equal 'old/x.liquid' $rows[2].OldPath 'and its old path (#4301)'
Assert-Equal '' $rows[0].OldPath 'a non-rename has no old path'

Write-Group '6. ConvertFrom-SyncSummaryRange and the -Commit guard'
$r = ConvertFrom-SyncSummaryRange 'origin/main...origin/live'
Assert-Equal 'origin/main' $r.Base 'base'
Assert-Equal 'origin/live' $r.Head 'head'
Assert-Equal 'v2.47.0' (ConvertFrom-SyncSummaryRange 'v2.47.0...live').Base 'a single dot is part of a ref'
Assert-True ($null -eq (ConvertFrom-SyncSummaryRange 'a..b')) 'two dots are not a range here'
Assert-True ($null -eq (ConvertFrom-SyncSummaryRange '--output=x...b')) 'a base that reads as an option is refused'
Assert-True ($null -eq (ConvertFrom-SyncSummaryRange 'a...-b')) 'a head that reads as an option is refused'
Assert-True ($null -eq (ConvertFrom-SyncSummaryRange 'a')) 'no separator'
Assert-True (Test-SyncSummaryCommitArg '19d6034') 'a hash is a plain revision'
Assert-True (Test-SyncSummaryCommitArg 'HEAD~2') 'HEAD~2 is'
Assert-True (-not (Test-SyncSummaryCommitArg '--output=x')) 'an option is not'
Assert-True (-not (Test-SyncSummaryCommitArg 'a b')) 'whitespace is not'
Assert-True (-not (Test-SyncSummaryCommitArg '')) 'empty is not'

Write-Group '7. Format-SyncSummaryNames'
Assert-Equal 'a, b' (Format-SyncSummaryNames -Names @('a', 'b') -Max 5) 'under the cap'
Assert-Equal 'a, b ... and 1 more' (Format-SyncSummaryNames -Names @('a', 'b', 'c') -Max 2) 'over the cap'

Write-Group '8. Get-SyncSummaryDeployRange refuses where the seam is unanswered'
$d = Get-SyncSummaryDeployRange -Trunk 'main' -DeployBranch ''
Assert-True (-not $d.Ok) 'no deploy branch: refused'
Assert-True ($d.Reason -match 'Get-ShopifyLiveDeployBranch') 'the refusal names the seam'
$d = Get-SyncSummaryDeployRange -Trunk '' -DeployBranch 'live'
Assert-Equal 'origin/main...origin/live' $d.Range 'an empty trunk answer defaults to main'
Assert-Equal 'origin/dev...origin/live' (Get-SyncSummaryDeployRange -Trunk 'dev' -DeployBranch 'live').Range 'the trunk seam is used'
Assert-True (-not (Get-SyncSummaryDeployRange -Trunk 'main' -DeployBranch 'main').Ok) 'the deploy branch may not be the trunk'
Assert-True (-not (Get-SyncSummaryDeployRange -Trunk 'main' -DeployBranch '--x').Ok) 'an option-shaped name is refused'

Write-Group '9. Get-SyncSummaryFindings'
$files = @(
    [pscustomobject]@{ Status = 'D'; Path = 'sections/promo-landing.liquid' }
    [pscustomobject]@{ Status = 'D'; Path = 'sections/clean-gone.liquid' }
    [pscustomobject]@{ Status = 'A'; Path = 'sections/fresh.liquid' }
    [pscustomobject]@{ Status = 'M'; Path = 'config/settings_data.json' }
    [pscustomobject]@{ Status = 'D'; Path = 'templates/page.old.json' }
    [pscustomobject]@{ Status = 'M'; Path = 'sections/changed.liquid' }
)
$lookup = { param($n) if ($n -eq 'promo-landing') { @('templates/page.promo.json') } else { @() } }
$f = @(Get-SyncSummaryFindings -Files $files -ReferenceLookup $lookup)
$kinds = @($f | ForEach-Object { $_.Kind })
Assert-Equal 'removed-section-referenced,removed-section-clean,new-section,settings,removed-template' ($kinds -join ',') 'all five kinds, in report order'
Assert-Equal 'alert' $f[0].Level 'a still-referenced removal is an alert'
Assert-True ($f[0].Detail -contains 'templates/page.promo.json') 'it names the template'
Assert-Equal 'info' $f[1].Level 'a clean removal is only information'
Assert-True ($f[3].Message -match 'settings_data\.json') 'the settings finding names the file'
Assert-True ($f[2].Detail[0] -eq 'fresh') 'the new section is named without extension'
Assert-Equal 0 @(Get-SyncSummaryFindings -Files @([pscustomobject]@{ Status = 'M'; Path = 'sections/a.liquid' })).Count 'a plain change raises nothing'
$f2 = @(Get-SyncSummaryFindings -Files @([pscustomobject]@{ Status = 'D'; Path = 'sections/x.liquid' }))
Assert-Equal 'removed-section-clean' $f2[0].Kind 'no lookup given: nothing points at it'

# #4301: a renamed section's OLD name is gone just as a deleted one's is.
$renLookup = { param($n) if ($n -eq 'promo-hero') { @('templates/page.hero.json') } else { @() } }
$f3 = @(Get-SyncSummaryFindings -Files @([pscustomobject]@{ Status = 'R'; Path = 'sections/hero-v2.liquid'; OldPath = 'sections/promo-hero.liquid' }) -ReferenceLookup $renLookup)
Assert-Equal 'removed-section-referenced' $f3[0].Kind 'a renamed section a template still names is an alert'
Assert-True ($f3[0].Message -match "'promo-hero' was renamed to 'hero-v2'") 'it names the old and the new name'
Assert-True ($f3[0].Detail -contains 'templates/page.hero.json') 'and the template'
$f4 = @(Get-SyncSummaryFindings -Files @([pscustomobject]@{ Status = 'R'; Path = 'sections/hero-v2.liquid'; OldPath = 'sections/promo-hero.liquid' }))
Assert-Equal 'removed-section-clean' $f4[0].Kind 'a rename nothing points at is a clean removal'
$f5 = @(Get-SyncSummaryFindings -Files @([pscustomobject]@{ Status = 'R'; Path = 'sections/promo-hero.liquid'; OldPath = 'sections/old/promo-hero.liquid' }) -ReferenceLookup $renLookup)
Assert-Equal 0 $f5.Count 'a rename that keeps the section name raises nothing'
$f6 = @(Get-SyncSummaryFindings -Files @([pscustomobject]@{ Status = 'R'; Path = 'snippets/promo-hero.liquid'; OldPath = 'sections/promo-hero.liquid' }) -ReferenceLookup $renLookup)
Assert-Equal 'removed-section-referenced' $f6[0].Kind 'a section moved out of sections/ is gone as a section'

# --- The script, against a throw-away repo ----------------------------------------------------
Write-Group '10. the script against a fixture repo'
$Fixture = Join-Path ([System.IO.Path]::GetTempPath()) "sync-summary-fixture-$PID-$([guid]::NewGuid().ToString('n'))"
function Invoke-FixtureGit {
    param([string[]]$GitArgs)
    $prev = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { $o = & git -C $Fixture -c user.name=Test -c user.email=test@example.invalid -c commit.gpgsign=false @GitArgs 2>&1 } finally { $ErrorActionPreference = $prev }
    if ($LASTEXITCODE -ne 0) { throw "fixture git failed: git $($GitArgs -join ' ')" }
    return $o
}
function Write-FixtureFile {
    param([string]$Rel, [string]$Text)
    $p = Join-Path $Fixture $Rel
    $dir = Split-Path -Parent $p
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($p, $Text)
}
function Invoke-SummaryScript {
    param([string[]]$ScriptArgs)
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script @ScriptArgs -RootOverride $Fixture 2>&1
    return [pscustomobject]@{ Code = $LASTEXITCODE; Out = ($out -join "`n") }
}

try {
    New-Item -ItemType Directory -Path $Fixture -Force | Out-Null
    Invoke-FixtureGit @('init', '-q') | Out-Null
    Write-FixtureFile 'sections/old-banner.liquid' 'old'
    Write-FixtureFile 'sections/kept.liquid' 'kept'
    Write-FixtureFile 'sections/orphan.liquid' 'orphan'
    Write-FixtureFile 'templates/page.promo.json' '{ "sections": { "main": { "type": "old-banner" } } }'
    Write-FixtureFile 'templates/page.gone.json' '{ "sections": { "main": { "type": "kept" } } }'
    Write-FixtureFile 'config/settings_data.json' '{ "a": 1 }'
    Write-FixtureFile 'sections/promo-hero.liquid' ('{% comment %} the promo hero section, long enough for rename detection {% endcomment %}' + "`n" + ('<div class="hero">{{ section.settings.title }}</div>' + "`n") * 5)
    Write-FixtureFile 'templates/page.hero.json' '{ "sections": { "main": { "type": "promo-hero" } } }'
    Invoke-FixtureGit @('add', '-A') | Out-Null
    Invoke-FixtureGit @('commit', '-q', '-m', 'feat: the theme') | Out-Null
    Invoke-FixtureGit @('branch', '-M', 'main') | Out-Null
    $baseSha = ((Invoke-FixtureGit @('rev-parse', 'HEAD')) | Select-Object -First 1).ToString().Trim()

    Remove-Item -LiteralPath (Join-Path $Fixture 'sections/old-banner.liquid')
    Remove-Item -LiteralPath (Join-Path $Fixture 'sections/orphan.liquid')
    Remove-Item -LiteralPath (Join-Path $Fixture 'templates/page.gone.json')
    Move-Item -LiteralPath (Join-Path $Fixture 'sections/promo-hero.liquid') -Destination (Join-Path $Fixture 'sections/hero-v2.liquid')
    Write-FixtureFile 'sections/brand-new.liquid' 'new'
    Write-FixtureFile 'config/settings_data.json' '{ "a": 2 }'
    Invoke-FixtureGit @('add', '-A') | Out-Null
    Invoke-FixtureGit @('commit', '-q', '-m', 'sync: live theme drift 2026-08-03') | Out-Null
    $syncSha = ((Invoke-FixtureGit @('rev-parse', 'HEAD')) | Select-Object -First 1).ToString().Trim()

    Write-FixtureFile 'README.md' 'readme'
    Invoke-FixtureGit @('add', '-A') | Out-Null
    Invoke-FixtureGit @('commit', '-q', '-m', 'docs: readme') | Out-Null

    $r = Invoke-SummaryScript @()
    Assert-Equal 0 $r.Code 'the default run exits 0'
    Assert-True ($r.Out -match 'Live-drift sync') 'it found the sync commit, not the newer docs commit'
    Assert-True ($r.Out -match 'Sections \(the building blocks of pages\)') 'the area label is English'
    Assert-True ($r.Out -match 'removed\s+2: ') 'two sections removed'
    Assert-True ($r.Out -match "Section 'old-banner' was removed, but these template") 'the still-referenced section is flagged'
    Assert-True ($r.Out -match 'templates/page\.promo\.json') 'with the template that points at it'
    Assert-True ($r.Out -match "Section 'orphan' was removed and no template") 'an unreferenced removal is a clean one'
    Assert-True ($r.Out -match "Section 'promo-hero' was renamed to 'hero-v2', but these template") 'a renamed section a template still names is flagged (#4301)'
    Assert-True ($r.Out -match 'templates/page\.hero\.json') 'with the template that still names the old name'
    Assert-True ($r.Out -match '1 new section\(s\)') 'the new section is counted'
    Assert-True ($r.Out -match 'Theme editor settings changed: settings_data\.json') 'settings are flagged'
    Assert-True ($r.Out -match '1 template\(s\) removed') 'the removed template is flagged'
    Assert-True ($r.Out -match 'Full diff: git show ') 'it names the full diff'

    $r = Invoke-SummaryScript @('-Commit', $syncSha)
    Assert-Equal 0 $r.Code '-Commit with a hash exits 0'
    Assert-True ($r.Out -match "Section 'old-banner' was removed, but") '-Commit reads the same state'

    $r = Invoke-SummaryScript @('-List')
    Assert-Equal 0 $r.Code '-List exits 0'
    Assert-True ($r.Out -match 'sync: live theme drift 2026-08-03') '-List shows the sync commit'
    Assert-True (-not ($r.Out -match 'docs: readme')) '-List does not show other commits'

    $r = Invoke-SummaryScript @('-Commit', '--output=x')
    Assert-Equal 1 $r.Code 'an option-shaped -Commit is refused'
    $r = Invoke-SummaryScript @('-Commit', 'nosuchrevision')
    Assert-Equal 1 $r.Code 'an unknown commit is refused'
    Assert-True ($r.Out -match 'not found') 'and says so'

    $r = Invoke-SummaryScript @('-Range', "$baseSha...$syncSha")
    Assert-Equal 0 $r.Code '-Range exits 0'
    Assert-True ($r.Out -match 'Live back-flow') 'the back-flow header'
    Assert-True ($r.Out -match "Section 'old-banner' was removed, but") 'the checks read the head of the range'
    $r = Invoke-SummaryScript @('-Range', 'nonsense')
    Assert-Equal 1 $r.Code 'a malformed -Range is refused'
    $r = Invoke-SummaryScript @('-Range', "$baseSha...$syncSha", '-Commit', $syncSha)
    Assert-Equal 1 $r.Code '-Range with -Commit is refused'

    $r = Invoke-SummaryScript @('-SinceTrunk')
    Assert-Equal 1 $r.Code '-SinceTrunk with the deploy-branch seam unanswered is refused'
    Assert-True ($r.Out -match 'Get-ShopifyLiveDeployBranch') 'naming the seam'

    # The seam answers: a deploy branch, a trunk, and a sync pattern of the store's own.
    Write-FixtureFile 'scripts/repo-config.ps1' @'
function Get-ShopifyLiveDeployBranch { return 'live' }
function Get-TrunkBranchName { return 'main' }
function Get-ShopifySyncReferencePattern { return '^drift:' }
'@
    Invoke-FixtureGit @('update-ref', 'refs/remotes/origin/main', $baseSha) | Out-Null
    Invoke-FixtureGit @('update-ref', 'refs/remotes/origin/live', $syncSha) | Out-Null
    $r = Invoke-SummaryScript @('-SinceTrunk')
    Assert-Equal 0 $r.Code '-SinceTrunk with the seam answered exits 0'
    Assert-True ($r.Out -match 'origin/main\.\.\.origin/live') 'it summarised origin/main...origin/live'
    Assert-True ($r.Out -match "Section 'old-banner' was removed, but") 'and found the same drift'

    $r = Invoke-SummaryScript @()
    Assert-Equal 0 $r.Code 'a run with a pattern that matches nothing exits 0'
    Assert-True ($r.Out -match 'No sync commit found') 'the store''s own pattern replaces the default'
    $r = Invoke-SummaryScript @('-Commit', 'HEAD', '-SinceTrunk')
    Assert-Equal 1 $r.Code '-SinceTrunk with -Commit is refused'
}
finally {
    if (Test-Path -LiteralPath $Fixture) {
        # git marks object files read-only on Windows; clear that before removing the tree.
        Get-ChildItem -LiteralPath $Fixture -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { try { $_.Attributes = 'Normal' } catch { } }
        Remove-Item -LiteralPath $Fixture -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Group '11. the files are English, ASCII and read-only'
foreach ($p in @($RulesLib, $Script)) {
    $bytes = [System.IO.File]::ReadAllBytes($p)
    $nonAscii = @($bytes | Where-Object { $_ -gt 127 }).Count
    Assert-Equal 0 $nonAscii ("{0} is pure ASCII" -f (Split-Path -Leaf $p))
}
$src = Get-Content -LiteralPath $Script -Raw
Assert-True ($src -match 'Get-ShopifySyncReferencePattern') 'the script reads the store''s sync-pattern seam'
Assert-True ($src -match 'Get-SyncDefaultReferencePattern') 'and falls back to the one default sync-main uses'
Assert-True (-not ($src -match 'Invoke-WebRequest|shopify theme|git (push|commit|checkout|reset|fetch)')) 'read-only: no network, no push, no write'
Assert-True ($src -match 'Format-SafeProseToken') 'refusals go through Format-SafeProseToken'

Write-Host ''
Write-Host ("{0} passed, {1} failed" -f $script:pass, $script:fail) -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
