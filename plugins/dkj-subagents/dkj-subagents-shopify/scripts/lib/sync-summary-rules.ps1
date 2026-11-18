<#
.SYNOPSIS
    The pure rules behind sync-summary.ps1 (#4289): which theme area a path belongs to, how a sync
    commit's subject is recognised, how git's name-status and log output is parsed, and the checks of
    the explanation block. No git call and no repo access.

.DESCRIPTION
    Dot-source this file. Split out of the script for the same reason sync-rules.ps1 is split out of
    sync-main.ps1: the script reads git, so everything that can be wrong without a repo lives here where
    scripts/tests/shopify-sync-summary.tests.ps1 measures it. The one thing the checks need from a repo --
    "does a template still point at this section?" -- is handed in as a script block.

    No Set-StrictMode here: dot-sourcing would change the strict mode of the calling script.
    Pure ASCII (repo convention for .ps1).
#>

# The field separator of the git format strings (%x1f). Windows PowerShell 5.1 has no backtick-u escape
# (that is PS 6+), so it is built from its code point.
function Get-SyncSummaryFieldSeparator {
    return [string][char]0x1f
}

function Get-SyncSummaryAreas {
    <#
    .SYNOPSIS
        The theme areas in the order in which they matter for "what changed": key (the directory) and the
        label printed above it.
    #>
    return @(
        [pscustomobject]@{ Key = 'sections';  Label = 'Sections (the building blocks of pages)' }
        [pscustomobject]@{ Key = 'templates'; Label = 'Templates (which sections sit on which page)' }
        [pscustomobject]@{ Key = 'snippets';  Label = 'Snippets' }
        [pscustomobject]@{ Key = 'layout';    Label = 'Layout' }
        [pscustomobject]@{ Key = 'blocks';    Label = 'Blocks' }
        [pscustomobject]@{ Key = 'assets';    Label = 'Assets (CSS/JS/images)' }
        [pscustomobject]@{ Key = 'locales';   Label = 'Locales (texts)' }
        [pscustomobject]@{ Key = 'config';    Label = 'Config (theme editor settings)' }
    )
}

function Get-SyncSummaryStatusLabel {
    <# The word for a one-letter git status; an unknown letter is returned as it is. #>
    param([string]$Status)
    switch ($Status) {
        'A' { return 'added' }
        'M' { return 'changed' }
        'D' { return 'removed' }
        'R' { return 'renamed' }
        default { return $Status }
    }
}

function Get-SyncSummaryAreaOf {
    <# The area key a path sits in ('' for a path in none of them). Case-insensitive, '/' separators. #>
    param([string]$Path)
    $p = ([string]$Path) -replace '\\', '/'
    foreach ($a in (Get-SyncSummaryAreas)) {
        if ($p.StartsWith($a.Key + '/', [System.StringComparison]::OrdinalIgnoreCase)) { return $a.Key }
    }
    return ''
}

function Test-SyncSummarySubject {
    <#
    .SYNOPSIS
        Whether a commit subject is that of a sync commit, by the pattern Get-ShopifySyncReferencePattern
        answers (default: Get-SyncDefaultReferencePattern in sync-rules.ps1). Matched against the SUBJECT,
        never through 'git log --grep', for the reason sync-rules.ps1 records (inbound #819).
    #>
    param([string]$Subject, [string]$Pattern)
    if (-not $Pattern) { return $false }
    return [bool]([string]$Subject -match $Pattern)
}

function Test-SyncSummaryPatternValid {
    <# Whether a seam answer compiles as a regex, so a consumer's typo degrades to the default. #>
    param([string]$Pattern)
    if (-not $Pattern) { return $false }
    try { $null = [regex]::Match('', $Pattern); return $true } catch { return $false }
}

function ConvertFrom-SyncSummaryLog {
    <#
    .SYNOPSIS
        The sync commits out of 'git log --format=%H%x1f%h%x1f%ad%x1f%an%x1f%s --date=short' lines,
        newest first as git printed them. A short line or a non-matching subject is skipped.
    #>
    param([object[]]$Lines, [string]$Pattern)
    $fs = Get-SyncSummaryFieldSeparator
    $res = New-Object System.Collections.ArrayList
    foreach ($line in @($Lines)) {
        if (-not $line) { continue }
        $p = ([string]$line) -split [regex]::Escape($fs)
        if ($p.Count -lt 5) { continue }
        if (Test-SyncSummarySubject -Subject $p[4] -Pattern $Pattern) {
            $null = $res.Add([pscustomobject]@{
                Sha = $p[0]; Short = $p[1]; Date = $p[2]; Author = $p[3]; Subject = $p[4]
            })
        }
    }
    return @($res)
}

function ConvertFrom-SyncSummaryNameStatus {
    <#
    .SYNOPSIS
        Rows (Status = first letter, Path = the LAST tab field, i.e. the new name of a rename, OldPath =
        the old name of a rename or copy, '' otherwise) out of 'git diff|show --name-status' lines. Paths
        are decoded with Convert-GitQuotedPath where that is loaded, because the script asks git for
        ASCII-quoted paths (language-layers.md, the READING rule). OldPath is kept because a renamed
        section's old name is gone just as a deleted one's is (#4301).
    #>
    param([object[]]$Lines)
    $rows = New-Object System.Collections.ArrayList
    $decode = [bool](Get-Command -Name 'Convert-GitQuotedPath' -CommandType Function -ErrorAction SilentlyContinue)
    foreach ($line in @($Lines)) {
        if (-not $line -or -not ([string]$line).Trim()) { continue }
        $parts = ([string]$line) -split "`t"
        if ($parts.Count -lt 2) { continue }
        $path = $parts[$parts.Count - 1]
        $old = if ($parts.Count -ge 3) { $parts[1] } else { '' }
        if ($decode) {
            $path = Convert-GitQuotedPath $path
            if ($old) { $old = Convert-GitQuotedPath $old }
        }
        $null = $rows.Add([pscustomobject]@{ Status = $parts[0].Substring(0, 1); Path = $path; OldPath = $old })
    }
    return @($rows)
}

function Format-SyncSummaryNames {
    <# 'a, b, c ... and N more' for the first Max names. #>
    param([string[]]$Names, [int]$Max = 12)
    $all = @($Names)
    $show = @($all | Select-Object -First $Max)
    $text = $show -join ', '
    $rest = $all.Count - $show.Count
    if ($rest -gt 0) { $text += (' ... and {0} more' -f $rest) }
    return $text
}

function ConvertFrom-SyncSummaryRange {
    <#
    .SYNOPSIS
        Splits '<base>...<head>' into its halves, or returns $null when it is not that shape.
    .DESCRIPTION
        No half may start with '-': git would read it as an option instead of a ref. A single dot is
        allowed (v2.47.0); two in a row are not, because they cannot be part of a ref and are the
        separator itself.
    #>
    param([string]$Range)
    if ([string]$Range -notmatch '^(?<base>(?!-)(?:(?!\.\.)\S)+)\.\.\.(?<head>(?!-)(?:(?!\.\.)\S)+)$') { return $null }
    return [pscustomobject]@{ Base = $Matches['base']; Head = $Matches['head'] }
}

function Test-SyncSummaryCommitArg {
    <# Whether -Commit is safe to hand to git as a revision: non-empty, no whitespace, not an option. #>
    param([string]$Commit)
    return ([string]$Commit -match '^[0-9A-Za-z_][^\s]*$')
}

function Get-SyncSummaryDeployRange {
    <#
    .SYNOPSIS
        The back-flow range for -SinceTrunk: 'origin/<trunk>...origin/<deploy branch>', built only from the
        store's own seam answers. Returns { Ok; Range; Reason }.
    .DESCRIPTION
        Unanswered Get-ShopifyLiveDeployBranch means the live theme is not Git-connected, so there IS no
        range to build and the answer is a refusal that names the seam -- never a guess at a branch name.
        Both names are held to the plain-ref pattern (Test-LivePromotionRef, live-push-rules.ps1) before
        they are composed into anything git reads.
    #>
    param([string]$Trunk, [string]$DeployBranch)
    $t = if ($Trunk) { [string]$Trunk } else { 'main' }
    $d = [string]$DeployBranch
    if (-not $d) {
        return [pscustomobject]@{ Ok = $false; Range = ''; Reason = 'Get-ShopifyLiveDeployBranch is not answered in scripts/repo-config.ps1, so there is no deploy branch to compare the trunk with. Pass -Range explicitly.' }
    }
    if (-not (Test-LivePromotionRef $t) -or -not (Test-LivePromotionRef $d)) {
        return [pscustomobject]@{ Ok = $false; Range = ''; Reason = 'The trunk or Get-ShopifyLiveDeployBranch is not a plain branch name (letters, digits, . _ / -). Pass -Range explicitly.' }
    }
    if ($d -ieq $t) {
        return [pscustomobject]@{ Ok = $false; Range = ''; Reason = 'Get-ShopifyLiveDeployBranch names the trunk itself. It should name the branch the live theme is connected to.' }
    }
    return [pscustomobject]@{ Ok = $true; Range = "origin/$t...origin/$d"; Reason = '' }
}

function Get-SyncSummaryFindings {
    <#
    .SYNOPSIS
        The explanation block: the things in a sync that matter, as rows { Kind; Level; Message; Detail }.

    .DESCRIPTION
        -Files           rows { Status; Path } (ConvertFrom-SyncSummaryNameStatus).
        -ReferenceLookup a script block taking a section name and returning the template paths that still
                         point at it IN THE STATE AFTER THE SYNC (empty or $null for none). The caller
                         owns the git call; here it is a parameter so the checks run without a repo.

        Kinds, in the order they are reported:
          removed-section-referenced  a section is gone -- deleted, or renamed away from its old name --
                                      and a template still names it (Level 'alert')
          removed-section-clean       a section is gone and nothing points at it (Level 'info', NOT a
                                      finding: it does not count towards "something to look at")
          new-section                 sections nobody asked for in this repo ('new')
          settings                    config/settings_data* changed ('notice')
          removed-template            a page layout is gone ('notice')
    #>
    param(
        [object[]]$Files,
        [scriptblock]$ReferenceLookup,
        [int]$MaxFiles = 12
    )
    $out = New-Object System.Collections.ArrayList
    $rows = @($Files)

    # A section's name is gone when it is deleted, and equally when it is renamed (status R, #4301): a
    # template still naming the OLD name fails the same way. A rename that keeps the name inside sections/
    # (only the extension or the case of a directory moved) leaves the name in place and is not counted.
    $removedSections = New-Object System.Collections.ArrayList
    foreach ($r in $rows) {
        if ($r.Status -eq 'D' -and (Get-SyncSummaryAreaOf $r.Path) -eq 'sections') {
            $null = $removedSections.Add([pscustomobject]@{ Name = [System.IO.Path]::GetFileNameWithoutExtension($r.Path); NewName = '' })
        }
        elseif ($r.Status -eq 'R' -and $r.PSObject.Properties['OldPath'] -and $r.OldPath -and (Get-SyncSummaryAreaOf $r.OldPath) -eq 'sections') {
            $oldName = [System.IO.Path]::GetFileNameWithoutExtension($r.OldPath)
            $newName = [System.IO.Path]::GetFileNameWithoutExtension($r.Path)
            if ((Get-SyncSummaryAreaOf $r.Path) -eq 'sections' -and $newName -ceq $oldName) { continue }
            $null = $removedSections.Add([pscustomobject]@{ Name = $oldName; NewName = $(if ((Get-SyncSummaryAreaOf $r.Path) -eq 'sections') { $newName } else { ([string]$r.Path) -replace '\\', '/' }) })
        }
    }
    foreach ($rs in $removedSections) {
        $s = $rs.Name
        $how = if ($rs.NewName) { "was renamed to '{0}'" -f $rs.NewName } else { 'was removed' }
        $hits = @()
        if ($ReferenceLookup) { $hits = @(& $ReferenceLookup $s | Where-Object { $_ }) }
        if ($hits.Count) {
            $null = $out.Add([pscustomobject]@{
                Kind = 'removed-section-referenced'; Level = 'alert'
                Message = ("Section '{0}' {1}, but these template(s) still point at the old name:" -f $s, $how)
                Detail = @(@($hits | Select-Object -First 6) + 'Such a page still returns HTTP 200 but does not render the section.')
            })
        } else {
            $null = $out.Add([pscustomobject]@{
                Kind = 'removed-section-clean'; Level = 'info'
                Message = ("Section '{0}' {1} and no template points at the old name any more -- a clean removal." -f $s, $how)
                Detail = @()
            })
        }
    }

    $newSections = @($rows | Where-Object { $_.Status -eq 'A' -and (Get-SyncSummaryAreaOf $_.Path) -eq 'sections' } |
        ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Path) })
    if ($newSections.Count) {
        $null = $out.Add([pscustomobject]@{
            Kind = 'new-section'; Level = 'new'
            Message = ("{0} new section(s) from the admin -- work nobody requested through this repo:" -f $newSections.Count)
            Detail = @($newSections -join ', ')
        })
    }

    $settings = @($rows | Where-Object { ([string]$_.Path) -like 'config/settings_data*' })
    if ($settings.Count) {
        $null = $out.Add([pscustomobject]@{
            Kind = 'settings'; Level = 'notice'
            Message = ("Theme editor settings changed: {0}" -f ((@($settings | ForEach-Object { (([string]$_.Path) -replace '\\', '/') -replace '^.*/', '' })) -join ', '))
            Detail = @('These are switches somebody turned in the editor, not code.')
        })
    }

    $removedTemplates = @($rows | Where-Object { $_.Status -eq 'D' -and (Get-SyncSummaryAreaOf $_.Path) -eq 'templates' })
    if ($removedTemplates.Count) {
        $null = $out.Add([pscustomobject]@{
            Kind = 'removed-template'; Level = 'notice'
            Message = ("{0} template(s) removed -- a page layout is gone:" -f $removedTemplates.Count)
            Detail = @(Format-SyncSummaryNames -Names @($removedTemplates | ForEach-Object { (([string]$_.Path) -replace '\\', '/') -replace '^.*/', '' }) -Max $MaxFiles)
        })
    }
    return @($out)
}
