<#
.SYNOPSIS
    The pure half of hooks/guard-reach-reason.ps1: which 'gh issue create' / 'gh issue edit' in a shell
    command puts the reach label on an issue (Get-ReachLabelInvocation), and whether an issue body
    carries the written reason that label needs (Test-ReachReasonSection).

.DESCRIPTION
    INBOUND #4057 (the owner, November 13, 2026): a session stops and thinks before it puts the reach
    label on an issue, and the reasoning is visible in the issue itself. Measured in smartwatchbanden:
    one developer's sessions filed 35 issues with 'minor' since November 1, and none of the 35 bodies said
    why management or the commissioner would notice the defect -- the test report-issue step 1 sets. The
    label decides whether an Asana card exists and whether the work shows on the business-facing
    worklist, so a careless label is noise on the management board, and with no reason written down
    nobody could check the call afterwards.

    THE SECTION is a heading 'Why <reach label>' at level 2 or 3, matched without regard to case, with at
    least one line of text under it before the next heading or the end. A heading with nothing under it
    is not a reason.

    WHAT IT RECOGNISES. The tokeniser is stale-paste-block-rules.ps1's ConvertTo-ShellSegments, so the
    same reach applies: a segment whose first token (after '&', '.' or a 'VAR=value' prefix) is gh or
    gh.exe, followed by the bare tokens 'issue' and 'create' or 'edit'. The label is read from
    --label/-l on a create and --add-label on an edit, each value split on commas. The body is read from
    --body/-b (inline) or --body-file/-F (a path, or '-' for stdin). gh's flags are read case-sensitively,
    and a short flag may carry its value attached ('-lminor'). Every value flag gh issue create and edit
    take is consumed with its value, so '--milestone 3' never reads as issue 3.

    AN INLINE BODY IS READ AS WRITTEN, with one translation: a PowerShell "`n" or "`r`n" escape inside it
    becomes a line break, so a one-line double-quoted PowerShell body is read the way gh receives it.

    AN ACCIDENT GUARD, NOT AN ADVERSARIAL ONE, with the tokeniser's reach: pwsh -Command "...", a value
    taken from a variable or $env, 'gh api', and a wrapper are out of reach.

    Pure ASCII (repo convention for .ps1). Tested by scripts/tests/guard-reach-reason.tests.ps1 in the
    source repo -- change one, run the other.
#>

. (Join-Path $PSScriptRoot 'stale-paste-block-rules.ps1')

function Get-ReachLabelInvocation {
    <#
        Pure: the gh issue create / edit calls in -Command that put -ReachLabel on an issue, each as
        Kind ('create' | 'edit'), Numbers (the issues an edit names, empty on a create), Repo (--repo/-R,
        else the repo of an issue URL, else ''), BodySource ('inline' | 'file' | 'stdin' | 'elsewhere' --
        a create's --template, --recover, --web or --editor -- | 'none'), Body (the inline text), BodyFile
        (the path) and BodyDynamic ($true where the inline text holds a '$' or opens with '(', so it is
        built at run time and is not what gh receives). An empty list where no call adds the label.
    #>
    param([AllowEmptyString()][string]$Command = '', [Parameter(Mandatory = $true)][string]$ReachLabel)

    $valueFlags = @{
        create = @('--assignee', '-a', '--body', '-b', '--body-file', '-F', '--label', '-l', '--milestone', '-m',
                   '--project', '-p', '--recover', '--template', '-T', '--title', '-t', '--repo', '-R', '--type')
        edit   = @('--add-assignee', '--add-label', '--add-project', '--body', '-b', '--body-file', '-F',
                   '--milestone', '-m', '--remove-assignee', '--remove-label', '--remove-project', '--title', '-t',
                   '--repo', '-R', '--type')
    }
    $labelFlags = @{ create = @('--label', '-l'); edit = @('--add-label') }

    $found = New-Object System.Collections.Generic.List[object]
    foreach ($segment in @(ConvertTo-ShellSegments -Command $Command)) {
        $tok = @($segment)
        $at = 0
        while ($at -lt $tok.Count -and -not $tok[$at].Quoted -and ($tok[$at].Text -eq '&' -or $tok[$at].Text -eq '.' -or $tok[$at].Text -match '\A[A-Za-z_][A-Za-z0-9_]*=')) { $at++ }
        if ($at + 2 -ge $tok.Count) { continue }
        if (($tok[$at].Text -split '[\\/]')[-1] -notmatch '(?i)\Agh(?:\.exe)?\z') { continue }
        if ($tok[$at + 1].Quoted -or $tok[$at + 1].Text -ne 'issue' -or $tok[$at + 2].Quoted) { continue }
        $kind = $tok[$at + 2].Text
        if ($kind -cne 'create' -and $kind -cne 'edit') { continue }

        $adds = $false
        $repo = ''
        $source = 'none'
        $body = ''
        $bodyFile = ''
        $numbers = New-Object System.Collections.Generic.List[int]
        for ($k = $at + 3; $k -lt $tok.Count; $k++) {
            $t = $tok[$k].Text
            $flag = $null
            $value = $null
            if (-not $tok[$k].Quoted -and $t.StartsWith('-')) {
                if ($t -match '\A(--[A-Za-z][A-Za-z-]*)=(.*)\z') { $flag = $Matches[1]; $value = $Matches[2] }
                elseif ($valueFlags[$kind] -ccontains $t) { $flag = $t }
                elseif ($t -cmatch '\A(-[A-Za-z])(.+)\z' -and $valueFlags[$kind] -ccontains $Matches[1]) { $flag = $Matches[1]; $value = $Matches[2] }
                else {
                    # A create that writes its body in a browser or an editor carries none in the call.
                    if ($kind -ceq 'create' -and $source -eq 'none' -and $t -cmatch '\A(?:--web|-w|--editor|-e)\z') { $source = 'elsewhere' }
                    continue
                }
                if (-not ($valueFlags[$kind] -ccontains $flag)) { continue }
                if ($null -eq $value) { if ($k + 1 -lt $tok.Count) { $k++; $value = $tok[$k].Text } else { $value = '' } }
                if ($labelFlags[$kind] -ccontains $flag) {
                    foreach ($l in ([string]$value -split ',')) { if ($l.Trim() -ieq $ReachLabel) { $adds = $true } }
                } elseif ($flag -ceq '--repo' -or $flag -ceq '-R') {
                    $repo = ([string]$value).Trim()
                } elseif ($flag -ceq '--body' -or $flag -ceq '-b') {
                    $source = 'inline'; $body = [string]$value
                } elseif ($flag -ceq '--body-file' -or $flag -ceq '-F') {
                    if (([string]$value).Trim() -eq '-') { $source = 'stdin'; $bodyFile = '' }
                    else { $source = 'file'; $bodyFile = ([string]$value).Trim() }
                } elseif (($flag -ceq '--template' -or $flag -ceq '-T' -or $flag -ceq '--recover') -and $source -eq 'none') {
                    $source = 'elsewhere'
                }
                continue
            }
            if ($kind -ceq 'edit') {
                $target = ConvertTo-IssueCloseTarget -Text $t
                if ($target) {
                    if ($target.Repo -and -not $repo) { $repo = $target.Repo }
                    if (-not $numbers.Contains($target.Number) -and $numbers.Count -lt 20) { $numbers.Add($target.Number) }
                }
            }
        }
        if (-not $adds) { continue }
        if ($repo -and $repo -notmatch '\A[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9._-]+\z') { $repo = '' }
        $dynamic = $false
        if ($source -eq 'inline') {
            $body = ($body -replace '`r`n', "`n") -replace '`n', "`n"
            # A body built at run time ('$body', "$(cat b.md)", '(Get-Content b.md -Raw)') is not the text gh
            # receives, so its absence of a section proves nothing (Victor's review, #4057).
            $dynamic = ($body.Contains('$') -or $body.TrimStart().StartsWith('('))
        }
        $found.Add([pscustomobject]@{
            Kind = $kind; Numbers = @($numbers.ToArray()); Repo = $repo
            BodySource = $source; Body = $body; BodyFile = $bodyFile; BodyDynamic = $dynamic
        })
    }
    # Unrolled on purpose: every caller wraps the result in @(), and a ',' here would hand it a list
    # holding one list, so an empty answer would count as one call.
    return @($found.ToArray())
}

function Test-ReachReasonSection {
    <#
        Pure: $true where -Body carries a 'Why <reach label>' heading (## or ###, any case) with at least
        one line of text under it before the next heading or the end.
    #>
    param([AllowEmptyString()][AllowNull()][string]$Body = '', [Parameter(Mandatory = $true)][string]$ReachLabel)

    $lines = @(([string]$Body -replace "`r`n", "`n") -split "`n")
    $heading = '(?i)\A\s{0,3}#{2,3}\s+Why\s+' + [regex]::Escape($ReachLabel.Trim()) + '\s*[:?]?\s*#*\s*\z'
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -notmatch $heading) { continue }
        for ($j = $i + 1; $j -lt $lines.Count; $j++) {
            if ($lines[$j] -match '\A\s{0,3}#{1,6}\s') { break }
            if ($lines[$j].Trim()) { return $true }
        }
    }
    return $false
}
