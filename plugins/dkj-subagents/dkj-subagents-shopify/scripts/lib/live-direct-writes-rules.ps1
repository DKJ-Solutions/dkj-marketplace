<#
.SYNOPSIS
    The pure rules behind live-direct-writes.ps1 (#4289): which bot commit on the live deploy branch is a
    direct FILE write, how a git log is parsed, how an earlier report is recognised, and what the one issue
    a run opens says. No git call, no network, no repo access.

.DESCRIPTION
    Dot-source this file. Split out of the script for the same reason sync-rules.ps1 is split out of
    sync-main.ps1: the script reads git and talks to GitHub, so everything that can be wrong without
    either lives here where scripts/tests/shopify-live-direct-writes.tests.ps1 measures it.

    THE SIGNAL, MEASURED on the live deploy branch of a Git-connected store (25 bot commits over twelve
    days). Shopify's GitHub integration writes two body shapes:

        Theme last edited by: <person>          a theme-EDITOR save: settings/template JSON, no file
                                                list. The sanctioned route; it flows back via a PR.
        Changed by: <person>                    a FILE write with a 'Files:' list. A CLI push or an
          Files:                                admin code-editor save -- the body does not say which,
          - modified <path> (<person>)          and both bypass the branch flow, so both are flagged.

    So the rule is: a shopify[bot] commit whose body carries a 'Changed by:' line is a direct write, and
    one that carries 'Theme last edited by:' never is.

    No Set-StrictMode here: dot-sourcing would change the strict mode of the calling script.
    Pure ASCII (repo convention for .ps1): Windows PowerShell 5.1 reads a BOM-less script as ANSI.
#>

function Get-DirectWriteLabel {
    <# The label every issue this check opens carries, and the one the dedupe reads. A store that already
       runs the check keeps its dedupe history only while this stays what it was. #>
    return 'live-direct-write'
}

function Get-DirectWriteBotAuthor {
    <# The commit author Shopify's GitHub integration writes under. #>
    return 'shopify[bot]'
}

function Get-DirectWriteIssueAuthors {
    <# The accounts whose issues count for the dedupe: only markers THIS workflow wrote, so a
       hand-written marker cannot silence a report. The three spellings are what gh has answered. #>
    return @('github-actions', 'app/github-actions', 'github-actions[bot]')
}

function ConvertTo-DirectWritePlainText {
    <# Commit text lands in an issue body and on a console: strip what could close a fence, mention or hide
       text, collapse every whitespace run (a newline included) and drop the remaining control characters. #>
    param([AllowEmptyString()][string]$Text)
    $flat = (($Text -replace '[`@<>]', '') -replace '\s+', ' ')
    return ($flat -replace '[\x00-\x1f\x7f]', '').Trim()
}

function Get-DirectWriteEditor {
    <# The person a commit body attributes a FILE write to, or $null for anything else (an editor save,
       a human commit, an empty body). #>
    param([AllowEmptyString()][string]$Body)
    if ([string]::IsNullOrEmpty($Body)) { return $null }
    $m = [regex]::Match($Body, '(?m)^Changed by:[ \t]*(.+?)[ \t]*\r?$')
    if ($m.Success -and $m.Groups[1].Value) { return (ConvertTo-DirectWritePlainText $m.Groups[1].Value) }
    return $null
}

function Get-DirectWriteFiles {
    <# The '- modified <path> (<who>)' lines under 'Files:' in a direct-write body, made plain. #>
    param([AllowEmptyString()][string]$Body)
    if ([string]::IsNullOrEmpty($Body)) { return @() }
    $idx = [regex]::Match($Body, '(?m)^Files:[ \t]*\r?$')
    if (-not $idx.Success) { return @() }
    $tail = $Body.Substring($idx.Index + $idx.Length)
    return @([regex]::Matches($tail, '(?m)^-[ \t]+(.+?)[ \t]*\r?$') | ForEach-Object { ConvertTo-DirectWritePlainText $_.Groups[1].Value })
}

function ConvertFrom-DirectWriteGitLog {
    <# Parses `git log --format=%H%x1f%an%x1f%aI%x1f%s%x1f%b%x1e` output into objects. #>
    param([AllowEmptyString()][string]$Raw)
    $out = @()
    if ([string]::IsNullOrEmpty($Raw)) { return $out }
    foreach ($rec in ($Raw -split [char]0x1e)) {
        $rec = $rec.Trim("`r", "`n")
        if (-not $rec) { continue }
        $f = $rec -split [char]0x1f, 5
        if ($f.Count -lt 5) { continue }
        $out += [pscustomobject]@{ Sha = $f[0]; Author = $f[1]; Date = $f[2]; Subject = $f[3]; Body = $f[4] }
    }
    return $out
}

function Select-DirectWrites {
    <# The commits that are direct writes by the bot and that no earlier issue has reported yet. #>
    param([object[]]$Commits, [string[]]$Reported = @())
    $seen = @{}
    foreach ($s in $Reported) { if ($s) { $seen[$s.ToLowerInvariant()] = $true } }
    $hits = @()
    foreach ($c in $Commits) {
        if ($c.Author -ne (Get-DirectWriteBotAuthor)) { continue }
        if ($seen.ContainsKey($c.Sha.ToLowerInvariant())) { continue }
        if ($c.Body -match '(?m)^Theme last edited by:') { continue }
        $who = Get-DirectWriteEditor -Body $c.Body
        if (-not $who) { continue }
        $hits += [pscustomobject]@{
            Sha = $c.Sha; Date = $c.Date; Editor = $who; Files = (Get-DirectWriteFiles -Body $c.Body)
        }
    }
    return $hits
}

function Get-ReportedShas {
    <# Every sha named by a marker in the given issue bodies. #>
    param([string[]]$Bodies = @())
    $shas = @()
    foreach ($b in $Bodies) {
        if (-not $b) { continue }
        foreach ($m in [regex]::Matches($b, '<!-- live-direct-write:([0-9a-fA-F]{7,40}) -->')) {
            $shas += $m.Groups[1].Value
        }
    }
    return $shas
}

function Test-DirectWriteSince {
    <# A floor is a UTC date, or a UTC date and time, in the one shape git reads unambiguously. #>
    param([AllowEmptyString()][string]$Value)
    return [bool]($Value -match '^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}Z)?$')
}

function Test-DirectWriteRef {
    <# A ref handed to git log: a plain revision, never something git could read as an option. #>
    param([AllowEmptyString()][string]$Value)
    return [bool]($Value -match '^(?!-)[A-Za-z0-9._/~^-]+$')
}

function Test-DirectWriteRepo {
    <# owner/name, as GITHUB_REPOSITORY spells it. #>
    param([AllowEmptyString()][string]$Value)
    return [bool]($Value -match '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$')
}

function New-DirectWriteIssueText {
    <# Title and body of the one issue a run opens. #>
    param([object[]]$Hits, [string]$Repo)
    $editors = @($Hits | ForEach-Object { $_.Editor } | Sort-Object -Unique)
    $n = @($Hits).Count
    $noun = if ($n -eq 1) { 'commit' } else { 'commits' }
    $title = "Direct file write to the live theme outside the branch flow ($n $noun by $($editors -join ', '))"
    $lines = @(
        'A scheduled check (`.github/workflows/live-direct-writes.yml`, from dkj-subagents-shopify) found commits that Shopify''s GitHub integration wrote onto the live deploy branch with a `Changed by:` line: a **file** write to the live theme -- a `shopify theme push` or an admin code-editor save -- rather than a theme-editor save. Neither goes through the promotion or the hotfix lane, so no guard saw it.',
        ''
    )
    foreach ($h in $Hits) {
        $short = $h.Sha.Substring(0, [Math]::Min(8, $h.Sha.Length))
        $link = if ($Repo) { "[$short](https://github.com/$Repo/commit/$($h.Sha))" } else { $short }
        $lines += "### $link -- $($h.Editor), $($h.Date)"
        $lines += ''
        $lines += '`````text'
        if (@($h.Files).Count -gt 0) { $lines += $h.Files } else { $lines += '(no file list in the commit body)' }
        $lines += '`````'
        $lines += ''
    }
    $lines += '## What to do'
    $lines += ''
    $lines += '1. Ask the editor whether the write was intended, and from where it was run. A CLI push from a shell that loaded none of this repo''s guards is the gap this check exists to see.'
    $lines += '2. Make sure the change flows back to the trunk (the usual live-to-trunk back-flow PR), so the next promotion does not overwrite it.'
    $lines += '3. Close this issue once both are done. Closing does not re-report these commits.'
    $lines += ''
    foreach ($h in $Hits) { $lines += "<!-- live-direct-write:$($h.Sha) -->" }
    return [pscustomobject]@{ Title = $title; Body = ($lines -join "`n") }
}
