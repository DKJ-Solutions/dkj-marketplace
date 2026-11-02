<#
.SYNOPSIS
    Regression tests for the release-note form gate (issue #2812): Get-ReleaseNoteFormShape and
    Compare-ReleaseNoteForm in release-lib.ps1, the check script scripts/lint/check-release-note-form.ps1,
    and its call from open-pr.ps1 -GatesOnly -NoteTreeOnly.

.DESCRIPTION
    Dependency-free: no Pester needed, only PowerShell.

        powershell -NoProfile -ExecutionPolicy Bypass -File scripts/tests/release-note-form.tests.ps1

    THE NOTES UNDER TEST COME FROM THE REAL GENERATOR, Build-ReleaseNoteDraft, and are then edited the way
    a hand edit drifts. A note written as a literal here would be a third statement of the form, beside the
    generator and the check, and would go stale the day the form moves.

    Fixture paths carry $PID (repo convention): the test gate runs suites in parallel.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../..')).Path
$Script   = Join-Path $RepoRoot 'scripts/lint/check-release-note-form.ps1'
. (Join-Path $RepoRoot 'scripts/lib/command-probe-lib.ps1')
. (Join-Path $RepoRoot 'scripts/lib/seam-lib.ps1')
. (Join-Path $RepoRoot 'scripts/lib/release-lib.ps1')

$script:pass  = 0
$script:fail  = 0
$script:trees = @()
$script:emptyHome = Join-Path ([System.IO.Path]::GetTempPath()) ("noteform-$PID-home-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
New-Item -ItemType Directory -Path $script:emptyHome -Force | Out-Null
$script:trees += $script:emptyHome

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Message" -ForegroundColor DarkGreen }
    else { $script:fail++; Write-Host "  [FAIL] $Message" -ForegroundColor Red }
}

function New-Draft {
    param([hashtable]$Wording = @{}, [int]$Tier = 2, [switch]$NoAudienceItems)
    $items = if ($NoAudienceItems) { $null } else { "### Something shipped`n`nIt works now." }
    Build-ReleaseNoteDraft -Version '2.3.0' -Date '2026-10-05' -Type 'Minor' -Title 'A release' `
        -Wording $Wording -AudienceTier $Tier -TaskItems $items
}

function Invoke-Check {
    param([string]$Root, [string[]]$Extra = @())
    # An empty home, always: whether dkj-solutions is enabled must be the fixture's answer, never this machine's (#3752).
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Script -RootOverride $Root -UserHomeOverride $script:emptyHome @Extra 2>&1
    return [pscustomobject]@{ Exit = $LASTEXITCODE; Text = ($out | Out-String) }
}

function New-Tree {
    param([string]$Label, [string]$Config = '')
    $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("noteform-$PID-$Label-" + [guid]::NewGuid().ToString('N').Substring(0, 6))
    New-Item -ItemType Directory -Path (Join-Path $dir 'scripts') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $dir 'notes\1.x') -Force | Out-Null
    $cfg = "function Get-ReleaseNoteRoot { 'notes' }`n" + $Config
    [System.IO.File]::WriteAllText((Join-Path $dir 'scripts\repo-config.ps1'), $cfg)
    $script:trees += $dir
    return $dir
}

function Set-Note {
    param([string]$Dir, [string]$Version, [string]$Text)
    [System.IO.File]::WriteAllText((Join-Path $Dir "notes\1.x\$Version.md"), $Text, (New-Object System.Text.UTF8Encoding $false))
}

try {
    Write-Host "`n== 1. a note in the drafted form has no findings ==" -ForegroundColor Cyan
    Assert-True (@(Compare-ReleaseNoteForm -Text (New-Draft)).Count -eq 0) 'the default draft matches its own form'
    Assert-True (@(Compare-ReleaseNoteForm -Text (New-Draft -NoAudienceItems)).Count -eq 0) 'a draft with no audience section matches too -- the draft itself leaves that heading out'
    $nl = @{ Title = 'Releasenotities'; AudienceLabel = 'Voor wie'; SectionAudience = 'Wat er veranderde' }
    Assert-True (@(Compare-ReleaseNoteForm -Text (New-Draft -Wording $nl) -Wording $nl).Count -eq 0) 'a translated draft matches when the same Wording is passed'
    Assert-True (@(Compare-ReleaseNoteForm -Text (New-Draft -Tier 1) -AudienceTier 1).Count -eq 0) 'a tier-1 draft matches at tier 1'

    Write-Host "`n== 2. each kind of drift is found ==" -ForegroundColor Cyan
    $base = New-Draft
    $added = $base.TrimEnd() + "`n`n## What this release cost to make`n`nA lot.`n"
    Assert-True (@(Compare-ReleaseNoteForm -Text $added).Count -eq 1) 'an added section heading is found'
    $renamed = $base -replace '## What changed', '## Changes'
    Assert-True ((Compare-ReleaseNoteForm -Text $renamed) -match "section headings") 'a renamed section heading is found'
    $label = $base -replace '\*\*For whom:\*\*', '**Voor wie:**'
    Assert-True ((Compare-ReleaseNoteForm -Text $label) -match 'header labels') 'a translated header label is found'
    $title = $base -replace '# Release notes v', '# Releasenotities v'
    Assert-True ((Compare-ReleaseNoteForm -Text $title) -match '^title reads') 'a changed title line is found'
    $noTitle = $base -replace '(?m)^# .*$', ''
    Assert-True ((Compare-ReleaseNoteForm -Text $noTitle) -match '^no title line') 'a missing title line is found'
    $nlNote = New-Draft -Wording $nl
    Assert-True (@(Compare-ReleaseNoteForm -Text $nlNote).Count -eq 3) 'a translated note with no Wording seam is found three times: title, labels, headings'
    # THE TWO RETIRED ORGANISATIONAL SECTIONS (#3584), written back by hand, are drift like any other.
    $withOrg = $base.TrimEnd() + "`n`n## What it is worth`n`nTime.`n`n## What was still open at this release`n`nNothing.`n"
    Assert-True ((Compare-ReleaseNoteForm -Text $withOrg) -match 'section headings') 'the retired organisational sections, added back by hand, are found'

    Write-Host "`n== 3. headings written ABOUT the form are not the form ==" -ForegroundColor Cyan
    $quoted = $base.TrimEnd() + "`n`nThe old shape:`n`n``````markdown`n## For consumers`n``````" + "`n`n<!-- ## Not a heading`n## Nor this -->`n"
    Assert-True (@(Compare-ReleaseNoteForm -Text $quoted).Count -eq 0) 'a heading inside a code fence or an HTML comment is ignored'
    $bold = $base -replace '## What changed\r?\n', "## What changed`n`n**Nothing breaks on update.** Read on.`n"
    Assert-True (@(Compare-ReleaseNoteForm -Text $bold).Count -eq 0) 'a bold lead-in below the first section is content, not a header label'

    Write-Host "`n== 4. the script judges the NEWEST note only ==" -ForegroundColor Cyan
    $t = New-Tree -Label 'newest'
    Set-Note -Dir $t -Version '1.9.0' -Text $added
    Set-Note -Dir $t -Version '1.10.0' -Text $base
    $r = Invoke-Check -Root $t
    Assert-True ($r.Exit -eq 0) "a drifted OLDER note does not fail the check (exit $($r.Exit))"
    Assert-True ($r.Text -match '1\.10\.0\.md') 'the newest is chosen by version, not by name -- 1.10.0 over 1.9.0'
    $r = Invoke-Check -Root $t -Extra @('-Path', 'notes/1.x/1.9.0.md')
    Assert-True ($r.Exit -eq 1 -and $r.Text -match '\[DRIFT\]') '-Path judges the named note instead'
    Set-Note -Dir $t -Version '1.11.0' -Text $renamed
    $r = Invoke-Check -Root $t
    Assert-True ($r.Exit -eq 1 -and $r.Text -match '1\.11\.0\.md') 'a drifted NEWEST note fails with exit 1 and names the file'
    Assert-True ($r.Text -match 'Get-ReleaseNoteWording') 'and the failure names the one seam that may change the form'

    Write-Host "`n== 5. the repo's own seams set the expected form ==" -ForegroundColor Cyan
    $t2 = New-Tree -Label 'seam' -Config "function Get-ReleaseNoteWording { @{ SectionAudience = 'Changes' } }`n"
    Set-Note -Dir $t2 -Version '1.0.0' -Text $renamed
    Assert-True ((Invoke-Check -Root $t2).Exit -eq 0) 'a note renamed through Get-ReleaseNoteWording passes'
    Set-Note -Dir $t2 -Version '1.1.0' -Text $base
    Assert-True ((Invoke-Check -Root $t2).Exit -eq 1) 'and the plugin default fails there, because that repo drafts a different heading'
    # Get-ReleaseNoteSections IS RETIRED (#3584): a repo still answering all three is not read, so a note
    # carrying the organisational sections fails there too, and the plain draft passes.
    $t3 = New-Tree -Label 'sections' -Config "function Get-ReleaseNoteSections { @('Audience', 'Value', 'Open') }`n"
    Set-Note -Dir $t3 -Version '1.0.0' -Text $withOrg
    Assert-True ((Invoke-Check -Root $t3).Exit -eq 1) 'a three-section note fails even where the retired seam still answers all three'
    Set-Note -Dir $t3 -Version '1.1.0' -Text $base
    Assert-True ((Invoke-Check -Root $t3).Exit -eq 0) 'and the one-section draft passes there'

    Write-Host "`n== 6. nothing to judge is a pass ==" -ForegroundColor Cyan
    $t4 = New-Tree -Label 'empty'
    $r = Invoke-Check -Root $t4
    Assert-True ($r.Exit -eq 0 -and $r.Text -match 'nothing to judge') 'an empty note tree exits 0 and says why'

    Write-Host "`n== 7. open-pr -GatesOnly -NoteTreeOnly runs it ==" -ForegroundColor Cyan
    foreach ($copy in @('scripts/release/open-pr.ps1', 'plugins/dkj-policy/scripts/release/open-pr.ps1')) {
        $src = [System.IO.File]::ReadAllText((Join-Path $RepoRoot $copy))
        $start = $src.IndexOf('if ($GatesOnly) {')
        $end = $src.IndexOf('(-GatesOnly)."', $start)
        $region = if ($start -ge 0 -and $end -gt $start) { $src.Substring($start, $end - $start) } else { '' }
        Assert-True ($region -match 'if \(\$NoteTreeOnly\) \{[\s\S]*check-release-note-form\.ps1') "$copy runs the form check inside -GatesOnly, under -NoteTreeOnly"
    }

    Write-Host "`n== 8. the brand book's heading rules, where dkj-solutions is enabled (#3752) ==" -ForegroundColor Cyan
    Assert-True (@(Get-ReleaseNoteHeadingFindings -Text (New-Draft)).Count -eq 0) 'the drafted form keeps both rules by itself'
    $bt = [string][char]0x60
    $codeHead = (New-Draft) -replace '### Something shipped', ('### Drop ' + $bt + '.prose' + $bt)
    $hf = @(Get-ReleaseNoteHeadingFindings -Text $codeHead)
    Assert-True ($hf.Count -eq 1 -and $hf[0] -match 'code span' -and $hf[0] -match '^line \d+: the h3 ') 'a code span in an h3 is named, with its line and level (rule 7)'
    $longHead = (New-Draft) -replace '### Something shipped', '### Your pages will look different now'
    $hf = @(Get-ReleaseNoteHeadingFindings -Text $longHead)
    Assert-True ($hf.Count -eq 1 -and $hf[0] -match 'runs to 6 words') 'six words in a heading is one too many (rule 8)'
    Assert-True (@(Get-ReleaseNoteHeadingFindings -Text ("#### A fourth level heading may run long here`n`nWith " + $bt + 'code' + $bt + " in the body.")).Count -eq 0) 'an h4 and a code span in the body are not judged'
    $fenced = "## What changed`n`n" + ($bt * 3) + "`n# a comment line that is not a heading at all, and long`n" + ($bt * 3) + "`n"
    Assert-True (@(Get-ReleaseNoteHeadingFindings -Text $fenced).Count -eq 0) 'a # line inside a fenced code block is not a heading'

    $t5 = New-Tree -Label 'brand'
    Set-Note -Dir $t5 -Version '1.0.0' -Text $codeHead
    Assert-True ((Invoke-Check -Root $t5).Exit -eq 0) 'without dkj-solutions enabled the heading rules say nothing -- a BWJ repo keeps its own styling'
    New-Item -ItemType Directory -Path (Join-Path $t5 '.claude') -Force | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $t5 '.claude\settings.json'), '{ "enabledPlugins": { "dkj-solutions@dkj-marketplace": true } }')
    $r = Invoke-Check -Root $t5
    Assert-True ($r.Exit -eq 1 -and $r.Text -match '\[HEADING\]' -and $r.Text -match 'rule 7' -and $r.Text -notmatch '\[DRIFT\]') 'with it enabled the same note is refused under [HEADING], and its form is not called drift'
    Set-Note -Dir $t5 -Version '1.1.0' -Text (New-Draft)
    Assert-True ((Invoke-Check -Root $t5).Exit -eq 0) 'and the newest note is the only one judged: a clean 1.1.0 passes over the older 1.0.0'
} finally {
    foreach ($d in $script:trees) { Remove-Item -LiteralPath $d -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host "`n$($script:pass) passed, $($script:fail) failed." -ForegroundColor $(if ($script:fail) { 'Red' } else { 'Green' })
if ($script:fail -gt 0) { exit 1 }
exit 0
