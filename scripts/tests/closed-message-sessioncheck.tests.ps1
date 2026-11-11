<#
.SYNOPSIS
    Tests for plugins/dkj-policy/extensions/bwj-development/hooks/closed-message-sessioncheck.ps1 -- the session check
    that reports a store whose asana-closed-message copy is missing, stale, or has no ASANA_PAT (#2871),
    a store config that states no Get-ResolvesExemptMatchers (#2959), and an Asana-linked issue still open
    after its -NoResolves pull request merged (#3945).

.DESCRIPTION
    What is pinned is WHEN it speaks: only in the two store repos and, for asana-closed-message alone,
    phone-factory (#3518), once per kind of gap, never on a secret
    list it could not read, and never when everything is in place. Each case runs the hook as a child
    process against a scratch fixture, with the repo slug, the secret names and the pull data passed in,
    so nothing here calls gh.

    Pure ASCII (repo convention for .ps1).
#>
$ErrorActionPreference = 'Continue'

$RepoRoot  = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$Hook      = Join-Path $RepoRoot 'plugins\dkj-policy\extensions\bwj-development\hooks\closed-message-sessioncheck.ps1'
$Templates = Join-Path $RepoRoot 'plugins\dkj-policy\extensions\bwj-development\templates'
# $PID and a guid in the fixture path: the test gate runs suites in parallel.
$Fixture   = Join-Path ([System.IO.Path]::GetTempPath()) "closed-message-sessioncheck-$PID-$([guid]::NewGuid().ToString('n'))"

. (Join-Path $PSScriptRoot '..\lib\fixture-git-lib.ps1')

$script:pass = 0
$script:fail = 0

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if ($Condition) { $script:pass++; Write-Host "  [PASS] $Name" -ForegroundColor Green }
    else            { $script:fail++; Write-Host "  [FAIL] $Name" -ForegroundColor Red }
}

function New-Store {
    <# A store checkout: -Copy places both templates, -Crlf writes them with CRLF, -Stale edits the script. #>
    param([string]$Label, [switch]$Copy, [switch]$Crlf, [switch]$Stale)
    $root = Join-Path $Fixture $Label
    New-Item -ItemType Directory -Force -Path (Join-Path $root '.github\workflows'), (Join-Path $root '.github\scripts') | Out-Null
    if ($Copy) {
        foreach ($p in @(@('asana-closed-message.yml', '.github\workflows'), @('asana-closed-message.ps1', '.github\scripts'),
                         @('asana-prio-label.yml', '.github\workflows'), @('asana-prio-label.ps1', '.github\scripts'))) {
            $text = [System.IO.File]::ReadAllText((Join-Path $Templates $p[0])) -replace "`r`n", "`n"
            if ($Crlf) { $text = $text -replace "`n", "`r`n" }
            if ($Stale -and $p[0] -like '*.ps1') { $text += "`n# an older copy`n" }
            [System.IO.File]::WriteAllText((Join-Path (Join-Path $root $p[1]) $p[0]), $text)
        }
    }
    return $root
}

function New-PullData {
    <# Finding 5's three gh reads as a fixture file (#3945). Empty by default, so no case calls gh. #>
    param([string]$Label, $Merged = @(), $Open = @(), $Issues = @())
    New-Item -ItemType Directory -Force -Path $Fixture | Out-Null
    $path = Join-Path $Fixture "pulls-$Label.json"
    $json = ConvertTo-Json -Depth 5 -InputObject @{ merged = @($Merged); open = @($Open); issues = @($Issues) }
    [System.IO.File]::WriteAllText($path, $json)
    return $path
}

function Invoke-Hook {
    <# ONE secret name: -File does not split a comma list into a [string[]], so two names would arrive as one. #>
    param([string]$Root, [string]$Slug, [string]$Secret, [string]$Pulls = $script:NoPulls)
    $hookArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Hook,
        '-RepoRootOverride', $Root, '-TemplateRootOverride', $Templates, '-RepoSlugOverride', $Slug,
        '-SecretNamesOverride', $Secret, '-PullDataOverride', $Pulls)
    $out = & powershell @hookArgs 2>&1 | ForEach-Object { "$_" }
    return [pscustomobject]@{ Text = ($out -join "`n"); Code = $LASTEXITCODE }
}

try {
    $script:NoPulls = New-PullData -Label 'none'
    $ok = New-Store -Label 'ok' -Copy
    $r = Invoke-Hook -Root $ok -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT'
    Assert-True ($r.Text.Trim() -eq '') 'a store with both copies and the secret is silent'
    Assert-True ($r.Code -eq 0) 'and exits 0'

    $crlf = New-Store -Label 'crlf' -Copy -Crlf
    $r = Invoke-Hook -Root $crlf -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT'
    Assert-True ($r.Text.Trim() -eq '') 'a copy checked out with CRLF is not stale'

    $none = New-Store -Label 'none'
    $r = Invoke-Hook -Root $none -Slug 'BWJ-Development/smartwatchbanden' -Secret 'CLAUDE_CODE_OATH_TOKEN'
    Assert-True ($r.Text -match '\[ERROR\] bwj-development: BWJ-Development/smartwatchbanden has no \.github/workflows/asana-closed-message\.yml and \.github/scripts/asana-closed-message\.ps1') 'the measured case (#2871): both files missing is one finding naming both'
    Assert-True ($r.Text -match 'has no ASANA_PAT secret') 'and the missing secret is its own finding'
    Assert-True ($r.Code -eq 0) 'a finding still exits 0'

    $stale = New-Store -Label 'stale' -Copy -Stale
    $r = Invoke-Hook -Root $stale -Slug 'BWJ-Development/xoxowildhearts' -Secret 'ASANA_PAT'
    Assert-True ($r.Text -match '\.github/scripts/asana-closed-message\.ps1 in BWJ-Development/xoxowildhearts differs from the template') 'a copy that differs from the template is reported'
    Assert-True ($r.Text -notmatch 'workflows/asana-closed-message\.yml in') 'and only the file that differs is named'

    # THE PRIO PAIR (#2945): reported on its own line, and the closed-message pair is not blamed for it.
    $noPrio = New-Store -Label 'no-prio' -Copy
    Remove-Item -LiteralPath (Join-Path $noPrio '.github\workflows\asana-prio-label.yml'), (Join-Path $noPrio '.github\scripts\asana-prio-label.ps1')
    $r = Invoke-Hook -Root $noPrio -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT'
    Assert-True ($r.Text -match '\[ERROR\] bwj-development: BWJ-Development/smartwatchbanden has no \.github/workflows/asana-prio-label\.yml and \.github/scripts/asana-prio-label\.ps1') 'a store missing only the prio pair is reported, naming that pair'
    Assert-True ($r.Text -notmatch 'asana-closed-message') 'and the closed-message pair, which is in place, is not named'
    Assert-True ($r.Code -eq 0) 'a finding still exits 0'

    $stalePrio = New-Store -Label 'stale-prio' -Copy
    [System.IO.File]::AppendAllText((Join-Path $stalePrio '.github\scripts\asana-prio-label.ps1'), "`n# an older copy`n")
    $r = Invoke-Hook -Root $stalePrio -Slug 'BWJ-Development/xoxowildhearts' -Secret 'ASANA_PAT'
    Assert-True ($r.Text -match '\.github/scripts/asana-prio-label\.ps1 in BWJ-Development/xoxowildhearts differs from the template') 'a prio script that differs from the template is reported'
    Assert-True ($r.Text -notmatch 'asana-closed-message' -and $r.Text -notmatch 'workflows/asana-prio-label\.yml in') 'and only that file is named'

    # THE RESOLVES-EXEMPT SEAM (#2959): a store config without Get-ResolvesExemptMatchers is reported; one
    # that defines it, or a store with no repo-config at all (every case above), is not.
    $noSeam = New-Store -Label 'no-seam' -Copy
    New-Item -ItemType Directory -Force -Path (Join-Path $noSeam 'scripts') | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $noSeam 'scripts\repo-config.ps1'),
        "function Get-RepoName { 'BWJ-Development/xoxowildhearts' }`n# function Get-ResolvesExemptMatchers { @() }`n")
    $r = Invoke-Hook -Root $noSeam -Slug 'BWJ-Development/xoxowildhearts' -Secret 'ASANA_PAT'
    Assert-True ($r.Text -match '\[ERROR\] bwj-development: BWJ-Development/xoxowildhearts states no Get-ResolvesExemptMatchers') 'the measured case (#2959): a store config without the seam is reported'
    Assert-True ($r.Text -match 'step 2 proposes the two matchers') 'and the finding names the adopt step that proposes it'
    Assert-True (@($r.Text -split "`n" | Where-Object { $_ -match '\[ERROR\]' }).Count -eq 1) 'a commented-out definition does not count, and nothing else is blamed'
    Assert-True ($r.Code -eq 0) 'a finding still exits 0'

    $seam = New-Store -Label 'seam' -Copy
    New-Item -ItemType Directory -Force -Path (Join-Path $seam 'scripts') | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $seam 'scripts\repo-config.ps1'),
        "function Get-RepoName { 'BWJ-Development/smartwatchbanden' }`r`n    function Get-ResolvesExemptMatchers {`r`n    return @()`r`n}`r`n")
    $r = Invoke-Hook -Root $seam -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT'
    Assert-True ($r.Text.Trim() -eq '') 'a store config that defines the seam (indented, CRLF) is silent'

    [System.IO.File]::WriteAllText((Join-Path $seam 'scripts\repo-config.ps1'), "function global:Get-ResolvesExemptMatchers { @() }`n")
    $r = Invoke-Hook -Root $seam -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT'
    Assert-True ($r.Text.Trim() -eq '') 'a scope-prefixed definition counts as stated'

    [System.IO.File]::WriteAllText((Join-Path $seam 'scripts\repo-config.ps1'), "function Get-ResolvesExemptMatchers-Old { @() }`n")
    $r = Invoke-Hook -Root $seam -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT'
    Assert-True ($r.Text -match 'states no Get-ResolvesExemptMatchers') 'a longer name that merely starts with the seam''s does not'

    $r = Invoke-Hook -Root $noSeam -Slug 'DKJ-Solutions/dkj-marketplace' -Secret 'ASANA_PAT'
    Assert-True ($r.Text.Trim() -eq '') 'and the seam is not asked of a repo that copies no workflow'

    $r = Invoke-Hook -Root $none -Slug 'BWJ-Development/smartwatchbanden' -Secret '<unreadable>'
    Assert-True ($r.Text -notmatch 'ASANA_PAT') 'a secret list it could not read is not reported as a missing secret'

    foreach ($slug in @('DKJ-Solutions/dkj-marketplace', 'someone/else')) {
        # A real list without ASANA_PAT, so silence here can only come from the repo name.
        $r = Invoke-Hook -Root $none -Slug $slug -Secret 'CLAUDE_CODE_OATH_TOKEN'
        Assert-True ($r.Text.Trim() -eq '') "silent outside the repos that copy a workflow: $slug"
    }

    # PHONE-FACTORY (#3518): adopted asana-closed-message alone, so that pair, the secret and the seam are
    # checked there, and the prio pair, which was not decided there, never is.
    $r = Invoke-Hook -Root $none -Slug 'BWJ-Development/phone-factory' -Secret 'CLAUDE_CODE_OATH_TOKEN'
    Assert-True ($r.Text -match 'phone-factory has no \.github/workflows/asana-closed-message\.yml and \.github/scripts/asana-closed-message\.ps1') 'phone-factory without the closed-message pair is reported'
    Assert-True ($r.Text -match 'phone-factory has no ASANA_PAT secret, so the asana-closed-message workflow cannot post on the Asana task\.') 'and its missing secret names the closed-message workflow alone'
    Assert-True ($r.Text -notmatch 'asana-prio-label') 'and the prio pair is never asked of it'

    $pf = New-Store -Label 'phone-factory' -Copy
    Remove-Item -LiteralPath (Join-Path $pf '.github\workflows\asana-prio-label.yml'), (Join-Path $pf '.github\scripts\asana-prio-label.ps1')
    $r = Invoke-Hook -Root $pf -Slug 'BWJ-Development/phone-factory' -Secret 'ASANA_PAT'
    Assert-True ($r.Text.Trim() -eq '') 'phone-factory with the closed-message pair and the secret is silent'

    $r = Invoke-Hook -Root $noSeam -Slug 'BWJ-Development/phone-factory' -Secret 'ASANA_PAT'
    Assert-True ($r.Text -match 'phone-factory states no Get-ResolvesExemptMatchers') 'and a phone-factory config without the seam is reported'
    Assert-True ($r.Text -notmatch 'asana-prio-label') 'without blaming the prio pair the fixture also holds'

    # OPEN AFTER ITS -NoResolves PR MERGED (#3945): the measured case is smartwatchbanden#1126 / PR #1144.
    $now = (Get-Date).ToUniversalTime()
    $recent = $now.AddDays(-1).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $old = $now.AddDays(-20).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $linked = "Body.`n<!-- asana-task: 1200000000000001 -->"
    $declared = "Ships #1126.`n<!-- resolves: none -->"
    $pulls = New-PullData -Label 'measured' `
        -Merged @(@{ number = 1144; headRefName = 'fix/1126-cart-badge'; body = $declared; mergedAt = $recent }) `
        -Issues @(@{ number = 1126; body = $linked })
    $r = Invoke-Hook -Root $ok -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT' -Pulls $pulls
    Assert-True ($r.Text -match '\[ERROR\] bwj-development: BWJ-Development/smartwatchbanden#1126 links an Asana task and is still open, though PR #1144') 'the measured case (#3945): an Asana-linked issue open after its -NoResolves PR merged is reported'
    Assert-True ($r.Text -match 'closes when its PR lands') 'and the finding states the rule'
    Assert-True ($r.Text -notmatch 'Ships #1126') 'and prints no PR body'
    Assert-True ($r.Code -eq 0) 'a finding still exits 0'

    $cases = @(
        @{ Name = 'an issue linking no Asana task closes under the ordinary gate, so it is not this finding'
           Merged = @(@{ number = 1144; headRefName = 'fix/1126-x'; body = $declared; mergedAt = $recent }); Open = @()
           Issues = @(@{ number = 1126; body = 'no task here' }) },
        @{ Name = 'a PR without the -NoResolves declaration is not read'
           Merged = @(@{ number = 1144; headRefName = 'fix/1126-x'; body = 'Closes #1126'; mergedAt = $recent }); Open = @()
           Issues = @(@{ number = 1126; body = $linked }) },
        @{ Name = 'an issue another OPEN PR is named for is still being built (#3059)'
           Merged = @(@{ number = 1144; headRefName = 'fix/1126-x'; body = $declared; mergedAt = $recent })
           Open = @(@{ headRefName = 'feat/1126-step-two' }); Issues = @(@{ number = 1126; body = $linked }) },
        @{ Name = 'a merge older than the window ages out'
           Merged = @(@{ number = 1144; headRefName = 'fix/1126-x'; body = $declared; mergedAt = $old }); Open = @()
           Issues = @(@{ number = 1126; body = $linked }) },
        @{ Name = 'an issue already closed is not in the open list, so nothing is said'
           Merged = @(@{ number = 1144; headRefName = 'fix/1126-x'; body = $declared; mergedAt = $recent }); Open = @(); Issues = @() }
    )
    foreach ($c in $cases) {
        $p = New-PullData -Label ([guid]::NewGuid().ToString('n')) -Merged $c.Merged -Open $c.Open -Issues $c.Issues
        $r = Invoke-Hook -Root $ok -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT' -Pulls $p
        Assert-True ($r.Text.Trim() -eq '') $c.Name
    }

    $r = Invoke-Hook -Root $ok -Slug 'BWJ-Development/smartwatchbanden' -Secret 'ASANA_PAT' -Pulls '<unreadable>'
    Assert-True ($r.Text.Trim() -eq '') 'a pull or issue list it could not read reports nothing'

    $r = Invoke-Hook -Root $ok -Slug 'DKJ-Solutions/dkj-marketplace' -Secret 'ASANA_PAT' -Pulls $pulls
    Assert-True ($r.Text.Trim() -eq '') 'and the finding is not asked of a repo outside the reach'

    # THE LIVE gh PATH (#3996): -PullDataOverride parses one object, so it never took Get-PullData's
    # per-list parse, where PS 5.1's ConvertFrom-Json wrapped each list as ONE element and the [int] cast
    # threw on every store session start. A stand-in gh.cmd first on PATH serves lists of TWO, the shape
    # that throws; one element would pass either way.
    $fakeGh = Join-Path $Fixture 'fake-gh'
    New-Item -ItemType Directory -Force -Path $fakeGh | Out-Null
    $two = @(
        @{ number = 1144; headRefName = 'fix/1126-cart-badge'; body = $declared; mergedAt = $recent },
        @{ number = 1145; headRefName = 'fix/1127-menu'; body = $declared; mergedAt = $recent })
    [System.IO.File]::WriteAllText((Join-Path $fakeGh 'merged.json'), (ConvertTo-Json -Depth 5 -InputObject $two))
    [System.IO.File]::WriteAllText((Join-Path $fakeGh 'open.json'),
        (ConvertTo-Json -Depth 5 -InputObject @(@{ headRefName = 'feat/9-a' }, @{ headRefName = 'feat/10-b' })))
    [System.IO.File]::WriteAllText((Join-Path $fakeGh 'issues.json'),
        (ConvertTo-Json -Depth 5 -InputObject @(@{ number = 1126; body = $linked }, @{ number = 1127; body = $linked })))
    [System.IO.File]::WriteAllText((Join-Path $fakeGh 'gh.cmd'), ("@echo off`r`n" +
        "if `"%1`"==`"issue`" (type `"%~dp0issues.json`" & exit /b 0)`r`n" +
        "if `"%6`"==`"merged`" (type `"%~dp0merged.json`" & exit /b 0)`r`n" +
        "type `"%~dp0open.json`"`r`nexit /b 0`r`n"))
    $savedPath = $env:PATH
    try {
        $env:PATH = "$fakeGh;$savedPath"
        $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook -RepoRootOverride $ok `
            -TemplateRootOverride $Templates -RepoSlugOverride 'BWJ-Development/xoxowildhearts' `
            -SecretNamesOverride 'ASANA_PAT' 2>&1 | ForEach-Object { "$_" }
    } finally { $env:PATH = $savedPath }
    $text = $out -join "`n"
    Assert-True ($text -notmatch 'skipped due to an error') 'the live gh path parses lists of two without throwing (#3996)'
    Assert-True (($text -match 'xoxowildhearts#1126 links') -and ($text -match 'xoxowildhearts#1127 links')) 'and reports each open-after-merge issue it read'

    # THE REAL ORIGIN READ, no slug override: an ssh origin naming a store is recognised as that store.
    $ssh = New-Store -Label 'ssh'
    Invoke-FixtureGitIn $ssh init -q
    Invoke-FixtureGitIn $ssh remote add origin 'git@github.com:BWJ-Development/smartwatchbanden.git'
    $out = & powershell -NoProfile -ExecutionPolicy Bypass -File $Hook -RepoRootOverride $ssh `
        -TemplateRootOverride $Templates -SecretNamesOverride 'ASANA_PAT' -PullDataOverride $script:NoPulls 2>&1 | ForEach-Object { "$_" }
    Assert-True (($out -join "`n") -match 'BWJ-Development/smartwatchbanden has no \.github/workflows') 'an ssh origin is read as owner/name and checked as a store'
} finally {
    if (Test-Path -LiteralPath $Fixture) { Remove-Item -Recurse -Force -LiteralPath $Fixture -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host "closed-message-sessioncheck: $script:pass passed, $script:fail failed"
# A BROKEN FIXTURE FAILS THE RUN (#1635): the ssh case reads a repo git init had to build.
$fixtureBroken = Write-FixtureGitSummary -Subject 'closed-message-sessioncheck.ps1'
if ($script:fail -gt 0 -or $fixtureBroken) { exit 1 }
exit 0
