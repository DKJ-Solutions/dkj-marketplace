<#
.SYNOPSIS
    Regression tests for the shared BWJ theme-reference check that dkj-repo-workflow-bwj ships --
    scripts/task/check-theme-refs.ps1 and scripts/lib/theme-refs-rules.ps1 (issue #4272, step 2 of #4259).

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/bwj-theme-refs.tests.ps1

    WHY A SUITE HERE FOR A FILE NOBODY IN THIS REPO USES -- the same answer bwj-market-urls.tests.ps1
    gives. Each BWJ store carried its own, diverged copy of this check. The converged copy takes, per
    behaviour, whichever copy was the more correct, and a mechanism shipped without a suite in the repo
    that ships it is one edit away from drifting again, this time inside the plugin.

    EVERYTHING RUNS ON MADE-UP FIXTURE THEMES built in a temp directory (this repo is public: no store
    name, domain or theme id appears here). Each category is tested in BOTH directions -- a fixture with
    the fault must be flagged, a clean one must be silent -- because a check that breaks silently is
    worse than none: it stays green while something breaks.

    WHAT IT HOLDS, one case group per behaviour where the two store copies differed:

      1. SECTION DEFINITIONS are only sections/*.liquid; a .json in sections/ is a GROUP.
      2. REFERENCES are the 'type' directly under sections.<id>, parsed; block types are not sections.
      3. TEMPLATES ARE READ RECURSIVELY (templates/customers/ is real).
      4. A MISSING GROUP is an error; '_blocks' is built in; either quote style in liquid is read.
      5. THE ORPHAN LIST: presets, Section Rendering API (with a bounded match), Cart Sections API,
         own-companion-asset exclusion, context variants of a group.
      6. JSON SHAPE: leading banner and // lines tolerated, trailing comma a warning, an unparseable
         file an ERROR (never silently skipped), a raw control character an error, and a quote inside a
         banner comment not confusing the string state.
      7. THE ALLOWLIST: -AllowMissing and the optional Get-ThemeRefsAllowedMissing seam silence the exit
         code and keep the finding visible as [KNOWN].
      8. EXIT CODES AND -Quiet.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Ext      = Join-Path $RepoRoot 'plugins\dkj-repo-workflow\extensions\dkj-repo-workflow-bwj'
$Checker  = Join-Path $Ext 'scripts\task\check-theme-refs.ps1'
$LibPath  = Join-Path $Ext 'scripts\lib\theme-refs-rules.ps1'
$Suite    = Join-Path ([System.IO.Path]::GetTempPath()) "bwj-theme-refs-fixture-$PID-$([guid]::NewGuid().ToString('n'))"

$script:pass = 0
$script:fail = 0
$script:n    = 0

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
function Assert-Match {
    param([string]$Text, [string]$Needle, [string]$Label)
    if ($Text.Contains($Needle)) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label -- '$Needle' not in the output`n$Text" -ForegroundColor Red }
}
function Assert-NoMatch {
    param([string]$Text, [string]$Needle, [string]$Label)
    if (-not $Text.Contains($Needle)) { $script:pass++; Write-Host "  [PASS] $Label" -ForegroundColor Green }
    else { $script:fail++; Write-Host "  [FAIL] $Label -- '$Needle' was in the output`n$Text" -ForegroundColor Red }
}
function Write-Group { param([string]$Title) Write-Host ''; Write-Host $Title -ForegroundColor Cyan }

function New-Fixture {
    $script:n++
    $root = Join-Path $Suite "fix$($script:n)"
    foreach ($d in 'sections', 'templates', 'layout', 'assets') { New-Item -ItemType Directory -Force -Path (Join-Path $root $d) | Out-Null }
    return $root
}
function Set-File {
    param([string]$Root, [string]$Rel, [string]$Content)
    $p = Join-Path $Root $Rel
    $dir = Split-Path -Parent $p
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($p, $Content, (New-Object System.Text.UTF8Encoding($false)))
}
function Invoke-Checker {
    param([string]$Root, [switch]$WarningsAsErrors, [switch]$Quiet, [string[]]$AllowMissing)
    $a = @('-Path', $Root)
    if ($WarningsAsErrors) { $a += '-WarningsAsErrors' }
    if ($Quiet) { $a += '-Quiet' }
    if ($AllowMissing) { $a += '-AllowMissing'; $a += ($AllowMissing -join ',') }
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Checker @a 2>&1 } finally { $ErrorActionPreference = $prev }
    $code = $LASTEXITCODE
    $text = (@($out | ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { [string]$_.Exception.Message } else { [string]$_ } }) -join "`n")
    return [pscustomobject]@{ Text = $text; Code = $code }
}

$HeroTpl = '{ "sections": { "hero_1": { "type": "hero" } }, "order": ["hero_1"] }'

Write-Host 'The shared BWJ theme-reference check -- where the plugin ships it (#4272)' -ForegroundColor Cyan
Assert-True (Test-Path -LiteralPath $Checker) 'dkj-repo-workflow-bwj ships scripts/task/check-theme-refs.ps1'
Assert-True (Test-Path -LiteralPath $LibPath) 'dkj-repo-workflow-bwj ships scripts/lib/theme-refs-rules.ps1'

try {
    # ---------------------------------------------------------------------------------------------------
    Write-Group '1. baseline: a clean tree'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' $HeroTpl
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'a consistent tree exits 0'
    Assert-Match $r.Text 'Summary: 0 error(s), 0 warning(s).' 'the summary is clean'
    Assert-Match $r.Text 'PASS' 'the verdict says PASS'

    # ---------------------------------------------------------------------------------------------------
    Write-Group '2. A: a missing section is an error and names both sides'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/page.promo.json' '{ "sections": { "gone_1": { "type": "vanished-landing" } }, "order": ["gone_1"] }'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'a template pointing at a missing section exits 1'
    Assert-Match $r.Text "vanished-landing" 'names the missing type'
    Assert-Match $r.Text 'templates/page.promo.json' 'names the template (relative path)'
    Assert-Match $r.Text "section 'gone_1'" 'names the section id, the locator the theme editor shows'

    Write-Group '3. a section GROUP (.json) is not a section definition'
    $fx = New-Fixture
    Set-File $fx 'sections/header-group.json' '{ "type": "header", "sections": {}, "order": [] }'
    Set-File $fx 'layout/theme.liquid' "{% sections 'header-group' %}"
    Set-File $fx 'templates/index.json' '{ "sections": { "g_1": { "type": "header-group" } }, "order": ["g_1"] }'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'a template naming a group as a section type is a missing section (counting groups as sections hid this)'

    Write-Group '4. block types are not sections (parse, never grep)'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' '{ "sections": { "hero_1": { "type": "hero", "blocks": { "a": { "type": "faq_item" }, "b": { "type": "heading" } }, "block_order": ["a","b"] } }, "order": ["hero_1"] }'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'block types produce no error'
    Assert-NoMatch $r.Text 'faq_item' 'faq_item is not reported'

    Write-Group '5. templates are read RECURSIVELY'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' $HeroTpl
    Set-File $fx 'templates/customers/login.json' '{ "sections": { "x_1": { "type": "login-missing" } }, "order": ["x_1"] }'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'a broken reference in templates/customers/ is found'
    Assert-Match $r.Text 'templates/customers/login.json' 'with its relative path'

    Write-Group '6. the built-in _blocks type is never missing'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' '{ "sections": { "hero_1": { "type": "hero" }, "w_1": { "type": "_blocks" } }, "order": ["hero_1"] }'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code '_blocks is Shopify''s own wrapper section'

    Write-Group '7. a missing GROUP and both quote styles in liquid'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' $HeroTpl
    Set-File $fx 'layout/theme.liquid' "{% sections 'footer-group' %}"
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'a {% sections %} call with no sections/<group>.json is an error'
    Assert-Match $r.Text "section group 'footer-group'" 'names the group'
    Assert-Match $r.Text 'layout/theme.liquid (line 1)' 'and where it is called'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' '{ "sections": {}, "order": [] }'
    Set-File $fx 'templates/gift_card.liquid' ('{% section "hero" %}' + "`r`n" + '{% section "absent-one" %}')
    $r = Invoke-Checker -Root $fx
    Assert-Match $r.Text "'absent-one'" 'a double-quoted {% section %} call is read, with CRLF line ends'
    Assert-Match $r.Text 'templates/gift_card.liquid (line 2)' 'and the line number is right'
    Assert-NoMatch $r.Text "'hero' does not exist" 'a double-quoted call to an existing section is fine'

    # ---------------------------------------------------------------------------------------------------
    Write-Group '8. B: the uncalled list'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'sections/forgotten.liquid' '<div>x</div>'
    Set-File $fx 'templates/index.json' $HeroTpl
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'an uncalled section is a WARNING, not an error'
    Assert-Match $r.Text 'forgotten' 'it is listed'
    $r2 = Invoke-Checker -Root $fx -WarningsAsErrors
    Assert-Equal 1 $r2.Code '-WarningsAsErrors lets it set the exit code'

    Write-Group '9. B: a section WITH presets is not a finding'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'sections/addable.liquid' "<div>x</div>`n{% schema %}`n{ `"name`": `"A`", `"presets`": [ { `"name`": `"A`" } ] }`n{% endschema %}"
    Set-File $fx 'templates/index.json' $HeroTpl
    $r = Invoke-Checker -Root $fx -WarningsAsErrors
    Assert-Equal 0 $r.Code 'a preset section stays green even with -WarningsAsErrors'
    Assert-Match $r.Text 'addable' 'but is still named, for information'

    Write-Group '10. B: Section Rendering API counts as use, and the match is BOUNDED'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'sections/dynamic.liquid' '<div>x</div>'
    Set-File $fx 'sections/dynamic-long.liquid' '<div>x</div>'
    Set-File $fx 'assets/theme.js' 'fetch("/?section_id=dynamic-long")'
    Set-File $fx 'templates/index.json' $HeroTpl
    $r = Invoke-Checker -Root $fx
    Assert-NoMatch $r.Text 'dynamic-long' 'section_id=dynamic-long makes dynamic-long alive'
    Assert-Match $r.Text 'dynamic' 'but it is NOT evidence for the section called just dynamic'
    Set-File $fx 'assets/theme.js' 'fetch("/?section_id=dynamic&x=1")'
    $r = Invoke-Checker -Root $fx
    Assert-Match $r.Text "`n    dynamic-long`n" 'a section_id followed by & still matches dynamic (so only dynamic-long is left uncalled)'

    Write-Group '11. B: Cart Sections API counts as use'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'sections/bundled.liquid' '<div>x</div>'
    Set-File $fx 'assets/theme.js' "function f() {`n  let sectionsToBundle = [`"bundled`"];`n}"
    Set-File $fx 'templates/index.json' $HeroTpl
    $r = Invoke-Checker -Root $fx
    Assert-NoMatch $r.Text 'bundled' 'a name quoted on a line that mentions sections is alive'

    Write-Group '12. B: the own companion asset is no evidence of use'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'sections/lonely.liquid' '<div>x</div>'
    Set-File $fx 'assets/lonely.js' 'console.log("lonely");'
    Set-File $fx 'templates/index.json' $HeroTpl
    $r = Invoke-Checker -Root $fx
    Assert-Match $r.Text 'lonely' 'a section with only its own asset stays uncalled'

    Write-Group '13. B: groups, and the context variant of a group'
    $fx = New-Fixture
    Set-File $fx 'sections/footer-group.json' '{ "sections": {}, "order": [] }'
    Set-File $fx 'sections/footer-group.context.nl-gb.json' '{ "sections": {}, "order": [] }'
    Set-File $fx 'sections/unused-group.json' '{ "sections": {}, "order": [] }'
    Set-File $fx 'layout/theme.liquid' "{% sections 'footer-group' %}"
    Set-File $fx 'templates/index.json' '{ "sections": {}, "order": [] }'
    $r = Invoke-Checker -Root $fx
    Assert-NoMatch $r.Text 'footer-group' 'a called group, and its two-part-locale context variant, are not uncalled'
    Assert-Match $r.Text 'unused-group' 'a group nothing calls is listed'
    Assert-Equal 0 $r.Code 'and is a warning'

    Write-Group '14. a section inside a group is a reference'
    $fx = New-Fixture
    Set-File $fx 'sections/logo-bar.liquid' '<div>x</div>'
    Set-File $fx 'sections/header-group.json' '{ "sections": { "l_1": { "type": "logo-bar" } }, "order": ["l_1"] }'
    Set-File $fx 'layout/theme.liquid' "{% sections 'header-group' %}"
    Set-File $fx 'templates/index.json' '{ "sections": {}, "order": [] }'
    $r = Invoke-Checker -Root $fx -WarningsAsErrors
    Assert-Equal 0 $r.Code 'logo-bar is called through the group'

    # ---------------------------------------------------------------------------------------------------
    Write-Group '15. JSON shape: banner and // lines tolerated'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' "/* generated */`n{`n  `"sections`": {`n    `"hero_1`": { `"type`": `"hero`" }`n    // `"old_1`": { `"type`": `"long-gone`" }`n  },`n  `"order`": [`"hero_1`"]`n}"
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'a banner and a commented-out section are fine'
    Assert-NoMatch $r.Text 'long-gone' 'the commented-out type is not a reference'

    Write-Group '16. C: a trailing comma is a warning, and the file is still read'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' "{`n  `"sections`": {`n    `"hero_1`": { `"type`": `"hero`" },`n    `"x_1`": { `"type`": `"nothing-here`" },`n  },`n  `"order`": [`"hero_1`",]`n}"
    $r = Invoke-Checker -Root $fx
    Assert-Match $r.Text 'comma directly before' 'the trailing comma is reported'
    Assert-Equal 1 $r.Code 'and the missing section behind it is still found (exit 1 from A, not from C)'
    Assert-Match $r.Text 'nothing-here' 'the reference was read despite the comma'

    Write-Group '17. D: an unparseable file is an ERROR, never skipped silently'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' $HeroTpl
    Set-File $fx 'templates/broken.json' '{ "sections": { "a": { "type": "hero" '
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'a template that cannot be parsed exits 1'
    Assert-Match $r.Text 'templates/broken.json' 'and is named'

    Write-Group '18. D: an empty file is nothing to check, not a failure'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' $HeroTpl
    Set-File $fx 'templates/empty.json' ''
    Set-File $fx 'templates/banner-only.json' '/* only a banner */'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'empty and banner-only files exit 0'

    Write-Group '19. E: a raw control character inside a string'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' ('{' + "`n" + '  "sections": {' + "`n" + '    "hero_1": { "type": "hero", "settings": { "t": "line one' + "`n" + 'line two" } }' + "`n" + '  },' + "`n" + '  "order": ["hero_1"]' + "`n" + '}')
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'a raw newline inside a string is an error'
    Assert-Match $r.Text 'newline (0x0A)' 'the character is named'
    Assert-Match $r.Text 'templates/index.json line 3' 'with the line it is on (calibrated: the line the newline ends)'
    $swallowed = $false
    try { $null = ('{ "a": "x' + "`n" + 'y" }') | ConvertFrom-Json -ErrorAction Stop; $swallowed = $true } catch { $swallowed = $false }
    Write-Host ('  [INFO] this PowerShell''s ConvertFrom-Json accepts the raw newline: ' + $swallowed + ' (true on 5.1, which is why E exists)') -ForegroundColor DarkGray

    Write-Group '20. E: escapes, layout whitespace and a quote in a banner are NOT findings'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    $good = '/* Do not edit "this" file */' + "`n" + '{' + "`n" + "`t" + '"sections": {' + "`n" + "`t`t" + '"hero_1": { "type": "hero", "settings": { "t": "a\nb\tc \"q\"" } }' + "`n" + "`t" + '},' + "`n" + "`t" + '"order": ["hero_1"]' + "`n" + '}'
    Set-File $fx 'templates/index.json' $good
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'escaped \n and \t, tabs outside strings, and quotes in the banner are clean'
    Assert-Match $r.Text 'Summary: 0 error(s)' 'and the summary agrees'

    Write-Group '21. block comment is NOT stripped from inside a string value'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/index.json' '{ "sections": { "hero_1": { "type": "hero", "settings": { "css": "/* a */ .x { color: red }" } } }, "order": ["hero_1"] }'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'a string holding a comment is parsed as the file Shopify reads'

    # ---------------------------------------------------------------------------------------------------
    Write-Group '22. the allowlist: -AllowMissing keeps the finding visible'
    $fx = New-Fixture
    Set-File $fx 'sections/hero.liquid' '<div>hero</div>'
    Set-File $fx 'templates/page.old.json' '{ "sections": { "w_1": { "type": "parked-landing" } }, "order": ["w_1"] }'
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'without an allowlist the finding is an error'
    $r = Invoke-Checker -Root $fx -AllowMissing @('parked-landing')
    Assert-Equal 0 $r.Code 'with -AllowMissing the gate is green'
    Assert-Match $r.Text '[KNOWN] ''parked-landing''' 'but the finding shows as KNOWN'
    Assert-Match $r.Text 'templates/page.old.json' 'with who calls it'

    Write-Group '23. the allowlist: the optional Get-ThemeRefsAllowedMissing seam, with its reason'
    Set-File $fx 'scripts/repo-config.ps1' "function Get-ThemeRefsAllowedMissing { return @{ 'parked-landing' = 'owner decision pending' } }"
    $r = Invoke-Checker -Root $fx
    Assert-Equal 0 $r.Code 'the seam answer silences the exit code'
    Assert-Match $r.Text 'owner decision pending' 'and its reason is printed with the finding'
    Remove-Item -LiteralPath (Join-Path $fx 'scripts') -Recurse -Force
    $r = Invoke-Checker -Root $fx
    Assert-Equal 1 $r.Code 'a store without the seam (or without repo-config.ps1) accepts nothing'

    Write-Group '24. -Quiet prints the summary and the verdict only'
    $r = Invoke-Checker -Root $fx -Quiet
    Assert-Equal 1 $r.Code '-Quiet does not change the exit code'
    Assert-Match $r.Text 'Summary: 1 error(s)' 'the summary is there'
    Assert-NoMatch $r.Text '== A.' 'the per-category report is not'

    Write-Group '25. the lib is English, ASCII and honest about its seam'
    foreach ($p in @($Checker, $LibPath)) {
        $bytes = [System.IO.File]::ReadAllBytes($p)
        $nonAscii = @($bytes | Where-Object { $_ -gt 127 }).Count
        Assert-Equal 0 $nonAscii ("{0} is pure ASCII" -f (Split-Path -Leaf $p))
    }
    $hay = (Get-Content -LiteralPath $Checker -Raw) + (Get-Content -LiteralPath $LibPath -Raw)
    Assert-True (-not ($hay -match 'rev-parse --show-toplevel')) 'no --show-toplevel read of the repo root (the root comes from repo-root-lib)'
} finally {
    if (Test-Path -LiteralPath $Suite) { Remove-Item -LiteralPath $Suite -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host ("{0} passed, {1} failed" -f $script:pass, $script:fail) -ForegroundColor $(if ($script:fail -eq 0) { 'Green' } else { 'Red' })
if ($script:fail -gt 0) { exit 1 }
exit 0
